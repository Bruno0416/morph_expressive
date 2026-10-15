import 'package:flutter/widgets.dart';

import '../../../foundations/foundations.dart';
import '../models/morph_menu_node.dart';
import '../styles/morph_menu_theme.dart';
import 'morph_menu_divider.dart';
import 'morph_menu_node_builders.dart';
import 'morph_menu_style_scope.dart';

/// Callback when a menu node produces a selection result.
typedef MorphMenuSelectCallback = void Function(Object? value);

/// Callback to open a cascading submenu from an item rect.
typedef MorphMenuOpenSubmenuCallback = void Function(
  Rect anchorRect,
  List<MorphMenuNode> children,
);

/// Renders a tree of [MorphMenuNode]s inside one elevated menu surface.
class MorphMenuContent extends StatelessWidget {
  /// MorphMenuContent.
  const MorphMenuContent({
    required this.nodes,
    required this.onSelect,
    required this.closeOnSelect,
    this.onOpenSubmenu,
    this.selectedValue,
    this.applyGroupShapes = true,
    this.autofocusFirst = true,
    this.sectionLabel,
    super.key,
  });

  /// nodes.

  final List<MorphMenuNode> nodes;

  /// onSelect.
  final MorphMenuSelectCallback onSelect;

  /// closeOnSelect.
  final bool closeOnSelect;

  /// onOpenSubmenu.
  final MorphMenuOpenSubmenuCallback? onOpenSubmenu;

  /// selectedValue.
  final Object? selectedValue;

  /// applyGroupShapes.
  final bool applyGroupShapes;

  /// autofocusFirst.
  final bool autofocusFirst;

  /// Optional section header drawn above [nodes] (callout 9).
  final String? sectionLabel;

