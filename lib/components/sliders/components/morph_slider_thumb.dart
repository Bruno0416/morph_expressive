import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:morph_expressive/components/sliders/morph_sliders.dart'
    show MorphRangeSlider, MorphSlider;
import 'package:morph_expressive/morph_components.dart'
    show MorphRangeSlider, MorphSlider;
import 'package:motor/motor.dart';

import '../../../foundations/foundations.dart';
import '../res/morph_slider_tokens.dart';
import '../styles/morph_slider_theme.dart';

/// Expressive bar handle for [MorphSlider] / [MorphRangeSlider].
///
/// The short axis springs from 4 to 2 while [pressed] or [focused]. Hover
/// keeps the resting width and does not paint a fill.
class MorphSliderThumb extends StatefulWidget {
  /// MorphSliderThumb.
  const MorphSliderThumb({
    required this.color,
    required this.pressed,
    this.focused = false,
    this.hovered = false,
    this.overlap = false,
    this.overlapColor,
    this.axis = Axis.horizontal,
    this.width,
    this.height,
    this.pressedThickness,
    super.key,
  });

  /// color.

  final Color color;

  /// pressed.
  final bool pressed;

  /// Whether keyboard focus chrome is showing.
  final bool focused;

  /// Whether the pointer is over the slider.
  final bool hovered;

  /// Whether this range handle overlaps the other handle.
  final bool overlap;

  /// Outline color used when [overlap] is true.
  final Color? overlapColor;

  /// axis.
  final Axis axis;

  /// Resting thumb width (cross-axis for vertical). Defaults to token sizes.
  final double? width;

  /// Resting thumb height (main-axis for vertical). Defaults to token sizes.
  final double? height;

  /// Pressed and focused thickness along the short axis.
  final double? pressedThickness;

  @override
  State<MorphSliderThumb> createState() => _MorphSliderThumbState();
}

class _MorphSliderThumbState extends State<MorphSliderThumb>
    with SingleTickerProviderStateMixin {
  late final SingleMotionController _short;

  @override
  void initState() {
    super.initState();
    _short = SingleMotionController(motion: _motion(), vsync: this)
      ..value = _target;
    _short.addListener(_onTick);
  }

  @override
  void didUpdateWidget(MorphSliderThumb oldWidget) {
    super.didUpdateWidget(oldWidget);
    final next = _target;
    if ((_short.value - next).abs() < 0.01) {
      return;
    }
    _short.motion = _motion();
    _short.animateTo(next);
  }

  @override
  void dispose() {
    _short.removeListener(_onTick);
    _short.dispose();
    super.dispose();
  }

  void _onTick() {
    if (mounted) {
      setState(() {});
    }
  }

  SpringMotion _motion() {
    final spring = MorphSliderTheme.defaults.dockSpring;
    return MorphMotion.springMotion(spring);
  }

  double get _target {
    final vertical = widget.axis == Axis.vertical;
    final resting = vertical
        ? (widget.height ?? MorphSliderTokens.verticalHandleHeight)
        : (widget.width ?? MorphSliderTokens.handleWidth);
    if (widget.pressed || widget.focused) {
      return widget.pressedThickness ?? MorphSliderTokens.pressedHandleWidth;
    }
    return resting;
  }

  @override
  Widget build(BuildContext context) {
    final theme = MorphTheme.of(context);
    final sliderTheme = theme.sliderTheme;
    final vertical = widget.axis == Axis.vertical;
    final long = vertical
        ? (widget.width ?? MorphSliderTokens.verticalHandleWidth)
        : (widget.height ?? MorphSliderTokens.handleHeight);
    final short = _short.value;
    final w = vertical ? long : short;
    final h = vertical ? short : long;
    final radius = math.max(w, h) / 2;
    final outline = widget.overlap
        ? Border.all(
            color: widget.overlapColor ?? theme.colorScheme.onPrimary,
            width: sliderTheme.overlapOutlineWidth,
          )
        : null;
    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        color: widget.color,
        borderRadius: BorderRadius.circular(radius),
        border: outline,
      ),
    );
  }
}
