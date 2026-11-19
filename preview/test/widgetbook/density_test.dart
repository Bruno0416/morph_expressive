import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart' show Material;
import 'package:morph_expressive/morph_expressive.dart';
import 'package:morph_expressive_preview/widgetbook/addons/morph_scope_addon.dart';

import 'support.dart';

String _path(String suffix) =>
    allUseCases().firstWhere((u) => u.path.endsWith(suffix)).path;

Future<void> _setMorph(WidgetTester tester, String field, String value) async {
  stateOf(tester).updateQueryField(group: 'morph', field: field, value: value);
  await tester.pump(const Duration(milliseconds: 300));
}

/// Painted height of a button. The layout box is inflated to the 48 dp
/// accessible target, so the visual surface is the Material below it.
double _visualHeight(WidgetTester tester, Finder button) => tester
    .getSize(find.descendant(of: button, matching: find.byType(Material)).first)
    .height;

double _buttonHeight(WidgetTester tester) =>
    _visualHeight(tester, find.byType(MorphButton).first);

void main() {
  testWidgets('the Morph addon density control changes the real theme', (
    tester,
  ) async {
    await openUseCase(tester, _path('buttons/morphbutton/playground'));
    MorphDensity density() =>
        MorphTheme.of(tester.element(find.byType(MorphButton).first)).density;

    expect(density(), MorphDensity.standard);
    final standard = _buttonHeight(tester);

    await _setMorph(tester, 'density', 'Compact');
    expect(density(), MorphDensity.compact);
    final compact = _buttonHeight(tester);

    await _setMorph(tester, 'density', 'Comfortable');
    expect(density(), MorphDensity.comfortable);
    final comfortable = _buttonHeight(tester);

    expect(compact, lessThan(standard));
    expect(comfortable, greaterThan(standard));
    expect(tester.takeException(), isNull);
  });

  testWidgets('the root scope (dialogs) follows the density control', (
    tester,
  ) async {
    await openUseCase(tester, _path('buttons/morphbutton/playground'));
    await _setMorph(tester, 'density', 'Compact');
    // Published after the frame; one more pump lets the root scope rebuild.
    await tester.pump(const Duration(milliseconds: 50));
    expect(activeMorphScope.value?.density, MorphDensity.compact);
  });

  testWidgets('density lab columns are three real themes', (tester) async {
    await openUseCase(tester, _path('density/morphdensity/overview'));
    final buttons = find.byType(MorphButton);
    expect(buttons, findsNWidgets(3));
    final densities = [
      for (var i = 0; i < 3; i++)
        MorphTheme.of(tester.element(buttons.at(i))).density,
    ];
    expect(densities, MorphDensity.values);
    final heights = [
      for (var i = 0; i < 3; i++) _visualHeight(tester, buttons.at(i)),
    ];
    expect(heights, [36.0, 40.0, 44.0]);
    // The accessible target stays 48 in every density.
    for (var i = 0; i < 3; i++) {
      expect(tester.getSize(buttons.at(i)).height, 48);
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('density lab spacing prints per-column metrics', (tester) async {
    await openUseCase(tester, _path('density/morphdensity/spacing-&-tokens'));
    expect(find.text('Compact'), findsWidgets);
    expect(find.text('Comfortable'), findsWidgets);
    expect(find.text('rowHeight'), findsNWidgets(3));
    expect(tester.takeException(), isNull);
  });
}
