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

Open <http://localhost:8080>. The responsive gallery covers 39 component
families with independent theme/brightness, typography and seed controls.
Coverage checks establish family samples, not independent visual coverage
for every exported helper type. For realistic animation performance, compare
against a release Web build, not only a debug run.

## Reproducible animated GIF scenes

The eight isolated capture scenes are `buttons`, `dropdown`, `segmented`,
`textfields`, `chips`, `sliders`, `loading` and `navigation`; their source
lives in `preview/lib/component_gif_capture.dart`. The URL query
`?capture=<scene>` selects a scene without altering the normal gallery.

From the repository root, regenerate **only the two changed scenes**:

```bash
bash tool/generate_component_gifs.sh --only chips
bash tool/generate_component_gifs.sh --only textfields
python3 tool/check_gif_branding.py
```

Chips uses **640 x 480 at 15 FPS over approximately 8.7 seconds** and shows
three variants: MD3-inspired filter/input/assist, expressive single selection,
and expressive multiple selection. The multiple sequence shows a circular
first/last transition and connected duplicate/merge between active pills.

Text fields uses **640 x 480 at 15 FPS over approximately 8.2 seconds** and
preserves search and outlined fields while adding the filled exterior-label
sequence (focus, placeholder, typing and blur).

The other six scenes keep their established 640 x 360, ~4.8-second captures.
The capture script requires Flutter, Node.js/npm, Python 3, curl and FFmpeg;
it installs Playwright/Chromium on first use and builds the Web preview in
release mode. No Playwright dependency is installed for library consumers.

You can override `MORPH_GIF_FPS` (8-30), `MORPH_GIF_SECONDS` or the local server
port. `--skip-build` reuses a previously built release preview and **must not**
be used after editing scene source. Review the generated files before a
release, and commit GIF changes together with their README references.

## 0.2.0 interaction review

- Multi-selection: verify 0 -> 1 and 1 -> 0 circular bloom, and non-boundary
  duplicate/merge movement with nearest selected chip.
- Filled text fields: verify empty, focused, populated and blurred label
  positions, including no overlap with a placeholder or entered value.
- Haptics: use the preview app bar preferences (Off/Light/Medium/Heavy), then
  verify physical intensity on a device because Web may lack feedback.
- Tabs and rail: tab focus should not scroll the outer page unexpectedly; the
  isolated rail demo should not tint itself from neighboring tab-body scroll.

## Verification

From the repository root:

```bash
bash tool/check.sh
```
