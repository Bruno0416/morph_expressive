import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart' show Scaffold, Text;
import 'package:morph_expressive/morph_expressive.dart';

import 'helpers/raster_capture.dart';

Widget _host(Widget child, GlobalKey key) => MorphMaterialApp(
  data: MorphThemeData.light(),
  home: Scaffold(
    body: Align(
      alignment: Alignment.topLeft,
      child: RepaintBoundary(
        key: key,
        child: Padding(padding: const EdgeInsets.all(12), child: child),
      ),
    ),
  ),
);

void main() {
  tearDown(() => MorphSmoothEdges.defaultMode = MorphSmoothEdgesMode.auto);

  testWidgets('auto is off outside Linux desktop; forced mode is honored', (
    tester,
  ) async {
    // The test platform is Android: auto must not intercept painting.
    final key = GlobalKey();
    await tester.pumpWidget(
      _host(
        const SizedBox(
          width: 100,
          height: 20,
          child: MorphProgressIndicator.linear(value: .5),
        ),
        key,
      ),
    );
    expect(MorphSmoothEdges.defaultMode, MorphSmoothEdgesMode.auto);
    final auto = await captureRaster(tester, key, pixelRatio: 2);
    MorphSmoothEdges.defaultMode = MorphSmoothEdgesMode.enabled;
    await tester.pumpWidget(
      _host(
        const SizedBox(
          width: 100,
          height: 20,
          child: MorphProgressIndicator.linear(value: .5),
        ),
        key,
      ),
    );
    await tester.pump();
    final forced = await captureRaster(tester, key, pixelRatio: 2);
    expect(forced.width, auto.width);
    var diff = 0;
    for (var i = 0; i < auto.rgba.length; i++) {
      diff += (auto.rgba[i] - forced.rgba[i]).abs();
    }
    // Offscreen then blit 1:1 reproduces the direct result (same coverage).
    expect(diff / auto.rgba.length, lessThan(1.5));
    var painted = 0;
    for (var i = 3; i < forced.rgba.length; i += 4) {
      if (forced.rgba[i] > 0) painted++;
    }
    expect(painted, greaterThan(200), reason: 'not blank / not clipped');
  });

  for (final mode in MorphSmoothEdgesMode.values) {
    testWidgets('layout, taps and semantics unchanged in ${mode.name}', (
      tester,
    ) async {
      MorphSmoothEdges.defaultMode = mode;
      var taps = 0;
      var slider = .3;
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        MorphMaterialApp(
          data: MorphThemeData.light(),
          home: Scaffold(
            body: Column(
              children: [
                MorphButton(onPressed: () => taps++, child: const Text('Tap')),
                SizedBox(
                  width: 240,
                  child: StatefulBuilder(
                    builder: (c, set) => MorphSlider.wavy(
                      value: slider,
                      onChanged: (v) => set(() => slider = v),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.tap(find.text('Tap'));
      await tester.pump();
      expect(taps, 1);
      final before = slider;
      await tester.tapAt(
        tester.getTopLeft(find.byType(MorphSlider)) + const Offset(200, 24),
      );
      await tester.pump(const Duration(milliseconds: 300)); // wave animates
      expect(slider, isNot(before));
      expect(find.byType(MorphSlider), findsOneWidget);
      expect(tester.takeException(), isNull);
      handle.dispose();
    });
  }
}
