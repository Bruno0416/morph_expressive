import 'dart:ui' show PointerDeviceKind;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart' show MaterialApp, Scaffold;
import 'package:morph_expressive/morph_expressive.dart';
import 'package:morph_expressive_preview/floating_navigation_sample.dart';
import 'package:morph_expressive_preview/main.dart';

import 'showcase_scroll_helper.dart';

void main() {
  for (final kind in [PointerDeviceKind.touch, PointerDeviceKind.mouse]) {
    testWidgets('nested floating sample refreshes with $kind', (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.linux;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);
      final outer = ScrollController();
      addTearDown(outer.dispose);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView(
              controller: outer,
              children: const [
                SizedBox(height: 40),
                SizedBox(height: 320, child: FloatingNavigationSample()),
                SizedBox(height: 1200),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final list = find.byKey(const ValueKey('floating_navigation_content'));
      final bounds = tester.getRect(list);
      final gesture = await tester.startGesture(
        bounds.topLeft + const Offset(180, 30),
        kind: kind,
      );
      for (var i = 0; i < 12; i++) {
        await gesture.moveBy(const Offset(0, 15));
        await tester.pump(const Duration(milliseconds: 16));
      }
      expect(find.text('Content 1 · refresh 0'), findsOneWidget);
      await gesture.up();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Content 1 · refresh 0'), findsOneWidget);
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      expect(find.text('Content 1 · refresh 1'), findsOneWidget);
      expect(outer.offset, 0);
      expect(tester.takeException(), isNull);
      debugDefaultTargetPlatformOverride = null;
    });
  }

  testWidgets('preview uses web-efficient glass without native regression', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: const Scaffold(
          body: SizedBox(height: 320, child: FloatingNavigationSample()),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final bar = tester.widget<MorphNavigationBar>(
      find.byType(MorphNavigationBar),
    );
    expect(bar.glass?.webBackdropBlur, isTrue);
    expect(bar.glass?.blurX, kIsWeb ? 5 : 10);
    expect(bar.glass?.blurY, kIsWeb ? 5 : 10);
    expect(find.byType(BackdropFilter), findsOneWidget);
    expect(
      tester.widget<BackdropFilter>(find.byType(BackdropFilter)).enabled,
      isTrue,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('actual gallery floating demo refreshes with mouse drag', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MorphPreviewApp());
    await revealShowcaseCategory(tester, 'navigation_bar');
    final list = find.byKey(const ValueKey('floating_navigation_content'));
    await tester.ensureVisible(list);
    await tester.pump();
    final bounds = tester.getRect(list);
    final gesture = await tester.startGesture(
      bounds.topLeft + const Offset(180, 30),
      kind: PointerDeviceKind.mouse,
    );
    for (var i = 0; i < 12; i++) {
      await gesture.moveBy(const Offset(0, 15));
      await tester.pump(const Duration(milliseconds: 16));
    }
    await gesture.up();
    await tester.pump(const Duration(seconds: 1));
    await tester.pump();
    expect(find.text('Content 1 · refresh 1'), findsOneWidget);
    expect(find.byType(MorphNavigationBarHost), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
