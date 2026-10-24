#!/usr/bin/env bash
# Verificacion unica de la libreria y su galeria de ejemplo.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

python3 tool/check_api.py
python3 tool/check_package_identity.py
python3 tool/check_gif_branding.py
python3 tool/check_icons.py
python3 tool/check_motion.py
python3 tool/check_morph_names.py
python3 tool/check_preview_coverage.py
python3 tool/check_third_party_notices.py
python3 -m unittest discover -s tool -p 'test_*.py'
python3 tool/check_dependency_imports.py

command -v flutter >/dev/null || {
  printf '%s\n' 'Flutter SDK is required for analysis and tests.' >&2
  exit 1
}
flutter pub get
flutter analyze
flutter test

(
  cd preview
  flutter pub get
  flutter analyze
  flutter test
)
printf '%s\n' 'Morph Expressive: all checks completed.'
