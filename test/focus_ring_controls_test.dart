import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morph_expressive/morph_components.dart';
import 'package:material_ui/material_ui.dart';

import 'focus_ring_test_support.dart';

void main() {
  setUp(setUpFocusRingTests);
  tearDown(tearDownFocusRingTests);

  registerFocusRingDropdownEnterToggleTests();
  registerFocusRingDropdownTabTrapTests();
  registerFocusRingSearchBarKeyboardRingTests();
  registerFocusRingTabLeavesTextFieldTests();
  registerFocusRingTextFieldTypingWithRingTests();
  registerFocusRingTabReachesSearchBarTests();
}

void registerFocusRingDropdownEnterToggleTests() {
  testWidgets('dropdown Enter toggles when field focused', (
    WidgetTester tester,
  ) async {
    final focusNode = FocusNode();
    addTearDown(focusNode.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: MorphTheme(
          data: MorphThemeData.light(),
          child: Scaffold(
            body: MorphDropdownMenu<String>(
              focusNode: focusNode,
              singleSelect: true,
              items: const <MorphDropdownItem<String>>[
                MorphDropdownItem(value: 'one', label: 'One'),
                MorphDropdownItem(value: 'two', label: 'Two'),
              ],
              onSelectionChanged: (_) {},
            ),
          ),
        ),
      ),
    );

    MorphFocusInteraction.instance.noteKeyboardHighlight();
    focusNode.requestFocus();
    await tester.pumpAndSettle();
    expect(focusNode.hasPrimaryFocus, isTrue);

    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(find.text('One'), findsOneWidget);

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
  });
}

void registerFocusRingDropdownTabTrapTests() {
  testWidgets('dropdown trap keeps Tab among field and panel', (
    WidgetTester tester,
  ) async {
    final outside = FocusNode(debugLabel: 'outside');
    addTearDown(outside.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: MorphTheme(
          data: MorphThemeData.light(),
          child: Scaffold(
            body: Column(
              children: <Widget>[
                MorphDropdownMenu<String>(
                  items: const <MorphDropdownItem<String>>[
                    MorphDropdownItem(value: 'one', label: 'One'),
                    MorphDropdownItem(value: 'two', label: 'Two'),
                  ],
                  onSelectionChanged: (_) {},
                ),
                MorphButton.filled(
                  focusNode: outside,
                  onPressed: () {},
                  child: const Text('Outside'),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byType(MorphDropdownMenu<String>));
    await tester.pumpAndSettle();
    expect(find.text('One'), findsOneWidget);

    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pumpAndSettle();
    expect(outside.hasPrimaryFocus, isFalse);

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
  });
}

void registerFocusRingSearchBarKeyboardRingTests() {
  testWidgets('search bar shows ring under keyboard modality', (
    WidgetTester tester,
  ) async {
    final focusNode = FocusNode();
    addTearDown(focusNode.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: MorphTheme(
          data: MorphThemeData.light(),
          child: Scaffold(
            body: MorphSearchBar(focusNode: focusNode, hintText: 'Search'),
          ),
        ),
      ),
    );

    MorphFocusInteraction.instance.noteKeyboardHighlight();
    focusNode.requestFocus();
    await tester.pumpAndSettle();

    expect(focusNode.hasPrimaryFocus, isTrue);
    expect(MorphFocusRing.shouldShow(focusNode), isTrue);
    final rings = tester.widgetList<MorphFocusRing>(
      find.byType(MorphFocusRing),
    );
    expect(rings.any((MorphFocusRing r) => r.focused), isTrue);
  });
}

void registerFocusRingTabLeavesTextFieldTests() {
  testWidgets('Tab leaves text field and clears its ring', (
    WidgetTester tester,
  ) async {
    final field = FocusNode(debugLabel: 'field');
    final next = FocusNode(debugLabel: 'next');
    addTearDown(field.dispose);
    addTearDown(next.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: MorphTheme(
          data: MorphThemeData.light(),
          child: Scaffold(
            body: Column(
              children: <Widget>[
                MorphTextField(focusNode: field, label: 'Name'),
                MorphButton.filled(
                  focusNode: next,
                  onPressed: () {},
                  child: const Text('Next'),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    MorphFocusInteraction.instance.noteKeyboardHighlight();
    field.requestFocus();
    await tester.pumpAndSettle();
    expect(field.hasPrimaryFocus, isTrue);
    expect(MorphFocusRing.shouldShow(field), isTrue);

    await tester.sendKeyDownEvent(LogicalKeyboardKey.tab);
    await tester.pumpAndSettle();
    await tester.sendKeyUpEvent(LogicalKeyboardKey.tab);

    expect(field.hasPrimaryFocus, isFalse);
    expect(MorphFocusRing.shouldShow(field), isFalse);
    expect(next.hasPrimaryFocus, isTrue);
  });
}

void registerFocusRingTextFieldTypingWithRingTests() {
  testWidgets('text field accepts typing while keyboard ring is shown', (
    WidgetTester tester,
  ) async {
    final field = FocusNode(debugLabel: 'field');
    addTearDown(field.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: MorphTheme(
          data: MorphThemeData.light(),
          child: Scaffold(
            body: MorphTextField(focusNode: field, label: 'Name'),
          ),
        ),
      ),
    );

    MorphFocusInteraction.instance.noteKeyboardHighlight();
    field.requestFocus();
    await tester.pumpAndSettle();
    expect(MorphFocusRing.shouldShow(field), isTrue);

    await tester.enterText(find.byType(EditableText), 'hello');
    await tester.pumpAndSettle();
    expect(find.text('hello'), findsOneWidget);
    expect(field.hasPrimaryFocus, isTrue);
  });
}

void registerFocusRingTabReachesSearchBarTests() {
  testWidgets('Tab reaches idle search bar EditableText', (
    WidgetTester tester,
  ) async {
    final before = FocusNode(debugLabel: 'before');
    final search = FocusNode(debugLabel: 'search');
    addTearDown(before.dispose);
    addTearDown(search.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: MorphTheme(
          data: MorphThemeData.light(),
          child: Scaffold(
            body: Column(
              children: <Widget>[
                MorphButton.filled(
                  focusNode: before,
                  onPressed: () {},
                  child: const Text('Before'),
                ),
                MorphSearchBar(focusNode: search, hintText: 'Search'),
              ],
            ),
          ),
        ),
      ),
    );

    MorphFocusInteraction.instance.noteKeyboardHighlight();
    before.requestFocus();
    await tester.pumpAndSettle();

    await tester.sendKeyDownEvent(LogicalKeyboardKey.tab);
    await tester.pumpAndSettle();
    await tester.sendKeyUpEvent(LogicalKeyboardKey.tab);

    expect(search.hasPrimaryFocus, isTrue);
    expect(MorphFocusRing.shouldShow(search), isTrue);
  });
}
