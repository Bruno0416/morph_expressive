# Component preview

## Tabs Lab

Gallery toolbar: **Tabs Lab**, or <http://127.0.0.1:8081/?lab=tabs>. Native direct
entry: `flutter run -d linux --release --dart-define=MORPH_LAB=tabs` in `preview/`.
Ten sections (underline, pill, rounded rectangle, slide vs elastic, fit,
distribution, scrollable bar, icons and badges, bar linked to real pages with a
live progress readout, independent controlled bar) and controls for presentation,
motion, duration, radii, thickness, insets, requested vs effective renderer,
reduced motion, RTL, 2× text and mobile width. Reproducible actions: first → last,
rapid changes, slow jump to interrupt with a swipe, change a label/badge, add or
remove tabs. See [Tabs: continuous selection](TABS.md).

## Operation & Skeleton Lab

Gallery toolbar: **Operation & Skeleton Lab**, or
<http://127.0.0.1:8081/?lab=operations>. Native direct entry:
`flutter run -d linux --release --dart-define=MORPH_LAB=operations` in `preview/`.
See [operation/loading API and examples](OPERATION_LOADING.md).

## Shape & Interaction Lab

Open `?lab=shapes` or the gallery toolbar's **Shape & Interaction Lab** action.
Route priority is benchmark environment flag > `?capture=...` > `?lab=shapes`
> existing gallery/mobile selection. Theme and seed controls use the Morph host.
The lab includes 35 shape pairs, progress/retarget, renderer diagnostics, an
always-accessible procedural ellipse Shader example, button timings, live loader
sequence and controlled shape buttons. Rounding/smoothing are explained as
unavailable for fixed catalog definitions. No simulated FPS is displayed.

Verified release server for this checkout:
<http://127.0.0.1:8081/?lab=shapes>. It serves `preview/build/web`:

```bash
cd preview
flutter build web --release
python3 -m http.server 8081 --bind 0.0.0.0 --directory build/web
```

Remote access requires forwarding port 8081; this is not a public hosted URL.
The existing Web/Linux runners are retained. Do not rerun `flutter create` merely
to open the lab. Detailed capabilities and limits: [SHAPE_ENGINE.md](SHAPE_ENGINE.md).

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

## Frosted surfaces and scroll compatibility (mobile preview)

The native mobile preview contains **Frosted Surfaces** and its
**Scroll Blur Compatibility Lab**. To validate unreleased source changes:

```bash
cd preview
flutter analyze
flutter test test/mobile_frosted_scroll_behavior_test.dart
flutter test test/mobile_scroll_blur_lab_test.dart
flutter test
flutter run -t lib/main_mobile.dart
```

The mobile app configures `MorphScrollBehavior` for its scrollable subtree;
individual laboratory modes can override it to show the original Flutter
stretch for comparison. Check repeated pulls at the leading and trailing
edges, dark/light palettes, blur enabled/disabled, and hit testing while
stretch is recovering. Cards that demonstrate blur explicitly opt in, because
ordinary `MorphCard` instances now stay opaque by default. Use a real device
(or a representative GPU emulator) to confirm that the backdrop samples the
expected background; widget tests alone cannot establish that visual property.

Read [Frosted surfaces](FROSTED_SURFACES.md) and
[MorphScrollBehavior](MORPH_SCROLL.md) for the public APIs.

## Reproducible animated GIF scenes

The 14 README GIFs come from isolated capture scenes in
`preview/lib/component_gif_capture.dart`; `?capture=<scene>` selects one without
touching the gallery. Scenes: `buttons`, `chips`, `dialogs`, `dropdown`, `lists`,
`loading`, `navigation`, `segmented`, `sliders`, `textfields`, `async_button`,
`skeleton`, `tabs` and `fab_menu`. `navigation_rail_drawer` is kept only for the
rail/drawer example in [NAVIGATION_MORPH.md](NAVIGATION_MORPH.md); it is not part
of the default set.

