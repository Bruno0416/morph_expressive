import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

import '../theme/morph_theme.dart';
import 'geometry/morph_shape.dart';
import 'morph_edge_coverage.dart';
import 'morph_contour_path.dart';

/// Normalizes a rotation to `[0, 2π)` for evaluation only (the animation phase
/// is never reset). Values within 1e-9 rad of a full turn or of an exact
/// quarter turn snap to it, so `rotate(2π)` (whose sine is ~-2.4e-16) paints
/// exactly like `rotate(0)` instead of taking a skewed, near-identity path.
double normalizeMorphRotation(double radians) {
  const turn = 2 * 3.141592653589793;
  var r = radians % turn;
  if (r < 0) r += turn;
  const eps = 1e-9;
  for (var q = 0; q <= 4; q++) {
    final target = q * turn / 4;
    if ((r - target).abs() < eps) return q == 4 ? 0 : target;
  }
  return r;
}

enum MorphShapeRenderer { canvas, shader, auto }

/// The actual renderer, not merely the requested preference.
class MorphShapeRenderStatus {
  const MorphShapeRenderStatus(this.effective, this.reason);
  final MorphShapeRenderer effective;
  final String? reason;
}

/// Draws one contour, without interactive semantics. Canvas is the reference.
/// A Shader request is best-effort and always has a working Canvas fallback.
class MorphShapeView extends StatefulWidget {
  const MorphShapeView({
    super.key,
    required this.shape,
    this.targetShape,
    this.progress = 0,
    this.contour,
    this.rotationRadians = 0,
    this.size = const Size(120, 120),
    this.color,
    this.gradient,
    this.renderer = MorphShapeRenderer.canvas,
    this.edgeAntialias = MorphEdgeAntialias.auto,
    this.onRendererChanged,
  });
  final MorphShape shape;
  final MorphShape? targetShape;
  final double progress;

  /// A captured/interpolated contour overrides the definitions and disables GPU.
  final MorphContour? contour;
  final double rotationRadians;
  final Size size;
  final Color? color;
  final Gradient? gradient;
  final MorphShapeRenderer renderer;

  /// Edge coverage policy of the Canvas path; the Shader path is analytic.
  final MorphEdgeAntialias edgeAntialias;
  final ValueChanged<MorphShapeRenderStatus>? onRendererChanged;
  @override
  State<MorphShapeView> createState() => _MorphShapeViewState();
}

class _MorphShapeViewState extends State<MorphShapeView> {
  static ui.FragmentProgram? _compiledProgram;
  ui.FragmentShader? _shader;
  bool _loading = false;
  String? _failure;
  MorphPreparedGeometry? _prepared;
  String? _lastStatus;
  @override
  void initState() {
    super.initState();
    _prepare();
  }

  @override
  void didUpdateWidget(MorphShapeView old) {
    super.didUpdateWidget(old);
    if (old.shape != widget.shape || old.targetShape != widget.targetShape) {
      _prepare();
    }
  }

  void _prepare() {
    _prepared = widget.targetShape == null
        ? null
        : const MorphGeometryEngine().prepare(
            widget.shape.contour,
            widget.targetShape!.contour,
          );
  }

  bool get _supported =>
      widget.contour == null &&
      widget.gradient == null &&
      widget.shape.ellipseRadii != null &&
      (widget.targetShape == null || widget.targetShape!.ellipseRadii != null);
  Future<void> _load() async {
    if (_loading || _shader != null || _failure != null) return;
    _loading = true;
    try {
      // Never cache a pending Future (it may belong to a dead zone).
      final program = _compiledProgram ?? await _loadProgram();
      _compiledProgram = program;
      if (mounted) setState(() => _shader = program.fragmentShader());
    } catch (error) {
      if (mounted) setState(() => _failure = 'shader load failed: $error');
    }
  }

  static Future<ui.FragmentProgram> _loadProgram() async {
    try {
      return await ui.FragmentProgram.fromAsset(
        'packages/morph_expressive/shaders/morph_ellipse.frag',
      );
    } catch (_) {
      // The package itself is the root application in its own test harness.
      return ui.FragmentProgram.fromAsset('shaders/morph_ellipse.frag');
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
  Widget build(BuildContext context) {
    if (!widget.progress.isFinite ||
        !widget.rotationRadians.isFinite ||
        !widget.size.width.isFinite ||
        !widget.size.height.isFinite ||
        widget.size.width <= 0 ||
        widget.size.height <= 0) {
      throw ArgumentError('Invalid shape view parameters');
    }
    final requested = widget.renderer != MorphShapeRenderer.canvas;
    if (requested && _supported) _load();
    final useShader = requested && _supported && _shader != null;
    _report(
      MorphShapeRenderStatus(
        useShader ? MorphShapeRenderer.shader : MorphShapeRenderer.canvas,
        !requested
            ? null
            : !_supported
            ? 'unsupported shape, transition, captured contour or gradient'
            : _failure ?? (!useShader ? 'shader loading' : null),
      ),
    );
    final contour =
        widget.contour ??
        _prepared?.at(widget.progress) ??
        widget.shape.contour;
    final radii = useShader
        ? Offset.lerp(
            widget.shape.ellipseRadii!,
            widget.targetShape?.ellipseRadii ?? widget.shape.ellipseRadii!,
            widget.progress.clamp(0.0, 1.0),
          )
        : null;
    final color = widget.color ?? MorphTheme.of(context).colorScheme.primary;
    final dpr = MediaQuery.maybeDevicePixelRatioOf(context) ?? 1;
    return SizedBox.fromSize(
      size: widget.size,
      child: CustomPaint(
        painter: _ShapePainter(
          contour: contour,
          rotation: widget.rotationRadians,
          color: color,
          gradient: widget.gradient,
          shader: useShader ? _shader : null,
          radii: radii,
          dpr: dpr,
          mode: widget.edgeAntialias,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _shader?.dispose();
    super.dispose();
  }
}

class _ShapePainter extends CustomPainter {
  _ShapePainter({
    required this.contour,
    required this.rotation,
    required this.color,
    this.gradient,
    this.shader,
    this.radii,
    required this.dpr,
    required this.mode,
  });
  final MorphContour contour;
  final double rotation, dpr;
  final MorphEdgeAntialias mode;
  final Color color;
  final Gradient? gradient;
  final ui.FragmentShader? shader;
  final Offset? radii;
  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.rotate(normalizeMorphRotation(rotation));
    canvas.translate(-size.width / 2, -size.height / 2);
    final rect = Offset.zero & size;
    if (shader case final s?) {
      final values = [
        size.width,
        size.height,
        radii!.dx * size.width,
        radii!.dy * size.height,
        color.r * color.a,
        color.g * color.a,
        color.b * color.a,
        color.a,
        dpr,
      ];
      for (var i = 0; i < values.length; i++) {
        s.setFloat(i, values[i]);
      }
      // Antialiased edge pixels fall outside the ellipse's own bounds; a
      // tight rect would clip them (flat or uneven extremes, worse under a
      // near-identity transform such as rotate(2π)).
      canvas.drawRect(rect.inflate(2), Paint()..shader = s);
    } else {
      MorphEdgeCoverage.draw(
        canvas,
        morphContourPath(contour, size),
        Paint()
          ..color = color
          ..shader = gradient?.createShader(rect),
        mode: mode,
        pixelRatio: dpr,
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_ShapePainter old) =>
      contour != old.contour ||
      rotation != old.rotation ||
      color != old.color ||
      gradient != old.gradient ||
      shader != old.shader ||
      radii != old.radii ||
      dpr != old.dpr ||
      mode != old.mode;
}
