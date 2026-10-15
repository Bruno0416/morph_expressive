import 'package:flutter/widgets.dart';

import '../controllers/morph_button_group_overflow_controller.dart';

/// Shares the group's [MorphButtonGroupOverflowController] with descendants.
///
/// Inserted by `MorphButtonGroup` for overflow menu / paging internals.
class MorphButtonGroupProvider extends InheritedWidget {
  /// Creates a provider for [controller].
  const MorphButtonGroupProvider({
    super.key,
    required this.controller,
    required super.child,
  });

  /// Reactive overflow / paging controller for this group.
  final MorphButtonGroupOverflowController controller;

  /// Nearest controller, or null outside a group.
  static MorphButtonGroupOverflowController? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<MorphButtonGroupProvider>()
        ?.controller;
  }

  /// Nearest controller; throws if none is found.
  static MorphButtonGroupOverflowController of(BuildContext context) {
    final controller = maybeOf(context);
    assert(
      controller != null,
      'MorphButtonGroupProvider.of() called with no MorphButtonGroupProvider '
      'ancestor.\nEnsure the widget is a descendant of MorphButtonGroup.',
    );
    return controller!;
  }

  @override
  bool updateShouldNotify(MorphButtonGroupProvider oldWidget) {
    return controller != oldWidget.controller;
  }
}
