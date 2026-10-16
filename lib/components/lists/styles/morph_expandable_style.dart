import 'package:material_ui/material_ui.dart';

import '../../../foundations/foundations.dart';
import '../enums/morph_expandable_enums.dart';
import 'morph_list_theme.dart';

/// Visual style configuration for `MorphExpandableList`.
@immutable
class MorphExpandableStyle {
  // ── Shape ──

  /// Outer radius for the first and last item (and single items).
  final double outerRadius;

  /// Inner radius for middle items.
  final double innerRadius;

  /// Inner radius applied when the card is hovered.
  final double hoverRadius;

  /// Inner radius applied when the card is pressed.
  final double pressedRadius;

  /// Gap between cards.
  final double gap;

  /// Border radius applied uniformly to the entire card when expanded.
  final double? expandedRadius;

  // ── Appearance ──

  /// Background colour for each card.
  final Color? color;

  /// Border drawn around each card.
  final BorderSide? border;

  /// Elevation of the card.
  final double elevation;

  // ── Padding ──

  /// Padding applied inside each header.
  final EdgeInsetsGeometry? headerPadding;

  /// Padding applied inside each body.
  final EdgeInsetsGeometry? bodyPadding;

  /// Gap between simple-mode title and subtitle/body text.
  final double titleSubtitleGap;

  /// Outer margin around each card.
  final EdgeInsetsGeometry? margin;

  // ── Trailing icon ──

  /// Expand icon padding.
  final EdgeInsetsGeometry iconPadding;

  /// Width of the pill behind the trailing expand icon.
  ///
  /// Size is stable across expand and collapse; only the fill toggles.
  /// Defaults to [MorphListExpandableTheme.defaultExpandedIconBackgroundSize].
  final double expandedIconBackgroundSize;

  /// Height of the pill behind the trailing expand icon.
  ///
  /// Defaults to [MorphListExpandableTheme.defaultExpandedIconBackgroundHeight].
  final double expandedIconBackgroundHeight;

  /// Fill for the expanded trailing-icon chrome. The chrome has no fill at
  /// rest.
  ///
  /// When null, resolves to [MorphColorScheme.surfaceContainer].
  final Color? expandedIconBackground;

  // ── Expanded state ──

  /// Whether an expanded row and its sublist switch to [expandedStateColor].
  ///
  /// When false, they keep the rest fill ([color]).
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

  /// Icon rotation angle in clockwise radians.
  final double iconRotationAngle;

  /// The icon in the collapsed state. Set to null to hide the default icon.
  final Widget? expandIcon;

  /// The icon in the expanded state. Set to null to hide the default icon.
  final Widget? collapseIcon;

  /// Expand icon placement.
  final MorphExpandableIconPlacement iconPlacement;

  // ── Interaction ──

  /// Whether [InkWell] will be used in the header for a ripple effect.
  final bool useInkWell;

  /// If true, the header can be clicked by the user to expand or collapse.
  final bool tapHeaderToToggle;

  /// If true, the body can be clicked by the user to expand.
  final bool tapBodyToExpand;

  /// If true, the body can be clicked by the user to collapse.
  final bool tapBodyToCollapse;

  // ── Layout ──

  /// The alignment of the header relative to the expand icon.
  final CrossAxisAlignment headerAlignment;

  /// The alignment of the body content.
  final AlignmentGeometry bodyAlignment;

  // ── Haptics & Feedback ──

  /// Haptic feedback level on tap.
  final MorphHapticFeedback haptic;

  /// Ink splash colour.
  final Color? splashColor;

  /// Ink highlight colour.
  final Color? highlightColor;

  /// Splash factory.
  final InteractiveInkFeatureFactory? splashFactory;

  /// Whether detected gestures should provide acoustic / haptic feedback.
  final bool enableFeedback;

  /// If true, toggling expansion/collapse is only possible by tapping the icon.
  final bool tapIconToToggle;

  /// The tooltip message displayed when hovering over or long-pressing the expand icon.
  final String? expandTooltip;

  /// The tooltip message displayed when hovering over or long-pressing the collapse icon.
  final String? collapseTooltip;

  /// MorphExpandableStyle.

