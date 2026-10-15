import 'package:flutter/widgets.dart';

import 'morph_shape_clipper.dart';
import 'morph_shape_kind.dart';

/// A box clipped to an [MorphShapeKind] polygon.
class MorphShapeContainer extends StatelessWidget {
  /// Creates a shaped container.
  const MorphShapeContainer({
    super.key,
    required this.kind,
    this.child,
    this.width,
    this.height,
    this.color,
    this.gradient,
    this.clipBehavior = Clip.antiAlias,
  });

  /// Circle.
  const MorphShapeContainer.circle({
    super.key,
    this.child,
    this.width,
    this.height,
    this.color,
    this.gradient,
    this.clipBehavior = Clip.antiAlias,
  }) : kind = MorphShapeKind.circle;

  /// Rounded square.
  const MorphShapeContainer.square({
    super.key,
    this.child,
    this.width,
    this.height,
    this.color,
    this.gradient,
    this.clipBehavior = Clip.antiAlias,
  }) : kind = MorphShapeKind.square;

  /// Slanted square.
  const MorphShapeContainer.slanted({
    super.key,
    this.child,
    this.width,
    this.height,
    this.color,
    this.gradient,
    this.clipBehavior = Clip.antiAlias,
  }) : kind = MorphShapeKind.slanted;

  /// Arch.
  const MorphShapeContainer.arch({
    super.key,
    this.child,
    this.width,
    this.height,
    this.color,
    this.gradient,
    this.clipBehavior = Clip.antiAlias,
  }) : kind = MorphShapeKind.arch;

  /// Semi-circle.
  const MorphShapeContainer.semiCircle({
    super.key,
    this.child,
    this.width,
    this.height,
    this.color,
    this.gradient,
    this.clipBehavior = Clip.antiAlias,
  }) : kind = MorphShapeKind.semiCircle;

  /// Oval.
  const MorphShapeContainer.oval({
    super.key,
    this.child,
    this.width,
    this.height,
    this.color,
    this.gradient,
    this.clipBehavior = Clip.antiAlias,
  }) : kind = MorphShapeKind.oval;

  /// Pill.
  const MorphShapeContainer.pill({
    super.key,
    this.child,
    this.width,
    this.height,
    this.color,
    this.gradient,
    this.clipBehavior = Clip.antiAlias,
  }) : kind = MorphShapeKind.pill;

  /// Triangle.
  const MorphShapeContainer.triangle({
    super.key,
    this.child,
    this.width,
    this.height,
    this.color,
    this.gradient,
    this.clipBehavior = Clip.antiAlias,
  }) : kind = MorphShapeKind.triangle;

  /// Arrow.
  const MorphShapeContainer.arrow({
    super.key,
    this.child,
    this.width,
    this.height,
    this.color,
    this.gradient,
    this.clipBehavior = Clip.antiAlias,
  }) : kind = MorphShapeKind.arrow;

  /// Fan.
  const MorphShapeContainer.fan({
    super.key,
    this.child,
    this.width,
    this.height,
    this.color,
    this.gradient,
    this.clipBehavior = Clip.antiAlias,
  }) : kind = MorphShapeKind.fan;

  /// Diamond.
  const MorphShapeContainer.diamond({
    super.key,
    this.child,
    this.width,
    this.height,
    this.color,
    this.gradient,
    this.clipBehavior = Clip.antiAlias,
  }) : kind = MorphShapeKind.diamond;

  /// Clam shell.
  const MorphShapeContainer.clamShell({
    super.key,
    this.child,
    this.width,
    this.height,
    this.color,
    this.gradient,
    this.clipBehavior = Clip.antiAlias,
  }) : kind = MorphShapeKind.clamShell;

  /// Pentagon.
  const MorphShapeContainer.pentagon({
    super.key,
    this.child,
    this.width,
    this.height,
    this.color,
    this.gradient,
    this.clipBehavior = Clip.antiAlias,
  }) : kind = MorphShapeKind.pentagon;

  /// Gem.
  const MorphShapeContainer.gem({
    super.key,
    this.child,
    this.width,
    this.height,
    this.color,
    this.gradient,
    this.clipBehavior = Clip.antiAlias,
  }) : kind = MorphShapeKind.gem;

  /// Sunny.
  const MorphShapeContainer.sunny({
    super.key,
    this.child,
    this.width,
    this.height,
    this.color,
    this.gradient,
    this.clipBehavior = Clip.antiAlias,
  }) : kind = MorphShapeKind.sunny;

  /// Very sunny.
  const MorphShapeContainer.verySunny({
    super.key,
    this.child,
    this.width,
    this.height,
    this.color,
    this.gradient,
    this.clipBehavior = Clip.antiAlias,
  }) : kind = MorphShapeKind.verySunny;

  /// Four-sided cookie.
  const MorphShapeContainer.cookie4Sided({
    super.key,
    this.child,
    this.width,
    this.height,
    this.color,
    this.gradient,
    this.clipBehavior = Clip.antiAlias,
  }) : kind = MorphShapeKind.cookie4Sided;

  /// Six-sided cookie.
  const MorphShapeContainer.cookie6Sided({
    super.key,
    this.child,
    this.width,
    this.height,
    this.color,
    this.gradient,
    this.clipBehavior = Clip.antiAlias,
  }) : kind = MorphShapeKind.cookie6Sided;

  /// Seven-sided cookie.
  const MorphShapeContainer.cookie7Sided({
    super.key,
    this.child,
    this.width,
    this.height,
    this.color,
    this.gradient,
    this.clipBehavior = Clip.antiAlias,
  }) : kind = MorphShapeKind.cookie7Sided;

