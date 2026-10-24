#!/usr/bin/env bash
# Genera los GIFs del README a partir de las escenas de Flutter Web.
# Requisitos: Flutter (SDK del repositorio), Node.js/npm, Python 3 y FFmpeg.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CAPTURE_DIR="$ROOT_DIR/tool/gif_capture"
PREVIEW_DIR="$ROOT_DIR/preview"
PORT="${MORPH_GIF_PORT:-8765}"
SKIP_BUILD=0
ONLY=()

while (($#)); do
  case "$1" in
    --only)
      if (($# < 2)); then echo 'Falta el nombre tras --only' >&2; exit 2; fi
      ONLY+=(--only "$2"); shift 2 ;;
    --skip-build) SKIP_BUILD=1; shift ;;
    -h|--help)
      cat <<'HELP'
Uso: bash tool/generate_component_gifs.sh [--only ESCENA ...] [--skip-build]
Escenas: buttons dropdown segmented textfields chips sliders loading navigation navigation_morph navigation_rail_drawer lists dialogs
Escenas chips/textfields: 640x480, 8.7s/8.2s para mostrar todas las variantes.
Escena navigation_morph: 640x520, 7.2s (bar Morph, expressive y páginas).
Escena navigation_rail_drawer: 640x500, 6.8s (rail y drawer Morph).
Escena lists: 640x360, 5.8s para mostrar el reveal/close de swipe actions.
Escena dialogs: 640x420, 6.5s para mostrar las animaciones del modal.
Escenas sliders/loading: 640x360, 6.8s para capturar el aplanamiento wavy 90–98%.
Otras escenas: 640x360, 4.8s (sin cambios).
Variables: MORPH_GIF_FPS=15, MORPH_GIF_SECONDS=duración opcional, MORPH_GIF_PORT=8765
Requiere: flutter, npm/node, python3 y ffmpeg. Primera ejecución instala Playwright/Chromium.
HELP
      exit 0 ;;
    *) echo "Opción no reconocida: $1" >&2; exit 2 ;;
  esac
done

for cmd in flutter npm node python3 ffmpeg curl; do
  command -v "$cmd" >/dev/null 2>&1 || {
    echo "[gif] Falta el comando requerido: $cmd" >&2
    exit 1
  }
done

if [[ ! -d "$CAPTURE_DIR/node_modules/playwright" ]]; then
  echo '[gif] Instalando Playwright (solo herramienta de desarrollo)...'
  npm install --prefix "$CAPTURE_DIR" --no-audit --no-fund
fi

# Descarga Chromium una única vez y lo reutiliza desde la caché de Playwright.
"$CAPTURE_DIR/node_modules/.bin/playwright" install chromium

if (( ! SKIP_BUILD )); then
  echo '[gif] Compilando la preview Flutter Web en release...'
  (cd "$ROOT_DIR" && flutter pub get)
  (cd "$PREVIEW_DIR" && flutter clean && flutter pub get && flutter build web --release)
fi

[[ -f "$PREVIEW_DIR/build/web/index.html" ]] || {
  echo '[gif] No existe preview/build/web/index.html. Ejecuta sin --skip-build.' >&2
  exit 1
}

# Evita capturar GIFs de una compilación antigua después de cambiar el branding.
for asset in "$PREVIEW_DIR/build/web/index.html" "$PREVIEW_DIR/build/web/main.dart.js"; do
  if [[ ! -f "$asset" ]]; then
    echo "[gif] Falta un recurso compilado: $asset" >&2
    exit 1
  fi
  if grep -Eiq 'Morph[[:space:]]+UI' "$asset"; then
    echo "[gif] Branding antiguo detectado en $asset. Regenera sin --skip-build." >&2
    exit 1
  fi
done

LOG_FILE="$(mktemp)"
SERVER_PID=''
cleanup() {
  if [[ -n "$SERVER_PID" ]]; then
    kill "$SERVER_PID" 2>/dev/null || true
    wait "$SERVER_PID" 2>/dev/null || true
  fi
  rm -f "$LOG_FILE"
}
trap cleanup EXIT INT TERM

python3 -m http.server "$PORT" --bind 127.0.0.1 \
  --directory "$PREVIEW_DIR/build/web" >"$LOG_FILE" 2>&1 &
SERVER_PID=$!

UP=0
for _ in {1..60}; do
  if curl -fsS "http://127.0.0.1:$PORT/" >/dev/null 2>&1; then
    UP=1
    break
  fi
  if ! kill -0 "$SERVER_PID" 2>/dev/null; then break; fi
  sleep 0.25
done
if (( ! UP )); then
  echo '[gif] No se pudo iniciar el servidor HTTP local:' >&2
  cat "$LOG_FILE" >&2
  exit 1
fi

echo '[gif] Capturando los componentes sin cursor...'
MORPH_GIF_URL="http://127.0.0.1:$PORT/" \
  node "$CAPTURE_DIR/capture.mjs" "${ONLY[@]}"
