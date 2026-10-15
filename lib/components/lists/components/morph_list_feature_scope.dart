import 'package:flutter/widgets.dart';

import '../../selection/controllers/morph_selection_controller.dart';
import '../styles/morph_list_reorder_state.dart';
import '../styles/morph_list_selection_state.dart';

/// Provides list selection/reorder config to descendants (e.g. list items).
class MorphListFeatureScope extends InheritedWidget {
  /// Creates a list feature scope.
  const MorphListFeatureScope({
    required this.selectionEnabled,
    required this.reorderEnabled,
    required this.selectionState,
    required this.reorderState,
    required this.controller,
    required this.itemCount,
    required this.onToggleSelection,
    required super.child,
    super.key,
  });

  /// Whether selection features are active.
  final bool selectionEnabled;

  /// Whether reorder features are active.
  final bool reorderEnabled;

  /// Selection visuals / triggers.
  final MorphListSelectionState selectionState;

  /// Reorder visuals / motion.
  final MorphListReorderState reorderState;

  /// Selection controller (may be owned by ancestor or list).
  final MorphSelectionController? controller;

  /// Total top-level items.
  final int itemCount;

  /// Toggles selection for the given index.
  final void Function(int index) onToggleSelection;

  /// Nearest scope, or null.
  static MorphListFeatureScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<MorphListFeatureScope>();
  }

  /// Whether the given index is selected.
  bool isSelected(int index) => controller?.isSelected(index) ?? false;

  /// Whether leading flip is available (selection on + selectedIcon set).
  bool get flipsLeading =>
      selectionEnabled && controller != null && selectionState.hasSelectedIcon;

  @override
  bool updateShouldNotify(MorphListFeatureScope oldWidget) {
    return selectionEnabled != oldWidget.selectionEnabled ||
        reorderEnabled != oldWidget.reorderEnabled ||
        selectionState != oldWidget.selectionState ||
        reorderState != oldWidget.reorderState ||
        controller != oldWidget.controller ||
        itemCount != oldWidget.itemCount ||
        controller?.selectedIndices != oldWidget.controller?.selectedIndices;
  }
}

/// Row index for the current list item under a feature scope.
class MorphListItemIndex extends InheritedWidget {
  /// Creates an index scope.
  const MorphListItemIndex({
    required this.index,
    required super.child,
    super.key,
  });

  /// Top-level list index.
  final int index;

  /// Nearest index, or null.
  static int? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<MorphListItemIndex>()
        ?.index;
  }

  @override
  bool updateShouldNotify(MorphListItemIndex oldWidget) =>
      index != oldWidget.index;
}
