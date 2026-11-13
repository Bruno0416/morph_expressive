import 'dart:math' as math;

import 'package:flutter/animation.dart' show Curves;
import 'package:flutter/foundation.dart';

import '../enums/morph_tabs_indicator_options.dart';

/// Horizontal extent of the indicator, in the coordinate space of the tab
/// track (the same space in which the tabs are laid out, so a scrolling bar
/// never needs its offset applied twice).
@immutable
class MorphTabsEdges {
  /// Creates an extent. [right] is never below [left].
  const MorphTabsEdges(this.left, double right)
    : right = right < left ? left : right;

  /// Left edge.
  final double left;

  /// Right edge.
  final double right;

  /// Width, never negative.
  double get width => right - left;

  /// Horizontal centre.
  double get center => (left + right) / 2;

  /// Whether both edges are within [tolerance] of [other].
  bool near(MorphTabsEdges other, [double tolerance = 0.5]) =>
      (left - other.left).abs() <= tolerance &&
      (right - other.right).abs() <= tolerance;

  @override
  bool operator ==(Object other) =>
      other is MorphTabsEdges && other.left == left && other.right == right;

  @override
  int get hashCode => Object.hash(left, right);

  @override
  String toString() => 'MorphTabsEdges($left, $right)';
}

/// Pure functions that turn measured tab extents and a progress into the
/// visible indicator extent. No state, no animation: the same inputs always
/// give the same output, which is what keeps the indicator in lockstep with
/// the pages during a swipe.
abstract final class MorphTabsGeometry {
  /// Extent between [a] and [b] at [t] (`0` = [a], `1` = [b]).
  ///
  /// [MorphTabsIndicatorMotion.slide] interpolates both edges together.
  /// [MorphTabsIndicatorMotion.elastic] moves the leading edge (the one in the
  /// direction of travel) ahead of the trailing edge by at most [elasticity]
  /// of the eased distance. Both edges stay monotonic, equal [a]/[b] at the
  /// ends and the width never turns negative.
  static MorphTabsEdges between(
    MorphTabsEdges a,
    MorphTabsEdges b,
    double t, {
    MorphTabsIndicatorMotion motion = MorphTabsIndicatorMotion.slide,
    double elasticity = 0.3,
  }) {
    final double u = t.clamp(0.0, 1.0).toDouble();
    if (u <= 0) {
      return a;
    }
    if (u >= 1) {
      return b;
    }
    if (motion == MorphTabsIndicatorMotion.slide) {
      return MorphTabsEdges(_mix(a.left, b.left, u), _mix(a.right, b.right, u));
    }
    // The stretch is bounded by the size of the indicator, not by the distance:
    // a long jump must not turn into a long bar.
    final double distance = (b.center - a.center).abs();
    final double reference = math.max(a.width, b.width);
    if (distance < 1e-9) {
      return MorphTabsEdges(_mix(a.left, b.left, u), _mix(a.right, b.right, u));
    }
    final double k =
        elasticity.clamp(0.0, 1.0).toDouble() *
        (distance <= reference ? 1.0 : reference / distance);
    final double lead = _mix(u, Curves.easeOutCubic.transform(u), k);
    final double trail = _mix(u, Curves.easeInCubic.transform(u), k);
    final bool forward = b.center >= a.center;
    final double left = _mix(a.left, b.left, forward ? trail : lead);
    final double right = _mix(a.right, b.right, forward ? lead : trail);
    return MorphTabsEdges(left, right);
  }

  /// Extent at the fractional tab index [position], between the neighbouring
  /// [targets]. Clamped to the first and last tab.
  static MorphTabsEdges atPosition(
    List<MorphTabsEdges> targets,
    double position, {
    MorphTabsIndicatorMotion motion = MorphTabsIndicatorMotion.slide,
    double elasticity = 0.3,
  }) {
    assert(targets.isNotEmpty);
    final double p = position.clamp(0.0, (targets.length - 1).toDouble());
    final int k = math.min(p.floor(), math.max(0, targets.length - 2));
    if (targets.length == 1) {
      return targets.first;
    }
    return between(
      targets[k],
      targets[k + 1],
      p - k,
      motion: motion,
      elasticity: elasticity,
    );
  }

  /// Selection weight (`0..1`) of every tab for a fractional [position].
  ///
  /// When [from] and [to] are given (programmatic travel) only those two tabs
  /// take part, so tabs in between never look selected.
  static List<double> weights(
    int count,
    double position, {
    int? from,
    int? to,
  }) {
    final List<double> result = List<double>.filled(count, 0);
    if (count == 0) {
      return result;
    }
    if (from != null && to != null && from != to) {
      final double s = ((position - from) / (to - from)).clamp(0.0, 1.0);
      result[from.clamp(0, count - 1)] = 1 - s;
      result[to.clamp(0, count - 1)] = s;
      return result;
    }
    final double p = position.clamp(0.0, (count - 1).toDouble());
    final int k = p.floor();
    final double f = p - k;
    result[k] = 1 - f;
    if (k + 1 < count) {
      result[k + 1] = f;
    }
    return result;
  }

  static double _mix(double a, double b, double t) => a + (b - a) * t;
}
