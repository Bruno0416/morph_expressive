import 'package:flutter/widgets.dart';

/// The visible main-axis size of one carousel slot.
class MorphCarouselSlotScope extends InheritedWidget {
  /// MorphCarouselSlotScope.
  const MorphCarouselSlotScope({
    required this.slotMain,
    required super.child,
    super.key,
  });

  /// Current slot length along the scroll axis.
  final double slotMain;

  /// Nearest slot scope, or null.
  static MorphCarouselSlotScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<MorphCarouselSlotScope>();
  }

  @override
  bool updateShouldNotify(MorphCarouselSlotScope oldWidget) =>
      slotMain != oldWidget.slotMain;
}
