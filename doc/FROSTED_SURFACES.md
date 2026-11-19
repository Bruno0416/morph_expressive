# Frosted surfaces: solid and frosted finishes

Morph Expressive can paint a surface as clipped backdrop blur ("frosted glass")
instead of an opaque fill. It is **optional**: a solid surface is faster and
easier to read over a flat background, so use frosted where the content behind
the surface is visually meaningful (imagery, gradients, scrolling content).
The snippets are compiled by `test/doc_examples_test.dart`.

## Solid versus frosted

| | `solid` (default) | `frosted` |
| --- | --- | --- |
| Paint | Opaque container color | Backdrop blur clipped to the shape, tinted with the container color, optional hairline |
| Cost | None | One `BackdropFilter` per surface |
| Content, ink, state layer, focus ring, motion | Unchanged | Unchanged (never blurred) |
| High contrast | Opaque | Opaque by default (`opaqueInHighContrast`) |

Two APIs exist, depending on where the widget lives:

| Kind of widget | API | Widgets |
| --- | --- | --- |
| In-flow content | `surface: MorphSurface.frosted` | `MorphCard` |
| Floating surfaces | `glass: MorphSurfaceGlass?` or the theme default | menus, dropdown panels, dialogs, bottom and side sheets, tooltips, snackbars, toolbars, FAB menu, search view, date and time pickers |
| Navigation chrome | `MorphAppBarGlass`, `MorphNavigationGlass` (separate APIs, see [NAVIGATION_MORPH.md](NAVIGATION_MORPH.md)) | `MorphAppBar`, `MorphNavigationBar` |

Buttons (`MorphButton`, `MorphAsyncButton`, `MorphIconButton`,
`MorphSplitButton`, `MorphButtonGroup` and `MorphShapeButton`) have no frosted
finish: they are not part of this API, and a blur per button or segment would
multiply backdrop filters.

## Configuring the glass

`MorphSurfaceGlass` holds the blur, tint, border and fallbacks:

```dart
const MorphSurfaceGlass glass = MorphSurfaceGlass(
  blurX: 12,
  blurY: 12,
  tintOpacity: 0.65,
  borderColor: Color(0x66FFFFFF),
  borderWidth: 1,
);
```

- `blurX` / `blurY`: Gaussian sigmas in logical pixels (default 12). Both zero
  mounts no `BackdropFilter`; tint and border can remain.
- `tint` and `tintOpacity` (default 0.65): without a `tint` the widget's semantic
  surface color is used. The opacity is independent of the blur.
- `borderColor` with a positive `borderWidth`: optional hairline along the
  shape. Blur and border are clipped to the animated shape.
- `blendMode` (default `srcOver`).
- `opaqueInHighContrast` (default `true`): paint an opaque surface when the
  system requests high contrast.
- `webBackdropBlur` (default `true`): `false` keeps tint and border but skips
  the backdrop blur on the web.
- `boundedBlur` (default `false`): experimental bounded sampling on native
  targets; it changes edge colors and is not a guaranteed speed-up
  ([FROSTED_BLUR_BENCHMARK.md](FROSTED_BLUR_BENCHMARK.md)).
- `const MorphSurfaceGlass.disabled()`: explicitly opaque, even when a parent
  theme enables glass.

## Cards

```dart
Widget frostedInFlow() {
  return Column(
    spacing: 12,
    children: [
      const MorphCard(surface: .frosted, headline: 'Frosted card'),
      // Explicit glass on a card: no `surface:` needed.
      const MorphCard(
        headline: 'Locally frosted',
        glass: MorphSurfaceGlass(blurX: 10, blurY: 10, tintOpacity: 0.50),
      ),
      // Force an opaque card even when a parent or the theme enables glass.
      const MorphCard(
        surface: .frosted,
        glass: MorphSurfaceGlass.disabled(),
        headline: 'Opaque override',
      ),
    ],
  );
}
```

Resolution for cards:

1. an explicit `glass:`; a disabled value means opaque;
2. otherwise `surface: .solid` means opaque;
3. `surface: .frosted` uses `MorphThemeData.floatingSurfaceGlass` when it is set
   and enabled, and falls back to the default `const MorphSurfaceGlass()`.
   Asking for a frosted surface on a widget is an explicit request that does
   not depend on app-level configuration.

Ordinary cards never sample the theme glass: **`MorphCard` is opaque unless it
sets `surface: .frosted` or `glass:`**, even when the theme enables floating
glass. A frosted card drops its elevation shadow. The deprecated
`MorphCard(frosted: true)` maps to `surface: .frosted`.

## Theme-wide default for floating surfaces

