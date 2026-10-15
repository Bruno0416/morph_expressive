# Getting started

## Requirements

Flutter >=3.47.0, Dart ^3.13.0. Morph Expressive uses `material_ui` for Material widgets;
import it instead of `package:flutter/material.dart` in code using these APIs.

## Dependency

Add Morph Expressive from pub.dev:

```yaml
dependencies:
  morph_expressive: ^0.1.0
```

Then run `flutter pub get`.

## Theme integration

```dart
import 'package:material_ui/material_ui.dart';
import 'package:morph_expressive/morph_expressive.dart';

void main() {
  const seed = Color(0xFF6750A4);
  final light = MorphThemeData.light(seedColor: seed);

  runApp(MaterialApp(
    theme: light.toThemeData(),
    home: MorphTheme(
      data: light,
      child: Scaffold(
        body: Center(child: MorphButton(
          onPressed: () {},
          label: const Text('Continue'),
        )),
      ),
    ),
  ));
}
```

This is a **static light** example. To follow the device theme, pass the correct
active `MorphThemeData` or configure the adaptive `MorphTheme` scope; do not let
the Material and Morph theme modes diverge.

For `MaterialApp.router`, use its `builder` property in the same way; Morph Expressive
does not require replacing a router.

## Imports

`package:morph_expressive/morph_expressive.dart` exports all component families, foundations,
and `FluentIcons`. The icon glyphs are provided by `fluent_icons_kit`.

## Next steps

Read [theming](THEMING.md), [components](COMPONENTS.md), and the
[interactive preview guide](PREVIEW.md).
