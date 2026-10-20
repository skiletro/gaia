#!/usr/bin/env python3
"""Publish discovered Knot repositories as an atomic cgit repository list."""

from __future__ import annotations

import argparse
import json
import os
from pathlib import Path
import re
import stat
import sys
import tempfile
import unicodedata
from urllib.error import HTTPError, URLError
from urllib.parse import quote, unquote, urlencode, urlsplit
from urllib.request import Request, urlopen


class TemporaryFailure(Exception):
    """Metadata could not be refreshed; a previous publication may be retained."""


class Unpublish(Exception):
    """Metadata authoritatively disappeared or is unsafe to publish."""


def clean_text(value: str) -> str:
    return "".join(
        " " if unicodedata.category(char).startswith("C") or char in "\u2028\u2029" else char
        for char in value
    ).strip()


def hostname(value: str) -> bool:
    return (
        isinstance(value, str)
        and len(value) <= 253
        and all(
            re.fullmatch(r"[A-Za-z0-9](?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?", label)
            for label in value.split(".")
        )
    )


def base_url(value: str, *, https: bool = False) -> str:
    try:
        parsed = urlsplit(value)
        valid = (
            parsed.scheme in (("https",) if https else ("http", "https"))
            and parsed.hostname
            and hostname(parsed.hostname)
            and parsed.username is None
            and parsed.password is None
            and not parsed.query
            and not parsed.fragment
            and parsed.port != 0
            and clean_text(value) == value
            and not any(char.isspace() for char in value)
            and "\\" not in value
        )
    except ValueError as error:
        raise Unpublish("invalid service URL") from error
    if not valid:
        raise Unpublish("invalid service URL")
    return value.rstrip("/")


def did_document_url(did: str, plc_url: str) -> str:
    if not isinstance(did, str):
        raise Unpublish("invalid DID")
    if re.fullmatch(r"did:plc:[a-z2-7]{24}", did):
        return f"{plc_url}/{did}"
    segment_pattern = r"(?:[A-Za-z0-9._-]|%[0-9A-Fa-f]{2})+"
    if re.fullmatch(rf"did:web:{segment_pattern}(?::{segment_pattern})*", did) is None:
        raise Unpublish("unsupported or invalid DID")
    try:
        parts = [unquote(part, errors="strict") for part in did[len("did:web:"):].split(":")]
    except UnicodeError as error:
        raise Unpublish("invalid did:web encoding") from error
    authority = parts[0]
    origin = base_url(f"https://{authority}", https=True)
    if urlsplit(origin).path:
        raise Unpublish("invalid did:web authority")
    segments = parts[1:]
    if any(
        not segment or segment in (".", "..")
        or any(char in segment for char in "/\\?#")
        or clean_text(segment) != segment
        or any(char.isspace() for char in segment)
        for segment in segments
    ):
        raise Unpublish("invalid did:web path")
    path = "/".join(quote(segment, safe="") for segment in segments)
    return f"{origin}/{path + '/' if path else '.well-known/'}did.json"


def valid_rkey(value: str) -> bool:
    return (
        isinstance(value, str)
        and value not in (".", "..")
        and re.fullmatch(r"[A-Za-z0-9._~:-]{1,512}", value) is not None
    )


def valid_handle(value: str, plc_url: str) -> bool:
    if not isinstance(value, str):
        return False
    if value.startswith("did:"):
        try:
            did_document_url(value, plc_url)
            return True
        except Unpublish:
            return False
    return (
        hostname(value) and "." in value
        and re.fullmatch(r"[A-Za-z][A-Za-z0-9-]*", value.rsplit(".", 1)[1]) is not None
    )


def request_json(url: str, *, authoritative: bool = False) -> dict:
    request = Request(url, headers={
        "User-Agent": "gaia-tangled-indexer/1.0",
        "Accept": "application/json",
    })
    try:
        with urlopen(request, timeout=15) as response:
            # Do not accept a redirect to credentials, non-HTTP protocols, or HTTP
            # when the identity document advertised HTTPS.
            redirected = urlsplit(response.geturl())._replace(query="").geturl()
            base_url(redirected, https=urlsplit(url).scheme == "https")
            result = json.load(response)
    except HTTPError as error:
        if authoritative and error.code == 404:
            raise Unpublish("record not found (HTTP 404)") from error
        raise TemporaryFailure(f"HTTP {error.code}") from error
    except (URLError, OSError, ValueError) as error:
        raise TemporaryFailure(f"request failed ({type(error).__name__})") from error
    if not isinstance(result, dict):
        raise TemporaryFailure("response is not a JSON object")
    return result


