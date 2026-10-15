import 'package:flutter/widgets.dart';
import 'package:morph_expressive/components/dropdown_menus/morph_dropdown_menus.dart'
    show MorphDropdownMenu;
import 'package:morph_expressive/morph_components.dart'
    show MorphDropdownMenu;

import '../../../foundations/foundations.dart';

/// Theme values for [MorphDropdownMenu].
@immutable
class MorphDropdownMenuTheme extends MorphThemeExtension<MorphDropdownMenuTheme> {
  /// MorphDropdownMenuTheme.
  const MorphDropdownMenuTheme({
    this.containerRadius = 28,
    this.panelElevation = MorphElevation.level2,
    this.panelMaxHeight = 350,
    this.panelMarginTop = 4,
    this.itemOuterRadius = 12,
    this.itemInnerRadius = 4,
    this.openSpring = MorphMotion.dropdownOpen,
    this.closeSpring = MorphMotion.dropdownClose,
    this.disabledOpacity = 0.38,
  });

  /// defaults.

  static const MorphDropdownMenuTheme defaults = MorphDropdownMenuTheme();

  /// containerRadius.

  final double containerRadius;

  /// panelElevation.
  final double panelElevation;

  /// panelMaxHeight.
  final double panelMaxHeight;

  /// panelMarginTop.
  final double panelMarginTop;

  /// itemOuterRadius.
  final double itemOuterRadius;

  /// itemInnerRadius.
  final double itemInnerRadius;

  /// openSpring.
  final MorphSpring openSpring;

  /// closeSpring.
  final MorphSpring closeSpring;

  /// disabledOpacity.
  final double disabledOpacity;

  /// fieldBackgroundColor.

  Color fieldBackgroundColor(MorphColorScheme scheme) =>
      scheme.surfaceContainerHighest;

  /// fieldForegroundColor.

  Color fieldForegroundColor(MorphColorScheme scheme) => scheme.onSurface;

  /// panelBackgroundColor.

  Color panelBackgroundColor(MorphColorScheme scheme) =>
      scheme.surfaceContainerHighest;

  /// chipBackgroundColor.

  Color chipBackgroundColor(MorphColorScheme scheme) => scheme.secondaryContainer;

  /// chipForegroundColor.

  Color chipForegroundColor(MorphColorScheme scheme) =>
      scheme.onSecondaryContainer;

  /// itemBackgroundColor.

  Color itemBackgroundColor(MorphColorScheme scheme) =>
      scheme.surfaceContainerHigh;

  /// itemSelectedBackgroundColor.

  Color itemSelectedBackgroundColor(MorphColorScheme scheme) =>
      scheme.secondaryContainer;

  /// itemForegroundColor.

  Color itemForegroundColor(MorphColorScheme scheme) => scheme.onSurface;

  /// itemSelectedForegroundColor.

  Color itemSelectedForegroundColor(MorphColorScheme scheme) =>
      scheme.onSecondaryContainer;

  /// hintTextStyle.

  TextStyle hintTextStyle(MorphTypeScale type, MorphColorScheme scheme) => type
      .bodyLarge
      .copyWith(color: MorphColorUtils.withOpacity(scheme.onSurface, 0.6));

  /// selectedTextStyle.

  TextStyle selectedTextStyle(MorphTypeScale type, MorphColorScheme scheme) =>
      type.bodyMedium.copyWith(color: scheme.onSurface);

  /// chipLabelStyle.

  TextStyle chipLabelStyle(MorphTypeScale type, MorphColorScheme scheme) =>
      type.labelMedium.copyWith(color: scheme.onSecondaryContainer);

  /// itemTextStyle.

  TextStyle itemTextStyle(MorphTypeScale type, MorphColorScheme scheme) =>
      type.bodyLarge.copyWith(
        color: scheme.onSurface,
        fontSize: (type.bodyLarge.fontSize ?? 16) + 2,
      );

  @override
  MorphDropdownMenuTheme copyWith({
    double? containerRadius,
    double? panelElevation,
    double? panelMaxHeight,
    double? panelMarginTop,
    double? itemOuterRadius,
    double? itemInnerRadius,
    MorphSpring? openSpring,
    MorphSpring? closeSpring,
    double? disabledOpacity,
  }) {
    return MorphDropdownMenuTheme(
      containerRadius: containerRadius ?? this.containerRadius,
      panelElevation: panelElevation ?? this.panelElevation,
      panelMaxHeight: panelMaxHeight ?? this.panelMaxHeight,
      panelMarginTop: panelMarginTop ?? this.panelMarginTop,
      itemOuterRadius: itemOuterRadius ?? this.itemOuterRadius,
      itemInnerRadius: itemInnerRadius ?? this.itemInnerRadius,
      openSpring: openSpring ?? this.openSpring,
      closeSpring: closeSpring ?? this.closeSpring,
      disabledOpacity: disabledOpacity ?? this.disabledOpacity,
    );
  }

  @override
  MorphDropdownMenuTheme lerp(MorphDropdownMenuTheme? other, double t) {
    if (other is! MorphDropdownMenuTheme) {
      return this;
    }
    return MorphDropdownMenuTheme(
      containerRadius: _lerpDouble(containerRadius, other.containerRadius, t)!,
      panelElevation: _lerpDouble(panelElevation, other.panelElevation, t)!,
      panelMaxHeight: _lerpDouble(panelMaxHeight, other.panelMaxHeight, t)!,
      panelMarginTop: _lerpDouble(panelMarginTop, other.panelMarginTop, t)!,
      itemOuterRadius: _lerpDouble(itemOuterRadius, other.itemOuterRadius, t)!,
      itemInnerRadius: _lerpDouble(itemInnerRadius, other.itemInnerRadius, t)!,
      openSpring: t < 0.5 ? openSpring : other.openSpring,
      closeSpring: t < 0.5 ? closeSpring : other.closeSpring,
      disabledOpacity: _lerpDouble(disabledOpacity, other.disabledOpacity, t)!,
    );
  }

  double? _lerpDouble(double a, double b, double t) => a + (b - a) * t;
}
