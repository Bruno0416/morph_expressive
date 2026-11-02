#!/usr/bin/env bash
# Morph Expressive 0.7.0: local pre-push validation. Never publishes or pushes.
set -Eeuo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

for cmd in dart flutter python3 git; do
  command -v "$cmd" >/dev/null 2>&1 || { echo "Missing required executable: $cmd" >&2; exit 1; }
done

if ! grep -Eq '^version:[[:space:]]*0\.7\.0([[:space:]]*)$' pubspec.yaml; then
  echo 'Expected version: 0.7.0 in root pubspec.yaml; apply the release patch first.' >&2
  exit 1
fi

REPORT_DIR="${MORPH_REPORT_DIR:-${TMPDIR:-/tmp}/morph-v0.7.0-validation-$(date +%Y%m%d-%H%M%S)}"
mkdir -p "$REPORT_DIR"
REPORT_DIR="$(cd "$REPORT_DIR" && pwd)"
echo "Reports: $REPORT_DIR"
echo 'The script performs no commit, tag, push or publish.'

run_log() {
  local name="$1"; shift
  echo
  echo "===== $name ====="
  "$@" 2>&1 | tee "$REPORT_DIR/$name.log"
}

run_log flutter-version flutter --version
run_log git-diff-check git diff --check
run_log format dart format --output=none --set-exit-if-changed lib test example preview/lib preview/test

# Existing source guards, root/preview analysis+tests, and latest/lowest
# dependency resolutions including the Flutter Web release build.
run_log matrix bash tool/check_dependency_matrix.sh all

# Pana evaluates the local, unpublished 0.7.0 package, not the old hosted one.
if ! dart pub global list | grep -Eq '^pana[[:space:]]'; then
  echo 'Installing pana (global tool) ...'
  run_log pana-install dart pub global activate pana
fi
run_log pana dart pub global run pana:pana --json .

python3 - "$REPORT_DIR/pana.log" <<'PY_PARSE'
from pathlib import Path
import json,sys
path=Path(sys.argv[1]); raw=path.read_text(errors='replace')
objects=[]
try: objects.append(json.loads(raw))
except ValueError: pass
for line in raw.splitlines():
    if line.lstrip().startswith('{'):
        try: objects.append(json.loads(line))
        except ValueError: pass

def collect(node):
    if isinstance(node,dict):
        if isinstance(node.get('sections'),list):
            yield node
        for k in ('report','scores','result','data'):
            if k in node:
                yield from collect(node[k])
    elif isinstance(node,list):
        for sub in node:
            yield from collect(sub)

reports=[item for obj in objects for item in collect(obj)]
if not reports:
    print('Pana finished but no structured report could be extracted; review pana.log manually.')
    sys.exit(2)
report=reports[-1]
sections=report.get('sections') or []
if sections:
    points=sum(int(s.get('grantedPoints',0)) for s in sections)
    maximum=sum(int(s.get('maxPoints',0)) for s in sections)
else:
    points=report.get('grantedPoints')
    maximum=report.get('maxPoints')
print(f'\nPana LOCAL 0.7.0 score: {points}/{maximum}')
for section in sections:
    print(f"  {section.get('title',section.get('id','section'))}: {section.get('grantedPoints')}/{section.get('maxPoints')}")
if points is None or maximum is None:
    print('Score missing from Pana report; inspect pana.log manually.')
    sys.exit(2)
if points != maximum:
    print('Pana score is below maximum. Read the section summaries in pana.log before pushing.')
    sys.exit(3)
PY_PARSE

# Verifies metadata, declared images, file inclusion and publishability, but
# deliberately does not upload anything.
run_log pub-dry-run dart pub publish --dry-run

printf '\nPASS: local 0.7.0 Pana + dependency matrix + dry-run.\n'
printf 'Reports retained at: %s\n' "$REPORT_DIR"
printf 'No push or publication was performed.\n'
