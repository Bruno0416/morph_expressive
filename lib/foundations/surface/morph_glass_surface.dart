import 'dart:ui' show ImageFilter, TileMode;

import 'package:flutter/widgets.dart';

import '../theme/morph_theme.dart';
import '../tokens/morph_elevation.dart';
import 'morph_surface_glass.dart';

/// How the frosted tint derives from the host surface's semantic color.
enum MorphGlassTintMode {
  /// Multiply the base color alpha by [MorphSurfaceGlass.tintOpacity].
  multiply,

  /// Use [MorphSurfaceGlass.tintOpacity] directly as the fill alpha.
  alpha,

  /// Paint the tint at full strength (opt-in for gradient surfaces).
  raw,
}

/// Shared frosted-glass renderer for Morph floating surfaces.
///
/// Wraps the interactive [child] with a blurred, tinted backdrop clipped
/// exactly to the surface shape. The elevation shadow is painted outside the
/// clip so it is never cropped, and the child content (text, icons, ink
/// splashes) is never blurred.
///
/// This is an internal building block for Morph widgets that expose a
/// `MorphSurfaceGlass? glass` parameter; applications configure the effect
/// through those widgets or through [MorphThemeData.floatingSurfaceGlass].
class MorphGlassSurface extends StatelessWidget {
  /// Paints a frosted backdrop behind [child] and clips it to the surface.
  const MorphGlassSurface({
    required this.glass,
    required this.baseColor,
    required this.child,
    this.shape,
    this.borderRadius,
    this.elevation = 0,
    this.shadowColor,
    this.tintMode = MorphGlassTintMode.multiply,
    super.key,
  }) : assert(
         (shape == null) != (borderRadius == null),
         'Provide exactly one of shape or borderRadius',
       );

  /// Effective frosted configuration; must be enabled.
  final MorphSurfaceGlass glass;

  /// Semantic background color of the host surface, used whenever
  /// [MorphSurfaceGlass.tint] is null and as the opaque high-contrast fill.
  final Color baseColor;

  /// Interactive content painted above the frosted backdrop, never blurred.
  final Widget child;

  /// Surface outline. Provide exactly one of [shape] or [borderRadius].
  final ShapeBorder? shape;
  final BorderRadius? borderRadius;

  /// Elevation level used to size the outer drop shadow (see [MorphElevation]).
  /// Callers must keep their own Material/DecoratedBox color transparent so
  /// the backdrop stays visible; this renderer paints the shadow instead.
  final double elevation;

  /// Color of the elevation shadow, typically the theme scheme shadow.
  final Color? shadowColor;

  /// How the tint color derives from [baseColor].
  final MorphGlassTintMode tintMode;

  /// Resolves the effective frosted configuration for a surface.
  ///
  /// Returns null when the surface must keep its original opaque paint:
  /// no local configuration, no theme-level
  /// [MorphThemeData.floatingSurfaceGlass], or an explicit
  /// [MorphSurfaceGlass.disabled] override. A local value wins over the
  /// theme, and a disabled local value beats an active global configuration.
  static MorphSurfaceGlass? resolve(
    BuildContext context,
    MorphSurfaceGlass? local,
  ) {
    final MorphSurfaceGlass? glass =
        local ?? MorphTheme.of(context).floatingSurfaceGlass;
    if (glass == null || !glass.enabled) {
      return null;
    }
    return glass;
  }

  ShapeBorder get _surfaceShape =>
      shape ?? RoundedRectangleBorder(borderRadius: borderRadius!);

  /// Computed tint fill color for the given base color.
  Color tintFor(Color base) {
    final Color source = glass.tint ?? base;
    return switch (tintMode) {
      MorphGlassTintMode.multiply => source.withValues(
        alpha: base.a * glass.tintOpacity,
      ),
      MorphGlassTintMode.alpha => source.withValues(alpha: glass.tintOpacity),
      MorphGlassTintMode.raw => source,
    };
  }

