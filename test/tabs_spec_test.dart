import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morph_expressive/components/badges/components/morph_badge_layout.dart';
import 'package:morph_expressive/morph_components.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  setUp(MorphFocusInteraction.resetForTest);

  testWidgets('primary label bar is 48 and icon plus label is 64', _heights);
  testWidgets('secondary icon leads the label in a 48 bar', _secondaryIcon);
  testWidgets('secondary badge stays after the label', _secondaryBadge);
  testWidgets('divider is outline variant inside a level 0 bar', _divider);
  testWidgets('arrow moves focus and enter selects', _keyboard);
  testWidgets('pointer tap dismisses the focus ring', _pointerDismissesRing);
  testWidgets('scrollable tabs start 52 from the leading edge', _scrollOffset);
  testWidgets('controller select reports the index', _controller);
  testWidgets('a swipe in the view selects the next tab', _swipeView);
  testWidgets('sliver tabs scroll away', _sliver);
  testWidgets('stacked primary badge stays inside the bar', _badgeInsideBar);
  testWidgets('scroll-away list sits in the same scroll view', _scrollAwayList);
}

Future<void> _heights(WidgetTester tester) async {
  await tester.pumpWidget(
    _bar(const <MorphTab>[MorphTab(label: 'A'), MorphTab(label: 'B')]),
  );
  await tester.pumpAndSettle();
  expect(tester.getSize(find.byType(MorphTabs)).height, 48);

  await tester.pumpWidget(
    _bar(const <MorphTab>[
      MorphTab(label: 'A', icon: Icon(MorphIcons.home)),
      MorphTab(label: 'B', icon: Icon(MorphIcons.star_outline)),
    ]),
  );
  await tester.pumpAndSettle();
  expect(tester.getSize(find.byType(MorphTabs)).height, 64);
}

Future<void> _secondaryIcon(WidgetTester tester) async {
  await tester.pumpWidget(
    _bar(const <MorphTab>[
      MorphTab(label: 'A', icon: Icon(MorphIcons.home)),
      MorphTab(label: 'B'),
    ], variant: MorphTabsVariant.secondary),
  );
  await tester.pumpAndSettle();
  expect(tester.getSize(find.byType(MorphTabs)).height, 48);
  expect(
    tester.getTopLeft(find.byIcon(MorphIcons.home)).dx,
    lessThan(tester.getTopLeft(find.text('A')).dx),
  );
}

Future<void> _secondaryBadge(WidgetTester tester) async {
  await tester.pumpWidget(
    _bar(const <MorphTab>[
      MorphTab(label: 'Overview', icon: Icon(MorphIcons.home), badgeCount: 2),
      MorphTab(label: 'Specs'),
    ], variant: MorphTabsVariant.secondary),
  );
  await tester.pumpAndSettle();
  expect(
    tester.getTopLeft(find.byIcon(MorphIcons.home)).dx,
    lessThan(tester.getTopLeft(find.text('Overview')).dx),
  );
  expect(
    tester.getTopLeft(find.text('Overview')).dx,
    lessThan(tester.getTopLeft(find.text('2')).dx),
  );
}

Future<void> _divider(WidgetTester tester) async {
  await tester.pumpWidget(
    _bar(const <MorphTab>[MorphTab(label: 'A'), MorphTab(label: 'B')]),
  );
  await tester.pumpAndSettle();
  final Material material = tester.widget<Material>(
    find
        .descendant(of: find.byType(MorphTabs), matching: find.byType(Material))
        .first,
  );
  final MorphColorScheme scheme = MorphTheme.of(
    tester.element(find.byType(MorphTabs)),
  ).colorScheme;
  expect(material.elevation, 0);
  expect(material.color, scheme.surface);
  final ColoredBox divider = tester.widget<ColoredBox>(
    find
        .descendant(of: find.byType(MorphTabs), matching: find.byType(ColoredBox))
        .first,
  );
  expect(divider.color, scheme.outlineVariant);
  expect(tester.getSize(find.byWidget(divider)).height, 1);
}

Future<void> _keyboard(WidgetTester tester) async {
  var selected = 0;
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return MorphTabs(
              selectedIndex: selected,
              onTabSelected: (int index) => setState(() => selected = index),
              tabs: const <MorphTab>[
                MorphTab(label: 'One'),
                MorphTab(label: 'Two'),
                MorphTab(label: 'Three'),
              ],
            );
          },
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  await tester.sendKeyDownEvent(LogicalKeyboardKey.tab);
  await tester.pump();
  await tester.sendKeyUpEvent(LogicalKeyboardKey.tab);
  await tester.sendKeyDownEvent(LogicalKeyboardKey.arrowRight);
  await tester.pump();
  await tester.sendKeyUpEvent(LogicalKeyboardKey.arrowRight);
  expect(selected, 0);
  await tester.sendKeyDownEvent(LogicalKeyboardKey.enter);
  await tester.pump();
  await tester.sendKeyUpEvent(LogicalKeyboardKey.enter);
  await tester.pump(const Duration(milliseconds: 150));
  expect(selected, 1);
}

Future<void> _pointerDismissesRing(WidgetTester tester) async {
  await tester.pumpWidget(
    _bar(const <MorphTab>[MorphTab(label: 'A'), MorphTab(label: 'B')]),
  );
  await tester.pumpAndSettle();
  await tester.sendKeyDownEvent(LogicalKeyboardKey.tab);
  await tester.pump();
  expect(MorphFocusInteraction.instance.ringsAllowed, isTrue);
  await tester.sendKeyUpEvent(LogicalKeyboardKey.tab);
  await tester.tap(find.text('A'));
  await tester.pump();
  expect(MorphFocusInteraction.instance.ringsAllowed, isFalse);
}

