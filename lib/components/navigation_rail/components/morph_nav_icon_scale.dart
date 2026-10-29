import 'package:flutter/widgets.dart';
import 'package:motor/motor.dart';

import '../../../foundations/interaction/morph_motion_controller.dart';
import '../../../foundations/foundations.dart';
import '../styles/morph_navigation_rail_theme.dart';

/// A spring-driven icon scale transition with a subtle selection pop.
///
/// Resting unselected scale can be customized by navigation bars, while the
/// rail and drawer continue to default to equal-size icons.
class MorphNavIconScale extends StatefulWidget {
  /// MorphNavIconScale.
  const MorphNavIconScale({
    required this.selected,
    this.unselectedScale = 1.0,
    required this.child,
    super.key,
  }) : assert(unselectedScale > 0);

  /// Whether the destination is currently selected.
  final bool selected;

  /// Unselected paint scale; a selected icon always rests at 1.0.
  final double unselectedScale;

  /// child.
  final Widget child;

  @override
  State<MorphNavIconScale> createState() => _MorphNavIconScaleState();
}

class _MorphNavIconScaleState extends State<MorphNavIconScale>
    with SingleTickerProviderStateMixin {
  late SingleMotionController _scale;

  SpringMotion _springMotion(MorphSpring spring) =>
      MorphMotion.springMotion(spring);

  SpringMotion get _motion =>
      _springMotion(MorphTheme.of(context).navigationRailTheme.iconScaleSpring);

  @override
  void initState() {
    super.initState();
    _scale = MorphMotionController(
      motion: _springMotion(MorphNavigationRailTheme.defaults.iconScaleSpring),
      vsync: this,
      initialValue: widget.selected ? 1.0 : widget.unselectedScale,
    );
  }

  @override
  void didUpdateWidget(covariant MorphNavIconScale oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selected != widget.selected ||
        oldWidget.unselectedScale != widget.unselectedScale) {
      _scale.motion = _motion;
      // Keep the original subtle pop when both states are at equal size.
      // Otherwise animate continuously from the old resting scale, so an
      // inactive icon grows towards 1.0 while the former active icon shrinks.
      if (!oldWidget.selected &&
          widget.selected &&
          oldWidget.unselectedScale == 1.0 &&
          widget.unselectedScale == 1.0) {
        _scale.value = 0.98;
      }
      _scale.animateTo(widget.selected ? 1.0 : widget.unselectedScale);
    }
  }

  @override
  void dispose() {
    _scale.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reducedMotion = MorphMotion.reduceMotionOf(context);
    return AnimatedBuilder(
      animation: _scale,
      builder: (BuildContext context, Widget? child) {
        final scale = reducedMotion
            ? (widget.selected ? 1.0 : widget.unselectedScale)
            : _scale.value;
        return Transform.scale(scale: scale, child: child);
      },
      child: widget.child,
    );
  }
}
