# Theming

Morph Expressive has one theme object, `MorphThemeData`, that carries the color
scheme, typography, density, haptics, motion preferences, the frosted-surface
default and one theme per component family. This guide covers how the colors
are produced, how the theme reaches widgets, and how to customize it. Every
Dart snippet is compiled by `test/doc_examples_test.dart`.

## Seed colors and the algorithm

`MorphThemeData.light(seedColor: ...)` and `.dark(seedColor: ...)` build a
`MorphColorScheme` from one color:

```dart
MorphThemeData lightTheme() =>
    MorphThemeData.light(seedColor: const Color(0xFF6750A4));
MorphThemeData darkTheme() =>
    MorphThemeData.dark(seedColor: const Color(0xFF6750A4));
```

The algorithm is the Material 3 one, not a custom palette:

1. `MorphColorScheme.fromSeed` calls Flutter's `ColorScheme.fromSeed`, which
   uses Material Color Utilities. The default `dynamicSchemeVariant` is
   `DynamicSchemeVariant.tonalSpot` (the MCU `SchemeTonalSpot`) and the default
   `contrastLevel` is `0`.
2. The resulting `ColorScheme` is adapted to `MorphColorScheme.fromColorScheme`.
   The adapter keeps every Material role (`primary`, `surfaceContainerHigh`,
   `outlineVariant`, ...) and adds Morph semantic roles derived from them:
   `emphasis`, `info` (tertiary), `danger` (error), `success`, `warning`,
   `surfaceStrong` and `outlineStrong`.
3. The scheme remembers its seed, variant and contrast so the matching dark
   scheme can be regenerated faithfully (see below).

Without a seed, `MorphThemeData.light()` / `.dark()` use the Material baseline
purple `0xFF6750A4`.

### Variants and contrast

`dynamicSchemeVariant` accepts any `DynamicSchemeVariant` (`tonalSpot`,
`vibrant`, `expressive`, `fidelity`, `content`, `monochrome`, `neutral`,
`rainbow`, `fruitSalad`); it is re-exported by Morph. `contrastLevel` ranges
from -1 (reduced) to 1 (high); both only apply when a seed is given.

```dart
MorphThemeData vibrantHighContrast() {
  return MorphThemeData.light(
    seedColor: const Color(0xFF00796B),
    dynamicSchemeVariant: DynamicSchemeVariant.vibrant,
    contrastLevel: 0.5, // -1 (reduced) .. 0 (standard) .. 1 (high)
  );
}

MorphColorScheme schemeOnly() {
  return MorphColorScheme.fromSeed(
    const Color(0xFF00796B),
    brightness: Brightness.dark,
    dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
  );
}
```

## Getting the theme into the widget tree

| You use | Install with |
| --- | --- |
| A new app | `MorphMaterialApp(data: ...)` |
| An existing `MaterialApp` / `MaterialApp.router` | `theme: data.toThemeData()` plus `MorphTheme` in its `builder` |
| A subtree (a section, a dialog body) | `MorphTheme(data: ..., child: ...)` |

`MorphMaterialApp` creates the `MaterialApp`, converts the theme to Material
`ThemeData` for both light and dark, and wraps the `Navigator` in
`MorphTheme`. Its derived `ThemeData` objects are cached and rebuilt only when
the inputs (data, typography parameters) change. It also configures the system
UI overlay (transparent bars, icon brightness); `drawUnderSystemBars: true`
draws edge to edge. It accepts the usual `MaterialApp` parameters (routes,
locales, `navigatorKey`, `scrollBehavior`, `builder` via `appBuilder`, ...); it
takes a `home`, so for `MaterialApp.router` use your own `MaterialApp` as in
[Getting started](GETTING_STARTED.md).

### Light, dark and brightness control

`MorphMaterialApp.data` is the **light template**. Dark mode is derived from it:

- `MorphThemeData.deriveDarkTemplate()` regenerates the scheme with
  `MorphThemeData.dark(seedColor:, dynamicSchemeVariant:, contrastLevel:)` from
  the original seed and copies every other field (typography, density,
  haptics, component themes, glass). The derived dark scheme therefore equals
  `MorphThemeData.dark(seedColor: seed)`. A scheme without a remembered seed
  (for example from `MorphThemeData.fromMaterial`) is re-seeded from its
  `primary`.
