# Morph Expressive

Morph Expressive is a Flutter design system inspired by Material 3 Expressive. It
builds on its ideas with a focus on symmetry, rounded shapes, balanced colors,
and smooth animations.

The goal is to make components look and feel consistent while exploring new
styles and interactions beyond Material 3 Expressive.

This README documents **0.6.0**. Check the
[pub.dev versions](https://pub.dev/packages/morph_expressive/versions) for the
latest published release. Morph Expressive is still in the 0.x series, so
public APIs and defaults may evolve between minor versions.

Morph Expressive is an independent fork of
[Material 3 Expressive](https://github.com/paadevelopments/material_3_expressive)
by Paa Developments. The original implementations are modified directly instead
of wrapped. See [NOTICE](NOTICE) and [LICENSE](LICENSE) for attribution.

## Requirements

- Flutter >= 3.47.0, Dart ^3.13.0.
- This release uses the `material_ui` package for Material widgets.
- No specific routing or state-management package is required.

## Installation

```yaml
dependencies:
  morph_expressive: ^0.6.0
```

Run `flutter pub get` after changing the constraint. To test a source checkout
before this version is available on pub.dev, use a Git/path dependency.

## Quick start

```dart
import 'package:material_ui/material_ui.dart'
    show Center, Color, MaterialApp, Scaffold, Text, runApp;
import 'package:morph_expressive/morph_expressive.dart'
    show MorphButton, MorphTheme, MorphThemeData;

void main() {
  const seed = Color(0xFF6750A4);
  final theme = MorphThemeData.light(seedColor: seed);

  runApp(
    MaterialApp(
      theme: theme.toThemeData(),
      home: MorphTheme(
        data: theme,
        child: Scaffold(
          body: Center(
            child: MorphButton(
              onPressed: () {},
              label: const Text('Continue'),
            ),
          ),
        ),
      ),
    ),
  );
}
```

This example uses a fixed light theme. For dynamic brightness, keep `MorphTheme`
and the host Material theme synchronized. `MaterialApp.router` is supported.

## New in 0.6.0

**Upgrading from 0.5.0:** `MorphNavigationBarDestination.icon` and
`selectedIcon` now accept `IconData`, not `Widget`. For custom icons use
`iconWidget` / `selectedIconWidget`. The two named bar constructors also
exchange their former visual mapping: `.expressive()` is the elastic icon
pill; `.morph()` is the sliding upper dash.

- **Navigation controls:** `.expressive()` defaults to a compact 64dp band,
  while `.morph()` uses 76dp to keep its top dash clear of the active icon.
  `iconSize` and `unselectedIconScale` customize glyph emphasis, and
  `distributeWideDestinations: true` evenly spaces destinations in wide mode.
  The unnamed standard bar retains its existing behavior.
- **Frosted AppBar:** `MorphAppBar.frosted()` uses `MorphAppBarGlass` for
  progressive, clipped blur and a surface tint growing from 0% at the bottom
  to 90% at the top, with a linear lower half and exponential upper half.
- **Composition:** `MorphNavigationBarHost` accepts *all three* bottom bar
  variants, whether glass is enabled or not. It supports floating placement,
  hide-on-scroll, back-to-top and optional pull-to-refresh. Without `onRefresh`
  no indicator is created; the refresh offset adapts automatically to a
  frosted AppBar with `extendBodyBehindAppBar: true`.
- **Page indicators and demos:** interactive dot spacing now matches the
  supplied `spacing`; the mobile preview exercises both frosted navigation
  surfaces and refresh. The Web gallery excludes its two costly live-blur
  scenes, while keeping the widgets available to consumers.

A complete navigation composition can use either `MorphNavigationBar.morph()`,
`.expressive()`, or the unnamed standard bar. In a `StatefulWidget`'s `build`
method, with a `selectedIndex` state field and a `refreshData` async method:

```dart
Scaffold(
  extendBodyBehindAppBar: true,
  appBar: MorphAppBar.frosted(titleText: 'Explore'),
  body: MorphNavigationBarHost(
    onRefresh: refreshData, // Omit to disable pull-to-refresh entirely.
    bar: MorphNavigationBar.morph(
      floating: true,
      iconSize: 32,
      unselectedIconScale: 0.9,
      selectedIndex: selectedIndex,
      onDestinationSelected: (index) => setState(() => selectedIndex = index),
      destinations: const [
        MorphNavigationBarDestination(icon: MorphIcons.home, label: 'Home'),
        MorphNavigationBarDestination(icon: MorphIcons.search, label: 'Search'),
      ],
    ),
    body: (context, controller, contentPadding) => ListView.builder(
      controller: controller,
      padding: EdgeInsets.only(
        top: MediaQuery.paddingOf(context).top + 64,
        bottom: contentPadding.bottom,
      ),
      itemCount: 40,
      itemBuilder: (context, index) => ListTile(title: Text('Item $index')),
    ),
  ),
)
```

The upper list clearance above is illustrative for the small AppBar: adapt it
to the actual AppBar height. The refresh indicator's clearance is managed by
the host for frosted AppBars that extend behind their content. Full options
and migration details are in the [navigation and glass API guide](doc/NAVIGATION_MORPH.md)
and [0.6.0 changelog](CHANGELOG.md).

## New in 0.5.0

- Added elastic navigation selection for bar, rail and drawer, a floating
  navigation host and optional interactive page indicators.
- Added configurable selection timing and scroll-aware frosted navigation
  rendering, improved reduced-motion handling, and filled refresh visuals.
- Added navigation capture scenes alongside the original Material showcase.

## Fixed in 0.4.1

- **Dependency compatibility:** explicit imports prevent collisions with
  Material UI 1.8.0's new geometry exports while preserving Morph's existing
  `material_new_shapes` polygon API and the `material_ui: ^1.6.0` constraint.
- **Regression prevention:** import-policy checks, public geometry tests and
  CI exercise fresh latest/lowest dependency resolutions. Each lane passes
  analysis, 759 library tests, 31 preview tests and a Web release build.
- **Platform metadata:** the manifest explicitly declares the six intended
  Flutter targets. See the [compatibility report](doc/PUB_DEV_COMPATIBILITY.md)
  for native-build limits and consumer import guidance.

## New in 0.4.0

- **Text-field validation on focus loss:** `MorphTextField.onUnfocus`
  provides the current value when focus leaves a field, allowing custom
  validation through `errorText`. Inline expression-based errors still work.
- **Theme-aware haptics:** Light, Medium, Heavy and Off are applied consistently
  to Morph-managed interactions, including selection, buttons, list actions,
  navigation, sheet gestures, refresh and discrete sliders. No native haptics
  plugin, custom FFI binary, or manual iOS Swift package installation is needed.
- **Expressive refresh:** configurable pull distance via
  `contentDragOffset` and `indicatorPadding`; a determinate reveal ring,
  an indeterminate refreshing ring, a completion spin and a distinct completion
  impact. The expressive/contained spinner defaults to a filled surface with
  no elevation; pass `elevation` explicitly to add a shadow. Existing
  background/foreground theme colors are respected.
- **List swipe choreography:** spring-animated reveal and close, a trailing
  three-dot affordance where enabled, and simultaneous closing/opening when
  moving between rows. Default feedback occurs at meaningful thresholds, not
  on every drag increment.
- **Buttons and navigation:** smoother, interruptible radius transitions,
  geometrically centered AppBar titles, adjusted drawer destination spacing,
  and theme-aware haptics for automatic back navigation and sheets.
- **Snackbar:** optional horizontal swipe-to-dismiss, animated release and a
  correctly styled close action.
- **Circular indicators:** size-aware stroke rendering for compact and large
  circular/wavy variants. The iPhone touch lab now compares 16/24/48/64 dp
  standard and wavy indicators, sliders with/without divisions, and refresh.

See the [changelog](CHANGELOG.md) for the release history and the
[release checklist](doc/RELEASE.md) for publication verification.

## What was fixed in 0.3.1

- **Wavy finishing:** Wavy slider and range slider tracks, along with linear
  and circular progress indicators, now fade their curvature smoothly from
  90% to 98% (and fade in from 10% to 15%) without a sudden shape jump.
- **Aligned date-range inputs:** Start and End filled fields reserve the same
  outside-label space, so focusing, entering dates or showing an error never
  staggers their painted surfaces. Other filled fields keep their default layout.
- **Date picker input:** Single-date and range entry dialogs accommodate
  the filled field's floating label and validation messages, scrolling
  safely on short screens and when the keyboard is visible.

## Added in 0.3.0

- **Swipeable lists:** `MorphListItemSwipe` reveals actions with Morph pill
  buttons, springs, configurable callbacks, and safe async dismissal without
  adding `flutter_slidable`. The optional trailing overflow affordance was
  restored in 0.4.0; see the current component guide.
- **Validation icons:** `MorphTextField` now shows no error glyph by default.
  Opt in with `errorIcon` and position it with
  `MorphTextFieldErrorIconPosition.prefix` or `.suffix`, in both filled and
  outlined fields.
- **Carousel stability:** focus/hover state notifications no longer attempt
  `setState()` during Flutter's build phase.
- **Examples and previews:** a richer interactive example plus GIFs for
  swipeable lists and animated floating dialogs.

### Also available since 0.2.0

- Multi-selection `MorphChipToggle<T>` with animated selection transitions.
- Filled `MorphTextField` with a floating exterior label.
- Theme-level haptic feedback configuration and reusable motion tweens.
- Morph navigation, native floating/glass bars and onboarding page indicators; see
  [navigation guide](doc/NAVIGATION_MORPH.md).
- System-aware reduced motion, with global and local accessibility settings; see
  [reduced motion](doc/REDUCED_MOTION_ACCESSIBILITY.md).
- Tabs with opt-in focus-driven auto-scrolling.

Practical examples and customization are in the
[components](doc/COMPONENTS.md), [theming](doc/THEMING.md) and
[motion](doc/MOTION.md) guides.

## Animated component previews

The examples below are captured directly from Morph Expressive running in Flutter Web
(dark theme, no mouse cursor). Each GIF is reproducible by the script in `tool/`.

| Buttons | Dropdown |
|:---:|:---:|
| <img src="https://raw.githubusercontent.com/Bruno0416/morph_expressive/main/doc/assets/gifs/buttons.gif" alt="Animated buttons" width="380"> | <img src="https://raw.githubusercontent.com/Bruno0416/morph_expressive/main/doc/assets/gifs/dropdown.gif" alt="Dropdown opening and closing" width="380"> |
| **Segmented toggle** | **Text fields** |
| <img src="https://raw.githubusercontent.com/Bruno0416/morph_expressive/main/doc/assets/gifs/segmented.gif" alt="Elastic segmented toggle" width="380"> | <img src="https://raw.githubusercontent.com/Bruno0416/morph_expressive/main/doc/assets/gifs/textfields.gif" alt="Search, outlined and filled text fields, including the floating label" width="380"> |
| **Chips** | **Sliders** |
| <img src="https://raw.githubusercontent.com/Bruno0416/morph_expressive/main/doc/assets/gifs/chips.gif" alt="Material 3 Expressive chips and Morph single/multiple selection" width="380"> | <img src="https://raw.githubusercontent.com/Bruno0416/morph_expressive/main/doc/assets/gifs/sliders.gif" alt="Linear and wavy sliders" width="380"> |
| **Loading indicators** | **Navigation** |
| <img src="https://raw.githubusercontent.com/Bruno0416/morph_expressive/main/doc/assets/gifs/loading.gif" alt="Animated progress and loading indicators" width="380"> | <img src="https://raw.githubusercontent.com/Bruno0416/morph_expressive/main/doc/assets/gifs/navigation.gif" alt="Animated navigation bars" width="380"> |
| **Morph navigation + page indicator** | **Morph rail + drawer** |
| <img src="https://raw.githubusercontent.com/Bruno0416/morph_expressive/main/doc/assets/gifs/navigation_morph.gif" alt="Expressive pill and Morph top-dash navigation bars with two page indicators" width="380"> | <img src="https://raw.githubusercontent.com/Bruno0416/morph_expressive/main/doc/assets/gifs/navigation_rail_drawer.gif" alt="Morph rail and drawer elastic selection" width="380"> |
| **List items and swipe actions** | **Floating dialogs** |
| <img src="https://raw.githubusercontent.com/Bruno0416/morph_expressive/main/doc/assets/gifs/lists.gif" alt="MorphList rows with spring swipe actions" width="380"> | <img src="https://raw.githubusercontent.com/Bruno0416/morph_expressive/main/doc/assets/gifs/dialogs.gif" alt="Expressive floating dialog transitions" width="380"> |

To create or refresh the GIFs from the repository root:

```bash
bash tool/generate_component_gifs.sh
```

This requires Flutter, Node.js/npm, Python 3 and FFmpeg. On first run the
script installs Playwright and Chromium locally, builds the Flutter Web preview
in release mode, captures twelve scenes at 15 FPS, and writes
`doc/assets/gifs/*.gif`. Most scenes are 640 × 360 / 4.8 s. `lists` uses
640 × 360 / 5.8 s to show reveal and close motion; `dialogs` uses
640 × 420 / 6.5 s for modal transitions. To preserve
all variants, **chips** and **textfields** use 640 × 480 and longer sequences
(8.7 / 8.2 s): chips show standard M3E filter/input/assist, expressive
single selection, and expressive multi-selection (circular first/last and
connected morphs); textfields show search, outlined, and the filled floating
label through focus, simulated typing and blur. The unchanged scenes rotate
purple, teal and blue seed colors; chips uses teal and textfields uses purple
for stable color references. Capture tools do not become runtime dependencies.
The navigation captures use 640 × 520 / 7.2 s for Expressive pill,
Morph top-dash and page indicators, and 640 × 500 / 6.8 s for rail and
drawer. **Regenerate `navigation_morph.gif` for 0.6.0**, because its scene and
bar geometry changed after 0.5.0; `navigation_rail_drawer.gif` can be
retained if its scene remains unchanged. Use
`bash tool/generate_component_gifs.sh --only navigation_morph` before publishing
and commit the updated GIF with its capture source.
Review generated GIFs before committing them. To regenerate one scene, use
`bash tool/generate_component_gifs.sh --only dropdown`.
For the expanded scenes, generate them separately with
`--only chips`, `--only textfields`, `--only lists`, or `--only dialogs`. These commands
replace only the corresponding GIF files, not the other scenes; preview the
results before committing. `--skip-build` reuses an already compiled web build
and should not be used after editing the capture scenes.

## Documentation

- [Getting started](https://github.com/Bruno0416/morph_expressive/blob/main/doc/GETTING_STARTED.md)
- [Theming and typography](https://github.com/Bruno0416/morph_expressive/blob/main/doc/THEMING.md)
- [Components](https://github.com/Bruno0416/morph_expressive/blob/main/doc/COMPONENTS.md)
- [Motion](https://github.com/Bruno0416/morph_expressive/blob/main/doc/MOTION.md)
- [Preview](https://github.com/Bruno0416/morph_expressive/blob/main/doc/PREVIEW.md)
- [Release checklist](https://github.com/Bruno0416/morph_expressive/blob/main/doc/RELEASE.md)

For a practical interactive example of buttons, chips, text fields,
list swipe actions, and dialogs, see
[`example/main.dart`](https://github.com/Bruno0416/morph_expressive/blob/main/example/main.dart)
and its [usage guide](example/README.md).

## Development

```bash
flutter pub get
bash tool/check.sh
cd preview
flutter run -d web-server --web-port 8080
```

The preview is a separate Flutter application with a responsive, continuous-
scroll component gallery organized by families. GIF capture scenes are available
with `?capture=buttons`, `?capture=dropdown`, `?capture=segmented`,
`?capture=textfields`, `?capture=chips`, `?capture=sliders`, `?capture=loading`,
`?capture=navigation`, `?capture=navigation_morph`,
`?capture=navigation_rail_drawer`, `?capture=lists` or `?capture=dialogs`.

## Credits

- Original implementation: Paa Developments, Material 3 Expressive (MIT).
- Icon assets: Fluent Icons Kit, distributed as a separate dependency.
- Third-party attribution: [NOTICE](NOTICE) and existing source headers.

Morph Expressive is not affiliated with Google or the upstream maintainers.

### Navigation timing and frosted performance

A frosted bar uses a **real**, tightly clipped `BackdropFilter` drawn as a
background sibling of its animated content. The blur remains mounted (but
`enabled: false`) during the host's own content scroll and visibility
transitions; scrolling a surrounding gallery does not disable the nested
bar's frosted effect. Destination animation no longer repaints through the
filter's child. Glass has no default Material shadow, though explicit
`elevation` is honored.

When a floating bar reappears on Android/iOS, the blur resumes during its
upward spring at `blurRevealProgress: 0.35` (the fraction of the reveal
completed). Set it lower for an earlier return or higher for a more
conservative transition in `MorphNavigationGlass`. Flutter Web still waits
until its own content scrolling and visibility motion finish to avoid
expensive background resampling.

Flutter Web is especially sensitive to large blur radii. The isolated floating-navigation sample uses a real 5px web blur
(10px on native), but the continuous Web gallery deliberately omits the
expensive live glass scenes. Use the native preview for the combined
AppBar/nav-bar scenario. Adjust `blurX`/`blurY` per app; `webBackdropBlur: false` remains an
explicit last-resort option for devices that cannot sustain real blur.

Use `selectionDelay: Duration.zero` (or a custom `Duration`) on `.morph`
bar, rail or drawer, and on `MorphPageIndicator`. Default selection delays
are 60ms for horizontal and 20ms for vertical motion.

`MorphNavigationGlass()` uses an 8px backdrop blur and disables live blur
during body scrolling when used inside `MorphNavigationBarHost`. For a
stronger treatment set `blurX`/`blurY`; use `blurX: 0, blurY: 0` for an
inexpensive tint-only translucent surface. `blurDuringScroll: true` keeps
continuous blur at additional GPU cost.
