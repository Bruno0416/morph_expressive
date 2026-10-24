import 'package:flutter/widgets.dart';

import '../../../foundations/foundations.dart';

/// Theme values for `MorphRefreshIndicator`.
@immutable
class MorphRefreshIndicatorTheme
    extends MorphThemeExtension<MorphRefreshIndicatorTheme> {
  /// Default resting top inset of the spinner (matches default indicator padding).
  static const double kDefaultDisplacement = 8;

  /// Default vertical gap above/below the spinner inside the list pad.
  static const double kDefaultIndicatorPadding = 8;

  /// kDefaultEdgeOffset.
  static const double kDefaultEdgeOffset = 0;

  /// kDefaultElevation.
  static const double kDefaultElevation = 0;

  /// kDragContainerExtentPercentage.
  static const double kDragContainerExtentPercentage = 0.25;

  /// kDragSizeFactorLimit.
  static const double kDragSizeFactorLimit = 1.5;

  /// Default release bubble spring (noticeable overshoot at rest).
  static const MorphSpring kDefaultReleaseBubbleSpring = MorphSpring(
    stiffness: 350,
    damping: 0.1,
  );

  /// Scale the bubble spring starts from before settling at 1.
  static const double kDefaultReleaseBubbleFromScale = 0.96;

  /// MorphRefreshIndicatorTheme.
  const MorphRefreshIndicatorTheme({
    this.defaultDisplacement = kDefaultDisplacement,
    this.defaultEdgeOffset = kDefaultEdgeOffset,
    this.defaultElevation = kDefaultElevation,
    this.dragContainerExtentPercentage = kDragContainerExtentPercentage,
    this.dragSizeFactorLimit = kDragSizeFactorLimit,
    this.indicatorSnapDuration = MorphMotion.short3,
    this.indicatorScaleDuration = MorphMotion.short4,
    this.releaseBubbleSpring = kDefaultReleaseBubbleSpring,
    this.releaseBubbleFromScale = kDefaultReleaseBubbleFromScale,
    this.settleSpring = MorphMotion.expressiveSpatialDefault,
  });

  /// defaults.
  static const MorphRefreshIndicatorTheme defaults =
      MorphRefreshIndicatorTheme();

  /// defaultDisplacement.
  final double defaultDisplacement;

  /// defaultEdgeOffset.
  final double defaultEdgeOffset;

  /// defaultElevation.
  final double defaultElevation;

  /// dragContainerExtentPercentage.
  final double dragContainerExtentPercentage;

  /// dragSizeFactorLimit.
  final double dragSizeFactorLimit;

  /// indicatorSnapDuration.
  final Duration indicatorSnapDuration;

  /// indicatorScaleDuration.
  final Duration indicatorScaleDuration;

  /// Spatial spring for the release scale bubble at the resting inset.
  final MorphSpring releaseBubbleSpring;

  /// Starting scale for the release bubble before it springs to 1.
  final double releaseBubbleFromScale;

  /// Spring for position / scale / content-pad settle after drag.
  final MorphSpring settleSpring;

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

  @override
  MorphRefreshIndicatorTheme copyWith({
    double? defaultDisplacement,
    double? defaultEdgeOffset,
    double? defaultElevation,
    double? dragContainerExtentPercentage,
    double? dragSizeFactorLimit,
    Duration? indicatorSnapDuration,
    Duration? indicatorScaleDuration,
    MorphSpring? releaseBubbleSpring,
    double? releaseBubbleFromScale,
    MorphSpring? settleSpring,
  }) {
    return MorphRefreshIndicatorTheme(
      defaultDisplacement: defaultDisplacement ?? this.defaultDisplacement,
      defaultEdgeOffset: defaultEdgeOffset ?? this.defaultEdgeOffset,
      defaultElevation: defaultElevation ?? this.defaultElevation,
      dragContainerExtentPercentage:
          dragContainerExtentPercentage ?? this.dragContainerExtentPercentage,
      dragSizeFactorLimit: dragSizeFactorLimit ?? this.dragSizeFactorLimit,
      indicatorSnapDuration:
          indicatorSnapDuration ?? this.indicatorSnapDuration,
      indicatorScaleDuration:
          indicatorScaleDuration ?? this.indicatorScaleDuration,
      releaseBubbleSpring: releaseBubbleSpring ?? this.releaseBubbleSpring,
      releaseBubbleFromScale:
          releaseBubbleFromScale ?? this.releaseBubbleFromScale,
      settleSpring: settleSpring ?? this.settleSpring,
    );
  }

  @override
  MorphRefreshIndicatorTheme lerp(MorphRefreshIndicatorTheme? other, double t) {
    if (other is! MorphRefreshIndicatorTheme) {
      return this;
    }
    return MorphRefreshIndicatorTheme(
      defaultDisplacement: _lerpDouble(
        defaultDisplacement,
        other.defaultDisplacement,
        t,
      )!,
      defaultEdgeOffset: _lerpDouble(
        defaultEdgeOffset,
        other.defaultEdgeOffset,
        t,
      )!,
      defaultElevation: _lerpDouble(
        defaultElevation,
        other.defaultElevation,
        t,
      )!,
      dragContainerExtentPercentage: _lerpDouble(
        dragContainerExtentPercentage,
        other.dragContainerExtentPercentage,
        t,
      )!,
      dragSizeFactorLimit: _lerpDouble(
        dragSizeFactorLimit,
        other.dragSizeFactorLimit,
        t,
      )!,
      indicatorSnapDuration: t < 0.5
          ? indicatorSnapDuration
          : other.indicatorSnapDuration,
      indicatorScaleDuration: t < 0.5
          ? indicatorScaleDuration
          : other.indicatorScaleDuration,
      releaseBubbleSpring: t < 0.5
          ? releaseBubbleSpring
          : other.releaseBubbleSpring,
      releaseBubbleFromScale: _lerpDouble(
        releaseBubbleFromScale,
        other.releaseBubbleFromScale,
        t,
      )!,
      settleSpring: t < 0.5 ? settleSpring : other.settleSpring,
    );
  }

  double? _lerpDouble(double a, double b, double t) => a + (b - a) * t;
}
