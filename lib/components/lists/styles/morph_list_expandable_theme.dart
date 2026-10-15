import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../../../foundations/foundations.dart';
import 'morph_list_card_list_theme.dart';

/// Theme values for expandable list widgets.
///
/// Stack geometry ([defaultOuterRadius], [defaultInnerRadius], [defaultGap])
/// matches [MorphListCardListTheme].
@immutable
class MorphListExpandableTheme {
  /// defaultOuterRadius.
  static const double defaultOuterRadius =
      MorphListCardListTheme.defaultOuterRadius;

  /// defaultInnerRadius.
  static const double defaultInnerRadius =
      MorphListCardListTheme.defaultInnerRadius;

  /// defaultHoverRadius.
  static const double defaultHoverRadius = defaultOuterRadius;

  /// defaultPressedRadius.
  ///
  /// Press uses the 16dp outer radius on every corner.
  static const double defaultPressedRadius = defaultOuterRadius;

  /// defaultGap.
  static const double defaultGap = MorphListCardListTheme.defaultGap;

  /// defaultTitleSubtitleGap.
  static const double defaultTitleSubtitleGap = 4;

  /// defaultHeaderPadding.
  ///
  /// Matches [MorphListCardListTheme.defaultItemPadding] so expandable headers
  /// align with card / dismissible list rows.
  static const EdgeInsets defaultHeaderPadding = EdgeInsets.symmetric(
    horizontal: 16,
    vertical: 10,
  );

  /// defaultBodyPadding.
  static const EdgeInsets defaultBodyPadding = EdgeInsets.fromLTRB(
    16,
    0,
    16,
    20,
  );

  /// defaultIconPadding.
  static const EdgeInsets defaultIconPadding = EdgeInsets.all(8);

  /// Width of the pill behind the trailing expand icon.
  ///
  /// Matches the narrow small icon button (32 x 40). The box stays this size
  /// when collapsed or expanded; only the fill is shown while expanded. Set to
  /// `0` to disable the chrome entirely.
  static const double defaultExpandedIconBackgroundSize = 32;

  /// Height of the pill behind the trailing expand icon.
  ///
  /// Matches the narrow small icon button (32 x 40).
  static const double defaultExpandedIconBackgroundHeight = 40;

  /// defaultIconRotationAngle.
  static const double defaultIconRotationAngle = math.pi;

  /// defaultExpandTooltip.
  static const String defaultExpandTooltip = 'Expand';

  /// defaultCollapseTooltip.
  static const String defaultCollapseTooltip = 'Collapse';

  /// MorphListExpandableTheme.

  const MorphListExpandableTheme({
    this.outerRadius = defaultOuterRadius,
    this.innerRadius = defaultInnerRadius,
    this.hoverRadius = defaultHoverRadius,
    this.pressedRadius = defaultPressedRadius,
    this.gap = defaultGap,
    this.titleSubtitleGap = defaultTitleSubtitleGap,
    this.headerPadding = defaultHeaderPadding,
    this.bodyPadding = defaultBodyPadding,
    this.iconPadding = defaultIconPadding,
    this.expandedIconBackgroundSize = defaultExpandedIconBackgroundSize,
    this.expandedIconBackgroundHeight = defaultExpandedIconBackgroundHeight,
    this.expandedIconBackground,
    this.expandedStateFill = true,
    this.expandedStateColor,
    this.roundSublistBottom = true,
    this.iconRotationAngle = defaultIconRotationAngle,
    this.expandTooltip = defaultExpandTooltip,
    this.collapseTooltip = defaultCollapseTooltip,
    this.expandMotion = MorphMotion.expressiveSpatialDefault,
    this.collapseMotion = MorphMotion.expressiveSpatialDefault,
    this.allowMultipleExpanded = false,
  });

  /// defaults.

  static const MorphListExpandableTheme defaults = MorphListExpandableTheme();

  /// outerRadius.

  final double outerRadius;

  /// innerRadius.
  final double innerRadius;

  /// hoverRadius.
  final double hoverRadius;

  /// pressedRadius.
  final double pressedRadius;

  /// gap.
  final double gap;

  /// titleSubtitleGap.
  final double titleSubtitleGap;

  /// headerPadding.
  final EdgeInsetsGeometry headerPadding;

  /// bodyPadding.
  final EdgeInsetsGeometry bodyPadding;

  /// iconPadding.
  final EdgeInsetsGeometry iconPadding;

