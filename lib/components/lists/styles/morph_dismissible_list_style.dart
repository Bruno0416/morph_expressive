import 'package:material_ui/material_ui.dart'
    show
        BorderSide,
        Color,
        EdgeInsetsGeometry,
        InteractiveInkFeatureFactory,
        Widget;

import '../../../foundations/foundations.dart';
import 'morph_list_theme.dart';

/// Immutable visual and interaction configuration for dismissible Morph lists.
class MorphDismissibleListStyle {
  /// Outer corner radius for first / last / single items.
  final double outerRadius;

  /// Border radius applied to the dragged card once it crosses the dismiss
  /// threshold. Defaults to [outerRadius].
  final double? selectedBorderRadius;

  /// Inner corner radius for middle items.
  final double innerRadius;

  /// Vertical gap between cards.
  final double gap;

  /// Horizontal gap between a swiped card and its revealed action.
  final double actionGap;

  /// Spacing between revealed swipe action buttons.
  final double actionSpacing;

  /// Horizontal padding at the leading / trailing edges of the action row.
  final double actionEdgePadding;

  /// Fraction of actions width required to snap the preview open on release.
  final double actionPreviewThreshold;

  /// Extra pixels past the actions width before rubber-band overdrag.
  final double actionOverdragExtent;

  /// Vertical inset subtracted from the list row height for action pills.
  final double actionVerticalInset;

  /// Minimum height for action / dismiss pills.
  final double actionMinHeight;

  /// Minimum visual width for action pills while revealing / hiding.
  final double actionMinWidth;

  /// When true, full dismiss invokes the primary swipe action for that side.
  final bool autoExecutePrimaryOnFullSwipe;

  /// Card background colour.
  final Color? color;

  /// Inner padding of each card's content area.
  final EdgeInsetsGeometry? padding;

  /// Outer margin around each card.
  final EdgeInsetsGeometry? margin;

  /// Optional border drawn on every card.
  final BorderSide? border;

  /// Resting elevation.
  final double elevation;

  /// Background revealed when swiping start‑to‑end (left→right in LTR).
  final Widget? background;

  /// Background revealed when swiping end‑to‑start (right→left in LTR).
  final Widget? secondaryBackground;

  /// Background Border Radius
  final double backgroundBorderRadius;

  /// Secondary Background Border Radius
  final double? secondaryBackgroundBorderRadius;

  /// Collapse speed. Higher = faster.
  final double collapseSpeed;

  /// splashColor.

  final Color? splashColor;

  /// highlightColor.
  final Color? highlightColor;

  /// splashFactory.
  final InteractiveInkFeatureFactory? splashFactory;

  /// Whether detected gestures provide feedback.
  final bool enableFeedback;

  /// Haptic intensity on tap.
  final MorphHapticFeedback hapticOnTap;

  /// Fraction of card width the user must drag before a dismiss triggers.
  final double dismissThreshold;

  /// Haptic intensity when the drag crosses / re‑crosses.
  final MorphHapticFeedback hapticOnThreshold;

  /// Plays sparse, motion-synced selection ticks during swipe and spring settle.
  /// Respects [enableFeedback] and the nearest MorphTheme haptic settings.
  final bool dismissHapticStream;

  /// Maximum pixel offset applied to neighbouring cards.
  final double neighbourPull;

  /// How many cards are affected.
  final int neighbourReach;

  /// Neighbour fraction spring (base; stiffness scaled by multiplier).
  final MorphSpring neighbourSpring;

  /// Roundness re-engage spring (base; stiffness scaled by multiplier).
  final MorphSpring reEngageSpring;

  /// Detach push spring (base; stiffness scaled by multiplier).
  final MorphSpring detachPushSpring;

  /// Roundness snap spring (base; stiffness scaled by multiplier).
  final MorphSpring roundnessSnapSpring;

  /// Drag spring-back spring (base; stiffness scaled by speedMul).
  final MorphSpring springBackSpring;

  /// Fly-away spring (base; stiffness scaled by speedMul).
  final MorphSpring flySpring;

  /// Damping for collapse; stiffness still uses [collapseSpeed] × speedMul.
  final double collapseDamping;

  /// MorphDismissibleListStyle.

