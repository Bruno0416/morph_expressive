import 'package:flutter/widgets.dart';

import 'morph_menu_key_target.dart';

/// Shares the open menu's focus targets with each row.
class MorphMenuKeyScope extends InheritedWidget {
  /// Creates a scope over [targets].
  const MorphMenuKeyScope({
    required this.targets,
    required super.child,
    super.key,
  });

  /// Rows in visual order. Mutated as rows mount and unmount.
  final List<MorphMenuKeyTarget> targets;

  /// The nearest scope, or null when the row is not inside a menu popup.
  static MorphMenuKeyScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<MorphMenuKeyScope>();
  }

  @override
  bool updateShouldNotify(covariant MorphMenuKeyScope oldWidget) {
    return targets != oldWidget.targets;
  }
}
