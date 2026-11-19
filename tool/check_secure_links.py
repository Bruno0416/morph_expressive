#!/usr/bin/env python3
"""Reject insecure links in the files pana scores (README.md, CHANGELOG.md).

pana deducts the README points for any `http://` link ("Links in README.md
should be secure"), which breaks the 160/160 publication gate. Plain text in
inline code (for example `127.0.0.1:8081`) is fine; only links are checked.
"""
from pathlib import Path
import re
import sys

ROOT = Path(__file__).resolve().parent.parent
FILES = ("README.md", "CHANGELOG.md")
LINK = re.compile(
    r"""\]\(\s*(http://[^)\s]+)"""      # [text](http://...)
    r"""|<(http://[^>\s]+)>"""           # <http://...>
    r"""|(?:href|src)\s*=\s*["'](http://[^"']+)["']""",  # HTML attributes
    re.IGNORECASE,
)


def insecure_links(text: str) -> list[tuple[int, str]]:
    found = []
    for match in LINK.finditer(text):
        url = next(group for group in match.groups() if group)
        found.append((text.count("\n", 0, match.start()) + 1, url))
    return found


def main() -> int:
    problems = []
    for name in FILES:
        path = ROOT / name
        if path.is_file():
            for line, url in insecure_links(path.read_text(encoding="utf-8")):
                problems.append(f"{name}:{line}: insecure link {url} (use https or inline code)")
    if problems:
        print("\n".join(problems), file=sys.stderr)
        return 1
    print(f"Secure links OK: {', '.join(FILES)}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
