import 'package:flutter/widgets.dart';

/// Marks descendants as content inside a list row surface.
///
/// List items read this scope to skip their own surface when the parent list
/// already owns the outermost surface. When [padsChild] is true, the parent
/// already applied padding and the item does not add its own.
class MorphListItemScope extends InheritedWidget {
  /// MorphListItemScope.
  const MorphListItemScope({
    required super.child,
    this.padsChild = false,
    super.key,
  });

  /// Whether the parent surface already padded the row.
  final bool padsChild;

  /// Nearest scope, or null.
  static MorphListItemScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<MorphListItemScope>();

  @override
  bool updateShouldNotify(MorphListItemScope oldWidget) =>
      padsChild != oldWidget.padsChild;
}
