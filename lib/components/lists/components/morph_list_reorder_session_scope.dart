import 'package:flutter/widgets.dart';

/// Whether an ancestor reorder host currently has an active drag.
///
/// [active] is updated synchronously when a drag begins/ends so gesture
/// callbacks can gate before the next frame.
class MorphListReorderSessionScope extends InheritedWidget {
  /// Creates a reorder session scope.
  const MorphListReorderSessionScope({
    required this.active,
    required super.child,
    super.key,
  });

  /// True while a reorder drag is in progress.
  final ValueNotifier<bool> active;

  /// Nearest session (registers a dependency). Prefer [isActive] in callbacks.
  static MorphListReorderSessionScope? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<MorphListReorderSessionScope>();
  }

  /// Whether a reorder drag is active above [context] (safe outside build).
  static bool isActive(BuildContext context) {
    final MorphListReorderSessionScope? scope = context
        .getInheritedWidgetOfExactType<MorphListReorderSessionScope>();
    return scope?.active.value ?? false;
  }

  @override
  bool updateShouldNotify(MorphListReorderSessionScope oldWidget) =>
      active != oldWidget.active;
}
