#!/usr/bin/env python3
"""Create a portable Morph Expressive source ZIP without Flutter/build caches.

Usage:
    python3 tools/snapshot.py
    python3 tools/snapshot.py --output ~/Downloads/morph_expressive-source.zip

Requires Python 3.10+ and only the standard library.
"""

from __future__ import annotations

import argparse
import os
from datetime import datetime
from pathlib import Path
from zipfile import ZIP_DEFLATED, ZipFile

# Directory names are omitted wherever they occur, including preview/.
EXCLUDED_DIRS = frozenset({
    ".git", ".dart_tool", ".idea", ".gradle", ".cache",
    ".pub-cache", ".venv", ".pytest_cache", "__pycache__",
    "build", "ephemeral", "coverage", "node_modules", "dist",
    "target", "snapshots",
})
EXCLUDED_FILES = frozenset({
    ".DS_Store", ".flutter-plugins", ".flutter-plugins-dependencies",
})
EXCLUDED_SUFFIXES = frozenset({".pyc", ".pyo", ".iml", ".log", ".zip"})


def source_files(project_root: Path, archive: Path):
    """Yield files in sorted order, skipping caches, symlinks and the output ZIP."""
    archive = archive.resolve()
    for parent, subdirs, filenames in os.walk(project_root, followlinks=False):
        base = Path(parent)
        subdirs[:] = sorted(
            name for name in subdirs
            if name not in EXCLUDED_DIRS and not (base / name).is_symlink()
        )
        for name in sorted(filenames):
            path = base / name
            if (
                name in EXCLUDED_FILES
                or path.suffix.lower() in EXCLUDED_SUFFIXES
                or path.is_symlink()
                or not path.is_file()
                or path.resolve() == archive
            ):
                continue
            yield path


def create_snapshot(project_root: Path, archive: Path) -> tuple[int, int]:
    project_root = project_root.expanduser().resolve()
    archive = archive.expanduser().resolve()
    if not (project_root / "pubspec.yaml").is_file() or not (project_root / "lib").is_dir():
        raise ValueError(f"Not a Flutter package root: {project_root}")
    archive.parent.mkdir(parents=True, exist_ok=True)
    count = 0
    total_bytes = 0
    # The archive gets built from sources only; never follow links outside root.
    with ZipFile(archive, "w", compression=ZIP_DEFLATED, compresslevel=7) as out:
        for path in source_files(project_root, archive):
            out.write(path, arcname=path.relative_to(project_root).as_posix())
            count += 1
            total_bytes += path.stat().st_size
    return count, total_bytes


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--output", type=Path, help="ZIP path (default: ./snapshots/<package>-snapshot-<date>.zip)"
    )
    args = parser.parse_args()
    root = Path(__file__).resolve().parent.parent
    timestamp = datetime.now().astimezone().strftime("%Y%m%d-%H%M%S")
    output = args.output or (root / "snapshots" / f"{root.name}-snapshot-{timestamp}.zip")
    count, total_bytes = create_snapshot(root, output)
    archive = output.expanduser().resolve()
    print(f"Snapshot: {archive}")
    print(f"Files: {count} | source size: {total_bytes / 1024:.1f} KiB | zip: {archive.stat().st_size / 1024:.1f} KiB")


if __name__ == "__main__":
    main()
