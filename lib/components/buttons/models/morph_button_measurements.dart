import 'package:flutter/foundation.dart';

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
