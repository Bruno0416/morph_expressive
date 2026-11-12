import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart'
    show Scaffold, Icon, Icons, InkWell;
import 'package:morph_expressive/morph_expressive.dart';

import 'helpers/raster_capture.dart';

void main() {
  tearDown(() => MorphSmoothEdges.defaultMode = MorphSmoothEdgesMode.auto);

  testWidgets('FAB ink uses a live outer clip throughout reversal', (
    tester,
  ) async {
    final controller = MorphFabMenuController();
    await tester.pumpWidget(
      MorphMaterialApp(
        data: MorphThemeData.light(),
        home: Scaffold(
          body: Align(
            alignment: Alignment.bottomRight,
            child: MorphFabMenu(
              controller: controller,
              items: const [
                MorphFabMenuItem(icon: Icon(Icons.add), label: 'Add'),
                MorphFabMenuItem(icon: Icon(Icons.remove), label: 'Remove'),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final surface = find.byType(MorphRoundedSurface);
    final ink = find.descendant(
      of: find.byKey(const ValueKey<String>('fab-menu-surface')),
      matching: find.byType(InkWell),
    );
    final inkElement = tester.element(ink);
    final gesture = await tester.startGesture(tester.getCenter(surface));
    await tester.pump(const Duration(milliseconds: 90));
    controller.open();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    void checkClip() {
      final geometry = tester.widget<MorphRoundedSurface>(surface);
      final clips = find.ancestor(of: ink, matching: find.byType(ClipRRect));
      expect(clips, findsWidgets);
      final clip = tester.widget<ClipRRect>(clips.first);
      expect(clip.borderRadius, BorderRadius.circular(geometry.radius));
      expect(
        tester.widget<InkWell>(ink).customBorder,
        isNull,
        reason: 'an ink feature must not capture a frame-specific border',
      );
      expect(tester.element(ink), same(inkElement));
      expect(
        find.ancestor(of: ink, matching: find.byType(MorphSmoothEdges)),
        findsOneWidget,
      );
    }

    checkClip();
    controller.close();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 80));
    checkClip();
    controller.open();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 70));
    checkClip();
    await gesture.cancel();
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  for (final child in <Widget>[
    const MorphProgressIndicator.circular(),
    const MorphProgressIndicator.circularWavy(value: .65),
    const MorphProgressIndicator.linearWavy(value: .65),
  ]) {
    testWidgets(
      'offscreen progress keeps repainting ${child.toStringShort()}',
      (tester) async {
        MorphSmoothEdges.defaultMode = MorphSmoothEdgesMode.enabled;
        final key = GlobalKey();
        await tester.pumpWidget(
          MorphMaterialApp(
            data: MorphThemeData.light(),
            home: Scaffold(
              body: Center(
                child: RepaintBoundary(
                  key: key,
                  child: SizedBox(
                    width: 180,
                    height: 100,
                    child: Center(child: child),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 100));
        final before = await captureRaster(tester, key);
        await tester.pump(const Duration(milliseconds: 240));
        final after = await captureRaster(tester, key);
        expect(
          after.rgba,
          isNot(orderedEquals(before.rgba)),
          reason:
              'descendant repaint boundaries must not bypass the image capture',
        );
      },
    );
  }
}
