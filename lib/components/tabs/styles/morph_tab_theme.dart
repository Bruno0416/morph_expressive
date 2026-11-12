import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../../../foundations/foundations.dart';
import '../enums/morph_tabs_indicator_options.dart';
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
    this.indicatorStyle = MorphTabsIndicatorStyle.underline,
    this.indicatorMotion = MorphTabsIndicatorMotion.slide,
    this.indicatorFit,
    this.indicatorElasticity = 0.3,
    this.indicatorDuration = MorphMotion.medium2,
    this.indicatorCurve = MorphMotion.enter,
    this.indicatorRoundedEnds = true,
    this.indicatorBottomCornerRadius = 0,
    this.secondaryIndicatorCornerRadius = 0,
    this.indicatorTabInset,
    this.indicatorPadding,
    this.indicatorSurfaceInset,
    this.indicatorVerticalPadding,
    this.indicatorGroupRadius,
    this.indicatorSurfaceRadius,
    this.indicatorColorOverride,
    this.indicatorGroupBackground = false,
    this.indicatorGroupColor,
    this.indicatorRenderer = MorphShapeRenderer.auto,
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

  /// Kept so existing theme copies still construct. The indicator now moves
  /// with [indicatorDuration] and [indicatorCurve] so it can follow a page
  /// progress deterministically, without overshoot.
  final MorphSpring indicatorSpring;

  /// Indicator presentation. Default [MorphTabsIndicatorStyle.underline].
  final MorphTabsIndicatorStyle indicatorStyle;

  /// Indicator motion profile. Default [MorphTabsIndicatorMotion.slide].
  final MorphTabsIndicatorMotion indicatorMotion;

  /// Indicator width basis. Null keeps the previous behaviour: content for
  /// primary tabs, the full tab for secondary tabs.
  final MorphTabsIndicatorFit? indicatorFit;

  /// Share of the eased distance by which the leading edge runs ahead of the
  /// trailing edge for [MorphTabsIndicatorMotion.elastic] (`0..1`).
  final double indicatorElasticity;

  /// Duration of a tap or programmatic change. Zero with reduced motion.
  final Duration indicatorDuration;

  /// Curve of a tap or programmatic change.
  final Curve indicatorCurve;

  /// Underline with fully rounded ends (radius = half the thickness). Default
  /// true. Set false for the previous flat-bottom, top-rounded underline.
  final bool indicatorRoundedEnds;

  /// Bottom corner radius of the underline. Zero keeps the bottom flush.
  final double indicatorBottomCornerRadius;

  /// Top corner radius of a secondary underline. Zero (square) by default.
  final double secondaryIndicatorCornerRadius;

  /// Underline inset from the tab edges for [MorphTabsIndicatorFit.tab]. Null: 0.
  /// A surface uses [indicatorSurfaceInset] instead.
  final double? indicatorTabInset;

  /// Horizontal padding of the surface around the content. Independent of the
  /// vertical padding and larger by default. Null: 16.
  final double? indicatorPadding;

  /// Uniform space between the surface and the container around the tabs (the
  /// group background, or the bar itself): the same on all four sides. Null: 4.
  final double? indicatorSurfaceInset;

  /// Vertical padding of the content inside the surface. It only reserves
  /// height (a surface bar grows until content + padding + insets fit); it never
  /// changes while the selection moves. Null: 8.
  final double? indicatorVerticalPadding;

  /// Corner radius of the group background (the outer container). Null: the
  /// inner radius plus [indicatorSurfaceInset], so the two stay concentric.
  /// When set together with [indicatorSurfaceRadius] both are honoured as given
  /// (after clamping to the geometry); when set alone the inner radius becomes
  /// this value minus the inset.
  final double? indicatorGroupRadius;

  /// Corner radius of the surface. Null: a pill (half the surface height) unless
  /// [indicatorGroupRadius] is set. A smaller value gives a rounded rectangle.
  final double? indicatorSurfaceRadius;

  /// Overrides the indicator colour (underline line or surface fill).
  final Color? indicatorColorOverride;

  /// Whether a surface indicator sits on a group background behind all tabs.
  final bool indicatorGroupBackground;

  /// Group background colour. Null: surface container highest.
  final Color? indicatorGroupColor;

  /// Renderer requested for the indicator. Shader is used when the indicator
  /// has uniform corner radii and the program is loaded; otherwise Canvas.
  final MorphShapeRenderer indicatorRenderer;

  /// Bar height for [variant]. [stacked] is primary icon plus label.
  ///
  /// [labelLineHeight] is the scaled height of one label line (20 at 1x). The
  /// spec heights are kept until a large text scale needs more room, so a
  /// stacked icon and a 2x label never overflow. The height depends only on
  /// the content and the scale, never on the selection.
  ///
  /// [badgeClearance] is the space a stacked badge mark needs above the icon
  /// (0 at 1x); the bar grows by what exceeds the default 4dp margin.
  /// [verticalChrome] is the space reserved around the content (8; for a
  /// surface twice its vertical padding plus twice its inset).
  double barHeight(
    MorphTabsVariant variant, {
    required bool stacked,
    double labelLineHeight = 20,
    double badgeClearance = 0,
    double verticalChrome = 8,
  }) {
    final bool stackedPrimary = variant == MorphTabsVariant.primary && stacked;
    final double base = stackedPrimary ? iconAndLabelHeight : height;
    final double content = stackedPrimary
        ? iconSize + stackedIconLabelGap + labelLineHeight
        : labelLineHeight;
    final double needed =
        content +
        verticalChrome +
        (badgeClearance > 4 ? badgeClearance - 4 : 0);
    return needed > base ? needed : base;
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

  /// Readable content colour on a custom indicator fill.
  Color _onColor(Color fill, MorphColorScheme scheme) {
    return fill.computeLuminance() > 0.5 ? scheme.surface : scheme.onSurface;
  }

  /// Resolves the indicator configuration for one bar.
  ///
  /// Precedence: the explicit widget arguments ([style], [motion], [fit],
  /// [renderer], [duration]), then this theme, then the package defaults.
  MorphTabIndicatorSpec resolveIndicator(
    MorphColorScheme scheme,
    MorphTabsVariant variant, {
    MorphTabsIndicatorStyle? style,
    MorphTabsIndicatorMotion? motion,
    MorphTabsIndicatorFit? fit,
    MorphShapeRenderer? renderer,
    Duration? duration,
  }) {
    final MorphTabsIndicatorStyle resolvedStyle = style ?? indicatorStyle;
    final bool surface = resolvedStyle == MorphTabsIndicatorStyle.surface;
    final double thickness = indicatorExtent(variant);
    final double top = indicatorRoundedEnds
        ? thickness / 2
        : (variant == MorphTabsVariant.primary
              ? indicatorCornerRadius
              : secondaryIndicatorCornerRadius);
    final double bottom = indicatorRoundedEnds
        ? thickness / 2
        : indicatorBottomCornerRadius;
    return MorphTabIndicatorSpec(
      style: resolvedStyle,
      motion: motion ?? indicatorMotion,
      fit:
          fit ??
          indicatorFit ??
          (indicatorFullWidth(variant)
              ? MorphTabsIndicatorFit.tab
              : MorphTabsIndicatorFit.content),
      renderer: renderer ?? indicatorRenderer,
      elasticity: indicatorElasticity.clamp(0.0, 1.0).toDouble(),
      duration: duration ?? indicatorDuration,
      curve: indicatorCurve,
      thickness: thickness,
      topRadius: top,
      bottomRadius: bottom,
      color:
          indicatorColorOverride ??
          (surface ? scheme.secondaryContainer : scheme.primary),
      tabInset: indicatorTabInset ?? 0,
      padding: indicatorPadding ?? 16,
      contentInset: indicatorInset,
      minLength: indicatorMinLength,
      surfaceInset: indicatorSurfaceInset ?? 4,
      verticalPadding: indicatorVerticalPadding ?? 8,
      surfaceRadius: indicatorSurfaceRadius,
      groupRadius: indicatorGroupRadius,
      groupBackground: surface && indicatorGroupBackground,
      groupColor: indicatorGroupColor ?? scheme.surfaceContainerHighest,
    );
  }

  /// Whether the indicator spans the whole tab slot.
  bool indicatorFullWidth(MorphTabsVariant variant) =>
      variant == MorphTabsVariant.secondary;

  /// Label and icon color for the variant, selection, and interaction.
  Color contentColor(
    MorphColorScheme scheme, {
    required MorphTabsVariant variant,
    required bool selected,
    required bool interacting,
    MorphTabsIndicatorStyle style = MorphTabsIndicatorStyle.underline,
  }) {
    if (style == MorphTabsIndicatorStyle.surface) {
      if (selected) {
        return indicatorColorOverride == null
            ? scheme.onSecondaryContainer
            : _onColor(indicatorColorOverride!, scheme);
      }
      return interacting ? scheme.onSurface : scheme.onSurfaceVariant;
    }
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
    MorphTabsIndicatorStyle style = MorphTabsIndicatorStyle.underline,
  }) {
    if (style == MorphTabsIndicatorStyle.surface && selected) {
      return contentColor(
        scheme,
        variant: variant,
        selected: true,
        interacting: false,
        style: style,
      );
    }
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
    MorphTabsIndicatorStyle? indicatorStyle,
    MorphTabsIndicatorMotion? indicatorMotion,
    MorphTabsIndicatorFit? indicatorFit,
    double? indicatorElasticity,
    Duration? indicatorDuration,
    Curve? indicatorCurve,
    bool? indicatorRoundedEnds,
    double? indicatorBottomCornerRadius,
    double? secondaryIndicatorCornerRadius,
    double? indicatorTabInset,
    double? indicatorPadding,
    double? indicatorSurfaceInset,
    double? indicatorVerticalPadding,
    double? indicatorGroupRadius,
    double? indicatorSurfaceRadius,
    Color? indicatorColorOverride,
    bool? indicatorGroupBackground,
    Color? indicatorGroupColor,
    MorphShapeRenderer? indicatorRenderer,
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
      indicatorStyle: indicatorStyle ?? this.indicatorStyle,
      indicatorMotion: indicatorMotion ?? this.indicatorMotion,
      indicatorFit: indicatorFit ?? this.indicatorFit,
      indicatorElasticity: indicatorElasticity ?? this.indicatorElasticity,
      indicatorDuration: indicatorDuration ?? this.indicatorDuration,
      indicatorCurve: indicatorCurve ?? this.indicatorCurve,
      indicatorRoundedEnds: indicatorRoundedEnds ?? this.indicatorRoundedEnds,
      indicatorBottomCornerRadius:
          indicatorBottomCornerRadius ?? this.indicatorBottomCornerRadius,
      secondaryIndicatorCornerRadius:
          secondaryIndicatorCornerRadius ?? this.secondaryIndicatorCornerRadius,
      indicatorTabInset: indicatorTabInset ?? this.indicatorTabInset,
      indicatorPadding: indicatorPadding ?? this.indicatorPadding,
      indicatorSurfaceInset:
          indicatorSurfaceInset ?? this.indicatorSurfaceInset,
      indicatorVerticalPadding:
          indicatorVerticalPadding ?? this.indicatorVerticalPadding,
      indicatorGroupRadius: indicatorGroupRadius ?? this.indicatorGroupRadius,
      indicatorSurfaceRadius:
          indicatorSurfaceRadius ?? this.indicatorSurfaceRadius,
      indicatorColorOverride:
          indicatorColorOverride ?? this.indicatorColorOverride,
      indicatorGroupBackground:
          indicatorGroupBackground ?? this.indicatorGroupBackground,
      indicatorGroupColor: indicatorGroupColor ?? this.indicatorGroupColor,
      indicatorRenderer: indicatorRenderer ?? this.indicatorRenderer,
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
      indicatorStyle: t < 0.5 ? indicatorStyle : other.indicatorStyle,
      indicatorMotion: t < 0.5 ? indicatorMotion : other.indicatorMotion,
      indicatorFit: t < 0.5 ? indicatorFit : other.indicatorFit,
      indicatorElasticity: _lerpDouble(
        indicatorElasticity,
        other.indicatorElasticity,
        t,
      ),
      indicatorDuration: Duration(
        microseconds: _lerpDouble(
          indicatorDuration.inMicroseconds.toDouble(),
          other.indicatorDuration.inMicroseconds.toDouble(),
          t,
        ).round(),
      ),
      indicatorCurve: t < 0.5 ? indicatorCurve : other.indicatorCurve,
      indicatorRoundedEnds: t < 0.5
          ? indicatorRoundedEnds
          : other.indicatorRoundedEnds,
      indicatorBottomCornerRadius: _lerpDouble(
        indicatorBottomCornerRadius,
        other.indicatorBottomCornerRadius,
        t,
      ),
      secondaryIndicatorCornerRadius: _lerpDouble(
        secondaryIndicatorCornerRadius,
        other.secondaryIndicatorCornerRadius,
        t,
      ),
      indicatorTabInset: _lerpNullable(
        indicatorTabInset,
        other.indicatorTabInset,
        t,
      ),
      indicatorPadding: _lerpNullable(
        indicatorPadding,
        other.indicatorPadding,
        t,
      ),
      indicatorSurfaceInset: _lerpNullable(
        indicatorSurfaceInset,
        other.indicatorSurfaceInset,
        t,
      ),
      indicatorVerticalPadding: _lerpNullable(
        indicatorVerticalPadding,
        other.indicatorVerticalPadding,
        t,
      ),
      indicatorGroupRadius: _lerpNullable(
        indicatorGroupRadius,
        other.indicatorGroupRadius,
        t,
      ),
      indicatorSurfaceRadius: _lerpNullable(
        indicatorSurfaceRadius,
        other.indicatorSurfaceRadius,
        t,
      ),
      indicatorColorOverride: _lerpColor(
        indicatorColorOverride,
        other.indicatorColorOverride,
        t,
      ),
      indicatorGroupBackground: t < 0.5
          ? indicatorGroupBackground
          : other.indicatorGroupBackground,
      indicatorGroupColor: _lerpColor(
        indicatorGroupColor,
        other.indicatorGroupColor,
        t,
      ),
      indicatorRenderer: t < 0.5 ? indicatorRenderer : other.indicatorRenderer,
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

  static Color? _lerpColor(Color? a, Color? b, double t) {
    if (a == null || b == null) {
      return t < 0.5 ? a : b;
    }
    return Color.lerp(a, b, t);
  }

  static double? _lerpNullable(double? a, double? b, double t) {
    if (a == null || b == null) {
      // An unset value is a resolved default: switch at the midpoint.
      return t < 0.5 ? a : b;
    }
    return _lerpDouble(a, b, t);
  }

  @override
  bool operator ==(Object other) {
    return other is MorphTabTheme &&
        other.height == height &&
        other.iconAndLabelHeight == iconAndLabelHeight &&
        other.iconSize == iconSize &&
        other.indicatorHeight == indicatorHeight &&
        other.secondaryIndicatorHeight == secondaryIndicatorHeight &&
        other.primaryIndicatorWidth == primaryIndicatorWidth &&
        other.indicatorMinLength == indicatorMinLength &&
        other.indicatorInset == indicatorInset &&
        other.indicatorCornerRadius == indicatorCornerRadius &&
        other.dividerHeight == dividerHeight &&
        other.elevation == elevation &&
        other.stackedIconLabelGap == stackedIconLabelGap &&
        other.inlineIconLabelGap == inlineIconLabelGap &&
        other.inlineBadgeGap == inlineBadgeGap &&
        other.badgeOverlap == badgeOverlap &&
        other.scrollableLeadingOffset == scrollableLeadingOffset &&
        other.scrollableTabPadding == scrollableTabPadding &&
        other.labelMaxLines == labelMaxLines &&
        other.focusThickness == focusThickness &&
        other.focusInset == focusInset &&
        other.interactionCornerRadius == interactionCornerRadius &&
        other.hoverOpacity == hoverOpacity &&
        other.focusOpacity == focusOpacity &&
        other.pressedOpacity == pressedOpacity &&
        other.indicatorSpring == indicatorSpring &&
        other.indicatorStyle == indicatorStyle &&
        other.indicatorMotion == indicatorMotion &&
        other.indicatorFit == indicatorFit &&
        other.indicatorElasticity == indicatorElasticity &&
        other.indicatorDuration == indicatorDuration &&
        other.indicatorCurve == indicatorCurve &&
        other.indicatorRoundedEnds == indicatorRoundedEnds &&
        other.indicatorBottomCornerRadius == indicatorBottomCornerRadius &&
        other.secondaryIndicatorCornerRadius ==
            secondaryIndicatorCornerRadius &&
        other.indicatorTabInset == indicatorTabInset &&
        other.indicatorPadding == indicatorPadding &&
        other.indicatorSurfaceInset == indicatorSurfaceInset &&
        other.indicatorVerticalPadding == indicatorVerticalPadding &&
        other.indicatorGroupRadius == indicatorGroupRadius &&
        other.indicatorSurfaceRadius == indicatorSurfaceRadius &&
        other.indicatorColorOverride == indicatorColorOverride &&
        other.indicatorGroupBackground == indicatorGroupBackground &&
        other.indicatorGroupColor == indicatorGroupColor &&
        other.indicatorRenderer == indicatorRenderer;
  }

  @override
  int get hashCode => Object.hashAll(<Object?>[
    height,
    iconAndLabelHeight,
    iconSize,
    indicatorHeight,
    secondaryIndicatorHeight,
    primaryIndicatorWidth,
    indicatorMinLength,
    indicatorInset,
    indicatorCornerRadius,
    dividerHeight,
    elevation,
    stackedIconLabelGap,
    inlineIconLabelGap,
    inlineBadgeGap,
    badgeOverlap,
    scrollableLeadingOffset,
    scrollableTabPadding,
    labelMaxLines,
    focusThickness,
    focusInset,
    interactionCornerRadius,
    hoverOpacity,
    focusOpacity,
    pressedOpacity,
    indicatorSpring,
    indicatorStyle,
    indicatorMotion,
    indicatorFit,
    indicatorElasticity,
    indicatorDuration,
    indicatorCurve,
    indicatorRoundedEnds,
    indicatorBottomCornerRadius,
    secondaryIndicatorCornerRadius,
    indicatorTabInset,
    indicatorPadding,
    indicatorSurfaceInset,
    indicatorVerticalPadding,
    indicatorGroupRadius,
    indicatorSurfaceRadius,
    indicatorColorOverride,
    indicatorGroupBackground,
    indicatorGroupColor,
    indicatorRenderer,
  ]);
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

/// Indicator configuration resolved from widget arguments, tab theme and
/// defaults by `MorphTabTheme.resolveIndicator`.
@immutable
class MorphTabIndicatorSpec {
  /// Creates a resolved indicator configuration.
  const MorphTabIndicatorSpec({
    required this.style,
    required this.motion,
    required this.fit,
    required this.renderer,
    required this.elasticity,
    required this.duration,
    required this.curve,
    required this.thickness,
    required this.topRadius,
    required this.bottomRadius,
    required this.color,
    required this.tabInset,
    required this.padding,
    required this.contentInset,
    required this.minLength,
    required this.surfaceInset,
    required this.verticalPadding,
    required this.surfaceRadius,
    required this.groupRadius,
    required this.groupBackground,
    required this.groupColor,
  });

  /// Presentation.
  final MorphTabsIndicatorStyle style;

  /// Motion profile.
  final MorphTabsIndicatorMotion motion;

  /// Width basis.
  final MorphTabsIndicatorFit fit;

  /// Requested renderer.
  final MorphShapeRenderer renderer;

  /// Elastic amplitude `0..1`.
  final double elasticity;

  /// Tap / programmatic duration.
  final Duration duration;

  /// Tap / programmatic curve.
  final Curve curve;

  /// Underline thickness.
  final double thickness;

  /// Underline top corner radius.
  final double topRadius;

  /// Underline bottom corner radius.
  final double bottomRadius;

  /// Fill colour.
  final Color color;

  /// Inset from the tab edges for [MorphTabsIndicatorFit.tab].
  final double tabInset;

  /// Surface padding around the content for [MorphTabsIndicatorFit.content].
  final double padding;

  /// Underline inset from the content for [MorphTabsIndicatorFit.content].
  final double contentInset;

  /// Shortest underline.
  final double minLength;

  /// Uniform inset between the surface and its container.
  final double surfaceInset;

  /// Vertical content padding inside the surface.
  final double verticalPadding;

  /// Surface corner radius, null for a pill.
  final double? surfaceRadius;

  /// Group background radius, null for concentric with the surface.
  final double? groupRadius;

  /// Whether a group background is drawn.
  final bool groupBackground;

  /// Group background colour.
  final Color groupColor;

  /// Surface height for a bar of [barHeight]: the same inset above and below.
  double surfaceHeight(double barHeight) =>
      math.max(0, barHeight - surfaceInset * 2);

  /// Inner (surface) radius for a bar of [barHeight], clamped to a capsule.
  ///
  /// Null [surfaceRadius] is a pill; if only [groupRadius] is set the inner
  /// radius is that value minus the inset.
  double innerRadius(double barHeight) {
    final double h = surfaceHeight(barHeight);
    final double r =
        surfaceRadius ??
        (groupRadius != null ? groupRadius! - surfaceInset : h / 2);
    return r.clamp(0.0, h / 2).toDouble();
  }

  /// Outer (container) radius: [groupRadius], else inner + inset, never more
  /// than half the bar height. Pill gives exactly half the bar height.
  double outerRadius(double barHeight) {
    final double r = groupRadius ?? innerRadius(barHeight) + surfaceInset;
    return r.clamp(0.0, barHeight / 2).toDouble();
  }

  /// Whether the indicator is a surface.
  bool get isSurface => style == MorphTabsIndicatorStyle.surface;

  /// Whether all four corners share one radius (the Shader can draw it).
  bool get uniformRadius => isSurface || topRadius == bottomRadius;

  @override
  bool operator ==(Object other) =>
      other is MorphTabIndicatorSpec &&
      other.style == style &&
      other.motion == motion &&
      other.fit == fit &&
      other.renderer == renderer &&
      other.elasticity == elasticity &&
      other.duration == duration &&
      other.curve == curve &&
      other.thickness == thickness &&
      other.topRadius == topRadius &&
      other.bottomRadius == bottomRadius &&
      other.color == color &&
      other.tabInset == tabInset &&
      other.padding == padding &&
      other.contentInset == contentInset &&
      other.minLength == minLength &&
      other.surfaceInset == surfaceInset &&
      other.verticalPadding == verticalPadding &&
      other.surfaceRadius == surfaceRadius &&
      other.groupRadius == groupRadius &&
      other.groupBackground == groupBackground &&
      other.groupColor == groupColor;

  @override
  int get hashCode => Object.hashAll(<Object?>[
    style,
    motion,
    fit,
    renderer,
    elasticity,
    duration,
    curve,
    thickness,
    topRadius,
    bottomRadius,
    color,
    tabInset,
    padding,
    contentInset,
    minLength,
    surfaceInset,
    verticalPadding,
    surfaceRadius,
    groupRadius,
    groupBackground,
    groupColor,
  ]);
}
