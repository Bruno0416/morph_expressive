import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morph_expressive_preview/main.dart';

void main() {
  Future<void> startAtWidth(WidgetTester tester, double width) async {
    tester.view.physicalSize = Size(width, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MorphPreviewApp());
    await tester.pump();
  }

  testWidgets('wide gallery places several button families on one row', (
    tester,
  ) async {
    await startAtWidth(tester, 1440);
    final buttons = find.byKey(const ValueKey('showcase_buttons'));
    final icons = find.byKey(const ValueKey('showcase_icon_buttons'));
    final group = find.byKey(const ValueKey('showcase_button_group'));
    expect(buttons, findsOneWidget);
    expect(icons, findsOneWidget);
    expect(group, findsOneWidget);
    final first = tester.getTopLeft(buttons);
    final second = tester.getTopLeft(icons);
    final third = tester.getTopLeft(group);
    expect(second.dy, closeTo(first.dy, 1));
    expect(third.dy, closeTo(first.dy, 1));
    expect(first.dx, lessThan(second.dx));
    expect(second.dx, lessThan(third.dx));
    expect(tester.takeException(), isNull);
  });

  testWidgets('narrow gallery wraps families instead of overflowing', (
    tester,
  ) async {
    await startAtWidth(tester, 720);
    final buttons = find.byKey(const ValueKey('showcase_buttons'));
    final icons = find.byKey(const ValueKey('showcase_icon_buttons'));
    expect(buttons, findsOneWidget);
    expect(icons, findsOneWidget);
    expect(
      tester.getTopLeft(icons).dy,
      greaterThan(tester.getTopLeft(buttons).dy),
    );
    expect(tester.takeException(), isNull);
  });
}
