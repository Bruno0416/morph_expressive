import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// Whether [MorphSmoothEdges] renders its child offscreen.
enum MorphSmoothEdgesMode {
  /// On where the defect was measured and is mitigated (Linux desktop,
  /// excluding Web); direct painting elsewhere.
  auto,

  /// Always offscreen.
  enabled,

  /// Always direct (reference path).
  disabled,
}

/// Draws [child] through an offscreen target at the device pixel ratio.
///
/// Measured finding (Linux, Impeller OpenGLESSDF): vector paths and hard clips
/// painted onto the window surface have binary coverage even with
/// `isAntiAlias`, while an offscreen *image* target of the same backend is
/// anti-aliased (a single AA fill inside a plain `saveLayer` is not). Material
/// and third-party painters (sliders, progress indicators, ink splash, clipped
/// swipe actions) cannot be redrawn with Morph's own coverage, so they are
/// rendered offscreen and blitted 1:1. Layout, hit testing and semantics are
/// untouched; only paint is intercepted. The image is created and disposed per
/// paint, bounded to the child bounds plus [bleed]; nothing is retained.
class MorphSmoothEdges extends SingleChildRenderObjectWidget {
  const MorphSmoothEdges({super.key, this.mode, this.bleed = 4, super.child});

  /// Overrides [defaultMode] for this subtree root.
  final MorphSmoothEdgesMode? mode;

  /// Extra logical pixels painted around the child (shadows, overshoot).
  final double bleed;

  /// Process-wide default, used when [mode] is null.
  static MorphSmoothEdgesMode defaultMode = MorphSmoothEdgesMode.auto;

  static bool _resolve(MorphSmoothEdgesMode? mode) =>
      switch (mode ?? defaultMode) {
        MorphSmoothEdgesMode.enabled => true,
        MorphSmoothEdgesMode.disabled => false,
        MorphSmoothEdgesMode.auto =>
          !kIsWeb && defaultTargetPlatform == TargetPlatform.linux,
      };

  @override
  RenderObject createRenderObject(BuildContext context) => _RenderSmoothEdges(
    enabled: _resolve(mode),
    bleed: bleed,
    pixelRatio: MediaQuery.maybeDevicePixelRatioOf(context) ?? 1,
  );

  @override
  void updateRenderObject(BuildContext context, RenderObject renderObject) {
    (renderObject as _RenderSmoothEdges)
      ..enabled = _resolve(mode)
      ..bleed = bleed
      ..pixelRatio = MediaQuery.maybeDevicePixelRatioOf(context) ?? 1;
  }
}

class _RenderSmoothEdges extends RenderProxyBox {
  _RenderSmoothEdges({
    required this._enabled,
    required this._bleed,
    required this._pixelRatio,
  });

  bool _enabled;
  set enabled(bool v) {
    if (v == _enabled) return;
    _enabled = v;
    markNeedsCompositingBitsUpdate();
    markNeedsPaint();
  }

  /// When active this is a repaint boundary: the offscreen image is generated
  /// only when this subtree repaints, and is not regenerated when an ancestor
  /// repaints without any change here (the composited layer is reused).
  @override
  bool get isRepaintBoundary => _enabled;

  double _bleed;
  set bleed(double v) {
    if (v == _bleed) return;
    _bleed = v;
    markNeedsPaint();
  }

  double _pixelRatio;
  set pixelRatio(double v) {
    if (v == _pixelRatio) return;
    _pixelRatio = v;
    markNeedsPaint();
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final child = this.child;
    if (child == null) return;
    if (!_enabled || size.isEmpty) {
      context.paintChild(child, offset);
      return;
    }
    final bounds = (Offset.zero & size).inflate(_bleed);
    // Render at the on-screen scale so scaled ancestors stay sharp.
    final m = getTransformTo(null);
    final scale = m.getMaxScaleOnAxis().clamp(.25, 4.0);
    final layer = OffsetLayer();
    final inner = PaintingContext(layer, bounds);
    inner.paintChild(child, Offset.zero);
    // The recording must be closed before the layer is rasterized; this is
    // the same sequence RenderRepaintBoundary uses internally.
    // ignore: invalid_use_of_protected_member
    inner.stopRecordingIfNeeded();
    final image = layer.toImageSync(bounds, pixelRatio: _pixelRatio * scale);
    layer.dispose();
    context.canvas.drawImageRect(
      image,
      Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      bounds.shift(offset),
      Paint()
        ..filterQuality = scale == 1 ? FilterQuality.none : FilterQuality.low
        ..isAntiAlias = false,
    );
    image.dispose();
  }
}
