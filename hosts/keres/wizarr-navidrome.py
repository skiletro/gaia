from __future__ import annotations

import logging
from typing import TYPE_CHECKING, Any

import requests
import structlog
from sqlalchemy import or_

from app.extensions import db
from app.models import Invitation, User
from app.services.invites import is_invite_valid
from app.services.media.utils import StandardizedPermissions

from .client_base import RestApiMixin, register_media_client

if TYPE_CHECKING:
    from app.services.media.user_details import MediaUserDetails


@register_media_client("navidrome")
class NavidromeClient(RestApiMixin):
    """Navidrome wrapper.

    Navidrome's Subsonic endpoint stubs all user-management routes with 501,
    so this client uses Navidrome's native API instead: POST /auth/login
    returns a JWT which authorises /api/user CRUD via the
    X-ND-Authorization header. The "api_key" setting holds the password of
    the Navidrome admin user named "admin" (the username is fixed by the
    salted-token Subsonic auth used elsewhere in wizarr).
    """

    #: API prefix for Subsonic/OpenSubsonic endpoints (read-only calls)
    API_PREFIX = "/rest"

    def __init__(self, *args, **kwargs):
        # Provide defaults for legacy compatibility
        kwargs.setdefault("url_key", "server_url")
        kwargs.setdefault("token_key", "api_key")

        super().__init__(*args, **kwargs)

        # Normalize URL
        if self.url:
            self.url = self.url.rstrip("/")

        self._jwt: str | None = None

    # ------------------------------------------------------------------
    # Native API authentication
    # ------------------------------------------------------------------

    def _jwt_token(self) -> str:
        """Login to the native API and cache the returned JWT."""
        if self._jwt:
            return self._jwt

        if not self.token:
            raise ValueError("Password (api_key) is required for Navidrome")

        response = requests.post(
            f"{self.url}/auth/login",
            json={"username": "admin", "password": self.token},
            headers={"Accept": "application/json"},
            timeout=60,
        )
        response.raise_for_status()
        token = response.json().get("token")
        if not token:
            raise ValueError("No token returned from Navidrome login")
        self._jwt = token
        return self._jwt

    def _native_headers(self) -> dict[str, str]:
        return {
            "Accept": "application/json",
            "Content-Type": "application/json",
            "X-ND-Authorization": f"Bearer {self._jwt_token()}",
        }

    def _native_request(self, method: str, path: str, **kwargs) -> Any:
        """Make a request to the Navidrome native API with auth headers."""
        response = requests.request(
            method,
            f"{self.url}{path}",
            headers=self._native_headers(),
            timeout=60,
            **kwargs,
        )
        response.raise_for_status()
        return response.json() if response.content else {}

    def _subsonic_auth_params(self) -> dict[str, str]:
        """Subsonic salted-MD5 auth (read-only endpoints)."""
        import hashlib
        import random
        import string

        if not self.token:
            raise ValueError("Password (api_key) is required for Navidrome")

        salt = "".join(random.choices(string.ascii_letters + string.digits, k=6))
        token_hash = hashlib.md5((self.token + salt).encode()).hexdigest()  # noqa: S324

        return {
            "u": "admin",
            "t": token_hash,
            "s": salt,
            "v": "1.16.1",
            "c": "wizarr",
            "f": "json",
        }

    def _subsonic_request(self, endpoint: str, params: dict | None = None) -> dict:
        """Make a read-only Subsonic API request with authentication."""
        auth_params = self._subsonic_auth_params()
        if params:
            auth_params.update(params)

        response = requests.get(
            f"{self.API_PREFIX}/{endpoint}",
            params=auth_params,
            headers={"Accept": "application/json"},
            timeout=60,
        )
        response.raise_for_status()

        data = response.json()
        subsonic_response = data.get("subsonic-response", {})
        if subsonic_response.get("status") != "ok":
            error = subsonic_response.get("error", {})
            raise Exception(
                f"Subsonic API error: {error.get('message', 'Unknown error')}"
            )

        return subsonic_response

    def validate_connection(self) -> tuple[bool, str]:
        """Validate connection to Navidrome server via native login."""
        try:
            self._jwt = None
            self._jwt_token()
            return True, "Connection successful"
        except Exception as exc:
            logging.error("Navidrome: connection validation failed – %s", exc)
            return False, f"Connection failed: {exc!s}"

    def libraries(self) -> dict[str, str]:
        """Return mapping of library_id -> display_name."""
        try:
            users = self._native_request("GET", "/api/user")
            for user in users:
                if user.get("isAdmin"):
                    libs = user.get("libraries", [])
                    return {str(lib["id"]): lib["name"] for lib in libs}
            return {}
        except Exception as exc:
            logging.warning("Navidrome: failed to fetch libraries – %s", exc)
            return {}

    def scan_libraries(
        self, url: str | None = None, token: str | None = None
    ) -> dict[str, str]:
        """Scan available libraries on this Navidrome server."""
        try:
            if url and token:
                # Create temporary client for scanning
                temp_client = NavidromeClient()
                temp_client.url = url.rstrip("/")
                temp_client.token = token
                return {
                    name: lib_id
                    for lib_id, name in temp_client.libraries().items()
                }
            return {name: lib_id for lib_id, name in self.libraries().items()}
        except Exception as exc:
            logging.warning("Navidrome: failed to scan libraries – %s", exc)
            return {}

    def list_users(self) -> list[User]:
        """Read users from Navidrome and reflect them locally."""
        server_id = getattr(self, "server_id", None)
        if server_id is None:
            return []

        try:
            remote_users = self._native_request("GET", "/api/user")
        except Exception as exc:
            logging.warning("Navidrome: failed to list users – %s", exc)
            return []

        users_by_name = {u["userName"]: u for u in remote_users}

        known_users = User.query.filter(User.server_id == server_id).all()
        if self._skip_prune_on_empty_remote(not users_by_name, known_users):
            return known_users

        try:
            # Add new users or update existing ones
            for username, remote in users_by_name.items():
                db_row = User.query.filter_by(
                    username=username, server_id=server_id
                ).first()
                if not db_row:
                    db_row = User(
                        token=remote.get("id", username),
                        username=username,
                        email=remote.get("email", ""),
                        code="empty",
                        server_id=server_id,
                    )
                    db.session.add(db_row)
                else:
                    db_row.token = remote.get("id", db_row.token)
                    db_row.email = remote.get("email", db_row.email)

            # Remove users that no longer exist upstream
            to_check = User.query.filter(User.server_id == server_id).all()
            for local in to_check:
                if local.username not in users_by_name:
                    db.session.delete(local)

            db.session.commit()

        except Exception as exc:
            logging.error("Navidrome: failed to sync users – %s", exc)
            db.session.rollback()
            return []

        # Get users with policy information
        users = User.query.filter(User.server_id == server_id).all()

        for user in users:
            if user.username in users_by_name:
                navidrome_user = users_by_name[user.username]
                user.is_admin = bool(navidrome_user.get("isAdmin", False))
                user.allow_downloads = True
            else:
                user.is_admin = False
                user.allow_downloads = True

        try:
            db.session.commit()
        except Exception as e:
            logging.error("Navidrome: failed to update user metadata – %s", e)
            db.session.rollback()
        return users

    def create_user(
        self,
        username: str,
        password: str,
        email: str,
        *,
        is_admin: bool = False,
        allow_downloads: bool = True,
    ) -> str:
        """Create a user and return the new user's id."""
        payload = {
            "userName": username,
            "password": password,
            "email": email,
            "isAdmin": is_admin,
        }
        try:
            created = self._native_request("POST", "/api/user", json=payload)
            return created.get("id", username)
        except Exception as exc:
            logging.error("Navidrome: failed to create user – %s", exc)
            raise

    def update_user(self, username: str, payload: dict[str, Any]):
        """Update user with given parameters."""
        try:
            users = self._native_request("GET", "/api/user")
            user_id = next(
                (u["id"] for u in users if u["userName"] == username), None
            )
            if user_id is None:
                raise ValueError(f"User {username} not found on Navidrome")

            body: dict[str, Any] = {"id": user_id}
            if "password" in payload:
                body["password"] = payload["password"]
            if "email" in payload:
                body["email"] = payload["email"]
            if "is_admin" in payload:
                body["isAdmin"] = bool(payload["is_admin"])

            self._native_request("PUT", f"/api/user/{user_id}", json=body)
        except Exception as exc:
            logging.error("Navidrome: failed to update user %s – %s", username, exc)
            raise

    def enable_user(self, user_id: str) -> bool:  # noqa: ARG002
        """Enable a user account on Navidrome.

        Navidrome doesn't have a direct enable feature
        """
        structlog.get_logger().warning(
            "Navidrome does not support enabling users. They need to be given library access."
        )
        return False

    def disable_user(self, user_id: str) -> bool:  # noqa: ARG002
        """Disable a user account on Navidrome.

        Navidrome doesn't have a direct disable feature
        """
        structlog.get_logger().warning(
            "Navidrome does not support disabling users. They need to be given library access."
        )
        return False

    def delete_user(self, username: str) -> bool:
        """Delete user from Navidrome."""
        try:
            users = self._native_request("GET", "/api/user")
            user_id = next(
                (u["id"] for u in users if u["userName"] == username), None
            )
            if user_id is None:
                logging.warning("Navidrome: user %s not found for delete", username)
                return False
            self._native_request("DELETE", f"/api/user/{user_id}")
            return True
        except Exception as exc:
            logging.error("Navidrome: failed to delete user – %s", exc)
            return False

    def get_user(self, username: str) -> dict:
        """Get a single user's details from Navidrome."""
        users = self._native_request("GET", "/api/user")
        for user in users:
            if user.get("userName") == username:
                return user
        return {}

    def get_user_details(self, user_identifier: str | int) -> MediaUserDetails:
        """Return standardised details for a user."""
        users = self._native_request("GET", "/api/user")

        match = None
        for user in users:
            if str(user.get("id")) == str(user_identifier) or user.get(
                "userName"
            ) == str(user_identifier):
                match = user
                break

        if match is None:
            raise ValueError(f"User {user_identifier} not found on Navidrome")

        return MediaUserDetails(
            username=match["userName"],
            email=match.get("email", ""),
            is_admin=match.get("isAdmin", False),
            allow_downloads=True,
            allow_live_tv=False,
        )

    def _do_join(
        self,
        username: str,
        password: str,
        confirm: str,
        email: str,
        code: str,
    ):
        """Public invite flow for Navidrome users."""
        if not 1 <= len(username) <= 50:
            return False, "Username must be 1-50 characters."
        if not 8 <= len(password) <= 128:
            return False, "Password must be 8-128 characters."
        if password != confirm:
            return False, "Passwords do not match."

        ok, msg = is_invite_valid(code)
        if not ok:
            return False, msg

        server_id = getattr(self, "server_id", None)
        if server_id is None:
            return False, "Server configuration error"

        existing = User.query.filter(
            or_(User.username == username, User.email == email),
            User.server_id == server_id,
        ).first()
        if existing:
            return False, "User or e-mail already exists."

        try:
            inv = Invitation.query.filter_by(code=code).first()

            # Get download permission from invitation
            allow_downloads = getattr(inv, "allow_downloads", True)
            if allow_downloads is None:
                allow_downloads = True

            # Create user on Navidrome
            user_id = self.create_user(
                username, password, email=email, allow_downloads=allow_downloads
            )
            if not user_id:
                return False, "Failed to create user on server"

            # Calculate expiry
            from app.services.expiry import calculate_user_expiry

            expires = (
                calculate_user_expiry(inv, getattr(self, "server_id", None))
                if inv
                else None
            )

            # Store locally
            local = User(
                token=user_id,
                username=username,
                email=email,
                code=code,
                expires=expires,
                server_id=server_id,
            )
            db.session.add(local)
            db.session.commit()

            return True, ""

        except Exception as exc:
            logging.error("Navidrome join failed: %s", exc)
            db.session.rollback()
            return False, "Failed to create user"

    def now_playing(self) -> list[dict]:
        """Return currently playing items (Subsonic endpoint)."""
        try:
            result = self._subsonic_request("getNowPlaying")
            entries = result.get("nowPlaying", {}).get("entry", [])
            if isinstance(entries, dict):
                entries = [entries]
            return entries
        except Exception as exc:
            logging.warning("Navidrome: failed to fetch now playing – %s", exc)
            return []

    def statistics(self):
        """Return server statistics."""
        try:
            return self.get_readonly_statistics()
        except Exception as exc:
            logging.warning("Navidrome: failed to fetch statistics – %s", exc)
            return {}

    def get_user_count(self) -> int:
        """Count users on Navidrome."""
        try:
            return len(self._native_request("GET", "/api/user"))
        except Exception as exc:
            logging.warning("Navidrome: failed to count users – %s", exc)
            return 0

    def get_server_info(self) -> dict:
        """Return basic server info via Subsonic ping."""
        try:
            result = self._subsonic_request("ping")
            return {
                "server_version": result.get("serverVersion", "unknown"),
                "api_version": result.get("version", "unknown"),
            }
        except Exception as exc:
            logging.warning("Navidrome: failed to get server info – %s", exc)
            return {}

    def get_readonly_statistics(self) -> dict:
        """Return statistics assembled from read-only endpoints."""
        try:
            info = self.get_server_info()
            return {
                "total_users": self.get_user_count(),
                "active_sessions": 0,
                "server_stats": info,
                "library_stats": {},
                "content_stats": {},
            }
        except Exception as exc:
            logging.warning("Navidrome: failed to get statistics – %s", exc)
            return {}

    def _headers(self) -> dict[str, str]:
        """Return default headers for native API requests."""
        return {"Accept": "application/json"}
