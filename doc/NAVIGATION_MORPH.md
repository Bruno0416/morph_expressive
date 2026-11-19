# Morph navigation and onboarding indicators

This guide describes the navigation APIs of Morph Expressive 0.6.1.
When migrating from 0.5.0 you must update `Widget` destinations to `IconData`
and review the `.morph()` / `.expressive()` constructors, whose visual
assignment was corrected in 0.6.0.
The unnamed constructor keeps the standard Material selection. The named
variants require no new dependencies.

## Selection that travels between destinations

Use `MorphNavigationBar.expressive` for the Material 3 elastic pill, and
`MorphNavigationRail.morph` / `MorphNavigationDrawer.morph` for the same
shared selection in the rail/drawer. `MorphNavigationBar.morph`, in contrast,
has a top line that travels between the destinations. Both named variants
keep `motion: MorphNavigationMotion.morph`; the unnamed constructor keeps its
standard behavior. You can change the `motion` field dynamically if you need
direct control.

A single figure travels through the real destination positions. The leading
edge starts immediately and the trailing one uses `selectionDelay` (60 ms
horizontal / 20 ms vertical by default) before following it with Motor. Rapid
changes cancel the previous delay; reduced motion aligns all edges without
waiting. Icons, labels, badges, keyboard, focus and callbacks are preserved;
the geometry is measured again for RTL, sections, variable width and text
scaling. Overlays capture the theme and the local preference, and update the
external selection.

The rail now has 48 px expanded destinations (previously 56), a 48 px
indicator, 60 px collapsed destinations with a label and a 6 px gap. Targets
never go below 48 px. All of these values remain customizable with
`MorphNavigationRailTheme` (`itemExpandedHeight`, `itemCollapsedHeight`,
`shortItemHeight`, `expandedIndicatorHeight`, `expandedItemGap`,
`itemVerticalGap`, etc.).

## Icons as `IconData` and compact size

`MorphNavigationBar` destinations now receive `IconData` directly. There is
no need to build an `Icon` manually; the bar resolves the color and the
`IconTheme` according to the selection state:

```dart
MorphNavigationBarDestination(
  icon: MorphIcons.home,
  selectedIcon: MorphIcons.search,
  label: 'Home',
)
```

If you need a fully custom icon, use `iconWidget` and `selectedIconWidget`
instead of `icon`/`selectedIcon`; do not mix both modes in the same property.
Badges still wrap the icon.

The base icon size is configured through `iconSize`, available for
`MorphNavigationBar()`, `.expressive()` and `.morph()`. The relative scale
`unselectedIconScale` lets you give more emphasis to the active destination,
without changing the touch geometry or the layout size:

```dart
MorphNavigationBar.morph(
  iconSize: 32,
  unselectedIconScale: 0.9, // 28.8 dp visual for inactive; 32 for active.
  destinations: destinations,
)
```

`unselectedIconScale: 1.0` (default) keeps the same visual size for selected
and inactive. Values above `1.0` enlarge the inactive ones. When the
selection changes, the size is interpolated by the existing spring, honoring
the reduced-motion preference. Custom icons (`iconWidget`) are also scaled
when painted, although `iconSize` is applied through the icon theme and
depends on the widget respecting it.

The `.expressive()` variant keeps **64 dp** by default. In `.morph()`, the
compact height is **76 dp** to separate the top indicator from the 32 dp
icon; the content shifts slightly downward by a value limited by `clamp`
according to the real height. Both accept `size: MorphNavBarSize.medium`
(**80 dp** base, adjustable by the content). The standard constructor
`MorphNavigationBar()` keeps **80 dp** by default, and `safeArea` still
respects the system navigation area when the bar is docked.

## Destination distribution in `wide`

By default the `MorphNavBarLayout.wide` destinations are grouped in the
center (or at the end chosen through `alignment`). To visually fill the full
width with equidistant centers, use `distributeWideDestinations: true`:

```dart
MorphNavigationBar.expressive(
  autoLayout: false,
  layout: MorphNavBarLayout.wide,
  distributeWideDestinations: true,
  destinations: destinations,
)
```

The parameter works equally in the standard and `.morph()` constructors, when
the resolved layout is `wide`. It does not alter the compact layout, it keeps
the indicator/pill width and the destinations remain accessible. With the
even distribution `alignment` is ignored; to return to the previous grouping
just use `distributeWideDestinations: false` (the default).

## Pull-to-refresh with nested scrolling (since 0.6.1)

