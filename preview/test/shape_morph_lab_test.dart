import 'package:material_ui/material_ui.dart' show MaterialApp, SizedBox;
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart'
    show MediaQuery, MediaQueryData, TextScaler, Size, Brightness;
import 'package:morph_expressive/morph_expressive.dart';
import 'package:morph_expressive_preview/shape_morph_lab.dart';

void main() {
  testWidgets('lab fits mobile at 2x text in both brightness modes', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    for (final brightness in Brightness.values) {
      await tester.pumpWidget(
        MaterialApp(
          home: MorphTheme(
            data: brightness == Brightness.dark
                ? MorphThemeData.dark()
                : MorphThemeData.light(),
            child: MediaQuery(
              data: MediaQueryData(
                size: const Size(390, 844),
                textScaler: TextScaler.linear(2),
              ),
              child: const ShapeMorphLab(),
            ),
          ),
        ),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);
      for (final title in [
        'E · Shape buttons',
        'D2 · Loader inset (contained vs plain)',
        'B2 · Edge quality (Canvas vs Shader)',
        'F · Connected groups',
      ]) {
        await tester.ensureVisible(find.text(title));
        await tester.pump();
        expect(tester.takeException(), isNull, reason: title);
      }
      await tester.pumpWidget(const SizedBox());
    }
  });
  testWidgets('lab exposes real morph controls and button counter', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: ShapeMorphLab()));
    expect(find.byType(MorphShapeView), findsWidgets);
    MorphShapeView geometry() => tester
        .widgetList<MorphShapeView>(find.byType(MorphShapeView))
        .firstWhere((v) => v.size == const Size(160, 160));
    final before = geometry().contour;
    await tester.ensureVisible(find.text('Retarget C'));
    await tester.pump();
    await tester.tap(find.text('Retarget C'));
    await tester.pump(const Duration(milliseconds: 80));
    final after = geometry().contour;
    expect(after, isNot(same(before)));
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });
  testWidgets('lab fits desktop width and exposes main spinning shape button', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MaterialApp(home: ShapeMorphLab()));
    await tester.pump();
    final buttons = tester
        .widgetList<MorphShapeButton>(find.byType(MorphShapeButton))
        .toList();
    expect(buttons.first.rotationEnabled, isTrue);
    expect(buttons.first.pressedShape, isNull, reason: 'main demo: no morph');
    expect(buttons[1].rotationEnabled, isFalse, reason: 'comparison');
    expect(buttons[2].pressedShape, isNotNull, reason: 'opt-in morph demo');
    await tester.ensureVisible(find.text('F · Connected groups'));
    await tester.pump();
    final groups = tester
        .widgetList<MorphButtonGroup>(find.byType(MorphButtonGroup))
        .toList();
    expect(groups, isNotEmpty);
    expect(
      groups.every((g) => g.type == MorphButtonGroupType.connected),
      isTrue,
    );
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });
}
