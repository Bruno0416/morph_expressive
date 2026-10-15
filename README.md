# Morph Expressive

Morph Expressive is a Flutter design system inspired by Material 3 Expressive. It
builds on its ideas with a focus on symmetry, rounded shapes, balanced colors,
and smooth animations.

The goal is to make components look and feel consistent while exploring new
styles and interactions beyond Material 3 Expressive.

**Version 0.1.0** is the first public release. The component APIs may evolve
while Morph Expressive is in the 0.x series.

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
  morph_expressive: ^0.1.0
```

Then run `flutter pub get`, or add the dependency with `flutter pub add morph_expressive`.

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

## Animated component previews

The examples below are captured directly from Morph Expressive running in Flutter Web
(dark theme, no mouse cursor). Each GIF is reproducible by the script in `tool/`.

| Buttons | Dropdown |
|:---:|:---:|
| <img src="https://raw.githubusercontent.com/Bruno0416/morph_expressive/main/doc/assets/gifs/buttons.gif" alt="Animated buttons" width="380"> | <img src="https://raw.githubusercontent.com/Bruno0416/morph_expressive/main/doc/assets/gifs/dropdown.gif" alt="Dropdown opening and closing" width="380"> |
| **Segmented toggle** | **Text fields** |
| <img src="https://raw.githubusercontent.com/Bruno0416/morph_expressive/main/doc/assets/gifs/segmented.gif" alt="Elastic segmented toggle" width="380"> | <img src="https://raw.githubusercontent.com/Bruno0416/morph_expressive/main/doc/assets/gifs/textfields.gif" alt="Animated text-field focus" width="380"> |
| **Chips** | **Sliders** |
| <img src="https://raw.githubusercontent.com/Bruno0416/morph_expressive/main/doc/assets/gifs/chips.gif" alt="Animated chips" width="380"> | <img src="https://raw.githubusercontent.com/Bruno0416/morph_expressive/main/doc/assets/gifs/sliders.gif" alt="Linear and wavy sliders" width="380"> |
| **Loading indicators** | **Navigation** |
| <img src="https://raw.githubusercontent.com/Bruno0416/morph_expressive/main/doc/assets/gifs/loading.gif" alt="Animated progress and loading indicators" width="380"> | <img src="https://raw.githubusercontent.com/Bruno0416/morph_expressive/main/doc/assets/gifs/navigation.gif" alt="Animated navigation bars" width="380"> |

To create or refresh the GIFs from the repository root:

```bash
bash tool/generate_component_gifs.sh
```

This requires Flutter, Node.js/npm, Python 3 and FFmpeg. On first run the
script installs Playwright and Chromium locally, builds the Flutter Web preview
in release mode, captures eight scenes at 640 × 360 / 15 FPS, and writes
`doc/assets/gifs/*.gif`. The captures cycle through purple, teal, and blue
seed colors. The capture tools do not become runtime dependencies.
Review generated GIFs before committing them. To regenerate one scene, use
`bash tool/generate_component_gifs.sh --only dropdown`.

## Documentation

- [Getting started](https://github.com/Bruno0416/morph_expressive/blob/main/doc/GETTING_STARTED.md)
- [Theming and typography](https://github.com/Bruno0416/morph_expressive/blob/main/doc/THEMING.md)
- [Components](https://github.com/Bruno0416/morph_expressive/blob/main/doc/COMPONENTS.md)
- [Motion](https://github.com/Bruno0416/morph_expressive/blob/main/doc/MOTION.md)
- [Preview](https://github.com/Bruno0416/morph_expressive/blob/main/doc/PREVIEW.md)
- [Release checklist](https://github.com/Bruno0416/morph_expressive/blob/main/doc/RELEASE.md)

For a minimal runnable example, see
[`example/main.dart`](https://github.com/Bruno0416/morph_expressive/blob/main/example/main.dart).

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
`?capture=textfields`, `?capture=chips`, `?capture=sliders`, `?capture=loading`
or `?capture=navigation`.

## Credits

- Original implementation: Paa Developments, Material 3 Expressive (MIT).
- Icon assets: Fluent Icons Kit, distributed as a separate dependency.
- Third-party attribution: [NOTICE](NOTICE) and existing source headers.

Morph Expressive is not affiliated with Google or the upstream maintainers.
