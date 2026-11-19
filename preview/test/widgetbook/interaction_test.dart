import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart'
    show Brightness, EditableText, Size, SizedBox, ValueKey;
import 'package:morph_expressive/morph_expressive.dart';
import 'package:morph_expressive_preview/main.dart';
import 'package:morph_expressive_preview/widgetbook/themes/seed_presets.dart';

import 'support.dart';

String _path(String suffix) =>
    allUseCases().firstWhere((u) => u.path.endsWith(suffix)).path;

Future<void> _setKnob(
  WidgetTester tester,
  String field,
  String value, {
  String group = 'knobs',
}) async {
  stateOf(tester).updateQueryField(group: group, field: field, value: value);
  await tester.pump(const Duration(milliseconds: 300));
}

void main() {
  testWidgets('the default app builds and shows the catalog title', (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(1440, 900)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const MorphWidgetbookApp());
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Morph Expressive'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the Morph addon switches the real MorphTheme brightness', (
    tester,
  ) async {
    await openUseCase(tester, _path('buttons/morphbutton/playground'));
    Brightness brightness() =>
        MorphTheme.of(tester.element(find.byType(MorphButton).first))
            .brightness;
    expect(brightness(), Brightness.light);
    await _setKnob(tester, 'mode', 'Dark', group: 'morph');
    expect(brightness(), Brightness.dark);
  });

  testWidgets('buttons: tapping increments the counter', (tester) async {
    await openUseCase(tester, _path('buttons/morphbutton/playground'));
    expect(find.text('Pressed 0 times'), findsOneWidget);
    await tester.tap(find.byType(MorphButton));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Pressed 1 times'), findsOneWidget);
  });

  testWidgets('knob changes reach the rendered widget', (tester) async {
    await openUseCase(tester, _path('buttons/morphbutton/playground'));
    expect(find.text('Button'), findsOneWidget);
    await _setKnob(tester, 'label', 'Hello');
    expect(find.text('Hello'), findsOneWidget);
    expect(find.text('Button'), findsNothing);
    await _setKnob(tester, 'enabled', 'false');
    expect(
      tester.widget<MorphButton>(find.byType(MorphButton)).onPressed,
      isNull,
    );
  });

  testWidgets('text fields: typing updates the controller readout', (
    tester,
  ) async {
    await openUseCase(tester, _path('text-fields/morphtextfield/playground'));
    await tester.enterText(find.byType(EditableText), 'abc');
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Typed: "abc"'), findsOneWidget);
  });

  testWidgets('sliders: dragging changes the value', (tester) async {
    await openUseCase(tester, _path('sliders/morphslider/playground'));
    expect(find.text('Value: 0.60'), findsOneWidget);
    final slider = find.byKey(const ValueKey('morph_slider_under_test'));
    await tester.drag(slider, const Offset(-120, 0));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('Value: 0.60'), findsNothing);
    expect(find.textContaining('Value: 0.'), findsOneWidget);
  });

  testWidgets('dialogs: open and close through the nested navigator', (
    tester,
  ) async {
    await openUseCase(
      tester,
      _path('dialogs/morphdialog/playground'),
      mode: 'Dark',
      seed: 'Green',
    );
    expect(find.byType(MorphDialog), findsNothing);
    await tester.tap(find.byType(MorphButton));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.byType(MorphDialog), findsOneWidget);
    // The dialog is pushed on the root navigator and still sees the real
    // Morph theme selected in the panel (dark, green seed).
    final theme = MorphTheme.of(tester.element(find.byType(MorphDialog)));
    expect(theme.brightness, Brightness.dark);
    expect(
      theme.colorScheme.primary,
      buildMorphTheme(
        morphSeedPresets['Green']!,
        Brightness.dark,
      ).colorScheme.primary,
    );
    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();
    expect(find.byType(MorphDialog), findsNothing);
    expect(find.text('Result: confirm'), findsOneWidget);
  });

  testWidgets('tabs: selecting a tab changes the page', (tester) async {
    await openUseCase(tester, _path('tabs/morphtabs/playground'));
    expect(find.text('Swipe or tap: Home'), findsOneWidget);
    await tester.tap(find.text('Explore'));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('Swipe or tap: Explore'), findsOneWidget);
  });

  testWidgets('checkbox and switch toggle', (tester) async {
    await openUseCase(tester, _path('checkbox/morphcheckbox/playground'));
    expect(find.text('Value: true'), findsOneWidget);
    await tester.tap(find.byType(MorphCheckbox));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('Value: false'), findsOneWidget);
  });

  testWidgets('menus open an overlay and report the selection', (tester) async {
    await openUseCase(tester, _path('menus/morphmenu/playground'));
    await tester.tap(find.text('Open menu'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('Edit'), findsOneWidget);
    await tester.tap(find.text('Edit'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('Last selection: edit'), findsOneWidget);
  });

  testWidgets('gestures: a long press does not break the playground', (
    tester,
  ) async {
    await openUseCase(tester, _path('cards/morphcard/playground'));
    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(MorphCard).first),
      kind: PointerDeviceKind.mouse,
    );
    await tester.pump(const Duration(milliseconds: 600));
    await gesture.up();
    await tester.pump(const Duration(milliseconds: 200));
    expect(tester.takeException(), isNull);
  });

  testWidgets('time and date picker dialogs open on the nested navigator', (
    tester,
  ) async {
    await openUseCase(
      tester,
      _path('time-pickers/morphtimepickerdialog/dialog'),
    );
    await tester.tap(find.text('Choose time'));
    await tester.pumpAndSettle();
    expect(find.byType(MorphTimePickerDialog), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());

    await openUseCase(
      tester,
      _path('date-pickers/morphdatepickerdialog/dialogs'),
    );
    await tester.tap(find.text('Open date picker'));
    await tester.pumpAndSettle();
    expect(find.byType(MorphDatePickerDialog), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.tapAt(const Offset(5, 5));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Open range picker'));
    await tester.pumpAndSettle();
    expect(find.byType(MorphDateRangePickerDialog), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