  const MorphDismissibleListStyle({
    this.outerRadius = MorphListDismissibleTheme.defaultOuterRadius,
    this.selectedBorderRadius,
    this.innerRadius = MorphListDismissibleTheme.defaultInnerRadius,
    this.gap = MorphListDismissibleTheme.defaultGap,
    this.actionGap = MorphListDismissibleTheme.defaultActionGap,
    this.actionSpacing = MorphListDismissibleTheme.defaultActionSpacing,
    this.actionEdgePadding = MorphListDismissibleTheme.defaultActionEdgePadding,
    this.actionPreviewThreshold =
        MorphListDismissibleTheme.defaultActionPreviewThreshold,
    this.actionOverdragExtent =
        MorphListDismissibleTheme.defaultActionOverdragExtent,
    this.actionVerticalInset =
        MorphListDismissibleTheme.defaultActionVerticalInset,
    this.actionMinHeight = MorphListDismissibleTheme.defaultActionMinHeight,
    this.actionMinWidth = MorphListDismissibleTheme.defaultActionMinWidth,
    this.autoExecutePrimaryOnFullSwipe = true,
    this.color,
    this.padding = MorphListDismissibleTheme.defaultItemPadding,
    this.margin,
    this.border,
    this.elevation = 0.0,
    this.background,
    this.secondaryBackground,
    this.backgroundBorderRadius =
        MorphListDismissibleTheme.defaultBackgroundBorderRadius,
    this.secondaryBackgroundBorderRadius =
        MorphListDismissibleTheme.defaultBackgroundBorderRadius,
    this.collapseSpeed = MorphListDismissibleTheme.defaultCollapseSpeed,
    this.splashColor,
    this.highlightColor,
    this.splashFactory,
    this.enableFeedback = true,
    this.hapticOnTap = MorphHapticFeedback.inherit,
    this.dismissThreshold = MorphListDismissibleTheme.defaultDismissThreshold,
    this.hapticOnThreshold = MorphHapticFeedback.inherit,
    this.dismissHapticStream = true,
    this.neighbourPull = MorphListDismissibleTheme.defaultNeighbourPull,
    this.neighbourReach = MorphListDismissibleTheme.defaultNeighbourReach,
    this.neighbourSpring = const MorphSpring(stiffness: 800, damping: 0.7),
    this.reEngageSpring = const MorphSpring(stiffness: 800, damping: 0.9),
    this.detachPushSpring = const MorphSpring(stiffness: 800, damping: 0.95),
    this.roundnessSnapSpring = const MorphSpring(stiffness: 1000, damping: 0.4),
    this.springBackSpring = const MorphSpring(stiffness: 380, damping: 0.6),
    this.flySpring = const MorphSpring(stiffness: 400, damping: 0.8),
    this.collapseDamping = 0.8,
  });

  /// Builds a style from [MorphListDismissibleTheme] token values.
  factory MorphDismissibleListStyle.fromTheme(MorphListDismissibleTheme theme) {
    return MorphDismissibleListStyle(
      outerRadius: theme.outerRadius,
      innerRadius: theme.innerRadius,
      gap: theme.gap,
      actionGap: theme.actionGap,
      actionSpacing: theme.actionSpacing,
      actionEdgePadding: theme.actionEdgePadding,
      actionPreviewThreshold: theme.actionPreviewThreshold,
      actionOverdragExtent: theme.actionOverdragExtent,
      actionVerticalInset: theme.actionVerticalInset,
      actionMinHeight: theme.actionMinHeight,
      actionMinWidth: theme.actionMinWidth,
      padding: theme.itemPadding,
      backgroundBorderRadius: theme.backgroundBorderRadius,
      secondaryBackgroundBorderRadius: theme.backgroundBorderRadius,
      collapseSpeed: theme.collapseSpeed,
      dismissThreshold: theme.dismissThreshold,
      neighbourPull: theme.neighbourPull,
      neighbourReach: theme.neighbourReach,
      neighbourSpring: theme.neighbourSpring,
      reEngageSpring: theme.reEngageSpring,
      detachPushSpring: theme.detachPushSpring,
      roundnessSnapSpring: theme.roundnessSnapSpring,
      springBackSpring: theme.springBackSpring,
      flySpring: theme.flySpring,
      collapseDamping: theme.collapseDamping,
    );
  }

