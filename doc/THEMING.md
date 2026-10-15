# Themes and typography

## Dynamic seed schemes

`MorphThemeData.light(seedColor: ...)` and `.dark(seedColor: ...)` create
matching seed-derived schemes. Avoid hard-coded accent colors inside custom
components; use the colors from `MorphTheme.of(context).colorScheme`.

Keep the Material layer in sync using each theme's `toThemeData()`:

```dart
final seed = const Color(0xFF6750A4);
final light = MorphThemeData.light(seedColor: seed);
final dark = MorphThemeData.dark(seedColor: seed);
```

Choose the matching theme for the active brightness, or enable adaptive
handling with `MorphTheme` (`autoTheming`, `dynamicColoring`, and optionally a
`MorphThemeController`). Theme changes should affect the package and the host
Material surfaces together.

## Typography

Pass an optional Flutter `TextTheme` to either factory:

```dart
final theme = MorphThemeData.light(
  seedColor: const Color(0xFF6750A4),
  textTheme: ThemeData().textTheme,
);
```

Google Fonts is optional, not a package dependency.

## Component-specific styling

Components expose `Morph*Theme` settings for shapes, colors, sizes, and
motion. A local widget or theme override takes precedence over package
defaults. Prefer these settings over compensating offsets and hard-coded
colors in application wrappers.

The default Fluent icons come from `fluent_icons_kit`; swap icons at the
component API level when customization is needed.
