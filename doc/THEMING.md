# Themes and typography

## Light, dark and dynamic colors

`MorphThemeData.light(seedColor: ...)` and `.dark(seedColor: ...)` create
seed-derived schemes. Use `MorphTheme.of(context).colorScheme` instead of
hard-coded accents in application components.

```dart
final seed = const Color(0xFF6750A4);
final light = MorphThemeData.light(seedColor: seed);
final dark = MorphThemeData.dark(seedColor: seed);
```

Use the matching `toThemeData()` for the host `MaterialApp`. For device-driven
brightness, configure adaptive handling with `MorphTheme` (`autoTheming`,
`dynamicColoring` and optionally a `MorphThemeController`). Keep the host
Material colors and Morph surface colors synchronized.

## Typography

An optional Flutter `TextTheme` can be supplied to either theme factory:

```dart
final theme = MorphThemeData.light(
  seedColor: const Color(0xFF6750A4),
  textTheme: ThemeData().textTheme,
);
```

Google Fonts is optional and is not a runtime dependency of this package.
The default Fluent icons use `fluent_icons_kit`; substitute component icons
via their documented APIs.

## Haptics (updated in 0.4.0)

Configure the feedback intensity and global opt-out at the nearest Morph theme:

```dart
final theme = MorphThemeData.light(
  seedColor: const Color(0xFF6750A4),
).copyWith(
  hapticsEnabled: true,
  hapticFeedback: MorphHapticFeedback.medium,
);

final quietTheme = theme.copyWith(hapticsEnabled: false);
```

The defaults are `hapticsEnabled: true` and
`hapticFeedback: MorphHapticFeedback.light`. A control exposing a `haptic`
property can use `MorphHapticFeedback.inherit` to follow its theme or `none`
to suppress feedback. `light`, `medium` and `heavy` select explicit strength
**only while global Morph haptics are enabled**.

For custom Morph widgets, prefer `MorphHaptics.triggerFor(context, level)`
and `MorphHaptics.selectionFor(context)` to legacy context-free calls.
`selectionFor` scales with the resolved theme intensity: Light uses
`selectionClick`, Medium uses `mediumImpact`, Heavy uses `heavyImpact`, and
None is silent. For explicit overrides, `triggerFor(context, level)` still
respects the global `hapticsEnabled` switch. Defaults inherit the theme.

Sliders and range sliders with `divisions` emit a single tick when their
selected step changes. Continuous sliders have no repetitive drag ticks.
List swipe uses threshold feedback; refresh uses activation/completion
impacts rather than simulated continuous vibration. All of these follow
Morph's global intensity unless explicitly overridden.

Morph 0.4.0 does **not** depend on `core_haptics` or require linking
`CoreHapticsFFI`/SwiftPM in a consuming iOS application.

The override governs **Morph-managed feedback**. Native host/platform
feedback may require separate configuration. Browser previews often have no
physical haptic capability; verify intensity on a real device.

## Component overrides and filled-label styling

`Morph*Theme` classes expose component-specific shapes, sizes, colors and
motion; a widget-level override takes precedence over its theme defaults.
For filled text fields, the default exterior label is slightly larger than
`bodyMedium` and uses `onSurface` when focused. Override its typography with
`floatingLabelTextStyle` on `MorphTextField` or `MorphTextFieldTheme`. The
outlined variant retains its established label treatment.