  /// Nine-sided cookie.
  const MorphShapeContainer.cookie9Sided({
    super.key,
    this.child,
    this.width,
    this.height,
    this.color,
    this.gradient,
    this.clipBehavior = Clip.antiAlias,
  }) : kind = MorphShapeKind.cookie9Sided;

  /// Twelve-sided cookie.
  const MorphShapeContainer.cookie12Sided({
    super.key,
    this.child,
    this.width,
    this.height,
    this.color,
    this.gradient,
    this.clipBehavior = Clip.antiAlias,
  }) : kind = MorphShapeKind.cookie12Sided;

  /// Four-leaf clover.
  const MorphShapeContainer.clover4Leaf({
    super.key,
    this.child,
    this.width,
    this.height,
    this.color,
    this.gradient,
    this.clipBehavior = Clip.antiAlias,
  }) : kind = MorphShapeKind.clover4Leaf;

  /// Eight-leaf clover.
  const MorphShapeContainer.clover8Leaf({
    super.key,
    this.child,
    this.width,
    this.height,
    this.color,
    this.gradient,
    this.clipBehavior = Clip.antiAlias,
  }) : kind = MorphShapeKind.clover8Leaf;

  /// Burst.
  const MorphShapeContainer.burst({
    super.key,
    this.child,
    this.width,
    this.height,
    this.color,
    this.gradient,
    this.clipBehavior = Clip.antiAlias,
  }) : kind = MorphShapeKind.burst;

  /// Soft burst.
  const MorphShapeContainer.softBurst({
    super.key,
    this.child,
    this.width,
    this.height,
    this.color,
    this.gradient,
    this.clipBehavior = Clip.antiAlias,
  }) : kind = MorphShapeKind.softBurst;

  /// Boom.
  const MorphShapeContainer.boom({
    super.key,
    this.child,
    this.width,
    this.height,
    this.color,
    this.gradient,
    this.clipBehavior = Clip.antiAlias,
  }) : kind = MorphShapeKind.boom;

  /// Soft boom.
  const MorphShapeContainer.softBoom({
    super.key,
    this.child,
    this.width,
    this.height,
    this.color,
    this.gradient,
    this.clipBehavior = Clip.antiAlias,
  }) : kind = MorphShapeKind.softBoom;

  /// Flower.
  const MorphShapeContainer.flower({
    super.key,
    this.child,
    this.width,
    this.height,
    this.color,
    this.gradient,
    this.clipBehavior = Clip.antiAlias,
  }) : kind = MorphShapeKind.flower;

  /// Puffy.
  const MorphShapeContainer.puffy({
    super.key,
    this.child,
    this.width,
    this.height,
    this.color,
    this.gradient,
    this.clipBehavior = Clip.antiAlias,
  }) : kind = MorphShapeKind.puffy;

  /// Puffy diamond.
  const MorphShapeContainer.puffyDiamond({
    super.key,
    this.child,
    this.width,
    this.height,
    this.color,
    this.gradient,
    this.clipBehavior = Clip.antiAlias,
  }) : kind = MorphShapeKind.puffyDiamond;

  /// Ghostish.
  const MorphShapeContainer.ghostish({
    super.key,
    this.child,
    this.width,
    this.height,
    this.color,
    this.gradient,
    this.clipBehavior = Clip.antiAlias,
  }) : kind = MorphShapeKind.ghostish;

  /// Pixel circle.
  const MorphShapeContainer.pixelCircle({
    super.key,
    this.child,
    this.width,
    this.height,
    this.color,
    this.gradient,
    this.clipBehavior = Clip.antiAlias,
  }) : kind = MorphShapeKind.pixelCircle;

  /// Pixel triangle.
  const MorphShapeContainer.pixelTriangle({
    super.key,
    this.child,
    this.width,
    this.height,
    this.color,
    this.gradient,
    this.clipBehavior = Clip.antiAlias,
  }) : kind = MorphShapeKind.pixelTriangle;

  /// Bun.
  const MorphShapeContainer.bun({
    super.key,
    this.child,
    this.width,
    this.height,
    this.color,
    this.gradient,
    this.clipBehavior = Clip.antiAlias,
  }) : kind = MorphShapeKind.bun;

  /// Heart.
  const MorphShapeContainer.heart({
    super.key,
    this.child,
    this.width,
    this.height,
    this.color,
    this.gradient,
    this.clipBehavior = Clip.antiAlias,
  }) : kind = MorphShapeKind.heart;

  /// Polygon kind.
  final MorphShapeKind kind;

  /// Optional content inside the clip.
  final Widget? child;

  /// Explicit width.
  final double? width;

  /// Explicit height.
  final double? height;

  /// Fill color (ignored when [gradient] is set, except as a fallback).
  final Color? color;

  /// Fill gradient. Overrides [color] when both are set.
  final Gradient? gradient;

  /// Clip quality.
  final Clip clipBehavior;

  @override
  Widget build(BuildContext context) {
    Widget content = child ?? const SizedBox.expand();
    if (gradient != null) {
      content = DecoratedBox(
        decoration: BoxDecoration(color: color, gradient: gradient),
        child: content,
      );
    } else if (color != null) {
      content = ColoredBox(color: color!, child: content);
    }
    if (width != null || height != null) {
      content = SizedBox(width: width, height: height, child: content);
    }
    return ClipPath(
      clipper: MorphShapeClipper(kind),
      clipBehavior: clipBehavior,
      child: content,
    );
  }
}
