import 'package:flutter/widgets.dart';

import '../../selection/controllers/morph_selection_controller.dart';
import '../enums/morph_list_selection_enums.dart';
import '../styles/morph_list_selection_state.dart';

/// Applies single/multiple selection semantics and notifies [onChanged].
void applyListSelectionToggle({
  required MorphSelectionController controller,
  required int index,
  required MorphListSelectionMode mode,
  ValueChanged<Set<int>>? onChanged,
}) {
  if (mode == MorphListSelectionMode.single) {
    final bool wasSelected = controller.isSelected(index);
    controller.clear();
    if (!wasSelected) {
      controller.select(index);
    }
  } else {
    controller.toggle(index);
  }
  onChanged?.call(controller.selectedIndices);
}

/// Effective selection state (widget override over theme).
MorphListSelectionState mergeListSelectionState({
  required MorphListSelectionState theme,
  MorphListSelectionState? override,
}) => override ?? theme;
