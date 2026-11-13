#!/usr/bin/env bash
# Called only by the main-only, fully gated release job after its preflight.
set -euo pipefail
python3 tool/ci/release.py assert-current-main
test -n "${PUB_DEV_TOKEN:-}" || { echo 'Publisher ID token is missing.' >&2; exit 1; }
# pub stores the variable's NAME; its value must survive through publication.
trap 'dart pub token remove https://pub.dev >/dev/null 2>&1 || true; unset PUB_DEV_TOKEN' EXIT
dart pub token add https://pub.dev --env-var=PUB_DEV_TOKEN
dart pub publish --force
