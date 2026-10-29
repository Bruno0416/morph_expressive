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

Open <http://localhost:8080>. The responsive gallery covers 40 component
families with independent theme/brightness, typography and seed controls.
Coverage checks establish family samples, not independent visual coverage
for every exported helper type. For realistic animation performance, compare
against a release Web build, not only a debug run.

The Web gallery intentionally omits the two live backdrop-blur samples
(`Gradient glass` AppBar and `Morph · floating glass`). Running these together
inside the main scrolling showcase is expensive on browser compositors.
Both demos remain available in the native preview and the corresponding
isolated widget tests; no library API or rendering feature is disabled.

## Reproducible animated GIF scenes

The twelve isolated capture scenes are `buttons`, `dropdown`, `segmented`,
`textfields`, `chips`, `sliders`, `loading`, `navigation`, `navigation_morph`,
`navigation_rail_drawer`, `lists` and `dialogs`; their
source lives in `preview/lib/component_gif_capture.dart`. The URL query
`?capture=<scene>` selects a scene without altering the normal gallery.

From the repository root, regenerate **only the changed scenes you touched**:

```bash
bash tool/generate_component_gifs.sh --only chips
bash tool/generate_component_gifs.sh --only textfields
bash tool/generate_component_gifs.sh --only lists --only dialogs
bash tool/generate_component_gifs.sh --only sliders --only loading
bash tool/generate_component_gifs.sh --only navigation_morph
python3 tool/check_gif_branding.py
```

Chips uses **640 x 480 at 15 FPS over approximately 8.7 seconds** and shows
three variants: MD3-inspired filter/input/assist, expressive single selection,
and expressive multiple selection. The multiple sequence shows a circular
first/last transition and connected duplicate/merge between active pills.

Text fields uses **640 x 480 at 15 FPS over approximately 8.2 seconds** and
preserves search and outlined fields while adding the filled exterior-label
sequence (focus, placeholder, typing and blur).

Lists uses **640 x 360 at 15 FPS over approximately 5.8 seconds** and shows
a regular MorphList item alongside swipe-enabled rows revealing actions
without an added trailing overflow icon.

Dialogs uses **640 x 420 at 15 FPS over approximately 6.5 seconds** to show
MorphDialog opening and closing with its scrim and spring transition.

Sliders and loading use **640 x 360 at 15 FPS over 6.8 seconds**; both now
show the 90–98% smoothstep wave flattening, including the wavy range slider
and the determinate circular/linear wavy indicators. Regenerate these GIFs
after changing the wavy amplitude curve. The other standard scenes
retain their 640 x 360, ~4.8-second captures.
Navigation keeps the original MD3E `navigation.gif` unchanged. The new
`navigation_morph` scene (640 × 520, 7.2 seconds) shows the elastic
`.expressive()` M3 pill, the `.morph()` sliding top-dash bar and
expanding/sliding page indicators. **Regenerate this GIF for 0.6.0** because
the constructor mapping, icon sizing and bar geometry changed.
`navigation_rail_drawer` (640 × 500, 6.8 seconds) shows independent selection
animations in a vertical rail and standard drawer. Both use real Morph widgets
and scripted state transitions, not manually rendered mock animations.

The capture script requires Flutter, Node.js/npm, Python 3, curl and FFmpeg;
it installs Playwright/Chromium on first use and builds the Web preview in
release mode. No Playwright dependency is installed for library consumers.

You can override `MORPH_GIF_FPS` (8-30), `MORPH_GIF_SECONDS` or the local server
port. `--skip-build` reuses a previously built release preview and **must not**
be used after editing scene source. Review the generated files before a
release, and commit GIF changes together with their README references.

## 0.3.0 interaction review

- Multi-selection: verify 0 -> 1 and 1 -> 0 circular bloom, and non-boundary
  duplicate/merge movement with nearest selected chip.
- Filled text fields: verify empty, focused, populated and blurred label
  positions, including no overlap with a placeholder or entered value. The
  gallery also includes no-icon, prefix-icon, and suffix-icon error-state
  examples in filled and outlined styles.
- Dialogs: verify floating modal entrance, barrier scrim and spring exit.
- Lists: verify swipe reveal opens/closes cleanly, action pills keep their
  spacing, and swipeable rows do not show a synthetic trailing overflow icon.
- Haptics: use the preview app bar preferences (Off/Light/Medium/Heavy), then
  verify physical intensity on a device because Web may lack feedback.
- Tabs and rail: tab focus should not scroll the outer page unexpectedly; the
  isolated rail demo should not tint itself from neighboring tab-body scroll.

## Verification

From the repository root:

```bash
bash tool/check.sh
```

## 0.3.1 regression review

- Scrub wavy slider and range slider progress through 10–15% and 90–98%; the
  wave amplitude must change continuously without a step or flicker.
- Repeat for determinate linear and circular wavy progress indicators.
  Custom amplitude callbacks and indeterminate states must be unaffected.
- Test both single-date and date-range input dialogs in portrait/landscape,
  with validation errors, on-screen keyboard, narrow screens and text scaling.
  Both range fields must share the same painted-surface top edge through
  focus, content and errors, with no whole-form jump when validation appears.
  Cancel/OK must remain reachable by scrolling.

## 0.4.0 native touch lab and interaction review

The browser gallery remains `preview/lib/main.dart`. For a physical iPhone or
Android device, use the native-only touch lab:

```bash
cd preview
flutter pub get
flutter test test/mobile_haptics_lab_test.dart
flutter run -t lib/main_mobile.dart
```

The device build needs its normal iOS signing/Android setup. The library does
not require CoreHapticsFFI or extra native packages. On iOS, Xcode signing is
still needed to install the preview app on a personal device.

- Compare Light / Medium / Heavy and Off across button groups, navigation,
  list swipe thresholds, refresh activation/completion, and sliders.
- Verify slider/range-slider motion is silent when continuous, but clicks once
  per changed `divisions` step. No persistent haptic waveform is used.
- Open one swipe row and reveal another: the first closes with motion, rather
  than snapping closed. Verify the three-dot affordance if the host enables it.
- Pull the refresh indicator: the ring fills, transitions to indeterminate,
  completes with a spin, then dismisses; color and background follow the
  active theme.
- Compare standard and wavy circular indicators at 16, 24, 48, and 64 dp.

Historical GIF scenes under `preview/lib/component_gif_capture.dart` are
separate from the mobile touch lab. Only regenerate GIFs if their captured
appearance or scripted interactions have changed and review the results.
