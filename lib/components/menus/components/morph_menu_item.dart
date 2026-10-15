import 'package:flutter/widgets.dart';
import 'package:morph_expressive/components/menus/morph_menus.dart'
    show MorphMenu;
import 'package:morph_expressive/morph_components.dart' show MorphMenu;

import '../../../foundations/foundations.dart';
import '../enums/morph_menu_color_style.dart';
import '../enums/morph_menu_item_shape.dart';
import '../styles/morph_menu_theme.dart';
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
        MorphMenuStyleScope.colorsOf(context) ?? menuTheme.colors(scheme, style);
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
            focused: state.focused,
            radius: radius,
            width: menuTheme.focusIndicatorWidth,
            gap: menuTheme.focusIndicatorOffset,
            color: menuTheme.focusRingColor(scheme),
            child: MorphStateLayerOverlay(
              state: state,
              color: selected ? palette.selectedContent : palette.stateLayer,
              shape: RoundedRectangleBorder(borderRadius: radius),
              child: _body(
                context,
                menuTheme: menuTheme,
                scheme: scheme,
                style: style,
                palette: palette,
                radius: radius,
                iconForeground: iconForeground,
                focused: state.focused,
              ),
            ),
          );
        },
      ),
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
  }) {
    final Color background = _entryBackground(
      menuTheme: menuTheme,
      palette: palette,
      focused: focused,
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
  }) {
    Color background = selected
        ? palette.selectedContainer
        : const Color(0x00000000);
    if (selected && !enabled) {
      background = background.withValues(alpha: menuTheme.disabledOpacity);
    }
    if (focused) {
      final Color layer = selected
          ? palette.selectedContent
          : palette.stateLayer;
      background = Color.alphaBlend(
        layer.withValues(alpha: MorphStateOpacity.focus),
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

  Widget _entryRow(
    BuildContext context, {
    required MorphMenuTheme menuTheme,
    required MorphColorScheme scheme,
    required MorphMenuColorStyle style,
    required Color iconForeground,
  }) {
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