- `autoTheming: true` follows the platform brightness.
- `initialTheme: Brightness.dark` starts in dark without following the platform.
- A `MorphThemeController` switches at runtime: `setBrightness`,
  `toggleBrightness`, `followSystem`.

```dart
Widget adaptiveApp(Widget home) {
  return MorphMaterialApp(
    data: MorphThemeData.light(seedColor: const Color(0xFF6750A4)),
    autoTheming: true, // follow the platform brightness
    home: home,
  );
}
```

```dart
class ThemeSwitcher extends StatefulWidget {
  const ThemeSwitcher({super.key});

  @override
  State<ThemeSwitcher> createState() => _ThemeSwitcherState();
}

class _ThemeSwitcherState extends State<ThemeSwitcher> {
  final MorphThemeController controller = MorphThemeController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MorphMaterialApp(
      data: MorphThemeData.light(seedColor: const Color(0xFF6750A4)),
      controller: controller,
      home: Scaffold(
        body: Center(
          child: MorphButton(
            onPressed: controller.toggleBrightness,
            child: const Text('Toggle light / dark'),
          ),
        ),
      ),
    );
  }
}
```

With `autoTheming: true`, `toggleBrightness(autoTheming: true)` inverts the
platform brightness instead of storing an override, and `followSystem()` clears
the override. Dark and light themes switch with the Material
`themeAnimationDuration`.

### Dynamic color

`dynamicColoring: true` makes the theme use the device palette when one exists:
the Android 12+ system palette or the desktop accent color (through the
`dynamic_color` plugin, read again when the app resumes). Morph generates a
`ColorScheme` from that seed, harmonizes it and applies it on top of the
template. When the platform offers nothing (iOS, web, most Linux setups) the
seed-based template is used, so always provide a seed you like.

```dart
Widget dynamicColorApp(Widget home) {
  return MorphMaterialApp(
    // Used when the device does not provide a dynamic palette.
    data: MorphThemeData.light(seedColor: const Color(0xFF6750A4)),
    autoTheming: true,
    dynamicColoring: true, // Android 12+ wallpaper colors, desktop accents
    home: home,
  );
}
```

`MorphDynamicColorHost` is the building block: it passes nullable light and dark
`ColorScheme`s to its builder if you want to wire the palette yourself.

## `MorphTheme`, `MorphThemeScope` and nesting

- `MorphTheme(data:, child:)` is a fixed theme for its subtree.
- `MorphTheme` with `initialTheme`, `autoTheming`, `dynamicColoring` or a
  `controller` inserts a `MorphThemeScope`, which resolves the template for the
  current brightness and dynamic palette. `MorphThemeScope` can also be used
  directly (`baseData`, `controller`).
- `MorphTheme.of(context)` returns the closest Morph theme; without one it
  adapts `Theme.of(context)` with `MorphThemeData.fromMaterial`, so Morph
  widgets still work under a plain `MaterialApp`. `maybeOf`, `brightnessOf`
  and `controllerOf` are also available.

Read tokens instead of hard-coding colors:

```dart
Widget themedBox(BuildContext context) {
  final MorphThemeData theme = MorphTheme.of(context);
  final MorphColorScheme colors = theme.colorScheme;
  return Container(
    padding: const EdgeInsets.all(16),
    color: colors.surfaceContainerHigh,
    child: Text(
      'Seed-derived surface',
      style: theme.textTheme.titleMedium?.copyWith(color: colors.onSurface),
    ),
  );
}
```

Themes nest: the nearest one wins and only its subtree is affected. Overlays
opened with the root navigator (dialogs, menus, sheets) use the theme above the
`Navigator`, which is why `MorphMaterialApp` installs it there.

```dart
Widget compactSection(BuildContext context, Widget child) {
  final MorphThemeData parent = MorphTheme.of(context);
  return MorphTheme(
    // A nested theme replaces the inherited one for its subtree only.
    data: parent.copyWith(density: .compact, hapticsEnabled: false),
    child: child,
  );
}

Widget brandedSection(Widget child) {
  return MorphTheme(
    data: MorphThemeData.light(seedColor: const Color(0xFFB3261E)),
    child: child,
  );
}
```

### Color roles for components

`MorphVariant` maps a role onto the scheme; `MorphVariantPalette` gives the
resolved colors when you build your own widgets:

