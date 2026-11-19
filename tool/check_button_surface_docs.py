#!/usr/bin/env python3
"""Fail when documentation or examples pass `surface:` to a button.

Frosted finish is not part of the button API in 1.0.0: `MorphButton`,
`MorphIconButton` and `MorphAsyncButton` take `variant` and a visual type, and
only `MorphCard` takes `surface:`. This guard scans the README, the current
guides, the examples and the library dartdoc for a call to one of those buttons
whose own argument list contains a `surface:` argument. Cards, glass and the
words "surface" or "frosted" are legitimate and are never flagged.
"""

from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent

BUTTON_CALL = re.compile(
    r'\b(?:MorphButton|MorphIconButton)(?:\s*\.\s*\w+)?\s*\('
    r'|\bMorphAsyncButton\s*\('
)
SURFACE_ARGUMENT = re.compile(r'(?:^|[,(])\s*surface\s*:')

# Release notes of earlier versions describe APIs that no longer exist.
HISTORICAL_DOCS = re.compile(r'(RELEASE_0_|UPGRADE_0_|R3_|CHANGELOG)')


def _argument_list(text: str, open_index: int) -> str | None:
    """Returns the top-level arguments of the call opened at `open_index`."""
    depth = 0
    top_level: list[str] = []
    quote: str | None = None
    i = open_index
    while i < len(text):
        ch = text[i]
        if quote:
            if ch == '\\':
                i += 2
                continue
            if ch == quote:
                quote = None
        elif ch in '\'"':
            quote = ch
        elif ch in '([{':
            depth += 1
            if depth > 1:
                top_level.append(' ')
                i += 1
                continue
        elif ch in ')]}':
            depth -= 1
            if depth == 0:
                return ''.join(top_level)
            if depth >= 1:
                top_level.append(' ')
                i += 1
                continue
        if depth == 1 and not quote:
            top_level.append(ch)
        elif depth > 1:
            top_level.append(' ')
        i += 1
    return None


def button_surface_calls(text: str) -> list[tuple[int, str]]:
    """Returns (line, call) for each button call with a `surface:` argument."""
    # Dartdoc and markdown quoting prefixes must not hide an argument.
    cleaned = re.sub(r'(?m)^\s*///? ?', '', text)
    offsets_text = cleaned
    found: list[tuple[int, str]] = []
    for match in BUTTON_CALL.finditer(offsets_text):
        arguments = _argument_list(offsets_text, match.end() - 1)
        if arguments is not None and SURFACE_ARGUMENT.search(arguments):
            line = offsets_text.count('\n', 0, match.start()) + 1
            found.append((line, match.group(0).rstrip('(').strip()))
    return found


def _files() -> list[Path]:
    files = [ROOT / 'README.md']
    files += sorted((ROOT / 'doc').glob('*.md'))
    for pattern in ('*.dart', '*.md'):
        files += sorted((ROOT / 'example').rglob(pattern))
    files += sorted((ROOT / 'lib').rglob('*.dart'))
    return [
        f for f in files
        if f.is_file() and not HISTORICAL_DOCS.search(f.name)
    ]


def main() -> int:
    problems: list[str] = []
    for path in _files():
        text = path.read_text(encoding='utf-8')
        for line, call in button_surface_calls(text):
            problems.append(
                f'{path.relative_to(ROOT)}:{line}: {call}(...) passes '
                '`surface:`; frosted finish is not part of the button API'
            )
    if problems:
        print('\n'.join(problems), file=sys.stderr)
        return 1
    print(f'Button surface docs: {len(_files())} files checked, none pass surface.')
    return 0


if __name__ == '__main__':
    sys.exit(main())
