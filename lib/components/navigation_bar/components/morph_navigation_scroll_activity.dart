import 'package:flutter/widgets.dart';

/// Shares scroll activity with the glass surface without rebuilding the body
/// for every scroll delta. Only start/end changes notify the bar.
class MorphNavigationScrollActivity
    extends InheritedNotifier<ValueNotifier<bool>> {
  const MorphNavigationScrollActivity({
    required ValueNotifier<bool> activity,
    required super.child,
    super.key,
  }) : super(notifier: activity);

  static bool isScrollingOf(BuildContext context) =>
      context
          .dependOnInheritedWidgetOfExactType<MorphNavigationScrollActivity>()
          ?.notifier
          ?.value ??
      false;
}
