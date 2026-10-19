import 'package:flutter/widgets.dart';

import '../../../foundations/foundations.dart';
import '../enums/morph_tabs_variant.dart';

/// Theme values for `MorphTabs`.
@immutable
class MorphTabTheme extends MorphThemeExtension<MorphTabTheme> {
  /// Creates tab theme tokens. Defaults match the tabs spec.
  const MorphTabTheme({
    this.height = 48,
    this.iconAndLabelHeight = 64,
    this.iconSize = 24,
    this.indicatorHeight = 3,
    this.secondaryIndicatorHeight = 2,
    this.primaryIndicatorWidth = 32,
    this.indicatorMinLength = 24,
    this.indicatorInset = 2,
    this.indicatorCornerRadius = 3,
    this.dividerHeight = 1,
    this.elevation = 0,
    this.stackedIconLabelGap = 2,
    this.inlineIconLabelGap = 8,
    this.inlineBadgeGap = 4,
    this.badgeOverlap = 6,
    this.scrollableLeadingOffset = 52,
    this.scrollableTabPadding = 16,
    this.labelMaxLines = 2,
    this.focusThickness = 3,
    this.focusInset = 3,
    this.interactionCornerRadius = 16,
    this.hoverOpacity = 0.08,
    this.focusOpacity = 0.1,
    this.pressedOpacity = 0.1,
    this.indicatorSpring = MorphMotion.spatialDefault,
  });

  /// Package defaults.
  static const MorphTabTheme defaults = MorphTabTheme();

  /// Label-only and secondary bar height.
  final double height;

  /// Primary bar height when a tab has both an icon and a label.
  final double iconAndLabelHeight;

  /// Icon size.
  final double iconSize;

  /// Primary active-indicator height.
  final double indicatorHeight;

  /// Secondary active-indicator height.
  final double secondaryIndicatorHeight;

  /// Kept so existing theme copies still construct.
  ///
  /// Primary indicator length follows the label, clamped by [indicatorMinLength].
  final double primaryIndicatorWidth;

  /// Shortest primary indicator.
  final double indicatorMinLength;

  /// Primary indicator inset from the content on each side.
  final double indicatorInset;

  /// Primary indicator top corner radius. Secondary indicators stay square.
  final double indicatorCornerRadius;

  /// Divider thickness, drawn inside the bar height.
  final double dividerHeight;

  /// Container elevation. Spec rest is level 0.
  final double elevation;

  /// Gap between a stacked primary icon and its label.
  final double stackedIconLabelGap;

  /// Gap between an inline icon and the label.
  final double inlineIconLabelGap;

  /// Gap between a label and an inline badge.
  final double inlineBadgeGap;

  /// Kept so existing theme copies still construct.
  ///
  /// A stacked badge uses the badge theme corner placement, so the mark stays
  /// on the icon and the icon and label stay centered.
  final double badgeOverlap;

  /// Leading offset of the first scrollable tab.
  final double scrollableLeadingOffset;

  /// Horizontal padding inside every scrollable tab.
  final double scrollableTabPadding;

  /// Label line limit. The second line ellipsizes.
  final int labelMaxLines;

  /// Keyboard focus ring thickness.
  final double focusThickness;

  /// Keyboard focus ring inset from the tab edge.
  final double focusInset;

  /// Corner radius of hover, press, and focus surfaces.
  final double interactionCornerRadius;

  /// Hover state-layer opacity.
  final double hoverOpacity;

  /// Focus state-layer opacity.
  final double focusOpacity;

  /// Pressed state-layer opacity.
  final double pressedOpacity;

  /// Spring that moves the active indicator.
  final MorphSpring indicatorSpring;

  /// Bar height for [variant]. [stacked] is primary icon plus label.
  double barHeight(MorphTabsVariant variant, {required bool stacked}) {
    if (variant == MorphTabsVariant.primary && stacked) {
      return iconAndLabelHeight;
    }
    return height;
  }

