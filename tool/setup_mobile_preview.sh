#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
preview="$repo_root/preview"

command -v flutter >/dev/null 2>&1 || {
  echo "Flutter must be installed and on PATH" >&2
  exit 1
}

cd "$preview"
if [[ ! -d android || ! -d ios ]]; then
  # Keep the existing preview/lib sources and web assets. Flutter creates only
  # the missing platform scaffolding and does not overwrite existing files.
  flutter create --platforms=android,ios --project-name=morph_expressive_preview \
    --org=dev.morph --no-pub .
fi
flutter pub get
printf '\nNative preview ready. Available devices:\n'
flutter devices
cat <<'INSTRUCTIONS'

Android: flutter run -t lib/main_mobile.dart -d YOUR_ANDROID_DEVICE_ID
iPhone:  xcross flutter run -t lib/main_mobile.dart

Do not run Flutter Web for physical haptics testing.
INSTRUCTIONS
