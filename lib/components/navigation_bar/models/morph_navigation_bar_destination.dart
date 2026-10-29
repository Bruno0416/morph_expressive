import 'package:material_ui/material_ui.dart' show Icon, IconData, Widget;

import '../components/morph_nav_badge_view.dart';

/// A single destination in the Morph navigation bar.
///
/// Provide an [IconData] in [icon] or a non-empty [label].
///
/// For custom icon content, use [iconWidget] instead of [icon].
/// The two options are mutually exclusive.
class MorphNavigationBarDestination {
  /// Creates a navigation destination from icon data or a custom icon widget.
  const MorphNavigationBarDestination({
    this.icon,
    this.label,
    this.selectedIcon,
    this.iconWidget,
    this.selectedIconWidget,
    this.badgeCount,
    this.badgeDot = false,
    this.semanticLabel,
  }) : assert(
         icon != null ||
             iconWidget != null ||
             (label != null && label.length > 0),
         'Provide an icon and/or a non-empty label',
       ),
       assert(
         icon == null || iconWidget == null,
         'Use icon or iconWidget, not both',
       ),
       assert(
         selectedIcon == null || selectedIconWidget == null,
         'Use selectedIcon or selectedIconWidget, not both',
       );

  /// Icon glyph used for this destination. An [Icon] is created internally.
  final IconData? icon;

  /// Optional glyph used when this destination is selected.
  final IconData? selectedIcon;

  /// Custom icon widget alternative to [icon].
  ///
  /// Use only when rendering requires more than an [IconData].
  final Widget? iconWidget;

  /// Custom selected icon widget alternative to [selectedIcon].
  final Widget? selectedIconWidget;

  /// label.
  final String? label;

  /// Optional badge counter.
  final int? badgeCount;

  /// If true, show a small dot instead of a counter.
  final bool badgeDot;

  /// semanticLabel.
  final String? semanticLabel;

  /// Resolved semantics string for the destination.
  String get resolvedSemanticLabel {
    if (semanticLabel != null && semanticLabel!.isNotEmpty) {
      return semanticLabel!;
    }
    if (label != null && label!.isNotEmpty) {
      return label!;
    }
    return 'Destination';
  }

  /// Whether this destination has a usable icon or custom icon widget.
  bool get hasIcon => icon != null || iconWidget != null;

  /// Whether this destination has a non-empty label.
  bool get hasLabel => label != null && label!.isNotEmpty;

  /// buildIcon.
  Widget buildIcon({bool selected = false}) {
    assert(hasIcon, 'Destination has no icon');
    final Widget base;
    if (selected && selectedIconWidget != null) {
      base = selectedIconWidget!;
    } else if (selected && selectedIcon != null) {
      base = Icon(selectedIcon);
    } else if (iconWidget != null) {
      base = iconWidget!;
    } else {
      base = Icon(icon);
    }
    if (badgeCount != null || badgeDot) {
      return MorphNavBadge(count: badgeCount, showDot: badgeDot, child: base);
    }
    return base;
  }
}
