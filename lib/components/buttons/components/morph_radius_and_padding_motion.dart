import '../../../foundations/interaction/morph_motion.dart';

import 'package:flutter/widgets.dart';
import 'package:motor/motor.dart';

/// Kept for compatibility with callers that import the motion constants.
const double kAnimationDeltaThreshold = 0.005;
const double kSpringRetargetTolerance = 0.1;

/// Animates the radius and padding together and retargets from the visible
/// geometry, including when the user releases during an unfinished press.
class MorphRadiusAndPaddingMotion extends StatefulWidget {
  const MorphRadiusAndPaddingMotion({
    super.key,
    required this.motion,
    required this.internalLeft,
    required this.internalRight,
    required this.internalTop,
    required this.internalBottom,
    required this.targetRadius,
    this.pressed = false,
    this.freezeTopLeft = false,
    this.freezeTopRight = false,
    this.freezeBottomLeft = false,
    this.freezeBottomRight = false,
    this.snapToTarget = false,
    required this.builder,
  });

  /// Retained for compatibility with the shared button motion API.
  final SpringMotion motion;
  final double internalLeft;
  final double internalRight;
  final double internalTop;
  final double internalBottom;
  final BorderRadius targetRadius;
  final bool pressed;
  final bool freezeTopLeft;
  final bool freezeTopRight;
  final bool freezeBottomLeft;
  final bool freezeBottomRight;
  final bool snapToTarget;
  final Widget Function(EdgeInsets padding, BorderRadius radius) builder;

  @override
  State<MorphRadiusAndPaddingMotion> createState() =>
      _MorphRadiusAndPaddingMotionState();
}

class _MorphRadiusAndPaddingMotionState
    extends State<MorphRadiusAndPaddingMotion>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late _MorphShapeTween _tween;

  // Press should react promptly; release needs room to visibly round back.
  static const Curve _pressCurve = _MorphShapeCurve();
  static const Curve _releaseCurve = Curves.easeInOutSine;
  late Curve _activeCurve;

  @override
  void initState() {
    super.initState();
    final target = _target();
    _tween = _MorphShapeTween(begin: target, end: target);
    _activeCurve = widget.pressed ? _pressCurve : _releaseCurve;
    _controller = AnimationController(vsync: this, value: 1);
  }

  _MorphShapeGeometry _target() => _MorphShapeGeometry(
    padding: EdgeInsets.fromLTRB(
      widget.internalLeft,
      widget.internalTop,
      widget.internalRight,
      widget.internalBottom,
    ),
    radius: widget.targetRadius,
  );

  _MorphShapeGeometry get _visible =>
      _tween.transform(_activeCurve.transform(_controller.value));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.snapToTarget || MorphMotion.reduceMotionOf(context)) {
      _controller.stop(canceled: false);
      _controller.value = 1;
    }
  }

  @override
  void didUpdateWidget(covariant MorphRadiusAndPaddingMotion oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.targetRadius == oldWidget.targetRadius &&
        widget.internalLeft == oldWidget.internalLeft &&
        widget.internalRight == oldWidget.internalRight &&
        widget.internalTop == oldWidget.internalTop &&
        widget.internalBottom == oldWidget.internalBottom &&
        widget.snapToTarget == oldWidget.snapToTarget) {
      return;
    }

    final current = _visible;
    final next = _target();
    _tween = _MorphShapeTween(begin: current, end: next);
    _activeCurve = widget.pressed ? _pressCurve : _releaseCurve;
    if (widget.snapToTarget || MorphMotion.reduceMotionOf(context)) {
      _controller.stop();
      _controller.value = 1;
      return;
    }
    // A slower ease-in/out on release prevents the default radius from
    // reappearing almost immediately after lifting a finger.
    _controller.duration = Duration(milliseconds: widget.pressed ? 165 : 380);
    _controller.forward(from: 0);
  }

  BorderRadius _radius(BorderRadius animated) {
    double corner(double value, double target, bool frozen) =>
        frozen ? target : value.clamp(0.0, double.infinity).toDouble();
    return BorderRadius.only(
      topLeft: Radius.circular(
        corner(
          animated.topLeft.x,
          widget.targetRadius.topLeft.x,
          widget.freezeTopLeft,
        ),
      ),
      topRight: Radius.circular(
        corner(
          animated.topRight.x,
          widget.targetRadius.topRight.x,
          widget.freezeTopRight,
        ),
      ),
      bottomLeft: Radius.circular(
        corner(
          animated.bottomLeft.x,
          widget.targetRadius.bottomLeft.x,
          widget.freezeBottomLeft,
        ),
      ),
      bottomRight: Radius.circular(
        corner(
          animated.bottomRight.x,
          widget.targetRadius.bottomRight.x,
          widget.freezeBottomRight,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool instant =
        widget.snapToTarget || MorphMotion.reduceMotionOf(context);
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final value = instant ? _target() : _visible;
          return widget.builder(value.padding, _radius(value.radius));
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

@immutable
class _MorphShapeGeometry {
  const _MorphShapeGeometry({required this.padding, required this.radius});
  final EdgeInsets padding;
  final BorderRadius radius;

  @override
  bool operator ==(Object other) =>
      other is _MorphShapeGeometry &&
      padding == other.padding &&
      radius == other.radius;

  @override
  int get hashCode => Object.hash(padding, radius);
}

class _MorphShapeTween extends Tween<_MorphShapeGeometry> {
  _MorphShapeTween({required super.begin, required super.end});

  @override
  _MorphShapeGeometry lerp(double t) => _MorphShapeGeometry(
    padding: EdgeInsets.lerp(begin!.padding, end!.padding, t)!,
    radius: BorderRadius.lerp(begin!.radius, end!.radius, t)!,
  );
}

/// A restrained overshoot on the geometry transition.
class _MorphShapeCurve extends Curve {
  const _MorphShapeCurve();

  @override
  double transformInternal(double t) {
    final cubic = Curves.easeOutCubic.transform(t);
    final back = Curves.easeOutBack.transform(t);
    return cubic + (back - cubic) * 0.45;
  }
}