  const MorphExpandableStyle({
    this.outerRadius = MorphListExpandableTheme.defaultOuterRadius,
    this.innerRadius = MorphListExpandableTheme.defaultInnerRadius,
    this.hoverRadius = MorphListExpandableTheme.defaultHoverRadius,
    this.pressedRadius = MorphListExpandableTheme.defaultPressedRadius,
    this.gap = MorphListExpandableTheme.defaultGap,
    this.expandedRadius,
    this.color,
    this.border,
    this.elevation = 0,
    this.headerPadding,
    this.bodyPadding,
    this.titleSubtitleGap = MorphListExpandableTheme.defaultTitleSubtitleGap,
    this.margin,
    this.iconPadding = MorphListExpandableTheme.defaultIconPadding,
    this.expandedIconBackgroundSize =
        MorphListExpandableTheme.defaultExpandedIconBackgroundSize,
    this.expandedIconBackgroundHeight =
        MorphListExpandableTheme.defaultExpandedIconBackgroundHeight,
    this.expandedIconBackground,
    this.expandedStateFill = true,
    this.expandedStateColor,
    this.roundSublistBottom = true,
    this.iconRotationAngle = MorphListExpandableTheme.defaultIconRotationAngle,
    this.expandIcon = const Icon(MorphIcons.expand_more_rounded),
    this.collapseIcon = const Icon(MorphIcons.expand_more_rounded),
    this.iconPlacement = MorphExpandableIconPlacement.right,
    this.useInkWell = true,
    this.tapHeaderToToggle = true,
    this.tapBodyToExpand = false,
    this.tapBodyToCollapse = false,
    this.headerAlignment = CrossAxisAlignment.start,
    this.bodyAlignment = Alignment.topLeft,
    this.haptic = MorphHapticFeedback.inherit,
    this.splashColor,
    this.highlightColor,
    this.splashFactory,
    this.enableFeedback = true,
    this.tapIconToToggle = false,
    this.expandTooltip = MorphListExpandableTheme.defaultExpandTooltip,
    this.collapseTooltip = MorphListExpandableTheme.defaultCollapseTooltip,
  });

  /// Builds a style from the given [MorphListExpandableTheme].
  factory MorphExpandableStyle.fromTheme(MorphListExpandableTheme theme) {
    return MorphExpandableStyle(
      outerRadius: theme.outerRadius,
      innerRadius: theme.innerRadius,
      hoverRadius: theme.hoverRadius,
      pressedRadius: theme.pressedRadius,
      gap: theme.gap,
      titleSubtitleGap: theme.titleSubtitleGap,
      iconPadding: theme.iconPadding,
      expandedIconBackgroundSize: theme.expandedIconBackgroundSize,
      expandedIconBackgroundHeight: theme.expandedIconBackgroundHeight,
      expandedIconBackground: theme.expandedIconBackground,
      expandedStateFill: theme.expandedStateFill,
      expandedStateColor: theme.expandedStateColor,
      roundSublistBottom: theme.roundSublistBottom,
      iconRotationAngle: theme.iconRotationAngle,
      expandTooltip: theme.expandTooltip,
      collapseTooltip: theme.collapseTooltip,
    );
  }

