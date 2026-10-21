import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morph_expressive/morph_components.dart';
import 'package:material_ui/material_ui.dart'
    show
        BorderRadius,
        BuildContext,
        ButtonActivateIntent,
        Center,
        Color,
        ColoredBox,
        Column,
        Element,
        FocusManager,
        FocusNode,
        FocusableActionDetector,
        Intent,
        MainAxisSize,
        MaterialApp,
        PhysicalModel,
        Radius,
        Scaffold,
        Semantics,
        ShortcutActivator,
        SingleActivator,
        SizedBox,
        Text,
        Widget,
        WidgetsApp;

import 'focus_nav_repro_test_support.dart';

void main() {
  setUp(setUpFocusNavReproTests);
  tearDown(tearDownFocusNavReproTests);

  registerWebStyleButtonActivateIntentTests();
  registerSelectionDialogEnterSelectsRowTests();
  registerSelectionDialogTabVisitsRowsTests();
  registerCheckboxFocusableFalseSkipsTabTests();
  registerFocusRingPaintsAboveOpaqueSiblingTests();
}

void registerWebStyleButtonActivateIntentTests() {
  testWidgets('Web-style ButtonActivateIntent activates focused button', (
    WidgetTester tester,
  ) async {
    var pressed = 0;
    final focusNode = FocusNode(debugLabel: 'btn');
    addTearDown(focusNode.dispose);

    // Mimic WidgetsApp web shortcuts: Enter → ButtonActivateIntent.
    await tester.pumpWidget(
      MaterialApp(
        shortcuts: <ShortcutActivator, Intent>{
          ...WidgetsApp.defaultShortcuts,
          const SingleActivator(LogicalKeyboardKey.enter):
              const ButtonActivateIntent(),
          const SingleActivator(LogicalKeyboardKey.numpadEnter):
              const ButtonActivateIntent(),
        },
        home: MorphTheme(
          data: MorphThemeData.light(),
          child: Scaffold(
            body: MorphButton.filled(
              focusNode: focusNode,
              onPressed: () => pressed++,
              child: const Text('Go'),
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
    await tester.pumpAndSettle();
    await tester.sendKeyUpEvent(LogicalKeyboardKey.enter);

    expect(pressed, 1);
  });
}

void registerSelectionDialogEnterSelectsRowTests() {
  testWidgets('selection dialog Enter selects focused row', (
    WidgetTester tester,
  ) async {
    List<String>? result;

    await pumpSelectionDialogEnterApp(
      tester,
      onResult: (List<String>? value) => result = value,
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    // Rows share one roving Tab stop (the active row); arrows move between
    // them. Embedded radios are never Tab stops.
    final Finder optionFocus = find.descendant(
      of: find.bySemanticsLabel('B'),
      matching: find.byType(FocusableActionDetector),
    );
    final FocusableActionDetector detector = tester
        .widgetList<FocusableActionDetector>(optionFocus)
        .firstWhere((FocusableActionDetector d) => d.enabled);
    final FocusNode? node = detector.focusNode;
    expect(node, isNotNull);
    expect(node!.skipTraversal, isTrue);
    expect(node.canRequestFocus, isTrue);

    final Finder radioFocus = find.descendant(
      of: find.byType(MorphRadio<String>),
      matching: find.byType(FocusableActionDetector),
    );
    for (final FocusableActionDetector radioDetector
        in tester.widgetList<FocusableActionDetector>(radioFocus)) {
      expect(radioDetector.enabled, isFalse);
      expect(radioDetector.focusNode?.skipTraversal, isTrue);
    }

    MorphFocusInteraction.instance.noteKeyboardHighlight();
    node.requestFocus();
    await tester.pumpAndSettle();
    expect(node.hasPrimaryFocus, isTrue);

    final MorphFocusRing rowRing = tester
        .widgetList<MorphFocusRing>(
          find.descendant(
            of: find.bySemanticsLabel('B'),
            matching: find.byType(MorphFocusRing),
          ),
        )
        .firstWhere((MorphFocusRing r) => r.focused);
    expect(rowRing.focused, isTrue);

    await tester.sendKeyDownEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    await tester.sendKeyUpEvent(LogicalKeyboardKey.enter);

    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(result, <String>['B']);
  });
}

void registerSelectionDialogTabVisitsRowsTests() {
  testWidgets('selection dialog Tab visits option rows under shell order', (
    WidgetTester tester,
  ) async {
    await pumpSelectionDialogShellOrderApp(tester);

    await tester.tap(find.text('Open selection'));
    await tester.pumpAndSettle();

    MorphFocusInteraction.instance.noteKeyboardHighlight();
    final hit = <String>{};
    for (var i = 0; i < 8; i++) {
      await tester.sendKeyDownEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyUpEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();

      final FocusNode? primary = FocusManager.instance.primaryFocus;
      primary?.context?.visitAncestorElements((Element element) {
        final Widget widget = element.widget;
        if (widget is Semantics && widget.properties.label != null) {
          hit.add(widget.properties.label!);
          return false;
        }
        return true;
      });
    }

    expect(
      hit.intersection(<String>{'Standard', 'Pro', 'Team'}),
      isNotEmpty,
      reason: 'Tab must reach selection rows (example-shell traversal)',
    );

    // Focused row must paint a keyboard focus ring (visible Tab feedback).
    expect(
      tester
          .widgetList<MorphFocusRing>(find.byType(MorphFocusRing))
          .any((MorphFocusRing r) => r.focused),
      isTrue,
    );
  });
}

void registerCheckboxFocusableFalseSkipsTabTests() {
  testWidgets('checkbox focusable false skips Tab traversal', (
    WidgetTester tester,
  ) async {
    final rowFocus = FocusNode(debugLabel: 'row');
    addTearDown(rowFocus.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: MorphTheme(
          data: MorphThemeData.light(),
          child: Scaffold(
            body: MorphTappable(
              focusNode: rowFocus,
              onTap: () {},
              builder: (BuildContext context, MorphInteractionState state) {
                return MorphCheckbox(
                  value: false,
                  onChanged: (_) {},
                  focusable: false,
                );
              },
            ),
          ),
        ),
      ),
    );

    final Finder checkboxDetector = find.descendant(
      of: find.byType(MorphCheckbox),
      matching: find.byType(FocusableActionDetector),
    );
    final FocusableActionDetector detector = tester.widget(checkboxDetector);
    expect(detector.enabled, isFalse);
    expect(detector.focusNode?.canRequestFocus, isFalse);
    expect(detector.focusNode?.skipTraversal, isTrue);
  });
}

void registerFocusRingPaintsAboveOpaqueSiblingTests() {
  testWidgets('focus ring paints above opaque sibling without extra gap', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MorphTheme(
          data: MorphThemeData.light(),
          child: const Scaffold(
            body: Center(
              child: SizedBox(
                width: 120,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    MorphFocusRing(
                      focused: true,
                      radius: BorderRadius.all(Radius.circular(12)),
                      child: ColoredBox(
                        color: Color(0xFF2196F3),
                        child: SizedBox(width: 120, height: 40),
                      ),
                    ),
                    // 3dp gap — less than default ring outset (gap+width = 4).
                    SizedBox(height: 3),
                    ColoredBox(
                      color: Color(0xFFFF9800),
                      child: SizedBox(width: 120, height: 40),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
    // Rings only paint during keyboard navigation (setUp resets that).
    MorphFocusInteraction.instance.noteKeyboardHighlight();
    await tester.pumpAndSettle();

    final PhysicalModel model = tester.widget(
      find.descendant(
        of: find.byType(MorphFocusRing),
        matching: find.byType(PhysicalModel),
      ),
    );
    expect(model.elevation, greaterThan(0));
    expect(tester.takeException(), isNull);
  });
}
