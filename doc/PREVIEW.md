# Component preview

`preview/` is a separate Flutter application for inspecting and interacting
with Morph Expressive. It is not part of the package's runtime API and its
dependencies (Widgetbook, build_runner) never reach the published package.

The default entry point is a **Widgetbook** catalog. It replaces the former
single-page gallery: every exported widget is reachable from Widgetbook's
navigation tree, and all controls are Widgetbook addons and knobs.

## Run locally

From the repository root:

```bash
flutter pub get
cd preview
flutter pub get
dart run build_runner build      # regenerates lib/main.directories.g.dart
flutter run -d web-server --web-hostname 127.0.0.1 --web-port 8081
```

Open <http://127.0.0.1:8081/>. For realistic animation and blur performance,
use a release build:

```bash
cd preview
flutter build web --release
python3 -m http.server 8081 --bind 127.0.0.1 --directory build/web
```

Remote access requires forwarding port 8081; this is not a public hosted URL.

## Catalog structure

```
preview/lib/
├── main.dart                        # route selection + @App MorphWidgetbookApp
├── main.directories.g.dart          # generated navigation tree (checked in)
├── component_catalog.dart           # generated list of exported widgets
└── widgetbook/
    ├── app/                         # Widgetbook app and addon order
    ├── addons/                      # Morph scope (theme/seed/RTL/motion) and backgrounds
    ├── themes/                      # seed presets and shared Widgetbook config
    ├── utilities/                   # stages, knob helpers, lab hosts
    ├── coverage_manifest.dart       # exported widget -> Widgetbook paths
    └── use_cases/
        ├── foundations/  actions/  selection/  inputs/
        └── navigation/   surfaces/ feedback/   overlays/
```

Top-level categories: **Foundations** (colors and themes, typography, shapes,
motion, surfaces), **Actions** (buttons, icon buttons, button groups, split
buttons, FAB, extended FAB, FAB menu, async buttons, shape buttons),
**Selection** (chips, segmented controls, checkbox, radio, switch), **Inputs**
(text fields, dropdowns, sliders, search, date and time pickers),
**Navigation** (navigation bar, rail, drawer, tabs, page indicator, app bars,
toolbars), **Surfaces & Content** (cards, lists, badges, dividers, carousels),
**Feedback** (loading indicator, progress, skeleton, refresh indicator,
snackbar) and **Overlays** (dialogs, bottom and side sheets, menus, tooltips).

Buttons, icon buttons and cards have a **Matrix** use case (visual type ×
`MorphVariant`, plus a frosted row over a decorative backdrop) and a
**Playground** whose knobs select the named constructor, variant, surface,
size, shape, enabled, selected, label and icon. See
[Component API](API_V1.md).

## Global controls

| Addon | Options |
| --- | --- |
| Morph theme | Light / Dark / System; density (Compact / Standard / Comfortable, applied with `copyWith(density:)` on the real theme); seed presets (Violet default, Blue, Green, Red, Yellow, Teal, Gray, near black, near white) and a custom hex seed; RTL; reduced motion; high contrast |
| Background | Theme surface, light, dark, high contrast, colored, decorative gradient, image-like pattern (for judging frosted surfaces) |
| Viewport | Fill, compact mobile 320×568, mobile 390×844, tablet 834×1112, desktop 1280×800 |
| Text scale | 0.8× to 2.0× |
| Inspector | Widget inspector overlay |

The Morph addon builds a real `MorphThemeData` from the selected seed and
installs `MorphTheme`, the adapted Material `ThemeData` and `MorphMotionScope`
around every use case, each with its own `Navigator` and `Overlay`. Morph
dialogs push on the root navigator, so the same theme is also installed
around the Widgetbook app; dialogs therefore cover the whole window.

## Adding a use case

1. Add an annotated top-level builder in the family's file under
   `preview/lib/widgetbook/use_cases/<category>/`:

   ```dart
   @widgetbook.UseCase(name: 'Playground', type: MorphButton, path: '[Actions]/Buttons')
   Widget buttonPlayground(BuildContext context) {
     final MorphVariant? variant = variantKnob(context);
     return StageCenter(child: MorphButton.tonal(variant: variant, onPressed: () {}, child: const Text('Tonal')));
   }
   ```

