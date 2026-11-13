import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/widgets.dart';

import '../morph_operation_state.dart';

/// Timing and entry shape for the status glyph swap of `MorphAsyncButton`.
///
/// Independent of the 90/160 ms press/release profile and of the surface
/// `transitionDuration`. [none] swaps glyphs immediately.
@immutable
class MorphOperationIconTransition {
  const MorphOperationIconTransition({
    this.duration = const Duration(milliseconds: 320),
    this.curve = Curves.easeOutCubic,
    this.successRotation = -45,
    this.initialScale = .6,
  }) : assert(initialScale >= 0 && initialScale <= 1);

  /// Glyph swap without rotation, scale or fade.
  static const none = MorphOperationIconTransition(duration: Duration.zero);
  static const defaults = MorphOperationIconTransition();

  final Duration duration;
  final Curve curve;

  /// Starting angle in degrees of an entering success glyph; ends at 0°.
  final double successRotation;

  /// Starting scale (0..1) of the entering glyph.
  final double initialScale;

  bool get enabled => duration > Duration.zero;

  @override
  bool operator ==(Object other) =>
      other is MorphOperationIconTransition &&
      duration == other.duration &&
      curve == other.curve &&
      successRotation == other.successRotation &&
      initialScale == other.initialScale;
  @override
  int get hashCode =>
      Object.hash(duration, curve, successRotation, initialScale);
}

class _Pose {
  const _Pose(this.opacity, this.scale, this.rotation);
  final double opacity, scale, rotation; // rotation in radians
}

/// Stable square slot for loader/status glyphs. The supplied widgets are
/// wrapped with Opacity/Transform only; their content is never rebuilt.
class MorphOperationGlyphSlot extends StatefulWidget {
  const MorphOperationGlyphSlot({
    super.key,
    required this.state,
    required this.glyph,
    required this.dimension,
    required this.transition,
  });
  final MorphOperationState state;
  final Widget? glyph;
  final double dimension;
  final MorphOperationIconTransition transition;

  @override
  State<MorphOperationGlyphSlot> createState() =>
      _MorphOperationGlyphSlotState();
}

class _MorphOperationGlyphSlotState extends State<MorphOperationGlyphSlot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(vsync: this)
    ..addListener(() => setState(() {}));
  Widget? _outgoing;
  _Pose _outgoingStart = const _Pose(1, 1, 0);

  MorphOperationIconTransition get _t => widget.transition;
  double get _c => _t.curve.transform(_controller.value.clamp(0.0, 1.0));

  // Fixed when a transition starts: later state changes must not reinterpret
  // the pose of a glyph that is already on screen.
  double _entryRotation = 0;

  _Pose get _incomingPose {
    if (!_controller.isAnimating && _controller.value >= 1) {
      return const _Pose(1, 1, 0);
    }
    final c = _c;
    return _Pose(
      const Interval(.3, 1).transform(c),
      lerpDouble(_t.initialScale, 1, c)!,
      lerpDouble(_entryRotation, 0, c)!,
    );
  }

  _Pose get _outgoingPose {
    final c = _c;
    final fade = const Interval(0, .6).transform(c);
    return _Pose(
      _outgoingStart.opacity * (1 - fade),
      _outgoingStart.scale * lerpDouble(1, .8, c)!,
      _outgoingStart.rotation,
    );
  }

  @override
  void didUpdateWidget(MorphOperationGlyphSlot old) {
    super.didUpdateWidget(old);
    if (old.state == widget.state) return;
    if (!_t.enabled) {
      _controller.value = 1;
      _outgoing = null;
      return;
    }
    // Start from what is visible: the glyph currently entering (or settled)
    // becomes the outgoing one, keeping its present pose.
    final visible = _controller.isAnimating ? _incomingPose : null;
    _outgoing = old.glyph;
    _entryRotation = widget.state == MorphOperationState.success
        ? _t.successRotation * math.pi / 180
        : 0;
    _outgoingStart = visible ?? const _Pose(1, 1, 0);
    _controller.duration = _t.duration;
    _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _posed(Widget child, _Pose pose) => Opacity(
    opacity: pose.opacity.clamp(0.0, 1.0),
    child: Transform.rotate(
      angle: pose.rotation,
      child: Transform.scale(scale: pose.scale, child: child),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final animating = _controller.isAnimating && _t.enabled;
    final glyph = widget.glyph;
    final children = <Widget>[
      if (animating && _outgoing != null)
        Positioned.fill(
          child: Center(child: _posed(_outgoing!, _outgoingPose)),
        ),
      if (glyph != null)
        Positioned.fill(
          child: Center(
            child: animating ? _posed(glyph, _incomingPose) : glyph,
          ),
        ),
    ];
    // Overflow visible: a rotating icon is never clipped by its slot.
    return SizedBox.square(
      dimension: widget.dimension,
      child: Stack(clipBehavior: Clip.none, children: children),
    );
  }
}
