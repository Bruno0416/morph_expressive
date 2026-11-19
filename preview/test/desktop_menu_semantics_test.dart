import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart' show Size, ValueKey;
import 'package:flutter_test/flutter_test.dart';

import 'widgetbook/support.dart';

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

void main() {
  testWidgets(
    'desktop context menus replace each other with Semantics enabled',
    (tester) async {
      await openUseCase(
        tester,
        'overlays/menus/morphmenupopup/desktop-context-menu-lab',
        size: const Size(1440, 900),
      );
      expect(tester.takeException(), isNull);
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
