import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morph_expressive_preview/main.dart';

void main() {
  testWidgets('native touch lab renders at phone width', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MorphPreviewApp(mobileLab: true));
    await tester.pump();

    expect(find.text('Morph · Touch Lab'), findsOneWidget);
    expect(find.text('Enable Morph haptics'), findsOneWidget);
    expect(find.text('Tap / hold'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