Starting with **0.6.1**, `MorphNavigationBarHost` keeps `onRefresh` as the
only API needed both for a simple list and for a `NestedScrollView` with tabs
(`PageView`) and inner vertical lists (`CustomScrollView`). The host selects a
single vertical source per drag, using the notification's context instead of
assuming that all content reports `depth == 0`. Horizontal gestures do not
take part in refresh recognition.

If the host has a `ScrollController` connected to the outer scroll, it only
lets a refresh start when that scroll is also at its start edge: it must not
refresh while a collapsible header is still retracted. The floating bar, the
glass and the return to top remain independent.

The bar's visibility also observes nested vertical scrollables, independently
of refresh. During a diagonal drag, an effective vertical movement can hide or
reveal the bar even if the gesture has a horizontal component. Swipes that the
`PageView` recognizes as horizontal do not hide it, and the single-source
selection avoids adding twice the displacements emitted by the parent and the
child scroll.

For the global start-edge check to work with collapsible headers, connect the
`controller` received in `body` to the outer `NestedScrollView` (or provide an
equivalent one through `scrollController`). The `PageView` can keep its inner
lists and the appropriate scrolling physics. The refresh filter and the
visibility logic are independent: the bar can hide on a diagonal gesture even
if refresh is not enabled. If the user switches tabs and `onRefresh` becomes
`null`, the host stops building the indicator.

The host does not impose a vertical scroll when Flutter interprets the
gesture as horizontal: a pure page change neither refreshes nor hides the bar.

```dart
MorphNavigationBarHost(
  onRefresh: () => reloadHome(),
  bar: MorphNavigationBar.morph(
    floating: true,
    destinations: destinations,
  ),
  body: (context, controller, padding) => NestedScrollView(
    controller: controller,
    headerSliverBuilder: (context, _) => headerSlivers,
    body: PageView(children: catalogTabs),
  ),
)
```

If the content is too short to scroll, configure
`AlwaysScrollableScrollPhysics` on the corresponding vertical list. The host
creates no indicator when `onRefresh` is `null`. For pages with nested
scrolling, tests should perform a real drag and verify that the callback
awaits its `Future`, instead of only checking that the widget is present.

## Bar with a top indicator

```dart
MorphNavigationBar.morph(
  selectedIndex: selected,
  onDestinationSelected: select,
  destinations: destinations,
  topIndicatorWidth: 40,
  topIndicatorHeight: 4,
)
```

It shows a sliding top bar, the active icon and the selected label. It uses a
compact layout even on wide screens. `iconSize` (32 by default in `.morph`)
and `labelStyle` let you adjust icons and typography. `labelBehavior` lets you
show all labels or hide them. By default it takes the full width and includes
the bottom safe area. It can be used in `Scaffold.bottomNavigationBar`.

`floating: true` rounds the container and leaves the safe area to the outer
host. The native host layers the content and the bar, reserves space for the
last row and observes vertical scrolling without consuming its notifications:

```dart
MorphNavigationBarHost(
  bar: MorphNavigationBar.morph(
    floating: true,
    selectedIndex: selected,
    onDestinationSelected: select,
    destinations: destinations,
    glass: const MorphNavigationGlass(
      blurX: 8,
      blurY: 8,
      tintOpacity: 0.65,
      tint: Color(0xFF19191C),
      borderColor: Color(0x33FFFFFF),
      borderWidth: 1,
    ),
  ),
  onRefresh: reload,
  body: (context, controller, contentPadding) => ListView.builder(
    controller: controller,
    padding: contentPadding,
    physics: const AlwaysScrollableScrollPhysics(),
    itemCount: items.length,
    itemBuilder: (context, index) => buildItem(items[index]),
  ),
)
```

Apply `contentPadding` to the scrollable content, not to an outer Padding:
this way the background continues under the glass. If you use an external
controller, its owner disposes of it; the host only disposes of the controller
it creates internally.

When scrolling down, the floating bar hides after `scrollThreshold` px; when
scrolling up or reaching the start it reappears. `showOnScrollEnd` lets it
show when scrolling stops. `hideOnScroll: false` keeps it visible. The docked
state stays visible. `showBackToTop` enables the return-to-top action;
`backToTopIcon` and `backToTopLabel` customize its icon and localized text.
The button shares the bar's horizontal center, even with asymmetric margins.
Use the builder's controller so the action can scroll the list. The host goes
in the Scaffold's body, with finite constraints, not in bottomNavigationBar.

**`MorphNavigationBarHost` works for any of the three designs:**
`MorphNavigationBar()` (standard MD3E), `.expressive()` (elastic pill) and
`.morph()` (top line). Just pass the desired constructor in `bar`;
`floating: true` enables the overlay on any of them. The `glass`
configuration is optional: without it the bar uses its normal surface but
keeps hide-on-scroll, return to top and refresh. No separate host is needed
for each design.

