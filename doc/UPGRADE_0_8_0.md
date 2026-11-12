# Upgrading from 0.7.x to 0.8.0

Morph Expressive 0.8.0 is additive: every 0.7.x constructor, enum, polygon type
and re-export remains. A few defaults changed to match the approved motion and
geometry; each one has a way back. All new symbols are exported from
`package:morph_expressive/morph_expressive.dart`. A runnable tour of the new
APIs is [`example/whats_new_0_8_0.dart`](../example/whats_new_0_8_0.dart); the
snippets below are excerpts of it.

Publication of 0.8.0 is pending: until it is published, depend on a Git or path
checkout (see [Getting started](GETTING_STARTED.md)).

## Changed defaults and behavior

| Area | 0.7.x | 0.8.0 | Go back / adjust |
| --- | --- | --- | --- |
| Button press / release | Fixed spring timing | 90 ms press, 160 ms release, reversible from the visible geometry | `MorphButtonTheme.pressDuration` / `releaseDuration` |
| Connected button group inner radii | 8 / 4 (pressed) | 11 / 6 | `MorphButtonTheme.connectedInnerRadius` / `connectedPressedInnerRadius` |
| Connected group width | Fills the available width | Widest measured button is the common width; never changes on selection | `MorphButtonGroup.itemWidth`, or `MorphButtonGroupAction.width` for one action |
| Connected group gap | 2 dp | 4 dp | `MorphButtonGroup.spacing` > `MorphButtonGroupTheme.connectedGap` (0 allowed) |
| Dropdown / menu motion | Original anchored spring | Centered fade and scale (`MorphDropdownMotionStyle.centered`); `liquid` and `legacy` stay available | `motionStyle: MorphDropdownMotionStyle.legacy` |
| Dropdown panel top margin | 4 dp | 8 dp | `MorphDropdownPanelStyle.marginTop` |
| Submenus (desktop) | Click | Hover with delays | `submenuBehavior: MorphMenuSubmenuBehavior(mode: MorphMenuSubmenuOpenMode.click)` |
| Rail and page indicator stretch | Original geometry | `organicStretchIntensity` 0.40 | `organicStretchIntensity: 0` |
| FAB menu | A second FAB in the overlay | One morphing surface | Visual only; `renderer` / `onRendererChanged` are new |
| Tabs underline | Top-rounded, flat bottom | Fully rounded ends | `MorphTabTheme(indicatorRoundedEnds: false)` |
| Tabs bar height | Fixed 48 / 64 | The same, growing only when large text needs it | None needed |
| Distant tab jump with `MorphTabsView` | Reported every crossed page | Reports only user swipes; no intermediate callbacks | None needed |
| `MorphTabTheme.indicatorSpring` | Moved the indicator | Kept, no longer used (`indicatorDuration`, `indicatorCurve`) | Use the new fields |

## New APIs

```dart
// Controlled operations (idle / loading / success / error); no timers inside.
MorphAsyncButton(
  label: 'Save changes',
  state: operation,
  presentation: MorphOperationPresentation.preserveWidth, // or .compact
  labels: const {
    MorphOperationState.success: 'Saved',
    MorphOperationState.error: 'Retry',
  },
  onPressed: save,
)

// Placeholders: one clock and one tilted band for the whole group.
MorphSkeletonGroup(
  loading: loading,
  angle: 18,
  placeholder: Column(children: [
    const MorphSkeleton.avatar(),
    MorphSkeleton.lines(count: 3),
  ]),
  child: profile,
)

// Single selection, multi toggle or independent actions.
MorphReactiveButtonGroup(
  selectedIndex: range,
  selectedExpansion: 0.08, // pressedExpansion defaults to 0.15
  onSelectedIndexChanged: (next) => setState(() => range = next ?? range),
  items: const [
    MorphReactiveGroupItem(label: Text('Day')),
    MorphReactiveGroupItem(label: Text('Week')),
  ],
)

MorphShapeButton(
  shape: MorphShapeCatalog.cookie7Sided,
  rotationEnabled: true, // optional; the surface rotates, not the content
  onPressed: onPressed,
  child: const Icon(MorphIcons.favorite_border),
)

// Tabs linked to real pages: share one controller.
MorphTabs(controller: tabs, tabs: items, selectedIndex: tab,
    onTabSelected: select, indicatorStyle: MorphTabsIndicatorStyle.surface)
MorphTabsView(controller: tabs, selectedIndex: tab,
    onTabSelected: select, children: pages)
```

Guides: [operations and skeleton](OPERATION_LOADING.md),
[shapes and renderers](SHAPE_ENGINE.md), [tabs](TABS.md),
[visual and interaction fixes](R3_VISUAL_FIXES.md) (connected groups, FAB menu,
submenus, semantics).

## Compatibility

* **Kept:** all 0.7.x public API, the polygon types and the dependency re-exports
  (`FluentIcons`, `MorphIcons`). `MorphDropdownMotionStyle.legacy`, the original
  geometry at intensity 0 and `MorphTabTheme.indicatorSpring` remain.
* **Themes:** `MorphThemeData` has two new fields, `asyncButtonTheme` and
  `skeletonTheme`; both are part of `copyWith`.
* **Loading indicator:** `shapes`, `renderer` (default Canvas) and `containedInset`
  (theme default 5) are new; the default sequence is unchanged.
* **Tabs theme:** the field `indicatorVerticalInset` never shipped in 0.7.x; use
  `indicatorSurfaceInset`.

## Modern implementation and renderer

There is no modern/legacy switch for components. Where a choice exists it is
explicit and local: `MorphShapeRenderer` (`canvas`, `shader`, `auto`) on shape
views, loaders, FAB menu, async button, skeleton and tabs; the dropdown
`motionStyle`; and `organicStretchIntensity` (0 = original).

| Piece | Shader | Canvas / other |
| --- | --- | --- |
| `MorphShapeView`, loaders, `MorphShapeButton` | Restricted procedural ellipse | Everything else; sampled edge coverage |
| FAB menu surface, tabs indicator, async button surface | Rounded rectangle (`morph_rrect`) with uniform radii | Fallback while loading, on failure, with gradients, and with asymmetric radii |
| Skeleton shimmer | Fragment shimmer per placeholder | Canvas / static / pulse |
| Sliders, progress, buttons (splash), swipe actions | – | Canvas with offscreen smoothing (`MorphSmoothEdges`) on desktop Linux; direct elsewhere |

`auto` never promises a backend; read the effective renderer through
`onRendererChanged`.

## Verified and not verified

Verified by automated tests and by running the Linux (Impeller OpenGLES) and Web
(Chromium) previews: see [RELEASE_0_8_0.md](RELEASE_0_8_0.md). Not measured: GPU
cost or frame rate on any device, other backends, DPRs or platforms, and real
haptics. Not included: the general migration of defaults, refresh indicator
changes and a continuous page indicator.