| Scene | Canvas | Duration | GIF fps | Content |
| --- | --- | --- | --- | --- |
| `buttons` | 640×370 | 7.2 s | 50 | Filled, tonal, elevated, outlined and text buttons pressed one at a time; four `MorphShapeButton`s (rotation, press, morph, rotation + morph), each pressed twice so the loop joins |
| `segmented` | 640×350 | 7.2 s | 50 | `MorphSegmentedToggle`, the connected `MorphButtonGroup` and the reactive group (expansion 0.08), one row at a time |
| `loading` | 640×310 | 8 s | 50 | Free and contained loaders, circular, circular wavy, linear and linear wavy progress; determinate values advance together |
| `navigation` | 640×350 | 7.2 s | 50 | Only Morph variants (`.expressive`, `.morph`) and page indicators |
| `async_button` | 640×260 | 10.6 s | 50 | Preserved/compact: idle → loading → success → loading → error |
| `skeleton` | 640×340 | 8.3 s | 50 | One tilted shimmer, then the real content |
| `tabs` | 640×380 | 7.5 s | 50 | Rounded underline and pill; selection change, reversed swipe, completed swipe |
| `fab_menu` | 640×400 | 7.7 s | 50 | FAB small / regular / medium / large, extended FABs, and the FAB menu opening and closing |
| `navigation_rail_drawer` | 640×380 | 7.6 s | 50 | Rail and drawer selection with the organic stretch (renderer checked outside the image) |
| `lists`, `sliders`, `dropdown` | 640×340 / 360 / 320 | 5.8 / 6.8 / 4.8 s | 50 | Unchanged sequences |
| `chips`, `textfields`, `dialogs` | 640×340 / 420 / 360 | 8.7 / 8.2 / 6.5 s | 25 | Unchanged sequences; the page produces 40, 25 and 14 real frames per second respectively, so 25 fps does not repeat frames artificially |

All headers are compact (title and short description on one line) so the
components use the canvas; the watermark stays clear of every scene.

Scenes drive the real widgets: state changes through timers and, where press or
drag feedback matters (buttons, segmented, async button, tabs), real pointer
events dispatched to the gesture binding. No cursor is rendered, no lab controls
or debug metrics appear, and no component is altered for the capture.

Each scene prints a start marker (`MORPH_GIF_SCENE_START`) once its first frame
is laid out. The capture tool starts recording 1.2 s later, after fonts and
shader programs had time to load. Frames come from the compositor screencast
(about 60 per second, each with its real timestamp) and are sampled on a uniform
1/fps grid: nothing is duplicated or interpolated to raise the rate, so playback
speed matches the real animation (a still screen repeats the last real frame).
GIF delays are centiseconds, so 50 fps (20 ms) is the fastest uniform rate. Sequences
return to their first state so the loop joins; the continuous rotation of the
ShapeButton is the only element with a small phase offset at the seam. Scenes
also print the effective renderer (`MORPH_GIF_RENDERER`); the rail/drawer capture
fails unless the organic stretch really runs on the Shader.

From the repository root (requires Flutter, Node.js/npm, Python 3, curl and
FFmpeg; Playwright/Chromium install on first use and are never a consumer
dependency):

```bash
bash tool/generate_component_gifs.sh                 # all 14, builds the Web preview
bash tool/generate_component_gifs.sh --only tabs     # one scene
python3 tool/check_gif_branding.py                   # assets, README and pub.dev gallery
```

`--skip-build` reuses a previous release build and must not be used after
editing a scene. `MORPH_GIF_FPS` (8–50) forces one frame rate for every scene; `MORPH_GIF_COLORS` and
`MORPH_GIF_DITHER` tune the palette.
Inspect the first frame, intermediate states, open/expanded states, the close
and the loop join before committing GIFs together with their README references.

pub.dev declares ten of the images (`pubspec.yaml` → `screenshots`: async_button,
skeleton, fab_menu, buttons, segmented, tabs, loading, navigation, dropdown,
lists); the README shows all 14. Screenshots are documentation only and are not
Flutter assets.

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
