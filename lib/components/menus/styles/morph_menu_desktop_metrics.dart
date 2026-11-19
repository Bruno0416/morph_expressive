import 'package:flutter/foundation.dart';

import '../../../foundations/tokens/morph_density.dart';

/// Layout metrics of the desktop menu presentation for one [MorphDensity].
///
/// A component-specific table (not the generic density deltas): the desktop
/// menu is a fixed-height-row surface and its rows must stay monotonic across
/// densities (`compact <= standard <= comfortable`) for every field.
@immutable
class MorphMenuDesktopMetrics {
  /// Creates custom desktop metrics.
  const MorphMenuDesktopMetrics({
    required this.itemHeight,
    required this.iconSize,
    required this.horizontalPadding,
    required this.containerVerticalPadding,
    required this.iconGap,
    required this.shortcutGap,
    required this.itemGap,
    required this.groupLabelHeight,
    required this.containerRadius,
    required this.itemRadius,
  });

  /// Dense rows for information-heavy desktop UIs.
  static const MorphMenuDesktopMetrics compact = MorphMenuDesktopMetrics(
    itemHeight: 28,
    iconSize: 16,
    horizontalPadding: 8,
    containerVerticalPadding: 4,
    iconGap: 8,
    shortcutGap: 20,
    itemGap: 0,
    groupLabelHeight: 24,
    containerRadius: 12,
    itemRadius: 8,
  );

  /// Default desktop rows.
  static const MorphMenuDesktopMetrics standard = MorphMenuDesktopMetrics(
    itemHeight: 32,
    iconSize: 16,
    horizontalPadding: 10,
    containerVerticalPadding: 4,
    iconGap: 8,
    shortcutGap: 24,
    itemGap: 0,
    groupLabelHeight: 28,
    containerRadius: 12,
    itemRadius: 8,
  );

  /// Roomier rows for touch-capable desktops and accessibility.
  static const MorphMenuDesktopMetrics comfortable = MorphMenuDesktopMetrics(
    itemHeight: 40,
    iconSize: 18,
    horizontalPadding: 12,
    containerVerticalPadding: 6,
    iconGap: 10,
    shortcutGap: 28,
    itemGap: 2,
    groupLabelHeight: 32,
    containerRadius: 14,
    itemRadius: 8,
  );

  /// Metrics for [density].
  static MorphMenuDesktopMetrics of(MorphDensity density) => switch (density) {
    MorphDensity.compact => compact,
    MorphDensity.standard => standard,
    MorphDensity.comfortable => comfortable,
  };

  /// Visual row height (the row never gets shorter than this).
  final double itemHeight;

  /// Leading, trailing and chevron icon size.
  final double iconSize;

  /// Space from the row highlight edge to its content.
  final double horizontalPadding;

  /// Padding above the first and below the last row of the surface.
  final double containerVerticalPadding;

  /// Gap between the leading slot and the label, and before trailing parts.
  final double iconGap;

  /// Gap between the label and the right-aligned shortcut hint.
  final double shortcutGap;

  /// Space between consecutive rows.
  final double itemGap;

  /// Height of a section label row.
  final double groupLabelHeight;

  /// Corner radius of the menu surface.
  final double containerRadius;

  /// Corner radius of the row highlight.
  final double itemRadius;

  @override
  bool operator ==(Object other) =>
      other is MorphMenuDesktopMetrics &&
      other.itemHeight == itemHeight &&
      other.iconSize == iconSize &&
      other.horizontalPadding == horizontalPadding &&
      other.containerVerticalPadding == containerVerticalPadding &&
      other.iconGap == iconGap &&
      other.shortcutGap == shortcutGap &&
      other.itemGap == itemGap &&
      other.groupLabelHeight == groupLabelHeight &&
      other.containerRadius == containerRadius &&
      other.itemRadius == itemRadius;

  @override
  int get hashCode => Object.hash(
    itemHeight,
    iconSize,
    horizontalPadding,
    containerVerticalPadding,
    iconGap,
    shortcutGap,
    itemGap,
    groupLabelHeight,
    containerRadius,
    itemRadius,
  );
}
