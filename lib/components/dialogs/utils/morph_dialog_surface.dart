import 'package:flutter/widgets.dart';

import '../../../foundations/foundations.dart';

/// [color] with an optional elevation-scaled [tint] layer.
Color morphDialogTinted(Color color, Color? tint, double elevation) {
  if (tint == null || elevation <= 0) {
    return color;
  }
  final double alpha = switch (elevation) {
    < MorphElevation.level2 => 0.05,
    < MorphElevation.level3 => 0.08,
    < MorphElevation.level4 => 0.11,
    < MorphElevation.level5 => 0.12,
    _ => 0.14,
  };
  return Color.alphaBlend(tint.withValues(alpha: alpha), color);
}