  @override
  Widget build(BuildContext context) {
    final theme = MorphTheme.of(context);
    final menuTheme = theme.menuTheme;
    final children = <Widget>[];
    var focused = false;

    if (sectionLabel != null) {
      children.add(_sectionLabel(context, sectionLabel!, menuTheme));
    }

    for (var i = 0; i < nodes.length; i++) {
      final node = nodes[i];
      if (i > 0 && node is MorphMenuGroup) {
        children.add(SizedBox(height: menuTheme.groupSpacing));
      }
      children.addAll(
        _buildNode(
          context,
          node,
          menuTheme,
          requestFocus: autofocusFirst && !focused,
          onFocused: () => focused = true,
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: _withGaps(children, menuTheme),
    );
  }

  List<Widget> _withGaps(List<Widget> children, MorphMenuTheme menuTheme) {
    if (menuTheme.itemGap <= 0 || children.length < 2) {
      return children;
    }
    final gapped = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      if (i > 0) {
        gapped.add(SizedBox(height: menuTheme.itemGap));
      }
      gapped.add(children[i]);
    }
    return gapped;
  }

  Widget _sectionLabel(
    BuildContext context,
    String label,
    MorphMenuTheme menuTheme,
  ) {
    final theme = MorphTheme.of(context);
    final style = MorphMenuStyleScope.styleOf(context);
    return SizedBox(
      height: menuTheme.groupLabelHeight,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal:
              menuTheme.stateLayerInset + menuTheme.groupLabelHorizontalPadding,
          vertical: menuTheme.groupLabelVerticalPadding,
        ),
        child: Align(
          alignment: AlignmentDirectional.centerStart,
          child: Text(
            label,
            style: menuTheme.groupLabelStyle(
              theme.typeScale,
              theme.colorScheme,
              style,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }

  List<Widget> _buildNode(
    BuildContext context,
    MorphMenuNode node,
    MorphMenuTheme menuTheme, {
    required bool requestFocus,
    required VoidCallback onFocused,
  }) {
    return switch (node) {
      MorphMenuDivider() => const <Widget>[MorphMenuDividerWidget()],
      MorphMenuGroup(:final label, :final children) => _buildGroup(
        context,
        label,
        children,
        menuTheme,
        requestFocus: requestFocus,
        onFocused: onFocused,
      ),
      MorphMenuEntry entry => _entryNode(entry, requestFocus, onFocused),
      MorphMenuSelectable item => _selectableNode(
        item,
        menuTheme,
        requestFocus,
        onFocused,
      ),
      MorphMenuToggleable item => _toggleableNode(
        item,
        menuTheme,
        requestFocus,
        onFocused,
      ),
      MorphMenuSubmenu item => _submenuNode(
        item,
        menuTheme,
        requestFocus,
        onFocused,
      ),
      MorphMenuWidget item => _widgetNode(
        context,
        item,
        menuTheme,
        requestFocus,
        onFocused,
      ),
    };
  }

  List<Widget> _entryNode(
    MorphMenuEntry entry,
    bool requestFocus,
    VoidCallback onFocused,
  ) {
    return _leaf(
      requestFocus: requestFocus,
      enabled: entry.enabled,
      onFocused: onFocused,
      child: MorphMenuNodeBuilders.entry(
        entry,
        autofocus: requestFocus && entry.enabled,
        onSelect: onSelect,
      ),
    );
  }

  List<Widget> _selectableNode(
    MorphMenuSelectable item,
    MorphMenuTheme menuTheme,
    bool requestFocus,
    VoidCallback onFocused,
  ) {
    final selected =
        item.selected || (selectedValue != null && selectedValue == item.value);
    return _leaf(
      requestFocus: requestFocus,
      enabled: item.enabled,
      onFocused: onFocused,
      child: MorphMenuNodeBuilders.selectable(
        item,
        selected: selected,
        autofocus: requestFocus && item.enabled,
        menuTheme: menuTheme,
        onSelect: onSelect,
      ),
    );
  }

  List<Widget> _toggleableNode(
    MorphMenuToggleable item,
    MorphMenuTheme menuTheme,
    bool requestFocus,
    VoidCallback onFocused,
  ) {
    return _leaf(
      requestFocus: requestFocus,
      enabled: item.enabled,
      onFocused: onFocused,
      child: MorphMenuNodeBuilders.toggleable(
        item,
        autofocus: requestFocus && item.enabled,
        menuTheme: menuTheme,
        onSelect: onSelect,
      ),
    );
  }

  List<Widget> _submenuNode(
    MorphMenuSubmenu item,
    MorphMenuTheme menuTheme,
    bool requestFocus,
    VoidCallback onFocused,
  ) {
    return _leaf(
      requestFocus: requestFocus,
      enabled: item.enabled,
      onFocused: onFocused,
      child: MorphMenuNodeBuilders.submenu(
        item,
        autofocus: requestFocus && item.enabled,
        menuTheme: menuTheme,
        onOpenSubmenu: onOpenSubmenu,
      ),
    );
  }

  List<Widget> _widgetNode(
    BuildContext context,
    MorphMenuWidget item,
    MorphMenuTheme menuTheme,
    bool requestFocus,
    VoidCallback onFocused,
  ) {
    return _leaf(
      requestFocus: requestFocus,
      enabled: item.enabled,
      onFocused: onFocused,
      child: MorphMenuNodeBuilders.customWidget(
        context,
        item,
        autofocus: requestFocus && item.enabled,
        menuTheme: menuTheme,
        onSelect: (Object? value) {
          if (closeOnSelect || value != null) {
            onSelect(value);
          }
        },
      ),
    );
  }

  List<Widget> _leaf({
    required bool requestFocus,
    required bool enabled,
    required VoidCallback onFocused,
    required Widget child,
  }) {
    if (requestFocus && enabled) {
      onFocused();
    }
    return <Widget>[child];
  }

  List<Widget> _buildGroup(
    BuildContext context,
    String? label,
    List<MorphMenuNode> children,
    MorphMenuTheme menuTheme, {
    required bool requestFocus,
    required VoidCallback onFocused,
  }) {
    final out = <Widget>[];
    if (label != null) {
      out.add(_sectionLabel(context, label, menuTheme));
    }

    final shaped = <MorphMenuNode>[];
    for (var i = 0; i < children.length; i++) {
      final child = children[i];
      if (!applyGroupShapes) {
        shaped.add(child);
        continue;
      }
      shaped.add(
        _withShape(child, menuTheme.shapeForIndex(i, children.length)),
      );
    }

    var focus = requestFocus;
    for (final child in shaped) {
      out.addAll(
        _buildNode(
          context,
          child,
          menuTheme,
          requestFocus: focus,
          onFocused: () {
            focus = false;
            onFocused();
          },
        ),
      );
    }
    return out;
  }

  MorphMenuNode _withShape(MorphMenuNode node, MorphMenuItemShape shape) {
    return switch (node) {
      MorphMenuEntry e => MorphMenuEntry(
        label: e.label,
        leading: e.leading,
        trailing: e.trailing,
        trailingText: e.trailingText,
        badge: e.badge,
        supportingText: e.supportingText,
        onPressed: e.onPressed,
        enabled: e.enabled,
        isDestructive: e.isDestructive,
        value: e.value,
        shape: shape,
      ),
      MorphMenuSelectable e => MorphMenuSelectable(
        label: e.label,
        value: e.value,
        leading: e.leading,
        trailing: e.trailing,
        trailingText: e.trailingText,
        badge: e.badge,
        supportingText: e.supportingText,
        selected: e.selected,
        onPressed: e.onPressed,
        enabled: e.enabled,
        shape: shape,
      ),
      MorphMenuToggleable e => MorphMenuToggleable(
        label: e.label,
        checked: e.checked,
        leading: e.leading,
        trailing: e.trailing,
        trailingText: e.trailingText,
        badge: e.badge,
        supportingText: e.supportingText,
        onChanged: e.onChanged,
        enabled: e.enabled,
        shape: shape,
      ),
      MorphMenuSubmenu e => MorphMenuSubmenu(
        label: e.label,
        children: e.children,
        leading: e.leading,
        badge: e.badge,
        enabled: e.enabled,
        shape: shape,
      ),
      MorphMenuWidget e => MorphMenuWidget(
        child: e.child,
        value: e.value,
        onPressed: e.onPressed,
        enabled: e.enabled,
        selected: e.selected,
        semanticLabel: e.semanticLabel,
        shape: shape,
      ),
      _ => node,
    };
  }
}
