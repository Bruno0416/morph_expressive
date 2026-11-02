import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart' show Size, ValueKey;
import 'package:flutter_test/flutter_test.dart';

import 'package:morph_expressive_preview/main.dart';

Future<void> _rightClick(WidgetTester tester, Finder finder) async {
  final TestGesture gesture = await tester.startGesture(
    tester.getCenter(finder),
    kind: PointerDeviceKind.mouse,
    buttons: kSecondaryMouseButton,
  );
  await gesture.up();
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 60));
  await tester.pump(const Duration(milliseconds: 60));
  await tester.pump(const Duration(milliseconds: 60));
}

void main() {
  testWidgets('desktop context menu lab opens and replaces menus', (
    WidgetTester tester,
  ) async {
    // The desktop lab intentionally uses a wide multi-column layout.
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MorphPreviewApp());

    await tester.tap(find.byTooltip('Desktop context menu preview'));
    await tester.pumpAndSettle();

    expect(find.text('Desktop context menu preview'), findsOneWidget);
    expect(find.text('Validate desktop replacement behavior'), findsOneWidget);

    final Finder targetA = find.byKey(
      const ValueKey<String>('desktop-context-target-A'),
    );
    final Finder targetB = find.byKey(
      const ValueKey<String>('desktop-context-target-B'),
    );

    await _rightClick(tester, targetA);
    expect(find.text('Open Workspace A'), findsOneWidget);

    await _rightClick(tester, targetB);
    expect(find.text('Open Workspace A'), findsNothing);
    expect(find.text('Open Workspace B'), findsOneWidget);

    await tester.tap(find.text('Move Workspace B to'));
    await tester.pumpAndSettle(const Duration(milliseconds: 50));
    expect(find.text('Archive'), findsOneWidget);

    await _rightClick(tester, targetA);
    expect(find.text('Open Workspace B'), findsNothing);
    expect(find.text('Archive'), findsNothing);
    expect(find.text('Open Workspace A'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
