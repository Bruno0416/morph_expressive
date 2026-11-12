import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

/// Internal ink renderer. The shader is optional: a rounded-paint fallback
/// remains available while it loads and on unsupported platforms.
enum MorphChipInkMode { bloom, stretch }

class MorphChipOrganicSurface extends StatefulWidget {
  const MorphChipOrganicSurface({
    super.key,
    required this.color,
    required this.radius,
    required this.intensity,
    required this.progress,
    required this.seed,
    required this.mode,
    required this.padding,
    this.bloomOrigin = const Offset(0.5, 0.5),
  });

  static Future<ui.FragmentProgram?>? _program;

  static Future<ui.FragmentProgram?> _loadProgram() => _program ??=
      ui.FragmentProgram.fromAsset(
            'packages/morph_expressive/shaders/chip_organic.frag',
          )
          .then<ui.FragmentProgram?>((value) => value)
          .catchError((Object _) => null);

  /// Starts compilation before the first tap where possible.
  static Future<void> warmUp() async {
    await _loadProgram();
  }

  /// Shares the compiled stretch program with other moving Morph indicators.
  /// Each caller owns and disposes its own shader uniform buffer.
  static Future<ui.FragmentShader?> createSharedShader() async =>
      (await _loadProgram())?.fragmentShader();

  final Color color;
  final double radius;
  final double intensity;
  final double progress;
  final double seed;
  final MorphChipInkMode mode;
  final double padding;

  /// Normalized pointer position at the beginning of a circular bloom.
  /// Center is used for non-pointer activation and for other ink modes.
  final Offset bloomOrigin;

  @override
  State<MorphChipOrganicSurface> createState() =>
      _MorphChipOrganicSurfaceState();
}

class _MorphChipOrganicSurfaceState extends State<MorphChipOrganicSurface> {
  ui.FragmentShader? _shader;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      // One compiled program shared by all chips, one mutable uniform buffer
      // per visible chip. The application does not need to declare this shader.
      final program = await MorphChipOrganicSurface._loadProgram();
      if (!mounted || program == null) return;
      setState(() => _shader = program.fragmentShader());
    } catch (_) {
      // Unsupported renderer or shader not bundled: use standard painting.
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
      key: const ValueKey('morph_chip_organic_surface'),
      painter: _MorphChipOrganicPainter(
        color: widget.color,
        radius: widget.radius,
        intensity: widget.intensity,
        progress: widget.progress,
        seed: widget.seed,
        mode: widget.mode,
        padding: widget.padding,
        bloomOrigin: widget.bloomOrigin,
        shader: _shader,
      ),
    ),
  );
}

class _MorphChipOrganicPainter extends CustomPainter {
  const _MorphChipOrganicPainter({
    required this.color,
    required this.radius,
    required this.intensity,
    required this.progress,
    required this.seed,
    required this.mode,
    required this.padding,
    required this.bloomOrigin,
    required this.shader,
  });

  final Color color;
  final double radius;
  final double intensity;
  final double progress;
  final double seed;
  final MorphChipInkMode mode;
  final double padding;
  final Offset bloomOrigin;
  final ui.FragmentShader? shader;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final p = progress.clamp(0.0, 1.0).toDouble();
    final program = shader;
    if (program != null) {
      // Uniform order is mirrored in shaders/chip_organic.frag.
      program
        ..setFloat(0, size.width)
        ..setFloat(1, size.height)
        ..setFloat(2, color.r)
        ..setFloat(3, color.g)
        ..setFloat(4, color.b)
        ..setFloat(5, color.a)
        ..setFloat(6, radius)
        ..setFloat(7, padding)
        ..setFloat(8, p)
        ..setFloat(9, intensity)
        ..setFloat(10, seed)
        ..setFloat(11, mode == MorphChipInkMode.bloom ? 1.0 : 0.0)
        ..setFloat(12, 0.0) // Chip movement is horizontal.
        ..setFloat(13, bloomOrigin.dx.clamp(0.0, 1.0).toDouble())
        ..setFloat(14, bloomOrigin.dy.clamp(0.0, 1.0).toDouble());
      canvas.drawRect(Offset.zero & size, Paint()..shader = program);
      return;
    }

    // Fallback while loading or if this device cannot compile the shader.
    final inner = Size(
      math.max(0.0, size.width - 2 * padding),
      math.max(0.0, size.height - 2 * padding),
    );
    if (inner.isEmpty) return;
    var width = inner.width;
    var height = inner.height;
    var r = radius;
    var opacity = 1.0;
    if (mode == MorphChipInkMode.bloom) {
      if (p <= 0) return;
      final diameter = math.min(inner.width, inner.height);
      final minDiameter = math.min(diameter, 4.0);
      if (p < 0.78) {
        final t = math.pow(p / 0.78, 2).toDouble();
        width = height = minDiameter + (diameter - minDiameter) * t;
        r = width / 2;
      } else {
        final t = 1.0 - math.pow(1.0 - (p - 0.78) / 0.22, 3).toDouble();
        width = diameter + (inner.width - diameter) * t;
        height = diameter + (inner.height - diameter) * t;
        r = diameter / 2 + (radius - diameter / 2) * t;
      }
      opacity = (p / 0.12).clamp(0.0, 1.0).toDouble();
    }
    final shift = mode == MorphChipInkMode.bloom
        ? (1 - p * p * (3 - 2 * p)).clamp(0.0, 1.0).toDouble()
        : 0.0;
    final tapCenter = Offset(
      padding + inner.width * bloomOrigin.dx.clamp(0.0, 1.0),
      padding + inner.height * bloomOrigin.dy.clamp(0.0, 1.0),
    );
    final center = Offset(
      size.width / 2 + (tapCenter.dx - size.width / 2) * shift,
      size.height / 2 + (tapCenter.dy - size.height / 2) * shift,
    );
    final rect = Rect.fromCenter(center: center, width: width, height: height);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(r)),
      Paint()..color = color.withValues(alpha: color.a * opacity),
    );
  }

  @override
  bool shouldRepaint(covariant _MorphChipOrganicPainter old) =>
      old.color != color ||
      old.radius != radius ||
      old.intensity != intensity ||
      old.progress != progress ||
      old.seed != seed ||
      old.mode != mode ||
      old.padding != padding ||
      old.bloomOrigin != bloomOrigin ||
      old.shader != shader;
}
