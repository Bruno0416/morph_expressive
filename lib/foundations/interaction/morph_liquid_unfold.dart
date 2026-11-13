import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

import 'morph_motion.dart';

/// Presentation choice for Morph dropdown and popup surfaces.
///
/// [centered] fades a surface in/out while scaling 90%-100% from its center.
/// [liquid] keeps the tap-origin unfolding mask; [legacy] keeps the original
/// height-based reveal / anchored spring. Selecting a style is explicit so
/// existing users can retain their preferred motion.
enum MorphDropdownMotionStyle { centered, liquid, legacy }

/// Shared liquid reveal for dropdown and popup overlays.
///
/// This is a *paint-only* transition. The child's layout stays stable, as do
/// its focus targets, scroll metrics and text sizes. A small fragment-shader
/// highlight follows the moving edge; a Canvas gradient is used if unavailable.
class MorphLiquidUnfold extends StatefulWidget {
  const MorphLiquidUnfold({
    super.key,
    required this.progress,
    required this.child,
    required this.opensAbove,
    this.intensity = 0.35,
    this.originX = 0.5,
    this.radius = 24,
    this.highlightColor = const Color(0xFFFFFFFF),
  }) : assert(intensity >= 0 && intensity <= 1),
       assert(originX >= 0 && originX <= 1);

  /// Spring progress. Small overshoots are intentionally clamped for clipping.
  final double progress;
  final Widget child;
  final bool opensAbove;

  /// 0 keeps a regular rounded unfold with no lateral tension or edge shader.
  final double intensity;

  /// Horizontal origin of the first ink, normalized within the trigger.
  final double originX;
  final double radius;
  final Color highlightColor;

  @override
  State<MorphLiquidUnfold> createState() => _MorphLiquidUnfoldState();
}

class _MorphLiquidUnfoldState extends State<MorphLiquidUnfold> {
  static Future<ui.FragmentProgram?>? _program;
  ui.FragmentShader? _shader;

  @override
  void initState() {
    super.initState();
    if (widget.intensity > 0) {
      _loadShader();
    }
  }

