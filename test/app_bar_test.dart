import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morph_expressive/morph_components.dart';
import 'package:material_ui/material_ui.dart';

import 'helpers/app_bar_test_helpers.dart';

const String _custom = 'Custom';
const String _compact = 'Compact';
const String _large = 'Large';

void main() {
  testWidgets(
    'MorphAppBar.top does not imply a back button without leading',
    _morphappbarTopDoesNotImplyABackButtonWithoutLeading,
  );
  testWidgets(
    'MorphAppBar.top shows an explicit leading widget',
    _morphappbarTopShowsAnExplicitLeadingWidget,
  );
  testWidgets(
    'MorphAppBar.top honours a custom title widget and actions',
    _morphappbarTopHonoursACustomTitleWidgetAndActions,
  );
  testWidgets(
    'compact density reduces the bar height',
    _compactDensityReducesTheBarHeight,
  );
  testWidgets(
    'regular content band is 64 and sits below the status bar',
    _regularContentBandSitsBelowTheStatusBar,
  );
  testWidgets(
    'flexible and baseline slivers use spec content heights',
    _flexibleAndBaselineSliversUseSpecContentHeights,
  );
  testWidgets(
    'controller collapses and hides the sliver',
    _controllerCollapsesAndHidesTheSliver,
  );
  testWidgets(
    'MorphAppBar.sliver renders an expanded large title',
    _morphappbarSliverRendersAnExpandedLargeTitle,
  );
  testWidgets(
    'MorphAppBar.search fills title slot and opens the search view',
    _morphappbarSearchFillsTitleSlotAndOpensTheSearchView,
  );
  testWidgets(
    'expanded title sits below the action row and returns when collapsed',
    _expandedTitleSitsBelowTheActionRowAndReturnsWhenCollapsed,
  );
  testWidgets(
    'entire hide slides the bar away and actions hide keeps the icons',
    _entireHideSlidesTheBarAwayAndActionsHideKeepsTheIcons,
  );
  testWidgets(
    'a title with no leading control starts 16 in',
    _titleWithNoLeadingControlStarts16In,
  );
  testWidgets(
    'centered title stays centered without a leading control',
    _centeredTitleStaysCenteredWithoutLeading,
  );
  testWidgets('search pill has no elevation', _searchPillHasNoElevation);
}

Future<void> _morphappbarTopDoesNotImplyABackButtonWithoutLeading(
  WidgetTester tester,
) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Builder(
        builder: (BuildContext context) {
          return Scaffold(
            appBar: const MorphAppBar.top(titleText: appBarInboxTitle),
            body: Center(
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (BuildContext context) {
                        return const Scaffold(
                          appBar: MorphAppBar.top(titleText: 'Details'),
                          body: SizedBox.shrink(),
                        );
                      },
                    ),
                  );
                },
                child: const Text('Open'),
              ),
            ),
          );
        },
      ),
    ),
  );

  await tester.tap(find.text('Open'));
  await tester.pumpAndSettle();

  expect(find.text('Details'), findsOneWidget);
  expect(find.byTooltip('Back'), findsNothing);
  expect(find.byType(BackButtonIcon), findsNothing);
}

Future<void> _morphappbarTopShowsAnExplicitLeadingWidget(
  WidgetTester tester,
) async {
  await tester.pumpWidget(
    hostAppBar(
      const MorphAppBar.top(
        titleText: appBarInboxTitle,
        leading: Icon(MorphIcons.menu),
      ),
    ),
  );

  expect(find.byIcon(MorphIcons.menu), findsOneWidget);
}

Future<void> _morphappbarTopHonoursACustomTitleWidgetAndActions(
  WidgetTester tester,
) async {
  await tester.pumpWidget(
    hostAppBar(
      const MorphAppBar.top(
        title: Text(_custom),
        actions: <Widget>[Icon(MorphIcons.search)],
      ),
    ),
  );

  expect(find.text(_custom), findsOneWidget);
  expect(find.byIcon(MorphIcons.search), findsOneWidget);
}

Future<void> _compactDensityReducesTheBarHeight(WidgetTester tester) async {
  await tester.pumpWidget(
    hostAppBar(
      const MorphAppBar.top(
        titleText: _compact,
        density: MorphAppBarDensity.compact,
      ),
    ),
  );

  final box = tester.getSize(
    find
        .descendant(
          of: find.byType(MorphAppBar),
          matching: find.byType(SizedBox),
        )
        .first,
  );
  expect(box.height, 56);
}

