import 'package:flutter/widgets.dart';

/// Replaces a list item's trailing slot with one widget.
///
/// Expandable rows use this so the expand icon is the only trailing icon.
class MorphListTrailingOverride extends InheritedWidget {
  /// MorphListTrailingOverride.
  const MorphListTrailingOverride({
    required super.child,
    this.trailing,
    super.key,
  });

  /// The only trailing widget. Null clears the slot.
  final Widget? trailing;

  /// Nearest override, or null when the item owns its trailing.
  static MorphListTrailingOverride? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<MorphListTrailingOverride>();
  }

  @override
  bool updateShouldNotify(MorphListTrailingOverride oldWidget) =>
      trailing != oldWidget.trailing;
}
