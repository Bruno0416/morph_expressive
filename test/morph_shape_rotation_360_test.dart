import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morph_expressive/morph_expressive.dart';

import 'helpers/raster_capture.dart';

double _deg(double d) => d * math.pi / 180;

void main() {
  final ellipse = MorphShape.ellipse(width: 1, height: .64);
  final clover = MorphShapeCatalog.fromKind(MorphShapeKind.clover4Leaf);

  Future<Raster> render(
    WidgetTester tester,
    MorphShape shape,
    double radians,
    MorphShapeRenderer renderer,
    double dpr,
  ) async {
    final key = GlobalKey();
    MorphShapeRenderStatus? status;
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: MediaQuery(
          data: MediaQueryData(devicePixelRatio: dpr),
          child: Align(
            alignment: Alignment.topLeft,
            child: RepaintBoundary(
              key: key,
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: MorphShapeView(
                  shape: shape,
                  size: const Size(96, 96),
                  color: const Color(0xff3060c0),
                  rotationRadians: radians,
                  renderer: renderer,
                  onRendererChanged: (s) => status = s,
                ),
              ),
            ),
          ),
        ),
      ),
    );
    for (var i = 0; i < 8; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 15)),
      );
      await tester.pump();
    }
    if (renderer == MorphShapeRenderer.shader) {
      expect(status?.effective, MorphShapeRenderer.shader);
    }
    return captureRaster(tester, key, pixelRatio: dpr);
  }

  int diff(Raster a, Raster b) {
    var d = 0;
    for (var i = 0; i < a.rgba.length; i++) {
      d += (a.rgba[i] - b.rgba[i]).abs();
    }
    return d;
  }

  test('normalization snaps full and quarter turns, keeps the rest', () {
    expect(normalizeMorphRotation(0), 0);
    expect(normalizeMorphRotation(_deg(360)), 0);
    expect(normalizeMorphRotation(_deg(720)), 0);
    expect(normalizeMorphRotation(_deg(-360)), 0);
    expect(normalizeMorphRotation(_deg(-90)), closeTo(1.5 * math.pi, 1e-12));
    expect(normalizeMorphRotation(_deg(450)), closeTo(math.pi / 2, 1e-12));
    expect(normalizeMorphRotation(_deg(359.999)), closeTo(_deg(359.999), 1e-9));
    expect(normalizeMorphRotation(_deg(360.001)), closeTo(_deg(.001), 1e-9));
  });

  for (final renderer in [
    MorphShapeRenderer.shader,
    MorphShapeRenderer.canvas,
  ]) {
    for (final dpr in [1.0, 2.0]) {
      testWidgets(
        '${renderer.name} @DPR $dpr: 360°, 720° and negatives equal 0°',
        (tester) async {
          final shape = renderer == MorphShapeRenderer.shader
              ? ellipse
              : clover;
          final zero = await render(tester, shape, 0, renderer, dpr);
          for (final degrees in [360.0, 720.0, -360.0, -720.0, 1080.0]) {
            final r = await render(tester, shape, _deg(degrees), renderer, dpr);
            expect(diff(zero, r), 0, reason: '$degrees° differs from 0°');
          }
          // Nearly a full turn stays close (continuity, no jump at the seam).
          for (final degrees in [359.999, 360.001, -359.999]) {
            final r = await render(tester, shape, _deg(degrees), renderer, dpr);
            expect(
              diff(zero, r) / zero.rgba.length,
              lessThan(.6),
              reason: '$degrees° jumps',
            );
          }
        },
      );
    }
  }

  testWidgets('shader top extreme keeps antialiased coverage at 0° and 360°', (
    tester,
  ) async {
    for (final degrees in [0.0, 360.0]) {
      final r = await render(
        tester,
        ellipse,
        _deg(degrees),
        MorphShapeRenderer.shader,
        2,
      );
      // Topmost opaque row of the ellipse: partial coverage must surround it
      // (not a flat cut), i.e. partial alpha exists in the rows just above.
      final cx = r.width ~/ 2;
      var firstOpaque = -1;
      for (var y = 0; y < r.height; y++) {
        if (r.alpha(cx, y) >= 250) {
          firstOpaque = y;
          break;
        }
      }
      expect(firstOpaque, greaterThan(2));
      var partial = 0;
      for (var y = 0; y < firstOpaque; y++) {
        for (var x = cx - 6; x <= cx + 6; x++) {
          final a = r.alpha(x, y);
          if (a > 6 && a < 250) partial++;
        }
      }
      expect(partial, greaterThan(3), reason: '$degrees°');
    }
  });

  testWidgets('several simultaneous instances stay independent', (
    tester,
  ) async {
    final keys = List.generate(3, (_) => GlobalKey());
    Widget col(List<double> rot, List<MorphShapeRenderer> rend) =>
        Directionality(
          textDirection: TextDirection.ltr,
          child: Row(
            textDirection: TextDirection.ltr,
            children: [
              for (var i = 0; i < 3; i++)
                RepaintBoundary(
                  key: keys[i],
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: MorphShapeView(
                      shape: ellipse,
                      size: const Size(96, 96),
                      color: const Color(0xff3060c0),
                      rotationRadians: rot[i],
                      renderer: rend[i],
                    ),
                  ),
                ),
            ],
          ),
        );
    Future<List<Raster>> shots() async {
      for (var i = 0; i < 6; i++) {
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 15)),
        );
        await tester.pump();
      }
      return [for (final k in keys) await captureRaster(tester, k)];
    }

    const s = MorphShapeRenderer.shader, c = MorphShapeRenderer.canvas;
    await tester.pumpWidget(col([0, _deg(360), _deg(90)], [s, s, c]));
    final first = await shots();
    expect(diff(first[0], first[1]), 0);
    // Rapid reconfiguration of every instance, then back.
    for (final cfg in [
      ([_deg(720), 0.0, _deg(45)], [c, s, s]),
      ([_deg(-360), _deg(360.001), 0.0], [s, c, s]),
      ([0.0, _deg(360), _deg(90)], [s, s, c]),
    ]) {
      await tester.pumpWidget(col(cfg.$1, cfg.$2));
    }
    final last = await shots();
    for (var i = 0; i < 3; i++) {
      expect(diff(first[i], last[i]), 0, reason: 'instance $i after changes');
    }
  });
}
