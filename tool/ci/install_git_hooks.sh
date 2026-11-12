#!/usr/bin/env bash
# Local, opt-in hook installer. Never clobbers a user's existing hooks.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT"
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo 'ERROR: This repository needs to be a Git checkout before installing hooks.' >&2
  exit 2
fi
HOOKS_CONFIG="$(git config --get core.hooksPath || true)"
if [[ -n "$HOOKS_CONFIG" ]]; then
  if [[ "$HOOKS_CONFIG" == /* ]]; then
    HOOKS_PATH="$HOOKS_CONFIG"
  else
    HOOKS_PATH="$ROOT/$HOOKS_CONFIG"
  fi
else
  HOOKS_PATH="$(git rev-parse --git-path hooks)"
fi
mkdir -p "$HOOKS_PATH"
# Upgrade previously installed generated hooks only if they were not modified.
legacy_pre_commit_sha='9ad5a8247de1f8bd16e39730e440a1b593a564e5c0401d05b0d7ac255c0f1e81'
legacy_pre_push_sha='876ca6462a01b8579e790c72e2e7e683e5c7e48f833ac1e199ad254a6eee4b4b'
previous_pre_commit_sha='0831a1983d77c12f5733c2826d404c7d0587a1ef97010a7164d951f36abfd969'
previous_pre_push_sha='dee54d7e7cb7d8fb0bdb698f678e615debc0e62ad9f85eb958d64e97ee6e7ec6'
for hook in pre-commit pre-push; do
  target="$HOOKS_PATH/$hook"
  if [[ -e "$target" || -L "$target" ]]; then
    # Never overwrite symlinks or user-customized hooks.
    if [[ -f "$target" && ! -L "$target" ]]; then
      expected="$legacy_pre_commit_sha"
      previous="$previous_pre_commit_sha"
      [[ "$hook" == "pre-push" ]] && expected="$legacy_pre_push_sha"
      [[ "$hook" == "pre-push" ]] && previous="$previous_pre_push_sha"
      actual="$(python3 - "$target" <<'PYHASH'
import hashlib
from pathlib import Path
import sys
print(hashlib.sha256(Path(sys.argv[1]).read_bytes()).hexdigest())
PYHASH
)"
      if [[ "$actual" == "$expected" || "$actual" == "$previous" ]]; then
        backup="$target.morph-previous.bak"
        if [[ -e "$backup" || -L "$backup" ]]; then
          echo "SKIP: backup already exists: $backup. Review hooks manually." >&2
          continue
        fi
        cp -p "$target" "$backup"
        cp "tool/ci/hooks/$hook" "$target"
        chmod +x "$target"
        echo "UPDATED: $target (old hook saved as $backup)"
        continue
      fi
      if grep -Fq '.agents/scripts/check_final_release_language.py' "$target"; then
        echo "WARNING: $target points to .agents/. Update this custom hook manually." >&2
      fi
    fi
    echo "SKIP: $target exists; custom hooks are not overwritten." >&2
    continue
  fi
  cp "tool/ci/hooks/$hook" "$target"
  chmod +x "$target"
  echo "INSTALLED: $target"
done
printf '%s\n' 'Hooks run locally; CI remains the independent enforcement layer.'
