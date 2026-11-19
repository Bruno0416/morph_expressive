import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart' show EditableText, SizedBox;
import 'package:morph_expressive/morph_expressive.dart';

import 'support.dart';

/// Assertions carried over from the retired single-page gallery tests; each
/// now runs against the Widgetbook use case that replaced its sample.
String _path(String suffix) =>
    allUseCases().firstWhere((u) => u.path.endsWith(suffix)).path;

Future<void> _setKnob(WidgetTester tester, String field, String value) async {
  stateOf(tester).updateQueryField(group: 'knobs', field: field, value: value);
  await tester.pump(const Duration(milliseconds: 300));
}

void main() {
  testWidgets('button group selects exclusively by default', (tester) async {
    await openUseCase(tester, _path('morphbuttongroup/playground'));
    final group = tester.widget<MorphButtonGroup>(
      find.byType(MorphButtonGroup),
    );
    expect(group.multiSelect, isFalse);
    expect(group.selectedIndex, 0);
    expect(group.selectedIndices, isNull);
    await tester.tap(find.text('Week').first);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('Selected: 1'), findsOneWidget);
  });

  testWidgets('filter chips toggle selection and keep the type', (
    tester,
  ) async {
    await openUseCase(tester, _path('morphchip/playground'));
    expect(find.text('Pressed 0 times · selected: false'), findsOneWidget);
    await tester.tap(find.byType(MorphChip));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('Pressed 1 times · selected: true'), findsOneWidget);
    expect(
      tester.widget<MorphChip>(find.byType(MorphChip)).type,
      MorphChipType.filter,
    );
    await tester.tap(find.byType(MorphChip));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('Pressed 2 times · selected: false'), findsOneWidget);
  });

  testWidgets('chip toggle exposes multi-selection independently', (
    tester,
  ) async {
    await openUseCase(tester, _path('morphchiptoggle/chip-toggle'));
    await _setKnob(tester, 'multi selection', 'true');
    var control = tester.widget<MorphChipToggle<String>>(
      find.byType(MorphChipToggle<String>),
    );
    expect(control.multiSelection, isTrue);
    expect(control.selectedValues, {'Daily', 'Monthly'});
    await tester.tap(find.text('Weekly'));
    await tester.pump(const Duration(milliseconds: 200));
    control = tester.widget<MorphChipToggle<String>>(
      find.byType(MorphChipToggle<String>),
    );
    expect(control.selectedValues, {'Daily', 'Weekly', 'Monthly'});
  });

  testWidgets('segmented toggle selects the tapped option', (tester) async {
    await openUseCase(tester, _path('morphsegmentedtoggle/segmented-toggle'));
    await tester.tap(find.text('TV Shows'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(
      tester
          .widget<MorphSegmentedToggle<String>>(
            find.byType(MorphSegmentedToggle<String>),
          )
          .selected,
      'TV Shows',
    );
  });

  testWidgets('navigation bar selection changes with a tap', (tester) async {
    await openUseCase(tester, _path('morphnavigationbar/playground'));
    expect(
      tester
          .widget<MorphNavigationBar>(find.byType(MorphNavigationBar))
          .selectedIndex,
      0,
    );
    await tester.tap(find.text('Search'));
    await tester.pump(const Duration(milliseconds: 400));
    expect(
      tester
          .widget<MorphNavigationBar>(find.byType(MorphNavigationBar))
          .selectedIndex,
      1,
    );
  });

  testWidgets('the navigation rail demo ignores scroll-under', (tester) async {
    await openUseCase(tester, _path('morphnavigationrail/playground'));
    expect(
      tester
          .widget<MorphNavigationRail>(find.byType(MorphNavigationRail))
          .scrollUnder,
      isFalse,
    );
  });

  testWidgets('sliders cover wave and range constructors', (tester) async {
    await openUseCase(tester, _path('morphslider/all-types'));
    final sliders = tester.widgetList<MorphSlider>(find.byType(MorphSlider));
    expect(sliders.where((s) => s.wavy).length, 2);
    await tester.pumpWidget(const SizedBox.shrink());
    await openUseCase(tester, _path('morphrangeslider/range-slider'));
    await _setKnob(tester, 'wavy', 'true');
    expect(find.byType(MorphRangeSlider), findsOneWidget);
    expect(
      tester.widget<MorphRangeSlider>(find.byType(MorphRangeSlider)).wavy,
      isTrue,
    );
  });

  testWidgets('tabs pair the bar with a swipeable view', (tester) async {
    await openUseCase(tester, _path('morphtabs/playground'));
    expect(find.byType(MorphTabs), findsOneWidget);
    expect(find.byType(MorphTabsView), findsOneWidget);
    await _setKnob(tester, 'variant', 'secondary');
    expect(
      tester.widget<MorphTabs>(find.byType(MorphTabs)).variant,
      MorphTabsVariant.secondary,
    );
  });

  testWidgets('selection mode fits and stays interactive', (tester) async {
    await openUseCase(tester, _path('morphselection/selection-mode'));
    expect(find.byType(MorphList), findsOneWidget);
    expect(tester.takeException(), isNull);
    final scope = MorphSelectionScope.of(
      tester.element(find.byType(MorphList)),
    );
    expect(scope.itemCount, 6);
    expect(scope.controller.selectedIndices, isEmpty);
    scope.controller.select(0);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Select all'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(MorphSelectionAppBar),
        matching: find.text('1'),
      ),
      findsOneWidget,
    );
    await tester.tap(find.text('Select all'));
    expect(
      scope.controller.selectedIndices,
      unorderedEquals(<int>[0, 1, 2, 3, 4, 5]),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    final clear = find.descendant(
      of: find.byType(MorphSelectionAppBar),
      matching: find.byWidgetPredicate(
        (w) => w is MorphIconButton && w.semanticLabel == 'Clear selection',
      ),
    );
    expect(clear, findsOneWidget);
    await tester.tap(clear);
    expect(scope.controller.selectedIndices, isEmpty);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Select rows below'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('cards cover every type and the group', (tester) async {
    await openUseCase(tester, _path('morphcard/matrix'));
    final types = tester
        .widgetList<MorphCard>(find.byType(MorphCard))
        .map((card) => card.type)
        .toSet();
    expect(types, containsAll(MorphCardType.values));
    await tester.pumpWidget(const SizedBox.shrink());
    await openUseCase(tester, _path('morphcardgroup/card-group'));
    expect(find.byType(MorphCardGroup), findsOneWidget);
  });

  testWidgets('text field matrix shows both named constructors', (
    tester,
  ) async {
    await openUseCase(tester, _path('morphtextfield/matrix'));
    final variants = tester
        .widgetList<MorphTextField>(find.byType(MorphTextField))
        .map((field) => field.variant)
        .toSet();
    expect(variants, MorphTextFieldVariant.values.toSet());
  });

  testWidgets(
    'a label-less filled field centres its leading icon on the text',
    (tester) async {
      await openUseCase(tester, _path('morphtextfield/playground'));
      await _setKnob(tester, 'label', '');
      await _setKnob(tester, 'leading icon', 'true');
      final field = tester.widget<MorphTextField>(find.byType(MorphTextField));
      expect(field.variant, MorphTextFieldVariant.filled);
      expect(field.label, isNull);
      expect(field.leading, isNotNull);
      final leading = find.descendant(
        of: find.byType(MorphTextField),
        matching: find.byIcon(FluentIcons.line.mail),
      );
      final editable = find.descendant(
        of: find.byType(MorphTextField),
        matching: find.byType(EditableText),
      );
      expect(
        (tester.getCenter(leading).dy - tester.getCenter(editable).dy).abs(),
        lessThan(6),
      );
    },
  );
}
