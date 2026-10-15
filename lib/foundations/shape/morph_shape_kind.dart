import 'morph_material_new_shapes_bridge.dart';

/// Catalog of Material 3 Expressive morph polygons for clipping and fill.
enum MorphShapeKind {
  /// Circle.
  circle,

  /// Rounded square.
  square,

  /// Slanted square.
  slanted,

  /// Arch.
  arch,

  /// Semi-circle.
  semiCircle,

  /// Oval.
  oval,

  /// Pill.
  pill,

  /// Triangle.
  triangle,

  /// Arrow.
  arrow,

  /// Fan.
  fan,

  /// Diamond.
  diamond,

  /// Clam shell.
  clamShell,

  /// Pentagon.
  pentagon,

  /// Gem.
  gem,

  /// Sunny.
  sunny,

  /// Very sunny.
  verySunny,

  /// Four-sided cookie.
  cookie4Sided,

  /// Six-sided cookie.
  cookie6Sided,

  /// Seven-sided cookie.
  cookie7Sided,

  /// Nine-sided cookie.
  cookie9Sided,

  /// Twelve-sided cookie.
  cookie12Sided,

  /// Four-leaf clover.
  clover4Leaf,

  /// Eight-leaf clover.
  clover8Leaf,

  /// Burst.
  burst,

  /// Soft burst.
  softBurst,

  /// Boom.
  boom,

  /// Soft boom.
  softBoom,

  /// Flower.
  flower,

  /// Puffy.
  puffy,

  /// Puffy diamond.
  puffyDiamond,

  /// Ghostish.
  ghostish,

  /// Pixel circle.
  pixelCircle,

  /// Pixel triangle.
  pixelTriangle,

  /// Bun.
  bun,

  /// Heart.
  heart;

  /// Every catalog entry, in declaration order.
  static List<MorphShapeKind> get all => values;

  /// Morph polygon for this kind.
  RoundedPolygon get polygon {
    return switch (this) {
      MorphShapeKind.circle => MorphMaterialNewShapes.circle,
      MorphShapeKind.square => MorphMaterialNewShapes.square,
      MorphShapeKind.slanted => MorphMaterialNewShapes.slanted,
      MorphShapeKind.arch => MorphMaterialNewShapes.arch,
      MorphShapeKind.semiCircle => MorphMaterialNewShapes.semiCircle,
      MorphShapeKind.oval => MorphMaterialNewShapes.oval,
      MorphShapeKind.pill => MorphMaterialNewShapes.pill,
      MorphShapeKind.triangle => MorphMaterialNewShapes.triangle,
      MorphShapeKind.arrow => MorphMaterialNewShapes.arrow,
      MorphShapeKind.fan => MorphMaterialNewShapes.fan,
      MorphShapeKind.diamond => MorphMaterialNewShapes.diamond,
      MorphShapeKind.clamShell => MorphMaterialNewShapes.clamShell,
      MorphShapeKind.pentagon => MorphMaterialNewShapes.pentagon,
      MorphShapeKind.gem => MorphMaterialNewShapes.gem,
      MorphShapeKind.sunny => MorphMaterialNewShapes.sunny,
      MorphShapeKind.verySunny => MorphMaterialNewShapes.verySunny,
      MorphShapeKind.cookie4Sided => MorphMaterialNewShapes.cookie4Sided,
      MorphShapeKind.cookie6Sided => MorphMaterialNewShapes.cookie6Sided,
      MorphShapeKind.cookie7Sided => MorphMaterialNewShapes.cookie7Sided,
      MorphShapeKind.cookie9Sided => MorphMaterialNewShapes.cookie9Sided,
      MorphShapeKind.cookie12Sided => MorphMaterialNewShapes.cookie12Sided,
      MorphShapeKind.clover4Leaf => MorphMaterialNewShapes.clover4Leaf,
      MorphShapeKind.clover8Leaf => MorphMaterialNewShapes.clover8Leaf,
      MorphShapeKind.burst => MorphMaterialNewShapes.burst,
      MorphShapeKind.softBurst => MorphMaterialNewShapes.softBurst,
      MorphShapeKind.boom => MorphMaterialNewShapes.boom,
      MorphShapeKind.softBoom => MorphMaterialNewShapes.softBoom,
      MorphShapeKind.flower => MorphMaterialNewShapes.flower,
      MorphShapeKind.puffy => MorphMaterialNewShapes.puffy,
      MorphShapeKind.puffyDiamond => MorphMaterialNewShapes.puffyDiamond,
      MorphShapeKind.ghostish => MorphMaterialNewShapes.ghostish,
      MorphShapeKind.pixelCircle => MorphMaterialNewShapes.pixelCircle,
      MorphShapeKind.pixelTriangle => MorphMaterialNewShapes.pixelTriangle,
      MorphShapeKind.bun => MorphMaterialNewShapes.bun,
      MorphShapeKind.heart => MorphMaterialNewShapes.heart,
    };
  }
}