2. Regenerate the tree with `dart run build_runner build` in `preview/`.
3. For a newly exported widget, run `python3 tool/generate_preview_catalog.py`
   and add it to `coverage_manifest.dart`.
4. Run `python3 tool/check_preview_coverage.py` and `flutter test` in
   `preview/`. The checks fail when an exported widget, a named constructor of
   a visual-type family, or a `variant`/`surface` axis is not represented.

Keep stateful harnesses (controllers, timers, simulated operations) inside the
preview, dispose them, and key them on structural knob changes.

## Labs and direct routes

The labs are Widgetbook use cases and keep their direct routes. Route priority:
benchmark/native/probe defines > `?lab=operations` > `?lab=tabs` >
`?capture=<scene>` > `?lab=shapes` > Widgetbook.

- **Tabs Lab** (`Navigation/Tabs`, `?lab=tabs`, native
  `--dart-define=MORPH_LAB=tabs`): ten sections and controls for presentation,
  motion, duration, radii, insets, renderer, reduced motion, RTL and text
  scale. See [Tabs: continuous selection](TABS.md).
- **Operation & Skeleton Lab** (`Feedback/Skeleton`, `?lab=operations`). See
  [operation/loading API and examples](OPERATION_LOADING.md).
- **Shape & Interaction Lab** (`Foundations/Shapes`, `?lab=shapes`): 35 shape
  pairs, progress/retarget, renderer diagnostics and controlled shape buttons.
  See [SHAPE_ENGINE.md](SHAPE_ENGINE.md).
- **Density Lab** (`Foundations/Density`): overview, controls, inputs,
  navigation and content matrices with the three densities side by side
  (each column is a nested `MorphTheme`), spacing and token readouts, and
  visual versus hit-target sizes.
- **Badge Lab** (`Surfaces & Content/Badges`): colors, sizes, counts and caps,
  labels, light/dark comparison, density and live contrast ratios.
- **Desktop Context Menu Lab** (`Overlays/Context menus`): real right-click
  surfaces for simple, icon, shortcut, long-label, destructive and disabled,
  checkable, grouped, nested-submenu, scrolling and viewport-edge menus,
  keyboard (Shift+F10, Menu key) and hover behavior, a density comparison and a
  standard-versus-desktop presentation comparison. See
  [Density and context menus](DENSITY_AND_CONTEXT_MENUS.md).
- Frosted surfaces, scroll blur compatibility, haptics, organic chip ink,
  desktop context menu, floating navigation and gradient app bar samples are
  use cases in their families.

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

The animated showcases come from isolated capture scenes in
`preview/lib/component_gif_capture.dart`; `?capture=<scene>` selects one without
touching the Widgetbook catalog. Every scene uses real Morph widgets, English
labels and an explicit theme and seed. `navigation_rail_drawer` is kept only for
the rail/drawer example in [NAVIGATION_MORPH.md](NAVIGATION_MORPH.md), and
`dialogs` is kept for documentation; neither is shown in the README.

