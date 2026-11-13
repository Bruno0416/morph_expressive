import 'package:flutter/foundation.dart';

/// How a submenu row opens its submenu.
enum MorphMenuSubmenuOpenMode {
  /// Mouse hover opens the submenu after [MorphMenuSubmenuBehavior.hoverDelay];
  /// click / tap, keyboard and touch still open it immediately.
  hover,

  /// Only click / tap and keyboard open it (hover does nothing).
  click,
}

/// Submenu opening policy of a menu, shared by every cascade level.
///
/// Touch always uses tap. In [MorphMenuSubmenuOpenMode.hover] a click on an
/// already open (or pending) submenu row keeps it open instead of toggling.
@immutable
class MorphMenuSubmenuBehavior {
  /// Creates a submenu policy (defaults: hover, 200 ms open, 250 ms close).
  const MorphMenuSubmenuBehavior({
    this.mode = MorphMenuSubmenuOpenMode.hover,
    this.hoverDelay = const Duration(milliseconds: 200),
    this.closeDelay = const Duration(milliseconds: 250),
  });

  /// Hover or click.
  final MorphMenuSubmenuOpenMode mode;

  /// Delay before a hovered submenu row opens its submenu (avoids accidental
  /// opening while crossing rows).
  final Duration hoverDelay;

  /// Grace period after the pointer leaves the parent/submenu pair before the
  /// submenu closes (covers the cross between them).
  final Duration closeDelay;

  @override
  bool operator ==(Object other) =>
      other is MorphMenuSubmenuBehavior &&
      other.mode == mode &&
      other.hoverDelay == hoverDelay &&
      other.closeDelay == closeDelay;

  @override
  int get hashCode => Object.hash(mode, hoverDelay, closeDelay);
}
