# Tabs: continuous selection and page progress

`MorphTabs` draws a continuous selection indicator that follows the real
progress of a `MorphTabsView`. Only the indicator moves: tabs, labels, icons and
the bar height stay still.

## Quick use

```dart
// A bar on its own.
MorphTabs(
  tabs: const [MorphTab(label: 'Home'), MorphTab(label: 'Explore')],
  selectedIndex: index,
  onTabSelected: (i) => setState(() => index = i),
  indicatorStyle: MorphTabsIndicatorStyle.surface,
);

// A bar linked to swipeable pages: share one controller.
final controller = MorphTabsController();
Column(children: [
  MorphTabs(controller: controller, tabs: tabs, selectedIndex: index,
      onTabSelected: (i) => setState(() => index = i)),
  Expanded(
    child: MorphTabsView(controller: controller, selectedIndex: index,
        onTabSelected: (i) => setState(() => index = i), children: pages),
  ),
]);
```

Without a shared controller the bar still works; after a swipe settles, the bar
animates its indicator to the new selection instead of following the finger.

## Configuration

| Concept | Widget argument | Tab theme field | Default |
| --- | --- | --- | --- |
| Presentation | `indicatorStyle` | `indicatorStyle` | `underline` (previous look) |
| Motion | `indicatorMotion` | `indicatorMotion`, `indicatorElasticity` | `slide`, 0.3 |
| Width basis | `indicatorFit` | `indicatorFit` | `content` (primary), `tab` (secondary) |
| Duration | `indicatorDuration` | `indicatorDuration`, `indicatorCurve` | 300 ms, `MorphMotion.enter` |
| Renderer | `indicatorRenderer` | `indicatorRenderer` | `auto` |
| Underline | – | `indicatorHeight`, `secondaryIndicatorHeight`, `indicatorRoundedEnds` (default **true**), `indicatorCornerRadius`, `indicatorBottomCornerRadius`, `secondaryIndicatorCornerRadius`, `indicatorInset`, `indicatorTabInset`, `indicatorMinLength` | 3 / 2 dp, fully rounded ends |
| Surface | – | `indicatorSurfaceInset` (uniform, 4), `indicatorPadding` (horizontal, 16), `indicatorVerticalPadding` (8), `indicatorSurfaceRadius` (null = pill), `indicatorGroupRadius`, `indicatorGroupBackground`, `indicatorGroupColor` | pill, concentric container |
| Colour | – | `indicatorColorOverride` | primary (underline), secondary container (surface) |

**Precedence:** widget argument → `MorphTabs.tabTheme` (replaces the inherited
tab theme for that bar) → `MorphTheme.of(context).tabTheme` → package default.
`MorphTabTheme.resolveIndicator` returns the resolved `MorphTabIndicatorSpec`.
Everything is carried by constructors, `copyWith`, `lerp`, `==`/`hashCode` and
the public exports. An unset (null) value in `lerp` switches at the midpoint.

The presentation is independent of `MorphTabsVariant`: the variant describes the
hierarchy of the tab (icon above or beside the label), the style describes how
the selection is drawn. Distribution (`alignment`, `scrollable`) and indicator
width (`indicatorFit`) are separate decisions. `MorphTabsAlignment.content`
(new) sizes each tab by its own content and padding; it scrolls when it overflows.

## Surface geometry

Three layers are coordinated: the outer container (the bar, or the group
background when enabled), the inner surface and the tab content.

* **Inset:** the gap between surface and container is `indicatorSurfaceInset` on
  all four sides (first and last tab included). It is applied once: hugging tabs
  reserve `inset + padding` on each side, tab-fit surfaces are the slot minus the
  inset. The outer bar shape never changes.
* **Content padding** is separate: `indicatorPadding` (horizontal) and
  `indicatorVerticalPadding` (reserves bar height only). They are part of the
  measurement and never change during a transition.
* **Radii:** pill = capsule (inner = surface height / 2, outer = bar height / 2).
  Rounded rectangle: `indicatorSurfaceRadius` = inner, outer = inner + inset.
  `indicatorGroupRadius` alone sets the outer and derives inner = outer − inset;
  both set are honoured as given. Everything is clamped to the geometry
  (`MorphTabIndicatorSpec.innerRadius/outerRadius`), so overrides or lerps never
  exceed a capsule.
* **Hover, pressed and focus** (surface only) use the same rectangle and inner
  radius as the surface, for selected and unselected tabs; the focus ring is
  concentric with a 2 dp gap. The hit target remains the whole slot.
* Underline: `indicatorRoundedEnds` is now the default; set it to `false` for the
  previous top-rounded, flat-bottom line. A scrolling bar clips sideways only so
  the edge coverage of the line is never cut.

## Who moves the indicator

The indicator rectangle is a pure function of measured tab extents and one
position. Nothing competes:

| Situation | Driver |
| --- | --- |
| Rest | The measured extent of the selected tab. |
| Tap or programmatic change, with a view | The view animates the pages and publishes `controller.position`; the bar follows it. |
| Tap or programmatic change, no view | The bar's own animation, from the **visible** rectangle to the live destination. |
| Drag, fling, interruption | The pages, through `controller.position`. No second animation chases them. |

A change of destination mid-flight starts from the visible rectangle: it never
returns to the origin, never finishes an obsolete animation and the indicator
never disappears. A distant destination travels directly; intermediate tabs get
no callback and their labels never take the selected colour. With reduced motion
the bar jumps and the pages jump, but the indicator still follows a finger.

## Selection, progress and focus

* **Selection** is `selectedIndex`, confirmed. `onTabSelected` reports a tap or
  key activation once. `MorphTabsView.onTabSelected` reports once each time the
  dominant page changes during a swipe, never per frame. A controlled parent can
  reject a request: the indicator stays on the confirmed selection, and if the
  user swiped the pages onto a rejected page they animate back.
* **Progress** (`MorphTabsController.position`, a fractional tab index) is
  transient and visual. It never changes `controller.index` and does not notify
  `controller` listeners. It is not announced to assistive technology.
* **Focus** is independent. Arrow keys move focus, Enter/Space selects; moving
  focus neither selects nor moves the indicator. The focus ring does not depend
  on the indicator.

## Motion

* `slide` interpolates the indicator rectangle. No oscillation.
* `elastic` moves the leading edge slightly ahead of the trailing edge and
  recovers on arrival. Both edges are monotonic and end exactly on the
  destination; widths never go negative. The stretch is bounded by the size of
  the indicator, not by the distance. It is deterministic from progress, so it
  also applies during a swipe without lag. Reduced motion removes it.

## Scrollable bars

The indicator lives in the same scrolling content as the tabs, so the scroll
offset is applied once. A selection change or a page progress reveals the target
tab inside the bar only (no other scrollable moves) and never fights a scroll the
user is performing. Focus-following scroll of enclosing scrollables stays opt-in
(`autoScrollToFocusedTab`).

## Measurement

Geometry is read from the laid-out tabs (real typography and text scale, icon,
badge, gaps, padding, directionality), not estimated from characters. It is
refreshed only when the content, theme, text scale, direction, width or tab list
change; a pure size change snaps, a content change animates from the visible
rectangle. The bar height is `max(spec height, content + 8)`, so 2× text grows
the bar once (e.g. 64 → 74 for stacked tabs) and never during a selection.

## List changes

* Give tabs a stable `MorphTab.id` (unique, set on all tabs). If the selected tab
  moved and the parent kept the old index, the bar reports its new index once.
* An out-of-range `selectedIndex` is shown clamped and reported once.
* Controllers and listeners are re-bound on controller change and released on
  dispose; a disposed bar ignores later `reportPosition` calls.

## Accessibility

Tab list, `tab` role with selected state, `tabPanel` role for pages, and a
`controlsNodes` relation between a tab and its page when a controller is shared.
RTL, touch, mouse, keyboard and 2× text are covered by tests. `MorphTab` has no
disabled state in this API.

## Renderer

`auto`/`shader` paint the indicator with the existing rounded-rectangle shader
(`MorphRoundedSurface`) when the corner radii are uniform and the program is
loaded; Canvas (with the same geometry and edge coverage) is used while it loads,
if it fails, and always for the legacy top-rounded underline. Report with
`onIndicatorRendererChanged` (requested vs effective). A fallback never restarts a
transition; uniforms are per instance; results arriving after dispose are dropped.

## Compatibility

All existing constructors, arguments and theme fields keep working. Defaults keep
the underline presentation. `indicatorSpring` is kept but no longer drives the
indicator (the indicator now uses `indicatorDuration` and `indicatorCurve`).
The primary underline still hugs the content minus `indicatorInset`; the secondary
underline still fills the tab. `MorphTabsView` gained `controller`, `duration` and
`curve`; the previous behaviour is unchanged without them, except that pages
crossed during a programmatic change to a distant tab no longer report selections.

## Preview

`?lab=tabs` (Web), `--dart-define=MORPH_LAB=tabs` (native) or the **Tabs Lab**
button in the gallery toolbar. See [PREVIEW.md](PREVIEW.md).

## Known limits

* The Shader is validated visually on Linux (Impeller OpenGLES) and headless
  Chromium; other GPUs/DPRs are not certified.
* With a linked view, a distant jump follows the page position, so the indicator
  passes over the extents of the intermediate tabs (speed varies per segment when
  tab widths differ). Interrupting it with a swipe is exactly continuous because
  both use the same mapping. Without a view the bar travels in a straight line.
* Distant jumps render the intermediate pages while they pass.
* No disabled tabs; no vertical tab bars.