| Scene | Canvas | Duration | GIF fps | Content |
| --- | --- | --- | --- | --- |
| `buttons` | 640×360 | 7 s | 25 | Filled, tonal, elevated, outlined and text buttons pressed in turn; four `MorphShapeButton`s (rotation, press, morph, rotation + morph) |
| `dropdown` | 640×360 | 7 s | 25 | Single-select menu (open, hover, choose, close) and a multi-select menu with chips |
| `segmented` | 640×360 | 7 s | 25 | `MorphSegmentedToggle`, a multi-select `MorphSegmentedButton` and a connected `MorphButtonGroup`, each with a selection readout |
| `textfields` | 640×360 | 7 s | 25 | Filled email field with floating label and validation error, outlined username with counter, search field with clear button; real typing |
| `chips` | 640×360 | 7.5 s | 25 | Filter chips selected and deselected, input chips removed and re-added through an assist chip, a multi-select chip group |
| `sliders` | 640×360 | 7 s | 25 | Linear, wavy and wavy range sliders dragged with value bubbles and readouts, each returning to its start |
| `loading` | 640×360 | 7 s | 25 | Loading indicator (free and contained) and circular, circular wavy, linear and linear wavy progress driven by one value |
| `navigation` | 640×360 | 7 s | 25 | Expressive and morph navigation bars with tapped destinations, followed by page indicators |
| `variants` | 640×360 | 6 s | 50 | The five `MorphVariant` roles across filled, tonal, outlined, text and icon buttons |
| `density` | 640×360 | 6.6 s | 25 | One `MorphThemeData.density` switch (compact, standard, comfortable) on the same components |
| `context_menu` | 640×360 | 7.2 s | 50 | Desktop context menu: secondary click at the pointer, row hover, a submenu and an action |
| `async_button` | 640×340 | 10.6 s | 50 | Preserved/compact: idle → loading → success → loading → error |
| `skeleton` | 640×340 | 8.3 s | 50 | One tilted shimmer, then the real content |
| `tabs` | 640×380 | 7.5 s | 50 | Rounded underline and pill; selection change, reversed swipe, completed swipe |
| `fab_menu` | 640×400 | 7.7 s | 50 | FAB sizes, extended FABs, and the FAB menu opening and closing |
| `lists` | 640×340 | 5.8 s | 50 | List rows with spring swipe actions |
| `dialogs` | 640×360 | 6.5 s | 25 | Floating dialog entrance and exit |
| `navigation_rail_drawer` | 640×380 | 7.6 s | 50 | Rail and drawer selection with the organic stretch (renderer checked outside the image) |

All headers are compact (title and short description on one line) so the
components use the canvas; the watermark stays clear of every scene.

Scenes drive the real widgets: state changes through timers and, where press or
drag feedback matters (buttons, segmented, async button, tabs), real pointer
events dispatched to the gesture binding. Only `context_menu` draws a pointer arrow (deliberately, to show where the secondary click happens); no lab controls
or debug metrics appear, and no component is altered for the capture.

Each scene prints a start marker (`MORPH_GIF_SCENE_START`) once its first frame
is laid out. The capture tool starts recording 1.2 s later, after fonts and
shader programs had time to load. Frames come from the compositor screencast
(about 60 per second, each with its real timestamp) and are sampled on a uniform
1/fps grid: nothing is duplicated or interpolated to raise the rate, so playback
speed matches the real animation (a still screen repeats the last real frame).
GIF delays are centiseconds, so 50 fps (20 ms) is the fastest uniform rate. Sequences
return to their first state so the loop joins; continuous rotations and waves
(shape buttons, loading, wavy sliders) are the only elements with a small phase
offset at the seam. Scenes
also print the effective renderer (`MORPH_GIF_RENDERER`); the rail/drawer capture
fails unless the organic stretch really runs on the Shader.

From the repository root (requires Flutter, Node.js/npm, Python 3, curl and
FFmpeg; Playwright/Chromium install on first use and are never a consumer
dependency):

```bash
bash tool/generate_component_gifs.sh                 # every default scene, builds the Web preview
bash tool/generate_component_gifs.sh --only tabs     # one scene
python3 tool/check_gif_branding.py                   # assets, README and pub.dev gallery
```

`--skip-build` reuses a previous release build and must not be used after
editing a scene. `MORPH_GIF_FPS` (8–50) forces one frame rate for every scene; `MORPH_GIF_COLORS` and
`MORPH_GIF_DITHER` tune the palette.
Inspect the first frame, intermediate states, open/expanded states, the close
and the loop join before committing GIFs together with their README references.

pub.dev declares ten of the images (`pubspec.yaml` → `screenshots`); the README
shows a curated subset with absolute `raw.githubusercontent.com` URLs, checked by
`tool/check_gif_branding.py`. Screenshots are documentation only and are not
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

The browser entry point is `preview/lib/main.dart` (the Widgetbook catalog since
the v1 preview migration). For a physical iPhone or
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
