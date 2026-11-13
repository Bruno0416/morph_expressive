#!/usr/bin/env python3
"""Block provisional-release labels accidentally introduced in Morph artifacts.

Usage: --all (working checkout), --staged (Git index), --revision REV (exact commit).
The policy and checker/test fixtures are exempt so they can describe patterns.
"""
from __future__ import annotations

import argparse
import os
from pathlib import Path
import re
import subprocess
import sys

DEFAULT_ROOT = Path(__file__).resolve().parents[2]
# Only files that can realistically carry source, documentation, build or release metadata.
SCANNED_EXTENSIONS = frozenset(
    {'.md', '.markdown', '.rst', '.txt', '.yaml', '.yml', '.json',
     '.toml', '.dart', '.py', '.sh', '.xml', '.properties', '.patch', '.diff'}
)
EXEMPT_PATHS = frozenset({
    '.agents/FINAL_RELEASE_POLICY.md',
    'tool/ci/check_final_release_language.py',
    'tool/ci/tests/test_final_release_language.py',
})
SKIP_DIRS = frozenset({
    '.git', '.dart_tool', '.gradle', '.idea', '.cxx', 'node_modules',
    'build', 'coverage', 'Pods', 'DerivedData', 'ephemeral',
    '.plugin_symlinks', '__pycache__',
})
MAX_BYTES = 2_000_000
BAD_PATTERNS = (
    ('English candidate wording', re.compile(r'\brelease[\s_-]*candidates?\b', re.I)),
    ('Spanish candidate wording', re.compile(
        r'\bcandidat[oa]s?\s+(?:(?:a|de|para)\s+)?'
        r'(?:release|lanzamientos?|publicaci[oó]n)\b', re.I)),
    ('candidate version wording', re.compile(
        r'\b(?:versi[oó]n|version|release)\s+candidat[ao]s?\b', re.I)),
    ('candidate release wording', re.compile(
        r'\b(?:lanzamiento|publicaci[oó]n|release)\s+candidat[oa]s?\b', re.I)),
    ('RC semantic version', re.compile(
        r'\bv?\d+\.\d+\.\d+\s*[-_.]\s*rc(?:[-_.]?\d+)?\b', re.I)),
    ('RC prefix before version', re.compile(
        r'\brc(?:[-_. ]?\d+)?\s+v?\d+\.\d+\.\d+\b', re.I)),
    ('release RC label', re.compile(
        r'\b(?:version|versi[oó]n|release|lanzamiento|publicaci[oó]n)\b'
        r'[^\n]{0,45}\bRC(?:[-_. ]?\d+)?\b', re.I)),
    ('RC release label', re.compile(
        r'\bRC(?:[-_. ]?\d+)?\b[^\n]{0,45}'
        r'\b(?:version|versi[oó]n|release|lanzamiento|publicaci[oó]n)\b', re.I)),
    ('standalone RC label', re.compile(r'\bRC(?:[-_. ]?\d+)?\b', re.I)),
    ('pre-release label', re.compile(r'\bpre[\s_-]*releases?\b', re.I)),
)


def git(root: Path, *args: str) -> bytes:
    result = subprocess.run(
        ['git', '-C', str(root), *args], capture_output=True, check=False
    )
    if result.returncode:
        detail = result.stderr.decode('utf-8', errors='replace').strip()
        raise RuntimeError(f'Git command failed ({" ".join(args)}): {detail}')
    return result.stdout


def in_git(root: Path) -> bool:
    return subprocess.run(
        ['git', '-C', str(root), 'rev-parse', '--show-toplevel'],
        capture_output=True, check=False,
    ).returncode == 0


def relative_names(root: Path, mode: str, revision: str | None) -> list[str]:
    if mode == 'staged':
        raw = git(root, 'diff', '--cached', '--name-only', '--diff-filter=ACMR', '-z')
        return sorted({x.decode('utf-8', errors='surrogateescape') for x in raw.split(b'\0') if x})
    if mode == 'revision':
        assert revision is not None
        raw = git(root, 'ls-tree', '-r', '-z', '--name-only', revision)
        return sorted({x.decode('utf-8', errors='surrogateescape') for x in raw.split(b'\0') if x})
    if in_git(root):
        raw = git(root, 'ls-files', '--cached', '--others', '--exclude-standard', '-z')
        return sorted({x.decode('utf-8', errors='surrogateescape') for x in raw.split(b'\0') if x})
    names: list[str] = []
    for folder, dirs, filenames in os.walk(root):
        dirs[:] = [d for d in dirs if d not in SKIP_DIRS]
        for name in filenames:
            names.append((Path(folder) / name).relative_to(root).as_posix())
    return sorted(names)