```dart
MorphVariantPalette dangerPalette(BuildContext context) {
  final MorphColorScheme scheme = MorphTheme.of(context).colorScheme;
  return MorphVariantPalette.of(scheme, MorphVariant.danger);
  // palette.color / onColor, container / onContainer, accent, outline
}
```

See [Component API](API_V1.md) for the table of roles.

## Converting to and from Material

`MorphThemeData.toThemeData()` builds the Material `ThemeData` (color scheme,
text theme, icon themes, `VisualDensity`, platform, splash and highlight).
`MorphThemeData.fromMaterial(ThemeData, density:)` goes the other way; the
adaptation is cached per `ThemeData` instance:

```dart
MorphThemeData fromExistingTheme(ThemeData material) {
  return MorphThemeData.fromMaterial(material, density: .comfortable);
}
```

## Typography

Without a text theme, `MorphTypography.material3()` supplies the baseline and
emphasized type scales. Pass a Flutter `TextTheme` (for example from a font
package) to adopt your fonts:

```dart
MorphThemeData typographyTheme(ThemeData materialTheme) {
  return MorphThemeData.light(
    seedColor: const Color(0xFF6750A4),
    textTheme: materialTheme.textTheme,
  );
}
```

`MorphMaterialApp` also accepts `fontFamily`, `fontFamilyFallback`, `package`,
`fontVariations`, `typeScaleMode`, `typeface` and `variableFont`. Google Fonts
is not a dependency of this package. Fluent icons come from `fluent_icons_kit`
and are exported as `FluentIcons`.

## Component themes and overrides

`MorphThemeData` has one theme per family (`buttonTheme`, `cardTheme`,
`textFieldTheme`, `tabTheme`, `dialogTheme`, ... and `asyncButtonTheme`,
`skeletonTheme`). Each is immutable with `copyWith`. Precedence is always:

1. explicit widget arguments (`decoration`, colors, `glass`, `density`);
2. the widget's `variant` (a call-site choice beats per-type theme colors);
3. the local component theme or decoration scope;
4. the inherited `MorphThemeData` component theme;
5. the package defaults.

```dart
MorphThemeData customizedTheme() {
  final MorphThemeData base = MorphThemeData.light(
    seedColor: const Color(0xFF6750A4),
  );
  return base.copyWith(
    cardTheme: base.cardTheme.copyWith(radius: 20),
    buttonTheme: base.buttonTheme.copyWith(
      pressDuration: const Duration(milliseconds: 60),
    ),
    floatingSurfaceGlass: const MorphSurfaceGlass(
      blurX: 14,
      blurY: 14,
      tintOpacity: 0.7,
    ),
  );
}
```

Other theme-level settings: `density` ([Density](DENSITY_AND_CONTEXT_MENUS.md)),
`floatingSurfaceGlass` ([Frosted surfaces](FROSTED_SURFACES.md)),
`reduceMotion` and `keyboardFocusIndicators` ([Accessibility](ACCESSIBILITY.md)),
`focusRingTheme` (`MorphFocusRingTheme(color:, width:, gap:)`), `splashColor`,
`highlightColor`, `platform` and `visualDensity` (the Material pass-through).

## Haptics

`hapticsEnabled` (default `true`) is the global switch for Morph-managed
feedback and `hapticFeedback` (default `MorphHapticFeedback.light`) the default
intensity. A control that exposes `haptic` can use `inherit` (follow the theme),
`none` (silent) or an explicit `light` / `medium` / `heavy`, which only apply
while the global switch is on.

```dart
MorphThemeData hapticsTheme() {
  final MorphThemeData theme = MorphThemeData.light(
    seedColor: const Color(0xFF6750A4),
  );
  return theme.copyWith(
    hapticsEnabled: true,
    hapticFeedback: MorphHapticFeedback.medium,
  );
}

MorphThemeData quietTheme(MorphThemeData theme) =>
    theme.copyWith(hapticsEnabled: false);
```

Custom widgets should call `MorphHaptics.triggerFor(context, level)` or
`MorphHaptics.selectionFor(context)`. Sliders with `divisions` tick once per
step; continuous sliders are silent. Haptics need a physical device: browsers
usually have no feedback hardware. Native platform feedback outside Morph's
controls is not governed by this switch.
