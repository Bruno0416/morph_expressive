import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart' show Size, ValueKey;
import 'package:morph_expressive/morph_expressive.dart';

import 'support.dart';

String _path(String suffix) =>
    allUseCases().firstWhere((u) => u.path.endsWith(suffix)).path;

const _desktop = Size(1280, 800);

Future<void> _rightClick(WidgetTester tester, Finder finder) async {
  final gesture = await tester.startGesture(
    tester.getCenter(finder),
    kind: PointerDeviceKind.mouse,
    buttons: kSecondaryMouseButton,
  );
  await gesture.up();
  for (var i = 0; i < 5; i++) {
    await tester.pump(const Duration(milliseconds: 60));
  }
}

Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 5; i++) {
    await tester.pump(const Duration(milliseconds: 60));
  }
}

const _target = ValueKey<String>('context-target');

void main() {
  testWidgets('context menu lab: right-click opens, item selects, reopens', (
    tester,
  ) async {
    await openUseCase(
      tester,
      _path('morphcontextmenuregion/simple'),
      size: _desktop,
    );
    expect(find.text('Rename'), findsNothing);

    await _rightClick(tester, find.byKey(_target));
    expect(find.text('Rename'), findsOneWidget);

    await tester.tap(find.text('Share'));
    await _settle(tester);
    expect(find.text('Rename'), findsNothing);
    expect(find.textContaining('Last action: share'), findsOneWidget);

    await _rightClick(tester, find.byKey(_target));
    expect(find.text('Rename'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('context menu lab: Escape closes the menu', (tester) async {
    await openUseCase(
      tester,
      _path('morphcontextmenuregion/simple'),
      size: _desktop,
    );
    await _rightClick(tester, find.byKey(_target));
    expect(find.text('Rename'), findsOneWidget);

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await _settle(tester);
    expect(find.text('Rename'), findsNothing);
    expect(find.textContaining('Last action: none yet'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('context menu lab: shortcuts are shown as hints', (tester) async {
    await openUseCase(
      tester,
      _path('morphcontextmenuregion/text-+-shortcuts'),
      size: _desktop,
    );
    await _rightClick(tester, find.byKey(_target));
    expect(find.text('Ctrl+C'), findsOneWidget);
    expect(find.text('Ctrl+Shift+Z'), findsOneWidget);
  });

  testWidgets('context menu lab: Shift+F10 opens from the focused target', (
    tester,
  ) async {
    await openUseCase(
      tester,
      _path('morphcontextmenuregion/keyboard-navigation'),
      size: _desktop,
    );
    await tester.tap(
      find.byKey(const ValueKey<String>('context-keyboard-target')),
    );
    await tester.pump();
    await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.f10);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
    await _settle(tester);
    expect(find.text('Open with'), findsOneWidget);

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await _settle(tester);
    expect(find.text('Open with'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('context menu lab: the three density columns are real themes', (
    tester,
  ) async {
    await openUseCase(
      tester,
      _path('morphcontextmenuregion/density-compare'),
      size: _desktop,
    );
    final heights = <double>[];
    for (final name in const ['compact', 'standard', 'comfortable']) {
      await _rightClick(
        tester,
        find.byKey(ValueKey<String>('context-density-$name')),
      );
      heights.add(tester.getSize(find.byType(MorphMenuItem).first).height);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await _settle(tester);
    }
    expect(heights[0], lessThan(heights[1]));
    expect(heights[1], lessThan(heights[2]));
    expect(tester.takeException(), isNull);
  });

  testWidgets('context menu lab: edge targets are flush to the canvas', (
    tester,
  ) async {
    await openUseCase(
      tester,
      _path('morphcontextmenuregion/near-viewport-edge'),
      size: _desktop,
    );
    final bottom = tester.getRect(
      find.byKey(const ValueKey<String>('context-corner-bottom-left')),
    );
    expect(bottom.bottom, closeTo(_desktop.height - 8, 1));
    final right = tester.getRect(
      find.byKey(const ValueKey<String>('context-corner-far-right')),
    );
    expect(right.right, closeTo(_desktop.width - 8, 1));

    await _rightClick(
      tester,
      find.byKey(const ValueKey<String>('context-corner-bottom-right')),
    );
    expect(find.text('Open with'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await _settle(tester);
    expect(tester.takeException(), isNull);
  });
}
