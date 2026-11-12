import 'dart:math' as math;
import 'dart:ui' show Offset, Rect;

import 'morph_cubic.dart';

/// One closed contour. Holes, multiple contours and self-intersections are
/// outside the supported topology. Closure tolerance is 1e-7 coordinate units.
class MorphContour {
  MorphContour(
    Iterable<MorphCubic> curves, {
    this.center = const Offset(.5, .5),
  }) : curves = List.unmodifiable(curves) {
    if (this.curves.isEmpty || this.curves.length > 512) {
      throw ArgumentError('A contour requires 1–512 cubic segments.');
    }
    if (!center.dx.isFinite || !center.dy.isFinite) {
      throw ArgumentError('Invalid center');
    }
    for (var i = 0; i < this.curves.length; i++) {
      if ((this.curves[i].end - this.curves[(i + 1) % this.curves.length].start)
              .distance >
          1e-7) {
        throw ArgumentError('Contour is not closed at segment $i.');
      }
    }
  }
  final List<MorphCubic> curves;
  final Offset center;
  Rect get bounds =>
      curves.map((c) => c.bounds).reduce((a, b) => a.expandToInclude(b));

  /// Three-point Gauss integration exactly integrates cubic x dy - y dx
  /// (a degree-five polynomial), apart from floating-point roundoff.
  double get signedArea {
    var area = 0.0;
    for (final c in curves) {
      for (final (t, w) in [
        (0.1127016653792583, 5 / 18),
        (.5, 4 / 9),
        (.8872983346207417, 5 / 18),
      ]) {
        final p = c.pointAt(t), d = c.derivativeAt(t);
        area += w * (p.dx * d.dy - p.dy * d.dx) / 2;
      }
    }
    return area;
  }

  /// Largest distance from [from] (default: the persistent [center]) to the
  /// curve, from 24 samples per cubic plus the exact anchors. Used once per
  /// shape to size a stable rotation envelope.
  double maxRadius([Offset? from]) {
    final origin = from ?? center;
    var r = 0.0;
    for (final c in curves) {
      for (var i = 0; i <= 24; i++) {
        r = math.max(r, (c.pointAt(i / 24) - origin).distance);
      }
    }
    return r;
  }

  MorphContour get reversed =>
      MorphContour(curves.reversed.map((c) => c.reversed), center: center);
  MorphContour map(Offset Function(Offset) transform) => MorphContour(
    curves.map((c) => c.map(transform)),
    center: transform(center),
  );

  /// Rotation in radians about the persistent contour center.
  MorphContour rotated(double radians) {
    if (!radians.isFinite) throw ArgumentError.value(radians, 'radians');
    final cos = math.cos(radians), sin = math.sin(radians);
    return map((p) {
      final d = p - center;
      return center + Offset(d.dx * cos - d.dy * sin, d.dx * sin + d.dy * cos);
    });
  }

  /// One-time normalization, never performed on animated frames.
  MorphContour normalized() {
    final b = bounds, side = math.max(b.width, b.height);
    if (side <= 1e-12) {
      throw ArgumentError('Cannot normalize a degenerate contour.');
    }
    return map((p) => (p - b.center) / side + const Offset(.5, .5));
  }
}
