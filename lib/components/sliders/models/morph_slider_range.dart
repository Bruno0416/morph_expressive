import 'package:flutter/foundation.dart';
import 'package:morph_expressive/components/sliders/morph_range_slider.dart'
    show MorphRangeSlider;
import 'package:morph_expressive/components/sliders/morph_sliders.dart'
    show MorphRangeSlider;
import 'package:morph_expressive/morph_components.dart' show MorphRangeSlider;

/// A continuous range with [start] ≤ [end], used by [MorphRangeSlider].
@immutable
class MorphSliderRange {
  /// MorphSliderRange.
  const MorphSliderRange(this.start, this.end)
    : assert(start <= end, 'start must be ≤ end');

  /// start.

  final double start;

  /// end.
  final double end;

  /// copyWith.

  MorphSliderRange copyWith({double? start, double? end}) {
    return MorphSliderRange(start ?? this.start, end ?? this.end);
  }

  @override
  bool operator ==(Object other) {
    return other is MorphSliderRange &&
        other.start == start &&
        other.end == end;
  }

  @override
  int get hashCode => Object.hash(start, end);

  @override
  String toString() => 'MorphSliderRange($start, $end)';
}