  /// Active indicator thickness for [variant].
  double indicatorExtent(MorphTabsVariant variant) {
    if (variant == MorphTabsVariant.secondary) {
      return secondaryIndicatorHeight;
    }
    return indicatorHeight;
  }

  /// Container color. Spec: surface.
  Color backgroundColor(MorphColorScheme scheme) => scheme.surface;

  /// Divider color. Spec: outline variant.
  Color dividerColor(MorphColorScheme scheme) => scheme.outlineVariant;

  /// Shadow color used when [elevation] is raised.
  Color shadowColor(MorphColorScheme scheme) => scheme.shadow;

  /// Active indicator color. Spec: primary.
  Color indicatorColor(MorphColorScheme scheme) => scheme.primary;

  /// Focus ring color. Spec: secondary.
  Color focusColor(MorphColorScheme scheme) => scheme.secondary;

  /// Whether the indicator spans the whole tab slot.
  bool indicatorFullWidth(MorphTabsVariant variant) =>
      variant == MorphTabsVariant.secondary;

  /// Label and icon color for the variant, selection, and interaction.
  Color contentColor(
    MorphColorScheme scheme, {
    required MorphTabsVariant variant,
    required bool selected,
    required bool interacting,
  }) {
    if (variant == MorphTabsVariant.secondary) {
      if (selected || interacting) {
        return scheme.onSurface;
      }
      return scheme.onSurfaceVariant;
    }
    if (selected) {
      return scheme.primary;
    }
    if (interacting) {
      return scheme.onSurface;
    }
    return scheme.onSurfaceVariant;
  }

  /// State-layer color. Inactive primary press uses on-surface.
  Color stateLayerColor(
    MorphColorScheme scheme, {
    required MorphTabsVariant variant,
    required bool selected,
  }) {
    if (variant == MorphTabsVariant.secondary || !selected) {
      return scheme.onSurface;
    }
    return scheme.primary;
  }

  /// Opacity for the highest interaction, or 0 when idle.
  double stateOpacity({
    required bool hovered,
    required bool focused,
    required bool pressed,
  }) {
    if (pressed) {
      return pressedOpacity;
    }
    if (focused) {
      return focusOpacity;
    }
    if (hovered) {
      return hoverOpacity;
    }
    return 0;
  }

  /// Label style. Spec: title small, 14 / 20 / 500 / 0.1.
  TextStyle labelStyle(
    MorphTypeScale type,
    MorphColorScheme scheme, {
    required bool selected,
    MorphTabsVariant variant = MorphTabsVariant.primary,
    bool interacting = false,
  }) {
    return type.titleSmall.copyWith(
      color: contentColor(
        scheme,
        variant: variant,
        selected: selected,
        interacting: interacting,
      ),
    );
  }

