import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart' show Scaffold, Text, TextButton;
import 'package:morph_expressive/morph_expressive.dart';

Widget _host({
  MorphMenuSubmenuBehavior behavior = const MorphMenuSubmenuBehavior(),
  TextDirection direction = TextDirection.ltr,
  List<String>? chosen,
}) => MorphMaterialApp(
  data: MorphThemeData.light(),
  // Above the Navigator, so the overlay (where menus live) is RTL too.
  appBuilder: (context, child) =>
      Directionality(textDirection: direction, child: child!),
  home: Directionality(
    textDirection: direction,
    child: Scaffold(
      body: Align(
        alignment: Alignment.topLeft,
        child: MorphMenu(
          submenuBehavior: behavior,
          onSelected: (v) => chosen?.add('$v'),
          anchorBuilder: (context, open) =>
              TextButton(onPressed: open, child: const Text('open')),
          children: const <MorphMenuNode>[
            MorphMenuEntry(label: 'First', value: 'first'),
            MorphMenuSubmenu(
              label: 'More',
              children: <MorphMenuNode>[
                MorphMenuEntry(label: 'Sub one', value: 'sub1'),
                MorphMenuEntry(label: 'Sub two', value: 'sub2'),
              ],
            ),
            MorphMenuSubmenu(
              label: 'Other',
              children: <MorphMenuNode>[
                MorphMenuEntry(label: 'Deep', value: 'deep'),
              ],
            ),
            MorphMenuEntry(label: 'Last', value: 'last'),
          ],
        ),
      ),
    ),
  ),
);

Future<void> _openMenu(WidgetTester tester) async {
  await tester.tap(find.text('open'));
  await tester.pump();
  await tester.pumpAndSettle(const Duration(milliseconds: 50));
}

Future<TestGesture> _mouse(WidgetTester tester) async {
  final g = await tester.createGesture(kind: PointerDeviceKind.mouse);
  await g.addPointer(location: const Offset(700, 500));
  addTearDown(g.removePointer);
  return g;
}

Finder get _sub => find.text('Sub one');

