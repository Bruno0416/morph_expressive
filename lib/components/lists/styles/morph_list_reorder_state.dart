import 'package:flutter/widgets.dart';

import '../../../foundations/foundations.dart';
import 'morph_list_theme.dart';

/// Visual and motion defaults for list reorder.
@immutable
class MorphListReorderState {
  /// Creates list reorder state.
  const MorphListReorderState({
    this.showDragHandle = true,
    this.dragElevation = MorphElevation.level4,
    this.dragScale = 1.02,
    this.dragRadius,
    this.dragColor,
    this.placeholderColor,
    this.placeholderBorder,
    this.placeholderRadius,
    this.displaceMotion = MorphMotion.expressiveSpatialPress,
    this.settleMotion = MorphMotion.expressiveSpatialDefault,
  });

  /// Theme defaults.
  static const MorphListReorderState defaults = MorphListReorderState();

  /// Whether to show a trailing drag-handle cue.
  final bool showDragHandle;

  /// Elevation while dragging.
  final double dragElevation;

  /// Scale while dragging.
  final double dragScale;

  /// Corner radius while dragging; defaults to card-list outer radius.
  final double? dragRadius;

  /// Fill while dragging; defaults to surface container high.
  final Color? dragColor;

  /// Placeholder slot fill; defaults to surface container low.
  final Color? placeholderColor;

  /// Placeholder slot outline.
  final BorderSide? placeholderBorder;

  /// Placeholder corner radius; defaults to card-list outer radius.
  final double? placeholderRadius;

  /// Neighbor displacement spring (noticeable overshoot).
  final MorphSpring displaceMotion;

  /// Spring that eases the lifted row into its slot before the order changes.
  final MorphSpring settleMotion;

  /// Resolved drag radius.
  double resolvedDragRadius(MorphListTheme listTheme) =>
      dragRadius ?? listTheme.cardList.outerRadius;

  /// Resolved placeholder radius.
  double resolvedPlaceholderRadius(MorphListTheme listTheme) =>
      placeholderRadius ?? listTheme.cardList.outerRadius;

  /// Drag fill.
  Color resolvedDragColor(MorphColorScheme scheme) =>
      dragColor ?? scheme.surfaceContainerHigh;

  /// Placeholder fill.
  Color resolvedPlaceholderColor(MorphColorScheme scheme) =>
      placeholderColor ?? scheme.surfaceContainerLow;

  /// copyWith.
  MorphListReorderState copyWith({
    bool? showDragHandle,
    double? dragElevation,
    double? dragScale,
    double? dragRadius,
    Color? dragColor,
    Color? placeholderColor,
    BorderSide? placeholderBorder,
    double? placeholderRadius,
    MorphSpring? displaceMotion,
    MorphSpring? settleMotion,
  }) {
    return MorphListReorderState(
      showDragHandle: showDragHandle ?? this.showDragHandle,
      dragElevation: dragElevation ?? this.dragElevation,
      dragScale: dragScale ?? this.dragScale,
      dragRadius: dragRadius ?? this.dragRadius,
      dragColor: dragColor ?? this.dragColor,
      placeholderColor: placeholderColor ?? this.placeholderColor,
      placeholderBorder: placeholderBorder ?? this.placeholderBorder,
      placeholderRadius: placeholderRadius ?? this.placeholderRadius,
      displaceMotion: displaceMotion ?? this.displaceMotion,
      settleMotion: settleMotion ?? this.settleMotion,
    );
  }
}
