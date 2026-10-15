import 'package:morph_expressive/components/menus/morph_menus.dart'
    show MorphMenu;
import 'package:morph_expressive/morph_components.dart' show MorphMenu;

/// How many items an [MorphMenu] may keep selected.
enum MorphMenuSelectionMode {
  /// One selected item. Choosing an item closes the menu when
  /// `closeOnSelect` is true.
  single,

  /// Many selected items. The menu stays open until it is dismissed.
  multi,
}
