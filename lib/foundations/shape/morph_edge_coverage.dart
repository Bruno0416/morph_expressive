import 'dart:ui'
    show BlendMode, Canvas, Color, Offset, Paint, PaintingStyle, Path;

/// Edge anti-aliasing policy for contours drawn through Canvas.
enum MorphEdgeAntialias {
  /// Currently [coverageSamples].
  auto,

  /// Plain `drawPath` with `Paint.isAntiAlias`. Fine on Skia and on Impeller
  /// backends with an MSAA window surface; binary edges on Impeller OpenGLES.
  native,

  /// Accumulate [MorphEdgeCoverage.sampleCount] sub-pixel shifted fills in a
  /// layer bounded to the contour, then colorize the summed coverage.
  coverageSamples,
}

/// Shared edge-coverage support for vector contours.
///
/// Finding (Linux, Impeller OpenGLESSDF, measured on screen): `drawPath` has
/// binary coverage even with `isAntiAlias = true`, and so do clips and a plain
/// `saveLayer` (a single AA fill inside a layer was identical). Only an
/// offscreen *image* probe showed partial alpha, so no probe can predict the
/// on-screen result. Accumulating eight sub-pixel shifted fills with additive
/// blending in a bounded layer yields 9 coverage levels there; fragment
/// shaders are unaffected. Cost: eight fills of the same path plus one layer
/// sized to the contour bounds (no images, no textures kept between frames).
class MorphEdgeCoverage {
  MorphEdgeCoverage._();

  /// Samples of the rotated-grid pattern; the 8 weights sum to exactly 255.
  static const int sampleCount = 8;
  static const List<Offset> _offsets = [
    Offset(-7 / 16, 3 / 16),
    Offset(-5 / 16, -5 / 16),
    Offset(-3 / 16, 7 / 16),
    Offset(-1 / 16, -1 / 16),
    Offset(1 / 16, 5 / 16),
    Offset(3 / 16, -7 / 16),
    Offset(5 / 16, 1 / 16),
    Offset(7 / 16, -3 / 16),
  ];
  static const List<int> _alphas = [32, 32, 32, 32, 32, 32, 32, 31];

  /// Draws [path] with [paint] (fill or stroke, solid color or shader).
  ///
  /// [pixelRatio] converts the physical sub-pixel pattern to logical units.
  /// [bleed] is the extra layer margin in logical pixels.
  static void draw(
    Canvas canvas,
    Path path,
    Paint paint, {
    required MorphEdgeAntialias mode,
    required double pixelRatio,
    double bleed = 2,
  }) {
    if (mode == MorphEdgeAntialias.native) {
      canvas.drawPath(path, paint..isAntiAlias = true);
      return;
    }
    var bounds = path.getBounds();
    if (paint.style == PaintingStyle.stroke) {
      bounds = bounds.inflate(paint.strokeWidth);
    }
    bounds = bounds.inflate(bleed + 1);
    canvas.saveLayer(bounds, Paint());
    final unit = 1 / (pixelRatio <= 0 ? 1 : pixelRatio);
    for (var i = 0; i < sampleCount; i++) {
      final shifted = path.shift(_offsets[i] * unit);
      canvas.drawPath(
        shifted,
        Paint()
          ..isAntiAlias = true
          ..style = paint.style
          ..strokeWidth = paint.strokeWidth
          ..strokeCap = paint.strokeCap
          ..strokeJoin = paint.strokeJoin
          ..blendMode = BlendMode.plus
          ..color = Color.fromARGB(_alphas[i], 255, 255, 255),
      );
    }
    // Colorize the accumulated coverage mask.
    final colorize = Paint()..blendMode = BlendMode.srcIn;
    if (paint.shader != null) {
      colorize.shader = paint.shader;
    } else {
      colorize.color = paint.color;
    }
    canvas.drawRect(bounds, colorize);
    canvas.restore();
  }
}
