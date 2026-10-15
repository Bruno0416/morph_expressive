import 'package:flutter/widgets.dart';

import '../../../foundations/foundations.dart';

/// Interaction snapshot for the current list row.
class MorphListInteractionScope extends InheritedWidget {
  /// Creates a row interaction scope.
  const MorphListInteractionScope({
    required this.state,
    required this.enabled,
    required this.selected,
    required super.child,
    super.key,
  });

  /// Hover, focus, press, and drag.
  final MorphInteractionState state;

  /// Whether the row accepts input.
  final bool enabled;

  /// Whether the row is selected.
  final bool selected;

  /// Nearest scope, or a resting snapshot.
  static MorphListInteractionScope? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<MorphListInteractionScope>();
  }

  @override
  bool updateShouldNotify(MorphListInteractionScope oldWidget) {
    return state != oldWidget.state ||
        enabled != oldWidget.enabled ||
        selected != oldWidget.selected;
  }
}