  /// Width of the pill behind the trailing expand icon.
  ///
  /// Size is stable across expand and collapse; only the fill toggles.
  /// Set to `0` to disable.
  final double expandedIconBackgroundSize;

  /// Height of the pill behind the trailing expand icon.
  final double expandedIconBackgroundHeight;

  /// Fill for the expanded trailing-icon chrome. The chrome has no fill at
  /// rest.
  ///
  /// When null, resolves to [MorphColorScheme.surfaceContainer].
  final Color? expandedIconBackground;

  /// Whether an expanded row and its sublist switch to [expandedStateColor].
  ///
  /// When false, they keep the rest fill.
  final bool expandedStateFill;

  /// Fill for an expanded row and its sublist when [expandedStateFill] is on.
  ///
  /// When null, resolves to [MorphColorScheme.surfaceContainerHigh].
  final Color? expandedStateColor;

  /// Whether the last row of a sublist expansion always takes the outer
  /// bottom corners, like the last row of a standalone list.
  ///
  /// When false, it does so only when its parent row is the last row, and
  /// otherwise keeps the inner radius to sit flush with the main list.
  final bool roundSublistBottom;

  /// iconRotationAngle.
  final double iconRotationAngle;

  /// expandTooltip.
  final String expandTooltip;

  /// collapseTooltip.
  final String collapseTooltip;

  /// expandMotion.
  final MorphSpring expandMotion;

  /// collapseMotion.
  final MorphSpring collapseMotion;

  /// allowMultipleExpanded.
  final bool allowMultipleExpanded;

  /// backgroundColor.

  Color backgroundColor(MorphColorScheme scheme) => scheme.surface;

  /// Expanded trailing-icon chrome color.
  Color resolvedExpandedIconBackground(MorphColorScheme scheme) =>
      expandedIconBackground ?? scheme.surfaceContainer;

  /// Expanded row and sublist fill.
  Color resolvedExpandedStateColor(MorphColorScheme scheme) =>
      expandedStateColor ?? scheme.surfaceContainerHigh;

  /// copyWith.

  MorphListExpandableTheme copyWith({
    double? outerRadius,
    double? innerRadius,
    double? hoverRadius,
    double? pressedRadius,
    double? gap,
    double? titleSubtitleGap,
    EdgeInsetsGeometry? headerPadding,
    EdgeInsetsGeometry? bodyPadding,
    EdgeInsetsGeometry? iconPadding,
    double? expandedIconBackgroundSize,
    double? expandedIconBackgroundHeight,
    Color? expandedIconBackground,
    bool? expandedStateFill,
    Color? expandedStateColor,
    bool? roundSublistBottom,
    double? iconRotationAngle,
    String? expandTooltip,
    String? collapseTooltip,
    MorphSpring? expandMotion,
    MorphSpring? collapseMotion,
    bool? allowMultipleExpanded,
  }) {
    return MorphListExpandableTheme(
      outerRadius: outerRadius ?? this.outerRadius,
      innerRadius: innerRadius ?? this.innerRadius,
      hoverRadius: hoverRadius ?? this.hoverRadius,
      pressedRadius: pressedRadius ?? this.pressedRadius,
      gap: gap ?? this.gap,
      titleSubtitleGap: titleSubtitleGap ?? this.titleSubtitleGap,
      headerPadding: headerPadding ?? this.headerPadding,
      bodyPadding: bodyPadding ?? this.bodyPadding,
      iconPadding: iconPadding ?? this.iconPadding,
      expandedIconBackgroundSize:
          expandedIconBackgroundSize ?? this.expandedIconBackgroundSize,
      expandedIconBackgroundHeight:
          expandedIconBackgroundHeight ?? this.expandedIconBackgroundHeight,
      expandedIconBackground:
          expandedIconBackground ?? this.expandedIconBackground,
      expandedStateFill: expandedStateFill ?? this.expandedStateFill,
      expandedStateColor: expandedStateColor ?? this.expandedStateColor,
      roundSublistBottom: roundSublistBottom ?? this.roundSublistBottom,
      iconRotationAngle: iconRotationAngle ?? this.iconRotationAngle,
      expandTooltip: expandTooltip ?? this.expandTooltip,
      collapseTooltip: collapseTooltip ?? this.collapseTooltip,
      expandMotion: expandMotion ?? this.expandMotion,
      collapseMotion: collapseMotion ?? this.collapseMotion,
      allowMultipleExpanded:
          allowMultipleExpanded ?? this.allowMultipleExpanded,
    );
  }
}
