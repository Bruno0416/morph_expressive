# Getting started

## Requirements

- Flutter >= 3.47.0 and Dart ^3.13.0.
- Morph Expressive uses `material_ui` for the host Material widgets in the
  examples; import it alongside `morph_expressive`.

## Install

```yaml
dependencies:
  morph_expressive: ^0.4.0
```

**Release status:** `^0.4.0` resolves after the 0.4.0 release is published
on pub.dev. Before then, choose the latest available published version or a
Git/path dependency for testing. Check the
[version history](https://pub.dev/packages/morph_expressive/versions).

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

## Configure theme-level interactions (available since 0.2.0)

Globally disable Morph-managed haptics when your app or accessibility policy
requires it:

```dart
final quietTheme = MorphThemeData.light(
  seedColor: const Color(0xFF6750A4),
).copyWith(hapticsEnabled: false);
```

The 0.4.0 release uses Flutter's built-in haptics; no external haptics
package or manual native framework linking is needed. For Light / Medium /
Heavy and per-widget overrides, see [Theming](THEMING.md).

For a runnable overview of selection, validation, swipe actions, and
dialogs, see [`example/main.dart`](../example/main.dart) and the
[example guide](../example/README.md). For deeper options, see
[Components](COMPONENTS.md). For curves, spring timing and composable
animation tweens, see [Motion](MOTION.md).

## Next steps

Open [Theming](THEMING.md), [Components](COMPONENTS.md),
[Motion](MOTION.md), or run the [interactive preview](PREVIEW.md).