  @override
  void didUpdateWidget(covariant MorphLiquidUnfold oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.intensity == 0 && widget.intensity > 0 && _shader == null) {
      _loadShader();
    }
  }

  Future<void> _loadShader() async {
    try {
      final program = await (_program ??= ui.FragmentProgram.fromAsset(
        'packages/morph_expressive/shaders/dropdown_liquid_unfold.frag',
      ).then<ui.FragmentProgram?>((p) => p).catchError((Object _) => null));
      if (mounted && program != null) {
        setState(() => _shader = program.fragmentShader());
      }
    } catch (_) {
      // The Canvas fallback requires no runtime-shader support.
    }
  }

  @override
  void dispose() {
    _shader?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduced = MorphMotion.reduceMotionOf(context);
    final t = reduced ? 1.0 : widget.progress.clamp(0.0, 1.0).toDouble();
    if (t <= 0.001) {
      return const SizedBox.shrink();
    }

    // The spatial curve controls the growing surface, while the transient
    // sinusoidal tension vanishes at both endpoints.
    final reveal = t >= 1
        ? 1.0
        : MorphMotion.spatial.transform(t).clamp(0.0, 1.0).toDouble();
    final tension = math.sin(math.pi * t) * widget.intensity;
    return ClipPath(
      clipBehavior: Clip.antiAlias,
      clipper: _MorphLiquidUnfoldClipper(
        reveal: reveal,
        tension: tension,
        opensAbove: widget.opensAbove,
        originX: widget.originX,
        radius: widget.radius,
      ),
      child: Stack(
        fit: StackFit.passthrough,
        children: [
          widget.child,
          if (tension > 0.001)
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: _MorphLiquidEdgePainter(
                    progress: t,
                    reveal: reveal,
                    tension: tension,
                    opensAbove: widget.opensAbove,
                    originX: widget.originX,
                    color: widget.highlightColor,
                    shader: _shader,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// The visible outline grows from the pointer's x coordinate. Only the mask
/// changes: the panel's widgets retain their intrinsic layout and font metrics.
class _MorphLiquidUnfoldClipper extends CustomClipper<Path> {
  const _MorphLiquidUnfoldClipper({
    required this.reveal,
    required this.tension,
    required this.opensAbove,
    required this.originX,
    required this.radius,
  });

  final double reveal;
  final double tension;
  final bool opensAbove;
  final double originX;
  final double radius;

  @override
  Path getClip(Size size) {
    if (size.isEmpty || reveal <= 0) {
      return Path();
    }
    if (reveal >= 1) {
      // Preserve the surface's own elevation/shadow when settled. Clipping to
      // its exact RRect here would cut off Material's outer drop shadow.
      return Path()
        ..addRect(Rect.fromLTWH(-48, -48, size.width + 96, size.height + 96));
    }

    final w = size.width;
    final h = size.height;
    final height = (h * reveal).clamp(0.0, h).toDouble();
    final top = opensAbove ? h - height : 0.0;
    final bottom = opensAbove ? h : height;
    // Start near the contact point; grow across the full panel without
    // changing its layout. The side edges have a slight temporary waist.
    final spread = (0.16 + 0.84 * Curves.easeOutCubic.transform(reveal))
        .clamp(0.0, 1.0)
        .toDouble();
    final anchor = w * originX;
    final left = anchor * (1 - spread);
    final right = anchor + (w - anchor) * spread;
    final r = math.min(radius, math.min((right - left) / 2, height / 2));
    final inset = math.min(8.0 * tension, (right - left) * 0.08);
    final middleY = (top + bottom) / 2;
    // The lateral faces subtly pull inward as the ink travels, then recover.
    return Path()
      ..moveTo(left + r, top)
      ..lineTo(right - r, top)
      ..quadraticBezierTo(right, top, right, top + r)
      ..cubicTo(
        right - inset,
        middleY - r,
        right - inset,
        middleY + r,
        right,
        bottom - r,
      )
      ..quadraticBezierTo(right, bottom, right - r, bottom)
      ..lineTo(left + r, bottom)
      ..quadraticBezierTo(left, bottom, left, bottom - r)
      ..cubicTo(
        left + inset,
        middleY + r,
        left + inset,
        middleY - r,
        left,
        top + r,
      )
      ..quadraticBezierTo(left, top, left + r, top)
      ..close();
  }

  @override
  bool shouldReclip(_MorphLiquidUnfoldClipper old) =>
      old.reveal != reveal ||
      old.tension != tension ||
      old.opensAbove != opensAbove ||
      old.originX != originX ||
      old.radius != radius;
}

/// A bounded, subtle highlight at the revealing edge, not over the whole menu.
/// A shader gives it a localized spatial response; a gradient provides parity
/// on Web/renderers without fragment-program support.
class _MorphLiquidEdgePainter extends CustomPainter {
  const _MorphLiquidEdgePainter({
    required this.progress,
    required this.reveal,
    required this.tension,
    required this.opensAbove,
    required this.originX,
    required this.color,
    required this.shader,
  });

  final double progress;
  final double reveal;
  final double tension;
  final bool opensAbove;
  final double originX;
  final Color color;
  final ui.FragmentShader? shader;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty || tension <= 0.001) {
      return;
    }
    final edge = opensAbove ? size.height * (1 - reveal) : size.height * reveal;
    if (shader != null) {
      shader!
        ..setFloat(0, size.width)
        ..setFloat(1, size.height)
        ..setFloat(2, progress)
        ..setFloat(3, edge)
        ..setFloat(4, originX)
        ..setFloat(5, tension)
        ..setFloat(6, color.r)
        ..setFloat(7, color.g)
        ..setFloat(8, color.b)
        ..setFloat(9, color.a);
      canvas.drawRect(Offset.zero & size, Paint()..shader = shader);
      return;
    }
    final alpha = (0.16 * tension).clamp(0.0, 0.16).toDouble();
    final start = math.max(0.0, edge - 10);
    final end = math.min(size.height, edge + 10);
    if (end <= start) {
      return;
    }
    canvas.drawRect(
      Rect.fromLTWH(0, start, size.width, end - start),
      Paint()
        ..shader = ui.Gradient.linear(
          Offset(0, start),
          Offset(0, end),
          [
            color.withValues(alpha: 0),
            color.withValues(alpha: alpha),
            color.withValues(alpha: 0),
          ],
          [0, 0.5, 1],
        ),
    );
  }

  @override
  bool shouldRepaint(_MorphLiquidEdgePainter old) =>
      old.progress != progress ||
      old.reveal != reveal ||
      old.tension != tension ||
      old.opensAbove != opensAbove ||
      old.originX != originX ||
      old.color != color ||
      old.shader != shader;
}
