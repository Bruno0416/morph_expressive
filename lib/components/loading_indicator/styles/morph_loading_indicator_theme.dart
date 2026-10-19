import 'package:flutter/widgets.dart';

import '../../../foundations/foundations.dart';
import '../enums/morph_loading_indicator_variant.dart';

/// Theme values for `MorphLoadingIndicator`.
@immutable
class MorphLoadingIndicatorTheme
    extends MorphThemeExtension<MorphLoadingIndicatorTheme> {
  /// MorphLoadingIndicatorTheme.
  const MorphLoadingIndicatorTheme({
    this.containerWidth = 48,
    this.containerHeight = 48,
    this.activeIndicatorSize = 38,
    this.containerShape = const CircleBorder(),
    this.globalRotationDuration = const Duration(milliseconds: 1600),
    this.morphInterval = MorphMotion.extraLong4,
    this.morphRotationDegrees = 45,
    this.morphSpring = MorphMotion.expressiveSpatialSlow,
    this.morphSpringVelocity = 2,
    this.pulseStartScale = 0.99,
    this.pulseSpring = MorphMotion.expressiveSpatialSlow,
    this.pulseSpringVelocity = 5,
  }) : assert(containerWidth > 0, 'containerWidth must be greater than zero'),
       assert(containerHeight > 0, 'containerHeight must be greater than zero'),
       assert(
         activeIndicatorSize > 0,
         'activeIndicatorSize must be greater than zero',
       );

  /// defaults.

  static const MorphLoadingIndicatorTheme defaults =
      MorphLoadingIndicatorTheme();

  /// containerWidth.

  final double containerWidth;

  /// containerHeight.
  final double containerHeight;

  /// activeIndicatorSize.
  final double activeIndicatorSize;

  /// Shape of the loading indicator container.
  ///
  /// Spec default is a circle ([CircleBorder]).
  final ShapeBorder containerShape;

  /// Spec minimum outer size (dp).
  static const double minSize = 24;

  /// Spec maximum outer size (dp).
  static const double maxSize = 240;

  /// Spec outer size at the default scale (dp).
  static const double defaultOuterSize = 48;

  /// Spec active / shape size at the default scale (dp).
  static const double defaultActiveSize = 38;

  /// Active-to-outer ratio (`38 / 48`) preserved when scaling via [resolveActiveSize].
  static const double activeToOuterRatio = defaultActiveSize / defaultOuterSize;

  /// Active indicator size for an outer edge of [outer], preserving the
  /// 38:48 spec ratio.
  static double resolveActiveSize(double outer) => outer * activeToOuterRatio;

  /// Full 360° continuous spin period.
  final Duration globalRotationDuration;

  /// Delay between polygon morph cycles.
  final Duration morphInterval;

  /// Extra rotation (degrees) applied across each morph transition.
  ///
  /// Spec default was 90; a lower value eases the whip at morph time.
  final double morphRotationDegrees;

  /// Spring driving morph progress `0 → 1`.
  final MorphSpring morphSpring;

  /// Initial velocity for the morph spring.
  final double morphSpringVelocity;

  /// Scale at the start of each morph-in pulse (`→ 1`).
  ///
  /// Values above `1` expand outward then settle down; below `1` shrink inward.
  final double pulseStartScale;

  /// Spring for the morph-in scale pulse settle.
  final MorphSpring pulseSpring;

  /// Initial velocity for the pulse spring (0 = smooth settle).
  final double pulseSpringVelocity;

  /// Legacy rounded container radius accessor.
  ///
  /// Prefer [containerShape] for new code.
  BorderRadius get containerRadius => BorderRadius.circular(999);

  /// activeColor.

  Color activeColor(MorphColorScheme scheme) => scheme.primary;

  /// containerColorDefault.

  Color containerColorDefault() => const Color(0x00000000);

  /// containedContainerColor.

  Color containedContainerColor(MorphColorScheme scheme) =>
      scheme.primaryContainer;

  /// containedActiveColor.

  Color containedActiveColor(MorphColorScheme scheme) =>
      scheme.onPrimaryContainer;

  /// resolveActiveColor.

  Color resolveActiveColor(
    MorphColorScheme scheme,
    MorphLoadingIndicatorVariant variant,
  ) {
    return switch (variant) {
      MorphLoadingIndicatorVariant.defaultStyle => activeColor(scheme),
      MorphLoadingIndicatorVariant.contained => containedActiveColor(scheme),
    };
  }

  /// resolveContainerColor.

  Color resolveContainerColor(
    MorphColorScheme scheme,
    MorphLoadingIndicatorVariant variant,
  ) {
    return switch (variant) {
      MorphLoadingIndicatorVariant.defaultStyle => containerColorDefault(),
      MorphLoadingIndicatorVariant.contained => containedContainerColor(scheme),
    };
  }

  @override
  MorphLoadingIndicatorTheme copyWith({
    double? containerWidth,
    double? containerHeight,
    double? activeIndicatorSize,
    ShapeBorder? containerShape,
    Duration? globalRotationDuration,
    Duration? morphInterval,
    double? morphRotationDegrees,
    MorphSpring? morphSpring,
    double? morphSpringVelocity,
    double? pulseStartScale,
    MorphSpring? pulseSpring,
    double? pulseSpringVelocity,
  }) {
    return MorphLoadingIndicatorTheme(
      containerWidth: containerWidth ?? this.containerWidth,
      containerHeight: containerHeight ?? this.containerHeight,
      activeIndicatorSize: activeIndicatorSize ?? this.activeIndicatorSize,
      containerShape: containerShape ?? this.containerShape,
      globalRotationDuration:
          globalRotationDuration ?? this.globalRotationDuration,
      morphInterval: morphInterval ?? this.morphInterval,
      morphRotationDegrees: morphRotationDegrees ?? this.morphRotationDegrees,
      morphSpring: morphSpring ?? this.morphSpring,
      morphSpringVelocity: morphSpringVelocity ?? this.morphSpringVelocity,
      pulseStartScale: pulseStartScale ?? this.pulseStartScale,
      pulseSpring: pulseSpring ?? this.pulseSpring,
      pulseSpringVelocity: pulseSpringVelocity ?? this.pulseSpringVelocity,
    );
  }

  @override
  MorphLoadingIndicatorTheme lerp(MorphLoadingIndicatorTheme? other, double t) {
    if (other is! MorphLoadingIndicatorTheme) {
      return this;
    }
    return MorphLoadingIndicatorTheme(
      containerWidth: _lerpDouble(containerWidth, other.containerWidth, t)!,
      containerHeight: _lerpDouble(containerHeight, other.containerHeight, t)!,
      activeIndicatorSize: _lerpDouble(
        activeIndicatorSize,
        other.activeIndicatorSize,
        t,
      )!,
      containerShape: ShapeBorder.lerp(
        containerShape,
        other.containerShape,
        t,
      )!,
      globalRotationDuration: t < 0.5
          ? globalRotationDuration
          : other.globalRotationDuration,
      morphInterval: t < 0.5 ? morphInterval : other.morphInterval,
      morphRotationDegrees: _lerpDouble(
        morphRotationDegrees,
        other.morphRotationDegrees,
        t,
      )!,
      morphSpring: t < 0.5 ? morphSpring : other.morphSpring,
      morphSpringVelocity: _lerpDouble(
        morphSpringVelocity,
        other.morphSpringVelocity,
        t,
      )!,
      pulseStartScale: _lerpDouble(pulseStartScale, other.pulseStartScale, t)!,
      pulseSpring: t < 0.5 ? pulseSpring : other.pulseSpring,
      pulseSpringVelocity: _lerpDouble(
        pulseSpringVelocity,
        other.pulseSpringVelocity,
        t,
      )!,
    );
  }

  double? _lerpDouble(double a, double b, double t) => a + (b - a) * t;
}
