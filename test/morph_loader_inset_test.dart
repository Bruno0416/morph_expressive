import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morph_expressive/morph_expressive.dart';

import 'helpers/raster_capture.dart';

const _shape = Color(0xffe02020), _shell = Color(0xff2040c0);

Widget _loader({
  double size = 48,
  double? inset,
  List<MorphShape>? shapes,
  double? turns,
  GlobalKey? key,
  MorphLoadingIndicatorVariant variant = MorphLoadingIndicatorVariant.contained,
}) => Directionality(
  textDirection: TextDirection.ltr,
  child: Center(
    child: RepaintBoundary(
      key: key,
      child: MorphLoadingIndicator(
        variant: variant,
        size: size,
        containedInset: inset,
        color: _shape,
        containerColor: _shell,
        shapes: shapes,
        rotationTurns: turns,
        morphInterval: const Duration(milliseconds: 400),
      ),
    ),
  ),
);

/// Largest logical distance from the center of any shape-colored pixel.
double _maxRadius(Raster r, double scale) {
  var m = 0.0;
  final c = r.width / 2;
  for (var y = 0; y < r.height; y++) {
    for (var x = 0; x < r.width; x++) {
      if (r.alpha(x, y) == 0) continue;
      final red = r.channel(x, y, 0), blue = r.channel(x, y, 2);
      if (red - blue < 60) continue; // shell or its edge
      m = math.max(
        m,
        math.sqrt(math.pow(x + .5 - c, 2) + math.pow(y + .5 - c, 2)) / scale,
      );
    }
  }
  return m;
}

void main() {
  const scale = 4.0;
  Future<double> sweep(
    WidgetTester tester,
    GlobalKey key, {
    required Duration total,
    Duration step = const Duration(milliseconds: 70),
  }) async {
    var worst = 0.0;
    for (var t = Duration.zero; t < total; t += step) {
      await tester.pump(step);
      worst = math.max(
        worst,
        _maxRadius(await captureRaster(tester, key, pixelRatio: scale), scale),
      );
    }
    return worst;
  }

  for (final (size, inset) in [
    (48.0, 5.0),
    (48.0, 8.0),
    (96.0, 5.0),
    (24.0, 2.0),
  ]) {
    testWidgets('default sequence keeps radial inset $inset @ $size', (
      tester,
    ) async {
      final key = GlobalKey();
      await tester.pumpWidget(_loader(size: size, inset: inset, key: key));
      final worst = await sweep(tester, key, total: const Duration(seconds: 6));
      // Budget = outer radius − inset; 0.5 dp tolerance covers AA coverage.
      expect(worst, lessThanOrEqualTo(size / 2 - inset + .5));
      expect(
        worst,
        greaterThan((size / 2 - inset) * .55),
        reason: 'indicator must remain a meaningful size',
      );
    });
  }

  testWidgets('wide sequence (gem/sunny corners) is scaled, not clipped', (
    tester,
  ) async {
    final key = GlobalKey();
    final wide = [
      MorphShapeCatalog.fromKind(MorphShapeKind.gem),
      MorphShapeCatalog.fromKind(MorphShapeKind.square),
      MorphShapeCatalog.fromKind(MorphShapeKind.sunny),
    ];
    await tester.pumpWidget(_loader(inset: 5, shapes: wide, key: key));
    final worst = await sweep(tester, key, total: const Duration(seconds: 5));
    expect(worst, lessThanOrEqualTo(19 + .5));
    // The shell still shows around it, i.e. points are not cut by the clip:
    // the farthest point stays inside the budget rather than touching the rim.
    expect(worst, lessThan(24 - 3));
  });

  testWidgets('live sequence change keeps the margin without a jump', (
    tester,
  ) async {
    final key = GlobalKey();
    await tester.pumpWidget(_loader(inset: 5, key: key));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpWidget(
      _loader(
        inset: 5,
        key: key,
        shapes: [
          MorphShapeCatalog.fromKind(MorphShapeKind.square),
          MorphShapeCatalog.fromKind(MorphShapeKind.gem),
        ],
      ),
    );
    final worst = await sweep(tester, key, total: const Duration(seconds: 3));
    expect(worst, lessThanOrEqualTo(19 + .6));
  });

  testWidgets('manual rotation and reduced motion respect the inset', (
    tester,
  ) async {
    final key = GlobalKey();
    for (final turns in [0.0, .125, .37]) {
      await tester.pumpWidget(
        _loader(
          inset: 5,
          turns: turns,
          key: key,
          shapes: [
            MorphShapeCatalog.fromKind(MorphShapeKind.square),
            MorphShapeCatalog.fromKind(MorphShapeKind.gem),
          ],
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));
      final r = _maxRadius(
        await captureRaster(tester, key, pixelRatio: scale),
        scale,
      );
      expect(r, lessThanOrEqualTo(19.5));
    }
    await tester.pumpWidget(
      MorphMotionScope(reduceMotion: true, child: _loader(inset: 5, key: key)),
    );
    await tester.pump(const Duration(milliseconds: 300));
    expect(
      _maxRadius(await captureRaster(tester, key, pixelRatio: scale), scale),
      lessThanOrEqualTo(19.5),
    );
  });

  testWidgets('plain variant keeps its 38 dp active size (no inset applied)', (
    tester,
  ) async {
    final key = GlobalKey();
    await tester.pumpWidget(
      _loader(
        key: key,
        variant: MorphLoadingIndicatorVariant.defaultStyle,
        turns: 0,
      ),
    );
    await tester.pump(const Duration(milliseconds: 50));
    final box = tester.getSize(find.byType(MorphShapeView));
    expect(box.width, 38);
  });

  for (final bad in [-1.0, 24.0, double.nan]) {
    testWidgets('inset $bad is rejected with ArgumentError', (tester) async {
      await tester.pumpWidget(_loader(inset: bad));
      expect(tester.takeException(), isA<ArgumentError>());
    });
  }
}
