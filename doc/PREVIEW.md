# Component preview

`preview/` is a separate Flutter application for inspecting and interacting
with Morph Expressive. It is not part of the package's runtime API.

## Run locally

From the repository root:

```bash
bash tool/setup_preview.sh
cd preview
flutter pub get
flutter run -d web-server --web-port 8080
```

Open <http://localhost:8080>. The current **development** gallery displays
examples by category with theme, typography, and seed controls. The source
coverage check verifies that families have samples; it does not certify
independent visual coverage of every exported helper class.

## Verification

```bash
# From the repository root
bash tool/check.sh
```

For more realistic Web animation performance, compare with
`flutter build web --release` instead of relying only on debug Web.

## Continuous showcase

The preview displays all component families in one lazy, vertically scrolling
showcase. Responsive rows place multiple families side by side when space allows.
It includes interactive examples and independent light/dark, typography and
seed controls; it does not include the removed Fluent icon-grid diagnostic.

## Automatic GIF previews

From the repository root:

```bash
bash tool/generate_component_gifs.sh
# Optional: regenerate only dropdown, reuse an existing Web build
bash tool/generate_component_gifs.sh --only dropdown --skip-build
```

Requirements: Flutter, Node.js/npm, Python 3, curl and FFmpeg. The script
installs Playwright/Chromium the first time, builds `preview/` in release mode,
starts a temporary local HTTP server, captures eight isolated 640x360 scenes at
15 FPS without a visible mouse cursor, and optimizes them into
`doc/assets/gifs/*.gif` using FFmpeg. Every scene automatically performs
interactions through its own Flutter state; there are no brittle pixel-based
Playwright clicks.

The eight scenes are `buttons`, `dropdown`, `segmented`, `textfields`,
`chips`, `sliders`, `loading`, and `navigation`. Their implementation lives in
`preview/lib/component_gif_capture.dart`.
They are selected by `?capture=<scene>` so the regular showcase is unchanged.

You can adjust `MORPH_GIF_FPS` (8–30) and `MORPH_GIF_SECONDS` (4.5–12).
Generated GIFs are README assets: review them and commit the files with the
README to avoid broken images on GitHub. The capture tooling is developer-only;
no Playwright dependency is required by consumers of `morph_expressive`.