Future<void> _regularContentBandSitsBelowTheStatusBar(
  WidgetTester tester,
) async {
  tester.view.devicePixelRatio = 1;
  tester.view.viewPadding = const FakeViewPadding(top: 24);
  tester.view.padding = const FakeViewPadding(top: 24);
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MorphMaterialApp(
      data: MorphThemeData.light(),
      home: const Scaffold(
        appBar: MorphAppBar.top(titleText: appBarInboxTitle),
        body: SizedBox.expand(),
      ),
    ),
  );

  final Size band = tester.getSize(
    find
        .descendant(
          of: find.byType(MorphAppBar),
          matching: find.byType(SizedBox),
        )
        .first,
  );
  expect(band.height, 64);
  expect(tester.getSize(find.byType(MorphAppBar)).height, 88);
  expect(
    tester.getTopLeft(find.text(appBarInboxTitle)).dy,
    greaterThanOrEqualTo(24),
  );
}

Future<double> _sliverExtent(
  WidgetTester tester, {
  required MorphAppBarVariant variant,
  String? subtitleText,
}) async {
  await tester.pumpWidget(
    hostAppBar(
      CustomScrollView(
        slivers: <Widget>[
          MorphAppBar.sliver(
            titleText: appBarInboxTitle,
            subtitleText: subtitleText,
            variant: variant,
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 2400)),
        ],
      ),
    ),
  );
  await tester.pumpAndSettle();
  final RenderSliver sliver = tester.renderObject<RenderSliver>(
    find.byType(MorphAppBar),
  );
  return sliver.geometry!.maxPaintExtent;
}

Future<void> _flexibleAndBaselineSliversUseSpecContentHeights(
  WidgetTester tester,
) async {
  expect(
    await _sliverExtent(tester, variant: MorphAppBarVariant.mediumFlexible),
    112,
  );
  expect(
    await _sliverExtent(
      tester,
      variant: MorphAppBarVariant.mediumFlexible,
      subtitleText: 'New messages',
    ),
    136,
  );
  expect(
    await _sliverExtent(tester, variant: MorphAppBarVariant.largeFlexible),
    120,
  );
  expect(
    await _sliverExtent(
      tester,
      variant: MorphAppBarVariant.largeFlexible,
      subtitleText: 'New messages',
    ),
    152,
  );
  expect(await _sliverExtent(tester, variant: MorphAppBarVariant.medium), 112);
  expect(
    await _sliverExtent(
      tester,
      variant: MorphAppBarVariant.medium,
      subtitleText: 'New messages',
    ),
    136,
  );
  expect(await _sliverExtent(tester, variant: MorphAppBarVariant.large), 152);
  expect(
    await _sliverExtent(
      tester,
      variant: MorphAppBarVariant.large,
      subtitleText: 'New messages',
    ),
    184,
  );
}

Future<void> _controllerCollapsesAndHidesTheSliver(WidgetTester tester) async {
  final controller = MorphAppBarController();
  addTearDown(controller.dispose);

  await tester.pumpWidget(
    hostAppBar(
      CustomScrollView(
        slivers: <Widget>[
          MorphAppBar.sliver(
            controller: controller,
            titleText: appBarInboxTitle,
            variant: MorphAppBarVariant.mediumFlexible,
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 4000)),
        ],
      ),
    ),
  );
  await tester.pumpAndSettle();
  expect(controller.isCollapsed, isFalse);
  expect(controller.isVisible, isTrue);

  final Future<void> collapsing = controller.collapse();
  await tester.pumpAndSettle();
  await collapsing;
  expect(controller.isCollapsed, isTrue);

  final Future<void> expanding = controller.expand();
  await tester.pumpAndSettle();
  await expanding;
  expect(controller.isCollapsed, isFalse);

  final Future<void> hiding = controller.hide();
  await tester.pumpAndSettle();
  await hiding;
  expect(controller.isVisible, isFalse);

  final Future<void> showing = controller.show();
  await tester.pumpAndSettle();
  await showing;
  expect(controller.isVisible, isTrue);
}

