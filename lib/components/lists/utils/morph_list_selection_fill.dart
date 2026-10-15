import 'package:flutter/widgets.dart';

import '../../../foundations/foundations.dart';
import '../../selection/morph_selection.dart';
import '../components/morph_list_feature_scope.dart';

/// Highlight fill for [index] when an enclosing scope has it selected.
///
/// Checks [MorphListFeatureScope] first, then [MorphSelectionScope].
Color? morphSelectionFill(BuildContext context, int index) {
  final MorphThemeData theme = MorphTheme.of(context);
  final MorphListFeatureScope? listScope = MorphListFeatureScope.maybeOf(context);
  if (listScope != null &&
      listScope.selectionEnabled &&
      listScope.isSelected(index)) {
    return listScope.selectionState.selectedColor(theme.colorScheme);
  }

  final MorphSelectionScope? scope = MorphSelectionScope.maybeOf(context);
  if (scope == null || !scope.controller.isSelected(index)) {
    return null;
  }
  return theme.selectionTheme.selectedColor(theme.colorScheme);
}

/// Selected equal-corner radius when list selection is active for [index].
BorderRadius? morphSelectionRadius(
  BuildContext context,
  int index, {
  double? outerRadius,
}) {
  final MorphListFeatureScope? listScope = MorphListFeatureScope.maybeOf(context);
  if (listScope != null &&
      listScope.selectionEnabled &&
      listScope.isSelected(index)) {
    final double radius =
        outerRadius ??
        listScope.selectionState.selectedOuterRadius(
          MorphTheme.of(context).listTheme,
        );
    return BorderRadius.circular(radius);
  }

  final MorphSelectionScope? scope = MorphSelectionScope.maybeOf(context);
  if (scope == null || !scope.controller.isSelected(index)) {
    return null;
  }
  final double radius =
      outerRadius ?? MorphTheme.of(context).listTheme.cardList.outerRadius;
  return BorderRadius.circular(radius);
}
