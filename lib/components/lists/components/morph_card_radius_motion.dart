import 'package:flutter/widgets.dart';
import 'package:motor/motor.dart';

import '../../../foundations/foundations.dart';
import '../styles/morph_list_theme.dart';

/// Springs a card's [BorderRadius] with the expressive spatial motion.
class MorphCardRadiusMotion extends StatefulWidget {
  /// MorphCardRadiusMotion.
  const MorphCardRadiusMotion({
    required this.radius,
    required this.builder,
    this.snap = false,
    this.motion,
    super.key,
  });

  /// Target corner radii.
  final BorderRadius radius;

  /// When true, the target is applied immediately (e.g. while dragging).
  final bool snap;

  /// Override spring; defaults to [MorphListCardListTheme.radiusSpring].
  final MorphSpring? motion;

  /// Builds the card with the animated radius.
  final Widget Function(BuildContext context, BorderRadius radius) builder;

  @override
  State<MorphCardRadiusMotion> createState() => _MorphCardRadiusMotionState();
}

class _MorphCardRadiusMotionState extends State<MorphCardRadiusMotion>
    with TickerProviderStateMixin {
  late final SingleMotionController _controller;
  late BorderRadius _from;
  late BorderRadius _to;

  SpringMotion _toMotion(MorphSpring spring) =>
      MorphMotion.springMotion(spring);

  SpringMotion get _motion {
    final spring =
        widget.motion ??
        (mounted
            ? MorphTheme.of(context).listTheme.cardList.radiusSpring
            : MorphListCardListTheme.defaults.radiusSpring);
    return _toMotion(spring);
  }

  @override
  void initState() {
    super.initState();
    _from = widget.radius;
    _to = widget.radius;
    _controller = SingleMotionController(
      motion: _toMotion(
        widget.motion ?? MorphListCardListTheme.defaults.radiusSpring,
      ),
      vsync: this,
      initialValue: 1,
    );
  }

  @override
  void didUpdateWidget(covariant MorphCardRadiusMotion oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.snap) {
      _from = widget.radius;
      _to = widget.radius;
      _controller.value = 1;
      return;
    }
    if (oldWidget.radius == widget.radius &&
        oldWidget.motion == widget.motion) {
      return;
    }
    _from = BorderRadius.lerp(_from, _to, _controller.value) ?? _to;
    _to = widget.radius;
    _controller
      ..motion = _motion
      ..value = 0
      ..animateTo(1);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.snap) {
      return widget.builder(context, widget.radius);
    }
    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget? _) {
        final BorderRadius radius =
            BorderRadius.lerp(_from, _to, _controller.value) ?? _to;
        return widget.builder(context, radius);
      },
    );
  }
}
