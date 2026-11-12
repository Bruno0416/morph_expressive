import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

import '../../../foundations/interaction/morph_motion.dart';

/// A short, progressive ink reveal of a selected date range. The same timing
/// spans every visible month; each day paints only its own portion of the ink.
/// The shape returns to a conventional fully rounded band at rest.
class MorphDateRangeInk extends StatefulWidget {
  const MorphDateRangeInk({
    super.key,
    required this.color,
    required this.progress,
    required this.dayIndex,
    required this.dayCount,
    required this.radius,
    required this.roundLeft,
    required this.roundRight,
    this.organicStretchIntensity = 0.40,
  }) : assert(organicStretchIntensity >= 0 && organicStretchIntensity <= 1);

  final Color color;
  final Animation<double> progress;
  final int dayIndex;
  final int dayCount;
  final double radius;
  final bool roundLeft;
  final bool roundRight;

  /// Cross-axis contraction while the range expands horizontally. Set to 0
  /// for the original full-height highlight, without changing its selection.
  final double organicStretchIntensity;

  /// Navigation-like spatial timing, bounded for use as a reveal mask.
  static double revealAt(double progress) => MorphMotion.spatial
      .transform(progress.clamp(0.0, 1.0).toDouble())
      .clamp(0.0, 1.0)
      .toDouble();

  /// Gentle height contraction, always zero at rest (including reduced motion).
  static double stretchAt(double progress, double intensity) {
    final t = progress.clamp(0.0, 1.0).toDouble();
    final amount = intensity.clamp(0.0, 1.0).toDouble();
    return 0.14 * amount * math.sin(math.pi * t);
  }

  static Future<ui.FragmentProgram?>? _program;

  static Future<ui.FragmentProgram?> _loadProgram() => _program ??=
      ui.FragmentProgram.fromAsset(
            'packages/morph_expressive/shaders/date_range_reveal.frag',
          )
          .then<ui.FragmentProgram?>((program) => program)
          .catchError((Object _) => null);

  /// Compile once ahead of the first range selection, when possible.
  static Future<void> warmUp() async {
    await _loadProgram();
  }

  @override
  State<MorphDateRangeInk> createState() => _MorphDateRangeInkState();
}

class _MorphDateRangeInkState extends State<MorphDateRangeInk> {
  ui.FragmentShader? _shader;

  @override
  void initState() {
    super.initState();
    _loadShader();
  }

  Future<void> _loadShader() async {
    try {
      final program = await MorphDateRangeInk._loadProgram();
      if (!mounted) return;
      if (program != null) setState(() => _shader = program.fragmentShader());
    } catch (_) {
      // Canvas fallback preserves selection on unsupported renderers.
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
      painter: _MorphDateRangeInkPainter(
        color: widget.color,
        progress: widget.progress,
        dayIndex: widget.dayIndex,
        dayCount: widget.dayCount,
        radius: widget.radius,
        roundLeft: widget.roundLeft,
        roundRight: widget.roundRight,
        organicStretchIntensity: widget.organicStretchIntensity,
        shader: _shader,
      ),
    ),
  );
}

class _MorphDateRangeInkPainter extends CustomPainter {
  _MorphDateRangeInkPainter({
    required this.color,
    required this.progress,
    required this.dayIndex,
    required this.dayCount,
    required this.radius,
    required this.roundLeft,
    required this.roundRight,
    required this.organicStretchIntensity,
    required this.shader,
  }) : super(repaint: progress);

  final Color color;
  final Animation<double> progress;
  final int dayIndex;
  final int dayCount;
  final double radius;
  final bool roundLeft;
  final bool roundRight;
  final double organicStretchIntensity;
  final ui.FragmentShader? shader;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final steps = dayCount < 1 ? 1 : dayCount;
    // Match navigation's spatial curve for the moving front. Clamp its small
    // overshoot: the reveal mask must never paint outside the selected dates.
    final travel = MorphDateRangeInk.revealAt(progress.value);
    final reveal = (travel * steps - dayIndex).clamp(0.0, 1.0).toDouble();
    if (reveal <= 0) return;
    // All day segments in the range share one cross-axis response, so there
    // are no height seams between neighboring cells during the animation.
    final stretch = MorphDateRangeInk.stretchAt(
      progress.value,
      organicStretchIntensity,
    );
    if (shader != null) {
      shader!
        ..setFloat(0, size.width)
        ..setFloat(1, size.height)
        ..setFloat(2, color.r)
        ..setFloat(3, color.g)
        ..setFloat(4, color.b)
        ..setFloat(5, color.a)
        ..setFloat(6, reveal)
        ..setFloat(7, roundLeft ? radius : 0.0)
        ..setFloat(8, roundRight ? radius : 0.0)
        ..setFloat(9, stretch);
      // Internal day boundaries must not be antialiased: neighboring cells
      // share the same filled band, and blending their edges shows seams.
      // The shader still smooths the actual rounded ends and moving front.
      canvas.drawRect(
        Offset.zero & size,
        Paint()
          ..isAntiAlias = false
          ..shader = shader,
      );
      return;
    }
    final inset = size.height * stretch * 0.5;
    final rect = Rect.fromLTWH(0, inset, size.width, size.height - 2 * inset);
    final rounded = math.min(radius, rect.height * 0.5);
    final band = RRect.fromRectAndCorners(
      rect,
      topLeft: Radius.circular(roundLeft ? rounded : 0.0),
      bottomLeft: Radius.circular(roundLeft ? rounded : 0.0),
      topRight: Radius.circular(roundRight ? rounded : 0.0),
      bottomRight: Radius.circular(roundRight ? rounded : 0.0),
    );
    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width * reveal, size.height));
    canvas.drawRRect(band, Paint()..color = color);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _MorphDateRangeInkPainter old) =>
      old.color != color ||
      old.progress != progress ||
      old.dayIndex != dayIndex ||
      old.dayCount != dayCount ||
      old.radius != radius ||
      old.roundLeft != roundLeft ||
      old.roundRight != roundRight ||
      old.organicStretchIntensity != organicStretchIntensity ||
      old.shader != shader;
}
