import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morph_expressive_preview/frosted_blur_benchmark_lab.dart';

void main() {
  testWidgets('lab renders distinct backdrop filters for each selected panel', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MorphFrostedBlurBenchmarkLab());
    await tester.pump();

    expect(find.byType(BackdropFilter), findsNWidgets(4));
    expect(
      find.byKey(const ValueKey('frosted-benchmark-panel-3')),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const ValueKey('frosted-panel-count')));
    await tester.pump();
    await tester.tap(find.text('8').last);
    await tester.pump();

    expect(find.byType(BackdropFilter), findsNWidgets(8));
    expect(
      find.byKey(const ValueKey('frosted-benchmark-panel-7')),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const ValueKey('frosted-mode-none')));
    await tester.pump();
    expect(find.byType(BackdropFilter), findsNothing);
  });
}
