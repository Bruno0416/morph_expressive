# Operation buttons and skeleton/shimmer

Included in Morph Expressive 0.8.0; it does not change the existing defaults.
Import: `package:morph_expressive/morph_expressive.dart`.

## Controlled button

```dart
MorphAsyncButton(
  label: 'Save',
  state: operationState, // MorphOperationState: idle/loading/success/error
  onPressed: saveFromTheApplication,
  presentation: MorphOperationPresentation.compact,
  labels: const {
    MorphOperationState.loading: 'Saving',
    MorphOperationState.success: 'Saved',
    MorphOperationState.error: 'Retry',
  },
)
```

The consumer owns the state, the Futures and the cancellation. There is no
result timer, minimum loading duration or exception interpretation.
`onPressed: null` or `enabled: false` disable it explicitly. While loading,
`blockWhileLoading: true` blocks the action but keeps the active colors and
focus; it does not trigger haptics again. `showLoadingLabel: false` leaves
only the loader.

A single MorphButton instance is kept for the whole operation. The five styles
are filled, tonal, outlined, text and elevated; it uses Morph's sizes and
typography. `icon`, `loading`, `successIcon` and `errorIcon` are optional.
The default loader is MorphLoadingIndicator; success/error include symbols,
not just color. `tooltip`, `focusNode`, `semanticLabel` and `semanticValue`
let you customize the interaction and translate the state description. There
is a single live semantics region; the loader produces no additional
announcements per frame.

`preserveWidth` keeps the measured width of the rest label (and its icon);
long state labels use ellipsis and never scale. `compact` animates toward a
touch square of at least 48 dp. Tight parent constraints, `constraints`,
decoration.fixedSize/size.width and explicit limits take priority. The height
adapts to the text; a smaller explicit constraint can reduce the touch area.
`shape` accepts round/square. The width/radius/color transition starts from
the visible value when interrupted; the new content appears without
stretching or accumulating old copies. `transitionDuration` (280 ms by
default) is independent of pressDuration/releaseDuration (90/160 ms). Reduced
motion makes the change immediate.

Decoration precedence: MorphButton scope → local decoration → the operation
theme's decorations for the state → the widget's stateDecorations. The surface
uses MorphRoundedSurface with `renderer`/`onRendererChanged`, with immediate
Canvas while the shader loads or fails. Gradients use the existing fallback.
An explicit backgroundBuilder keeps its authority over the renderer and is
reported as Canvas/custom. No additional offscreen capture is added to
MorphButton.

### Error colors (semantic default)

In `error` (with the button enabled) the defaults use Morph's color tokens,
per style: filled `error`/`onError`; tonal `errorContainer`/
`onErrorContainer`; outlined a transparent surface with `error` border and
content; text `error` content; elevated keeps its elevated surface with an
8 % `error` tint and `error` content. Contrast is verified by test (≥ 3:1,
light and dark). Error never depends on color alone: the icon
(`MorphIcons.error`/`errorIcon`) and the label change. Disabled keeps its
disabled colors, distinct from error.

Color precedence in `error`: semantic error defaults (above the MorphButton
scope and the local `decoration`, so it is not confused with idle) →
`MorphAsyncButtonTheme.decorations[error]` → the widget's
`stateDecorations[error]` (wins). The other states do not change: scope →
decoration → theme → widget.

Preserved width: never smaller than glyph + gap + label of a state (bounded
by the rest label width); this way, on small buttons without a rest icon, the
glyph does not squeeze the label until it is clipped.

### Glyph transition (loading → success)

The state glyph lives in a stable square space (`iconSize`), without
clipping. On a state change: the outgoing glyph scales down (→ .8) and fades
out (0–60 % of the curve) while the incoming one appears by opacity
(30–100 %), scale (from `initialScale` = .6) and, on success, rotation from
`successRotation` (−45°) to 0°. Neither the button nor the label scales or
rotates; the label only performs its existing fade. `successIcon`/`errorIcon`/
`loading` are arbitrary `Widget`s; they are wrapped with Opacity/Transform,
never copied.

Configuration: `MorphAsyncButton.iconTransition` →
`MorphAsyncButtonTheme.iconTransition` →
`MorphOperationIconTransition.defaults` (320 ms, `easeOutCubic`). `.none` (or
reduced motion) switches the glyph without rotation or movement. It is
independent of `transitionDuration` (surface/width, 280 ms) and of the 90/160
ms press/release. An interruption starts from the visible pose: the glyph that
was entering becomes the outgoing one with its current opacity/scale/angle;
there are no internal timers, minimum durations or automatic return to idle.
When leaving compact, the padding grows with the width so it does not overflow
while the surface is narrow.

## Skeleton

```dart
MorphSkeletonGroup(
  loading: isLoading,
  semanticLabel: 'Loading profile',
  placeholder: Row(children: [
    const MorphSkeleton.avatar(),
    const SizedBox(width: 16),
    Expanded(child: MorphSkeleton.lines(count: 3)),
  ]),
  child: profile,
)
```

