import 'package:flutter/widgets.dart';

/// Resolved height/padding/icon metrics for the navigation bar.
@immutable
class MorphNavMetrics {
  /// heightSmall.
  final double heightSmall;

  /// heightMedium.
  final double heightMedium;

  /// iconSize.
  final double iconSize;

  /// padding.
  final EdgeInsetsGeometry padding;

  /// indicatorThickness.
  final double indicatorThickness; // for underline
  /// MorphNavMetrics.
  const MorphNavMetrics({
    required this.heightSmall,
    required this.heightMedium,
    required this.iconSize,
    required this.padding,
    required this.indicatorThickness,
  });
}