def should_scan(name: str) -> bool:
    normalized = name.replace('\\', '/')
    if normalized in EXEMPT_PATHS:
        return False
    if any(part in SKIP_DIRS for part in normalized.split('/')[:-1]):
        return False
    return Path(normalized).suffix.lower() in SCANNED_EXTENSIONS or normalized in {'CHANGELOG', 'README'}


def load_file(root: Path, name: str, mode: str, revision: str | None) -> bytes | None:
    if mode == 'staged':
        return git(root, 'show', ':' + name)
    if mode == 'revision':
        assert revision is not None
        return git(root, 'show', revision + ':' + name)
    p = root / name
    if not p.is_file() or p.is_symlink() or p.stat().st_size > MAX_BYTES:
        return None
    return p.read_bytes()


def scan_content(name: str, raw: bytes) -> list[tuple[str, int, str]]:
    if len(raw) > MAX_BYTES or b'\0' in raw:
        return []
    issues: list[tuple[str, int, str]] = []
    # A document's filename must be clean as well as its contents.
    for label, regex in BAD_PATTERNS:
        if regex.search(name):
            issues.append((label + ' in filename', 0, name))
            break
    text = raw.decode('utf-8', errors='replace')
    for line_no, line in enumerate(text.splitlines(), 1):
        for label, regex in BAD_PATTERNS:
            if regex.search(line):
                issues.append((label, line_no, line.strip()[:180]))
                break
    return issues


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    modes = parser.add_mutually_exclusive_group(required=True)
    modes.add_argument('--all', action='store_true', help='scan tracked and untracked files in working tree')
    modes.add_argument('--staged', action='store_true', help='scan the exact staged Git index blobs')
    modes.add_argument('--revision', metavar='COMMIT', help='scan the exact named Git commit/revision')
    parser.add_argument('--root', type=Path, default=DEFAULT_ROOT, help='repository directory (for testing)')
    parser.add_argument('--ref', action='append', default=[], help='check a ref name/tag being pushed')
    opts = parser.parse_args(argv)
    root = opts.root.resolve()
    mode = 'all' if opts.all else 'staged' if opts.staged else 'revision'
    if not root.is_dir():
        parser.error(f'not a directory: {root}')
    if mode != 'all' and not in_git(root):
        parser.error(f'--{mode} requires a Git checkout: {root}')
    errors: list[tuple[str, str, int, str]] = []
    inspected = 0
    try:
        for ref in opts.ref:
            for label, line_no, excerpt in scan_content('[Git ref]', ref.encode('utf-8')):
                errors.append(('[Git ref]', label, line_no, excerpt))
        if mode == 'revision':
            message = git(root, 'show', '-s', '--format=%B', opts.revision)
            for label, line_no, excerpt in scan_content('[commit message]', message):
                errors.append(('[commit message]', label, line_no, excerpt))
        for name in relative_names(root, mode, opts.revision):
            if not should_scan(name):
                continue
            data = load_file(root, name, mode, opts.revision)
            if data is None or len(data) > MAX_BYTES or b'\0' in data:
                continue
            inspected += 1
            for label, line_no, excerpt in scan_content(name, data):
                errors.append((name, label, line_no, excerpt))
    except (RuntimeError, OSError) as exc:
        print(f'ERROR: {exc}', file=sys.stderr)
        return 2

    if errors:
        print(f'BLOCKED: {len(errors)} prohibited release-label occurrence(s).', file=sys.stderr)
        for name, label, line_no, excerpt in errors[:80]:
            loc = f'{name}:{line_no}' if line_no else name
            print(f'  {loc} — {label}\n    {excerpt}', file=sys.stderr)
        print('Fix naming before commit/push; see tool/ci/README.md.', file=sys.stderr)
        return 1
    qualifier = f' ({opts.revision})' if opts.revision else ''
    print(f'PASS: no prohibited release labels in {inspected} scanned files [{mode}{qualifier}].')
    return 0


if __name__ == '__main__':
    sys.exit(main())