  @override
  MorphTabTheme copyWith({
    double? height,
    double? iconAndLabelHeight,
    double? iconSize,
    double? indicatorHeight,
    double? secondaryIndicatorHeight,
    double? primaryIndicatorWidth,
    double? indicatorMinLength,
    double? indicatorInset,
    double? indicatorCornerRadius,
    double? dividerHeight,
    double? elevation,
    double? stackedIconLabelGap,
    double? inlineIconLabelGap,
    double? inlineBadgeGap,
    double? badgeOverlap,
    double? scrollableLeadingOffset,
    double? scrollableTabPadding,
    int? labelMaxLines,
    double? focusThickness,
    double? focusInset,
    double? interactionCornerRadius,
    double? hoverOpacity,
    double? focusOpacity,
    double? pressedOpacity,
    MorphSpring? indicatorSpring,
  }) {
    return MorphTabTheme(
      height: height ?? this.height,
      iconAndLabelHeight: iconAndLabelHeight ?? this.iconAndLabelHeight,
      iconSize: iconSize ?? this.iconSize,
      indicatorHeight: indicatorHeight ?? this.indicatorHeight,
      secondaryIndicatorHeight:
          secondaryIndicatorHeight ?? this.secondaryIndicatorHeight,
      primaryIndicatorWidth:
          primaryIndicatorWidth ?? this.primaryIndicatorWidth,
      indicatorMinLength: indicatorMinLength ?? this.indicatorMinLength,
      indicatorInset: indicatorInset ?? this.indicatorInset,
      indicatorCornerRadius:
          indicatorCornerRadius ?? this.indicatorCornerRadius,
      dividerHeight: dividerHeight ?? this.dividerHeight,
      elevation: elevation ?? this.elevation,
      stackedIconLabelGap: stackedIconLabelGap ?? this.stackedIconLabelGap,
      inlineIconLabelGap: inlineIconLabelGap ?? this.inlineIconLabelGap,
      inlineBadgeGap: inlineBadgeGap ?? this.inlineBadgeGap,
      badgeOverlap: badgeOverlap ?? this.badgeOverlap,
      scrollableLeadingOffset:
          scrollableLeadingOffset ?? this.scrollableLeadingOffset,
      scrollableTabPadding: scrollableTabPadding ?? this.scrollableTabPadding,
      labelMaxLines: labelMaxLines ?? this.labelMaxLines,
      focusThickness: focusThickness ?? this.focusThickness,
      focusInset: focusInset ?? this.focusInset,
      interactionCornerRadius:
          interactionCornerRadius ?? this.interactionCornerRadius,
      hoverOpacity: hoverOpacity ?? this.hoverOpacity,
      focusOpacity: focusOpacity ?? this.focusOpacity,
      pressedOpacity: pressedOpacity ?? this.pressedOpacity,
      indicatorSpring: indicatorSpring ?? this.indicatorSpring,
    );
  }

  @override
  MorphTabTheme lerp(MorphTabTheme? other, double t) {
    if (other is! MorphTabTheme) {
      return this;
    }
    final _MorphTabGeometryLerp geometry = _lerpGeometry(other, t);
    final _MorphTabSpacingLerp spacing = _lerpSpacing(other, t);
    final _MorphTabInteractionLerp interaction = _lerpInteraction(other, t);
    return MorphTabTheme(
      height: geometry.height,
      iconAndLabelHeight: geometry.iconAndLabelHeight,
      iconSize: geometry.iconSize,
      indicatorHeight: geometry.indicatorHeight,
      secondaryIndicatorHeight: geometry.secondaryIndicatorHeight,
      primaryIndicatorWidth: geometry.primaryIndicatorWidth,
      indicatorMinLength: geometry.indicatorMinLength,
      indicatorInset: geometry.indicatorInset,
      indicatorCornerRadius: geometry.indicatorCornerRadius,
      dividerHeight: geometry.dividerHeight,
      elevation: geometry.elevation,
      stackedIconLabelGap: spacing.stackedIconLabelGap,
      inlineIconLabelGap: spacing.inlineIconLabelGap,
      inlineBadgeGap: spacing.inlineBadgeGap,
      badgeOverlap: spacing.badgeOverlap,
      scrollableLeadingOffset: spacing.scrollableLeadingOffset,
      scrollableTabPadding: spacing.scrollableTabPadding,
      labelMaxLines: spacing.labelMaxLines,
      focusThickness: interaction.focusThickness,
      focusInset: interaction.focusInset,
      interactionCornerRadius: _lerpDouble(
        interactionCornerRadius,
        other.interactionCornerRadius,
        t,
      ),
      hoverOpacity: interaction.hoverOpacity,
      focusOpacity: interaction.focusOpacity,
      pressedOpacity: interaction.pressedOpacity,
      indicatorSpring: interaction.indicatorSpring,
    );
  }

