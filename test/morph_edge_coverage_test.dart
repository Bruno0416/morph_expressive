import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morph_expressive/morph_expressive.dart';

import 'helpers/raster_capture.dart';

class _Reference extends CustomPainter {
  _Reference(this.contour, this.offset, this.color);
  final MorphContour contour;
  final Offset offset;
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    canvas.translate(offset.dx, offset.dy);
    canvas.drawPath(
      morphContourPath(contour, size),
      Paint()
        ..isAntiAlias = true
        ..color = color,
    );
  }

  @override
  bool shouldRepaint(_Reference old) => false;
}

void main() {
  const color = Color(0xff3060c0);
  final contour = MorphShapeCatalog.fromKind(MorphShapeKind.clover4Leaf)
      .contour;

  for (final dpr in [1.0, 1.5, 2.0]) {
    for (final mode in [MorphEdgeAntialias.auto, MorphEdgeAntialias.native]) {
      testWidgets(
        'edge coverage ${mode.name} @DPR $dpr matches direct Canvas path',
        (tester) async {
          final viewKey = GlobalKey(), refKey = GlobalKey();
          const offset = Offset(.37, .23);
          const size = Size(48, 48);
          Widget boxed(Key key, Widget child) => RepaintBoundary(
            key: key,
            child: SizedBox(width: 56, height: 56, child: child),
          );
          await tester.pumpWidget(
            Directionality(
              textDirection: TextDirection.ltr,
              child: MediaQuery(
                data: MediaQueryData(devicePixelRatio: dpr),
                child: Row(
                  textDirection: TextDirection.ltr,
                  children: [
                    boxed(
                      viewKey,
                      Padding(
                        padding: const EdgeInsets.all(4),
                        child: Transform.translate(
                          offset: offset,
                          child: MorphShapeView(
                            shape: MorphShapeCatalog.fromKind(
                              MorphShapeKind.clover4Leaf,
                            ),
                            size: size,
                            color: color,
                            edgeAntialias: mode,
                          ),
                        ),
                      ),
                    ),
                    boxed(
                      refKey,
                      Padding(
                        padding: const EdgeInsets.all(4),
                        child: CustomPaint(
                          size: size,
                          painter: _Reference(contour, offset, color),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
          final a = await captureRaster(tester, viewKey, pixelRatio: dpr);
          final b = await captureRaster(tester, refKey, pixelRatio: dpr);
          expect(a.width, b.width);
          // Interior opaque, exterior transparent.
          expect(a.alpha(a.width ~/ 2, a.height ~/ 2), 255);
          expect(a.alpha(0, 0), 0);
          var edge = 0, partial = 0, diff = 0, refPartial = 0;
          for (var y = 0; y < a.height; y++) {
            for (var x = 0; x < a.width; x++) {
              final p = a.alpha(x, y), q = b.alpha(x, y);
              if (p == 0 && q == 0) continue;
              if (p == 255 && q == 255) continue;
              edge++;
              diff += (p - q).abs();
              if (p > 8 && p < 247) partial++;
              if (q > 8 && q < 247) refPartial++;
            }
          }
          expect(edge, greaterThan(40));
          // Anti-aliased edge: most edge pixels have fractional coverage and
          // the profile stays close to the reference (tolerance per pixel).
          expect(partial, greaterThan(refPartial * .6));
          expect(
            diff / edge,
            lessThan(mode == MorphEdgeAntialias.native ? 1 : 28),
          );
          // No halo: color channels of translucent edge pixels stay the color
          // (premultiplied rawRgba): channel <= alpha-scaled color.
          for (var y = 0; y < a.height; y++) {
            for (var x = 0; x < a.width; x++) {
              final al = a.alpha(x, y);
              if (al == 0 || al == 255) continue;
              expect(a.channel(x, y, 2), lessThanOrEqualTo(0xc0 + 2));
            }
          }
        },
      );
    }
  }

  testWidgets('sampled edge keeps outer pixel ring clear (bounds bleed)', (
    tester,
  ) async {
    final key = GlobalKey();
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: RepaintBoundary(
            key: key,
            child: Padding(
              padding: const EdgeInsets.all(3),
              child: MorphShapeView(
                shape: MorphShapeCatalog.circle,
                size: const Size(24, 24),
                color: color,
              ),
            ),
          ),
        ),
      ),
    );
    final r = await captureRaster(tester, key, pixelRatio: 2);
    for (var i = 0; i < r.width; i++) {
      expect(r.alpha(i, 0), 0);
      expect(r.alpha(i, r.height - 1), 0);
    }
  });
}
