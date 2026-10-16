# Getting started

## Requirements

- Flutter >= 3.47.0 and Dart ^3.13.0.
- Morph Expressive uses `material_ui` for the host Material widgets in the
  examples; import it alongside `morph_expressive`.

## Install

```yaml
dependencies:
  morph_expressive: ^0.2.0
```

**Release status:** this is the intended dependency constraint **after 0.2.0
has been published on pub.dev**. Until that happens, the published release is
0.1.0 (`^0.1.0`), which does not expose the new 0.2.0 APIs. For pre-release
validation, use the repository source with a Git/path dependency.

Run `flutter pub get` after selecting the appropriate version.

## Theme integration

```dart
import 'package:material_ui/material_ui.dart';
import 'package:morph_expressive/morph_expressive.dart';

void main() {
  const seed = Color(0xFF6750A4);
  final theme = MorphThemeData.light(seedColor: seed);

  runApp(MaterialApp(
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
  ));
}
```

This example uses a fixed light theme. For device brightness changes, keep the
active Material theme and `MorphTheme` data synchronized; an adaptive
`MorphTheme` or a `MorphThemeController` can help manage this. The library is
compatible with `MaterialApp.router` via its `builder` property.

The package import exports component families, foundations, and `FluentIcons`.
The icon glyphs are provided by the `fluent_icons_kit` dependency.

## Configure 0.2.0 interactions

Globally disable Morph-managed haptics when your app or accessibility policy
requires it:

```dart
final quietTheme = MorphThemeData.light(
  seedColor: const Color(0xFF6750A4),
).copyWith(hapticsEnabled: false);
```

For an example of single/multiple chip selection and the filled floating label,
see [Components](COMPONENTS.md). For curves, spring timing and composable
animation tweens, see [Motion](MOTION.md).

## Next steps

Open [Theming](THEMING.md), [Components](COMPONENTS.md),
[Motion](MOTION.md), or run the [interactive preview](PREVIEW.md).
