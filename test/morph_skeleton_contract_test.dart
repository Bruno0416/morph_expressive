import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart' show Scaffold;
import 'package:morph_expressive/morph_expressive.dart';

import 'helpers/raster_capture.dart';

Widget host(Widget child, {bool reduced = false, MorphThemeData? data}) =>
    MorphMaterialApp(
      data: data ?? MorphThemeData.light().copyWith(reduceMotion: reduced),
      home: Scaffold(body: Center(child: child)),
    );

void main() {
  testWidgets('groups have independent phases and clocks', (tester) async {
    final first = GlobalKey(), second = GlobalKey();
    var showSecond = false;
    late StateSetter update;
    Widget group(GlobalKey key) => RepaintBoundary(
      key: key,
      child: const SizedBox(
        width: 180,
        height: 20,
        child: MorphSkeletonGroup(
          renderer: MorphShapeRenderer.canvas,
          intensity: 1,
          baseColor: Color(0xff222222),
          highlightColor: Color(0xffeeeeee),
          placeholder: MorphSkeleton(height: 20, radius: 0),
        ),
      ),
    );
    await tester.pumpWidget(
      host(
        StatefulBuilder(
          builder: (context, set) {
            update = set;
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [group(first), if (showSecond) group(second)],
            );
          },
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 650));
    update(() => showSecond = true);
    await tester.pump();
    final a = await captureRaster(tester, first),
        b = await captureRaster(tester, second);
    expect(a.rgba, isNot(orderedEquals(b.rgba)));
    await tester.pumpWidget(const SizedBox());
  });
  testWidgets('one group uses one common horizontal sweep for unequal rows', (
    tester,
  ) async {
    final key = GlobalKey();
    await tester.pumpWidget(
      host(
        RepaintBoundary(
          key: key,
          child: const SizedBox(
            width: 240,
            child: MorphSkeletonGroup(
              renderer: MorphShapeRenderer.canvas,
              baseColor: Color(0xff222222),
              highlightColor: Color(0xffeeeeee),
              intensity: 1,
              placeholder: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MorphSkeleton(width: 240, height: 20, radius: 0),
                  SizedBox(height: 10),
                  MorphSkeleton(width: 120, height: 20, radius: 0),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 650));
    final image = await captureRaster(tester, key);
    for (var x = 1; x < 119; x++) {
      for (var channel = 0; channel < 3; channel++) {
        expect(
          image.channel(x, 10, channel),
          closeTo(image.channel(x, 40, channel), 1),
          reason: 'same global sweep; allow one 8-bit quantization level',
        );
      }
    }
    await tester.pumpWidget(const SizedBox());
    expect(tester.takeException(), isNull);
  });

  testWidgets('reduced motion, disabled, content and TickerMode stop clock', (
    tester,
  ) async {
    for (final mode in ['reduced', 'disabled', 'content', 'ticker']) {
      await tester.pumpWidget(
        host(
          TickerMode(
            enabled: mode != 'ticker',
            child: MorphSkeletonGroup(
              loading: mode != 'content',
              enabled: mode != 'disabled',
              placeholder: const MorphSkeleton(width: 120),
              child: const SizedBox(width: 120, height: 16),
            ),
          ),
          reduced: mode == 'reduced',
        ),
      );
      await tester.pump(const Duration(milliseconds: 400));
      expect(tester.hasRunningAnimations, isFalse, reason: mode);
      await tester.pumpWidget(const SizedBox());
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('renderer fallback and live configuration keep group alive', (
    tester,
  ) async {
    MorphShapeRenderStatus? status;
    var renderer = MorphShapeRenderer.canvas;
    var effect = MorphSkeletonEffect.shimmer;
    late StateSetter update;
    await tester.pumpWidget(
      host(
        StatefulBuilder(
          builder: (context, set) {
            update = set;
            return MorphSkeletonGroup(
              renderer: renderer,
              effect: effect,
              onRendererChanged: (r) => status = r,
              placeholder: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  MorphSkeleton.avatar(),
                  MorphSkeleton(width: 80),
                ],
              ),
            );
          },
        ),
      ),
    );
    await tester.pump();
    expect(status?.effective, MorphShapeRenderer.canvas);
    final element = tester.element(find.byType(MorphSkeletonGroup));
    update(() {
      renderer = MorphShapeRenderer.shader;
      effect = MorphSkeletonEffect.pulse;
    });
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 120));
    expect(
      status?.effective,
      MorphShapeRenderer.canvas,
      reason: 'pulse uses shared Canvas coverage',
    );
    expect(tester.element(find.byType(MorphSkeletonGroup)), same(element));
    await tester.pumpWidget(const SizedBox());
    expect(tester.takeException(), isNull);
  });

  test('themes propagate copyWith, dark template and interpolation', () {
    const async = MorphAsyncButtonTheme(
      transitionDuration: Duration(milliseconds: 400),
    );
    const skeleton = MorphSkeletonTheme(intensity: .7);
    final data = MorphThemeData.light().copyWith(
      asyncButtonTheme: async,
      skeletonTheme: skeleton,
    );
    expect(data.copyWith().asyncButtonTheme, async);
    expect(data.copyWith().skeletonTheme, skeleton);
    expect(
      skeleton.lerp(skeleton.copyWith(intensity: .3), .5).intensity,
      closeTo(.5, .0001),
    );
    expect(async.copyWith(), async);
    expect(skeleton.copyWith(), skeleton);
  });
}
