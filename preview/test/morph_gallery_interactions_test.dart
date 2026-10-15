import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:morph_expressive/morph_expressive.dart';
import 'package:morph_expressive_preview/main.dart';

import 'showcase_scroll_helper.dart';

/// Verificaciones de regresion de las muestras interactivas de Morph.
void main() {
  Future<void> start(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MorphPreviewApp());
  }

  Future<void> category(WidgetTester tester, String value) async {
    // Materializar la familia dentro del ListView.builder responsive.
    await revealShowcaseCategory(tester, value);
  }

  testWidgets('connected buttons default to exclusive selection', (tester) async {
    await start(tester);
    await category(tester, 'button_group');
    final widget = tester.widget<MorphButtonGroup>(find.byType(MorphButtonGroup));
    expect(widget.multiSelect, isFalse);
    expect(widget.selectedIndex, 0);
    expect(widget.selectedIndices, isNull);
    expect(widget.selectionRequired, isTrue);
  });

  testWidgets('filter and input chips maintain independent state', (tester) async {
    await start(tester);
    await category(tester, 'chips');
    final filter = find.byKey(const ValueKey('chip_filter'));
    final input = find.byKey(const ValueKey('chip_input'));
    expect(tester.widget<MorphChip>(filter).selected, isFalse);
    expect(tester.widget<MorphChip>(input).selected, isFalse);
    await tester.tap(filter);
    await tester.pump();
    expect(tester.widget<MorphChip>(filter).selected, isTrue);
    expect(tester.widget<MorphChip>(input).selected, isFalse);
    await tester.tap(input);
    await tester.pump();
    expect(tester.widget<MorphChip>(filter).selected, isTrue);
    expect(tester.widget<MorphChip>(input).selected, isTrue);
    await tester.tap(filter);
    await tester.pump();
    expect(tester.widget<MorphChip>(filter).selected, isFalse);
    expect(tester.widget<MorphChip>(input).selected, isTrue);
  });

  testWidgets('assist and suggestion chips show visible action feedback', (tester) async {
    await start(tester);
    await category(tester, 'chips');
    await tester.tap(find.byKey(const ValueKey('chip_assist')));
    await tester.pump();
    expect(find.text('Last action: assist (1)'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('chip_suggestion')));
    await tester.pump();
    expect(find.text('Last action: suggestion (2)'), findsOneWidget);
  });

  testWidgets('slider preview includes wave and range constructors', (tester) async {
    await start(tester);
    await category(tester, 'sliders');
    final sliders = tester.widgetList<MorphSlider>(find.byType(MorphSlider)).toList();
    expect(sliders.where((item) => item.wavy).length, 2);
    final ranges = tester.widgetList<MorphRangeSlider>(
      find.byType(MorphRangeSlider),
    ).toList();
    expect(ranges.length, 2);
    expect(ranges.where((item) => item.wavy).length, 1);
  });

  testWidgets('tab preview includes secondary tabs and a swipeable view', (tester) async {
    await start(tester);
    await category(tester, 'tabs');
    expect(find.byType(MorphTabs), findsNWidgets(2));
    expect(find.byType(MorphTabsView), findsOneWidget);
  });

  testWidgets('selection preview fits and remains interactive', (tester) async {
    await start(tester);
    await category(tester, 'selection');

    final host = find.byKey(const ValueKey('selection_preview_host'));
    expect(host, findsOneWidget);
    expect(tester.getSize(host).height, 360);
    expect(find.byType(MorphList), findsOneWidget);
    expect(tester.takeException(), isNull);

    // El contenido de MorphList.scrollable es lazy: sus flips pueden no
    // estar montados hasta que el sliver construya las filas visibles.
    // Usar el controller compartido comprueba el wiring de la preview sin
    // depender de la materializacion de un item especifico del ListView.
    final scope = MorphSelectionScope.of(
      tester.element(find.byType(MorphList)),
    );
    expect(scope.itemCount, 3);
    expect(scope.controller.selectedIndices, isEmpty);
    scope.controller.select(0);
    expect(scope.controller.selectedIndices, contains(0));
    // Evitar pumpAndSettle: otras muestras del showcase pueden tener
    // animaciones infinitas. Esperar solo la transicion de Selection.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Select all'), findsOneWidget);
    expect(find.descendant(
      of: find.byType(MorphSelectionAppBar),
      matching: find.text('1'),
    ), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Select all'));
    expect(scope.controller.selectedIndices, unorderedEquals(<int>[0, 1, 2]));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.descendant(
      of: find.byType(MorphSelectionAppBar),
      matching: find.text('3'),
    ), findsOneWidget);
    expect(tester.takeException(), isNull);

    // MorphIconButton utiliza MorphTooltip, no el Tooltip de Flutter.
    // Buscar la accion por su etiqueta evita depender de otro toolkit.
    final clearSelection = find.descendant(
      of: find.byType(MorphSelectionAppBar),
      matching: find.byWidgetPredicate(
        (widget) => widget is MorphIconButton &&
            widget.semanticLabel == 'Clear selection',
      ),
    );
    expect(clearSelection, findsOneWidget);
    await tester.tap(clearSelection);
    expect(scope.controller.selectedIndices, isEmpty);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Select rows below'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('card preview includes every variant and group', (tester) async {
    await start(tester);
    await category(tester, 'cards');
    final variants = tester.widgetList<MorphCard>(find.byType(MorphCard))
        .map((card) => card.variant).toSet();
    expect(variants, containsAll(MorphCardVariant.values));
    expect(find.byType(MorphCardGroup), findsOneWidget);
  });
}
