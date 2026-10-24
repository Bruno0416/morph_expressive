import 'package:flutter/widgets.dart';
import 'package:motor/motor.dart';

import '../../../foundations/interaction/morph_motion_controller.dart';
import '../../../foundations/foundations.dart';
import '../styles/morph_navigation_rail_theme.dart';

/// Subtle scale pop on the newly selected icon (≈1.0 → 1.08 → 1.0).
class MorphNavIconScale extends StatefulWidget {
  /// MorphNavIconScale.
  const MorphNavIconScale({
    required this.selected,
    required this.child,
    super.key,
  });

  /// selected.

  final bool selected;

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
      initialValue: 1,
    );
  }

  @override
  void didUpdateWidget(covariant MorphNavIconScale oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.selected && widget.selected) {
      // Overshoot spring from slightly under 1 — no shrink-first dip.
      _scale
        ..motion = _motion
        ..value = 0.98
        ..animateTo(1);
    }
  }

  @override
  void dispose() {
    _scale.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scale,
      builder: (BuildContext context, Widget? child) {
        return Transform.scale(scale: _scale.value, child: child);
      },
      child: widget.child,
    );
  }
}
