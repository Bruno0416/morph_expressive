# Frosted surfaces — theme, opt-in cards, and menus

> **0.7.0 release candidate.** This guide describes the source-tree API.
> The 0.7.0 package has not been published yet; use a path dependency until
> the release checks and new GIF capture are complete.

Morph Expressive supports clipped backdrop blur on selected floating surfaces.
It is designed to be **optional**: an ordinary opaque surface is often faster
and easier to read over a flat background. Use frosted surfaces where the
background is visually meaningful, rather than enabling them indiscriminately.

## Shared configuration

`MorphSurfaceGlass` configures the blur, tint, border, and platform fallback:

```dart
const glass = MorphSurfaceGlass(
  blurX: 12,
  blurY: 12,
  tintOpacity: 0.65,
  borderColor: Color(0x66FFFFFF),
  borderWidth: 1,
);
```

- `blurX` / `blurY`: Gaussian sigmas in logical pixels. Both zero means **no
  `BackdropFilter`**, although tint and border can remain.
- `tint`: optional explicit color; otherwise the widget's semantic surface
  color is used. `tintOpacity` ranges from 0 to 1; it is independent of blur.
- `borderColor` plus positive `borderWidth`: optional outline. The shared
  renderer clips the blur and border to the surface shape; child content is
  painted over the backdrop, not itself blurred.
- `blendMode`: backdrop compositing mode (default `BlendMode.srcOver`).
- `opaqueInHighContrast: true`: use an opaque surface when the system requests
  high contrast.
- `webBackdropBlur: false`: preserve tint and border but skip backdrop blur on
  Web; native blur is unaffected.
- `const MorphSurfaceGlass.disabled()`: explicitly restores an opaque surface,
  including when a parent theme enables frosted surfaces.

`MorphSurfaceGlass` is different from `MorphAppBarGlass` and
`MorphNavigationGlass`. The latter two belong to the separate navigation
surfaces documented in [Navigation](NAVIGATION_MORPH.md).

## Theme-wide defaults for floating surfaces

The theme's `floatingSurfaceGlass` (alias: `surfaceGlass`) supplies the default
for compatible floating surfaces such as dropdown panels, menus, dialogs,
bottom sheets, side sheets, and tooltips.

```dart
final base = MorphThemeData.light(seedColor: const Color(0xFF6750A4));
final themed = base.copyWith(
  floatingSurfaceGlass: const MorphSurfaceGlass(
    blurX: 12,
    blurY: 12,
    tintOpacity: 0.65,
  ),
);

// Install `themed` using the usual MorphTheme + MaterialApp setup.
```

For these floating surfaces, the resolution order is:

| Widget `glass:` | Theme `floatingSurfaceGlass` | Result |
| --- | --- | --- |
| A configured, enabled value | Anything | Local glass |
| `const MorphSurfaceGlass.disabled()` | Anything | Opaque |
| `null` | Enabled | Theme glass |
| `null` | `null` or disabled | Original opaque surface |

For example, an individual dialog can override the theme:

```dart
const MorphDialog(
  title: 'Options',
  content: Text('Choose a setting.'),
  glass: MorphSurfaceGlass(blurX: 8, blurY: 8),
)
```

For `MorphDropdownMenu`, `glass` controls the **opened panel**, not its closed
field. For `MorphMenu`, it controls the opened popup. `showMorphMenu(...)` also
exposes `glass`. When calling `MorphBottomSheet.show(...)`, pass `glass` to the
show helper; its adaptive variant also forwards it to the selected surface.

## Cards are intentionally opt-in

**`MorphCard` is opaque by default**, even if the theme configures
`floatingSurfaceGlass`. This is deliberate: cards frequently sit over uniform
backgrounds, where sampling the backdrop consumes resources without adding
useful visual separation.

```dart
// Ordinary card: normal fill and elevation; no backdrop filter.
const MorphCard(headline: 'Regular card');

// Reuse the current theme's glass (if the theme enabled it).
const MorphCard(frosted: true, headline: 'Frosted card');

// Explicit glass, even when the theme has no glass configuration.
const MorphCard(
  headline: 'Locally frosted',
  glass: MorphSurfaceGlass(blurX: 10, blurY: 10, tintOpacity: 0.50),
);

// Override any theme and force an opaque card.
const MorphCard(
  frosted: true,
  glass: MorphSurfaceGlass.disabled(),
  headline: 'Opaque override',
);
```

Card resolution is **local `glass` first**, then theme glass **only** when
`frosted: true`; otherwise the normal opaque card is used. Setting
`frosted: true` alone does not invent a glass configuration when the theme
has none. A frosted card suppresses its conventional elevation shadow; an
opaque card retains the normal card styling and interactions.

**Migration note for source users:** if an earlier in-development build made
all cards frosted when the theme enabled glass, add `frosted: true` explicitly
to the cards that should keep that effect. This intentional default change
is not part of published `0.6.1`.

## Context menus and repeated secondary clicks

Menus share the same glass resolution rules, but **glass does not change their
input semantics**. The popup implementation allows secondary-button events to
reach underlying targets through its dismiss scrim and coordinates open menus
per root `Overlay`. Opening a different context menu in that overlay replaces
the old one, rather than stacking multiple menus. A normal primary click on
the scrim dismisses the menu.

```dart
// For context menus anchored to an existing rect:
final selection = await showMorphMenu<String>(
  context: context,
  anchor: anchorRect, // e.g. the target's global bounds
  children: const [
    MorphMenuEntry(label: 'Rename', value: 'rename'),
    MorphMenuEntry(label: 'Delete', value: 'delete'),
  ],
  glass: const MorphSurfaceGlass(blurX: 10, blurY: 10),
);
```

The application is still responsible for detecting a right-click and
providing the correct anchor rectangle. The regular `MorphMenu` constructor
also accepts `glass:`. **`MorphMenu.entries` currently has no `glass`
argument**; use `MorphMenu(...)` with its `entries:` argument, or
`showMorphMenu(...)`, when a local glass override is required.

## Performance and compatibility

- Prefer opaque cards on flat backgrounds. Reserve frosted cards and popups for
  visually layered screens.
- Prefer moderate blur sigmas. Increasing blur radius and animating the
  backdrop simultaneously can be expensive, especially on Web.
- Use `blurX: 0, blurY: 0` for a tint-only surface with no blur sampling, or
  `webBackdropBlur: false` for a web-specific fallback.
- If a frosted card is placed inside a scrollable that stretches, Flutter's
  stock shader-based overscroll may capture the child through `ImageFiltered`
  and change the pixels available to its `BackdropFilter`.
  [MorphScrollBehavior](MORPH_SCROLL.md) uses Flutter-like **geometric** stretch
  without adding that filter.
- The result still depends on the actual compositor and ancestor clipping;
  widget tests alone cannot prove visual backdrop correctness. Verify on the
  device you intend to support.

## Validation in the source checkout

```bash
flutter analyze
flutter test test/frosted_surface_test.dart
flutter test test/morph_scroll_native_parity_test.dart
flutter test test/morph_scroll_repeated_spring_test.dart
flutter test
cd preview
flutter analyze
flutter test
flutter run -t lib/main_mobile.dart
```

In the mobile preview, inspect **Frosted Surfaces** and **Scroll Blur
Compatibility Lab** in light/dark modes, with backdrop blur enabled/disabled,
and with repeated overscroll at both ends. Also verify the default opaque card,
`frosted: true`, and explicit `glass` overrides.

The [self-contained example](../example/frosted_surfaces.dart) demonstrates
these variants together with a colorful backdrop and geometric scrolling.
