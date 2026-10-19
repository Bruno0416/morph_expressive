import 'package:flutter/widgets.dart';

import '../../../foundations/foundations.dart';
import '../enums/morph_nav_bar_enums.dart';
import '../models/morph_nav_metrics.dart';
import '../res/morph_nav_bar_constants.dart';

part 'morph_navigation_bar_theme_lerp.dart';

/// Theme values for `MorphNavigationBar`.
@immutable
class MorphNavigationBarTheme
    extends MorphThemeExtension<MorphNavigationBarTheme> {
  /// MorphNavigationBarTheme.
  const MorphNavigationBarTheme({
    this.heightSmall = MorphNavBarConstants.heightSmall,
    this.heightMedium = MorphNavBarConstants.heightMedium,
    this.iconSize = 24,
    this.indicatorThickness = 3,
    this.compactHeightReduction = 4,
    this.compactIndicatorReduction = 1,
    this.indicatorScaleSpring = MorphMotion.navigationSelection,
    this.indicatorFadeSpring = MorphMotion.navigationEffects,
    this.elevation = MorphNavBarConstants.elevation,
    this.verticalIndicatorWidth = MorphNavBarConstants.flexibleIndicatorWidth,
    this.verticalIndicatorHeight = MorphNavBarConstants.indicatorHeight,
    this.verticalIndicatorRadius = MorphNavBarConstants.indicatorRadius,
    this.verticalPaddingTop = MorphNavBarConstants.verticalPaddingTop,
    this.verticalPaddingBottom = MorphNavBarConstants.verticalPaddingBottom,
    this.verticalIconLabelGap = MorphNavBarConstants.verticalIconLabelGap,
    this.horizontalIndicatorHeight =
        MorphNavBarConstants.horizontalIndicatorHeight,
    this.horizontalPadding = MorphNavBarConstants.horizontalBarPadding,
    this.horizontalIndicatorInset =
        MorphNavBarConstants.horizontalIndicatorInset,
    this.horizontalIconLabelGap = MorphNavBarConstants.horizontalIconLabelGap,
    this.baselineExtraPadding = MorphNavBarConstants.baselineExtraPadding,
    this.itemGap = MorphNavBarConstants.itemGap,
    this.wideItemGap = MorphNavBarConstants.wideDestinationGap,
    this.wideEdgePadding = MorphNavBarConstants.wideDestinationGap,
    this.hoverIndicatorWidth = MorphNavBarConstants.hoverIndicatorWidth,
    this.wideBreakpoint = MorphNavBarConstants.mediumWindowBreakpoint,
    this.focusRingThickness = MorphNavBarConstants.focusRingThickness,
    this.focusRingInset = MorphNavBarConstants.focusRingInset,
    this.hoverOpacity = MorphNavBarConstants.stateHoverOpacity,
    this.focusOpacity = MorphNavBarConstants.stateFocusOpacity,
    this.pressedOpacity = MorphNavBarConstants.statePressedOpacity,
    this.labelFontSize = MorphNavBarConstants.labelFontSize,
    this.labelLineHeight = MorphNavBarConstants.labelLineHeight,
    this.labelLetterSpacing = MorphNavBarConstants.labelLetterSpacing,
    this.inactiveLabelWeight = FontWeight.w500,
    this.activeLabelWeight = FontWeight.w700,
    this.restingLabelMaxLines = MorphNavBarConstants.restingLabelMaxLines,
    this.scaledLabelMaxLines = MorphNavBarConstants.scaledLabelMaxLines,
    this.truncationTextScale = MorphNavBarConstants.truncationTextScale,
  });

  /// defaults.
  static const MorphNavigationBarTheme defaults = MorphNavigationBarTheme();

  /// heightSmall.
  final double heightSmall;

  /// heightMedium.
  final double heightMedium;

  /// iconSize.
  final double iconSize;

  /// indicatorThickness.
  final double indicatorThickness;

  /// compactHeightReduction.
  final double compactHeightReduction;

  /// compactIndicatorReduction.
  final double compactIndicatorReduction;

  /// Spatial spring for the selection indicator width scale.
  final MorphSpring indicatorScaleSpring;

  /// Effects spring for the selection indicator fade.
  final MorphSpring indicatorFadeSpring;

  /// Container elevation.
  final double elevation;

  /// Vertical active pill width.
  final double verticalIndicatorWidth;

  /// Vertical active pill height.
  final double verticalIndicatorHeight;

  /// Vertical pill corner radius.
  final double verticalIndicatorRadius;

  /// Padding above the vertical icon pill.
  final double verticalPaddingTop;

  /// Padding below the vertical label.
  final double verticalPaddingBottom;

  /// Gap between the vertical icon pill and the label.
  final double verticalIconLabelGap;

  /// Horizontal pill height before text scale growth.
  final double horizontalIndicatorHeight;

  /// Padding above and below a horizontal pill.
  final double horizontalPadding;

  /// Leading and trailing inset inside a horizontal pill.
  final double horizontalIndicatorInset;

  /// Gap between the icon and the label in a horizontal pill.
  final double horizontalIconLabelGap;

  /// Extra padding the baseline size adds above and below.
  final double baselineExtraPadding;

  /// Gap between vertical destinations.
  final double itemGap;

  /// Gap between horizontal destinations.
  final double wideItemGap;

  /// Inset between a start- or end-aligned horizontal group and the bar edge.
  final double wideEdgePadding;

  /// Inactive hover pill width.
  final double hoverIndicatorWidth;

  /// Auto-layout width that switches to horizontal items.
  final double wideBreakpoint;

  /// Inset focus ring thickness.
  final double focusRingThickness;

  /// Inset of the focus ring from the destination edge.
  final double focusRingInset;

  /// Hover state-layer opacity.
  final double hoverOpacity;

  /// Focus state-layer opacity.
  final double focusOpacity;

  /// Pressed state-layer opacity.
  final double pressedOpacity;

  /// Label size at 1x.
  final double labelFontSize;

  /// Label line height at 1x.
  final double labelLineHeight;

  /// Label tracking.
  final double labelLetterSpacing;

  /// Inactive label weight.
  final FontWeight inactiveLabelWeight;

  /// Active label weight.
  final FontWeight activeLabelWeight;

  /// Label lines at 1x.
  final int restingLabelMaxLines;

  /// Label lines above 1x.
  final int scaledLabelMaxLines;

  /// Text scale above which a label may ellipsize.
  final double truncationTextScale;

  /// metrics.
  MorphNavMetrics metrics(MorphNavBarDensity density, MorphSpacing spacing) {
    var hSmall = heightSmall;
    var hMedium = heightMedium;
    var icon = iconSize;
    var underline = indicatorThickness;

    if (density == MorphNavBarDensity.compact) {
      hSmall -= compactHeightReduction;
      hMedium -= compactHeightReduction;
      underline -= compactIndicatorReduction;
    }

    return MorphNavMetrics(
      heightSmall: hSmall,
      heightMedium: hMedium,
      iconSize: icon,
      padding: EdgeInsets.symmetric(horizontal: spacing.md),
      indicatorThickness: underline,
    );
  }

  /// containerColor.
  Color containerColor(MorphColorScheme scheme) => scheme.surfaceContainerHigh;

  /// indicatorColor.
  Color indicatorColor(MorphColorScheme scheme) => scheme.secondaryContainer;

  /// Active icon color.
  Color selectedColor(MorphColorScheme scheme) => scheme.onSecondaryContainer;

  /// Active label color.
  Color activeLabelColor(MorphColorScheme scheme) => scheme.onSurface;

  /// Inactive icon and label color.
  Color unselectedColor(MorphColorScheme scheme) => scheme.onSurfaceVariant;

  /// State layer color.
  Color stateLayerColor(MorphColorScheme scheme) => scheme.onSecondaryContainer;

  /// Inset focus ring color.
  Color focusRingColor(MorphColorScheme scheme) => scheme.secondary;

  /// Shadow color at elevation 0.
  Color shadowColor(MorphColorScheme scheme) => scheme.shadow;

  /// Label style. Active labels use [activeLabelWeight].
  TextStyle labelStyle(MorphTypeScale type, {bool selected = false}) {
    return type.labelMedium.copyWith(
      fontSize: labelFontSize,
      height: labelLineHeight / labelFontSize,
      letterSpacing: labelLetterSpacing,
      fontWeight: selected ? activeLabelWeight : inactiveLabelWeight,
    );
  }

  /// containerShape.
  ShapeBorder containerShape(MorphNavBarShapeFamily family) {
    if (family == MorphNavBarShapeFamily.round) {
      return RoundedRectangleBorder(borderRadius: MorphShapes.roundSet.lg);
    }
    return const RoundedRectangleBorder();
  }

  /// indicatorShapePill.
  ShapeBorder indicatorShapePill() => const StadiumBorder();

  /// underlineDecoration.
  BoxDecoration underlineDecoration(Color color, double thickness) {
    return BoxDecoration(
      border: Border(
        bottom: BorderSide(color: color, width: thickness),
      ),
    );
  }

  @override
  MorphNavigationBarTheme copyWith({
    double? heightSmall,
    double? heightMedium,
    double? iconSize,
    double? indicatorThickness,
    double? compactHeightReduction,
    double? compactIndicatorReduction,
    MorphSpring? indicatorScaleSpring,
    MorphSpring? indicatorFadeSpring,
    double? elevation,
    double? verticalIndicatorWidth,
    double? verticalIndicatorHeight,
    double? verticalIndicatorRadius,
    double? verticalPaddingTop,
    double? verticalPaddingBottom,
    double? verticalIconLabelGap,
    double? horizontalIndicatorHeight,
    double? horizontalPadding,
    double? horizontalIndicatorInset,
    double? horizontalIconLabelGap,
    double? baselineExtraPadding,
    double? itemGap,
    double? wideItemGap,
    double? wideEdgePadding,
    double? hoverIndicatorWidth,
    double? wideBreakpoint,
    double? focusRingThickness,
    double? focusRingInset,
    double? hoverOpacity,
    double? focusOpacity,
    double? pressedOpacity,
    double? labelFontSize,
    double? labelLineHeight,
    double? labelLetterSpacing,
    FontWeight? inactiveLabelWeight,
    FontWeight? activeLabelWeight,
    int? restingLabelMaxLines,
    int? scaledLabelMaxLines,
    double? truncationTextScale,
  }) {
    return MorphNavigationBarTheme(
      heightSmall: heightSmall ?? this.heightSmall,
      heightMedium: heightMedium ?? this.heightMedium,
      iconSize: iconSize ?? this.iconSize,
      indicatorThickness: indicatorThickness ?? this.indicatorThickness,
      compactHeightReduction:
          compactHeightReduction ?? this.compactHeightReduction,
      compactIndicatorReduction:
          compactIndicatorReduction ?? this.compactIndicatorReduction,
      indicatorScaleSpring: indicatorScaleSpring ?? this.indicatorScaleSpring,
      indicatorFadeSpring: indicatorFadeSpring ?? this.indicatorFadeSpring,
      elevation: elevation ?? this.elevation,
      verticalIndicatorWidth:
          verticalIndicatorWidth ?? this.verticalIndicatorWidth,
      verticalIndicatorHeight:
          verticalIndicatorHeight ?? this.verticalIndicatorHeight,
      verticalIndicatorRadius:
          verticalIndicatorRadius ?? this.verticalIndicatorRadius,
      verticalPaddingTop: verticalPaddingTop ?? this.verticalPaddingTop,
      verticalPaddingBottom:
          verticalPaddingBottom ?? this.verticalPaddingBottom,
      verticalIconLabelGap: verticalIconLabelGap ?? this.verticalIconLabelGap,
      horizontalIndicatorHeight:
          horizontalIndicatorHeight ?? this.horizontalIndicatorHeight,
      horizontalPadding: horizontalPadding ?? this.horizontalPadding,
      horizontalIndicatorInset:
          horizontalIndicatorInset ?? this.horizontalIndicatorInset,
      horizontalIconLabelGap:
          horizontalIconLabelGap ?? this.horizontalIconLabelGap,
      baselineExtraPadding: baselineExtraPadding ?? this.baselineExtraPadding,
      itemGap: itemGap ?? this.itemGap,
      wideItemGap: wideItemGap ?? this.wideItemGap,
      wideEdgePadding: wideEdgePadding ?? this.wideEdgePadding,
      hoverIndicatorWidth: hoverIndicatorWidth ?? this.hoverIndicatorWidth,
      wideBreakpoint: wideBreakpoint ?? this.wideBreakpoint,
      focusRingThickness: focusRingThickness ?? this.focusRingThickness,
      focusRingInset: focusRingInset ?? this.focusRingInset,
      hoverOpacity: hoverOpacity ?? this.hoverOpacity,
      focusOpacity: focusOpacity ?? this.focusOpacity,
      pressedOpacity: pressedOpacity ?? this.pressedOpacity,
      labelFontSize: labelFontSize ?? this.labelFontSize,
      labelLineHeight: labelLineHeight ?? this.labelLineHeight,
      labelLetterSpacing: labelLetterSpacing ?? this.labelLetterSpacing,
      inactiveLabelWeight: inactiveLabelWeight ?? this.inactiveLabelWeight,
      activeLabelWeight: activeLabelWeight ?? this.activeLabelWeight,
      restingLabelMaxLines: restingLabelMaxLines ?? this.restingLabelMaxLines,
      scaledLabelMaxLines: scaledLabelMaxLines ?? this.scaledLabelMaxLines,
      truncationTextScale: truncationTextScale ?? this.truncationTextScale,
    );
  }

  @override
  MorphNavigationBarTheme lerp(MorphNavigationBarTheme? other, double t) {
    if (other is! MorphNavigationBarTheme) {
      return this;
    }
    return _lerpNavigationBarTheme(other, t);
  }
}
