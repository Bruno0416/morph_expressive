import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

import 'morph_edge_coverage.dart';
import 'morph_shape_view.dart';

/// A filled rounded rectangle whose size and corner radius may change every
/// frame (a FAB turning into its close button, a pill into a circle).
///
/// [MorphShapeRenderer.shader] / [MorphShapeRenderer.auto] evaluate the exact
/// rounded-rectangle distance in a fragment shader (analytic coverage, no
/// layers). [MorphShapeRenderer.canvas] draws the equivalent `RRect` through
/// [MorphEdgeCoverage]. The Canvas path is the fallback while the shader loads
/// or fails, when a gradient is requested, and always remains available.
/// [onRendererChanged] reports the renderer actually used.
class MorphRoundedSurface extends StatefulWidget {
  const MorphRoundedSurface({
    super.key,
    required this.size,
    required this.radius,
    required this.color,
    this.gradient,
    this.side,
    this.outlineGradient,
    this.elevation = 0,
    this.shadowColor = const Color(0xff000000),
    this.renderer = MorphShapeRenderer.auto,
    this.edgeAntialias = MorphEdgeAntialias.auto,
    this.onRendererChanged,
    this.child,
  });

  final Size size;
  final double radius;
  final Color color;
  final Gradient? gradient;

  /// Optional outline drawn inside the edge (always on Canvas, over either
  /// fill renderer); [outlineGradient] replaces its color.
  final BorderSide? side;
  final Gradient? outlineGradient;
  final double elevation;
  final Color shadowColor;
  final MorphShapeRenderer renderer;
  final MorphEdgeAntialias edgeAntialias;
  final ValueChanged<MorphShapeRenderStatus>? onRendererChanged;
  final Widget? child;

  @override
  State<MorphRoundedSurface> createState() => _MorphRoundedSurfaceState();
}

class _MorphRoundedSurfaceState extends State<MorphRoundedSurface> {
  // Only the completed program is cached: a cached pending Future can belong
  // to a dead zone (tests, hot restarts) and would never complete.
  static ui.FragmentProgram? _program;
  ui.FragmentShader? _shader;
  String? _failure;
  bool _loading = false;
  String? _lastStatus;

  bool get _wantsShader =>
      widget.renderer != MorphShapeRenderer.canvas && widget.gradient == null;

  Future<void> _load() async {
    if (_loading || _shader != null || _failure != null) return;
    _loading = true;
    try {
      final program = _program ??= await _loadProgram();
      if (!mounted) return;
      setState(() => _shader = program.fragmentShader());
    } catch (error) {
      if (mounted) setState(() => _failure = 'shader load failed: $error');
    }
  }

  static Future<ui.FragmentProgram> _loadProgram() async {
    try {
      return await ui.FragmentProgram.fromAsset(
        'packages/morph_expressive/shaders/morph_rrect.frag',
      );
    } catch (_) {
      return ui.FragmentProgram.fromAsset('shaders/morph_rrect.frag');
    }
  }

  void _report(MorphShapeRenderStatus status) {
    final key = '${status.effective}:${status.reason}';
    if (key == _lastStatus) return;
    _lastStatus = key;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.onRendererChanged?.call(status);
    });
  }

  @override
  void dispose() {
    _shader?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_wantsShader) _load();
    final useShader = _wantsShader && _shader != null;
    _report(
      MorphShapeRenderStatus(
        useShader ? MorphShapeRenderer.shader : MorphShapeRenderer.canvas,
        widget.renderer == MorphShapeRenderer.canvas
            ? null
            : widget.gradient != null
            ? 'gradient fill uses Canvas'
            : _failure ?? (useShader ? null : 'shader loading'),
      ),
    );
    return CustomPaint(
      size: widget.size,
      painter: _RoundedSurfacePainter(
        size: widget.size,
        radius: widget.radius,
        color: widget.color,
        gradient: widget.gradient,
        side: widget.side,
        outlineGradient: widget.outlineGradient,
        elevation: widget.elevation,
        shadowColor: widget.shadowColor,
        shader: useShader ? _shader : null,
        mode: widget.edgeAntialias,
        dpr: MediaQuery.maybeDevicePixelRatioOf(context) ?? 1,
      ),
      child: widget.child,
    );
  }
}

class _RoundedSurfacePainter extends CustomPainter {
  _RoundedSurfacePainter({
    required this.size,
    required this.radius,
    required this.color,
    required this.gradient,
    required this.side,
    required this.outlineGradient,
    required this.elevation,
    required this.shadowColor,
    required this.shader,
    required this.mode,
    required this.dpr,
  });
  final Size size;
  final double radius, elevation, dpr;
  final Color color, shadowColor;
  final Gradient? gradient, outlineGradient;
  final BorderSide? side;
  final ui.FragmentShader? shader;
  final MorphEdgeAntialias mode;

  @override
  void paint(Canvas canvas, Size canvasSize) {
    final rect = Offset.zero & size;
    final r = radius.clamp(0.0, size.shortestSide / 2).toDouble();
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(r));
    if (elevation > 0) {
      canvas.drawShadow(Path()..addRRect(rrect), shadowColor, elevation, true);
    }
    if (shader case final s?) {
      final values = [
        size.width,
        size.height,
        r,
        color.r * color.a,
        color.g * color.a,
        color.b * color.a,
        color.a,
        dpr,
      ];
      for (var i = 0; i < values.length; i++) {
        s.setFloat(i, values[i]);
      }
      // Inflated so antialiased edge pixels are not clipped by the rect.
      canvas.drawRect(rect.inflate(2), Paint()..shader = s);
    } else {
      MorphEdgeCoverage.draw(
        canvas,
        Path()..addRRect(rrect),
        Paint()
          ..color = color
          ..shader = gradient?.createShader(rect),
        mode: mode,
        pixelRatio: dpr,
      );
    }
    final s = side;
    if (s != null && s.width > 0 && s.style != BorderStyle.none) {
      final inset = rrect.deflate(s.width / 2);
      MorphEdgeCoverage.draw(
        canvas,
        Path()..addRRect(inset),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = s.width
          ..color = s.color
          ..shader = outlineGradient?.createShader(rect),
        mode: mode,
        pixelRatio: dpr,
      );
    }
  }

  @override
  bool shouldRepaint(_RoundedSurfacePainter old) =>
      size != old.size ||
      radius != old.radius ||
      color != old.color ||
      gradient != old.gradient ||
      side != old.side ||
      outlineGradient != old.outlineGradient ||
      elevation != old.elevation ||
      shadowColor != old.shadowColor ||
      shader != old.shader ||
      mode != old.mode ||
      dpr != old.dpr;
}
