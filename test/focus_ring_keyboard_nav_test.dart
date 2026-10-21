import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morph_expressive/morph_components.dart';
import 'package:material_ui/material_ui.dart'
    show
        Center,
        Color,
        ColoredBox,
        Column,
        Expanded,
        FocusNode,
        Icon,
        Icons,
        ListView,
        MaterialApp,
        Offset,
        Scaffold,
        ScrollController,
        SizedBox,
        Text,
        Widget;

import 'focus_ring_test_support.dart';

void main() {
  setUp(setUpFocusRingTests);
  tearDown(tearDownFocusRingTests);

  registerFocusRingSinglePrimaryAmongButtonsTests();
  registerFocusRingPointerClearsTabResumesTests();
  registerFocusRingKeyboardScrollIntoViewTests();
  registerFocusRingNavBarKeyboardActivateTests();
  registerFocusRingPointerTapOnCardTests();
  registerFocusRingPointerOutsideClearsTests();
}

void registerFocusRingSinglePrimaryAmongButtonsTests() {
  testWidgets('only one primary focus ring among two buttons', (
    WidgetTester tester,
  ) async {
    final a = FocusNode(debugLabel: 'a');
    final b = FocusNode(debugLabel: 'b');
    addTearDown(a.dispose);
    addTearDown(b.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: MorphTheme(
          data: MorphThemeData.light(),
          child: Scaffold(
            body: Column(
              children: <Widget>[
                MorphButton.filled(
                  focusNode: a,
                  onPressed: () {},
                  child: const Text('A'),
                ),
                MorphButton.filled(
                  focusNode: b,
                  onPressed: () {},
                  child: const Text('B'),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    await tester.sendKeyDownEvent(LogicalKeyboardKey.tab);
    await tester.pumpAndSettle();
    expect(MorphFocusInteraction.instance.ringsAllowed, isTrue);
    expect(a.hasPrimaryFocus || b.hasPrimaryFocus, isTrue);
    expect(a.hasPrimaryFocus && b.hasPrimaryFocus, isFalse);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.tab);
  });
}

void registerFocusRingPointerClearsTabResumesTests() {
  testWidgets('pointer clears ring; Tab resumes from clicked button', (
    WidgetTester tester,
  ) async {
    final a = FocusNode(debugLabel: 'a');
    final b = FocusNode(debugLabel: 'b');
    final c = FocusNode(debugLabel: 'c');
    addTearDown(a.dispose);
    addTearDown(b.dispose);
    addTearDown(c.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: MorphTheme(
          data: MorphThemeData.light(),
          child: Scaffold(
            body: Column(
              children: <Widget>[
                MorphButton.filled(
                  focusNode: a,
                  onPressed: () {},
                  child: const Text('A'),
                ),
                MorphButton.filled(
                  focusNode: b,
                  onPressed: () {},
                  child: const Text('B'),
                ),
                MorphButton.filled(
                  focusNode: c,
                  onPressed: () {},
                  child: const Text('C'),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    await tester.sendKeyDownEvent(LogicalKeyboardKey.tab);
    await tester.pumpAndSettle();
    expect(MorphFocusInteraction.instance.ringsAllowed, isTrue);

    await tester.tap(find.text('B'));
    await tester.pumpAndSettle();
    expect(MorphFocusInteraction.instance.ringsAllowed, isFalse);
    expect(b.hasPrimaryFocus, isTrue);

    await tester.sendKeyDownEvent(LogicalKeyboardKey.tab);
    await tester.pumpAndSettle();
    expect(MorphFocusInteraction.instance.ringsAllowed, isTrue);
    expect(c.hasPrimaryFocus, isTrue);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.tab);
  });
}

void registerFocusRingKeyboardScrollIntoViewTests() {
  testWidgets('keyboard focus scrolls button into view', (
    WidgetTester tester,
  ) async {
    final top = FocusNode(debugLabel: 'top');
    final bottom = FocusNode(debugLabel: 'bottom');
    addTearDown(top.dispose);
    addTearDown(bottom.dispose);
    final scrollController = ScrollController();
    addTearDown(scrollController.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: MorphTheme(
          data: MorphThemeData.light(),
          child: Scaffold(
            body: SizedBox(
              height: 200,
              child: ListView(
                controller: scrollController,
                scrollCacheExtent: const ScrollCacheExtent.pixels(2000),
                children: <Widget>[
                  MorphButton.filled(
                    focusNode: top,
                    onPressed: () {},
                    child: const Text('Top'),
                  ),
                  const SizedBox(height: 600),
                  MorphButton.filled(
                    focusNode: bottom,
                    onPressed: () {},
                    child: const Text('Bottom'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    expect(scrollController.offset, 0);
    MorphFocusInteraction.instance.noteKeyboardHighlight();
    bottom.requestFocus();
    await tester.pumpAndSettle();

    expect(bottom.hasPrimaryFocus, isTrue);
    expect(scrollController.offset, greaterThan(0));
  });
}

void registerFocusRingNavBarKeyboardActivateTests() {
  testWidgets('nav bar destination activates with keyboard', (
    WidgetTester tester,
  ) async {
    var selected = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: MorphTheme(
          data: MorphThemeData.light(),
          child: Scaffold(
            body: MorphNavigationBar(
              selectedIndex: selected,
              onDestinationSelected: (int i) => selected = i,
              destinations: const <MorphNavigationBarDestination>[
                MorphNavigationBarDestination(
                  icon: Icon(Icons.home),
                  label: 'Home',
                ),
                MorphNavigationBarDestination(
                  icon: Icon(Icons.search),
                  label: 'Search',
                ),
              ],
            ),
          ),
        ),
      ),
    );

    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(selected, anyOf(0, 1));
    expect(tester.takeException(), isNull);
  });
}

void registerFocusRingPointerOutsideClearsTests() {
  testWidgets('pointer tap outside segmented button clears keyboard ring', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MorphTheme(
          data: MorphThemeData.light(),
          child: Scaffold(
            body: SizedBox.expand(
              child: Column(
                children: <Widget>[
                  MorphSegmentedButton<int>(
                    selected: const <int>{0},
                    onSelectionChanged: (_) {},
                    segments: const <MorphSegment<int>>[
                      MorphSegment<int>(value: 0, label: 'Day'),
                      MorphSegment<int>(value: 1, label: 'Week'),
                    ],
                  ),
                  const Expanded(child: ColoredBox(color: Color(0x00000000))),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    await tester.sendKeyDownEvent(LogicalKeyboardKey.tab);
    await tester.pumpAndSettle();
    expect(MorphFocusInteraction.instance.ringsAllowed, isTrue);
    expect(
      tester
          .widgetList<MorphFocusRing>(find.byType(MorphFocusRing))
          .any((MorphFocusRing r) => r.focused),
      isTrue,
    );

    await tester.tapAt(const Offset(400, 500));
    await tester.pump(); // deferred ring clear notify
    await tester.pumpAndSettle();
    expect(MorphFocusInteraction.instance.ringsAllowed, isFalse);
    expect(
      tester
          .widgetList<MorphFocusRing>(find.byType(MorphFocusRing))
          .any((MorphFocusRing r) => r.focused),
      isFalse,
    );
    await tester.sendKeyUpEvent(LogicalKeyboardKey.tab);
  });
}

void registerFocusRingPointerTapOnCardTests() {
  testWidgets('pointer tap on card does not show ring and fires once', (
    WidgetTester tester,
  ) async {
    var taps = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: MorphTheme(
          data: MorphThemeData.light(),
          child: Scaffold(
            body: Center(
              child: MorphCard(
                onPressed: () => taps++,
                child: const Text('Item'),
              ),
            ),
          ),
        ),
      ),
    );

    // Pretend keyboard was used earlier so rings were allowed.
    MorphFocusInteraction.instance.noteKeyboardHighlight();
    expect(MorphFocusInteraction.instance.ringsAllowed, isTrue);

    await tester.tap(find.text('Item'));
    await tester.pump();
    expect(taps, 1);
    await tester.pump(); // deferred ring clear notify
    expect(MorphFocusInteraction.instance.ringsAllowed, isFalse);

    // Ring chrome must not paint from pointer focus.
    final rings = tester.widgetList<MorphFocusRing>(
      find.byType(MorphFocusRing),
    );
    for (final ring in rings) {
      expect(ring.focused, isFalse);
    }
  });
}
