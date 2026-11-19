import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morph_expressive/morph_expressive.dart';

import 'context_menu_support.dart';

const Offset _origin = Offset(100, 100);

Future<void> _key(WidgetTester tester, LogicalKeyboardKey key) async {
  await tester.sendKeyEvent(key);
  await tester.pump(const Duration(milliseconds: 50));
}

Future<void> _open(
  WidgetTester tester, {
  List<MorphMenuNode>? children,
  ValueChanged<Object>? onSelected,
  Offset at = _origin,
}) async {
  setContextViewport(tester);
  await tester.pumpWidget(
    contextHost(children: children, onSelected: onSelected),
  );
  await rightClick(tester, at);
}

Future<void> _hover(
  WidgetTester tester,
  TestGesture mouse,
  String label,
) async {
  await mouse.moveTo(tester.getCenter(find.text(label)));
  await tester.pump();
}

bool get _menuOpen => panelFinder.evaluate().isNotEmpty;

void main() {
  group('highlight and keyboard', () {
    testWidgets('a pointer-opened menu highlights nothing until used', (
      tester,
    ) async {
      await _open(tester);
      for (final String label in <String>['Open', 'Rename', 'Delete']) {
        expect(rowFocused(tester, label), isFalse, reason: label);
      }
    });

    testWidgets('hover moves the highlight to the hovered row', (tester) async {
      await _open(tester);
      final TestGesture mouse = await mousePointer(tester);
      await _hover(tester, mouse, 'Rename');
      expect(rowFocused(tester, 'Rename'), isTrue);
      await _hover(tester, mouse, 'Open');
      expect(rowFocused(tester, 'Open'), isTrue);
      expect(rowFocused(tester, 'Rename'), isFalse);
    });

    testWidgets('hovering a disabled row does not highlight it', (
      tester,
    ) async {
      await _open(tester);
      final TestGesture mouse = await mousePointer(tester);
      await _hover(tester, mouse, 'Rename');
      await _hover(tester, mouse, 'Disabled');
      expect(rowFocused(tester, 'Disabled'), isFalse);
      expect(rowFocused(tester, 'Rename'), isTrue);
    });

    testWidgets('arrows skip disabled rows and dividers and wrap', (
      tester,
    ) async {
      await _open(tester);
      await _key(tester, LogicalKeyboardKey.arrowDown);
      expect(rowFocused(tester, 'Open'), isTrue, reason: 'first Down = first');
      await _key(tester, LogicalKeyboardKey.arrowDown);
      expect(rowFocused(tester, 'Rename'), isTrue);
      await _key(tester, LogicalKeyboardKey.arrowDown);
      expect(rowFocused(tester, 'Move to'), isTrue, reason: 'skips disabled');
      await _key(tester, LogicalKeyboardKey.arrowDown);
      expect(rowFocused(tester, 'Delete'), isTrue);
      await _key(tester, LogicalKeyboardKey.arrowDown);
      expect(rowFocused(tester, 'Open'), isTrue, reason: 'wraps to the top');
      await _key(tester, LogicalKeyboardKey.arrowUp);
      expect(rowFocused(tester, 'Delete'), isTrue, reason: 'wraps to bottom');
      await _key(tester, LogicalKeyboardKey.arrowUp);
      expect(rowFocused(tester, 'Move to'), isTrue);
    });

    testWidgets('ArrowUp from nothing lands on the last row', (tester) async {
      await _open(tester);
      await _key(tester, LogicalKeyboardKey.arrowUp);
      expect(rowFocused(tester, 'Delete'), isTrue);
    });

    testWidgets('Home and End jump to the first and last enabled row', (
      tester,
    ) async {
      await _open(tester);
      await _key(tester, LogicalKeyboardKey.end);
      expect(rowFocused(tester, 'Delete'), isTrue);
      await _key(tester, LogicalKeyboardKey.home);
      expect(rowFocused(tester, 'Open'), isTrue);
    });

    testWidgets('Enter activates the highlighted row and closes', (
      tester,
    ) async {
      final List<Object> chosen = <Object>[];
      await _open(tester, onSelected: chosen.add);
      await _key(tester, LogicalKeyboardKey.arrowDown);
      await _key(tester, LogicalKeyboardKey.arrowDown);
      await _key(tester, LogicalKeyboardKey.enter);
      await settleMenu(tester);
      expect(chosen, <Object>['rename']);
      expect(_menuOpen, isFalse);
    });

    testWidgets('Space activates the highlighted row', (tester) async {
      final List<Object> chosen = <Object>[];
      await _open(tester, onSelected: chosen.add);
      await _key(tester, LogicalKeyboardKey.end);
      await _key(tester, LogicalKeyboardKey.space);
      await settleMenu(tester);
      expect(chosen, <Object>['delete']);
      expect(_menuOpen, isFalse);
    });

    testWidgets('Escape closes the menu and removes the overlay', (
      tester,
    ) async {
      final List<Object> chosen = <Object>[];
      await _open(tester, onSelected: chosen.add);
      await _key(tester, LogicalKeyboardKey.arrowDown);
      await _key(tester, LogicalKeyboardKey.escape);
      await settleMenu(tester);
      expect(_menuOpen, isFalse);
      expect(find.byType(MorphMenuPopup<Object>), findsNothing);
      expect(find.byType(MorphMenuItem), findsNothing);
      expect(chosen, isEmpty);
      expect(tester.takeException(), isNull);
    });

    testWidgets('a disabled row does nothing when clicked or activated', (
      tester,
    ) async {
      final List<Object> chosen = <Object>[];
      await _open(tester, onSelected: chosen.add);
      await tester.tap(find.text('Disabled'));
      await settleMenu(tester);
      expect(chosen, isEmpty);
      expect(_menuOpen, isTrue, reason: 'the menu stays open');
    });

    testWidgets('clicking a row selects it and closes', (tester) async {
      final List<Object> chosen = <Object>[];
      await _open(tester, onSelected: chosen.add);
      await tester.tap(find.text('Open'));
      await settleMenu(tester);
      expect(chosen, <Object>['open']);
      expect(_menuOpen, isFalse);
    });
  });

  group('submenus', () {
    Finder design() => find.text('Design');

    testWidgets('hover opens after the short delay, not before', (
      tester,
    ) async {
      await _open(tester);
      final TestGesture mouse = await mousePointer(tester);
      await _hover(tester, mouse, 'Move to');
      await tester.pump(const Duration(milliseconds: 80));
      expect(design(), findsNothing, reason: 'before the 120 ms delay');
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 200));
      expect(design(), findsOneWidget);
      // Opens beside the parent, first row aligned with the owner row.
      final Rect parent = surfaceRect(tester);
      final Rect sub = surfaceRect(tester, deepest: true);
      expect(sub.left, greaterThanOrEqualTo(parent.right - 4));
      expect(sub.top, closeTo(rowRect(tester, 'Move to').top - 4, 1));
      // Hover-opening does not steal the highlight from the parent row.
      expect(rowFocused(tester, 'Move to'), isTrue);
    });

    testWidgets('Right opens the submenu and focuses its first row', (
      tester,
    ) async {
      await _open(tester);
      await _key(tester, LogicalKeyboardKey.arrowDown);
      await _key(tester, LogicalKeyboardKey.arrowDown);
      await _key(tester, LogicalKeyboardKey.arrowDown);
      expect(rowFocused(tester, 'Move to'), isTrue);
      await _key(tester, LogicalKeyboardKey.arrowRight);
      await tester.pump(const Duration(milliseconds: 200));
      expect(design(), findsOneWidget);
      expect(rowFocused(tester, 'Design'), isTrue);
    });

    testWidgets('Left closes the submenu and refocuses its owner', (
      tester,
    ) async {
      await _open(tester);
      await _key(tester, LogicalKeyboardKey.end);
      await _key(tester, LogicalKeyboardKey.arrowUp);
      await _key(tester, LogicalKeyboardKey.arrowRight);
      await tester.pump(const Duration(milliseconds: 200));
      expect(design(), findsOneWidget);
      await _key(tester, LogicalKeyboardKey.arrowLeft);
      await tester.pump(const Duration(milliseconds: 200));
      expect(design(), findsNothing);
      expect(_menuOpen, isTrue);
      expect(rowFocused(tester, 'Move to'), isTrue);
    });

    testWidgets('Escape closes the submenu first, then the menu', (
      tester,
    ) async {
      await _open(tester);
      await _key(tester, LogicalKeyboardKey.end);
      await _key(tester, LogicalKeyboardKey.arrowUp);
      await _key(tester, LogicalKeyboardKey.arrowRight);
      await tester.pump(const Duration(milliseconds: 200));
      await _key(tester, LogicalKeyboardKey.escape);
      await tester.pump(const Duration(milliseconds: 200));
      expect(design(), findsNothing);
      expect(find.text('Rename'), findsOneWidget, reason: 'root still open');
      await _key(tester, LogicalKeyboardKey.escape);
      await settleMenu(tester);
      expect(_menuOpen, isFalse);
    });

    testWidgets('Escape closes a hover-opened submenu before the menu', (
      tester,
    ) async {
      await _open(tester);
      final TestGesture mouse = await mousePointer(tester);
      await _hover(tester, mouse, 'Move to');
      await tester.pump(const Duration(milliseconds: 300));
      expect(design(), findsOneWidget);
      await _key(tester, LogicalKeyboardKey.escape);
      await tester.pump(const Duration(milliseconds: 200));
      expect(design(), findsNothing);
      expect(find.text('Rename'), findsOneWidget);
    });

    testWidgets('travelling toward the submenu does not close it', (
      tester,
    ) async {
      await _open(tester);
      final TestGesture mouse = await mousePointer(tester);
      await _hover(tester, mouse, 'Move to');
      await tester.pump(const Duration(milliseconds: 300));
      expect(design(), findsOneWidget);

      final Rect parent = surfaceRect(tester);
      final Rect owner = rowRect(tester, 'Move to');
      // Diagonal run toward the submenu, crossing the plain row below.
      final Offset down = Offset(parent.right - 12, owner.center.dy + 32);
      await mouse.moveTo(down);
      await tester.pump(const Duration(milliseconds: 200));
      expect(design(), findsOneWidget, reason: 'inside the safe triangle');
      // Arriving in the submenu keeps it open indefinitely.
      await mouse.moveTo(tester.getCenter(design()));
      await tester.pump(const Duration(seconds: 1));
      expect(design(), findsOneWidget);
    });

    double ownerFill(WidgetTester tester) {
      final Finder containers = find.descendant(
        of: find.ancestor(
          of: find.text('Move to'),
          matching: find.byType(MorphMenuItem),
        ),
        matching: find.byType(Container),
      );
      for (final Element e in containers.evaluate()) {
        final Decoration? d = (e.widget as Container).decoration;
        if (d is BoxDecoration && d.color != null) {
          return d.color!.a;
        }
      }
      return 0;
    }

    testWidgets('the owner row stays highlighted while its submenu is open', (
      tester,
    ) async {
      await _open(tester);
      final TestGesture mouse = await mousePointer(tester);
      await _hover(tester, mouse, 'Move to');
      await tester.pump(const Duration(milliseconds: 300));
      expect(design(), findsOneWidget);
      await mouse.moveTo(tester.getCenter(design()));
      await tester.pump(const Duration(milliseconds: 50));
      expect(ownerFill(tester), greaterThan(0), reason: 'owner stays lit');
      await _key(tester, LogicalKeyboardKey.escape);
      await tester.pump(const Duration(milliseconds: 200));
      expect(design(), findsNothing);
      expect(ownerFill(tester), 0, reason: 'dropped with the submenu');
    });

    testWidgets('keyboard-opened submenus also light the owner row', (
      tester,
    ) async {
      await _open(tester);
      await _key(tester, LogicalKeyboardKey.end);
      await _key(tester, LogicalKeyboardKey.arrowUp);
      await _key(tester, LogicalKeyboardKey.arrowRight);
      await tester.pump(const Duration(milliseconds: 200));
      expect(rowFocused(tester, 'Design'), isTrue);
      expect(ownerFill(tester), greaterThan(0));
    });

    testWidgets('moving away from the submenu closes it after the grace', (
      tester,
    ) async {
      await _open(tester);
      final TestGesture mouse = await mousePointer(tester);
      await _hover(tester, mouse, 'Move to');
      await tester.pump(const Duration(milliseconds: 300));
      expect(design(), findsOneWidget);
      await _hover(tester, mouse, 'Open');
      await tester.pump(const Duration(milliseconds: 100));
      expect(design(), findsOneWidget, reason: 'grace period still running');
      await tester.pump(const Duration(milliseconds: 400));
      expect(design(), findsNothing);
      expect(_menuOpen, isTrue);
    });

    testWidgets('the submenu flips to the left when there is no room', (
      tester,
    ) async {
      const Size narrow = Size(460, 600);
      setContextViewport(tester, narrow);
      await tester.pumpWidget(contextHost());
      await rightClick(tester, const Offset(200, 100));
      final TestGesture mouse = await mousePointer(
        tester,
        const Offset(10, 500),
      );
      await _hover(tester, mouse, 'Move to');
      await tester.pump(const Duration(milliseconds: 300));
      expect(design(), findsOneWidget);
      final Rect parent = surfaceRect(tester);
      final Rect sub = surfaceRect(tester, deepest: true);
      expect(sub.right, lessThanOrEqualTo(parent.left + 6));
      expect(sub.left, greaterThanOrEqualTo(7.5));
    });

    testWidgets('a tall submenu shifts up to stay in the viewport', (
      tester,
    ) async {
      const Size size = Size(800, 400);
      setContextViewport(tester, size);
      await tester.pumpWidget(
        contextHost(
          children: <MorphMenuNode>[
            const MorphMenuEntry(label: 'First', value: 'f'),
            const MorphMenuEntry(label: 'Second', value: 's'),
            MorphMenuSubmenu(
              label: 'Many',
              children: <MorphMenuNode>[
                for (var i = 0; i < 8; i++)
                  MorphMenuEntry(label: 'Child $i', value: 'c$i'),
              ],
            ),
          ],
        ),
      );
      await rightClick(tester, const Offset(100, 250));
      final TestGesture mouse = await mousePointer(
        tester,
        const Offset(700, 50),
      );
      await _hover(tester, mouse, 'Many');
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Child 0'), findsOneWidget);
      final Rect sub = surfaceRect(tester, deepest: true);
      expect(sub.bottom, lessThanOrEqualTo(size.height - 7.5));
      expect(sub.top, greaterThanOrEqualTo(7.5));
    });
  });

  group('dismissal and lifecycle', () {
    testWidgets('clicking outside closes the menu', (tester) async {
      await _open(tester);
      await tester.tapAt(const Offset(600, 450));
      await settleMenu(tester);
      expect(_menuOpen, isFalse);
      expect(find.byType(MorphMenuItem), findsNothing);
    });

    testWidgets('right click elsewhere reopens at the new position', (
      tester,
    ) async {
      await _open(tester);
      await rightClick(tester, const Offset(400, 300));
      expect(panelFinder, findsOneWidget);
      final Rect surface = surfaceRect(tester);
      expect(surface.left, closeTo(400, 1));
      expect(surface.top, closeTo(300, 1));
    });

    testWidgets('tearing the host down with timers pending is clean', (
      tester,
    ) async {
      await _open(tester);
      final TestGesture mouse = await mousePointer(tester);
      await _hover(tester, mouse, 'Move to'); // Hover timer pending.
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 1));
      expect(tester.takeException(), isNull);
    });

    testWidgets('density and brightness changes while open do not throw', (
      tester,
    ) async {
      await _open(tester);
      expect(rowRect(tester, 'Rename').height, 32);
      await tester.pumpWidget(
        contextHost(density: MorphDensity.comfortable, dark: true),
      );
      await tester.pump(const Duration(milliseconds: 50));
      expect(tester.takeException(), isNull);
      expect(panelFinder, findsOneWidget);
      expect(rowRect(tester, 'Rename').height, 40);
      await tester.pumpWidget(contextHost(density: MorphDensity.compact));
      await tester.pump(const Duration(milliseconds: 50));
      expect(tester.takeException(), isNull);
      expect(rowRect(tester, 'Rename').height, 28);
    });

    testWidgets('open and close durations are short', (tester) async {
      setContextViewport(tester);
      await tester.pumpWidget(contextHost());
      await rightClick(tester, _origin, settle: false);
      await tester.pump(const Duration(milliseconds: 150));
      final Finder opacity = find.byKey(
        const ValueKey<String>('morph-popup-panel-opacity'),
      );
      expect(tester.widget<Opacity>(opacity).opacity, 1.0);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(panelFinder, findsNothing, reason: 'gone within ~90 ms close');
    });

    testWidgets('reduced motion opens and closes without animation', (
      tester,
    ) async {
      setContextViewport(tester);
      tester.platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures(disableAnimations: true);
      addTearDown(
        tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
      );
      await tester.pumpWidget(contextHost());
      await rightClick(tester, _origin, settle: false);
      await tester.pump();
      expect(panelFinder, findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump();
      expect(panelFinder, findsNothing);
    });
  });
}
