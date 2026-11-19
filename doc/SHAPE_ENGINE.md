# 2D shape engine

## Model and usage

The additive API is imported from `package:morph_expressive/morph_expressive.dart`.
`MorphCubic` keeps the anchors and Bézier controls; it offers evaluation,
derivative, De Casteljau split and bounds computed from the interior roots of
the derivative. `MorphContour` copies its curves into an immutable list,
requires closure within a tolerance of 1e-7 and accepts 1 to 512 finite
segments. Normalization is explicit; rotation uses radians around the
persistent center.

```dart
final engine = MorphGeometryEngine();
final transition = engine.prepare(
  MorphShapeCatalog.cookie7Sided.contour,
  MorphShapeCatalog.softBurst.contour,
);
final visible = transition.at(0.4);
final interrupted = engine.prepare(visible, MorphShapeCatalog.pentagon.contour);
// interrupted.at(0) keeps the visible geometric locus.
```

`prepare` normalizes winding, exactly subdivides the curves with the longest
control polygon until the counts match, and searches for a cyclic seam using
anchors and controls. The search costs O(n²), once per target; `at` costs
O(n). There is no LCM, fitting or polyline conversion. Retargets never raise
the count above the maximum of the endpoints, up to 512. There is no global
transition cache; the owner keeps its prepared morph. The catalog caches only
its 35 entries.

Finite progress is clamped to [0,1]; NaN and infinity raise `ArgumentError`.
The correspondence is heuristic: it does not implement full semantic feature
matching and does not guarantee simple contours in every frame. Holes,
multiple contours and incompatible topologies are outside the contract. There
is no parity certification with the AndroidX algorithm. Position continuity of
the captured contour is guaranteed, velocity continuity is not. External size
or rotation changes follow the consumer's values; the transform is not
retargeted automatically.

## Canvas and Shader

`MorphShapeView` draws with `Path.cubicTo`, antialiasing, a color or a
`Gradient`. It adds no interactive semantics. Its shared space is not
renormalized every frame; a non-square target deliberately stretches x/y. The
consumer must reserve space for the rotation envelope. The painter does not
prepare correspondences. The current view rebuilds geometry when progress
changes; it does not offer a `Listenable` repaint channel without rebuild for
high-density animations.

Canvas is the default. `.shader` and `.auto` are requests with a fallback,
never guarantees. `onRendererChanged` reports the effective renderer and the
reason. Only `MorphShape.ellipse()` and transitions between these procedural
ellipses are eligible: the analytic ellipse approximates the four-cubic
reference. The raster test at DPR 2, size 120×120 and alpha 0.5 requires a
mean per-channel error below 2/255. This is not a guarantee for every
size/DPR. Catalog shapes, including `circle` and `oval`, do not claim this
capability. Captured contours, gradients and ineligible transitions use Canvas.

The program is loaded outside paint from
`packages/morph_expressive/shaders/morph_ellipse.frag`; the root package tests
use a local asset fallback. Each widget owns independent uniforms and disposes
its `FragmentShader`. A load failure is recorded without a per-frame retry.
The error path exists, but a failed compilation has not been injected in tests.
No FPS improvement or Impeller/RTX validation is claimed from Web tests.

## Catalog provenance

The nine local definitions are fixed cubic data from `material_new_shapes`
**1.0.0**, generated with its public API and keeping its MIT license in
`NOTICE`. SHA-256 of the resolved package archive:
`e4bc375205e187e8fb232573387112dd8c0dd45b03af8aa2b3c79eb4b9e3e0dc`.
They are not parameterizable rounding/smoothing generators.
The other 26 entries publicly convert `RoundedPolygon.cubics`.
All of them are then evaluated with the package's own engine, not with
`material_new_shapes.Morph`.

