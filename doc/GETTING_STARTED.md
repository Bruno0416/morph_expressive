# Getting started

This guide takes you from an empty Flutter app to a themed screen that uses the
v1 API. Every Dart snippet here is compiled by the package's own tests
(`test/doc_examples_test.dart`).

## Requirements

- Flutter >= 3.47.0 and Dart ^3.13.0.
- Morph Expressive builds on `material_ui` (the Material widgets) and exports
  the Fluent icon set as `FluentIcons`. Add `material_ui` to the app that uses
  it and import it with an explicit `show` list.

## Install

```bash
flutter pub add morph_expressive material_ui
```

or edit `pubspec.yaml` and run `flutter pub get`:

```yaml
dependencies:
  morph_expressive: ^1.0.0
  material_ui: ^1.6.0
```

Version 1.0.0 is prepared in this repository and its publication is pending.
Until it appears on pub.dev, depend on the published `^0.8.0` (see
[Upgrading from 0.7.x](UPGRADE_0_8_0.md) and
[Upgrading to the v1 API](UPGRADE_1_0_0.md)) or on a Git/path checkout:

```yaml
dependencies:
  morph_expressive:
    git:
      url: https://github.com/Bruno0416/morph_expressive.git
```

One import exposes the components, the foundations (theme, color, motion,
surfaces) and `FluentIcons`:

```dart
import 'package:morph_expressive/morph_expressive.dart';
```

## Option 1 - `MorphMaterialApp` (recommended)

`MorphMaterialApp` creates the `MaterialApp`, derives the Material `ThemeData`
for light and dark from one seed, and installs `MorphTheme` below the
`Navigator`, so dialogs, menus and sheets see the same theme.

```dart
import 'package:material_ui/material_ui.dart'
    show
        BuildContext,
        Center,
        Color,
        Column,
        MainAxisSize,
        Scaffold,
        StatelessWidget,
        Text,
        Widget,
        runApp;
import 'package:morph_expressive/morph_expressive.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MorphMaterialApp(
      // One seed color generates the whole palette. Dark mode is derived from
      // the same seed and follows the platform brightness.
      data: MorphThemeData.light(seedColor: const Color(0xFF6750A4)),
      autoTheming: true,
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 16,
            children: [
              MorphButton(onPressed: () {}, child: const Text('Continue')),
              MorphButton.tonal(
                variant: .tertiary,
                onPressed: () {},
                child: const Text('Explore'),
              ),
              MorphButton.outlined(
                variant: .danger,
                surface: .frosted,
                onPressed: () {},
                child: const Text('Delete'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

`autoTheming: true` follows the platform brightness. To switch brightness from
the app, pass a `MorphThemeController` (see [Theming](THEMING.md)). Without
`autoTheming` or a controller the app stays in the brightness of `data`.

## Option 2 - keep your `MaterialApp`

If the app already owns a `MaterialApp` (or `MaterialApp.router`), convert the
Morph theme with `toThemeData()` and install `MorphTheme` in the `builder`:

```dart
import 'package:material_ui/material_ui.dart'
    show
        Brightness,
        BuildContext,
        Center,
        Color,
        MaterialApp,
        Scaffold,
        SizedBox,
        StatelessWidget,
        Text,
        Theme,
        ThemeMode,
        Widget,
        runApp;
import 'package:morph_expressive/morph_expressive.dart';

void main() => runApp(const ExistingApp());

class ExistingApp extends StatelessWidget {
  const ExistingApp({super.key});

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFF6750A4);
    final light = MorphThemeData.light(seedColor: seed);
    final dark = MorphThemeData.dark(seedColor: seed);

    return MaterialApp(
      theme: light.toThemeData(),
      darkTheme: dark.toThemeData(),
      themeMode: ThemeMode.system,
      // The builder wraps the Navigator, so dialogs, menus and sheets also see
      // the Morph theme. Pick the data that matches the Material brightness.
      builder: (context, child) => MorphTheme(
        data: Theme.of(context).brightness == Brightness.dark ? dark : light,
        child: child ?? const SizedBox.shrink(),
      ),
      home: Scaffold(
        body: Center(
          child: MorphButton(onPressed: () {}, child: const Text('Continue')),
        ),
      ),
    );
  }
}
```

`MorphTheme(data: ...)` is a plain, fixed theme. Use `MorphMaterialApp`, or
`MorphTheme` with `autoTheming`, `dynamicColoring` or a controller, when Morph
itself should react to brightness changes (see [Theming](THEMING.md)).

## The three axes of the API

| Axis | Chosen with | Examples |
| --- | --- | --- |
| Visual type | Named constructor | `MorphButton.outlined`, `MorphCard.filled`, `MorphIconButton.tonal` |
| Color role | `variant:` | `.primary`, `.secondary`, `.tertiary`, `.muted`, `.danger` |
| Surface finish | `surface:` | `.solid` (default), `.frosted` |

`variant` and `surface` use Dart's enum shorthand (`.danger`); the long form
`MorphVariant.danger` is equivalent. Omitting `variant` keeps each type's
canonical Material 3 colors. See [Component API](API_V1.md).

## First widgets

```dart
Widget firstWidgets({
  required VoidCallback onContinue,
  required TextEditingController controller,
}) {
  return Column(
    spacing: 12,
    children: [
      MorphButton(onPressed: onContinue, child: const Text('Continue')),
      MorphIconButton.tonal(
        onPressed: () {},
        tooltip: 'Add',
        icon: Icon(FluentIcons.line.add),
      ),
      MorphTextField.outlined(controller: controller, label: 'Name'),
      MorphChip.filter(label: 'Open now', selected: true, onPressed: () {}),
      const MorphCard.filled(
        headline: 'Welcome',
        supportingText: 'A filled card in the primary container color.',
      ),
    ],
  );
}
```

`MorphButton` takes either a `child` or an `icon` and `label`; the callback is
`onPressed`. The component catalog with every family and constructor is in
[Components](COMPONENTS.md).

## Density

Density is a theme-level setting that changes layout metrics (heights, padding,
gaps), never fonts or colors:

```dart
MorphThemeData compactTheme(Color seed) {
  return MorphThemeData.light(seedColor: seed, density: .compact);
}
```

Compact reduces the visible box but keeps the 48 dp tap target. See
[Density and context menus](DENSITY_AND_CONTEXT_MENUS.md).

## Where to go next

- [Theming](THEMING.md): seeds, light/dark, contrast, dynamic color, nested
  themes and component overrides.
- [Components](COMPONENTS.md) and [Component API](API_V1.md).
- [Frosted surfaces](FROSTED_SURFACES.md) and [MorphScrollBehavior](MORPH_SCROLL.md).
- [Accessibility](ACCESSIBILITY.md) and [Motion](MOTION.md).
- [Widgetbook preview](PREVIEW.md): every exported widget with live knobs.
- [`example/`](../example/README.md): runnable apps.

The package never requires native setup: haptics use Flutter's built-in
services and dynamic color uses the `dynamic_color` plugin only when you enable
`dynamicColoring`.
