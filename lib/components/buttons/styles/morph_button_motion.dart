import 'package:flutter/widgets.dart';
import 'package:morph_expressive/morph_components.dart' show MorphButton;
import 'package:motor/motor.dart';

import '../../../foundations/interaction/morph_motion.dart';

/// Spring-based motion configuration for [MorphButton].
@immutable
class MorphButtonMotion {
  /// stiffness.
  final double stiffness;

  /// damping.
  final double damping;

  /// MorphButtonMotion.

  const MorphButtonMotion({required this.stiffness, required this.damping});

  /// standard.

  static const MorphButtonMotion standard = MorphButtonMotion(
    stiffness: 1150,
    damping: 0.82,
  );

  /// standardOverflow.

  static const MorphButtonMotion standardOverflow = MorphButtonMotion(
    stiffness: 1150,
    damping: 0.88,
  );

  /// standardPopup.

  static const MorphButtonMotion standardPopup = MorphButtonMotion(
    stiffness: 1450,
    damping: 0.92,
  );

  /// expressiveEffectsFast.

  static const MorphButtonMotion expressiveEffectsFast = MorphButtonMotion(
    stiffness: 3800,
    damping: 1,
  );

  /// Usa el mismo resorte espacial de la fundacion Morph.
  static const MorphButtonMotion expressiveSpatialDefault = MorphButtonMotion(
    stiffness: 720,
    damping: 0.88,
  );

  /// Interactive press/release morph — same recipe as floating toolbar / FAB menu.
  static const MorphButtonMotion expressiveSpatialPress = MorphButtonMotion(
    stiffness: 1050,
    damping: 0.85,
  );

  /// Morph de forma con overshoot sutil, igual que buttonMorph.
  static const MorphButtonMotion shapeMorph = MorphButtonMotion(
    stiffness: 1150,
    damping: 0.82,
  );

  /// standardSpatialFast.

  static const MorphButtonMotion standardSpatialFast = MorphButtonMotion(
    stiffness: 1400,
    damping: 0.9,
  );

  /// custom.

  factory MorphButtonMotion.custom(double stiffness, double damping) {
    return MorphButtonMotion(stiffness: stiffness, damping: damping);
  }

  /// Converts this configuration to a [SpringMotion].
  SpringMotion toMotion() => MorphMotion.springMotion(
    MorphSpring(stiffness: stiffness, damping: damping),
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MorphButtonMotion &&
          stiffness == other.stiffness &&
          damping == other.damping;

  @override
  int get hashCode => Object.hash(stiffness, damping);
}
