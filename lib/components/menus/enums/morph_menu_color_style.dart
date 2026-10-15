import 'package:morph_expressive/components/menus/morph_menus.dart'
    show MorphMenu;
import 'package:morph_expressive/morph_components.dart' show MorphMenu;

/// Standard vs vibrant container color mapping for [MorphMenu].
enum MorphMenuColorStyle {
  /// Surface container low + on-surface / on-surface-variant content.
  standard,

  /// Tertiary container surface; tertiary selected item (Compose vibrant menu).
  vibrant,

  /// Neutral surface with primary selection accents (e.g. split-button popup).
  primary,
}
