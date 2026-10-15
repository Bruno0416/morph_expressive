import 'package:flutter/widgets.dart';

/// Marks a dismissible row and lets it reveal its swipe actions without a
/// drag.
class MorphListSwipeOverflow extends InheritedWidget {
  /// Creates a swipe-overflow scope.
  const MorphListSwipeOverflow({this.onReveal, required super.child, super.key});

  /// Opens the action preview. Null when the row has no swipe actions.
  final VoidCallback? onReveal;

  /// Nearest scope, or null when the row is not a dismissible row.
  static MorphListSwipeOverflow? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<MorphListSwipeOverflow>();
  }

  @override
  bool updateShouldNotify(MorphListSwipeOverflow oldWidget) {
    return onReveal != oldWidget.onReveal;
  }
}
