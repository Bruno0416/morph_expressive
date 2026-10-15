import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../../../foundations/foundations.dart';
import '../enums/morph_segmented_button_enums.dart';

/// Theme values for `MorphSegmentedButton`.
@immutable
class MorphSegmentedButtonTheme
    extends MorphThemeExtension<MorphSegmentedButtonTheme> {
  /// Creates segmented button theme tokens.
  const MorphSegmentedButtonTheme({
    this.height = 40,
    this.targetSize = 48,
    this.iconSize = 18,
    this.segmentHorizontalPadding = 12,
    this.iconLabelGap = 8,
    this.borderWidth = 1,
    this.focusIndicatorWidth = 3,
    this.focusIndicatorGap = 2,
    this.disabledOutlineOpacity = 0.12,
    this.disabledContentOpacity = 0.38,
    this.maxWidth,
    this.outlineColor,
    this.outlineGradient,
    this.dividerColor,
    this.dividerGradient,
    this.selectedBackgroundColor,
    this.selectedBackgroundGradient,
    this.unselectedBackgroundGradient,
    this.selectedForegroundColor,
    this.unselectedForegroundColor,
    this.selectedForegroundGradient,
    this.unselectedForegroundGradient,
    this.focusIndicatorColor,
  });

  /// Spec defaults.
  static const MorphSegmentedButtonTheme defaults = MorphSegmentedButtonTheme();

  /// Base container height at density 0 (40dp).
  final double height;

  /// Minimum accessible target edge (48dp).
  final double targetSize;

  /// Leading / selected check icon size (18dp).
  final double iconSize;

  /// Minimum horizontal padding inside each segment (12dp).
  final double segmentHorizontalPadding;

  /// Gap between icon and label (8dp).
  final double iconLabelGap;

  /// Outline and divider stroke width (1dp).
  final double borderWidth;

  /// Keyboard focus ring thickness (3dp).
  final double focusIndicatorWidth;

  /// Gap between segment surface and focus ring (2dp).
  final double focusIndicatorGap;

  /// Disabled outline opacity (0.12) on onSurface.
  final double disabledOutlineOpacity;

  /// Disabled label/icon opacity (0.38) on onSurface.
  final double disabledContentOpacity;

  /// Optional max width for the group; null = unconstrained.
  final double? maxWidth;

  /// Group outline color. Defaults to the color scheme outline.
  final Color? outlineColor;

  /// Optional gradient for the group outline ring.
  final Gradient? outlineGradient;

  /// Divider color between segments. Defaults to the group outline color.
  final Color? dividerColor;

  /// Optional gradient for the dividers, sampled across the whole group.
  final Gradient? dividerGradient;

  /// Solid selected segment fill. Defaults to secondaryContainer.
  final Color? selectedBackgroundColor;

  /// Optional gradient for selected segments.
  final Gradient? selectedBackgroundGradient;

  /// Optional gradient for unselected segments.
  final Gradient? unselectedBackgroundGradient;

  /// Optional solid color for selected labels and icons.
  final Color? selectedForegroundColor;

  /// Optional solid color for unselected labels and icons.
  final Color? unselectedForegroundColor;

  /// Optional gradient for selected labels and icons.
  final Gradient? selectedForegroundGradient;

  /// Optional gradient for unselected labels and icons.
  final Gradient? unselectedForegroundGradient;

  /// Focus ring color. Defaults to secondary.
  final Color? focusIndicatorColor;

  /// Visual container height for [density] (−4dp per level from [height]).
  double heightFor(MorphSegmentedButtonDensity density) {
    return math.max(24, height + density.heightAdjustment);
  }

  /// Layout height: at least [targetSize] for the touch target.
  double layoutHeightFor(MorphSegmentedButtonDensity density) {
    final double visual = heightFor(density);
    return math.max(visual, targetSize);
  }

  /// Pill radius from the visual container height.
  BorderRadius borderRadiusFor(MorphSegmentedButtonDensity density) {
    return MorphShapes.resolve(heightFor(density) / 2);
  }

  /// The borderRadius at density 0.
  BorderRadius get borderRadius => MorphShapes.resolve(height / 2);

  /// Solid outline color for the group ring.
  Color outline(MorphColorScheme scheme, {required bool enabled}) {
    final Color base = outlineColor ?? scheme.outline;
    if (enabled) {
      return base;
    }
    return (outlineColor ?? scheme.onSurface).withValues(
      alpha: disabledOutlineOpacity,
    );
  }

  /// Solid divider color between segments.
  Color divider(MorphColorScheme scheme, {required bool enabled}) {
    if (!enabled) {
      return outline(scheme, enabled: false);
    }
    return dividerColor ?? outline(scheme, enabled: true);
  }

  /// Focus ring color.
  Color focusColor(MorphColorScheme scheme) =>
      focusIndicatorColor ?? scheme.secondary;

  /// Foreground for labels and icons.
  Color foregroundColor(
    MorphColorScheme scheme, {
    required bool selected,
    required bool enabled,
  }) {
    if (!enabled) {
      return scheme.onSurface.withValues(alpha: disabledContentOpacity);
    }
    if (selected) {
      return selectedForegroundColor ?? scheme.onSecondaryContainer;
    }
    return unselectedForegroundColor ?? scheme.onSurface;
  }

  /// Background fill for a segment; null when unselected (transparent).
  Color? backgroundColor(MorphColorScheme scheme, {required bool selected}) {
    if (!selected) {
      return null;
    }
    return selectedBackgroundColor ?? scheme.secondaryContainer;
  }

  @override
  MorphSegmentedButtonTheme copyWith({
    double? height,
    double? targetSize,
    double? iconSize,
    double? segmentHorizontalPadding,
    double? iconLabelGap,
    double? borderWidth,
    double? focusIndicatorWidth,
    double? focusIndicatorGap,
    double? disabledOutlineOpacity,
    double? disabledContentOpacity,
    double? maxWidth,
    Color? outlineColor,
    Gradient? outlineGradient,
    Color? dividerColor,
    Gradient? dividerGradient,
    Color? selectedBackgroundColor,
    Gradient? selectedBackgroundGradient,
    Gradient? unselectedBackgroundGradient,
    Color? selectedForegroundColor,
    Color? unselectedForegroundColor,
    Gradient? selectedForegroundGradient,
    Gradient? unselectedForegroundGradient,
    Color? focusIndicatorColor,
  }) {
    return MorphSegmentedButtonTheme(
      height: height ?? this.height,
      targetSize: targetSize ?? this.targetSize,
      iconSize: iconSize ?? this.iconSize,
      segmentHorizontalPadding:
          segmentHorizontalPadding ?? this.segmentHorizontalPadding,
      iconLabelGap: iconLabelGap ?? this.iconLabelGap,
      borderWidth: borderWidth ?? this.borderWidth,
      focusIndicatorWidth: focusIndicatorWidth ?? this.focusIndicatorWidth,
      focusIndicatorGap: focusIndicatorGap ?? this.focusIndicatorGap,
      disabledOutlineOpacity:
          disabledOutlineOpacity ?? this.disabledOutlineOpacity,
      disabledContentOpacity:
          disabledContentOpacity ?? this.disabledContentOpacity,
      maxWidth: maxWidth ?? this.maxWidth,
      outlineColor: outlineColor ?? this.outlineColor,
      outlineGradient: outlineGradient ?? this.outlineGradient,
      dividerColor: dividerColor ?? this.dividerColor,
      dividerGradient: dividerGradient ?? this.dividerGradient,
      selectedBackgroundColor:
          selectedBackgroundColor ?? this.selectedBackgroundColor,
      selectedBackgroundGradient:
          selectedBackgroundGradient ?? this.selectedBackgroundGradient,
      unselectedBackgroundGradient:
          unselectedBackgroundGradient ?? this.unselectedBackgroundGradient,
      selectedForegroundColor:
          selectedForegroundColor ?? this.selectedForegroundColor,
      unselectedForegroundColor:
          unselectedForegroundColor ?? this.unselectedForegroundColor,
      selectedForegroundGradient:
          selectedForegroundGradient ?? this.selectedForegroundGradient,
      unselectedForegroundGradient:
          unselectedForegroundGradient ?? this.unselectedForegroundGradient,
      focusIndicatorColor: focusIndicatorColor ?? this.focusIndicatorColor,
    );
  }

  @override
  MorphSegmentedButtonTheme lerp(MorphSegmentedButtonTheme? other, double t) {
    if (other is! MorphSegmentedButtonTheme) {
      return this;
    }
    return MorphSegmentedButtonTheme(
      height: _lerpDouble(height, other.height, t)!,
      targetSize: _lerpDouble(targetSize, other.targetSize, t)!,
      iconSize: _lerpDouble(iconSize, other.iconSize, t)!,
      segmentHorizontalPadding: _lerpDouble(
        segmentHorizontalPadding,
        other.segmentHorizontalPadding,
        t,
      )!,
      iconLabelGap: _lerpDouble(iconLabelGap, other.iconLabelGap, t)!,
      borderWidth: _lerpDouble(borderWidth, other.borderWidth, t)!,
      focusIndicatorWidth: _lerpDouble(
        focusIndicatorWidth,
        other.focusIndicatorWidth,
        t,
      )!,
      focusIndicatorGap: _lerpDouble(
        focusIndicatorGap,
        other.focusIndicatorGap,
        t,
      )!,
      disabledOutlineOpacity: _lerpDouble(
        disabledOutlineOpacity,
        other.disabledOutlineOpacity,
        t,
      )!,
      disabledContentOpacity: _lerpDouble(
        disabledContentOpacity,
        other.disabledContentOpacity,
        t,
      )!,
      maxWidth: t < 0.5 ? maxWidth : other.maxWidth,
      outlineColor: Color.lerp(outlineColor, other.outlineColor, t),
      outlineGradient: t < 0.5 ? outlineGradient : other.outlineGradient,
      dividerColor: Color.lerp(dividerColor, other.dividerColor, t),
      dividerGradient: t < 0.5 ? dividerGradient : other.dividerGradient,
      selectedBackgroundColor: Color.lerp(
        selectedBackgroundColor,
        other.selectedBackgroundColor,
        t,
      ),
      selectedBackgroundGradient: t < 0.5
          ? selectedBackgroundGradient
          : other.selectedBackgroundGradient,
      unselectedBackgroundGradient: t < 0.5
          ? unselectedBackgroundGradient
          : other.unselectedBackgroundGradient,
      selectedForegroundColor: Color.lerp(
        selectedForegroundColor,
        other.selectedForegroundColor,
        t,
      ),
      unselectedForegroundColor: Color.lerp(
        unselectedForegroundColor,
        other.unselectedForegroundColor,
        t,
      ),
      selectedForegroundGradient: t < 0.5
          ? selectedForegroundGradient
          : other.selectedForegroundGradient,
      unselectedForegroundGradient: t < 0.5
          ? unselectedForegroundGradient
          : other.unselectedForegroundGradient,
      focusIndicatorColor: Color.lerp(
        focusIndicatorColor,
        other.focusIndicatorColor,
        t,
      ),
    );
  }

  double? _lerpDouble(double a, double b, double t) => a + (b - a) * t;
}
