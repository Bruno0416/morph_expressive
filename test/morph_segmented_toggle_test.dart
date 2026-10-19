import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:morph_expressive/morph_expressive.dart';

void main() {
  final theme = MorphThemeData.light(seedColor: const Color(0xFF6750A4));

  testWidgets('MorphSegmentedToggle updates exclusive selection', (
    tester,
  ) async {
    String value = 'Movies';
    await tester.pumpWidget(
      MorphMaterialApp(
        data: theme,
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) => SizedBox(
              width: 360,
              child: MorphSegmentedToggle<String>(
                options: const [
                  MorphSegmentedToggleOption(value: 'Movies', label: 'Movies'),
                  MorphSegmentedToggleOption(value: 'TV', label: 'TV Shows'),
                ],
                selected: value,
                onChanged: (next) => setState(() => value = next),
              ),
            ),
          ),
        ),
      ),
    );
    expect(value, 'Movies');
    await tester.tap(find.text('TV Shows'));
    await tester.pump();
    expect(value, 'TV');
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('MorphSegmentedToggle keeps the latest rapid selection', (
    tester,
  ) async {
    String value = 'Movies';
    await tester.pumpWidget(
      MorphMaterialApp(
        data: theme,
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) => SizedBox(
              width: 360,
              child: MorphSegmentedToggle<String>(
                options: const [
                  MorphSegmentedToggleOption(value: 'Movies', label: 'Movies'),
                  MorphSegmentedToggleOption(value: 'TV', label: 'TV Shows'),
                ],
                selected: value,
                onChanged: (next) => setState(() => value = next),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('TV Shows'));
    await tester.pump(const Duration(milliseconds: 20));
    await tester.tap(find.text('Movies'));
    await tester.pumpAndSettle();
    expect(value, 'Movies');
    expect(tester.takeException(), isNull);
  });

  test('TextField Morph corner defaults and theme overrides', () {
    final base = MorphTextFieldTheme.defaults;
    expect(base.filledShape.topLeft.x, 18);
    expect(base.outlinedShape.bottomRight.x, 18);
    expect(base.shapeAt(MorphTextFieldVariant.outlined, 1).topLeft.x, 24);
    expect(base.shapeAt(MorphTextFieldVariant.filled, 0.5).topLeft.x, 21);
    final custom = base.copyWith(
      focusedOutlinedShape: BorderRadius.circular(30),
    );
    expect(custom.shapeAt(MorphTextFieldVariant.outlined, 1).topLeft.x, 30);
  });
}