Future<void> _morphappbarSliverRendersAnExpandedLargeTitle(
  WidgetTester tester,
) async {
  await tester.pumpWidget(
    hostAppBar(
      CustomScrollView(
        slivers: <Widget>[
          const MorphAppBar.sliver(
            titleText: _large,
            variant: MorphAppBarVariant.large,
          ),
          SliverList.list(
            children: <Widget>[
              for (int i = 0; i < 20; i++)
                SizedBox(height: 48, child: Text('row$i')),
            ],
          ),
        ],
      ),
    ),
  );
  await tester.pumpAndSettle();

  expect(find.text(_large), findsWidgets);
}

Future<void> _morphappbarSearchFillsTitleSlotAndOpensTheSearchView(
  WidgetTester tester,
) async {
  final controller = MorphSearchController();
  addTearDown(controller.dispose);

  await tester.pumpWidget(
    MorphMaterialApp(
      data: MorphThemeData.light(),
      home: Scaffold(
        appBar: MorphAppBar.search(
          searchController: controller,
          barHintText: 'Search',
          leading: const Icon(MorphIcons.menu),
          actions: const <Widget>[
            Icon(MorphIcons.tune),
            Icon(MorphIcons.account_circle),
          ],
          suggestionsBuilder: (BuildContext context, MorphSearchController c) {
            return const <Widget>[];
          },
        ),
        body: const SizedBox.shrink(),
      ),
    ),
  );

  expect(
    find.byWidgetPredicate(
      (Widget widget) =>
          widget is Text &&
          widget.data == 'Search' &&
          widget.overflow == TextOverflow.ellipsis,
    ),
    findsOneWidget,
  );
  expect(find.byIcon(MorphIcons.menu), findsOneWidget);
  expect(find.byIcon(MorphIcons.tune), findsOneWidget);

  final barBox = tester.getSize(find.byType(MorphSearchBar));
  final appBarBox = tester.getSize(find.byType(MorphAppBar));
  // Below max width the bar should occupy most of the toolbar (not min 360).
  expect(barBox.width, greaterThan(200));
  expect(barBox.width, lessThan(appBarBox.width));

  await tester.tap(find.byType(MorphSearchBar));
  await tester.pumpAndSettle();
  expect(controller.isOpen, isTrue);
}

Future<void> _expandedTitleSitsBelowTheActionRowAndReturnsWhenCollapsed(
  WidgetTester tester,
) async {
  await tester.pumpWidget(
    hostAppBar(
      const CustomScrollView(
        slivers: <Widget>[
          MorphAppBar.sliver(
            titleText: _large,
            variant: MorphAppBarVariant.large,
            leading: Icon(MorphIcons.menu),
          ),
          SliverToBoxAdapter(child: SizedBox(height: 2400)),
        ],
      ),
    ),
  );
  await tester.pumpAndSettle();

  final double iconTop = tester.getTopLeft(find.byIcon(MorphIcons.menu)).dy;
  final double expandedTop = tester.getTopLeft(find.text(_large)).dy;
  expect(expandedTop, greaterThan(iconTop + 24));

  tester.state<ScrollableState>(find.byType(Scrollable)).position.jumpTo(400);
  await tester.pump();

  final double collapsedTop = tester.getTopLeft(find.text(_large)).dy;
  expect(collapsedTop, lessThan(expandedTop - 24));
}

Future<void> _entireHideSlidesTheBarAwayAndActionsHideKeepsTheIcons(
  WidgetTester tester,
) async {
  await _entireHideSlidesTheBarAway(tester);
  await _actionsHideKeepsTheIconsVisible(tester);
}

Future<void> _entireHideSlidesTheBarAway(WidgetTester tester) async {
  await tester.pumpWidget(
    hostAppBar(
      const CustomScrollView(
        slivers: <Widget>[
          MorphAppBar.sliver(
            titleText: appBarInboxTitle,
            variant: MorphAppBarVariant.mediumFlexible,
            hideMode: MorphAppBarHideMode.entire,
            leading: Icon(MorphIcons.menu),
          ),
          SliverToBoxAdapter(child: SizedBox(height: 4000)),
        ],
      ),
    ),
  );
  await tester.pumpAndSettle();

  final double before = tester
      .renderObject<RenderSliver>(find.byType(MorphAppBar))
      .geometry!
      .paintExtent;
  expect(before, greaterThan(64));

  await tester.drag(find.byType(CustomScrollView), const Offset(0, -800));
  await tester.pumpAndSettle();

  final double after = tester
      .renderObject<RenderSliver>(find.byType(MorphAppBar, skipOffstage: false))
      .geometry!
      .paintExtent;
  expect(after, lessThan(1));

  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pumpAndSettle();
}

