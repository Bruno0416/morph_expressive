import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morph_expressive/morph_components.dart';
import 'package:material_ui/material_ui.dart';

import 'focus_nav_repro_test_support.dart';

// ---------- buscador especifico del boton para limpiar ----------
// El mismo glifo Fluent aparece en los chips y el boton principal.
Finder findDropdownClearButton() => find.byWidgetPredicate(
  (widget) =>
      widget is Icon && widget.icon == MorphIcons.close && widget.size == 24,
);

void main() {
  setUp(setUpFocusNavReproTests);
  tearDown(tearDownFocusNavReproTests);

  registerDropdownChipAndClearTabStopsTests();
  registerEnterOnDropdownClearTests();
  registerEnterOnDropdownChipTests();
}

void registerDropdownChipAndClearTabStopsTests() {
  testWidgets('Dropdown chip and clear are Tab stops with rings', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MorphTheme(
          data: MorphThemeData.light(),
          child: Scaffold(
            body: MorphDropdownMenu<String>(
              items: const <MorphDropdownItem<String>>[
                MorphDropdownItem(value: 'one', label: 'One', selected: true),
                MorphDropdownItem(value: 'two', label: 'Two', selected: true),
              ],
              fieldStyle: const MorphDropdownFieldStyle(showClearIcon: true),
              onSelectionChanged: (_) {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    MorphFocusInteraction.instance.noteKeyboardHighlight();
    await tester.sendKeyDownEvent(LogicalKeyboardKey.tab);
    await tester.pumpAndSettle();
    await tester.sendKeyUpEvent(LogicalKeyboardKey.tab);

    var ringStops = 0;
    for (var i = 0; i < 6; i++) {
      final FocusNode? primary = FocusManager.instance.primaryFocus;
      if (primary != null &&
          primary.canRequestFocus &&
          MorphFocusRing.shouldShow(primary)) {
        ringStops++;
      }
      await tester.sendKeyDownEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
      await tester.sendKeyUpEvent(LogicalKeyboardKey.tab);
    }

    expect(
      ringStops,
      greaterThanOrEqualTo(2),
      reason: 'Expected multiple field/chip/clear ring stops, got $ringStops',
    );
    expect(find.text('One'), findsOneWidget);
    expect(findDropdownClearButton(), findsOneWidget);
  });
}

void registerEnterOnDropdownClearTests() {
  testWidgets('Enter on dropdown clear removes all selections', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MorphTheme(
          data: MorphThemeData.light(),
          child: Scaffold(
            body: MorphDropdownMenu<String>(
              items: const <MorphDropdownItem<String>>[
                MorphDropdownItem(value: 'one', label: 'One', selected: true),
                MorphDropdownItem(value: 'two', label: 'Two', selected: true),
              ],
              fieldStyle: const MorphDropdownFieldStyle(showClearIcon: true),
              onSelectionChanged: (_) {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('One'), findsOneWidget);
    expect(findDropdownClearButton(), findsOneWidget);

    MorphFocusInteraction.instance.noteKeyboardHighlight();

    var foundClear = false;
    for (var i = 0; i < 8; i++) {
      await tester.sendKeyDownEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
      await tester.sendKeyUpEvent(LogicalKeyboardKey.tab);
      final Element iconEl = findDropdownClearButton().evaluate().first;
      final FocusableActionDetector? detector = iconEl
          .findAncestorWidgetOfExactType<FocusableActionDetector>();
      final FocusNode? node = detector?.focusNode;
      if (node != null && node.hasPrimaryFocus) {
        foundClear = true;
        break;
      }
    }
    expect(foundClear, isTrue, reason: 'Tab should reach the clear control');

    await tester.sendKeyDownEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    await tester.sendKeyUpEvent(LogicalKeyboardKey.enter);

    expect(find.text('One'), findsNothing);
    expect(findDropdownClearButton(), findsNothing);
  });
}

void registerEnterOnDropdownChipTests() {
  testWidgets('Enter on dropdown chip removes that selection', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MorphTheme(
          data: MorphThemeData.light(),
          child: Scaffold(
            body: MorphDropdownMenu<String>(
              items: const <MorphDropdownItem<String>>[
                MorphDropdownItem(value: 'one', label: 'One', selected: true),
                MorphDropdownItem(value: 'two', label: 'Two', selected: true),
              ],
              fieldStyle: const MorphDropdownFieldStyle(showClearIcon: true),
              onSelectionChanged: (_) {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    MorphFocusInteraction.instance.noteKeyboardHighlight();

    var foundChip = false;
    for (var i = 0; i < 8; i++) {
      await tester.sendKeyDownEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
      await tester.sendKeyUpEvent(LogicalKeyboardKey.tab);
      final Element chipText = find.text('One').evaluate().first;
      final FocusableActionDetector? detector = chipText
          .findAncestorWidgetOfExactType<FocusableActionDetector>();
      final FocusNode? node = detector?.focusNode;
      if (node != null && node.hasPrimaryFocus) {
        foundChip = true;
        break;
      }
    }
    expect(foundChip, isTrue, reason: 'Tab should reach the One chip');

    await tester.sendKeyDownEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    await tester.sendKeyUpEvent(LogicalKeyboardKey.enter);

    expect(find.text('One'), findsNothing);
    expect(find.text('Two'), findsOneWidget);
  });
}
