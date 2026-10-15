import 'package:material_ui/material_ui.dart';

import '../../../foundations/foundations.dart';
import '../enums/morph_navigation_rail_enums.dart';
import '../models/morph_navigation_rail_destination.dart';
import 'morph_rail_item_button.dart';

/// Single rail item (private to package). One class per file.
class MorphRailItem extends StatelessWidget {
  /// Creates a single navigation rail item.
  const MorphRailItem({
    super.key,
    required this.destination,
    required this.selected,
    required this.onTap,
    required this.expanded,
    required this.labelBehavior,
    this.suppressInk = false,
    this.focusNode,
    this.skipTraversal = false,
  });

  /// Destination data driving this item.
  final MorphNavigationRailDestination destination;

  /// Whether this item is currently selected.
  final bool selected;

  /// Called when the item is tapped.
  final VoidCallback onTap;

  /// Whether the rail is expanded (shows label and badges inline).
  final bool expanded;

  /// Whether this item's label should be visible.
  final MorphNavigationRailLabelBehavior labelBehavior;

  /// When true, disables the splash while the rail width is changing.
  final bool suppressInk;

  /// Focus node owned by the rail.
  final FocusNode? focusNode;

  /// When true, Tab skips this destination.
  final bool skipTraversal;

  @override
  Widget build(BuildContext context) {
    final theme = MorphTheme.of(context).navigationRailTheme;
    final bool unlabeled =
        destination.short ||
        labelBehavior == MorphNavigationRailLabelBehavior.alwaysHide;
    final height = expanded
        ? theme.itemExpandedHeight
        : unlabeled
        ? theme.shortItemHeight
        : theme.itemCollapsedHeight;

    final Widget button = MorphRailItemButton(
      icon: destination.icon,
      selectedIcon: destination.selectedIcon,
      isSelected: selected,
      onPressed: onTap,
      expanded: expanded,
      labelBehavior: labelBehavior,
      label: destination.label,
      semanticLabel: destination.semanticLabel,
      suppressInk: suppressInk,
      badgeCount: destination.badgeCount,
      short: destination.short,
      focusNode: focusNode,
      skipTraversal: skipTraversal,
    );

    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: height),
      child: button,
    );
  }
}
