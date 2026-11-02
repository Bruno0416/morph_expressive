import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morph_expressive/morph_expressive.dart' show FluentIcons;
import 'package:morph_expressive_preview/main.dart';

void main() {
  testWidgets('frosted lab is the mobile home and opens the touch lab', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MorphPreviewApp(mobileLab: true));
    await tester.pump();

    // The frosted surfaces lab is now the primary mobile screen.
    expect(find.text('Frosted Surfaces'), findsOneWidget);
    expect(find.text('Frosted glass'), findsOneWidget);

    // The existing haptics lab stays reachable from it.
    await tester.tap(find.byIcon(FluentIcons.line.phone_vibrate));
    await tester.pumpAndSettle();

    expect(find.text('Morph · Touch Lab'), findsOneWidget);
    expect(find.text('Enable Morph haptics'), findsOneWidget);
    expect(find.text('Tap / hold'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
