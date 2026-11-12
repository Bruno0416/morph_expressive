import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morph_expressive/morph_expressive.dart';
import 'package:morph_expressive_preview/operation_loading_lab.dart';

void main() {
  polishLabTests();
  for (final width in [390.0, 1440.0]) {
    testWidgets('operation lab at $width with text 2x', (tester) async {
      tester.view.physicalSize = Size(width, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MorphMaterialApp(
          data: MorphThemeData.light(),
          home: const OperationLoadingLab(),
        ),
      );
      await tester.tap(find.text('Text 2×: false'));
      await tester.pump(const Duration(milliseconds: 400));
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('loading').first);
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byType(MorphAsyncButton), findsWidgets);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    });
  }
}

void polishLabTests() {
  for (final width in [390.0, 1440.0]) {
    testWidgets('polish sections at $width: RTL, 2x, narrow, all modes', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MorphMaterialApp(
          data: MorphThemeData.light(),
          home: const OperationLoadingLab(),
        ),
      );
      for (final t in ['RTL: false', 'Text 2×: false']) {
        await tester.tap(find.text(t));
        await tester.pump(const Duration(milliseconds: 100));
      }
      Future<void> tapText(String text) async {
        final f = find.text(text).first;
        await tester.ensureVisible(f);
        await tester.pump();
        await tester.tap(f);
        await tester.pump(const Duration(milliseconds: 150));
      }

      await tapText('Loading → success');
      await tester.pump(const Duration(milliseconds: 1600));
      await tapText('Interrupt during entry');
      await tester.pump(const Duration(milliseconds: 1500));
      await tapText('Container: wide 560');
      await tapText('fit uniform');
      await tapText('Custom radii: false');
      await tapText('Month');
      await tester.pump(const Duration(seconds: 1));
      await tapText('-30°');
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(MorphReactiveButtonGroup), findsWidgets);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    });
  }
}
