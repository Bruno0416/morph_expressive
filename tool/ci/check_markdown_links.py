#!/usr/bin/env python3
"""Validate local Markdown file/asset targets; no network or anchor checks."""
from __future__ import annotations

import argparse
from pathlib import Path
import re
import sys
from urllib.parse import unquote, urlsplit

from check_final_release_language import relative_names

ROOT = Path(__file__).resolve().parents[2]
LINK = re.compile(r'\[[^\]\n]*\]\((<[^>\n]+>|[^\s)]+)')
REFERENCE = re.compile(r'(?m)^\s{0,3}\[[^\]\n]+\]:\s*(<[^>\n]+>|\S+)')
HTML = re.compile(r'''(?:src|href)\s*=\s*["']([^"']+)["']''', re.I)
FENCE = re.compile(r'(?ms)^\s{0,3}(`{3,}|~{3,})[^\n]*\n.*?^\s{0,3}\1\s*$')


def missing_targets(root: Path, file: Path) -> list[str]:
    text = FENCE.sub('', file.read_text(encoding='utf-8'))
    text = re.sub(r'`+[^`\n]*`+', '', text)
    missing = []
    for pattern in (LINK, REFERENCE, HTML):
        for match in pattern.finditer(text):
            target = match.group(1).strip('<>')
            parsed = urlsplit(target)
            if parsed.scheme or parsed.netloc or not parsed.path:
                continue
            path = unquote(parsed.path)
            resolved = (root / path.lstrip('/') if path.startswith('/') else file.parent / path).resolve()
            if not resolved.is_relative_to(root.resolve()) or not resolved.exists():
                missing.append(target)
    return missing


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--root', type=Path, default=ROOT)
    parser.add_argument('--include-local-context', action='store_true',
                        help='also inspect root AGENTS.md and local .agents Markdown')
    args = parser.parse_args()
    root = args.root.resolve()
    try:
        files = {root / name for name in relative_names(root, 'all', None)
                 if Path(name).suffix.lower() in {'.md', '.markdown'}
                 and not any(part in {'.agents', '.serena', 'AGENTS.md'} for part in Path(name).parts)}
        if args.include_local_context:
            files.update((root / '.agents').glob('*.md'))
            if (root / 'AGENTS.md').is_file():
                files.add(root / 'AGENTS.md')
        errors = [(file.relative_to(root), target) for file in sorted(files)
                  if file.is_file() and not file.is_symlink() for target in missing_targets(root, file)]
        if errors:
            for file, target in errors:
                print(f'{file}: missing or external local target: {target}', file=sys.stderr)
            return 1
        print(f'PASS: local Markdown file/asset targets in {len(files)} documents.')
        return 0
    except (OSError, RuntimeError, ValueError) as exc:
        print(f'Markdown check FAILED: {exc}', file=sys.stderr)
        return 1


if __name__ == '__main__':
    raise SystemExit(main())
