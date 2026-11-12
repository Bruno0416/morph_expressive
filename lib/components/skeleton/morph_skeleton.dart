import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

import '../../foundations/foundations.dart';
export 'morph_skeleton_theme.dart';

enum MorphSkeletonEffect { shimmer, pulse, none }

enum MorphShimmerDirection {
  leftToRight,
  rightToLeft,
  topToBottom,
  bottomToTop,
}

/// One animation clock and coordinate space for all descendant placeholders.
/// Hidden real content keeps layout but cannot receive focus, taps or semantics.
class MorphSkeletonGroup extends StatefulWidget {
  const MorphSkeletonGroup({
    super.key,
    required this.placeholder,
    this.child,
    this.loading = true,
    this.enabled = true,
    this.effect = MorphSkeletonEffect.shimmer,
    this.direction = MorphShimmerDirection.leftToRight,
    this.duration,
    this.transitionDuration,
    this.intensity,
    this.angle,
    this.baseColor,
    this.highlightColor,
    this.renderer = MorphShapeRenderer.auto,
    this.onRendererChanged,
    this.semanticLabel,
  });
  final Widget placeholder;
  final Widget? child;
  final bool loading, enabled;
  final MorphSkeletonEffect effect;
  final MorphShimmerDirection direction;
  final Duration? duration, transitionDuration;
  final double? intensity;

  /// Shimmer band tilt in degrees (null → [MorphSkeletonTheme.angle], 0).
  ///
  /// The band is the un-tilted band (perpendicular to [direction]) rotated
  /// clockwise on screen by this angle: for left/right directions it is the
  /// inclination from the vertical (positive leans like `/`, negative `\`);
  /// for top/bottom directions the horizontal band rotates the same way.
  /// [direction] still decides which way the band travels. Only shimmer is
  /// affected; pulse and static placeholders ignore it. Values near ±90° make
  /// the band almost parallel to the axis and are supported.
  final double? angle;
  final Color? baseColor, highlightColor;
  final MorphShapeRenderer renderer;
  final ValueChanged<MorphShapeRenderStatus>? onRendererChanged;
  final String? semanticLabel;
  @override
  State<MorphSkeletonGroup> createState() => _MorphSkeletonGroupState();
}

