import 'package:flutter_test/flutter_test.dart';
import 'package:morph_expressive/morph_components.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets(
    'MorphSelection fills selected rows with the highlight color',
    _morphselectionFillsSelectedRowsWithTheHighlightColor,
  );
  testWidgets(
    'MorphSelection selectedColor overrides the theme highlight',
    _morphselectionSelectedColorOverridesTheThemeHighlight,
  );
}

Future<void> _pumpSelection(
  WidgetTester tester,
  MorphSelectionController controller, {
  Color? selectedColor,
}) async {
  await tester.pumpWidget(
    MorphMaterialApp(
      data: MorphThemeData.light(seedColor: const Color(0xFF6750A4)),
      home: MorphSelection(
        controller: controller,
        itemCount: 3,
        selectedColor: selectedColor,
        appBar: const MorphSelectionAppBar(idle: SizedBox(height: 32)),
        body: MorphList.scrollable(
          itemCount: 3,
          itemBuilder: (BuildContext context, int index) =>
              MorphListItem(headline: 'Item $index'),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Color? _rowColor(WidgetTester tester, String headline) {
  final Finder card = find.ancestor(
    of: find.text(headline),
    matching: find.byType(MorphCard),
  );
  return tester.widget<MorphCard>(card.first).color;
}

Future<void> _morphselectionFillsSelectedRowsWithTheHighlightColor(
  WidgetTester tester,
) async {
  final controller = MorphSelectionController()..select(1);
  addTearDown(controller.dispose);

  await _pumpSelection(tester, controller);

  final MorphColorScheme scheme = MorphThemeData.light(
    seedColor: const Color(0xFF6750A4),
  ).colorScheme;
  expect(_rowColor(tester, 'Item 1'), scheme.secondaryContainer);
  expect(_rowColor(tester, 'Item 0'), isNot(scheme.secondaryContainer));
}

Future<void> _morphselectionSelectedColorOverridesTheThemeHighlight(
  WidgetTester tester,
) async {
  final controller = MorphSelectionController()..select(2);
  addTearDown(controller.dispose);

  await _pumpSelection(
    tester,
    controller,
    selectedColor: const Color(0xFF00FF00),
  );

  expect(_rowColor(tester, 'Item 2'), const Color(0xFF00FF00));
  expect(_rowColor(tester, 'Item 1'), isNot(const Color(0xFF00FF00)));
}