`onRefresh` integrates the existing MorphRefreshIndicator, awaits its Future
and keeps the bar visible during the reload. **If `onRefresh` is omitted or
`null`, the host does not create `MorphRefreshIndicator` or show its
animation**. `refreshController` allows a programmatic reload when `onRefresh`
exists. In `Scaffold(extendBodyBehindAppBar: true)` with a
`MorphAppBar.frosted`, the host automatically computes the `edgeOffset` to
show the spinner below the AppBar. For custom layouts you can set
`refreshIndicatorEdgeOffset` explicitly. With a normal opaque bar, without an
AppBar or without content behind it, the default offset (0) is kept.
Visibility animations use Motor and `visibilitySpring`.

`maxBarWidth`, `floatingMargin` and `floatingRadius` control size and
position. For glass on a docked bar placed in `Scaffold.bottomNavigationBar`,
use `Scaffold.extendBody: true` if you want the content to show behind the
glass. Without content behind it, the filter only blurs the Scaffold's
background.

The keyboard hides the floating presentation. With accessibleNavigation it
stays visible and with reduced motion the selection and visibility reach the
final state without a decorative trip; going back to the top uses jumpTo.

The host is inspired by the documented behavior of
[flutter_floating_bottom_bar](https://github.com/codenameakshay/flutter-floating-bottom-bar)
(scroll, overlaid bar and return to top). It is an original implementation;
it does not incorporate code from that dependency nor modify AnimatedNavBar
in WatchNext.

## Glass

`glass: null` keeps the normal background. `MorphNavigationGlass` allows X/Y
blur, tint, opacity, gradient, border and blendMode. The filter is always
clipped to the container. `opaqueInHighContrast` enables an opaque surface when
the system requests high contrast. The tint and content colors must be chosen
with enough contrast for the application's background.

In `MorphNavigationBarHost`, `blurDuringScroll: false` (default) suspends only
the blur while the content scrolls and restores it when it stops. Tint,
gradient, border and interaction remain available. Use
`blurDuringScroll: true` to keep the continuous blur. A bar without a host
always keeps the blur. This option avoids recomputing the moving background;
a `RepaintBoundary` alone does not freeze a backdrop that changes. The scroll
of a page containing the navbar does not control its filter: only the host's
internal scroll and the visibility state count. On Android/iOS,
`blurRevealProgress` (0.35 by default, range 0–1) lets the blur return during
the appearance without waiting for the end of the spring; Web keeps a more
conservative policy. `webBackdropBlur: false` opts for a tint without real
blur on Web only. In all cases the blur stays clipped and separated from the
icons and the animated indicators.

The host hides the bar by translation, without an opacity layer over the
filter. When it finishes hiding, it is not painted and its tickers are
suspended; its selection state is preserved. The demo uses real blur of sigma
5 on Web and 10 on native, and local state so that a reload does not rebuild
the whole gallery.

To test pull-to-refresh in the preview, go back to the first item and drag
down with the left button or a touch gesture; release when the indicator is
fully revealed. The wheel alone does not trigger a reload. The demo waits
650 ms and then increments the counter of its rows. Its scroll explicitly
accepts the mouse and uses clamping physics.

## Page indicator

```dart
MorphPageIndicator(
  count: 3,
  selectedIndex: page,
  activeWidth: 40,
  inactiveWidth: 16,
  height: 16,
  spacing: 6,
  onPageSelected: (index) {
    if (MorphMotion.reduceMotionOf(context)) {
      pageController.jumpToPage(index);
    } else {
      pageController.animateToPage(
        index,
        duration: MorphMotion.medium2,
        curve: MorphMotion.standard,
      );
    }
  },
)
```

| Result | Configuration |
| --- | --- |
| Equal pills | activeWidth and inactiveWidth equal |
| Wide active capsule | activeWidth larger, inactiveHeight omitted |
| Growing dots | effect expand and inactiveHeight smaller than height |
| Fixed-size slots | effect slide |
| Information only | onPageSelected omitted |

The default effect is expand. The accessible semantic targets keep 48x48
without changing the visual distance between dots, which is determined by
`spacing`. The selected state is always announced. `semanticLabelBuilder`
allows custom texts; by default the Material localization is used.
`activeColor`, `inactiveColor` and `spring` customize its appearance.

`selectedIndex` is controlled by the application; the callback requests the
change. The widget does not assume ownership of a PageController. If the
change navigates a PageView, also apply the reduced-motion preference to that
PageView.

## Verification

```bash
flutter test test/navigation_morph_test.dart test/page_indicator_test.dart
flutter test --dart-define=MORPH_MOTION_AUDIT_PROFILE=reduced \
  test/navigation_morph_test.dart test/page_indicator_test.dart
flutter test --dart-define=MORPH_MOTION_AUDIT_PROFILE=reduce-only \
  test/navigation_morph_test.dart test/page_indicator_test.dart
```

The gallery shows standard navigation, the Expressive pill, Morph with a top
line and a floating bar with glass and reload, plus four page indicator
configurations.

Floating bar regressions are checked with
`flutter test test/navigation_refinement_test.dart` and
`(cd preview && flutter test test/floating_navigation_sample_test.dart)`.

## Navigation GIFs

- `navigation.gif` (0.8.0): Morph-only variants — the `.expressive` pill, the
  `.morph` line and the `expand` and `slide` effects of `MorphPageIndicator`.
  It replaces the standard MD3E scene and the old `navigation_morph`, which
  was retired to avoid duplicated content.
- `navigation_rail_drawer.gif`: independent selection transitions in
  `MorphNavigationRail.morph` and `MorphNavigationDrawer.morph`, with the
  organic stretch (`organicStretchIntensity` 0.40). Regenerated with the 0.8.0
  code at 50 fps; the capture checks outside the image that the stretch uses
  the Shader and fails if it falls back to Canvas. It is kept only for this
  guide; it is not part of the README GIFs or the pub.dev gallery.

To capture them again, from the root:

```bash
bash tool/generate_component_gifs.sh --only navigation
bash tool/generate_component_gifs.sh --only navigation_rail_drawer
python3 tool/check_gif_branding.py
```

Generation requires Flutter Web, Chromium/Playwright and FFmpeg; see
[PREVIEW.md](PREVIEW.md).

## Compact indicators and native gradient AppBar

`MorphPageIndicator.spacing` now defines the **visual distance between
capsules**, even when `onPageSelected` is configured. The interactive
destinations keep 48×48 accessible nodes through a separate layer; gestures
pick the nearest destination so they do not intercept each other on compact
tracks. `slide` and `expand` remain compatible with RTL, keyboard and reduced
motion.

For a translucent top AppBar, use `MorphAppBar.frosted` with the content
**behind** the bar (`extendBodyBehindAppBar: true`):

```dart
Scaffold(
  extendBodyBehindAppBar: true,
  appBar: MorphAppBar.frosted(
    titleText: 'Explore',
    glass: const MorphAppBarGlass(
      topOpacity: 0.90,   // 90% at the top, 0% at the bottom edge
      maxBlurSigma: 16,   // maximum blur at the top
      blurBands: 7,       // six progressive filters
      tintCurvePower: 0.38,
      blurCurvePower: 1.8,
      blurClearExtent: 4, // 4 logical pixels without blur at the bottom
    ),
  ),
  body: ListView.builder(
    itemCount: 40,
    itemBuilder: (context, index) => ListTile(title: Text('Item $index')),
  ),
)
```

The tint is continuous: it starts at **0% at the bottom edge**, grows
**linearly up to the middle** (≈26% opacity) and then accelerates through an
exponential curve up to **90% at the top** (`topOpacity`). The transition
keeps a continuous slope at the midpoint. The gradient uses 65 samples to
represent that progression accurately. The blur starts at **0 sigma at the
bottom** for `blurClearExtent` logical pixels (4 by default). Just above, small
bands of almost-zero sigma appear; the bands progressively increase in height
and strength going up. `blurBands - 1` filters are kept, with no additional
listeners or animations on the blur. It is a band-based approximation, not a
continuous per-pixel blur shader.

To adjust the curves without changing the extremes: `tintCurvePower` controls
the acceleration of the upper half of the tint and `blurCurvePower > 1`
reduces the jump between the sharp zone and the first blur band.
`blurClearExtent` leaves the bottom edge free of blur (only the blur: the tint
still reaches zero). The number of filters is `blurBands - 1`; for slow
devices you can use `blurBands: 5`.
`topOpacity` defines opacity, not a percentage of transparency. If you prefer
~75% top transparency, use `topOpacity: 0.25`; it may be necessary to raise
the blur to guarantee title contrast. A higher number of `blurBands` improves
the progression but increases the rendering cost.

This variant targets **Android/iOS** to evaluate native performance. In the
mobile preview, open **Gradient AppBar + page indicator** in Touch Lab: the
scenario combines the frosted AppBar, the floating Morph navbar, the compact
dots and pull-to-refresh with automatic offset.
From `preview/`, use `flutter run -t lib/main_mobile.dart` and choose your
connected device. The Flutter Web engine also works, but several
`BackdropFilter`s can be expensive when the background scrolls.
