import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

import 'morph_chip_organic_surface.dart';

/// Paints the same harmonic stretch as MorphChip, oriented across movement.
/// A horizontal journey pinches height; a vertical journey pinches width.
/// No new animation curve is introduced: [progress] tracks the existing motion.
abstract final class MorphOrganicIndicatorPaint {
  static void paint(
    Canvas canvas, {
    required Rect rect,
    required Color color,
    required double radius,
    required double intensity,
    required double progress,
    required Axis axis,
    ui.FragmentShader? shader,
  }) {
    if (rect.isEmpty) return;
    final t = progress.clamp(0.0, 1.0).toDouble();
    final amount = intensity.clamp(0.0, 1.0).toDouble();
    final r = radius
        .clamp(0.0, math.min(rect.width, rect.height) * 0.5)
        .toDouble();
    final envelope = math.sin(math.pi * t);
    if (amount <= 0 || envelope <= 0.00001) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(r)),
        Paint()..color = color,
      );
      return;
    }
    if (shader != null) {
      shader
        ..setFloat(0, rect.width)
        ..setFloat(1, rect.height)
        ..setFloat(2, color.r)
        ..setFloat(3, color.g)
        ..setFloat(4, color.b)
        ..setFloat(5, color.a)
        ..setFloat(6, r)
        ..setFloat(7, 0.0)
        ..setFloat(8, t)
        ..setFloat(9, amount)
        ..setFloat(10, 0.0)
        ..setFloat(11, 0.0)
        ..setFloat(12, axis == Axis.vertical ? 1.0 : 0.0)
        ..setFloat(13, 0.5)
        ..setFloat(14, 0.5);
      canvas.save();
      canvas.translate(rect.left, rect.top);
      canvas.drawRect(Offset.zero & rect.size, Paint()..shader = shader);
      canvas.restore();
      return;
    }

    // CPU fallback follows the same cross-axis rule. In a vertically moving
    // horizontal capsule there is no straight section on its travel axis;
    // slightly scale its width to keep the response visible on web fallbacks.
    if (axis == Axis.vertical) {
      canvas.save();
      canvas.translate(rect.center.dx, rect.center.dy);
      canvas.scale(1.0 - 0.12 * amount * envelope, 1.0);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset.zero,
            width: rect.width,
            height: rect.height,
          ),
          Radius.circular(r),
        ),
        Paint()..color = color,
      );
      canvas.restore();
      return;
    }
    // Horizontal: preserve the rounded end caps, as in MorphChip.
    canvas.save();
    canvas.translate(rect.center.dx, rect.center.dy);
    if (axis == Axis.vertical) canvas.rotate(-math.pi / 2);
    final width = axis == Axis.horizontal ? rect.width : rect.height;
    final height = axis == Axis.horizontal ? rect.height : rect.width;
    final half = width * 0.5;
    final top = -height * 0.5;
    final bottom = height * 0.5;
    final straight = math.max(0.0, half - r);
    final pinch =
        height * 0.12 * amount * envelope * _smoothstep(0, 10, straight);
    if (straight <= 0.001 || pinch <= 0.00001) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset.zero, width: width, height: height),
          Radius.circular(r),
        ),
        Paint()..color = color,
      );
    } else {
      // Cubic top/bottom only; the two rounded ends are untouched.
      final path = Path()
        ..moveTo(-half + r, top)
        ..cubicTo(
          -straight * 0.4,
          top,
          -straight * 0.3,
          top + pinch,
          0,
          top + pinch,
        )
        ..cubicTo(
          straight * 0.3,
          top + pinch,
          straight * 0.4,
          top,
          half - r,
          top,
        )
        ..arcToPoint(Offset(half, top + r), radius: Radius.circular(r))
        ..lineTo(half, bottom - r)
        ..arcToPoint(Offset(half - r, bottom), radius: Radius.circular(r))
        ..cubicTo(
          straight * 0.4,
          bottom,
          straight * 0.3,
          bottom - pinch,
          0,
          bottom - pinch,
        )
        ..cubicTo(
          -straight * 0.3,
          bottom - pinch,
          -straight * 0.4,
          bottom,
          -half + r,
          bottom,
        )
        ..arcToPoint(Offset(-half, bottom - r), radius: Radius.circular(r))
        ..lineTo(-half, top + r)
        ..arcToPoint(Offset(-half + r, top), radius: Radius.circular(r))
        ..close();
      canvas.drawPath(path, Paint()..color = color);
    }
    canvas.restore();
  }

  static double _smoothstep(double a, double b, double x) {
    final t = ((x - a) / (b - a)).clamp(0.0, 1.0).toDouble();
    return t * t * (3 - 2 * t);
  }
}

/// A standalone surface for moving segmented selectors.
class MorphOrganicIndicatorSurface extends StatefulWidget {
  const MorphOrganicIndicatorSurface({
    super.key,
    required this.color,
    required this.radius,
    required this.intensity,
    required this.progress,
    this.axis = Axis.horizontal,
  }) : assert(intensity >= 0 && intensity <= 1);

  final Color color;
  final double radius;
  final double intensity;
  final double progress;
  final Axis axis;

  @override
  State<MorphOrganicIndicatorSurface> createState() =>
      _MorphOrganicIndicatorSurfaceState();
}

class _MorphOrganicIndicatorSurfaceState
    extends State<MorphOrganicIndicatorSurface> {
  ui.FragmentShader? _shader;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (widget.intensity == 0) return;
    final shader = await MorphChipOrganicSurface.createSharedShader();
    if (!mounted) {
      shader?.dispose();
      return;
    }
    if (shader != null) {
      setState(() => _shader = shader);
    }
  }

  @override
  void didUpdateWidget(MorphOrganicIndicatorSurface oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.intensity == 0 && widget.intensity > 0 && _shader == null) {
      _load();
    }
  }

  @override
  void dispose() {
    _shader?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => RepaintBoundary(
    child: CustomPaint(
      painter: _MorphOrganicIndicatorPainter(
        color: widget.color,
        radius: widget.radius,
        intensity: widget.intensity,
        progress: widget.progress,
        axis: widget.axis,
        shader: _shader,
      ),
    ),
  );
}

class _MorphOrganicIndicatorPainter extends CustomPainter {
  const _MorphOrganicIndicatorPainter({
    required this.color,
    required this.radius,
    required this.intensity,
    required this.progress,
    required this.axis,
    this.shader,
  });
  final Color color;
  final double radius;
  final double intensity;
  final double progress;
  final Axis axis;
  final ui.FragmentShader? shader;

  @override
  void paint(Canvas canvas, Size size) => MorphOrganicIndicatorPaint.paint(
    canvas,
    rect: Offset.zero & size,
    color: color,
    radius: radius,
    intensity: intensity,
    progress: progress,
    axis: axis,
    shader: shader,
  );

  @override
  bool shouldRepaint(covariant _MorphOrganicIndicatorPainter old) =>
      old.color != color ||
      old.radius != radius ||
      old.intensity != intensity ||
      old.progress != progress ||
      old.axis != axis ||
      old.shader != shader;
}
