import 'dart:math' as math;
import 'dart:ui' show Offset, Rect;

/// Immutable cubic Bézier, in a renderer-independent 2D coordinate space.
class MorphCubic {
  MorphCubic(this.start, this.control1, this.control2, this.end) {
    for (final p in [start, control1, control2, end]) {
      if (!p.dx.isFinite || !p.dy.isFinite) {
        throw ArgumentError('Cubic coordinates must be finite.');
      }
    }
  }

  final Offset start, control1, control2, end;

  static double _parameter(double t) {
    if (!t.isFinite) throw ArgumentError.value(t, 'progress', 'must be finite');
    return t.clamp(0.0, 1.0);
  }

  Offset pointAt(double progress) {
    final t = _parameter(progress), s = 1 - t;
    return start * (s * s * s) +
        control1 * (3 * s * s * t) +
        control2 * (3 * s * t * t) +
        end * (t * t * t);
  }

  Offset derivativeAt(double progress) {
    final t = _parameter(progress), s = 1 - t;
    return (control1 - start) * (3 * s * s) +
        (control2 - control1) * (6 * s * t) +
        (end - control2) * (3 * t * t);
  }

  /// Exact De Casteljau split; no sampling or curve fitting.
  (MorphCubic, MorphCubic) split(double progress) {
    final t = _parameter(progress);
    final a = Offset.lerp(start, control1, t)!;
    final b = Offset.lerp(control1, control2, t)!;
    final c = Offset.lerp(control2, end, t)!;
    final d = Offset.lerp(a, b, t)!, e = Offset.lerp(b, c, t)!;
    final f = Offset.lerp(d, e, t)!;
    return (MorphCubic(start, a, d, f), MorphCubic(f, e, c, end));
  }

  MorphCubic map(Offset Function(Offset) transform) => MorphCubic(
    transform(start),
    transform(control1),
    transform(control2),
    transform(end),
  );
  MorphCubic get reversed => MorphCubic(end, control2, control1, start);

  MorphCubic interpolate(MorphCubic other, double progress) {
    final t = _parameter(progress);
    return MorphCubic(
      Offset.lerp(start, other.start, t)!,
      Offset.lerp(control1, other.control1, t)!,
      Offset.lerp(control2, other.control2, t)!,
      Offset.lerp(end, other.end, t)!,
    );
  }

  /// Tight axis-aligned bounds, including interior derivative roots.
  Rect get bounds {
    final points = [start, end];
    void roots(double p0, double p1, double p2, double p3) {
      final a = -p0 + 3 * p1 - 3 * p2 + p3,
          b = 2 * (p0 - 2 * p1 + p2),
          c = p1 - p0;
      void add(double t) {
        if (t > 0 && t < 1) points.add(pointAt(t));
      }

      if (a.abs() < 1e-14) {
        if (b.abs() > 1e-14) add(-c / b);
      } else {
        final discriminant = b * b - 4 * a * c;
        if (discriminant >= 0) {
          final d = math.sqrt(discriminant);
          add((-b - d) / (2 * a));
          add((-b + d) / (2 * a));
        }
      }
    }

    roots(start.dx, control1.dx, control2.dx, end.dx);
    roots(start.dy, control1.dy, control2.dy, end.dy);
    return Rect.fromLTRB(
      points.map((p) => p.dx).reduce(math.min),
      points.map((p) => p.dy).reduce(math.min),
      points.map((p) => p.dx).reduce(math.max),
      points.map((p) => p.dy).reduce(math.max),
    );
  }

  /// Control polygon length: conservative, used only to choose subdivisions.
  double get controlLength =>
      (control1 - start).distance +
      (control2 - control1).distance +
      (end - control2).distance;
}
