import 'package:flutter/widgets.dart';

import 'controllers/morph_toolbar_visibility_controller.dart';
import 'enums/morph_toolbar_enums.dart';

/// Integrates scroll notifications with a [MorphToolbarVisibilityController].
class MorphToolbarScrollBehavior {
  /// MorphToolbarScrollBehavior.
  const MorphToolbarScrollBehavior({
    this.exitDirection = MorphToolbarExitDirection.bottom,
    required this.controller,
    this.action = MorphToolbarScrollAction.hide,
  });

  /// Creates a behavior that exits (slides away) while scrolling (opt-in).
  factory MorphToolbarScrollBehavior.exitAlways({
    MorphToolbarExitDirection exitDirection = MorphToolbarExitDirection.bottom,
    MorphToolbarVisibilityController? controller,
  }) {
    return MorphToolbarScrollBehavior(
      exitDirection: exitDirection,
      controller: controller ?? MorphToolbarVisibilityController(),
    );
  }

  /// Creates a behavior that collapses to the adjacent FAB / expand-trigger
  /// action while scrolling (opt-in), instead of sliding the whole pill away.
  ///
  /// Requires the toolbar to have an adjacent FAB (with
  /// `MorphToolbar.fabExpandsToolbar` true) or an
  /// `MorphToolbarAction.isExpandTrigger` action — asserted in debug builds.
  factory MorphToolbarScrollBehavior.collapseAlways({
    MorphToolbarVisibilityController? controller,
  }) {
    return MorphToolbarScrollBehavior(
      controller: controller ?? MorphToolbarVisibilityController(),
      action: MorphToolbarScrollAction.collapse,
    );
  }

  /// Direction the toolbar slides when hiding. Unused when [action] is
  /// `MorphToolbarScrollAction.collapse`.
  final MorphToolbarExitDirection exitDirection;

  /// Shared visibility state (manual
  /// [MorphToolbarVisibilityController.show] /
  /// [MorphToolbarVisibilityController.hide] or scroll-driven).
  final MorphToolbarVisibilityController controller;

  /// Whether scrolling slides the pill away (`hide`, default) or collapses
  /// it to the adjacent FAB / expand-trigger action (`collapse`).
  ///
  /// The two are mutually exclusive by construction — pick one via
  /// [MorphToolbarScrollBehavior.exitAlways] or
  /// [MorphToolbarScrollBehavior.collapseAlways]. Pass the same behavior to the
  /// toolbar and its [MorphToolbarScrollWrapper]; a collapse request reaching a
  /// scroll-exit toolbar is asserted in debug builds.
  final MorphToolbarScrollAction action;
}

/// Listens to [ScrollNotification]s on [child] and updates [behavior].
///
/// Place this around the scrollable content, not around the toolbar itself.
/// The toolbar reads the same [MorphToolbarScrollBehavior.controller].
class MorphToolbarScrollWrapper extends StatefulWidget {
  /// MorphToolbarScrollWrapper.
  const MorphToolbarScrollWrapper({
    required this.behavior,
    required this.child,
    super.key,
  });

  /// behavior.
  final MorphToolbarScrollBehavior behavior;

  /// child.
  final Widget child;

  @override
  State<MorphToolbarScrollWrapper> createState() =>
      _MorphToolbarScrollWrapperState();
}

class _MorphToolbarScrollWrapperState extends State<MorphToolbarScrollWrapper> {
  bool _handleScrollNotification(ScrollNotification notification) {
    if (notification is ScrollUpdateNotification) {
      _handleScrollUpdate(notification);
    }
    return false;
  }

  /// Triggers the instant the scroll delta changes direction, at any scroll
  /// position and at any drag speed:
  /// [MorphToolbarScrollAction.hide] springs the pill fully open/closed
  /// ([MorphToolbarVisibilityController.show] / [MorphToolbarVisibilityController.hide]
  /// are no-ops when already at or heading to that target, so repeated
  /// deltas in the same direction don't restart the spring);
  /// [MorphToolbarScrollAction.collapse] flips the collapse-request flag
  /// instead, which the toolbar mirrors onto its own expand state.
  void _handleScrollUpdate(ScrollUpdateNotification notification) {
    final double? delta = notification.scrollDelta;
    if (delta == null || delta == 0) {
      return;
    }
    final MorphToolbarVisibilityController controller =
        widget.behavior.controller;
    final bool hiding = delta > 0;
    switch (widget.behavior.action) {
      case MorphToolbarScrollAction.hide:
        if (hiding) {
          controller.hide();
        } else {
          controller.show();
        }
      case MorphToolbarScrollAction.collapse:
        if (hiding) {
          controller.requestCollapse();
        } else {
          controller.requestExpand();
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: _handleScrollNotification,
      child: widget.child,
    );
  }
}