Future<void> _scrollOffset(WidgetTester tester) async {
  await tester.pumpWidget(
    _bar(const <MorphTab>[
      MorphTab(label: 'Overview'),
      MorphTab(label: 'Specs'),
      MorphTab(label: 'Reviews'),
    ], scrollable: true),
  );
  await tester.pumpAndSettle();
  expect(tester.getTopLeft(find.text('Overview')).dx, greaterThanOrEqualTo(52));
}

Future<void> _controller(WidgetTester tester) async {
  final controller = MorphTabsController();
  addTearDown(controller.dispose);
  var selected = 0;
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return MorphTabs(
              controller: controller,
              selectedIndex: selected,
              onTabSelected: (int index) => setState(() => selected = index),
              tabs: const <MorphTab>[
                MorphTab(label: 'A'),
                MorphTab(label: 'B'),
              ],
            );
          },
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  controller.select(1);
  await tester.pump();
  expect(selected, 1);
  expect(controller.index, 1);
}

Future<void> _swipeView(WidgetTester tester) async {
  var selected = 0;
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return MorphTabsView(
              selectedIndex: selected,
              onTabSelected: (int index) => setState(() => selected = index),
              children: const <Widget>[Text('First'), Text('Second')],
            );
          },
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  await tester.drag(find.byType(PageView), const Offset(-400, 0));
  await tester.pumpAndSettle();
  expect(selected, 1);
}

Future<void> _sliver(WidgetTester tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: CustomScrollView(
          slivers: <Widget>[
            MorphTabs.sliver(
              selectedIndex: 0,
              onTabSelected: (_) {},
              tabs: const <MorphTab>[
                MorphTab(label: 'Alpha'),
                MorphTab(label: 'Beta'),
              ],
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 2000)),
          ],
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  final Finder alpha = find.text('Alpha');
  final double before = tester.getTopLeft(alpha).dy;
  await tester.drag(find.byType(CustomScrollView), const Offset(0, -400));
  await tester.pumpAndSettle();
  expect(
    tester.getTopLeft(find.text('Alpha', skipOffstage: false)).dy,
    lessThan(before),
  );
  await tester.drag(find.byType(CustomScrollView), const Offset(0, 400));
  await tester.pumpAndSettle();
  expect(find.text('Alpha'), findsOneWidget);
}

Future<void> _badgeInsideBar(WidgetTester tester) async {
  await tester.pumpWidget(
    _bar(const <MorphTab>[
      MorphTab(label: 'Overview', icon: Icon(MorphIcons.home), badgeCount: 2),
      MorphTab(label: 'Specs', icon: Icon(MorphIcons.tune)),
    ]),
  );
  await tester.pumpAndSettle();
  final RenderMorphBadgeLayout badge = tester.renderObject<RenderMorphBadgeLayout>(
    find.byType(MorphBadgeLayout),
  );
  final RenderBox content = badge.firstChild!;
  final RenderBox indicator = badge.childAfter(content)!;
  final data = indicator.parentData! as MorphBadgeLayoutParentData;
  final Offset topLeft = badge.localToGlobal(data.offset);
  final RenderBox bar = tester.renderObject<RenderBox>(find.byType(MorphTabs));
  final Offset barTop = bar.localToGlobal(Offset.zero);
  expect(topLeft.dy, greaterThanOrEqualTo(barTop.dy - 0.01));
  expect(
    topLeft.dy + indicator.size.height,
    lessThanOrEqualTo(barTop.dy + bar.size.height + 0.01),
  );
  expect(
    tester.getTopLeft(find.text('Overview')).dy,
    tester.getTopLeft(find.text('Specs')).dy,
  );
  final Offset iconTop = tester.getTopLeft(find.byIcon(MorphIcons.home));
  final Size iconSize = tester.getSize(find.byIcon(MorphIcons.home));
  expect(topLeft.dy, lessThan(iconTop.dy + iconSize.height));
  expect(topLeft.dy + indicator.size.height, greaterThan(iconTop.dy));
}

Future<void> _scrollAwayList(WidgetTester tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: CustomScrollView(
          slivers: <Widget>[
            const MorphAppBar.sliver(
              variant: MorphAppBarVariant.small,
              pinned: false,
              titleText: 'Overview',
            ),
            SliverToBoxAdapter(
              child: MorphTabs(
                selectedIndex: 0,
                onTabSelected: (_) {},
                tabs: const <MorphTab>[
                  MorphTab(label: 'Overview'),
                  MorphTab(label: 'Specs'),
                ],
              ),
            ),
            const SliverPadding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 24),
              sliver: SliverToBoxAdapter(
                child: MorphList(itemCount: 3, itemBuilder: _scrollAwayItem),
              ),
            ),
          ],
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  expect(find.text('Item 1'), findsOneWidget);
}

Widget _scrollAwayItem(BuildContext context, int index) {
  return MorphListItem(headline: 'Item ${index + 1}');
}

Widget _bar(
  List<MorphTab> tabs, {
  MorphTabsVariant variant = MorphTabsVariant.primary,
  bool? scrollable,
}) {
  return MaterialApp(
    home: Scaffold(
      body: MorphTabs(
        variant: variant,
        scrollable: scrollable,
        selectedIndex: 0,
        onTabSelected: (_) {},
        tabs: tabs,
      ),
    ),
  );
}
