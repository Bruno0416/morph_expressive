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
python3 tool/check_button_surface_docs.py
python3 tool/check_preview_coverage.py
python3 tool/check_secure_links.py
python3 tool/check_third_party_notices.py
python3 -m unittest discover -s tool -p 'test_*.py'
python3 tool/check_dependency_imports.py

command -v flutter >/dev/null || {
  printf '%s\n' 'Flutter SDK is required for analysis and tests.' >&2
  exit 1
}
flutter pub get
# Root analysis also visits the nested preview package on a clean CI checkout.
# Resolve BOTH package configurations before the first analysis or test.
(
  cd preview
  flutter pub get
)
for package_config in .dart_tool/package_config.json preview/.dart_tool/package_config.json; do
  test -s "$package_config" || {
    printf 'Missing package configuration after dependency resolution: %s\n' "$package_config" >&2
    exit 1
  }
done
# The Widgetbook navigation tree is generated from @UseCase annotations and
# checked in. Regenerate it and fail when the committed copy was stale.
(
  cd preview
  generated=lib/main.directories.g.dart
  before="$(mktemp)"
  trap 'rm -f "$before"' EXIT
  cp "$generated" "$before"
  dart run build_runner build
  dart format "$generated" >/dev/null
  cmp -s "$before" "$generated" || {
    printf '%s\n' "preview/$generated was stale; it has been regenerated, review and keep it." >&2
    exit 1
  }
)
flutter analyze
flutter test

(
  cd preview
  flutter analyze
  flutter test
  # The Widgetbook catalog must also compile for the web release target.
  flutter build web --release
)
printf '%s\n' 'Morph Expressive: all checks completed.'
