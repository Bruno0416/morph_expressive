import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:flutter/widgets.dart';
import 'package:morph_expressive/components/menus/morph_menus.dart'
    show MorphMenu;
import 'package:morph_expressive/morph_components.dart' show MorphMenu;

import '../../../foundations/foundations.dart';
import '../enums/morph_menu_color_style.dart';
import '../enums/morph_menu_item_shape.dart';
import '../enums/morph_menu_presentation.dart';
import '../styles/morph_menu_theme.dart';
import 'morph_menu_presentation_scope.dart';
import 'morph_menu_style_scope.dart';

/// A single interactive row inside an [MorphMenu] popup.
class MorphMenuItem extends StatelessWidget {
  /// MorphMenuItem.
  const MorphMenuItem({
    required this.label,
    required this.onTap,
    this.leading,
    this.trailing,
    this.trailingText,
    this.badge,
    this.supportingText,
    this.enabled = true,
    this.isDestructive = false,
    this.selected = false,
    this.shape = MorphMenuItemShape.standalone,
    this.autofocus = false,
    this.focusNode,
    super.key,
  });

  /// label.

  final String label;

  /// onTap.
  final VoidCallback? onTap;

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

  /// enabled.
  final bool enabled;

  /// isDestructive.
  final bool isDestructive;

  /// selected.
  final bool selected;

  /// shape.
  final MorphMenuItemShape shape;

  /// autofocus.
  final bool autofocus;

