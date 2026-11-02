import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart' show Size, ValueKey;
import 'package:flutter_test/flutter_test.dart';
import 'package:morph_expressive_preview/main.dart';

Future<void> _secondaryClick(WidgetTester tester, Finder target) async {
  final gesture = await tester.startGesture(
    tester.getCenter(target),
    kind: PointerDeviceKind.mouse,
    buttons: kSecondaryMouseButton,
  );
  await gesture.up();
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 60));
  await tester.pump(const Duration(milliseconds: 60));
  await tester.pump(const Duration(milliseconds: 60));
}

void _desktopViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(1440, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

void main() {
  testWidgets('haptics menu opens and closes with Semantics enabled', (
    tester,
  ) async {
    _desktopViewport(tester);
    await tester.pumpWidget(const MorphPreviewApp());
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    await tester.tap(find.byTooltip('Haptic settings'));
    await tester.pumpAndSettle();
    expect(find.text('Medium'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Medium'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    // Verify the original route is still interactive after the popup closes.
    await tester.tap(find.byTooltip('Desktop context menu preview'));
    await tester.pumpAndSettle();
    expect(find.text('Validate desktop replacement behavior'), findsOneWidget);
    expect(tester.takeException(), isNull);
  }, semanticsEnabled: true);

  testWidgets(
    'desktop context menus replace each other with Semantics enabled',
    (tester) async {
      _desktopViewport(tester);
      await tester.pumpWidget(const MorphPreviewApp());
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      await tester.tap(find.byTooltip('Desktop context menu preview'));
      await tester.pumpAndSettle();
      expect(
        find.text('Validate desktop replacement behavior'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);

      await _secondaryClick(
        tester,
        find.byKey(const ValueKey<String>('desktop-context-target-A')),
      );
      expect(
        find.textContaining('Opened menu for Workspace A at'),
        findsOneWidget,
        reason: 'Secondary click must reach the workspace rather than a scrim.',
      );
      expect(find.text('Open Workspace A'), findsOneWidget);
      expect(tester.takeException(), isNull);

      await _secondaryClick(
        tester,
        find.byKey(const ValueKey<String>('desktop-context-target-B')),
      );
      expect(
        find.textContaining('Opened menu for Workspace B at'),
        findsOneWidget,
      );
      expect(find.text('Open Workspace A'), findsNothing);
      expect(find.text('Open Workspace B'), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
    semanticsEnabled: true,
  );
}
