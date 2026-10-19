import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morph_expressive/foundations/foundations.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  test('overlayStyle uses transparent bars and light icons', () {
    const SystemUiOverlayStyle style = MorphScrimSystemUi.overlayStyle;

    expect(style.statusBarColor, Colors.transparent);
    expect(style.systemNavigationBarColor, Colors.transparent);
    expect(style.statusBarIconBrightness, Brightness.light);
    expect(style.systemNavigationBarIconBrightness, Brightness.light);
    expect(style.statusBarBrightness, Brightness.light);
    expect(style.systemStatusBarContrastEnforced, isFalse);
    expect(style.systemNavigationBarContrastEnforced, isFalse);
  });

  test('bottomSheetOverlayStyle uses light status bar icons only', () {
    const SystemUiOverlayStyle style =
        MorphScrimSystemUi.bottomSheetOverlayStyle;

    expect(style.statusBarColor, Colors.transparent);
    expect(style.statusBarIconBrightness, Brightness.light);
    expect(style.statusBarBrightness, Brightness.light);
    expect(style.systemStatusBarContrastEnforced, isFalse);
    expect(style.systemNavigationBarIconBrightness, isNull);
    expect(style.systemNavigationBarColor, isNull);
    expect(style.systemNavigationBarContrastEnforced, isNull);
  });

  testWidgets('wrap applies AnnotatedRegion with overlayStyle', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(home: MorphScrimSystemUi.wrap(const SizedBox.shrink())),
    );

    final AnnotatedRegion<SystemUiOverlayStyle> region = tester.widget(
      find.byType(AnnotatedRegion<SystemUiOverlayStyle>),
    );

    expect(region.value, MorphScrimSystemUi.overlayStyle);
  });

  testWidgets(
    'wrapBottomSheet applies AnnotatedRegion with bottomSheetOverlayStyle',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MorphScrimSystemUi.wrapBottomSheet(const SizedBox.shrink()),
        ),
      );

      final AnnotatedRegion<SystemUiOverlayStyle> region = tester.widget(
        find.byType(AnnotatedRegion<SystemUiOverlayStyle>),
      );

      expect(region.value, MorphScrimSystemUi.bottomSheetOverlayStyle);
    },
  );
}