| Shape | Definition | Canvas | Shader / GPU transition |
| --- | --- | --- | --- |
| circle | Fixed native, derived | Yes | No; fallback |
| square | Adapted | Yes | No; fallback |
| slanted | Adapted | Yes | No; fallback |
| arch | Adapted | Yes | No; fallback |
| semiCircle | Adapted | Yes | No; fallback |
| oval | Fixed native, derived | Yes | No; fallback |
| pill | Fixed native, derived | Yes | No; fallback |
| triangle | Adapted | Yes | No; fallback |
| arrow | Adapted | Yes | No; fallback |
| fan | Adapted | Yes | No; fallback |
| diamond | Adapted | Yes | No; fallback |
| clamShell | Adapted | Yes | No; fallback |
| pentagon | Fixed native, derived | Yes | No; fallback |
| gem | Adapted | Yes | No; fallback |
| sunny | Fixed native, derived | Yes | No; fallback |
| verySunny | Adapted | Yes | No; fallback |
| cookie4Sided | Fixed native, derived | Yes | No; fallback |
| cookie6Sided | Adapted | Yes | No; fallback |
| cookie7Sided | Fixed native, derived | Yes | No; fallback |
| cookie9Sided | Fixed native, derived | Yes | No; fallback |
| cookie12Sided | Adapted | Yes | No; fallback |
| clover4Leaf | Adapted | Yes | No; fallback |
| clover8Leaf | Adapted | Yes | No; fallback |
| burst | Adapted | Yes | No; fallback |
| softBurst | Fixed native, derived | Yes | No; fallback |
| boom | Adapted | Yes | No; fallback |
| softBoom | Adapted | Yes | No; fallback |
| flower | Adapted | Yes | No; fallback |
| puffy | Adapted | Yes | No; fallback |
| puffyDiamond | Adapted | Yes | No; fallback |
| ghostish | Adapted | Yes | No; fallback |
| pixelCircle | Adapted | Yes | No; fallback |
| pixelTriangle | Adapted | Yes | No; fallback |
| bun | Adapted | Yes | No; fallback |
| heart | Adapted | Yes | No; fallback |
| `MorphShape.ellipse()` | Native, procedural | Yes | Yes; only ellipse → ellipse |

## Choosing shapes for icon buttons

`MorphShapeButton` places the `child` at the center of the `size` square and
rotates the surface around that same center: the icon never moves. Some
catalog shapes are not symmetric about that center (their bounding box is
offset, for example `cookie7Sided` ≈ 1 % upward, `heart`, `ghostish`,
`pentagon`, `arrow`), and a centered icon can look off-center. For icon
buttons, especially with rotation, prefer shapes with rotational symmetry
(`sunny`, `softBurst`, `clover4Leaf`, `clover8Leaf`, `flower`, `softBoom`).
`test/morph_shape_button_center_test.dart` pins this contract.

## Loader and button

Both loaders accept `shapes` (at least two) or `polygons` (legacy, at least
two), which are mutually exclusive, and `renderer`. The default sequence does
not change. The loader uses a ticker between starts and keeps the spring
response; the interval is not a morph duration. `TickerMode`, reduced motion
and manual mode stop the cycles. Sequence changes capture the current
contour. The loader hands captured contours to the view, so it currently uses
Canvas even with ellipses. The conservative envelope for any rotation and the
transform continuity when speed/rotation change need additional validation;
the absence of clipping is not certified for every custom polygon.

```dart
MorphShapeButton(
  shape: MorphShapeCatalog.cookie7Sided,
  pressedShape: MorphShapeCatalog.softBurst,
  selectedShape: MorphShapeCatalog.pentagon,
  selected: selected,
  rotationOnPress: 0.0, // radians; container only
  onPressed: onPressed,
  child: const Text('Save'),
)
```

Selection is controlled; press takes priority, with a fallback to
selected/rest if an optional shape is missing. It reuses the button
interaction lifecycle; Material/InkWell is the action authority. It shares one
contour for ink, clip and hit test; the child neither rotates nor scales. The
minimum outer size is 48 dp; the active surface follows the contour and does
not guarantee an inscribed 48 dp circle for every concave shape. Visible
focus, tooltip and Semantics are included.

## Sources consulted

- [Shapes in Compose](https://developer.android.com/develop/ui/compose/graphics/draw/shapes).
- [LoadingIndicator in Compose, commit dd7d2935e6a5ab12f6957a813926eea1ca38188e](https://android.googlesource.com/platform/frameworks/support/+/dd7d2935e6a5ab12f6957a813926eea1ca38188e/compose/material3/material3/src/commonMain/kotlin/androidx/compose/material3/LoadingIndicator.kt).
- [Fragment shaders in Flutter](https://docs.flutter.dev/ui/design/graphics/fragment-shaders).

The new matching is not a port of the AndroidX implementation; no algorithm
SHA is invented. The sequence shared with Compose does not imply motion parity.
