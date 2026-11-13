import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morph_expressive/morph_expressive.dart';
import 'package:morph_expressive_preview/main.dart';
import 'package:morph_expressive_preview/tabs_lab.dart';

Future<void> _open(WidgetTester tester, double width) async {
  tester.view.physicalSize = Size(width, 1400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    MorphMaterialApp(data: MorphThemeData.light(), home: const TabsLab()),
  );
  await tester.pump(const Duration(milliseconds: 300));
}

Future<void> _tap(WidgetTester tester, String text) async {
  final Finder f = find.text(text).first;
  await tester.ensureVisible(f);
  await tester.pump();
  await tester.tap(f);
  await tester.pump(const Duration(milliseconds: 60));
}

void main() {
  for (final double width in <double>[390, 1440]) {
    testWidgets('tabs lab at $width: sections, actions, RTL, 2x, reduced', (
      WidgetTester tester,
    ) async {
      await _open(tester, width);
      expect(find.byType(MorphTabs), findsWidgets);
      expect(find.byType(MorphTabsView), findsOneWidget);
      await tester.ensureVisible(
        find.byKey(const ValueKey<String>('tabs_lab_scroll')),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);

      for (final String label in <String>[
        'Presentation: underline',
        'Presentation: surface',
        'Motion: elastic',
        'Motion: slide',
        'Renderer: canvas',
        'Renderer: auto',
        'Reduced motion: false',
        'RTL: false',
        'Text 2×: false',
      ]) {
        await _tap(tester, label);
        expect(tester.takeException(), isNull, reason: label);
      }
      // Reproducible actions on the linked bar and pages.
      for (final String action in <String>[
        'First → last',
        'Rapid changes',
        'Slow jump (swipe to interrupt)',
        'Label: short',
        'Badge on Activity: false',
        'Add at end',
        'Insert at start',
        'Remove selected',
      ]) {
        await _tap(tester, action);
        await tester.pump(const Duration(milliseconds: 500));
        expect(tester.takeException(), isNull, reason: action);
      }
      await tester.pumpAndSettle(
        const Duration(milliseconds: 100),
        EnginePhase.sendSemanticsUpdate,
        const Duration(seconds: 5),
      );
      expect(
        find.byKey(const ValueKey<String>('tabs_lab_progress')),
        findsOneWidget,
      );
      await tester.pumpWidget(const SizedBox());
    });
  }

  testWidgets('swiping the real pages moves the linked indicator', (
    WidgetTester tester,
  ) async {
    await _open(tester, 1440);
    final Finder view = find.byKey(
      const ValueKey<String>('tabs_lab_linked_view'),
    );
    await tester.ensureVisible(view);
    await tester.pump();
    await tester.drag(view, const Offset(-500, 0));
    await tester.pumpAndSettle();
    expect(find.textContaining('selected: 1'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('the app can reject a request from the independent bar', (
    WidgetTester tester,
  ) async {
    await _open(tester, 1440);
    await _tap(tester, 'App rejects changes: false');
    await _tap(tester, 'Select 4');
    await tester.pumpAndSettle();
    expect(find.text('confirmed selection: Day'), findsOneWidget);
    await _tap(tester, 'App rejects changes: true');
    await _tap(tester, 'Select 4');
    await tester.pumpAndSettle();
    expect(find.text('confirmed selection: All time'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('?lab=tabs style entry point renders the lab', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MorphPreviewApp(tabsLab: true));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Tabs Lab'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });
}