def scan_repositories(root: Path, plc_url: str) -> dict[str, Path]:
    root = root.resolve(strict=True)
    if clean_text(str(root)) != str(root):
        raise ValueError("repository root contains control characters")
    repositories = {}
    # Errors opening or iterating this directory must abort, not publish an
    # apparently successful empty scan over the last known good index.
    with os.scandir(root) as entries:
        for entry in entries:
            if not stat.S_ISDIR(entry.stat(follow_symlinks=False).st_mode):
                continue
            try:
                did_document_url(entry.name, plc_url)
            except Unpublish:
                continue
            path = root / entry.name
            try:
                modes = [(path / name).lstat().st_mode for name in ("HEAD", "objects", "refs")]
            except FileNotFoundError:
                continue
            if stat.S_ISREG(modes[0]) and all(stat.S_ISDIR(mode) for mode in modes[1:]):
                repositories[entry.name] = path
    return repositories


def publication(value: dict, plc_url: str) -> dict:
    if not isinstance(value, dict):
        raise Unpublish("invalid publication metadata")
    handle, rkey = value.get("handle"), value.get("rkey")
    if not valid_handle(handle, plc_url) or not valid_rkey(rkey):
        raise Unpublish("invalid publication identity")
    name, description = value.get("name"), value.get("description", "")
    if not isinstance(name, str) or not isinstance(description, str):
        raise Unpublish("invalid publication text")
    return {
        "handle": handle,
        "rkey": rkey,
        "name": clean_text(name) or rkey,
        "description": clean_text(description),
    }


def load_cache(path: Path, plc_url: str) -> dict:
    try:
        with path.open(encoding="utf-8") as stream:
            cached = json.load(stream)
        if not isinstance(cached, dict) or cached.get("version") != 1:
            raise ValueError("unknown cache format")
        entries = cached.get("repositories")
        if not isinstance(entries, dict):
            raise ValueError("invalid cache entries")
    except FileNotFoundError:
        return {}
    except (OSError, ValueError) as error:
        print(f"indexer: ignoring unreadable metadata cache ({type(error).__name__})", file=sys.stderr)
        return {}
    result = {}
    for did, value in entries.items():
        try:
            did_document_url(did, plc_url)
            result[did] = publication(value, plc_url)
        except Unpublish:
            print("indexer: ignoring invalid cached repository metadata", file=sys.stderr)
    return result


def repository_records(owner_did: str, pds: str) -> dict:
    repositories = {}
    cursor, seen_cursors = None, set()
    prefix = f"at://{owner_did}/sh.tangled.repo/"
    while True:
        query = {"repo": owner_did, "collection": "sh.tangled.repo", "limit": 100}
        if cursor is not None:
            query["cursor"] = cursor
        page = request_json(f"{pds}/xrpc/com.atproto.repo.listRecords?{urlencode(query)}")
        records = page.get("records")
        if not isinstance(records, list):
            raise TemporaryFailure("invalid PDS repository collection")
        for record in records:
            if not isinstance(record, dict) or not isinstance(record.get("value"), dict):
                raise TemporaryFailure("invalid PDS repository record")
            value, uri = record["value"], record.get("uri")
            if not isinstance(uri, str) or not uri.startswith(prefix):
                raise TemporaryFailure("repository record has an invalid owner or collection")
            rkey = uri[len(prefix):]
            if not valid_rkey(rkey):
                raise TemporaryFailure("repository record has an invalid record key")
            repo_did = value.get("repoDid")
            if isinstance(repo_did, str):
                repositories.setdefault(repo_did, []).append((rkey, value))
        cursor = page.get("cursor")
        if cursor is None or cursor == "":
            return repositories
        if not isinstance(cursor, str) or cursor in seen_cursors:
            raise TemporaryFailure("invalid PDS pagination cursor")
        seen_cursors.add(cursor)


def owner_metadata(did: str, plc_url: str, owners: dict) -> tuple[str, dict]:
    if did in owners:
        return owners[did]
    document = request_json(did_document_url(did, plc_url))
    if document.get("id") != did:
        raise Unpublish("owner DID document identity mismatch")
    handle = did
    aliases = document.get("alsoKnownAs", [])
    if not isinstance(aliases, list):
        raise Unpublish("invalid owner aliases")
    for alias in aliases:
        if isinstance(alias, str) and alias.startswith("at://"):
            candidate = alias[len("at://"):]
            if not valid_handle(candidate, plc_url) or candidate.startswith("did:"):
                raise Unpublish("invalid owner handle")
            handle = candidate
            break
    services = document.get("service", [])
    if not isinstance(services, list):
        raise Unpublish("invalid owner services")
    for service in services:
        if isinstance(service, dict) and service.get("id") in ("#atproto_pds", f"{did}#atproto_pds"):
            endpoint = service.get("serviceEndpoint")
            if not isinstance(endpoint, str):
                raise Unpublish("invalid PDS endpoint")
            records = repository_records(did, base_url(endpoint, https=True))
            owners[did] = (handle, records)
            return owners[did]
    raise Unpublish("owner has no atproto PDS")