  /// Creates a copy of this decoration with the given fields replaced.
  MorphExpandableStyle copyWith({
    double? outerRadius,
    double? innerRadius,
    double? hoverRadius,
    double? pressedRadius,
    double? gap,
    double? expandedRadius,
    Color? color,
    BorderSide? border,
    double? elevation,
    EdgeInsetsGeometry? headerPadding,
    EdgeInsetsGeometry? bodyPadding,
    double? titleSubtitleGap,
    EdgeInsetsGeometry? margin,
    EdgeInsetsGeometry? iconPadding,
    double? expandedIconBackgroundSize,
    double? expandedIconBackgroundHeight,
    Color? expandedIconBackground,
    bool? expandedStateFill,
    Color? expandedStateColor,
    bool? roundSublistBottom,
    double? iconRotationAngle,
    Widget? expandIcon,
    Widget? collapseIcon,
    MorphExpandableIconPlacement? iconPlacement,
    bool? useInkWell,
    bool? tapHeaderToToggle,
    bool? tapBodyToExpand,
    bool? tapBodyToCollapse,
    CrossAxisAlignment? headerAlignment,
    AlignmentGeometry? bodyAlignment,
    MorphHapticFeedback? haptic,
    Color? splashColor,
    Color? highlightColor,
    InteractiveInkFeatureFactory? splashFactory,
    bool? enableFeedback,
    bool? tapIconToToggle,
    String? expandTooltip,
    String? collapseTooltip,
  }) {
    return MorphExpandableStyle(
      outerRadius: outerRadius ?? this.outerRadius,
      innerRadius: innerRadius ?? this.innerRadius,
      hoverRadius: hoverRadius ?? this.hoverRadius,
      pressedRadius: pressedRadius ?? this.pressedRadius,
      gap: gap ?? this.gap,
      expandedRadius: expandedRadius ?? this.expandedRadius,
      color: color ?? this.color,
      border: border ?? this.border,
      elevation: elevation ?? this.elevation,
      headerPadding: headerPadding ?? this.headerPadding,
      bodyPadding: bodyPadding ?? this.bodyPadding,
      titleSubtitleGap: titleSubtitleGap ?? this.titleSubtitleGap,
      margin: margin ?? this.margin,
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
      expandIcon: expandIcon ?? this.expandIcon,
      collapseIcon: collapseIcon ?? this.collapseIcon,
      iconPlacement: iconPlacement ?? this.iconPlacement,
      useInkWell: useInkWell ?? this.useInkWell,
      tapHeaderToToggle: tapHeaderToToggle ?? this.tapHeaderToToggle,
      tapBodyToExpand: tapBodyToExpand ?? this.tapBodyToExpand,
      tapBodyToCollapse: tapBodyToCollapse ?? this.tapBodyToCollapse,
      headerAlignment: headerAlignment ?? this.headerAlignment,
      bodyAlignment: bodyAlignment ?? this.bodyAlignment,
      haptic: haptic ?? this.haptic,
      splashColor: splashColor ?? this.splashColor,
      highlightColor: highlightColor ?? this.highlightColor,
      splashFactory: splashFactory ?? this.splashFactory,
      enableFeedback: enableFeedback ?? this.enableFeedback,
      tapIconToToggle: tapIconToToggle ?? this.tapIconToToggle,
      expandTooltip: expandTooltip ?? this.expandTooltip,
      collapseTooltip: collapseTooltip ?? this.collapseTooltip,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MorphExpandableStyle &&
          outerRadius == other.outerRadius &&
          innerRadius == other.innerRadius &&
          hoverRadius == other.hoverRadius &&
          pressedRadius == other.pressedRadius &&
          gap == other.gap &&
          expandedRadius == other.expandedRadius &&
          color == other.color &&
          border == other.border &&
          elevation == other.elevation &&
          headerPadding == other.headerPadding &&
          bodyPadding == other.bodyPadding &&
          titleSubtitleGap == other.titleSubtitleGap &&
          margin == other.margin &&
          iconPadding == other.iconPadding &&
          expandedIconBackgroundSize == other.expandedIconBackgroundSize &&
          expandedIconBackgroundHeight == other.expandedIconBackgroundHeight &&
          expandedIconBackground == other.expandedIconBackground &&
          expandedStateFill == other.expandedStateFill &&
          expandedStateColor == other.expandedStateColor &&
          roundSublistBottom == other.roundSublistBottom &&
          iconRotationAngle == other.iconRotationAngle &&
          expandIcon == other.expandIcon &&
          collapseIcon == other.collapseIcon &&
          iconPlacement == other.iconPlacement &&
          useInkWell == other.useInkWell &&
          tapHeaderToToggle == other.tapHeaderToToggle &&
          tapBodyToExpand == other.tapBodyToExpand &&
          tapBodyToCollapse == other.tapBodyToCollapse &&
          headerAlignment == other.headerAlignment &&
          bodyAlignment == other.bodyAlignment &&
          haptic == other.haptic &&
          splashColor == other.splashColor &&
          highlightColor == other.highlightColor &&
          splashFactory == other.splashFactory &&
          enableFeedback == other.enableFeedback &&
          tapIconToToggle == other.tapIconToToggle &&
          expandTooltip == other.expandTooltip &&
          collapseTooltip == other.collapseTooltip;

  @override
  int get hashCode => Object.hashAll([
    outerRadius,
    innerRadius,
    hoverRadius,
    pressedRadius,
    gap,
    expandedRadius,
    color,
    border,
    elevation,
    headerPadding,
    bodyPadding,
    titleSubtitleGap,
    margin,
    iconPadding,
    expandedIconBackgroundSize,
    expandedIconBackgroundHeight,
    expandedIconBackground,
    expandedStateFill,
    expandedStateColor,
    roundSublistBottom,
    iconRotationAngle,
    expandIcon,
    collapseIcon,
    iconPlacement,
    useInkWell,
    tapHeaderToToggle,
    tapBodyToExpand,
    tapBodyToCollapse,
    headerAlignment,
    bodyAlignment,
    haptic,
    splashColor,
    highlightColor,
    splashFactory,
    enableFeedback,
    tapIconToToggle,
    expandTooltip,
    collapseTooltip,
  ]);
}
