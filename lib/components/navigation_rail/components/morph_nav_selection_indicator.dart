import 'package:flutter/widgets.dart';
import 'package:motor/motor.dart';

import '../../../foundations/interaction/morph_motion_controller.dart';
import '../../../foundations/foundations.dart';

/// Per-destination selection indicator.
///
/// Width scales from 0.64 to 1 with [scaleSpring]. The selected pill fades
/// in through [fadeSpring] while the selected destination expands.
/// Leaving a destination fades through the same effects spring. A resting unselected
/// indicator is fully hidden. The child is only the indicator shape; icons
/// and labels stay outside this widget.
class MorphSelectionIndicator extends StatefulWidget {
  /// MorphSelectionIndicator.
  const MorphSelectionIndicator({
    required this.selected,
    required this.child,
    this.scaleSpring = MorphMotion.expressiveSpatialDefault,
    this.fadeSpring = MorphMotion.effectsFast,
    super.key,
  });

  /// Whether this destination is selected.
  final bool selected;

  /// Indicator shape. It is scaled and faded; it is not the icon or label.
  final Widget child;

  /// Spatial spring for the width scale.
  final MorphSpring scaleSpring;

  /// Effects spring for the fade.
  final MorphSpring fadeSpring;

  @override
  State<MorphSelectionIndicator> createState() =>
      _MorphSelectionIndicatorState();
}

class _MorphSelectionIndicatorState extends State<MorphSelectionIndicator>
    with TickerProviderStateMixin {
  static const double _restScale = 0.64;

  late final SingleMotionController _scale;
  late final SingleMotionController _fade;

  SpringMotion _scaleMotion(MorphSpring spring) =>
      MorphMotion.springMotion(spring);

  SpringMotion _fadeMotion(MorphSpring spring) =>
      MorphMotion.springMotion(spring);

  @override
  void initState() {
    super.initState();
    final bool selected = widget.selected;
    _scale = MorphMotionController(
      motion: _scaleMotion(widget.scaleSpring),
      vsync: this,
      initialValue: selected ? 1 : _restScale,
    );
    _fade = MorphMotionController(
      motion: _fadeMotion(widget.fadeSpring),
      vsync: this,
      initialValue: selected ? 1 : 0,
    );
  }

  @override
  void didUpdateWidget(covariant MorphSelectionIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scaleSpring != widget.scaleSpring) {
      _scale.motion = _scaleMotion(widget.scaleSpring);
    }
    if (oldWidget.fadeSpring != widget.fadeSpring) {
      _fade.motion = _fadeMotion(widget.fadeSpring);
    }
    if (oldWidget.selected == widget.selected) {
      return;
    }
    if (widget.selected) {
      // Animate width and opacity together, matching Compose's separation
      // of spatial and effects motion instead of revealing the fill at once.
      _fade.animateTo(1);
      _scale.animateTo(1);
      return;
    }
    _scale.animateTo(_restScale);
    _fade.animateTo(0);
  }

  @override
  void dispose() {
    _scale.dispose();
    _fade.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge(<Listenable>[_scale, _fade]),
      builder: (BuildContext context, Widget? child) {
        final double scale = _scale.value.clamp(0.0, 1.0);
        final double opacity = _fade.value.clamp(0, 1);
        return Opacity(
          opacity: opacity,
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.diagonal3Values(scale, 1, 1),
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}