  /// Focus node owned by the menu key registration, when this row is in a popup.
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    final theme = MorphTheme.of(context);
    final menuTheme = theme.menuTheme;
    final scheme = theme.colorScheme;
    final style = MorphMenuStyleScope.styleOf(context);
    final palette =
        MorphMenuStyleScope.colorsOf(context) ??
        menuTheme.colors(scheme, style);
    final radius = menuTheme.itemBorderRadius;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: menuTheme.stateLayerInset),
      child: MorphTappable(
        enabled: enabled,
        onTap: onTap,
        autofocus: autofocus && enabled,
        focusNode: focusNode,
        semanticLabel: label,
        materialInk: true,
        builder: (BuildContext context, MorphInteractionState state) {
          final Color iconForeground = menuTheme.entryIconForegroundColor(
            scheme,
            enabled: enabled,
            isDestructive: isDestructive,
            selected: selected,
            hovered: state.hovered,
            focused: state.focused,
            pressed: state.pressed,
            style: style,
          );
          return MorphFocusRing(
            // Desktop rows show the keyboard highlight as the row fill only.
            focused: state.focused && menuTheme.focusIndicatorWidth > 0,
            radius: radius,
            width: menuTheme.focusIndicatorWidth,
            gap: menuTheme.focusIndicatorOffset,
            color: menuTheme.focusRingColor(scheme),
            child: MorphStateLayerOverlay(
              state: state,
              color: selected ? palette.selectedContent : palette.stateLayer,
              shape: RoundedRectangleBorder(borderRadius: radius),
              child: _expandable(
                context,
                (bool expanded) => _body(
                  context,
                  menuTheme: menuTheme,
                  scheme: scheme,
                  style: style,
                  palette: palette,
                  radius: radius,
                  iconForeground: iconForeground,
                  focused: state.focused,
                  expanded: expanded,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Desktop menus keep the owner row of an open submenu highlighted.
  Widget _expandable(BuildContext context, Widget Function(bool) build) {
    final ValueListenable<FocusNode?>? expanded =
        MorphMenuPresentationScope.maybeOf(context)?.expandedNode;
    final FocusNode? node = focusNode;
    if (expanded == null || node == null) {
      return build(false);
    }
    return ValueListenableBuilder<FocusNode?>(
      valueListenable: expanded,
      builder: (BuildContext context, FocusNode? open, Widget? _) =>
          build(identical(open, node)),
    );
  }

  Widget _body(
    BuildContext context, {
    required MorphMenuTheme menuTheme,
    required MorphColorScheme scheme,
    required MorphMenuColorStyle style,
    required MorphMenuColors palette,
    required BorderRadius radius,
    required Color iconForeground,
    required bool focused,
    bool expanded = false,
  }) {
    final Color background = _entryBackground(
      menuTheme: menuTheme,
      palette: palette,
      focused: focused,
      expanded: expanded,
    );
    return Container(
      constraints: BoxConstraints(minHeight: menuTheme.entryHeight),
      padding: EdgeInsets.symmetric(
        horizontal: menuTheme.entryHorizontalPadding,
        vertical: menuTheme.entryVerticalPadding,
      ),
      alignment: Alignment.center,
      decoration: BoxDecoration(color: background, borderRadius: radius),
      child: _entryRow(
        context,
        menuTheme: menuTheme,
        scheme: scheme,
        style: style,
        iconForeground: iconForeground,
      ),
    );
  }

  Color _entryBackground({
    required MorphMenuTheme menuTheme,
    required MorphMenuColors palette,
    required bool focused,
    bool expanded = false,
  }) {
    Color background = selected
        ? palette.selectedContainer
        : const Color(0x00000000);
    if (selected && !enabled) {
      background = background.withValues(alpha: menuTheme.disabledOpacity);
    }
    if (focused || expanded) {
      final Color layer = selected
          ? palette.selectedContent
          : palette.stateLayer;
      background = Color.alphaBlend(
        layer.withValues(
          alpha: focused ? MorphStateOpacity.focus : MorphStateOpacity.hover,
        ),
        background,
      );
    }
    return background;
  }

  Widget _labelBlock(
    BuildContext context, {
    required MorphMenuTheme menuTheme,
    required MorphColorScheme scheme,
    required MorphMenuColorStyle style,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          label,
          style: menuTheme.entryLabelStyle(
            MorphTheme.of(context).typeScale,
            scheme,
            enabled: enabled,
            isDestructive: isDestructive,
            selected: selected,
            style: style,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (supportingText != null)
          Text(
            supportingText!,
            style: menuTheme.supportingTextStyle(
              MorphTheme.of(context).typeScale,
              scheme,
              enabled: enabled,
              selected: selected,
              style: style,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
      ],
    );
  }

  Widget _desktopRow(
    BuildContext context, {
    required MorphMenuPresentationScope scope,
    required MorphMenuTheme menuTheme,
    required MorphColorScheme scheme,
    required MorphMenuColorStyle style,
    required Color iconForeground,
  }) {
    final IconThemeData iconTheme = IconThemeData(
      color: iconForeground,
      size: menuTheme.iconSize,
    );
    final bool leadingSlot = scope.reserveLeading || leading != null;
    return Row(
      children: <Widget>[
        if (leadingSlot) ...<Widget>[
          SizedBox(
            width: menuTheme.iconSize,
            height: menuTheme.iconSize,
            child: leading == null
                ? null
                : Center(
                    child: IconTheme.merge(data: iconTheme, child: leading!),
                  ),
          ),
          SizedBox(width: menuTheme.iconGap),
        ],
        Expanded(
          child: _labelBlock(
            context,
            menuTheme: menuTheme,
            scheme: scheme,
            style: style,
          ),
        ),
        if (badge != null) ...<Widget>[
          SizedBox(width: menuTheme.iconGap),
          badge!,
        ],
        if (trailingText != null) ...<Widget>[
          SizedBox(width: menuTheme.resolvedShortcutGap),
          Text(
            trailingText!,
            maxLines: 1,
            style: menuTheme.trailingTextStyle(
              MorphTheme.of(context).typeScale,
              scheme,
              enabled: enabled,
              selected: selected,
              style: style,
            ),
          ),
        ],
        // Fixed trailing slot: chevrons and trailing icons share one column.
        if (trailing != null || scope.reserveTrailing) ...<Widget>[
          SizedBox(width: menuTheme.iconGap),
          SizedBox(
            width: menuTheme.iconSize,
            height: menuTheme.iconSize,
            child: trailing == null
                ? null
                : Center(
                    child: IconTheme.merge(data: iconTheme, child: trailing!),
                  ),
          ),
        ],
      ],
    );
  }

  Widget _entryRow(
    BuildContext context, {
    required MorphMenuTheme menuTheme,
    required MorphColorScheme scheme,
    required MorphMenuColorStyle style,
    required Color iconForeground,
  }) {
    final MorphMenuPresentationScope? scope =
        MorphMenuPresentationScope.maybeOf(context);
    if (scope != null && scope.presentation == MorphMenuPresentation.desktop) {
      return _desktopRow(
        context,
        scope: scope,
        menuTheme: menuTheme,
        scheme: scheme,
        style: style,
        iconForeground: iconForeground,
      );
    }
    return Row(
      children: <Widget>[
        if (leading != null) ...<Widget>[
          IconTheme.merge(
            data: IconThemeData(
              color: iconForeground,
              size: menuTheme.iconSize,
            ),
            child: leading!,
          ),
          SizedBox(width: menuTheme.iconGap),
        ],
        Expanded(
          child: _labelBlock(
            context,
            menuTheme: menuTheme,
            scheme: scheme,
            style: style,
          ),
        ),
        if (badge != null) ...<Widget>[
          SizedBox(width: menuTheme.iconGap),
          badge!,
        ],
        if (trailingText != null) ...<Widget>[
          SizedBox(width: menuTheme.iconGap),
          Text(
            trailingText!,
            style: menuTheme.trailingTextStyle(
              MorphTheme.of(context).typeScale,
              scheme,
              enabled: enabled,
              selected: selected,
              style: style,
            ),
          ),
        ],
        if (trailing != null) ...<Widget>[
          SizedBox(width: menuTheme.iconGap),
          IconTheme.merge(
            data: IconThemeData(
              color: iconForeground,
              size: menuTheme.iconSize,
            ),
            child: trailing!,
          ),
        ],
      ],
    );
  }
}