`MorphThemeData.floatingSurfaceGlass` (constructor alias `surfaceGlass`) is the
default for the floating surfaces above:

```dart
MorphThemeData frostedTheme() {
  final MorphThemeData base = MorphThemeData.light(
    seedColor: const Color(0xFF6750A4),
  );
  return base.copyWith(
    floatingSurfaceGlass: const MorphSurfaceGlass(
      blurX: 12,
      blurY: 12,
      tintOpacity: 0.65,
    ),
  );
}
```

| Widget `glass:` | Theme `floatingSurfaceGlass` | Result |
| --- | --- | --- |
| Configured, enabled | any | Local glass |
| `MorphSurfaceGlass.disabled()` | any | Opaque |
| `null` | enabled | Theme glass |
| `null` | `null` or disabled | Opaque |

An individual dialog can override the theme:

```dart
Widget optionsDialog() {
  return const MorphDialog(
    title: 'Options',
    content: Text('Choose a setting.'),
    glass: MorphSurfaceGlass(blurX: 8, blurY: 8),
  );
}
```

For `MorphDropdownMenu`, `glass` controls the opened panel, not the closed
field. For `MorphMenu` it controls the opened popup (the `MorphMenu.entries`
factory has no `glass` argument: use `MorphMenu(...)` or `showMorphMenu`).
`MorphBottomSheet.show(...)` takes `glass` on the show helper.

```dart
Future<String?> pickAction(BuildContext context, Rect anchorRect) {
  return showMorphMenu<String>(
    context: context,
    anchor: anchorRect,
    children: const [
      MorphMenuEntry(label: 'Rename', value: 'rename'),
      MorphMenuEntry(label: 'Delete', value: 'delete'),
    ],
    glass: const MorphSurfaceGlass(blurX: 10, blurY: 10),
  );
}
```

Glass does not change input semantics: menus let secondary-button events reach
the widgets under the dismiss scrim, only one context menu is open per root
`Overlay`, and a primary click on the scrim dismisses it.

## Backgrounds, contrast and legibility

Frosted surfaces look right only over something to blur. Over a flat color the
result is a slightly tinted solid surface that still costs a blur; prefer
`solid` there.

Legibility is guaranteed independently of the backdrop. When a card
asks for `surface: .frosted` without an explicit `glass:`, the tint opacity is
raised (never lowered) in 0.02 steps until its supporting text reaches
**4.5:1** against the tint blended over both a white and a black backdrop.
Neutral content such as `onSurfaceVariant` keeps the configured translucency;
colored content on colored fills gets a denser tint. Disabled cards keep the
configured value. An explicit `glass:` is used as given, so you own its
contrast.

For the system **high-contrast** setting, `opaqueInHighContrast: true` paints
the opaque container color and drops the hairline. Turn it off only if you
handle contrast yourself:

```dart
const MorphSurfaceGlass tintOnlyOnWeb = MorphSurfaceGlass(
  webBackdropBlur: false, // keep tint and border, skip the blur on the web
);

const MorphSurfaceGlass alwaysTranslucent = MorphSurfaceGlass(
  opaqueInHighContrast: false, // default true: opaque under high contrast
);
```

## Web, renderers and performance

- Each frosted surface is a real `BackdropFilter`; do not use them for long
  lists of repeated items. Prefer a few large panels or controls placed over
  imagery.
- Use moderate sigmas. Large blur radii on animated or scrolling content are
  expensive, especially on the web: use `webBackdropBlur: false` for a tint-only
  web fallback, or `blurX: 0, blurY: 0` for tint-only everywhere.
- Flutter's default shader-based overscroll stretch places an `ImageFiltered`
  ancestor above scroll content, which changes what a `BackdropFilter` inside it
  samples. `MorphScrollBehavior` uses a geometric stretch without that filter
  ([MORPH_SCROLL.md](MORPH_SCROLL.md)):

```dart
Widget frostedScroller(List<Widget> children) {
  return ScrollConfiguration(
    behavior: const MorphScrollBehavior(),
    child: ListView(children: children),
  );
}
```

- Widget tests cannot prove visual backdrop correctness. Verify on the devices
  and renderers you support; the [Widgetbook preview](PREVIEW.md) has a
  background addon (gradient, image-like pattern, high contrast) for this.

## Source checkout validation

```bash
flutter analyze
flutter test test/frosted_surface_test.dart test/api_frosted_legibility_test.dart
flutter test test/morph_scroll_native_parity_test.dart
```

The runnable [frosted example](../example/frosted_surfaces.dart) shows opaque,
theme-frosted and custom-glass cards over a colorful backdrop, with floating
surfaces and geometric scrolling.