class _MorphSkeletonGroupState extends State<MorphSkeletonGroup>
    with SingleTickerProviderStateMixin {
  late final AnimationController clock = AnimationController(vsync: this);
  final space = GlobalKey();
  static ui.FragmentProgram? _program;
  ui.FragmentProgram? program;
  String? _failure;
  bool _requestedProgram = false;
  MorphShapeRenderStatus? _lastStatus;
  @override
  void initState() {
    super.initState();
  }

  Future<void> _load() async {
    try {
      final loaded =
          _program ??
          await ui.FragmentProgram.fromAsset(
            'packages/morph_expressive/shaders/morph_shimmer.frag',
          );
      _program = loaded;
      if (mounted) setState(() => program = loaded);
    } catch (_) {
      if (mounted) {
        setState(() => _failure = 'Shader unavailable; Canvas gradient');
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void didUpdateWidget(MorphSkeletonGroup old) {
    super.didUpdateWidget(old);
    _sync();
  }

  void _sync() {
    final duration =
        widget.duration ?? MorphTheme.of(context).skeletonTheme.duration;
    assert(duration > Duration.zero);
    final wasDuration = clock.duration;
    clock.duration = duration;
    final run =
        widget.loading &&
        widget.enabled &&
        widget.effect != MorphSkeletonEffect.none &&
        !MorphMotion.reduceMotionOf(context) &&
        TickerMode.valuesOf(context).enabled;
    if (run &&
        widget.effect == MorphSkeletonEffect.shimmer &&
        widget.renderer != MorphShapeRenderer.canvas &&
        !_requestedProgram) {
      _requestedProgram = true;
      _load();
    }
    if (run && (!clock.isAnimating || wasDuration != duration)) {
      clock.repeat(period: duration);
    } else if (!run) {
      clock.stop();
    }
  }

  void _report(MorphShapeRenderStatus status) {
    if (_lastStatus?.effective == status.effective &&
        _lastStatus?.reason == status.reason) {
      return;
    }
    _lastStatus = status;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.onRendererChanged?.call(status);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = MorphTheme.of(context);
    final reduced = MorphMotion.reduceMotionOf(context);
    final effect = reduced || !widget.enabled
        ? MorphSkeletonEffect.none
        : widget.effect;
    final useShader =
        program != null &&
        widget.renderer != MorphShapeRenderer.canvas &&
        effect == MorphSkeletonEffect.shimmer;
    _report(
      MorphShapeRenderStatus(
        useShader ? MorphShapeRenderer.shader : MorphShapeRenderer.canvas,
        useShader
            ? 'Directional fragment shader'
            : _failure ?? 'Canvas / static placeholder',
      ),
    );
    final base =
        widget.baseColor ??
        theme.skeletonTheme.baseColor ??
        theme.colorScheme.surfaceContainerHighest;
    final highlight =
        widget.highlightColor ??
        theme.skeletonTheme.highlightColor ??
        theme.colorScheme.onSurface;
    final amount = widget.intensity ?? theme.skeletonTheme.intensity;
    assert(amount >= 0 && amount <= 1);
    final tilt = (widget.angle ?? theme.skeletonTheme.angle) * math.pi / 180;
    return _SkeletonScope(
      state: this,
      effect: effect,
      direction: widget.direction,
      intensity: amount,
      angle: tilt,
      base: base,
      highlight: highlight,
      program: useShader ? program : null,
      child: RepaintBoundary(
        key: space,
        child: Semantics(
          container: true,
          liveRegion: widget.loading && widget.semanticLabel != null,
          label: widget.loading ? widget.semanticLabel : null,
          child: TweenAnimationBuilder<double>(
            tween: Tween(end: widget.loading ? 1 : 0),
            duration: reduced
                ? Duration.zero
                : widget.transitionDuration ??
                      theme.skeletonTheme.transitionDuration,
            builder: (context, opacity, _) => Stack(
              alignment: AlignmentDirectional.topStart,
              children: [
                if (widget.child != null)
                  IgnorePointer(
                    ignoring: widget.loading,
                    child: ExcludeFocus(
                      excluding: widget.loading,
                      child: ExcludeSemantics(
                        excluding: widget.loading,
                        child: Opacity(
                          opacity: 1 - opacity,
                          child: widget.child,
                        ),
                      ),
                    ),
                  ),
                if (opacity > 0)
                  IgnorePointer(
                    child: ExcludeFocus(
                      child: ExcludeSemantics(
                        child: Opacity(
                          opacity: opacity,
                          child: widget.placeholder,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    clock.dispose();
    super.dispose();
  }
}

class _SkeletonScope extends InheritedWidget {
  const _SkeletonScope({
    required this.state,
    required this.effect,
    required this.direction,
    required this.intensity,
    required this.angle,
    required this.base,
    required this.highlight,
    required this.program,
    required super.child,
  });
  final _MorphSkeletonGroupState state;
  final MorphSkeletonEffect effect;
  final MorphShimmerDirection direction;
  final double intensity;

  /// Radians.
  final double angle;
  final Color base, highlight;
  final ui.FragmentProgram? program;
  @override
  bool updateShouldNotify(_SkeletonScope old) =>
      effect != old.effect ||
      direction != old.direction ||
      intensity != old.intensity ||
      angle != old.angle ||
      base != old.base ||
      highlight != old.highlight ||
      program != old.program;
}

/// Explicit composable placeholder. Outside a group it owns a single group.
class MorphSkeleton extends StatefulWidget {
  const MorphSkeleton({
    super.key,
    this.width,
    this.height = 16,
    this.radius = 8,
    this.shape,
  });
  const MorphSkeleton.avatar({super.key, double size = 48})
    : width = size,
      height = size,
      radius = size / 2,
      shape = null;
  const MorphSkeleton.line({super.key, this.width, this.height = 12})
    : radius = 6,
      shape = null;
  const MorphSkeleton.image({
    super.key,
    this.width,
    this.height = 180,
    this.radius = 16,
  }) : shape = null;
  final double? width;
  final double height, radius;
  final MorphShape? shape;
  static Widget lines({
    int count = 3,
    double height = 12,
    double gap = 8,
    double lastLineFraction = .65,
  }) {
    assert(count > 0 && lastLineFraction > 0 && lastLineFraction <= 1);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < count; i++) ...[
          if (i > 0) SizedBox(height: gap),
          FractionallySizedBox(
            widthFactor: i == count - 1 ? lastLineFraction : 1,
            child: MorphSkeleton.line(height: height),
          ),
        ],
      ],
    );
  }

  @override
  State<MorphSkeleton> createState() => _MorphSkeletonState();
}

class _MorphSkeletonState extends State<MorphSkeleton> {
  ui.FragmentShader? shader;
  ui.FragmentProgram? program;
  @override
  Widget build(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<_SkeletonScope>();
    if (scope == null) {
      return MorphSkeletonGroup(
        placeholder: MorphSkeleton(
          width: widget.width,
          height: widget.height,
          radius: widget.radius,
          shape: widget.shape,
        ),
      );
    }
    if (program != scope.program) {
      shader?.dispose();
      program = scope.program;
      shader = program?.fragmentShader();
    }
    return LayoutBuilder(
      builder: (context, bounds) => SizedBox(
        width: widget.width ?? (bounds.hasBoundedWidth ? bounds.maxWidth : 120),
        height: widget.height,
        child: CustomPaint(
          painter: _SkeletonPainter(
            scope,
            shader,
            widget.radius,
            widget.shape,
            () {
              final own = context.findRenderObject();
              final group = scope.state.space.currentContext
                  ?.findRenderObject();
              if (own is RenderBox &&
                  group is RenderBox &&
                  own.attached &&
                  group.attached) {
                return (
                  origin: own.localToGlobal(Offset.zero, ancestor: group),
                  size: group.size,
                );
              }
              return (origin: Offset.zero, size: const Size(120, 120));
            },
            MediaQuery.devicePixelRatioOf(context),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    shader?.dispose();
    super.dispose();
  }
}

class _SkeletonPainter extends CustomPainter {
  _SkeletonPainter(
    this.scope,
    this.shader,
    this.radius,
    this.shape,
    this.coordinates,
    this.dpr,
  ) : super(repaint: scope.state.clock);
  final _SkeletonScope scope;
  final ui.FragmentShader? shader;
  final double radius, dpr;
  final MorphShape? shape;
  final ({Offset origin, Size size}) Function() coordinates;
  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final phase = scope.effect == MorphSkeletonEffect.none
        ? 0.0
        : scope.state.clock.value;
    final coords = coordinates();
    final r = radius.clamp(0.0, size.shortestSide / 2);
    final path = shape == null
        ? (Path()..addRRect(
            RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(r)),
          ))
        : morphContourPath(shape!.contour, size);
    final sh = shader;
    if (sh != null && shape == null) {
      final values = <double>[
        size.width,
        size.height,
        coords.origin.dx,
        coords.origin.dy,
        coords.size.width,
        coords.size.height,
        phase,
        scope.direction.index.toDouble(),
        scope.intensity,
        scope.base.r,
        scope.base.g,
        scope.base.b,
        scope.base.a,
        scope.highlight.r,
        scope.highlight.g,
        scope.highlight.b,
        scope.highlight.a,
        r,
        dpr,
        scope.angle,
      ];
      for (var i = 0; i < values.length; i++) {
        sh.setFloat(i, values[i]);
      }
      canvas.drawRect((Offset.zero & size).inflate(1), Paint()..shader = sh);
      return;
    }
    final paint = Paint()..color = scope.base;
    if (scope.effect == MorphSkeletonEffect.pulse) {
      paint.color = Color.lerp(
        scope.base,
        scope.highlight,
        (.5 - .5 * math.cos(phase * math.pi * 2)) * scope.intensity,
      )!;
    } else if (scope.effect == MorphSkeletonEffect.shimmer) {
      final g = morphShimmerGeometry(coords.size, scope.direction, scope.angle);
      final sweep = g.sweep(phase * 1.6 - .3);
      final center = g.normal * sweep - coords.origin;
      final along = g.normal * g.halfWidth;
      paint.shader = ui.Gradient.linear(
        center - along,
        center + along,
        [
          scope.base,
          Color.lerp(scope.base, scope.highlight, scope.intensity)!,
          scope.base,
        ],
        [0, .5, 1],
      );
    }
    MorphEdgeCoverage.draw(
      canvas,
      path,
      paint,
      mode: MorphEdgeAntialias.auto,
      pixelRatio: dpr,
    );
  }

  @override
  bool shouldRepaint(_SkeletonPainter old) => true;
}

/// Shared group-space geometry of the tilted shimmer band (Canvas path; the
/// fragment shader mirrors these formulas). `normal` is the unit vector the
/// band travels along; positions are dot products with it, in group space.
@visibleForTesting
({
  Offset normal,
  double min,
  double length,
  double halfWidth,
  bool reverse,
  double Function(double) sweep,
})
morphShimmerGeometry(
  Size group,
  MorphShimmerDirection direction,
  double angle,
) {
  final horizontal = direction.index < 2;
  final normal = horizontal
      ? Offset(math.cos(angle), math.sin(angle))
      : Offset(-math.sin(angle), math.cos(angle));
  final length = math.max(
    1.0,
    normal.dx.abs() * group.width + normal.dy.abs() * group.height,
  );
  final min =
      math.min(0.0, normal.dx * group.width) +
      math.min(0.0, normal.dy * group.height);
  final base = math.max(1.0, horizontal ? group.width : group.height);
  final edge = (.2 * base / length).clamp(.02, .45);
  final reverse = direction.index.isOdd;
  return (
    normal: normal,
    min: min,
    length: length,
    halfWidth: edge * length,
    reverse: reverse,
    // Position along the normal for a band at axis phase `s` (0..1 across
    // the projected group), honouring the travel direction.
    sweep: (double s) => min + (reverse ? 1 - s : s) * length,
  );
}
