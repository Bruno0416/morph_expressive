import 'package:flutter/widgets.dart';
import 'package:morph_expressive/components/menus/morph_menus.dart'
    show MorphMenu;
import 'package:morph_expressive/morph_components.dart' show MorphMenu;

import '../enums/morph_menu_item_shape.dart';

export '../enums/morph_menu_item_shape.dart';

/// A node in an [MorphMenu] content tree.
@immutable
sealed class MorphMenuNode {
  const MorphMenuNode();
}

/// Standard action row (Compose `DropdownMenuItem`).
@immutable
class MorphMenuEntry extends MorphMenuNode {
  /// MorphMenuEntry.
  const MorphMenuEntry({
    required this.label,
    this.leading,
    this.trailing,
    this.trailingText,
    this.badge,
    this.supportingText,
    this.onPressed,
    this.enabled = true,
    this.isDestructive = false,
    this.value,
    this.shape = MorphMenuItemShape.standalone,
  });

  /// label.

  final String label;

  /// leading.
  final Widget? leading;

  /// trailing.
  final Widget? trailing;

  /// Shortcut / secondary trailing label (e.g. `⌘C`).
  final String? trailingText;

  /// Optional status chip before trailing icon/text.
  final Widget? badge;

  /// supportingText.

  final String? supportingText;

  /// onPressed.
  final VoidCallback? onPressed;

  /// enabled.
  final bool enabled;

  /// isDestructive.
  final bool isDestructive;

  /// Optional result returned by `showMorphMenu` when this entry is chosen.
  final Object? value;

  /// shape.

  final MorphMenuItemShape shape;
}

/// Single-select row with a trailing check when selected.
@immutable
class MorphMenuSelectable extends MorphMenuNode {
  /// MorphMenuSelectable.
  const MorphMenuSelectable({
    required this.label,
    required this.value,
    this.leading,
    this.trailing,
    this.trailingText,
    this.badge,
    this.supportingText,
    this.selected = false,
    this.onPressed,
    this.enabled = true,
    this.shape = MorphMenuItemShape.standalone,
  });

  /// label.

  final String label;

  /// value.
  final Object value;

  /// leading.
  final Widget? leading;

  /// trailing.
  final Widget? trailing;

  /// trailingText.
  final String? trailingText;

  /// badge.
  final Widget? badge;

  /// supportingText.
  final String? supportingText;

  /// selected.
  final bool selected;

  /// onPressed.
  final VoidCallback? onPressed;

  /// enabled.
  final bool enabled;

  /// shape.
  final MorphMenuItemShape shape;
}

/// Toggleable row (Compose checked menu item).
@immutable
class MorphMenuToggleable extends MorphMenuNode {
  /// MorphMenuToggleable.
  const MorphMenuToggleable({
    required this.label,
    required this.checked,
    this.leading,
    this.trailing,
    this.trailingText,
    this.badge,
    this.supportingText,
    this.onChanged,
    this.enabled = true,
    this.shape = MorphMenuItemShape.standalone,
  });

  /// label.

  final String label;

  /// checked.
  final bool checked;

  /// leading.
  final Widget? leading;

  /// trailing.
  final Widget? trailing;

  /// trailingText.
  final String? trailingText;

  /// badge.
  final Widget? badge;

  /// supportingText.
  final String? supportingText;

  /// onChanged.
  final ValueChanged<bool>? onChanged;

  /// enabled.
  final bool enabled;

  /// shape.
  final MorphMenuItemShape shape;
}

/// Horizontal rule between menu sections inside one elevated surface.
@immutable
class MorphMenuDivider extends MorphMenuNode {
  /// MorphMenuDivider.
  const MorphMenuDivider();
}

/// Elevated surface / subgroup of items with optional section [label].
///
/// Each top-level [MorphMenuGroup] becomes its own elevated menu container;
/// consecutive non-group nodes share one implicit surface.
@immutable
class MorphMenuGroup extends MorphMenuNode {
  /// MorphMenuGroup.
  const MorphMenuGroup({required this.children, this.label});

  /// Alias that names the item list [entries] (maps to [children]).
  const MorphMenuGroup.entries({
    required List<MorphMenuNode> entries,
    this.label,
  }) : children = entries;

  /// label.

  final String? label;

  /// children.
  final List<MorphMenuNode> children;
}

/// Cascading submenu opened from a parent row.
@immutable
class MorphMenuSubmenu extends MorphMenuNode {
  /// MorphMenuSubmenu.
  const MorphMenuSubmenu({
    required this.label,
    required this.children,
    this.leading,
    this.badge,
    this.enabled = true,
    this.shape = MorphMenuItemShape.standalone,
  });

  /// label.

  final String label;

  /// leading.
  final Widget? leading;

  /// badge.
  final Widget? badge;

  /// children.
  final List<MorphMenuNode> children;

  /// enabled.
  final bool enabled;

  /// shape.
  final MorphMenuItemShape shape;
}

/// Row whose body is an arbitrary [child] (host-provided content).
@immutable
class MorphMenuWidget extends MorphMenuNode {
  /// MorphMenuWidget.
  const MorphMenuWidget({
    required this.child,
    this.value,
    this.onPressed,
    this.enabled = true,
    this.selected = false,
    this.semanticLabel,
    this.shape = MorphMenuItemShape.standalone,
  });

  /// child.

  final Widget child;

  /// value.
  final Object? value;

  /// onPressed.
  final VoidCallback? onPressed;

  /// enabled.
  final bool enabled;

  /// selected.
  final bool selected;

  /// semanticLabel.
  final String? semanticLabel;

  /// shape.
  final MorphMenuItemShape shape;
}

/// Partitions top-level menu nodes into elevated surface groups.
List<MorphMenuGroup> morphMenuPartitionSurfaces(List<MorphMenuNode> nodes) {
  if (nodes.isEmpty) {
    return const <MorphMenuGroup>[];
  }
  final surfaces = <MorphMenuGroup>[];
  var flatRun = <MorphMenuNode>[];

  void flushFlat() {
    if (flatRun.isEmpty) {
      return;
    }
    surfaces.add(MorphMenuGroup(children: List<MorphMenuNode>.of(flatRun)));
    flatRun = <MorphMenuNode>[];
  }

  for (final node in nodes) {
    if (node is MorphMenuGroup) {
      flushFlat();
      surfaces.add(node);
    } else {
      flatRun.add(node);
    }
  }
  flushFlat();
  return surfaces;
}
