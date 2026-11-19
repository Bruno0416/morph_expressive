import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart' show Scaffold, Text;
import 'package:morph_expressive/morph_expressive.dart';

import 'context_menu_support.dart';

/// A focusable 120x40 target placed at (60, 80).
Widget _target(FocusNode node) => Align(
  alignment: Alignment.topLeft,
  child: Padding(
    padding: const EdgeInsets.only(left: 60, top: 80),
    child: Focus(
      focusNode: node,
      child: const SizedBox(width: 120, height: 40),
    ),
  ),
);

Future<void> _shiftF10(WidgetTester tester) async {
  await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
  await tester.sendKeyEvent(LogicalKeyboardKey.f10);
  await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
  await settleMenu(tester);
}

void main() {
  group('keyboard', () {
    testWidgets('Shift+F10 opens the desktop menu at the focused child', (
      tester,
    ) async {
      setContextViewport(tester);
      final FocusNode node = FocusNode(debugLabel: 'target');
      addTearDown(node.dispose);
      await tester.pumpWidget(contextHost(child: _target(node)));
      node.requestFocus();
      await tester.pump();
      await _shiftF10(tester);
      expect(panelFinder, findsOneWidget);
      final Rect surface = surfaceRect(tester);
      expect(surface.left, closeTo(60, 1));
      expect(surface.top, closeTo(120, 1), reason: 'bottom-left of the rect');
      // Keyboard opening highlights the first enabled row.
      expect(rowFocused(tester, 'Open'), isTrue);
    });

    testWidgets('the ContextMenu key opens the menu', (tester) async {
      setContextViewport(tester);
      final FocusNode node = FocusNode(debugLabel: 'target');
      addTearDown(node.dispose);
      await tester.pumpWidget(contextHost(child: _target(node)));
      node.requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.contextMenu);
      await settleMenu(tester);
      expect(panelFinder, findsOneWidget);
      expect(surfaceRect(tester).left, closeTo(60, 1));
    });

    testWidgets('F10 without Shift and other keys do nothing', (tester) async {
      setContextViewport(tester);
      final FocusNode node = FocusNode();
      addTearDown(node.dispose);
      await tester.pumpWidget(contextHost(child: _target(node)));
      node.requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.f10);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyA);
      await settleMenu(tester);
      expect(panelFinder, findsNothing);
    });

    testWidgets('focus returns to the child after Escape', (tester) async {
      setContextViewport(tester);
      final FocusNode node = FocusNode(debugLabel: 'target');
      addTearDown(node.dispose);
      await tester.pumpWidget(contextHost(child: _target(node)));
      node.requestFocus();
      await tester.pump();
      await _shiftF10(tester);
      expect(node.hasFocus, isFalse, reason: 'focus moved into the menu');
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await settleMenu(tester);
      expect(panelFinder, findsNothing);
      expect(node.hasPrimaryFocus, isTrue);
    });

    testWidgets('focus returns to the child after a selection', (tester) async {
      setContextViewport(tester);
      final List<Object> chosen = <Object>[];
      final FocusNode node = FocusNode(debugLabel: 'target');
      addTearDown(node.dispose);
      await tester.pumpWidget(
        contextHost(child: _target(node), onSelected: chosen.add),
      );
      node.requestFocus();
      await tester.pump();
      await _shiftF10(tester);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await settleMenu(tester);
      expect(chosen, <Object>['rename']);
      expect(node.hasPrimaryFocus, isTrue);
    });

    testWidgets('an explicit region focus node receives the shortcuts', (
      tester,
    ) async {
      setContextViewport(tester);
      final FocusNode node = FocusNode(debugLabel: 'region');
      addTearDown(node.dispose);
      await tester.pumpWidget(contextHost(focusNode: node));
      node.requestFocus();
      await tester.pump();
      await _shiftF10(tester);
      expect(panelFinder, findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await settleMenu(tester);
      expect(node.hasPrimaryFocus, isTrue);
    });

    testWidgets('a disabled region ignores the keyboard', (tester) async {
      setContextViewport(tester);
      final FocusNode node = FocusNode();
      addTearDown(node.dispose);
      await tester.pumpWidget(
        contextHost(child: _target(node), enabled: false),
      );
      node.requestFocus();
      await tester.pump();
      await _shiftF10(tester);
      expect(panelFinder, findsNothing);
    });
  });

  group('pointer and touch', () {
    testWidgets('long press with touch opens the standard presentation', (
      tester,
    ) async {
      setContextViewport(tester);
      await tester.pumpWidget(contextHost());
      final TestGesture touch = await tester.startGesture(
        const Offset(200, 200),
      );
      await tester.pump(const Duration(milliseconds: 700));
      await touch.up();
      await settleMenu(tester);
      expect(find.byType(MorphMenuItem), findsWidgets);
      expect(panelFinder, findsNothing, reason: 'not the desktop panel');
      expect(rowRect(tester, 'Rename').height, 48);
    });

    testWidgets('openOnLongPress false keeps touch inert', (tester) async {
      setContextViewport(tester);
      await tester.pumpWidget(contextHost(openOnLongPress: false));
      final TestGesture touch = await tester.startGesture(
        const Offset(200, 200),
      );
      await tester.pump(const Duration(milliseconds: 700));
      await touch.up();
      await settleMenu(tester);
      expect(find.byType(MorphMenuItem), findsNothing);
    });

    testWidgets('a primary-button mouse click does not open the menu', (
      tester,
    ) async {
      setContextViewport(tester);
      await tester.pumpWidget(contextHost());
      final TestGesture mouse = await tester.startGesture(
        const Offset(200, 200),
        kind: PointerDeviceKind.mouse,
      );
      await mouse.up();
      await settleMenu(tester);
      expect(find.byType(MorphMenuItem), findsNothing);
    });

    testWidgets('a disabled region ignores right click', (tester) async {
      setContextViewport(tester);
      await tester.pumpWidget(contextHost(enabled: false));
      await rightClick(tester, const Offset(200, 200));
      expect(find.byType(MorphMenuItem), findsNothing);
    });

    testWidgets('menuBuilder runs on every open and the value is reported', (
      tester,
    ) async {
      setContextViewport(tester);
      var builds = 0;
      final List<String> chosen = <String>[];
      await tester.pumpWidget(
        MorphMaterialApp(
          data: MorphThemeData.light(),
          home: Scaffold(
            body: MorphContextMenuRegion<String>(
              menuBuilder: (BuildContext context) {
                builds++;
                return <MorphMenuNode>[
                  MorphMenuEntry(label: 'Build $builds', value: 'v$builds'),
                ];
              },
              onSelected: chosen.add,
              child: const SizedBox.expand(),
            ),
          ),
        ),
      );
      await rightClick(tester, const Offset(200, 200));
      await tester.tap(find.text('Build 1'));
      await settleMenu(tester);
      await rightClick(tester, const Offset(200, 200));
      expect(find.text('Build 2'), findsOneWidget);
      await tester.tap(find.text('Build 2'));
      await settleMenu(tester);
      expect(chosen, <String>['v1', 'v2']);
    });

    testWidgets('nested regions open only the innermost menu', (tester) async {
      setContextViewport(tester);
      await tester.pumpWidget(
        MorphMaterialApp(
          data: MorphThemeData.light(),
          home: Scaffold(
            body: MorphContextMenuRegion<Object>(
              children: const <MorphMenuNode>[
                MorphMenuEntry(label: 'Outer', value: 'outer'),
              ],
              child: Align(
                alignment: Alignment.topLeft,
                child: MorphContextMenuRegion<Object>(
                  children: const <MorphMenuNode>[
                    MorphMenuEntry(label: 'Inner', value: 'inner'),
                  ],
                  child: const SizedBox(width: 200, height: 200),
                ),
              ),
            ),
          ),
        ),
      );
      await rightClick(tester, const Offset(50, 50));
      expect(find.text('Inner'), findsOneWidget);
      expect(find.text('Outer'), findsNothing);
    });

    testWidgets('region density override beats the theme density', (
      tester,
    ) async {
      setContextViewport(tester);
      await tester.pumpWidget(
        contextHost(
          density: MorphDensity.standard,
          regionDensity: MorphDensity.compact,
        ),
      );
      await rightClick(tester, const Offset(100, 100));
      expect(rowRect(tester, 'Rename').height, 28);
    });

    Widget nestedHost(MorphThemeData nested) => MorphMaterialApp(
      data: MorphThemeData.light(),
      home: Scaffold(
        body: MorphTheme(
          data: nested,
          child: MorphContextMenuRegion<Object>(
            children: sampleMenu(),
            child: const SizedBox.expand(),
          ),
        ),
      ),
    );

    testWidgets('a nested compact theme beats the standard root density', (
      tester,
    ) async {
      setContextViewport(tester);
      await tester.pumpWidget(
        nestedHost(
          MorphThemeData.light().copyWith(density: MorphDensity.compact),
        ),
      );
      await rightClick(tester, const Offset(100, 100));
      expect(rowRect(tester, 'Rename').height, 28);
    });

    testWidgets('a nested dark theme colors the menu under a light root', (
      tester,
    ) async {
      setContextViewport(tester);
      final MorphThemeData dark = MorphThemeData.dark();
      await tester.pumpWidget(nestedHost(dark));
      await rightClick(tester, const Offset(100, 100));
      final Text label = tester.widget<Text>(find.text('Rename'));
      expect(label.style!.color, dark.colorScheme.onSurface);
    });

    testWidgets('an explicit region density beats a nested theme', (
      tester,
    ) async {
      setContextViewport(tester);
      await tester.pumpWidget(
        MorphMaterialApp(
          data: MorphThemeData.light(),
          home: Scaffold(
            body: MorphTheme(
              data: MorphThemeData.light().copyWith(
                density: MorphDensity.compact,
              ),
              child: MorphContextMenuRegion<Object>(
                density: MorphDensity.comfortable,
                children: sampleMenu(),
                child: const SizedBox.expand(),
              ),
            ),
          ),
        ),
      );
      await rightClick(tester, const Offset(100, 100));
      expect(rowRect(tester, 'Rename').height, 40);
    });

    testWidgets('showMorphContextMenu opens at the position and returns', (
      tester,
    ) async {
      setContextViewport(tester);
      Future<Object?>? result;
      await tester.pumpWidget(
        MorphMaterialApp(
          data: MorphThemeData.light(),
          home: Scaffold(
            body: Builder(
              builder: (BuildContext context) => GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => result = showMorphContextMenu<Object>(
                  context: context,
                  position: const Offset(250, 180),
                  children: sampleMenu(),
                ),
                child: const SizedBox.expand(),
              ),
            ),
          ),
        ),
      );
      await tester.tapAt(const Offset(10, 10));
      await settleMenu(tester);
      final Rect surface = surfaceRect(tester);
      expect(surface.left, closeTo(250, 1));
      expect(surface.top, closeTo(180, 1));
      await tester.tap(find.text('Delete'));
      await settleMenu(tester);
      expect(await result, 'delete');
      expect(panelFinder, findsNothing);
    });
  });
}
