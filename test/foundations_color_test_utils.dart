import 'package:flutter/widgets.dart';
import 'package:morph_expressive/morph_expressive.dart';

/// Seeds covering the hue wheel plus the extremes that stress tonal palettes.
///
/// Values are inputs only; no test asserts an exact generated ARGB literal.
const Map<String, Color> kFoundationsSeeds = <String, Color>{
  'blue': Color(0xFF2196F3),
  'violet': Color(0xFF7C4DFF),
  'green': Color(0xFF4CAF50),
  'red': Color(0xFFF44336),
  'yellow': Color(0xFFFFEB3B),
  'gray': Color(0xFF9E9E9E),
  'very light': Color(0xFFFFFDE7),
  'very dark': Color(0xFF050505),
  'low chroma': Color(0xFF7A7F8C),
  'high chroma': Color(0xFF00FF40),
};

/// Every role of [scheme] by name, used for whole-scheme comparisons because
/// [MorphColorScheme] intentionally does not define value equality.
Map<String, Color> morphRoles(MorphColorScheme s) => <String, Color>{
  'primary': s.primary,
  'onPrimary': s.onPrimary,
  'primaryContainer': s.primaryContainer,
  'onPrimaryContainer': s.onPrimaryContainer,
  'secondary': s.secondary,
  'onSecondary': s.onSecondary,
  'secondaryContainer': s.secondaryContainer,
  'onSecondaryContainer': s.onSecondaryContainer,
  'tertiary': s.tertiary,
  'onTertiary': s.onTertiary,
  'tertiaryContainer': s.tertiaryContainer,
  'onTertiaryContainer': s.onTertiaryContainer,
  'error': s.error,
  'onError': s.onError,
  'errorContainer': s.errorContainer,
  'onErrorContainer': s.onErrorContainer,
  'surface': s.surface,
  'onSurface': s.onSurface,
  'onSurfaceVariant': s.onSurfaceVariant,
  'surfaceContainerLowest': s.surfaceContainerLowest,
  'surfaceContainerLow': s.surfaceContainerLow,
  'surfaceContainer': s.surfaceContainer,
  'surfaceContainerHigh': s.surfaceContainerHigh,
  'surfaceContainerHighest': s.surfaceContainerHighest,
  'surfaceDim': s.surfaceDim,
  'surfaceBright': s.surfaceBright,
  'inverseSurface': s.inverseSurface,
  'onInverseSurface': s.onInverseSurface,
  'inversePrimary': s.inversePrimary,
  'outline': s.outline,
  'outlineVariant': s.outlineVariant,
  'shadow': s.shadow,
  'scrim': s.scrim,
  'surfaceTint': s.surfaceTint,
  'emphasis': s.emphasis,
  'onEmphasis': s.onEmphasis,
  'info': s.info,
  'success': s.success,
  'warning': s.warning,
  'danger': s.danger,
  'surfaceStrong': s.surfaceStrong,
  'onSurfaceStrong': s.onSurfaceStrong,
  'outlineStrong': s.outlineStrong,
};

/// WCAG 2.x contrast ratio between two opaque colors.
double contrastRatio(Color a, Color b) {
  final double la = a.computeLuminance();
  final double lb = b.computeLuminance();
  final double lighter = la > lb ? la : lb;
  final double darker = la > lb ? lb : la;
  return (lighter + 0.05) / (darker + 0.05);
}