  /// copyWith.
  MorphDismissibleListStyle copyWith({
    double? outerRadius,
    double? selectedBorderRadius,
    double? innerRadius,
    double? gap,
    double? actionGap,
    double? actionSpacing,
    double? actionEdgePadding,
    double? actionPreviewThreshold,
    double? actionOverdragExtent,
    double? actionVerticalInset,
    double? actionMinHeight,
    double? actionMinWidth,
    bool? autoExecutePrimaryOnFullSwipe,
    Color? color,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    BorderSide? border,
    double? elevation,
    Widget? background,
    Widget? secondaryBackground,
    double? backgroundBorderRadius,
    double? secondaryBackgroundBorderRadius,
    double? collapseSpeed,
    Color? splashColor,
    Color? highlightColor,
    InteractiveInkFeatureFactory? splashFactory,
    bool? enableFeedback,
    MorphHapticFeedback? hapticOnTap,
    double? dismissThreshold,
    MorphHapticFeedback? hapticOnThreshold,
    bool? dismissHapticStream,
    double? neighbourPull,
    int? neighbourReach,
    MorphSpring? neighbourSpring,
    MorphSpring? reEngageSpring,
    MorphSpring? detachPushSpring,
    MorphSpring? roundnessSnapSpring,
    MorphSpring? springBackSpring,
    MorphSpring? flySpring,
    double? collapseDamping,
  }) {
    return MorphDismissibleListStyle(
      outerRadius: outerRadius ?? this.outerRadius,
      selectedBorderRadius: selectedBorderRadius ?? this.selectedBorderRadius,
      innerRadius: innerRadius ?? this.innerRadius,
      gap: gap ?? this.gap,
      actionGap: actionGap ?? this.actionGap,
      actionSpacing: actionSpacing ?? this.actionSpacing,
      actionEdgePadding: actionEdgePadding ?? this.actionEdgePadding,
      actionPreviewThreshold:
          actionPreviewThreshold ?? this.actionPreviewThreshold,
      actionOverdragExtent: actionOverdragExtent ?? this.actionOverdragExtent,
      actionVerticalInset: actionVerticalInset ?? this.actionVerticalInset,
      actionMinHeight: actionMinHeight ?? this.actionMinHeight,
      actionMinWidth: actionMinWidth ?? this.actionMinWidth,
      autoExecutePrimaryOnFullSwipe:
          autoExecutePrimaryOnFullSwipe ?? this.autoExecutePrimaryOnFullSwipe,
      color: color ?? this.color,
      padding: padding ?? this.padding,
      margin: margin ?? this.margin,
      border: border ?? this.border,
      elevation: elevation ?? this.elevation,
      background: background ?? this.background,
      secondaryBackground: secondaryBackground ?? this.secondaryBackground,
      backgroundBorderRadius:
          backgroundBorderRadius ?? this.backgroundBorderRadius,
      secondaryBackgroundBorderRadius:
          secondaryBackgroundBorderRadius ??
          this.secondaryBackgroundBorderRadius,
      collapseSpeed: collapseSpeed ?? this.collapseSpeed,
      splashColor: splashColor ?? this.splashColor,
      highlightColor: highlightColor ?? this.highlightColor,
      splashFactory: splashFactory ?? this.splashFactory,
      enableFeedback: enableFeedback ?? this.enableFeedback,
      hapticOnTap: hapticOnTap ?? this.hapticOnTap,
      dismissThreshold: dismissThreshold ?? this.dismissThreshold,
      hapticOnThreshold: hapticOnThreshold ?? this.hapticOnThreshold,
      dismissHapticStream: dismissHapticStream ?? this.dismissHapticStream,
      neighbourPull: neighbourPull ?? this.neighbourPull,
      neighbourReach: neighbourReach ?? this.neighbourReach,
      neighbourSpring: neighbourSpring ?? this.neighbourSpring,
      reEngageSpring: reEngageSpring ?? this.reEngageSpring,
      detachPushSpring: detachPushSpring ?? this.detachPushSpring,
      roundnessSnapSpring: roundnessSnapSpring ?? this.roundnessSnapSpring,
      springBackSpring: springBackSpring ?? this.springBackSpring,
      flySpring: flySpring ?? this.flySpring,
      collapseDamping: collapseDamping ?? this.collapseDamping,
    );
  }
}
