import 'package:flutter/widgets.dart';

import '../../../foundations/foundations.dart';

/// Theme values for Morph time pickers.
@immutable
class MorphTimePickerTheme extends MorphThemeExtension<MorphTimePickerTheme> {
  /// MorphTimePickerTheme.
  const MorphTimePickerTheme({
    this.padding = const EdgeInsets.all(24),
    this.dialSize = 256,
    this.dialKnobRadius = 20,
    this.dialCenterRadius = 4,
    this.dialRingInset = 4,
    this.dialHandWidth = 2,
    this.dialLabelFontSize = 16,
    this.fieldSize = const Size(96, 80),
    this.fieldMargin = const EdgeInsets.symmetric(horizontal: 4),
    this.periodOptionSize = const Size(52, 40),
    this.periodPortraitSize = const Size(52, 80),
    this.periodLandscapeSize = const Size(216, 38),
    this.periodInputSize = const Size(52, 72),
    this.fieldPeriodGap = 12,
    this.headerDialGap = 24,
    this.elevation = 6,
    this.headerLandscapeWidth = 216,
  });

  /// defaults.

  static const MorphTimePickerTheme defaults = MorphTimePickerTheme();

  /// padding.

  final EdgeInsets padding;

  /// dialSize.
  final double dialSize;

  /// dialKnobRadius.
  final double dialKnobRadius;

  /// dialCenterRadius.
  final double dialCenterRadius;

  /// dialRingInset.
  final double dialRingInset;

  /// dialHandWidth.
  final double dialHandWidth;

  /// dialLabelFontSize.
  final double dialLabelFontSize;

  /// fieldSize.
  final Size fieldSize;

  /// fieldMargin.
  final EdgeInsets fieldMargin;

  /// Half of [periodPortraitSize] (legacy per-option size).
  final Size periodOptionSize;

  /// Full AM/PM control size in portrait dial mode (Material dayPeriodPortraitSize).
  final Size periodPortraitSize;

  /// Full AM/PM control size in landscape dial mode.
  final Size periodLandscapeSize;

  /// Full AM/PM control size in input mode (slightly shorter than portrait).
  final Size periodInputSize;

  /// fieldPeriodGap.
  final double fieldPeriodGap;

  /// headerDialGap.
  final double headerDialGap;

  /// elevation.
  final double elevation;

  /// headerLandscapeWidth.
  final double headerLandscapeWidth;

  /// The borderRadius.

  BorderRadius get borderRadius => MorphShapes.radiusExtraLarge;

  /// The dialogShape.
  BorderRadius get dialogShape => MorphShapes.radiusExtraLarge;

  /// backgroundColor.

  Color backgroundColor(MorphColorScheme scheme) => scheme.surfaceContainerHigh;

  /// containerColor.

  Color containerColor(MorphColorScheme scheme) => scheme.surfaceContainerHigh;

  /// headerBackgroundColor.

  Color headerBackgroundColor(MorphColorScheme scheme) =>
      scheme.surfaceContainerHigh;

  /// headerForegroundColor.

  Color headerForegroundColor(MorphColorScheme scheme) =>
      scheme.onSurfaceVariant;

  /// dividerColor.

  Color dividerColor(MorphColorScheme scheme) =>
      MorphColorUtils.withOpacity(scheme.onSurface, 0.12);

  /// periodOptionBackgroundColor.

  Color periodOptionBackgroundColor(
    MorphColorScheme scheme, {
    required bool selected,
  }) {
    return selected ? scheme.tertiaryContainer : const Color(0x00000000);
  }

  /// periodOptionForegroundColor.

  Color periodOptionForegroundColor(
    MorphColorScheme scheme, {
    required bool selected,
  }) {
    return selected ? scheme.onTertiaryContainer : scheme.onSurfaceVariant;
  }

  /// fieldBackgroundColor.

  Color fieldBackgroundColor(MorphColorScheme scheme, {required bool active}) {
    return active ? scheme.primaryContainer : scheme.surfaceContainerHighest;
  }

  /// fieldForegroundColor.

  Color fieldForegroundColor(MorphColorScheme scheme, {required bool active}) {
    return active ? scheme.onPrimaryContainer : scheme.onSurface;
  }

  /// headerHelpStyle.

  TextStyle headerHelpStyle(MorphTypeScale typeScale, MorphColorScheme scheme) {
    return typeScale.labelLarge.copyWith(color: headerForegroundColor(scheme));
  }

  /// headerHeadlineStyle.