Future<void> _actionsHideKeepsTheIconsVisible(WidgetTester tester) async {
  await tester.pumpWidget(
    hostAppBar(
      const CustomScrollView(
        slivers: <Widget>[
          MorphAppBar.sliver(
            titleText: appBarInboxTitle,
            variant: MorphAppBarVariant.mediumFlexible,
            hideMode: MorphAppBarHideMode.actions,
            leading: Icon(MorphIcons.menu),
            actions: <Widget>[Icon(MorphIcons.search)],
          ),
          SliverToBoxAdapter(child: SizedBox(height: 4000)),
        ],
      ),
    ),
  );
  await tester.pumpAndSettle();

  await tester.drag(find.byType(CustomScrollView), const Offset(0, -800));
  await tester.pumpAndSettle();

  expect(find.byIcon(MorphIcons.menu), findsOneWidget);
  expect(find.byIcon(MorphIcons.search), findsOneWidget);
  final double iconTop = tester.getTopLeft(find.byIcon(MorphIcons.menu)).dy;
  expect(iconTop, lessThan(64));
  final SliverGeometry geometry = tester
      .renderObject<RenderSliver>(find.byType(MorphAppBar))
      .geometry!;
  expect(geometry.layoutExtent, lessThan(8));
  expect(geometry.paintExtent, greaterThan(48));
  expect(
    tester
        .renderObjectList<RenderClipRect>(
          find.descendant(
            of: find.byType(MorphAppBar),
            matching: find.byType(ClipRect),
          ),
        )
        .where((RenderClipRect clip) => clip.size.width > 100)
        .every((RenderClipRect clip) => clip.size.height < 8),
    isTrue,
  );
  expect(
    tester
        .getTopLeft(
          find.byWidgetPredicate(
            (Widget widget) => widget is SizedBox && widget.height == 4000,
          ),
        )
        .dy,
    lessThan(iconTop + 24),
  );

  final MorphColorScheme scheme = MorphTheme.of(
    tester.element(find.byType(MorphAppBar, skipOffstage: false)),
  ).colorScheme;
  expect(
    find.byWidgetPredicate((Widget widget) {
      if (widget is! DecoratedBox) {
        return false;
      }
      final Decoration decoration = widget.decoration;
      return decoration is BoxDecoration &&
          decoration.color == scheme.surfaceContainerHigh;
    }),
    findsWidgets,
  );
}

Future<void> _titleWithNoLeadingControlStarts16In(WidgetTester tester) async {
  await tester.pumpWidget(
    const MaterialApp(
      home: Scaffold(appBar: MorphAppBar.top(titleText: appBarInboxTitle)),
    ),
  );
  await tester.pumpAndSettle();

  final double dx = tester.getTopLeft(find.text(appBarInboxTitle)).dx;
  expect(dx, greaterThanOrEqualTo(16));
  expect(dx, lessThan(24));
}

Future<void> _centeredTitleStaysCenteredWithoutLeading(
  WidgetTester tester,
) async {
  await tester.pumpWidget(
    hostAppBar(
      const MorphAppBar.top(
        titleText: 'No leading',
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: <Widget>[Icon(MorphIcons.search)],
      ),
    ),
  );
  await tester.pumpAndSettle();
  final double titleX = tester.getCenter(find.text('No leading')).dx;
  final double barX = tester.getCenter(find.byType(MorphAppBar)).dx;
  expect((titleX - barX).abs(), lessThanOrEqualTo(1));
}

Future<void> _searchPillHasNoElevation(WidgetTester tester) async {
  final controller = MorphSearchController();
  addTearDown(controller.dispose);
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        appBar: MorphAppBar.search(
          searchController: controller,
          barHintText: 'Search',
          suggestionsBuilder: (BuildContext context, MorphSearchController c) {
            return const <Widget>[];
          },
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();

  final Material pill = tester.widget<Material>(
    find
        .descendant(
          of: find.byType(MorphSearchBar),
          matching: find.byType(Material),
        )
        .first,
  );
  expect(pill.elevation, 0);
}
