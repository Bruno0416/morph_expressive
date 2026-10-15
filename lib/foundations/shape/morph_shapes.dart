import 'package:flutter/widgets.dart';

import '../tokens/morph_dimensions.dart';

/// Material 3 Expressive shape (corner radius) tokens.
///
/// The expressive shape scale extends the baseline scale with the
/// `largeIncreased`, `extraLargeIncreased` and `extraExtraLarge` steps used by
/// the new large components (FAB menu, toolbars, expressive buttons).
abstract final class MorphShapes {
  const MorphShapes._();

  /// 0dp — sharp corners.
  static const double none = MorphDimensions.radiusNone;

  /// 4dp corner radius.
  static const double extraSmall = MorphDimensions.radiusExtraSmall;

  /// 8dp corner radius.
  static const double small = MorphDimensions.radiusSmall;

  /// 12dp corner radius.
  static const double medium = MorphDimensions.radiusMedium;

  /// 16dp corner radius.
  static const double large = MorphDimensions.radiusLarge;

  /// 20dp corner radius (expressive large+).
  static const double largeIncreased = MorphDimensions.radiusLargeIncreased;

  /// 28dp corner radius.
  static const double extraLarge = MorphDimensions.radiusExtraLarge;

  /// 32dp corner radius (expressive XL+).
  static const double extraLargeIncreased =
      MorphDimensions.radiusExtraLargeIncreased;

  /// 48dp corner radius.
  static const double extraExtraLarge = MorphDimensions.radiusExtraExtraLarge;

  /// Sentinel radius that resolves to a fully rounded (stadium) shape.
  static const double full = MorphDimensions.radiusFull;

  /// [BorderRadius] for [none].
  static const BorderRadius radiusNone = MorphDimensions.borderRadiusNone;

  /// [BorderRadius] for [extraSmall].
  static const BorderRadius radiusExtraSmall =
      MorphDimensions.borderRadiusExtraSmall;

  /// [BorderRadius] for [small].
  static const BorderRadius radiusSmall = MorphDimensions.borderRadiusSmall;

  /// [BorderRadius] for [medium].
  static const BorderRadius radiusMedium = MorphDimensions.borderRadiusMedium;

  /// [BorderRadius] for [large].
  static const BorderRadius radiusLarge = MorphDimensions.borderRadiusLarge;

  /// [BorderRadius] for [largeIncreased].
  static const BorderRadius radiusLargeIncreased =
      MorphDimensions.borderRadiusLargeIncreased;

  /// [BorderRadius] for [extraLarge].
  static const BorderRadius radiusExtraLarge =
      MorphDimensions.borderRadiusExtraLarge;

  /// [BorderRadius] for [extraLargeIncreased].
  static const BorderRadius radiusExtraLargeIncreased =
      MorphDimensions.borderRadiusExtraLargeIncreased;

  /// [BorderRadius] for [extraExtraLarge].
  static const BorderRadius radiusExtraExtraLarge =
      MorphDimensions.borderRadiusExtraExtraLarge;

  /// Fully rounded stadium shape border.
  static const StadiumBorder stadium = StadiumBorder();

  /// Resolves a corner radius token to a [BorderRadius].
  ///
  /// The [full] sentinel produces a very large radius that reads as a stadium
  /// for any realistic component height.
  static BorderRadius resolve(double token) {
    return MorphDimensions.resolveRadius(token);
  }

  /// The expressive *round* shape set (mirrors `morph_design`'s round family).
  static const MorphShapeSet roundSet = MorphShapeSet(
    xs: BorderRadius.all(Radius.circular(999)),
    sm: BorderRadius.all(Radius.circular(20)),
    md: BorderRadius.all(Radius.circular(28)),
    lg: BorderRadius.all(Radius.circular(44)),
    xl: BorderRadius.all(Radius.circular(64)),
  );

  /// The expressive *square* shape set (mirrors `morph_design`'s square family).
  static const MorphShapeSet squareSet = MorphShapeSet(
    xs: BorderRadius.all(Radius.circular(6)),
    sm: BorderRadius.all(Radius.circular(8)),
    md: BorderRadius.all(Radius.circular(12)),
    lg: BorderRadius.all(Radius.circular(16)),
    xl: BorderRadius.all(Radius.circular(20)),
  );
}

/// A five-step [BorderRadius] scale for a single shape family.
///
/// Mirrors the `MorphShapeSet` from the `morph_design` package.
@immutable
class MorphShapeSet {
  /// Creates a five-step shape set.
  const MorphShapeSet({
    required this.xs,
    required this.sm,
    required this.md,
    required this.lg,
    required this.xl,
  });

  /// Extra-small corner radius in this family.
  final BorderRadius xs;

  /// Small corner radius in this family.
  final BorderRadius sm;

  /// Medium corner radius in this family.
  final BorderRadius md;

  /// Large corner radius in this family.
  final BorderRadius lg;

  /// Extra-large corner radius in this family.
  final BorderRadius xl;
}