  TextStyle headerHeadlineStyle(
    MorphTypeScale typeScale,
    MorphColorScheme scheme,
  ) {
    return typeScale.headlineLarge.copyWith(color: scheme.onSurface);
  }

  /// headerHeadlineShortStyle.

  TextStyle headerHeadlineShortStyle(
    MorphTypeScale typeScale,
    MorphColorScheme scheme,
  ) {
    return typeScale.headlineSmall.copyWith(color: scheme.onSurface);
  }

  @override
  MorphTimePickerTheme copyWith({
    EdgeInsets? padding,
    double? dialSize,
    double? dialKnobRadius,
    double? dialCenterRadius,
    double? dialRingInset,
    double? dialHandWidth,
    double? dialLabelFontSize,
    Size? fieldSize,
    EdgeInsets? fieldMargin,
    Size? periodOptionSize,
    Size? periodPortraitSize,
    Size? periodLandscapeSize,
    Size? periodInputSize,
    double? fieldPeriodGap,
    double? headerDialGap,
    double? elevation,
    double? headerLandscapeWidth,
  }) {
    return MorphTimePickerTheme(
      padding: padding ?? this.padding,
      dialSize: dialSize ?? this.dialSize,
      dialKnobRadius: dialKnobRadius ?? this.dialKnobRadius,
      dialCenterRadius: dialCenterRadius ?? this.dialCenterRadius,
      dialRingInset: dialRingInset ?? this.dialRingInset,
      dialHandWidth: dialHandWidth ?? this.dialHandWidth,
      dialLabelFontSize: dialLabelFontSize ?? this.dialLabelFontSize,
      fieldSize: fieldSize ?? this.fieldSize,
      fieldMargin: fieldMargin ?? this.fieldMargin,
      periodOptionSize: periodOptionSize ?? this.periodOptionSize,
      periodPortraitSize: periodPortraitSize ?? this.periodPortraitSize,
      periodLandscapeSize: periodLandscapeSize ?? this.periodLandscapeSize,
      periodInputSize: periodInputSize ?? this.periodInputSize,
      fieldPeriodGap: fieldPeriodGap ?? this.fieldPeriodGap,
      headerDialGap: headerDialGap ?? this.headerDialGap,
      elevation: elevation ?? this.elevation,
      headerLandscapeWidth: headerLandscapeWidth ?? this.headerLandscapeWidth,
    );
  }

  @override
  MorphTimePickerTheme lerp(MorphTimePickerTheme? other, double t) {
    if (other is! MorphTimePickerTheme) {
      return this;
    }
    return MorphTimePickerTheme(
      padding: EdgeInsets.lerp(padding, other.padding, t)!,
      dialSize: _lerpDouble(dialSize, other.dialSize, t)!,
      dialKnobRadius: _lerpDouble(dialKnobRadius, other.dialKnobRadius, t)!,
      dialCenterRadius: _lerpDouble(
        dialCenterRadius,
        other.dialCenterRadius,
        t,
      )!,
      dialRingInset: _lerpDouble(dialRingInset, other.dialRingInset, t)!,
      dialHandWidth: _lerpDouble(dialHandWidth, other.dialHandWidth, t)!,
      dialLabelFontSize: _lerpDouble(
        dialLabelFontSize,
        other.dialLabelFontSize,
        t,
      )!,
      fieldSize: Size.lerp(fieldSize, other.fieldSize, t)!,
      fieldMargin: EdgeInsets.lerp(fieldMargin, other.fieldMargin, t)!,
      periodOptionSize: Size.lerp(periodOptionSize, other.periodOptionSize, t)!,
      periodPortraitSize: Size.lerp(
        periodPortraitSize,
        other.periodPortraitSize,
        t,
      )!,
      periodLandscapeSize: Size.lerp(
        periodLandscapeSize,
        other.periodLandscapeSize,
        t,
      )!,
      periodInputSize: Size.lerp(periodInputSize, other.periodInputSize, t)!,
      fieldPeriodGap: _lerpDouble(fieldPeriodGap, other.fieldPeriodGap, t)!,
      headerDialGap: _lerpDouble(headerDialGap, other.headerDialGap, t)!,
      elevation: _lerpDouble(elevation, other.elevation, t)!,
      headerLandscapeWidth: _lerpDouble(
        headerLandscapeWidth,
        other.headerLandscapeWidth,
        t,
      )!,
    );
  }

  double? _lerpDouble(double a, double b, double t) => a + (b - a) * t;
}
