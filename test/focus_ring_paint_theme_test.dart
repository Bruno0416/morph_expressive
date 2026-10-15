import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morph_expressive/morph_components.dart';
import 'package:material_ui/material_ui.dart';

import 'focus_ring_test_support.dart';

void main() {
  setUp(setUpFocusRingTests);
  tearDown(tearDownFocusRingTests);

  registerFocusRingPaintsWhenFocusedTests();
  registerFocusRingThemeColorOverrideTests();
  registerFocusRingButtonTraditionalHighlightTests();
  registerFocusRingCheckboxSharedThemeTests();
  registerFocusRingIndicatorsDisabledTests();
}

void registerFocusRingPaintsWhenFocusedTests() {
  testWidgets('MorphFocusRing paints when focused', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MorphTheme(
          data: MorphThemeData.light(),
          child: const Scaffold(
            body: Center(
              child: MorphFocusRing(
                focused: true,
                radius: BorderRadius.all(Radius.circular(12)),
                child: SizedBox(width: 80, height: 40),
              ),
            ),
          ),
        ),
      ),
    );
    expect(find.byType(MorphFocusRing), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

void registerFocusRingThemeColorOverrideTests() {
  testWidgets('focusRingTheme color override applies', (
    WidgetTester tester,
  ) async {
    const override = Color(0xFFAA00FF);
    await tester.pumpWidget(
      MaterialApp(
        home: MorphTheme(
          data: MorphThemeData.light().copyWith(
            focusRingTheme: const MorphFocusRingTheme(color: override),
          ),
          child: Builder(
            builder: (BuildContext context) {
              final Color resolved = MorphTheme.of(context).focusRingTheme
                  .resolveColor(MorphTheme.of(context).colorScheme);
              expect(resolved, override);
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  });
}

void registerFocusRingButtonTraditionalHighlightTests() {
  testWidgets('MorphButton shows focus ring under traditional highlight', (
    WidgetTester tester,
  ) async {
    final focusNode = FocusNode();
    addTearDown(focusNode.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: MorphTheme(
          data: MorphThemeData.light(),
          child: Scaffold(
            body: Center(
              child: MorphButton.filled(
                focusNode: focusNode,
                onPressed: () {},
                child: const Text('Go'),
              ),
            ),
          ),
        ),
      ),
    );

    MorphFocusInteraction.instance.noteKeyboardHighlight();
    focusNode.requestFocus();
    await tester.pumpAndSettle();
    expect(focusNode.hasFocus, isTrue);
    expect(find.byType(MorphFocusRing), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}

void registerFocusRingCheckboxSharedThemeTests() {
  testWidgets('checkbox focus ring uses shared theme', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MorphTheme(
          data: MorphThemeData.light(),
          child: Scaffold(body: MorphCheckbox(value: false, onChanged: (_) {})),
        ),
      ),
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pumpAndSettle();
    expect(find.byType(MorphFocusRing), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}

void registerFocusRingIndicatorsDisabledTests() {
  testWidgets('keyboardFocusIndicators false hides focus rings', (
    WidgetTester tester,
  ) async {
    final focusNode = FocusNode();
    addTearDown(focusNode.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: MorphTheme(
          data: MorphThemeData.light().copyWith(keyboardFocusIndicators: false),
          child: Scaffold(
            body: Column(
              children: <Widget>[
                const MorphFocusRing(
                  focused: true,
                  radius: BorderRadius.all(Radius.circular(8)),
                  child: SizedBox(width: 40, height: 40),
                ),
                MorphButton.filled(
                  focusNode: focusNode,
                  onPressed: () {},
                  child: const Text('Go'),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    MorphFocusInteraction.instance.noteKeyboardHighlight();
    focusNode.requestFocus();
    await tester.pumpAndSettle();

    expect(focusNode.hasPrimaryFocus, isTrue);
    expect(
      MorphFocusRing.shouldShow(
        focusNode,
        tester.element(find.byType(MorphButton)),
      ),
      isFalse,
    );

    final PhysicalModel forcedRing = tester.widget(
      find.descendant(
        of: find.byType(MorphFocusRing).first,
        matching: find.byType(PhysicalModel),
      ),
    );
    expect(forcedRing.elevation, 0);

    // Button shouldShow respects the theme flag (no painted ring chrome).
    expect(
      tester
          .widgetList<PhysicalModel>(
            find.descendant(
              of: find.byType(MorphButton),
              matching: find.byType(PhysicalModel),
            ),
          )
          .every((PhysicalModel m) => m.elevation == 0),
      isTrue,
    );
  });
}
