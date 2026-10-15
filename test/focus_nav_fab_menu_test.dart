import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morph_expressive/morph_components.dart';
import 'package:material_ui/material_ui.dart';

import 'focus_nav_repro_test_support.dart';

void main() {
  setUp(setUpFocusNavReproTests);
  tearDown(tearDownFocusNavReproTests);

  registerFabMenuTabVisitsEveryItemTests();
  registerFabMenuEscapeClosesOpenMenuTests();
  registerFabEnterActivatesWhenFocusedTests();
}

void registerFabMenuTabVisitsEveryItemTests() {
  testWidgets('FAB menu focuses close first then Tab visits every item', (
    WidgetTester tester,
  ) async {
    const labels = <String>['Image', 'Video', 'Audio', 'Document'];
    await pumpFabMenuApp(tester, labels: labels);

    await tester.tap(find.byType(MorphFab));
    await tester.pumpAndSettle();
    for (final label in labels) {
      expect(find.text(label), findsOneWidget);
    }

    final FocusScopeNode menuScope = findFabMenuScope()!;
    final List<FocusNode> focusable = menuScope.traversalDescendants
        .where((FocusNode n) => n.canRequestFocus && !n.skipTraversal)
        .toList();
    // Close + each menu item.
    expect(focusable, hasLength(labels.length + 1));

    // Spec: initial focus remains on the close button.
    expect(
      FocusManager.instance.primaryFocus?.debugLabel,
      'MorphFabMenuClose',
      reason: 'Open should focus the close button first',
    );

    final visited = <FocusNode>{};
    for (var i = 0; i < focusable.length + 1; i++) {
      final FocusNode? primary = FocusManager.instance.primaryFocus;
      expect(
        primary?.debugLabel,
        isNot('MorphFabMenu'),
        reason: 'FocusScope must skipTraversal so Tab walks targets',
      );
      expect(
        focusable.contains(primary),
        isTrue,
        reason: 'Tab should stay on close/item nodes, got $primary',
      );
      visited.add(primary!);
      await pumpFocusNavTab(tester);
    }

    expect(
      visited,
      unorderedEquals(focusable),
      reason: 'Tab must reach close and every FAB menu item',
    );
  });
}

void registerFabMenuEscapeClosesOpenMenuTests() {
  testWidgets('FAB menu Escape closes open menu', (WidgetTester tester) async {
    await pumpFabMenuApp(tester, labels: const <String>['Image', 'Video']);

    await tester.tap(find.byType(MorphFab));
    await tester.pumpAndSettle();
    expect(find.text('Image'), findsOneWidget);

    await tester.sendKeyDownEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    await tester.sendKeyUpEvent(LogicalKeyboardKey.escape);

    expect(find.text('Image'), findsNothing);
  });
}

void registerFabEnterActivatesWhenFocusedTests() {
  testWidgets('FAB Enter activates when focused', (WidgetTester tester) async {
    var pressed = 0;
    final focusNode = FocusNode(debugLabel: 'fab');
    addTearDown(focusNode.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: MorphTheme(
          data: MorphThemeData.light(),
          child: Scaffold(
            floatingActionButton: MorphFab(
              focusNode: focusNode,
              icon: const Icon(Icons.add),
              onPressed: () => pressed++,
            ),
          ),
        ),
      ),
    );

    MorphFocusInteraction.instance.noteKeyboardHighlight();
    focusNode.requestFocus();
    await tester.pumpAndSettle();
    expect(focusNode.hasPrimaryFocus, isTrue);

    await tester.sendKeyDownEvent(LogicalKeyboardKey.enter);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 48));

    // Press scale should be running (same path as pointer press).
    final transforms = tester.widgetList<Transform>(
      find.descendant(
        of: find.byType(MorphFab),
        matching: find.byType(Transform),
      ),
    );
    final bool scaled = transforms.any((Transform t) {
      final double scale = t.transform.storage[0];
      return (scale - 1.0).abs() > 0.001;
    });
    expect(scaled, isTrue, reason: 'Enter should play FAB press scale');

    await tester.sendKeyUpEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();

    expect(pressed, 1);
  });
}
