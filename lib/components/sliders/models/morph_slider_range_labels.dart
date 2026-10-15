import 'package:flutter/foundation.dart';
import 'package:morph_expressive/components/sliders/morph_range_slider.dart'
    show MorphRangeSlider;
import 'package:morph_expressive/components/sliders/morph_sliders.dart'
    show MorphRangeSlider;
import 'package:morph_expressive/morph_components.dart'
    show MorphRangeSlider;

/// Optional labels for the start and end thumbs of [MorphRangeSlider].
@immutable
class MorphSliderRangeLabels {
  /// MorphSliderRangeLabels.
  const MorphSliderRangeLabels(this.start, this.end);

  /// start.

  final String start;

  /// end.
  final String end;
}
