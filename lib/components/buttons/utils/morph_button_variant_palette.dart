import 'package:flutter/widgets.dart';

import '../../../foundations/foundations.dart';
import '../enums/morph_button_enums.dart';

/// Maps a [MorphVariantPalette] onto the slots of a [MorphButtonStyle]
/// (resting, non-toggle state).
///
/// | Style | Container | Content |
/// | --- | --- | --- |
/// | filled | color | onColor |
/// | tonal | container | onContainer |
/// | elevated | surfaceContainerLow | accent |
/// | outlined / text | transparent | accent |
extension MorphButtonVariantPalette on MorphVariantPalette {
  /// Resting container color for [style].
  Color containerFor(MorphColorScheme scheme, MorphButtonStyle style) =>
      switch (style) {
        MorphButtonStyle.filled => color,
        MorphButtonStyle.tonal => container,
        MorphButtonStyle.elevated => scheme.surfaceContainerLow,
        MorphButtonStyle.outlined ||
        MorphButtonStyle.text => const Color(0x00000000),
      };

  /// Resting content color for [style].
  Color contentFor(MorphButtonStyle style) => switch (style) {
    MorphButtonStyle.filled => onColor,
    MorphButtonStyle.tonal => onContainer,
    MorphButtonStyle.elevated ||
    MorphButtonStyle.outlined ||
    MorphButtonStyle.text => accent,
  };
}