  /// Bar / indicator geometry fields lerped for [lerp].
  _MorphTabGeometryLerp _lerpGeometry(MorphTabTheme other, double t) {
    return (
      height: _lerpDouble(height, other.height, t),
      iconAndLabelHeight: _lerpDouble(
        iconAndLabelHeight,
        other.iconAndLabelHeight,
        t,
      ),
      iconSize: _lerpDouble(iconSize, other.iconSize, t),
      indicatorHeight: _lerpDouble(indicatorHeight, other.indicatorHeight, t),
      secondaryIndicatorHeight: _lerpDouble(
        secondaryIndicatorHeight,
        other.secondaryIndicatorHeight,
        t,
      ),
      primaryIndicatorWidth: _lerpDouble(
        primaryIndicatorWidth,
        other.primaryIndicatorWidth,
        t,
      ),
      indicatorMinLength: _lerpDouble(
        indicatorMinLength,
        other.indicatorMinLength,
        t,
      ),
      indicatorInset: _lerpDouble(indicatorInset, other.indicatorInset, t),
      indicatorCornerRadius: _lerpDouble(
        indicatorCornerRadius,
        other.indicatorCornerRadius,
        t,
      ),
      dividerHeight: _lerpDouble(dividerHeight, other.dividerHeight, t),
      elevation: _lerpDouble(elevation, other.elevation, t),
    );
  }

  /// Spacing / label fields lerped for [lerp].
  _MorphTabSpacingLerp _lerpSpacing(MorphTabTheme other, double t) {
    return (
      stackedIconLabelGap: _lerpDouble(
        stackedIconLabelGap,
        other.stackedIconLabelGap,
        t,
      ),
      inlineIconLabelGap: _lerpDouble(
        inlineIconLabelGap,
        other.inlineIconLabelGap,
        t,
      ),
      inlineBadgeGap: _lerpDouble(inlineBadgeGap, other.inlineBadgeGap, t),
      badgeOverlap: _lerpDouble(badgeOverlap, other.badgeOverlap, t),
      scrollableLeadingOffset: _lerpDouble(
        scrollableLeadingOffset,
        other.scrollableLeadingOffset,
        t,
      ),
      scrollableTabPadding: _lerpDouble(
        scrollableTabPadding,
        other.scrollableTabPadding,
        t,
      ),
      labelMaxLines: t < 0.5 ? labelMaxLines : other.labelMaxLines,
    );
  }

  /// Focus / state-opacity / motion fields lerped for [lerp].
  _MorphTabInteractionLerp _lerpInteraction(MorphTabTheme other, double t) {
    return (
      focusThickness: _lerpDouble(focusThickness, other.focusThickness, t),
      focusInset: _lerpDouble(focusInset, other.focusInset, t),
      hoverOpacity: _lerpDouble(hoverOpacity, other.hoverOpacity, t),
      focusOpacity: _lerpDouble(focusOpacity, other.focusOpacity, t),
      pressedOpacity: _lerpDouble(pressedOpacity, other.pressedOpacity, t),
      indicatorSpring: MorphSpring(
        stiffness: _lerpDouble(
          indicatorSpring.stiffness,
          other.indicatorSpring.stiffness,
          t,
        ),
        damping: _lerpDouble(
          indicatorSpring.damping,
          other.indicatorSpring.damping,
          t,
        ),
      ),
    );
  }

  static double _lerpDouble(double a, double b, double t) => a + (b - a) * t;
}

/// Geometry fields grouped for [MorphTabTheme._lerpGeometry].
typedef _MorphTabGeometryLerp = ({
  double height,
  double iconAndLabelHeight,
  double iconSize,
  double indicatorHeight,
  double secondaryIndicatorHeight,
  double primaryIndicatorWidth,
  double indicatorMinLength,
  double indicatorInset,
  double indicatorCornerRadius,
  double dividerHeight,
  double elevation,
});

/// Spacing / label fields grouped for [MorphTabTheme._lerpSpacing].
typedef _MorphTabSpacingLerp = ({
  double stackedIconLabelGap,
  double inlineIconLabelGap,
  double inlineBadgeGap,
  double badgeOverlap,
  double scrollableLeadingOffset,
  double scrollableTabPadding,
  int labelMaxLines,
});

/// Focus / state-opacity / motion fields grouped for
/// [MorphTabTheme._lerpInteraction].
typedef _MorphTabInteractionLerp = ({
  double focusThickness,
  double focusInset,
  double hoverOpacity,
  double focusOpacity,
  double pressedOpacity,
  MorphSpring indicatorSpring,
});
