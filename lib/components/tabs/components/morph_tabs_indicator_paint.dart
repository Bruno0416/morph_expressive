part of '../morph_tabs.dart';

/// Painting of the indicator and the optional group background.
///
/// The Shader (through `MorphRoundedSurface`) only draws geometry: uniform
/// corner radii. Everything else, and every fallback, is Canvas with the same
/// rectangle and radii, so both renderers show identical geometry.
extension _MorphTabsIndicatorPaint on _MorphTabsState {
  /// Indicator layer. [surface] layers sit behind the tabs, underline layers
  /// above them; the layer that does not match the style paints nothing.
  Widget _indicatorLayer({required bool surface}) {
    return AnimatedBuilder(
      animation: _pulse,
      builder: (BuildContext context, Widget? _) {
        final MorphTabIndicatorSpec spec = _spec;
        if (spec.isSurface != surface) {
          return const SizedBox.shrink();
        }
        final MorphTabsEdges? edges = _visibleEdges();
        if (edges == null) {
          return const SizedBox.shrink();
        }
        final double top = surface
            ? spec.surfaceInset
            : math.max(0, _barHeight - spec.thickness);
        final double height = surface
            ? spec.surfaceHeight(_barHeight)
            : spec.thickness;
        if (edges.width <= 0 || height <= 0) {
          return const SizedBox.shrink();
        }
        final Size size = Size(edges.width, height);
        final double topRadius = surface
            ? spec.innerRadius(_barHeight)
            : spec.topRadius;
        final double bottomRadius = surface ? topRadius : spec.bottomRadius;
        return Positioned(
          left: edges.left,
          top: top,
          width: size.width,
          height: size.height,
          child: IgnorePointer(
            child: _IndicatorShape(
              key: const ValueKey<String>('morph-tabs-indicator'),
              size: size,
              topRadius: topRadius,
              bottomRadius: bottomRadius,
              color: spec.color,
              renderer: spec.renderer,
              onStatus: _reportRenderer,
            ),
          ),
        );
      },
    );
  }

  Widget _groupBackground() {
    final MorphTabIndicatorSpec spec = _spec;
    if (!spec.groupBackground) {
      return const SizedBox.shrink();
    }
    // The outer container: concentric with the surface (inner radius + inset).
    return Positioned.fill(
      child: IgnorePointer(
        child: DecoratedBox(
          key: const ValueKey<String>('morph-tabs-group'),
          decoration: BoxDecoration(
            color: spec.groupColor,
            borderRadius: BorderRadius.circular(spec.outerRadius(_barHeight)),
          ),
        ),
      ),
    );
  }

  void _reportRenderer(MorphShapeRenderStatus status) {
    final String key = '${status.effective}:${status.reason}';
    if (key == _lastRenderer) {
      return;
    }
    _lastRenderer = key;
    final ValueChanged<MorphShapeRenderStatus>? callback =
        widget.onIndicatorRendererChanged;
    if (callback == null) {
      return;
    }
    if (SchedulerBinding.instance.schedulerPhase !=
        SchedulerPhase.persistentCallbacks) {
      // Already outside build (the surface reports from a post-frame callback).
      callback(status);
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        callback(status);
      }
    });
  }
}

/// One indicator rectangle. Shader when the radii are uniform and the program
/// is available, Canvas otherwise.
class _IndicatorShape extends StatelessWidget {
  const _IndicatorShape({
    super.key,
    required this.size,
    required this.topRadius,
    required this.bottomRadius,
    required this.color,
    required this.renderer,
    required this.onStatus,
  });

  final Size size;
  final double topRadius;
  final double bottomRadius;
  final Color color;
  final MorphShapeRenderer renderer;
  final ValueChanged<MorphShapeRenderStatus> onStatus;

  @override
  Widget build(BuildContext context) {
    final bool uniform = (topRadius - bottomRadius).abs() < 1e-6;
    if (uniform) {
      return MorphRoundedSurface(
        size: size,
        radius: topRadius,
        color: color,
        renderer: renderer,
        onRendererChanged: onStatus,
      );
    }
    onStatus(
      MorphShapeRenderStatus(
        MorphShapeRenderer.canvas,
        renderer == MorphShapeRenderer.canvas
            ? null
            : 'asymmetric corner radii use Canvas',
      ),
    );
    return CustomPaint(
      size: size,
      painter: _IndicatorPainter(
        size: size,
        topRadius: topRadius,
        bottomRadius: bottomRadius,
        color: color,
        dpr: MediaQuery.maybeDevicePixelRatioOf(context) ?? 1,
      ),
    );
  }
}

class _IndicatorPainter extends CustomPainter {
  const _IndicatorPainter({
    required this.size,
    required this.topRadius,
    required this.bottomRadius,
    required this.color,
    required this.dpr,
  });

  final Size size;
  final double topRadius;
  final double bottomRadius;
  final Color color;
  final double dpr;

  @override
  void paint(Canvas canvas, Size canvasSize) {
    final double cap = size.shortestSide / 2;
    final Radius top = Radius.circular(math.min(topRadius, cap));
    final Radius bottom = Radius.circular(math.min(bottomRadius, cap));
    final RRect rrect = RRect.fromRectAndCorners(
      Offset.zero & size,
      topLeft: top,
      topRight: top,
      bottomLeft: bottom,
      bottomRight: bottom,
    );
    MorphEdgeCoverage.draw(
      canvas,
      Path()..addRRect(rrect),
      Paint()..color = color,
      mode: MorphEdgeAntialias.auto,
      pixelRatio: dpr,
    );
  }

  @override
  bool shouldRepaint(_IndicatorPainter old) =>
      size != old.size ||
      topRadius != old.topRadius ||
      bottomRadius != old.bottomRadius ||
      color != old.color ||
      dpr != old.dpr;
}
