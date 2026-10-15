import 'package:flutter/widgets.dart';

import '../../../foundations/foundations.dart';

/// Springs and predictive-back amounts for a side sheet.
@immutable
class MorphSideSheetMotion {
  /// MorphSideSheetMotion.
  const MorphSideSheetMotion({
    this.enterSpring = MorphMotion.spatialDefault,
    this.scrimSpring = MorphMotion.effectsDefault,
    this.layoutSpring = MorphMotion.spatialDefault,
    this.settleSpring = MorphMotion.spatialDefault,
    this.predictiveBackShrinkX = 24,
    this.predictiveBackGrowX = 12,
    this.predictiveBackLiftY = 48,
    this.predictiveBackCornerRadius = 16,
  });

  /// Spring for opening and closing.
  final MorphSpring enterSpring;

  /// Spring for the scrim fade.
  final MorphSpring scrimSpring;

  /// Spring for modal / standard morphs and body resizing.
  final MorphSpring layoutSpring;

  /// Spring back after a cancelled predictive back.
  final MorphSpring settleSpring;

  /// Width lost when the back swipe moves away from the anchored edge (24).
  final double predictiveBackShrinkX;

  /// Width gained when the back swipe starts at the anchored edge (12).
  final double predictiveBackGrowX;

  /// Height lost at full progress, split above and below (48).
  final double predictiveBackLiftY;

  /// Corner radius on every corner at full progress (16).
  final double predictiveBackCornerRadius;

  /// Returns a copy with the given fields replaced.
  MorphSideSheetMotion copyWith({
    MorphSpring? enterSpring,
    MorphSpring? scrimSpring,
    MorphSpring? layoutSpring,
    MorphSpring? settleSpring,
    double? predictiveBackShrinkX,
    double? predictiveBackGrowX,
    double? predictiveBackLiftY,
    double? predictiveBackCornerRadius,
  }) {
    return MorphSideSheetMotion(
      enterSpring: enterSpring ?? this.enterSpring,
      scrimSpring: scrimSpring ?? this.scrimSpring,
      layoutSpring: layoutSpring ?? this.layoutSpring,
      settleSpring: settleSpring ?? this.settleSpring,
      predictiveBackShrinkX:
          predictiveBackShrinkX ?? this.predictiveBackShrinkX,
      predictiveBackGrowX: predictiveBackGrowX ?? this.predictiveBackGrowX,
      predictiveBackLiftY: predictiveBackLiftY ?? this.predictiveBackLiftY,
      predictiveBackCornerRadius:
          predictiveBackCornerRadius ?? this.predictiveBackCornerRadius,
    );
  }

  /// Interpolates between this and [other]; springs switch at the midpoint.
  MorphSideSheetMotion lerp(MorphSideSheetMotion other, double t) {
    final end = t < 0.5 ? this : other;
    return end.copyWith(
      predictiveBackShrinkX: _lerp(
        predictiveBackShrinkX,
        other.predictiveBackShrinkX,
        t,
      ),
      predictiveBackGrowX: _lerp(
        predictiveBackGrowX,
        other.predictiveBackGrowX,
        t,
      ),
      predictiveBackLiftY: _lerp(
        predictiveBackLiftY,
        other.predictiveBackLiftY,
        t,
      ),
      predictiveBackCornerRadius: _lerp(
        predictiveBackCornerRadius,
        other.predictiveBackCornerRadius,
        t,
      ),
    );
  }

  static double _lerp(double a, double b, double t) => a + (b - a) * t;
}
