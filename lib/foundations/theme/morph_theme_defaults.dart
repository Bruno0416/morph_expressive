import 'package:flutter/foundation.dart';

import '../color/morph_color_scheme.dart';
import '../type/morph_typography.dart';
import 'morph_theme_data.dart';

/// Assembles a complete [MorphThemeData] from core tokens and component defaults.
MorphThemeData buildMorphThemeDefaults({
  MorphColorScheme? colorScheme,
  MorphTypography? typography,
  MorphTypeScale? typeScale,
  double visualDensity = 0,
  TargetPlatform? platform,
  bool useMaterial3 = true,
}) {
  return MorphThemeData(
    colorScheme: colorScheme,
    typography: typography,
    typeScale: typeScale,
    visualDensity: visualDensity,
    platform: platform,
    useMaterial3: useMaterial3,
  );
}