void main() {
  testWidgets('hover opens after the delay, not before', (tester) async {
    await tester.pumpWidget(_host());
    await _openMenu(tester);
    final mouse = await _mouse(tester);
    await mouse.moveTo(tester.getCenter(find.text('More')));
    await tester.pump(const Duration(milliseconds: 120));
    expect(_sub, findsNothing, reason: 'before the 200 ms delay');
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pumpAndSettle(const Duration(milliseconds: 50));
    expect(_sub, findsOneWidget);
  });

  testWidgets('crossing from parent row to the submenu keeps it open', (
    tester,
  ) async {
    await tester.pumpWidget(_host());
    await _openMenu(tester);
    final mouse = await _mouse(tester);
    await mouse.moveTo(tester.getCenter(find.text('More')));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle(const Duration(milliseconds: 50));
    expect(_sub, findsOneWidget);
    // Leave the parent (through the gap) and enter the submenu in < 250 ms.
    final target = tester.getCenter(_sub);
    await mouse.moveTo(
      Offset(
        (tester.getCenter(find.text('More')).dx + target.dx) / 2,
        target.dy,
      ),
    );
    await tester.pump(const Duration(milliseconds: 80));
    await mouse.moveTo(target);
    await tester.pump(const Duration(milliseconds: 400));
    expect(_sub, findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('moving to another row cancels the pending open', (tester) async {
    await tester.pumpWidget(_host());
    await _openMenu(tester);
    final mouse = await _mouse(tester);
    await mouse.moveTo(tester.getCenter(find.text('More')));
    await tester.pump(const Duration(milliseconds: 100));
    await mouse.moveTo(tester.getCenter(find.text('Last')));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle(const Duration(milliseconds: 50));
    expect(_sub, findsNothing);
  });

  testWidgets('switching branches opens only one submenu at a time', (
    tester,
  ) async {
    await tester.pumpWidget(_host());
    await _openMenu(tester);
    final mouse = await _mouse(tester);
    await mouse.moveTo(tester.getCenter(find.text('More')));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle(const Duration(milliseconds: 50));
    expect(_sub, findsOneWidget);
    await mouse.moveTo(tester.getCenter(find.text('Other')));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle(const Duration(milliseconds: 50));
    expect(find.text('Deep'), findsOneWidget);
    expect(_sub, findsNothing);
  });

  testWidgets('leaving parent and submenu closes it after the grace period', (
    tester,
  ) async {
    await tester.pumpWidget(_host());
    await _openMenu(tester);
    final mouse = await _mouse(tester);
    await mouse.moveTo(tester.getCenter(find.text('More')));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle(const Duration(milliseconds: 50));
    await mouse.moveTo(const Offset(780, 580));
    await tester.pump(const Duration(milliseconds: 100));
    expect(_sub, findsOneWidget, reason: 'tolerance: no flicker');
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle(const Duration(milliseconds: 50));
    expect(_sub, findsNothing);
  });

  testWidgets('click mode ignores hover; click opens', (tester) async {
    await tester.pumpWidget(
      _host(
        behavior: const MorphMenuSubmenuBehavior(
          mode: MorphMenuSubmenuOpenMode.click,
        ),
      ),
    );
    await _openMenu(tester);
    final mouse = await _mouse(tester);
    await mouse.moveTo(tester.getCenter(find.text('More')));
    await tester.pump(const Duration(milliseconds: 600));
    expect(_sub, findsNothing);
    await tester.tap(find.text('More'));
    await tester.pumpAndSettle(const Duration(milliseconds: 50));
    expect(_sub, findsOneWidget);
  });

  testWidgets('hover mode: click opens at once and a second click keeps it', (
    tester,
  ) async {
    await tester.pumpWidget(_host());
    await _openMenu(tester);
    await tester.tap(find.text('More'));
    await tester.pumpAndSettle(const Duration(milliseconds: 50));
    expect(_sub, findsOneWidget);
    await tester.tap(find.text('More'));
    await tester.pumpAndSettle(const Duration(milliseconds: 50));
    expect(_sub, findsOneWidget, reason: 'no contradictory toggle');
  });

  testWidgets('custom delays are honored', (tester) async {
    await tester.pumpWidget(
      _host(
        behavior: const MorphMenuSubmenuBehavior(
          hoverDelay: Duration(milliseconds: 600),
        ),
      ),
    );
    await _openMenu(tester);
    final mouse = await _mouse(tester);
    await mouse.moveTo(tester.getCenter(find.text('More')));
    await tester.pump(const Duration(milliseconds: 400));
    expect(_sub, findsNothing);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle(const Duration(milliseconds: 50));
    expect(_sub, findsOneWidget);
  });

  testWidgets('touch uses tap and never hover', (tester) async {
    await tester.pumpWidget(_host());
    await _openMenu(tester);
    final touch = await tester.startGesture(
      tester.getCenter(find.text('More')),
      kind: PointerDeviceKind.touch,
    );
    await tester.pump(const Duration(milliseconds: 400));
    expect(_sub, findsNothing, reason: 'down alone does not hover-open');
    await touch.up();
    await tester.pumpAndSettle(const Duration(milliseconds: 50));
    expect(_sub, findsOneWidget);
  });

  testWidgets('keyboard opens with the arrow of the reading direction', (
    tester,
  ) async {
    for (final (dir, key) in [
      (TextDirection.ltr, LogicalKeyboardKey.arrowRight),
      (TextDirection.rtl, LogicalKeyboardKey.arrowLeft),
    ]) {
      await tester.pumpWidget(_host(direction: dir));
      await _openMenu(tester);
      // The first row is focused on open; one step down is the submenu row.
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.sendKeyEvent(key);
      await tester.pumpAndSettle(const Duration(milliseconds: 50));
      expect(_sub, findsOneWidget, reason: dir.name);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle(const Duration(milliseconds: 50));
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle(const Duration(milliseconds: 50));
    }
  });

  testWidgets('timers are cancelled when the menu closes or is disposed', (
    tester,
  ) async {
    await tester.pumpWidget(_host());
    await _openMenu(tester);
    final mouse = await _mouse(tester);
    await mouse.moveTo(tester.getCenter(find.text('More')));
    await tester.pump(const Duration(milliseconds: 50)); // open pending
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle(const Duration(milliseconds: 50));
    // Close pending (submenu open, pointer leaves) then dispose everything.
    await _openMenu(tester);
    await mouse.moveTo(tester.getCenter(find.text('More')));
    await tester.pump(const Duration(milliseconds: 300));
    await mouse.moveTo(const Offset(780, 580));
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 500));
    expect(tester.takeException(), isNull);
    // flutter_test fails the run on pending timers: reaching here proves it.
  });

  testWidgets('semantics stay valid through open, submenu and close frames', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(_host());
    await tester.tap(find.text('open'));
    for (var i = 0; i < 30; i++) {
      await tester.pump(const Duration(milliseconds: 16));
      expect(tester.takeException(), isNull, reason: 'open frame $i');
    }
    final mouse = await _mouse(tester);
    await mouse.moveTo(tester.getCenter(find.text('More')));
    for (var i = 0; i < 40; i++) {
      await tester.pump(const Duration(milliseconds: 16));
      expect(tester.takeException(), isNull, reason: 'submenu frame $i');
    }
    expect(_sub, findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    for (var i = 0; i < 30; i++) {
      await tester.pump(const Duration(milliseconds: 16));
      expect(tester.takeException(), isNull, reason: 'close frame $i');
    }
    await tester.pumpAndSettle(const Duration(milliseconds: 50));
    expect(tester.takeException(), isNull);
    handle.dispose();
  });

  test('behavior value semantics', () {
    expect(
      const MorphMenuSubmenuBehavior(),
      const MorphMenuSubmenuBehavior(mode: MorphMenuSubmenuOpenMode.hover),
    );
    expect(
      const MorphMenuSubmenuBehavior(),
      isNot(
        const MorphMenuSubmenuBehavior(mode: MorphMenuSubmenuOpenMode.click),
      ),
    );
  });
}
