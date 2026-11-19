# Upgrading to the v1 component API

This guide covers the migration from 0.8.x to 1.0.0: named constructors for
visual types, shared chromatic variants and an independent surface finish, plus
the density system and desktop context menus. The reference is
[Component API: type, variant and surface](API_V1.md); coming from 0.7.x, read
[Upgrading from 0.7.x](UPGRADE_0_8_0.md) first.

Version 1.0.0 is implemented and validated locally; its publication is
pending. The latest published version is 0.8.0. The two snippets marked
"After" are compiled by `test/doc_examples_test.dart`.

## Summary

| Area | Before | Now |
| --- | --- | --- |
| Color roles | per-call `decoration` overrides | `variant: MorphVariant?` on buttons, icon buttons, cards, async / split / shape buttons and button groups |
| Frosted in-flow controls | `MorphCard(frosted: true)` only | `surface: MorphSurface.frosted` on `MorphButton`, `MorphAsyncButton`, `MorphIconButton`, `MorphCard` |
| Icon button type | `variant: MorphIconButtonVariant.x` | `type: MorphIconButtonType.x` or `MorphIconButton.x(...)` |
| Card type | `variant: MorphCardVariant.x` | `type: MorphCardType.x` or `MorphCard.x(...)` |
| Text field type | `variant: MorphTextFieldVariant.x` | unchanged, plus `MorphTextField.filled` / `.outlined` |
| Chip type | `type: MorphChipType.x` | unchanged, plus `MorphChip.assist` / `.filter` / `.input` / `.suggestion` |
| Seed schemes | `MorphColorScheme.fromSeed(seed, brightness:)` | adds optional `dynamicSchemeVariant` and `contrastLevel` |

## Breaking changes

### `MorphIconButton`

The visual type parameter is now `type`. The name `variant` is the shared color
role, as on every other action component.

```dart
// Before (does not compile with 1.0.0)
MorphIconButton(variant: MorphIconButtonVariant.tonal, icon: icon, onPressed: f);
```

After:

```dart
List<Widget> iconButtonMigration(Widget icon, VoidCallback f) {
  return [
    MorphIconButton.tonal(icon: icon, onPressed: f),
    MorphIconButton(type: MorphIconButtonType.tonal, icon: icon, onPressed: f),
  ];
}
```

`MorphIconButtonVariant` remains a deprecated typedef of `MorphIconButtonType`,
so references to the enum name still compile with a deprecation hint. Calls
that pass `variant: MorphIconButtonVariant.x` fail to compile with a type error
(`MorphIconButtonType` is not a `MorphVariant`); rename the argument to `type:`.

### `MorphCard`

```dart
// Before (frosted: true still works but is deprecated)
MorphCard(variant: MorphCardVariant.outlined, frosted: true, child: child);
```

After:

```dart
List<Widget> cardMigration(Widget child) {
  return [
    MorphCard.outlined(surface: .frosted, child: child),
    MorphCard(
      type: MorphCardType.outlined,
      surface: MorphSurface.frosted,
      child: child,
    ),
  ];
}
```

- `MorphCardVariant` is a deprecated typedef of `MorphCardType`.
- `frosted: true` still works and is deprecated in favor of
  `surface: MorphSurface.frosted`. An explicit `glass:` configuration still wins.
- The enum lives in `components/cards/enums/morph_card_type.dart`; the old
  `morph_card_variant.dart` file re-exports it for direct imports.
- List widgets and list themes keep their `variant` parameter. It is typed
  `MorphCardType` and still names the row card type.

## Additive changes

- `MorphVariant`, `MorphSurface` and `MorphVariantPalette` are exported from
  `package:morph_expressive/morph_expressive.dart`.
- `variant` and `surface` default to `null` and `MorphSurface.solid`; existing
  code renders exactly as before.
- `MorphColorScheme.fromSeed` and `MorphThemeData.light` / `.dark` accept
  `dynamicSchemeVariant` (default `DynamicSchemeVariant.tonalSpot`) and
  `contrastLevel` (default `0`). `DynamicSchemeVariant` is re-exported.
