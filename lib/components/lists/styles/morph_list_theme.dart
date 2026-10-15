import 'package:flutter/widgets.dart';

import '../../../foundations/foundations.dart';
import 'morph_list_card_list_theme.dart';
import 'morph_list_dismissible_theme.dart';
import 'morph_list_expandable_theme.dart';
import 'morph_list_item_theme.dart';
import 'morph_list_reorder_state.dart';
import 'morph_list_selection_state.dart';

export 'morph_list_card_list_theme.dart';
export 'morph_list_dismissible_theme.dart';
export 'morph_list_expandable_theme.dart';
export 'morph_list_item_theme.dart';

/// Theme values for list-family widgets.
@immutable
class MorphListTheme extends MorphThemeExtension<MorphListTheme> {
  /// MorphListTheme.
  const MorphListTheme({
    this.item = MorphListItemTheme.defaults,
    this.cardList = MorphListCardListTheme.defaults,
    this.dismissible = MorphListDismissibleTheme.defaults,
    this.expandable = MorphListExpandableTheme.defaults,
    this.selection = MorphListSelectionState.defaults,
    this.reorder = MorphListReorderState.defaults,
  });

  /// defaults.

  static const MorphListTheme defaults = MorphListTheme();

  /// item.

  final MorphListItemTheme item;

  /// cardList.
  final MorphListCardListTheme cardList;

  /// dismissible.
  final MorphListDismissibleTheme dismissible;

  /// expandable.
  final MorphListExpandableTheme expandable;

  /// Selection visuals and triggers for list variants.
  final MorphListSelectionState selection;

  /// Reorder visuals and motion for list variants.
  final MorphListReorderState reorder;

  @override
  MorphListTheme copyWith({
    MorphListItemTheme? item,
    MorphListCardListTheme? cardList,
    MorphListDismissibleTheme? dismissible,
    MorphListExpandableTheme? expandable,
    MorphListSelectionState? selection,
    MorphListReorderState? reorder,
  }) {
    return MorphListTheme(
      item: item ?? this.item,
      cardList: cardList ?? this.cardList,
      dismissible: dismissible ?? this.dismissible,
      expandable: expandable ?? this.expandable,
      selection: selection ?? this.selection,
      reorder: reorder ?? this.reorder,
    );
  }

  @override
  MorphListTheme lerp(MorphListTheme? other, double t) {
    if (other is! MorphListTheme) {
      return this;
    }
    if (t < 0.5) {
      return this;
    }
    return other;
  }
}
