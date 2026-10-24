#!/usr/bin/env bash
# Resolve and test disposable copies; never rewrite the working lockfiles.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MODE="${1:-all}"
case "$MODE" in
  all) MODES=(latest lowest) ;;
  latest|lowest) MODES=("$MODE") ;;
  *) printf 'Usage: bash tool/check_dependency_matrix.sh [all|latest|lowest]\n' >&2; exit 2 ;;
esac
command -v flutter >/dev/null || { printf 'Flutter SDK is required.\n' >&2; exit 1; }
WORK="$(mktemp -d "${TMPDIR:-/tmp}/morph-dependencies.XXXXXX")"
trap 'rm -rf "$WORK"' EXIT

for resolution in "${MODES[@]}"; do
  target="$WORK/$resolution"
  python3 - "$ROOT" "$target" <<'PY'
from pathlib import Path
import shutil
import sys

source, target = map(Path, sys.argv[1:])
shutil.copytree(
    source, target,
    ignore=shutil.ignore_patterns(
        '.git', '.idea', '.dart_tool', '.gradle', '.cxx',
        '.plugin_symlinks', 'build', 'coverage', '__pycache__',
        'DerivedData', 'ephemeral', 'node_modules', 'Pods',
        'docs', '*.zip', '*.patch', 'pubspec.lock', '.flutter-plugins-dependencies',
    ),
)
PY
  (
    cd "$target"
    printf '\nMorph dependency resolution: %s\n' "$resolution"
    if [[ "$resolution" == latest ]]; then
      flutter pub upgrade
      (cd preview && flutter pub upgrade)
    else
      flutter pub downgrade
      (cd preview && flutter pub downgrade)
    fi
    flutter pub deps --style=compact
    dart format --output=none --set-exit-if-changed lib test example preview/lib preview/test
    bash tool/check.sh
    (cd preview && flutter build web --release --no-pub)
  )
done
