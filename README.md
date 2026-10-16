# Morph Expressive

Morph Expressive is a Flutter design system inspired by Material 3 Expressive. It
builds on its ideas with a focus on symmetry, rounded shapes, balanced colors,
and smooth animations.

The goal is to make components look and feel consistent while exploring new
styles and interactions beyond Material 3 Expressive.

This README describes **version 0.3.1**. Version **0.3.0** is already
published; check the [pub.dev versions](https://pub.dev/packages/morph_expressive/versions)
for the latest available release. Morph Expressive is still in the 0.x series,
so APIs may evolve between releases.

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
  morph_expressive: ^0.3.1
```

`^0.3.1` becomes available only after the new version is published on
pub.dev. Until then, use `^0.3.0` for the published version or a Git/path
dependency to test the unreleased source. Run `flutter pub get` after updating.

## Quick start

```dart
import 'package:material_ui/material_ui.dart';
import 'package:morph_expressive/morph_expressive.dart';

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

## What's fixed in 0.3.1

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
  adding `flutter_slidable`. No extra overflow icon is inserted on the row.
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
| **List items and swipe actions** | **Floating dialogs** |
| <img src="https://raw.githubusercontent.com/Bruno0416/morph_expressive/main/doc/assets/gifs/lists.gif" alt="MorphList rows with spring swipe actions" width="380"> | <img src="https://raw.githubusercontent.com/Bruno0416/morph_expressive/main/doc/assets/gifs/dialogs.gif" alt="Expressive floating dialog transitions" width="380"> |

To create or refresh the GIFs from the repository root:

```bash
bash tool/generate_component_gifs.sh
```

This requires Flutter, Node.js/npm, Python 3 and FFmpeg. On first run the
script installs Playwright and Chromium locally, builds the Flutter Web preview
in release mode, captures ten scenes at 15 FPS, and writes
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
`?capture=navigation`, `?capture=lists` or `?capture=dialogs`.

## Credits

- Original implementation: Paa Developments, Material 3 Expressive (MIT).
- Icon assets: Fluent Icons Kit, distributed as a separate dependency.
- Third-party attribution: [NOTICE](NOTICE) and existing source headers.

Morph Expressive is not affiliated with Google or the upstream maintainers.
