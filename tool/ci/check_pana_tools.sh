#!/usr/bin/env bash
# pana 0.23.19 uses these WebP commands for screenshots and thumbnails.
set -euo pipefail
missing=0
for tool in webpinfo cwebp dwebp gif2webp webpmux; do
  if ! command -v "$tool" >/dev/null 2>&1; then
    printf 'Missing pana screenshot dependency: %s (Ubuntu/Debian package: webp)\n' "$tool" >&2
    missing=1
  fi
done
if [ "$missing" -ne 0 ]; then exit 1; fi
printf '%s\n' 'Pana screenshot tools are available.'
