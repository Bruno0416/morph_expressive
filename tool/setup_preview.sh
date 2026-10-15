#!/usr/bin/env bash
set -euo pipefail

# ---------- preparar la galeria web ----------
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT/preview"
flutter create --platforms=web .
flutter pub get
printf '\nPreview ready: cd preview && flutter run -d chrome\n'
