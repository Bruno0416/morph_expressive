import 'package:flutter_test/flutter_test.dart';
import 'package:morph_expressive/morph_expressive.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  test('application TextTheme is respected in light and dark Morph themes', () {
    final appFonts = ThemeData().textTheme.apply(fontFamily: 'serif');
    for (final factory in [MorphThemeData.light, MorphThemeData.dark]) {
      final theme = factory(textTheme: appFonts);
      expect(theme.textTheme.bodyMedium?.fontFamily, 'serif');
      expect(theme.toThemeData().textTheme.bodyLarge?.fontFamily, 'serif');
    }
  });

  test('tooltips use current scheme, capsule defaults and custom shapes', () {
    const tooltip = MorphTooltipTheme();
    expect(tooltip.plainShape, isA<StadiumBorder>());
    for (final theme in [MorphThemeData.light(), MorphThemeData.dark()]) {
      expect(tooltip.plainContainerColor(theme.colorScheme),
          theme.colorScheme.surfaceContainerHigh);
      expect(tooltip.plainMessageStyle(theme.typeScale, theme.colorScheme).color,
          theme.colorScheme.onSurface);
    }
    expect(tooltip.copyWith(plainShape: const CircleBorder()).plainShape,
        isA<CircleBorder>());
  });

  test('dropdown search minimum height is configurable', () {
    const search = MorphDropdownSearchStyle();
    expect(search.minHeight, 52);
    expect(search.copyWith(minHeight: 52).minHeight, 52);
  });

  testWidgets('MorphChipToggle exposes the Morph selection API', (tester) async {
    String selected = 'flutter';
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: MorphChipToggle<String>(
          selected: selected,
          onChanged: (value) => selected = value,
          options: const [
            MorphChipToggleOption(value: 'flutter', label: 'Flutter'),
            MorphChipToggleOption(value: 'dart', label: 'Dart'),
          ],
        ),
      ),
    ));
    await tester.tap(find.text('Dart'));
    expect(selected, 'dart');
  });

  test('dropdown uses a softer, non-bouncing closing spring', () {
    expect(MorphMotion.dropdownOpen.damping, lessThan(1));
    expect(MorphMotion.dropdownClose.stiffness,
        lessThan(MorphMotion.dropdownOpen.stiffness));
    expect(MorphMotion.dropdownClose.damping, greaterThanOrEqualTo(1));
    expect(MorphMotion.buttonMorph.damping, lessThan(1));
  });
}
