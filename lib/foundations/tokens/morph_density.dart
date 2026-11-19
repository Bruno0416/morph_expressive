import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'morph_spacing.dart';

/// Global layout density of Morph components.
///
/// Density is a second, independent axis next to each component's `size`:
/// a `sm` button stays a `sm` button in every density, and only its layout
/// metrics (visual height, padding, gaps, row heights) move. Density never
/// scales text, never applies a transform and never changes colors, types,
/// variants or surfaces.
///
/// [standard] is the approved Morph geometry and resolves every metric to the
/// historical value. Configure it on the theme:
///
/// ```dart
/// final theme = MorphThemeData.light(seedColor: seed).copyWith(
///   density: .compact,
/// );
/// ```
enum MorphDensity {
  /// Tighter rows, smaller gaps and lower controls for information-dense UIs.
  compact,

  /// The default Morph geometry.
  standard,

  /// Slightly taller controls and more generous spacing.
  comfortable;

  /// The additive layout adjustments of this density.
  MorphDensityMetrics get metrics => switch (this) {
    MorphDensity.compact => MorphDensityMetrics.compact,
    MorphDensity.standard => MorphDensityMetrics.standard,
    MorphDensity.comfortable => MorphDensityMetrics.comfortable,
  };
}

/// Additive layout adjustments of a [MorphDensity], in logical pixels.
///
/// Every value is a delta added to a component's standard metric, never a
/// multiplier, so [standard] is exactly zero and the approved geometry is
/// preserved by construction. Components resolve a metric with [adjust],
/// which keeps results non-negative and above any functional minimum.
///
/// Larger controls tolerate larger reductions: [controlHeight] is indexed by
/// the component size step (0 = smallest). The values are monotonic: for any
/// metric, compact ≤ standard ≤ comfortable.
@immutable
class MorphDensityMetrics with Diagnosticable {
  /// Creates custom density metrics.
  const MorphDensityMetrics({
    required this.controlHeight,
    required this.rowHeight,
    required this.paddingHorizontal,
    required this.paddingVertical,
    required this.gap,
    required this.iconSize,
  });

  /// Compact adjustments.
  static const MorphDensityMetrics compact = MorphDensityMetrics(
    controlHeight: <double>[-4, -4, -8, -8, -8],
    rowHeight: -8,
    paddingHorizontal: -2,
    paddingVertical: -2,
    gap: -2,
    iconSize: -2,
  );

  /// Standard: no adjustment.
  static const MorphDensityMetrics standard = MorphDensityMetrics(
    controlHeight: <double>[0, 0, 0, 0, 0],
    rowHeight: 0,
    paddingHorizontal: 0,
    paddingVertical: 0,
    gap: 0,
    iconSize: 0,
  );

  /// Comfortable adjustments.
  static const MorphDensityMetrics comfortable = MorphDensityMetrics(
    controlHeight: <double>[4, 4, 4, 8, 8],
    rowHeight: 8,
    paddingHorizontal: 2,
    paddingVertical: 2,
    gap: 2,
    iconSize: 0,
  );

  /// Visual control height delta per size step (smallest first). Steps beyond
  /// the list reuse its last value.
  final List<double> controlHeight;

  /// Row height delta for list items, menu items and similar rows.
  final double rowHeight;

  /// Horizontal padding delta, applied per side.
  final double paddingHorizontal;

  /// Vertical padding delta, applied per side.
  final double paddingVertical;

  /// Gap delta between related elements (icon/label, items in a group).
  final double gap;

  /// Icon size delta for icons that are part of a control's layout.
  final double iconSize;

  /// Control height delta for the size step [step] (0 = smallest size).
  double controlHeightFor(int step) {
    if (controlHeight.isEmpty) {
      return 0;
    }
    return controlHeight[step.clamp(0, controlHeight.length - 1)];
  }

  /// Adds [delta] to [standard], never going below [min] (or zero).
  static double adjust(double standard, double delta, {double min = 0}) {
    final double value = standard + delta;
    return value < min ? min : value;
  }

  /// Applies the padding deltas to [padding], keeping each side ≥ 0.
  EdgeInsets padding(EdgeInsets padding) {
    if (paddingHorizontal == 0 && paddingVertical == 0) {
      return padding;
    }
    return EdgeInsets.fromLTRB(
      adjust(padding.left, paddingHorizontal),
      adjust(padding.top, paddingVertical),
      adjust(padding.right, paddingHorizontal),
      adjust(padding.bottom, paddingVertical),
    );
  }

  /// Applies the gap delta to a spacing scale, keeping each step ≥ 0 and the
  /// scale ordered.
  MorphSpacing spacing(MorphSpacing base) {
    if (gap == 0) {
      return base;
    }
    double step(double value, double factor) => adjust(value, gap * factor);
    return MorphSpacing(
      xs: step(base.xs, 0.5),
      sm: step(base.sm, 1),
      md: step(base.md, 1),
      lg: step(base.lg, 2),
      xl: step(base.xl, 2),
      xxl: step(base.xxl, 4),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is MorphDensityMetrics &&
      listEquals(other.controlHeight, controlHeight) &&
      other.rowHeight == rowHeight &&
      other.paddingHorizontal == paddingHorizontal &&
      other.paddingVertical == paddingVertical &&
      other.gap == gap &&
      other.iconSize == iconSize;

  @override
  int get hashCode => Object.hash(
    Object.hashAll(controlHeight),
    rowHeight,
    paddingHorizontal,
    paddingVertical,
    gap,
    iconSize,
  );

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(IterableProperty<double>('controlHeight', controlHeight))
      ..add(DoubleProperty('rowHeight', rowHeight))
      ..add(DoubleProperty('paddingHorizontal', paddingHorizontal))
      ..add(DoubleProperty('paddingVertical', paddingVertical))
      ..add(DoubleProperty('gap', gap))
      ..add(DoubleProperty('iconSize', iconSize));
  }
}