Shapes: `MorphSkeleton`, `.line`, `.lines`, `.avatar`, `.image`, and `shape`
from MorphShapeCatalog. Explicit dimensions or the available width; without a
bounded width, the generic one uses 120 dp. For multiple lines, provide a
bounded width. Placeholders are not inferred from real widgets.

`MorphSkeletonEffect.shimmer`, `.pulse`, `.none`; four directions through
MorphShimmerDirection. One controller per group, not per rectangle. Positions
are transformed into the group's space for a coherent sweep even across rows
of different widths. The FragmentProgram is loaded outside paint and shared;
each placeholder has its own FragmentShader and uniforms. Each fragment only
covers its rectangle. There are no image captures, backdrop filters or glow.

### Band angle

`MorphSkeletonGroup.angle` (degrees) → `MorphSkeletonTheme.angle` → 0. 0° is
the approved look. The band is the untilted band (perpendicular to the
direction) rotated clockwise on screen: with left/right it is the tilt from
the vertical (positive `/`, negative `\`); with up/down the horizontal band
rotates the same way. `direction` still decides the travel direction; the
angle only decides the tilt. It is computed in the group's common space: the
phase is normalized over the projection of the group's rectangle onto the
band normal (covering corners) and the visual band width stays at .2 of the
untilted axis (bounded at angles close to ±90°). Shader and Canvas use the
same formulas (`morphShimmerGeometry` / `uAngle`). Pulse and the static
placeholder ignore the angle; the phase is not restarted when it changes. The
tree and the shapes are not rotated.

Shimmer auto/shader uses the fragment shader when available; Canvas uses a
gradient with the same phase and space. Pulse and static are painted on
Canvas. Catalog shapes use Canvas with MorphEdgeCoverage to respect their
exact contour; the group's effective state describes the rectangles and does
not convert catalog contours to a procedural shader.

Precedence: widget → MorphThemeData.skeletonTheme → colorScheme/defaults.
Configurable: duration (1600 ms), transitionDuration (180 ms), intensity
(.35), baseColor, highlightColor, enabled, renderer and the effective
callback. Both new themes offer copyWith/lerp/equality and are preserved when
copying MorphThemeData. The operation decoration maps are immutable by
contract; when interpolating, one map is chosen at t=.5, as a discrete
setting.

The real content keeps its layout; while loading it has IgnorePointer,
ExcludeFocus and ExcludeSemantics. The crossfade never shows an empty frame or
allows activating hidden content. Use equivalent sizes in placeholder/content
to keep the space stable. A reversal retargets from the visible opacity.
Reduced motion uses static placeholders and an immediate change. Disabled,
visible content and a disabled TickerMode stop the clock. Dispose releases the
controller and shaders. For lists, use TickerMode and the viewport's
mount/unmount; there is no global visibility system. An independent group has
its own phase.

## Reactive button group

`MorphReactiveButtonGroup` is a new component; `MorphButtonGroup` (including
the approved connected one) does not change. It reuses `MorphButton`, the
group theme (`connectedGap`, heights) and per-decoration radii; it does not
duplicate the classic group's overflow or measurement.

Modes (`MorphReactiveGroupMode`): `singleSelect` (`selectedIndex`; tapping the
selected item clears it unless `selectionRequired`), `multiToggle`
(`selectedIndices`) and `actions` (never selected; `onPressed` per item). The
state always belongs to the consumer; selection/toggle/action are confirmed by
the button's normal tap, never on pointer down. Cancellation by scroll/drag
fires nothing and restores widths. Multiple pointers: each button keeps its
press and they are resolved together with the same distribution.

Distribution (`resolveReactiveWidths`, a single common state animated by one
ticker; the render object re-lays out, it does not rebuild). Stable base:
natural widths and the row height are measured only when content, theme or
constraints change (never from the animated result) and the children receive
a tight height, so the height does not vary during interaction. Each button's
natural width (content, padding, icons, `minWidth`; icon-only minimum square)
→ `fit`: `fill` (bounded width: distributes the slack proportionally to the
natural width; the expansion moves width between siblings, total constant),
`natural` (the expansion only consumes slack; siblings do not yield) or
`uniform` (equal widths). With an unbounded width, infinite space is never
distributed: natural widths, and the pressed/active item grows its ratio
without others yielding. Per-item target = `max(selectedExpansion if
selected, pressedExpansion if pressed)`, not a sum. `pressedExpansion` is .15
and `selectedExpansion` .08 by default: they are the ratio of the rest width
(a pressed 130 dp button gains ≈ 20 dp). Local compensation: each item that
asks for width takes it only from its adjacent neighbors (half and half; at an
end, from the only neighbor; if one has no slack, from the other). Distant
elements do not change. A neighbor without slack yields less (soft
saturation); the part not yielded is not rerouted to the other side, to avoid
jumps or waves. Donors yield only what exceeds their natural width, weighted
by how little they ask for (a selected item loses its gain when its pressed
neighbor claims it); if there is no slack the amplitude is 0 (shapes and
feedback are kept); if the parent fits not even the natural widths they are
compressed proportionally with ellipsis. No negative widths or overflow; with
everything active only the shapes change. The evolution is a critically
damped system per value (ω 30/22 rad/s, no overshoot or velocity jump), with a
bounded dt. `width` pins an item outside the distribution. Visible values are
retargeted (position and velocity are preserved), reduced motion jumps to the
target.

Shapes: radii in dp per group or item (`restRadius`, `selectedRadius`,
`pressedRadius`); the rest is pill/circular and the selected/pressed one uses
`MorphButton`'s squarer defaults. Per-item styles (`style`, `decoration`)
allow the central button of media controls. Text, icons and labels never
scale; ellipsis only when they do not fit; the full text stays in Semantics.
RTL reverses the order; hit testing, splash and focus belong to each surface
(the layout assigns the real size). Limitation: if a `selectedLabel` changes
the natural width, the change is immediate.

## Preview and examples

Gallery → **Operation & Skeleton Lab**. Stable Web access: `?lab=operations`.
Web: `?lab=operations&section=async|groups|shimmer` jumps to the section.
Optional native review: `--dart-define=MORPH_OPERATION_SECTION=async|groups|shimmer` jumps to the section and `MORPH_OPERATION_AUTORUN=true` repeats loading→success.
Linux: `flutter run -d linux --release --dart-define=MORPH_LAB=operations`
from `preview/`. The file `preview/lib/operation_loading_lab.dart` is the
compilable example of the simulations with cancelable generations/timers.

New sections: **AsyncButton polish** (five styles in error, override and
disabled, loading→success/error/loading, repetition, interruption during the
entrance, normal 320 ms/slow 1400 ms, default icon and custom Widget,
animation disabled, compact/preserve), **Reactive button groups** (the three
modes, connectivity, two media controls, icon-only/label-only/icon+label,
several active and all active, 560/260 container, long labels, uniform,
expansion/radius/gap sliders and a comparison with the previous connected one)
and, in the shimmer, an angle control −90…90 with presets and a comparison
between groups (0°, ±30°, wide/narrow).

It includes five styles and both widths, manual states, success/error/retry,
immediate result, interruptions, disabled, long text, icons, custom loader,
sizes, card, eight-row list, posters, catalog shape and independent groups.
Controls for light/dark, mobile, 2× text, RTL, reduced motion, duration,
direction, intensity and requested/effective renderer.

No performance improvements are promised. The cost of the Canvas sweep is per
contour and that of the shader per rectangle; the solution keeps the existing
smoothing.

## Local validation — 2026-11-11

- Root analysis without issues. Focused operation/skeleton, press and rotation
  suite: 24 tests passed. Preview suite: 57 passed, including 390/1440 px with
  2× text. Specific tests check raster synchronization (tolerance of one 8-bit
  quantization level), group independence, TickerMode, reduced motion,
  focus/keyboard, semantics, reversal and dispose.
- `tool/check.sh`: Python guards, imports and analysis passed; root suite 1051
  passed and three historical failures identified in the R3 report:
  `list_expandable_test`: `expandable nested last row closes bottom radii`,
  `sublist last row rounds its bottom unless opted out`;
  `text_field_test`: `MorphTextField centers the label until it floats`.
  Those families were not touched. The preview suite was run separately.
- Web and Linux release builds passed. Real native review through
  `MORPH_OPERATION_REVIEW=true`, Impeller OpenGLESSDF: several loading
  buttons, compact/preserved, error, an eight-skeleton list and
  reduced/RTL/mobile/2× text configuration. The captures detected, and allowed
  fixing, the low-contrast filled loader (regression added); the later review
  shows contrast and soft edges. Temporary evidence: `/tmp/opencode/operations-native-*.png`.
- Headless Chromium at 1440×1000: idle/loading/error changes, interruptions,
  effective Canvas/Shader, real content/return to loading and light/mobile/RTL/2×.
  No JS exceptions from the app. A 404 for `/favicon.ico` from the preview
  server remains; the build warning about Material/Cupertino fonts from
  existing examples also persists. The new lab uses Fluent.
- Indicative sample of 120 requestAnimationFrame intervals in headless
  Chromium, several buttons loading and animated skeleton groups: median
  16.7 ms, p95 33.4 ms, maximum 50 ms. **This is not a GPU or Flutter
  build/raster measurement**, nor proof of an improvement; some intervals
  exceeded a 16.7 ms budget. Performance on other GPUs/DPR or long lists is
  not certified.
- The naming gate available at `tool/ci/check_final_release_language.py`
  passed. The local instructions already point to that path; see the
  automation audit in [the 0.8.0 report](RELEASE_0_8_0.md) for the later state
  of tooling and publication.

Final implementation of the described scope; there are no version changes,
commit, push, tags or publication. CI and validation on other platforms are
pending.
