import 'package:flutter_test/flutter_test.dart';

import 'dart:ui' show Size;

import 'package:morph_expressive/morph_expressive.dart';

void main() {
  test('native reference mask comparison at 128 square resolution', () {
    for (final kind in MorphShapeKind.values.where(
      (s) => s.geometry.provenance == MorphShapeProvenance.native,
    )) {
      final own = morphContourPath(kind.geometry.contour, const Size(1, 1));
      final reference = kind.polygon.toPath();
      var different = 0;
      for (var y = 0; y < 128; y++) {
        for (var x = 0; x < 128; x++) {
          final p = Offset((x + .5) / 128, (y + .5) / 128);
          if (own.contains(p) != reference.contains(p)) different++;
        }
      }
      // Legacy toPath rounds to thousandths; compare binary occupancy with
      // a 0.5% pixel budget in addition to exact control-point tests below.
      expect(different / (128 * 128), lessThan(.005), reason: kind.name);
    }
  });

  test(
    'loader pairs, reversed winding and interrupted seams preserve masks',
    () {
      final sequence = [
        MorphShapeCatalog.softBurst,
        MorphShapeCatalog.cookie9Sided,
        MorphShapeCatalog.pentagon,
        MorphShapeCatalog.pill,
        MorphShapeCatalog.sunny,
        MorphShapeCatalog.cookie4Sided,
        MorphShapeCatalog.oval,
        MorphShapeCatalog.softBurst,
      ];
      for (var i = 0; i < sequence.length - 1; i++) {
        final morph = const MorphGeometryEngine().prepare(
          sequence[i].contour,
          sequence[i + 1].contour.reversed,
        );
        for (final t in [.13, .5, .91]) {
          final visible = morph.at(t);
          final captured = const MorphGeometryEngine()
              .prepare(visible, MorphShapeCatalog.cookie7Sided.contour)
              .at(0);
          final a = morphContourPath(visible, const Size(1, 1));
          final b = morphContourPath(captured, const Size(1, 1));
          var mismatch = 0;
          for (var y = 0; y < 64; y++) {
            for (var x = 0; x < 64; x++) {
              final p = Offset((x + .5) / 64, (y + .5) / 64);
              if (a.contains(p) != b.contains(p)) mismatch++;
            }
          }
          expect(mismatch, 0);
        }
      }
    },
  );
  test(
    'nine native fixed definitions exactly preserve reference cubic geometry',
    () {
      for (final kind in MorphShapeKind.values) {
        final shape = kind.geometry;
        final reference = MorphShape.fromPolygon(kind.polygon);
        expect(shape.contour.curves.length, reference.contour.curves.length);
        for (var i = 0; i < shape.contour.curves.length; i++) {
          for (var sample = 0; sample <= 32; sample++) {
            expect(
              (shape.contour.curves[i].pointAt(sample / 32) -
                      reference.contour.curves[i].pointAt(sample / 32))
                  .distance,
              lessThan(1e-12),
            );
          }
        }
      }
      expect(
        MorphShapeCatalog.all
            .where((s) => s.provenance == MorphShapeProvenance.native)
            .length,
        9,
      );
    },
  );
  test('De Casteljau subdivision preserves curve and interior extrema', () {
    final c = MorphCubic(
      const Offset(0, 0),
      const Offset(0, 4),
      const Offset(2, 4),
      const Offset(2, 0),
    );
    expect(c.bounds.bottom, closeTo(3, 1e-10));
    for (final t in [0.1, 0.3, 0.5, 0.9]) {
      final (left, right) = c.split(t);
      for (var i = 0; i <= 20; i++) {
        final u = i / 20;
        expect((left.pointAt(u) - c.pointAt(t * u)).distance, lessThan(1e-10));
        expect(
          (right.pointAt(u) - c.pointAt(t + (1 - t) * u)).distance,
          lessThan(1e-10),
        );
      }
    }
  });

  test('catalog conversion and bounded retarget preserve visible contour', () {
    final engine = MorphGeometryEngine();
    final shapes = MorphShapeKind.values.map((s) => s.geometry).toList();
    expect(shapes.length, 35);
    var contour = shapes.first.contour;
    for (var i = 0; i < 250; i++) {
      final morph = engine.prepare(contour, shapes[i % shapes.length].contour);
      expect(morph.start.curves.length, lessThanOrEqualTo(512));
      // Matching only subdivides/reorders: bounds at interruption are unchanged.
      expect(
        (morph.at(0).bounds.topLeft - contour.bounds.topLeft).distance,
        lessThan(1e-7),
      );
      expect(
        (morph.at(0).bounds.bottomRight - contour.bounds.bottomRight).distance,
        lessThan(1e-7),
      );
      contour = morph.at(0.37);
    }
    expect(
      () => engine.prepare(contour, shapes.last.contour).at(double.nan),
      throwsArgumentError,
    );
  });
}
