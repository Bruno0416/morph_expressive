import 'package:flutter/widgets.dart';

import '../../../foundations/foundations.dart';
import '../../selection/components/morph_selection_flip.dart';
import '../components/morph_list_feature_scope.dart';
import '../components/morph_list_key_target.dart';
import '../components/morph_list_keyboard.dart';
import '../components/morph_list_trailing_override.dart';
import '../enums/morph_list_selection_enums.dart';

/// Resolves leading widget for list selection flip (leading only).
///
/// Flips between [leading] and the selection icon when selection is enabled.
/// Otherwise returns [leading] unchanged.
Widget? morphResolveListLeading({
  required BuildContext context,
  required int? index,
  required Widget? leading,
}) {
  if (index == null) {
    return leading;
  }
  final MorphListFeatureScope? scope = MorphListFeatureScope.maybeOf(context);
  if (scope == null || !scope.selectionEnabled) {
    return leading;
  }
  final iconTrigger =
      scope.selectionState.trigger == MorphListSelectionTrigger.icon;
  if (!scope.selectionState.hasSelectedIcon && !iconTrigger) {
    return leading;
  }

  final single = scope.selectionState.mode == MorphListSelectionMode.single;
  final Widget selectedIcon =
      scope.selectionState.selectedIcon ??
      Icon(single ? MorphIcons.radio_button_checked : MorphIcons.check_box);
  final Widget child =
      leading ??
      Icon(
        single
            ? MorphIcons.radio_button_unchecked
            : MorphIcons.check_box_outline_blank,
      );
  final bool selected = scope.isSelected(index);
  final VoidCallback? onIconTap = iconTrigger
      ? () => scope.onToggleSelection(index)
      : null;

  final Widget flip = MorphSelectionFlip(
    selected: selected,
    selectedChild: selectedIcon,
    duration: scope.selectionState.iconFlipDuration,
    onTap: onIconTap,
    child: child,
  );
  if (onIconTap == null || MorphListKeyboardGroup.maybeOf(context) == null) {
    return flip;
  }
  // Arrow-reachable row action instead of its own Tab stop.
  return MorphListKeyTarget(
    index: index,
    onActivate: onIconTap,
    child: ExcludeFocus(child: flip),
  );
}

/// Resolves trailing widget; reorder drag handle replaces any trailing when on.
///
/// The handle stays in this slot at rest and while the row is dragged.
Widget? morphResolveListTrailing({
  required BuildContext context,
  required Widget? trailing,
}) {
  final MorphListTrailingOverride? override = MorphListTrailingOverride.maybeOf(
    context,
  );
  if (override != null) {
    return override.trailing;
  }
  final MorphListFeatureScope? scope = MorphListFeatureScope.maybeOf(context);
  if (scope == null ||
      !scope.reorderEnabled ||
      !scope.reorderState.showDragHandle) {
    return trailing;
  }

  return const Icon(MorphIcons.drag_handle);
}
