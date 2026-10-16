import 'package:flutter/widgets.dart';

import '../../../foundations/foundations.dart';

/// Theme values for Morph date pickers.
@immutable
class MorphDatePickerTheme extends MorphThemeExtension<MorphDatePickerTheme> {
  /// MorphDatePickerTheme.
  const MorphDatePickerTheme({
    this.width = 328,
    this.padding = const EdgeInsets.all(12),
    this.daySize = 40,
    this.arrowIconSize = 24,
    this.arrowPadding = const EdgeInsets.all(8),
    this.gridPadding = const EdgeInsets.only(top: 4),
    this.daysPerWeek = 7,
    this.elevation = 6,
    this.insetPadding = const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 24,
    ),
    this.headerPortraitHeight = 120,
    this.headerLandscapeWidth = 152,
    this.subHeaderHeight = 52,
    this.inputHorizontalPadding = 24,
    this.actionHorizontalPadding = 8,
    this.actionSpacing = 8,
  });

  /// defaults.

  static const MorphDatePickerTheme defaults = MorphDatePickerTheme();

  /// width.

  final double width;

  /// padding.
  final EdgeInsets padding;

  /// daySize.
  final double daySize;

  /// arrowIconSize.
  final double arrowIconSize;

  /// arrowPadding.
  final EdgeInsets arrowPadding;

  /// gridPadding.
  final EdgeInsets gridPadding;

  /// daysPerWeek.
  final int daysPerWeek;

  /// elevation.
  final double elevation;

  /// insetPadding.
  final EdgeInsets insetPadding;

  /// headerPortraitHeight.
  final double headerPortraitHeight;

  /// headerLandscapeWidth.
  final double headerLandscapeWidth;

  /// subHeaderHeight.
  final double subHeaderHeight;

  /// inputHorizontalPadding.
  final double inputHorizontalPadding;

  /// actionHorizontalPadding.
  final double actionHorizontalPadding;

  /// actionSpacing.
  final double actionSpacing;

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

  /// weekdayColor.

  Color weekdayColor(MorphColorScheme scheme) => scheme.onSurfaceVariant;

  /// todayColor.

  Color todayColor(MorphColorScheme scheme) => scheme.primary;

  /// selectedDayBackgroundColor.

  Color selectedDayBackgroundColor(MorphColorScheme scheme) => scheme.primary;

  /// selectedDayForegroundColor.

  Color selectedDayForegroundColor(MorphColorScheme scheme) => scheme.onPrimary;

  /// rangeStartBackgroundColor.

  Color rangeStartBackgroundColor(MorphColorScheme scheme) => scheme.primary;

  /// rangeEndBackgroundColor.

  Color rangeEndBackgroundColor(MorphColorScheme scheme) => scheme.primary;

  /// rangeSelectionColor.

  Color rangeSelectionColor(MorphColorScheme scheme) =>
      MorphColorUtils.withOpacity(scheme.primary, 0.12);

  /// rangeHighlightColor.

  Color rangeHighlightColor(MorphColorScheme scheme) =>
      MorphColorUtils.withOpacity(scheme.primary, 0.12);

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

  /// weekdayStyle.

  TextStyle weekdayStyle(MorphTypeScale typeScale, MorphColorScheme scheme) {
    return typeScale.bodySmall.copyWith(color: weekdayColor(scheme));
  }

  /// dayStyle.

  TextStyle dayStyle(MorphTypeScale typeScale, MorphColorScheme scheme) {
    return typeScale.bodyMedium.copyWith(color: scheme.onSurface);
  }

  /// yearStyle.

  TextStyle yearStyle(MorphTypeScale typeScale, MorphColorScheme scheme) {
    return typeScale.titleMedium.copyWith(color: scheme.onSurface);
  }

  /// selectedYearStyle.

  TextStyle selectedYearStyle(
    MorphTypeScale typeScale,
    MorphColorScheme scheme,
  ) {
    return typeScale.titleMedium.copyWith(color: scheme.onPrimary);
  }

  /// dayForegroundColor.

  Color dayForegroundColor(
    MorphColorScheme scheme, {
    required bool selected,
    required bool enabled,
  }) {
    if (!enabled) {
      return MorphColorUtils.withOpacity(scheme.onSurface, 0.38);
    }
    return selected ? selectedDayForegroundColor(scheme) : scheme.onSurface;
  }

  /// yearForegroundColor.

  Color yearForegroundColor(
    MorphColorScheme scheme, {
    required bool selected,
    required bool enabled,
  }) {
    if (!enabled) {
      return MorphColorUtils.withOpacity(scheme.onSurface, 0.38);
    }
    return selected ? selectedDayForegroundColor(scheme) : scheme.onSurface;
  }

  @override
  MorphDatePickerTheme copyWith({
    double? width,
    EdgeInsets? padding,
    double? daySize,
    double? arrowIconSize,
    EdgeInsets? arrowPadding,
    EdgeInsets? gridPadding,
    int? daysPerWeek,
    double? elevation,
    EdgeInsets? insetPadding,
    double? headerPortraitHeight,
    double? headerLandscapeWidth,
    double? subHeaderHeight,
    double? inputHorizontalPadding,
    double? actionHorizontalPadding,
    double? actionSpacing,
  }) {
    return MorphDatePickerTheme(
      width: width ?? this.width,
      padding: padding ?? this.padding,
      daySize: daySize ?? this.daySize,
      arrowIconSize: arrowIconSize ?? this.arrowIconSize,
      arrowPadding: arrowPadding ?? this.arrowPadding,
      gridPadding: gridPadding ?? this.gridPadding,
      daysPerWeek: daysPerWeek ?? this.daysPerWeek,
      elevation: elevation ?? this.elevation,
      insetPadding: insetPadding ?? this.insetPadding,
      headerPortraitHeight: headerPortraitHeight ?? this.headerPortraitHeight,
      headerLandscapeWidth: headerLandscapeWidth ?? this.headerLandscapeWidth,
      subHeaderHeight: subHeaderHeight ?? this.subHeaderHeight,
      inputHorizontalPadding:
          inputHorizontalPadding ?? this.inputHorizontalPadding,
      actionHorizontalPadding:
          actionHorizontalPadding ?? this.actionHorizontalPadding,
      actionSpacing: actionSpacing ?? this.actionSpacing,
    );
  }

  @override
  MorphDatePickerTheme lerp(MorphDatePickerTheme? other, double t) {
    if (other is! MorphDatePickerTheme) {
      return this;
    }
    return MorphDatePickerTheme(
      width: _lerpDouble(width, other.width, t)!,
      padding: EdgeInsets.lerp(padding, other.padding, t)!,
      daySize: _lerpDouble(daySize, other.daySize, t)!,
      arrowIconSize: _lerpDouble(arrowIconSize, other.arrowIconSize, t)!,
      arrowPadding: EdgeInsets.lerp(arrowPadding, other.arrowPadding, t)!,
      gridPadding: EdgeInsets.lerp(gridPadding, other.gridPadding, t)!,
      daysPerWeek:
          daysPerWeek + ((other.daysPerWeek - daysPerWeek) * t).round(),
      elevation: _lerpDouble(elevation, other.elevation, t)!,
      insetPadding: EdgeInsets.lerp(insetPadding, other.insetPadding, t)!,
      headerPortraitHeight: _lerpDouble(
        headerPortraitHeight,
        other.headerPortraitHeight,
        t,
      )!,
      headerLandscapeWidth: _lerpDouble(
        headerLandscapeWidth,
        other.headerLandscapeWidth,
        t,
      )!,
      subHeaderHeight: _lerpDouble(subHeaderHeight, other.subHeaderHeight, t)!,
      inputHorizontalPadding: _lerpDouble(
        inputHorizontalPadding,
        other.inputHorizontalPadding,
        t,
      )!,
      actionHorizontalPadding: _lerpDouble(
        actionHorizontalPadding,
        other.actionHorizontalPadding,
        t,
      )!,
      actionSpacing: _lerpDouble(actionSpacing, other.actionSpacing, t)!,
    );
  }

  double? _lerpDouble(double a, double b, double t) => a + (b - a) * t;
}
