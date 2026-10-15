import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morph_expressive/morph_components.dart';

void main() {
  test('split menu primary palette follows current theme seed', () {
    for (final theme in <MorphThemeData>[
      MorphThemeData.light(seedColor: const Color(0xFF6750A4)),
      MorphThemeData.dark(seedColor: const Color(0xFF6750A4)),
    ]) {
      final primary = theme.menuTheme.colors(
        theme.colorScheme,
        MorphMenuColorStyle.primary,
      );
      final regular = theme.menuTheme.colors(theme.colorScheme);
      expect(primary.selectedContainer, theme.colorScheme.primaryContainer);
      expect(primary.selectedContent, theme.colorScheme.onPrimaryContainer);
      expect(regular.selectedContainer, theme.colorScheme.tertiaryContainer);
    }
  });

  testWidgets('slider indicator fits the measured value and tooltip padding',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MorphMaterialApp(
        data: MorphThemeData.light(seedColor: const Color(0xFF6750A4)),
        home: Center(
          child: Builder(builder: (BuildContext context) {
            final theme = MorphTheme.of(context);
            return MorphSliderValueIndicator(
              label: '0.60',
              colors: theme.sliderTheme.colors(theme.colorScheme, enabled: true),
            );
          }),
        ),
      ),
    );
    expect(tester.getSize(find.byType(MorphSliderValueIndicator)).width,
        greaterThan(48));
    expect(find.text('0.60'), findsOneWidget);
  });
}
