import 'package:material_ui/material_ui.dart' show Brightness, Color;
import 'package:morph_expressive/morph_expressive.dart';

/// Named seed colors used by the Widgetbook theme addon.
///
/// Every entry generates a real [MorphThemeData]; none of them is a
/// preview-only palette.
const morphSeedPresets = <String, Color>{
  'Violet': Color(0xFF6750A4),
  'Blue': Color(0xFF1E6FEB),
  'Green': Color(0xFF2E7D32),
  'Red': Color(0xFFD32F2F),
  'Yellow': Color(0xFFF9C80E),
  'Teal': Color(0xFF00897B),
  'Gray': Color(0xFF808080),
  'Near black': Color(0xFF101010),
  'Near white': Color(0xFFFAFAFA),
};

/// Name of the default preset (Material baseline violet).
const morphDefaultSeedName = 'Violet';

/// Parses `#RRGGBB`, `RRGGBB` or `#AARRGGBB`; returns null when invalid.
Color? parseHexColor(String input) {
  final text = input.trim().replaceFirst('#', '');
  if (text.length != 6 && text.length != 8) return null;
  final value = int.tryParse(text, radix: 16);
  if (value == null) return null;
  return Color(text.length == 6 ? 0xFF000000 | value : value);
}

/// Resolves the effective seed from a preset name and an optional custom hex.
Color resolveSeed(String presetName, String customHex) {
  return parseHexColor(customHex) ??
      morphSeedPresets[presetName] ??
      morphSeedPresets[morphDefaultSeedName]!;
}

/// Builds the real Morph theme for [seed] and [brightness].
MorphThemeData buildMorphTheme(
  Color seed,
  Brightness brightness, {
  bool reduceMotion = false,
  MorphDensity density = MorphDensity.standard,
}) {
  final base = brightness == Brightness.dark
      ? MorphThemeData.dark(seedColor: seed)
      : MorphThemeData.light(seedColor: seed);
  return base.copyWith(reduceMotion: reduceMotion, density: density);
}
