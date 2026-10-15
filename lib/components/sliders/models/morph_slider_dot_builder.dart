import 'package:flutter/widgets.dart';
import 'package:morph_expressive/components/sliders/morph_sliders.dart'
    show MorphRangeSlider, MorphSlider;
import 'package:morph_expressive/morph_components.dart'
    show MorphRangeSlider, MorphSlider;

/// Builds a custom stop/tick marker for [MorphSlider] / [MorphRangeSlider].
///
/// [color] is the resolved stop/tick color. [size] is the default marker size.
/// [active] is true when the marker sits on the active track segment.
typedef MorphSliderDotBuilder = Widget Function({
  required BuildContext context,
  required Color color,
  required double size,
  required bool active,
});
