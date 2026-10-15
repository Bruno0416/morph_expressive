import 'package:flutter/widgets.dart';

/// When true, expandable items jump expand progress instead of springing.
///
/// Used to collapse a row before reorder drag measures extent.
class MorphExpandableSnapCollapse extends InheritedWidget {
  /// Creates a snap-collapse scope.
  const MorphExpandableSnapCollapse({
    required this.snap,
    required super.child,
    super.key,
  });

  /// Whether expand/collapse updates should snap.
  final bool snap;

  /// Nearest snap flag, or false when absent.
  static bool of(BuildContext context) {
    return context
            .dependOnInheritedWidgetOfExactType<MorphExpandableSnapCollapse>()
            ?.snap ??
        false;
  }

  @override
  bool updateShouldNotify(MorphExpandableSnapCollapse oldWidget) =>
      snap != oldWidget.snap;
}
