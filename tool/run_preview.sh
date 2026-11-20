#!/usr/bin/env bash
set -euo pipefail

die() { printf '%s\n' "$1" >&2; exit 1; }

printf 'Widgetbook\n  1) Nativa (escritorio)\n  2) Firefox (puerto 8080)\n'
while true; do
  printf 'Elige una opción [1-2]: '
  IFS= read -r choice || exit 1
  case "$choice" in
    1|2) break ;;
    *) printf 'Opción inválida. Escribe 1 o 2.\n' >&2 ;;
  esac
done

command -v flutter >/dev/null || die 'Flutter no está en el PATH.'
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$root/preview"
os="$(uname -s)"

if [[ "$choice" == 1 ]]; then
  case "$os" in
    Linux) device=linux ;;
    Darwin) device=macos ;;
    MINGW*|MSYS*|CYGWIN*) device=windows ;;
    *) die "Plataforma de escritorio no compatible: $os" ;;
  esac
  if [[ ! -d "$device" ]]; then
    # Flutter create also rewrites the lockfile; import only the platform files.
    (
      staging="$(mktemp -d)"
      trap 'rm -rf -- "$staging"' EXIT
      (cd "$staging" && flutter create --platforms="$device" \
        --project-name=morph_expressive_preview --org=dev.morph --empty --no-pub .)
      mv "$staging/$device" .
    )
  fi
  exec flutter run -d "$device" -t lib/main.dart
fi

firefox="$(command -v firefox || command -v firefox.exe || true)"
if [[ -z "$firefox" ]]; then
  case "$os" in
    Darwin) firefox='/Applications/Firefox.app/Contents/MacOS/firefox' ;;
    MINGW*|MSYS*|CYGWIN*) firefox="${ProgramFiles:-C:/Program Files}/Mozilla Firefox/firefox.exe" ;;
  esac
  [[ -n "$firefox" && -x "$firefox" ]] || die 'No se encontró Firefox. Instálalo o añádelo al PATH.'
fi
command -v curl >/dev/null || die 'La opción Firefox requiere curl.'
url='http://127.0.0.1:8080/'
if curl --noproxy '*' --silent --output /dev/null --max-time 1 "$url"; then
  die 'El puerto 8080 ya está en uso.'
fi

# Keep Flutter in the foreground so its interactive commands still work.
(
  until curl --noproxy '*' --fail --silent --output /dev/null --max-time 2 "$url"; do
    sleep 1
  done
  "$firefox" "$url" &
) &
watcher=$!
trap 'kill "$watcher" 2>/dev/null || true' EXIT
flutter run -d web-server -t lib/main.dart --web-hostname 127.0.0.1 --web-port 8080
