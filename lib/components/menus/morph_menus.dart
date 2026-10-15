import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../foundations/foundations.dart';
import 'components/morph_menu_popup.dart';
import 'enums/morph_menu_anchor_position.dart';
import 'enums/morph_menu_color_style.dart';
import 'enums/morph_menu_selection_mode.dart';
import 'enums/morph_menu_variant.dart';
import 'models/morph_menu_node.dart';
import 'utils/morph_menu_overlay_rect.dart';

export 'components/morph_menu_content.dart';
export 'components/morph_menu_divider.dart';
export 'components/morph_menu_item.dart';
export 'components/morph_menu_popup.dart';
export 'enums/morph_menu_anchor_position.dart';
export 'enums/morph_menu_color_style.dart';
export 'enums/morph_menu_item_shape.dart';
export 'enums/morph_menu_selection_mode.dart';
export 'enums/morph_menu_variant.dart';
export 'models/morph_menu_node.dart';
export 'styles/morph_menu_theme.dart';
export 'utils/morph_menu_overlay_rect.dart';
export 'utils/morph_menu_placer.dart';
export 'utils/morph_menu_spring_motion.dart';

/// Builds the anchor for an [MorphMenu], given a callback to open the menu.
typedef MorphMenuAnchorBuilder = Widget Function(
  BuildContext context,
  VoidCallback open,
);

/// A Material 3 Expressive menu (Compose `DropdownMenu` + `DropdownMenuPopup`).
///
/// Displays a temporary surface of [children] anchored to a widget built by
/// [anchorBuilder]. The menu springs open from the anchor and closes when an
/// entry is chosen or the scrim is tapped.
class MorphMenu extends StatefulWidget {
  /// MorphMenu.
  const MorphMenu({
    required this.anchorBuilder,
    this.children,
    this.entries,
    this.position = MorphMenuAnchorPosition.bottomStart,
    this.colorStyle = MorphMenuColorStyle.standard,
    this.variant = MorphMenuVariant.vertical,
    this.selectionMode = MorphMenuSelectionMode.single,
    this.closeOnSelect = true,
    this.onSelected,
    this.selectedValue,
    super.key,
  }) : assert(
         children != null || entries != null,
         'Provide children or entries.',
       );

  /// Convenience constructor for a flat list of action [MorphMenuEntry]s.
  factory MorphMenu.entries({
    Key? key,
    required MorphMenuAnchorBuilder anchorBuilder,
    required List<MorphMenuEntry> entries,
    MorphMenuAnchorPosition position = MorphMenuAnchorPosition.bottomStart,
    MorphMenuColorStyle colorStyle = MorphMenuColorStyle.standard,
    MorphMenuVariant variant = MorphMenuVariant.vertical,
    MorphMenuSelectionMode selectionMode = MorphMenuSelectionMode.single,
    bool closeOnSelect = true,
    ValueChanged<Object?>? onSelected,
    Object? selectedValue,
  }) {
    return MorphMenu(
      key: key,
      anchorBuilder: anchorBuilder,
      children: entries,
      position: position,
      colorStyle: colorStyle,
      variant: variant,
      selectionMode: selectionMode,
      closeOnSelect: closeOnSelect,
      onSelected: onSelected,
      selectedValue: selectedValue,
    );
  }

  /// anchorBuilder.

  final MorphMenuAnchorBuilder anchorBuilder;

  /// Full menu content tree (items, groups, dividers, submenus).
  final List<MorphMenuNode>? children;

  /// Convenience alias for a flat list of [MorphMenuEntry] action rows.
  final List<MorphMenuEntry>? entries;

  /// position.

  final MorphMenuAnchorPosition position;

  /// Standard (surface) vs vibrant (tertiary) color mapping.
  final MorphMenuColorStyle colorStyle;

  /// Vertical or baseline layout.
  final MorphMenuVariant variant;

  /// Single-select closes according to [closeOnSelect]. Multi-select stays open.
  final MorphMenuSelectionMode selectionMode;

  /// closeOnSelect.

  final bool closeOnSelect;

  /// onSelected.
  final ValueChanged<Object?>? onSelected;

  /// selectedValue.
  final Object? selectedValue;

  List<MorphMenuNode> get _nodes => children ?? entries!;

  @override
  State<MorphMenu> createState() => _MorphMenuState();
}

class _MorphMenuState extends State<MorphMenu> {
  final GlobalKey _anchorKey = GlobalKey();
  final FocusNode _anchorFocus = FocusNode(debugLabel: 'MorphMenuAnchor');
  OverlayEntry? _menuEntry;
  bool _open = false;

  bool get _multi => widget.selectionMode == MorphMenuSelectionMode.multi;

  @override
  void didUpdateWidget(covariant MorphMenu oldWidget) {
    super.didUpdateWidget(oldWidget);
    final OverlayEntry? entry = _menuEntry;
    if (entry == null) {
      return;
    }
    // The parent often setStates from onSelected while this menu is building.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (entry.mounted) {
        entry.markNeedsBuild();
      }
    });
  }

  @override
  void dispose() {
    _anchorFocus.dispose();
    super.dispose();
  }

  Future<void> _openMenu() async {
    if (_open) {
      return;
    }
    final BuildContext? anchorContext = _anchorKey.currentContext;
    final Rect? anchor = anchorContext == null
        ? null
        : morphOverlayRectFor(anchorContext);
    if (anchor == null) {
      return;
    }
    setState(() => _open = true);

    final bool stayOpen = _multi || !widget.closeOnSelect;
    final result = await showMorphMenu<Object>(
      context: context,
      anchor: anchor,
      children: widget._nodes,
      readChildren: () => widget._nodes,
      position: widget.position,
      colorStyle: widget.colorStyle,
      variant: widget.variant,
      selectionMode: widget.selectionMode,
      closeOnSelect: !stayOpen && widget.closeOnSelect,
      selectedValue: widget.selectedValue,
      callerFocusNode: _focusedAnchorNode(),
      onItemChosen: stayOpen ? widget.onSelected : null,
      onEntry: (OverlayEntry entry) => _menuEntry = entry,
    );

    _menuEntry = null;
    if (mounted) {
      setState(() => _open = false);
    }
    if (result != null && !stayOpen) {
      widget.onSelected?.call(result);
    }
  }

  FocusNode _focusedAnchorNode() {
    final FocusNode? current = FocusManager.instance.primaryFocus;
    if (current == null) {
      return _anchorFocus;
    }
    if (current == _anchorFocus || current.ancestors.contains(_anchorFocus)) {
      return current;
    }
    return _anchorFocus;
  }

  KeyEventResult _onAnchorKey(FocusNode node, KeyEvent event) {
    if (_open || event is! KeyDownEvent) {
      return KeyEventResult.ignored;
    }
    final key = event.logicalKey;
    final bool openKey =
        key == LogicalKeyboardKey.arrowDown ||
        key == LogicalKeyboardKey.arrowUp ||
        key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.space;
    if (!openKey) {
      return KeyEventResult.ignored;
    }
    _openMenu();
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    return MorphComponentTheme(
      builder: (BuildContext context) {
        return KeyedSubtree(
          key: _anchorKey,
          child: Focus(
            focusNode: _anchorFocus,
            canRequestFocus: false,
            skipTraversal: true,
            onKeyEvent: _onAnchorKey,
            child: widget.anchorBuilder(context, _openMenu),
          ),
        );
      },
    );
  }
}
