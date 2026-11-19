#!/usr/bin/env bash
# Generates the README GIFs from the Flutter Web scenes.
# Requirements: Flutter (the repository SDK), Node.js/npm, Python 3 and FFmpeg.
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
      if (($# < 2)); then echo 'Missing the scene name after --only' >&2; exit 2; fi
      ONLY+=(--only "$2"); shift 2 ;;
    --skip-build) SKIP_BUILD=1; shift ;;
    -h|--help)
      cat <<'HELP'
Usage: bash tool/generate_component_gifs.sh [--only SCENE ...] [--skip-build]
Scenes: buttons chips dialogs dropdown lists loading navigation segmented
  sliders textfields async_button skeleton tabs fab_menu variants density context_menu frosted
  (the README uses a subset: see ALLOWED_GIFS in tool/check_gif_branding.py)
Guide-only scene: navigation_rail_drawer (not part of the default set).
Each scene marks its start (MORPH_GIF_SCENE_START); recording starts 1.2 s later (fonts and shaders ready).
Frames come from the compositor screencast (~60/s, with their real timestamps) and are
sampled on a uniform grid: no duplication or interpolation. All showcases are 640x360
(16:9) at 25 FPS (4 cs) or 50 FPS (2 cs, the uniform GIF maximum) for fast motion. The
navigation_rail_drawer scene also checks the effective renderer outside the image.
Sizes: see sceneSettings in tool/gif_capture/capture.mjs.
Variables: MORPH_GIF_FPS=8..50 (forces the same value for every scene), MORPH_GIF_SECONDS=optional duration, MORPH_GIF_PORT=8765
Requires: flutter, npm/node, python3 and ffmpeg. The first run installs Playwright/Chromium.
HELP
      exit 0 ;;
    *) echo "Unknown option: $1" >&2; exit 2 ;;
  esac
done

for cmd in flutter npm node python3 ffmpeg curl; do
  command -v "$cmd" >/dev/null 2>&1 || {
    echo "[gif] Missing required command: $cmd" >&2
    exit 1
  }
done

if [[ ! -d "$CAPTURE_DIR/node_modules/playwright" ]]; then
  echo '[gif] Installing Playwright (development tool only)...'
  npm install --prefix "$CAPTURE_DIR" --no-audit --no-fund
fi

# Downloads Chromium once and reuses it from the Playwright cache.
"$CAPTURE_DIR/node_modules/.bin/playwright" install chromium

if (( ! SKIP_BUILD )); then
  echo '[gif] Building the Flutter Web preview in release mode...'
  (cd "$ROOT_DIR" && flutter pub get)
  (cd "$PREVIEW_DIR" && flutter pub get && flutter build web --release)
fi

[[ -f "$PREVIEW_DIR/build/web/index.html" ]] || {
  echo '[gif] preview/build/web/index.html does not exist. Run without --skip-build.' >&2
  exit 1
}

# Avoid capturing GIFs from an old build after a branding change.
for asset in "$PREVIEW_DIR/build/web/index.html" "$PREVIEW_DIR/build/web/main.dart.js"; do
  if [[ ! -f "$asset" ]]; then
    echo "[gif] Missing built asset: $asset" >&2
    exit 1
  fi
  if grep -Eiq 'Morph[[:space:]]+UI' "$asset"; then
    echo "[gif] Old branding detected in $asset. Regenerate without --skip-build." >&2
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
  echo '[gif] Could not start the local HTTP server:' >&2
  cat "$LOG_FILE" >&2
  exit 1
fi

echo '[gif] Capturing the scenes (none shows a cursor except context_menu, which draws its own)...'
MORPH_GIF_URL="http://127.0.0.1:$PORT/" \
  node "$CAPTURE_DIR/capture.mjs" "${ONLY[@]}"
