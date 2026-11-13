import 'dart:math' as math;

import 'morph_contour.dart';
import 'morph_cubic.dart';
export 'morph_contour.dart';
export 'morph_cubic.dart';

/// Prepares orientation, segment partition and cyclic seam once per target.
/// No dependency morph evaluator, LCM expansion or per-frame search is used.
class MorphGeometryEngine {
  const MorphGeometryEngine();
  MorphPreparedGeometry prepare(MorphContour start, MorphContour end) {
    if (start.signedArea.abs() < 1e-12 || end.signedArea.abs() < 1e-12) {
      throw ArgumentError('Morph endpoints must enclose nonzero area.');
    }
    if (start.signedArea * end.signedArea < 0) end = end.reversed;
    final count = math.max(start.curves.length, end.curves.length);
    final a = _partition(start.curves, count),
        b = _partition(end.curves, count);
    // Anchors and tangents both contribute; this aligns corners/lobes instead
    // of choosing a seam using just the bounding rectangle.
    var best = double.infinity, seam = 0;
    for (var shift = 0; shift < count; shift++) {
      var cost = 0.0;
      for (var i = 0; i < count; i++) {
        final x = a[i], y = b[(i + shift) % count];
        cost +=
            (x.start - y.start).distanceSquared +
            .25 * (x.control1 - y.control1).distanceSquared +
            .25 * (x.control2 - y.control2).distanceSquared;
      }
      if (cost < best) {
        best = cost;
        seam = shift;
      }
    }
    return MorphPreparedGeometry._(
      MorphContour(a, center: start.center),
      MorphContour(
        List.generate(count, (i) => b[(i + seam) % count]),
        center: end.center,
      ),
    );
  }

  List<MorphCubic> _partition(List<MorphCubic> input, int count) {
    final result = input.toList();
    while (result.length < count) {
      var index = 0;
      for (var i = 1; i < result.length; i++) {
        if (result[i].controlLength > result[index].controlLength) index = i;
      }
      final (a, b) = result[index].split(.5);
      result.replaceRange(index, index + 1, [a, b]);
    }
    return result;
  }
}

/// Immutable value; capture [at] before preparing a new transition.
/// Retargeting cannot grow beyond the largest input segment count (max 512).
class MorphPreparedGeometry {
  MorphPreparedGeometry._(this.start, this.end);
  final MorphContour start, end;
  MorphContour at(double progress) {
    if (!progress.isFinite) throw ArgumentError.value(progress, 'progress');
    final t = progress.clamp(0.0, 1.0);
    if (t == 0) return start;
    if (t == 1) return end;
    return MorphContour(
      List.generate(
        start.curves.length,
        (i) => start.curves[i].interpolate(end.curves[i], t),
      ),
      center: start.center + (end.center - start.center) * t,
    );
  }
}