  @override
  Widget build(BuildContext context) {
    assert(glass.enabled, 'Render MorphGlassSurface only for enabled glass');
    final TextDirection? direction = Directionality.maybeOf(context);
    final bool opaque =
        glass.opaqueInHighContrast && MediaQuery.highContrastOf(context);
    final ShapeBorder surfaceShape = _surfaceShape;
    final Color fill = opaque ? baseColor : tintFor(baseColor);
    final Color? borderColor = opaque ? null : glass.borderColor;
    final bool showBorder = borderColor != null && glass.borderWidth > 0;

    Widget backdrop = CustomPaint(
      painter: _GlassFillPainter(
        shape: surfaceShape,
        textDirection: direction,
        fill: fill,
      ),
    );
    if (!opaque && glass.wantsBlur) {
      backdrop = glass.boundedBlur
          ? BackdropFilter(
              filterConfig: ImageFilterConfig.blur(
                sigmaX: glass.blurX,
                sigmaY: glass.blurY,
                tileMode: TileMode.clamp,
                bounded: true,
              ),
              blendMode: glass.blendMode,
              child: backdrop,
            )
          : BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: glass.blurX,
                sigmaY: glass.blurY,
              ),
              blendMode: glass.blendMode,
              child: backdrop,
            );
    }

    Widget surface = ClipPath(
      clipper: ShapeBorderClipper(
        shape: surfaceShape,
        textDirection: direction,
      ),
      child: Stack(
        fit: StackFit.passthrough,
        children: [
          // One raster boundary for the blurred backdrop; the child keeps the
          // original hit testing, ink, focus and semantics behavior.
          Positioned.fill(child: RepaintBoundary(child: backdrop)),
          child,
          if (showBorder)
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: _GlassBorderPainter(
                    shape: surfaceShape,
                    textDirection: direction,
                    borderColor: borderColor,
                    borderWidth: glass.borderWidth,
                  ),
                ),
              ),
            ),
        ],
      ),
    );

    // Frosted surfaces do not draw elevation shadows to avoid darkening
    // and contaminating the blurred backdrop. The blur + tint + border
    // provide sufficient visual separation.
    // When frosted is disabled, callers use their original shadow drawing.
    return surface;
  }
}

class _GlassFillPainter extends CustomPainter {
  const _GlassFillPainter({
    required this.shape,
    required this.textDirection,
    required this.fill,
  });

  final ShapeBorder shape;
  final TextDirection? textDirection;
  final Color fill;

  @override
  void paint(Canvas canvas, Size size) {
    final Path path = shape.getOuterPath(
      Offset.zero & size,
      textDirection: textDirection,
    );
    // Fill even at alpha 0 so the backdrop filter keeps a full region.
    canvas.drawPath(path, Paint()..color = fill);
  }

  @override
  bool shouldRepaint(_GlassFillPainter oldDelegate) {
    return oldDelegate.shape != shape ||
        oldDelegate.textDirection != textDirection ||
        oldDelegate.fill != fill;
  }
}

class _GlassBorderPainter extends CustomPainter {
  const _GlassBorderPainter({
    required this.shape,
    required this.textDirection,
    required this.borderColor,
    required this.borderWidth,
  });

  final ShapeBorder shape;
  final TextDirection? textDirection;
  final Color? borderColor;
  final double borderWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final Color? color = borderColor;
    if (color == null || borderWidth <= 0) {
      return;
    }
    final Path path = shape.getOuterPath(
      Offset.zero & size,
      textDirection: textDirection,
    );
    // The surrounding clip cuts the outer half of the stroke, so double the
    // width to land on the requested thickness inside the surface edge.
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = borderWidth * 2,
    );
  }

  @override
  bool shouldRepaint(_GlassBorderPainter oldDelegate) {
    return oldDelegate.shape != shape ||
        oldDelegate.textDirection != textDirection ||
        oldDelegate.borderColor != borderColor ||
        oldDelegate.borderWidth != borderWidth;
  }
}
