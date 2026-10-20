"""Render cgit About pages without executing repository-provided HTML or includes."""

from html import escape
from pathlib import Path
import sys

from docutils.core import publish_parts
import markdown
import nh3


def render_readme(content: str, filename: str) -> str:
    suffix = Path(filename).suffix.lower()
    if suffix in {".md", ".markdown", ".mdown", ".mkd"}:
        fragment = markdown.markdown(
            content,
            extensions=["fenced_code", "tables", "sane_lists"],
            output_format="html5",
        )
    elif suffix == ".rst":
        fragment = publish_parts(
            source=content,
            writer_name="html5",
            settings_overrides={
                "raw_enabled": False,
                "file_insertion_enabled": False,
                "syntax_highlight": "none",
                "doctitle_xform": False,
                "halt_level": 6,
            },
        )["fragment"]
    else:
        return f'<pre class="readme-plain">{escape(content)}</pre>\n'

    fragment = nh3.clean(
        fragment,
        tags=nh3.ALLOWED_TAGS | {"details", "summary"},
        attributes={**nh3.ALLOWED_ATTRIBUTES, "code": {"class"}},
        url_schemes={"http", "https", "mailto"},
    )
    return f'<article class="markdown-body">{fragment}</article>\n'


def main() -> None:
    filename = sys.argv[1] if len(sys.argv) > 1 else "README"
    content = sys.stdin.buffer.read().decode("utf-8", errors="replace")
    sys.stdout.buffer.write(render_readme(content, filename).encode("utf-8"))


if __name__ == "__main__":
    main()
