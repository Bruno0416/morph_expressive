import 'package:flutter/widgets.dart';

import '../../../foundations/foundations.dart';
import '../enums/morph_list_selection_enums.dart';
import 'morph_list_theme.dart';

/// Visual and interaction defaults for list selection.
@immutable
class MorphListSelectionState {
  /// Creates list selection state.
  const MorphListSelectionState({
    this.mode = MorphListSelectionMode.multiple,
    this.selectedIcon,
    this.trigger = MorphListSelectionTrigger.icon,
    this.highlightColor,
    this.iconFlipDuration = MorphMotion.selectionFlip,
  });

  /// Theme defaults (no selected icon → no leading flip).
  static const MorphListSelectionState defaults = MorphListSelectionState();

  /// Single or multiple selection.
  final MorphListSelectionMode mode;

  /// Optional icon shown when selected; flips with the row's leading widget.
  ///
  /// When null, the leading widget is left unchanged (no flip).
  final Widget? selectedIcon;

  /// How selection is toggled.
  final MorphListSelectionTrigger trigger;

  /// Selected fill override; defaults to secondary container.
  final Color? highlightColor;

  /// Duration of the selection icon flip.
  final Duration iconFlipDuration;

  /// Whether a leading flip can be shown.
  bool get hasSelectedIcon => selectedIcon != null;

  /// Selected card fill.
  Color selectedColor(MorphColorScheme scheme) =>
      highlightColor ?? scheme.secondaryContainer;

  /// Selected equal-corner radius (matches card-list outer radius).
  double selectedOuterRadius(MorphListTheme listTheme) =>
      listTheme.cardList.outerRadius;

  /// copyWith.
  MorphListSelectionState copyWith({
    MorphListSelectionMode? mode,
    Widget? selectedIcon,
    bool clearSelectedIcon = false,
    MorphListSelectionTrigger? trigger,
    Color? highlightColor,
    Duration? iconFlipDuration,
  }) {
    return MorphListSelectionState(
      mode: mode ?? this.mode,
      selectedIcon: clearSelectedIcon
          ? null
          : (selectedIcon ?? this.selectedIcon),
      trigger: trigger ?? this.trigger,
      highlightColor: highlightColor ?? this.highlightColor,
      iconFlipDuration: iconFlipDuration ?? this.iconFlipDuration,
    );
  }
}