def resolve_repository(did: str, knot_url: str, knot_host: str, plc_url: str, owners: dict) -> dict:
    description = request_json(
        f"{knot_url}/xrpc/sh.tangled.repo.describeRepo?{urlencode({'repoDid': did})}",
        authoritative=True,
    )
    if description.get("repoDid") != did:
        raise Unpublish("describeRepo identity mismatch")
    owner_did, rkey = description.get("ownerDid"), description.get("rkey")
    did_document_url(owner_did, plc_url)
    if not valid_rkey(rkey):
        raise Unpublish("invalid repository record key")
    handle, repositories = owner_metadata(owner_did, plc_url, owners)
    # Knot may return a historical alias, not the record's actual PDS key.
    # Match the stable repository DID, using the hint only to disambiguate aliases.
    matches = repositories.get(did, [])
    record = next((record for record in matches if record[0] == rkey), None)
    if record is None:
        if not matches:
            raise Unpublish("repository missing from owner's PDS collection")
        if len(matches) != 1:
            raise TemporaryFailure("multiple PDS records match the repository DID")
        record = matches[0]
    rkey, value = record
    if value.get("knot") != knot_host:
        raise Unpublish("repository record Knot mismatch")
    return publication({
        "handle": handle,
        "rkey": rkey,
        "name": value.get("name") or rkey,
        "description": value.get("description", ""),
    }, plc_url)


def render_index(repositories: dict[str, Path], metadata: dict, knot_host: str) -> str:
    lines = []
    for did in sorted(metadata):
        repo = metadata[did]
        lines.extend([
            f"repo.url={quote(repo['handle'], safe='')}/{quote(repo['rkey'], safe='')}",
            f"repo.name={repo['handle']}/{repo['name']}",
            f"repo.owner={repo['handle']}",
            f"repo.desc={repo['description']}",
            f"repo.path={repositories[did]}",
            f"repo.clone-url=https://{knot_host}/{did}",
            "",
        ])
    return "\n".join(lines)


def atomic_write(path: Path, content: str) -> None:
    temporary = None
    try:
        with tempfile.NamedTemporaryFile(mode="w", encoding="utf-8", dir=path.parent, delete=False) as stream:
            temporary = Path(stream.name)
            os.fchmod(stream.fileno(), 0o644)
            stream.write(content)
            stream.flush()
            os.fsync(stream.fileno())
        os.replace(temporary, path)
    finally:
        if temporary is not None:
            temporary.unlink(missing_ok=True)


def generate(repo_root: Path, state_dir: Path, knot_url: str, knot_host: str, plc_url: str) -> None:
    knot_url, plc_url = base_url(knot_url), base_url(plc_url)
    if not hostname(knot_host):
        raise ValueError("invalid public Knot hostname")
    repositories = scan_repositories(repo_root, plc_url)
    cached = load_cache(state_dir / "metadata.json", plc_url)
    metadata, owners = {}, {}
    for did in sorted(repositories):
        try:
            metadata[did] = resolve_repository(did, knot_url, knot_host, plc_url, owners)
        except TemporaryFailure as error:
            retained = did in cached
            if retained:
                metadata[did] = cached[did]
            print(f"indexer: {did}: {error}; {'retaining cached metadata' if retained else 'omitting unresolved repository'}", file=sys.stderr)
        except Unpublish as error:
            print(f"indexer: {did}: {error}; unpublishing repository", file=sys.stderr)
    index = render_index(repositories, metadata, knot_host)
    state_dir.mkdir(parents=True, exist_ok=True)
    atomic_write(state_dir / "metadata.json", json.dumps({"version": 1, "repositories": metadata}, indent=2) + "\n")
    atomic_write(state_dir / "repositories.cgitrc", index)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--repo-root", type=Path, required=True)
    parser.add_argument("--state-dir", type=Path, required=True)
    parser.add_argument("--knot-url", required=True)
    parser.add_argument("--knot-host", required=True)
    parser.add_argument("--plc-url", default="https://plc.directory")
    args = parser.parse_args()
    try:
        generate(args.repo_root, args.state_dir, args.knot_url, args.knot_host, args.plc_url)
    except (OSError, ValueError, Unpublish) as error:
        print(f"indexer: index not updated ({type(error).__name__}): {error}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
