import 'package:flutter/widgets.dart';

import '../controllers/morph_selection_controller.dart';

/// Provides the active [MorphSelectionController] to descendant selection widgets.
class MorphSelectionScope extends InheritedWidget {
  /// Creates a selection scope.
  const MorphSelectionScope({
    required this.controller,
    required this.itemCount,
    required super.child,
    super.key,
  });

  /// Shared selection controller.
  final MorphSelectionController controller;

  /// Item count from the wired selection list (for select-all).
  final int itemCount;

  /// The nearest scope, or null.
  static MorphSelectionScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<MorphSelectionScope>();
  }

  /// The nearest scope; throws if missing.
  static MorphSelectionScope of(BuildContext context) {
    final scope = maybeOf(context);
    assert(
      scope != null,
      'MorphSelectionScope.of() called with no MorphSelectionScope ancestor.',
    );
    return scope!;
  }

  @override
  bool updateShouldNotify(MorphSelectionScope oldWidget) {
    return controller != oldWidget.controller ||
        itemCount != oldWidget.itemCount;
  }
}
