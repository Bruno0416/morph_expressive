import 'package:morph_expressive/components/split_buttons/styles/morph_split_button_decoration.dart'
    show MorphSplitButtonDecoration;

/// Menu presentation style used by [MorphSplitButtonDecoration.menuStyle].
enum MorphSplitButtonMenuStyle {
  /// Spring-animated popup menu anchored to the trailing segment.
  popup,

  /// Modal bottom sheet menu.
  bottomSheet,

  /// Native Flutter popup menu.
  native,
}