- `surface: MorphSurface.frosted` uses the theme's `floatingSurfaceGlass` when it
  is enabled and the default `MorphSurfaceGlass()` otherwise, so it works
  without any theme configuration ([Frosted surfaces](FROSTED_SURFACES.md)).
- New documents: [Accessibility](ACCESSIBILITY.md), a rewritten
  [Theming](THEMING.md), [Components](COMPONENTS.md) and [Release process](RELEASE.md).

## Intentional visual changes

- **Disabled containers and outlines** of buttons and FABs use
  `MorphStateOpacity.disabledContainer` (0.12, the Material 3 value) instead of
  a local 0.1. Every component now takes its disabled alphas from the shared
  `MorphStateOpacity` tokens.
- **Derived dark themes** (`MorphMaterialApp` and `MorphThemeScope` adaptive
  dark mode) are now generated from the original seed, scheme variant and
  contrast instead of re-seeding from the light `primary`. The derived dark
  scheme now equals `MorphThemeData.dark(seedColor)`; with the default seed the
  dark `secondary` moves by one channel step.

## Technical notes for the changelog

- Added `MorphVariant`, `MorphSurface` and `MorphVariantPalette` shared API.
- Added `variant` and `surface` to `MorphButton` (all constructors) and
  `MorphAsyncButton`; `variant` to `MorphSplitButton`, `MorphButtonGroup` and
  `MorphShapeButton`.
- Added `MorphIconButton.standard/.filled/.tonal/.outlined`, `MorphIconButtonType`,
  `variant` and `surface`; renamed the type parameter to `type`.
- Added `MorphCard.elevated/.filled/.outlined`, `MorphCardType`, `variant` and
  `surface`; renamed the type parameter to `type`; deprecated `frosted`.
- Added `MorphTextField.filled/.outlined` and
  `MorphChip.assist/.filter/.input/.suggestion`.
- Added scheme variant and contrast options to seed-based themes.
- Fixed derived dark themes drifting from `MorphThemeData.dark(seedColor)`.
- Cached the derived Material themes in `MorphMaterialApp`.
- Normalized disabled alphas to `MorphStateOpacity` tokens.
- Frosted in-flow controls raise their tint opacity when needed so content
  keeps 4.5:1 (3:1 for icons) over any backdrop.
- Outlined cards and icon buttons with a primary, secondary or tertiary
  variant keep their own `outlineVariant` border.
- Replaced imports deprecated by Flutter 3.50 (`package:flutter/material.dart`)
  with `package:material_ui/material_ui.dart`.
- Migrated the preview to Widgetbook (see [Preview](PREVIEW.md)).

## Density, badges and desktop context menus

See [Density and context menus](DENSITY_AND_CONTEXT_MENUS.md).

- Added `MorphDensity` (`compact`, `standard`, `comfortable`) and
  `MorphDensityMetrics`; `MorphThemeData.density` (default `standard`),
  `copyWith(density:)` and a `density` argument on `MorphThemeData.light`,
  `.dark` and `.fromMaterial`. Standard keeps every previous dimension.
- `MorphSegmentedButton.density`, `MorphButtonGroup.density`,
  `MorphNavigationBar.density` and `MorphAppBar.density` are now nullable;
  `null` follows the theme density. Passing a value works as before; only code
  that reads these fields as non-null needs a null check.
  `MorphChipToggle.height` is nullable too (`null` = 40 dp plus the density
  delta).
- `MorphSplitButtonTheme.splitHeight(size)` no longer takes a density argument;
  the theme resolves density once (`MorphSplitButtonTheme.density`).
- Badge labels use `w600` with slightly more padding (standard min size 18,
  was 16). `MorphBadgeTheme.density` overrides the global density.
- Added `MorphContextMenuRegion`, `showMorphContextMenu`,
  `MorphMenuPresentation` and `MorphMenuDesktopMetrics`. `showMorphMenu`
  gains `presentation`, `density` and `autofocusFirstItem`; its default
  geometry is unchanged. Menus now follow the caller's nested `MorphTheme`.
- Home/End move the highlight in every menu.
