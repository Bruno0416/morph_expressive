import 'package:flutter/widgets.dart';

/// Values a card group shares with each card.
class MorphCardGroupScope extends InheritedWidget {
  /// Creates a group scope.
  const MorphCardGroupScope({
    required this.vertical,
    required super.child,
    this.restingElevation,
    this.dragged = false,
    super.key,
  });

  /// When true, media sits above the text instead of beside it.
  final bool vertical;

  /// Resting elevation shared by cards that do not set their own.
  final double? restingElevation;

  /// Whether this card is the one currently picked up.
  final bool dragged;

  /// The nearest group scope, if any.
  static MorphCardGroupScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<MorphCardGroupScope>();
  }

  @override
  bool updateShouldNotify(MorphCardGroupScope oldWidget) {
    return vertical != oldWidget.vertical ||
        restingElevation != oldWidget.restingElevation ||
        dragged != oldWidget.dragged;
  }
}
