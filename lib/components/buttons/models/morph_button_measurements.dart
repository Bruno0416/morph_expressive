import 'package:flutter/foundation.dart';

import '../../../foundations/tokens/morph_density.dart';
import '../enums/morph_button_enums.dart';

/// Resolved layout measurements for a button size variant.
@immutable
class MorphButtonMeasurements {
  /// MorphButtonMeasurements.
  const MorphButtonMeasurements({
    required this.height,
    required this.hPadding,
    required this.iconSize,
    required this.iconGap,
    this.outlineWidth = 2,
  });

  /// height.
  final double height;

  /// hPadding.
  final double hPadding;

  /// iconSize.
  final double iconSize;

  /// iconGap.
  final double iconGap;

  /// Outline stroke width for outlined buttons (dp).
  final double outlineWidth;

  /// Applies the global [metrics] to these token measurements.
  ///
  /// [step] is the size step (xs = 0 ... xl = 4). Resolved once, in the theme
  /// layer; widgets must consume the result without scaling it again.
  MorphButtonMeasurements withDensity(MorphDensityMetrics metrics, int step) {
    return MorphButtonMeasurements(
      height: MorphDensityMetrics.adjust(
        height,
        metrics.controlHeightFor(step),
        min: 24,
      ),
      hPadding: MorphDensityMetrics.adjust(hPadding, metrics.paddingHorizontal),
      iconSize: MorphDensityMetrics.adjust(iconSize, metrics.iconSize, min: 16),
      iconGap: MorphDensityMetrics.adjust(iconGap, metrics.gap),
      outlineWidth: outlineWidth,
    );
  }

  /// applyCustomSize.

  MorphButtonMeasurements applyCustomSize(MorphButtonSize? custom) {
    if (custom == null) {
      return this;
    }
    return MorphButtonMeasurements(
      height: custom.height ?? height,
      hPadding: custom.hPadding ?? hPadding,
      iconSize: custom.iconSize ?? iconSize,
      iconGap: custom.iconGap ?? iconGap,
      outlineWidth: custom.outlineWidth ?? outlineWidth,
    );
  }
}
