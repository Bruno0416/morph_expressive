import 'package:flutter/widgets.dart';

import '../../../foundations/foundations.dart';
import '../enums/morph_menu_color_style.dart';
import '../models/morph_menu_node.dart';
import '../styles/morph_menu_theme.dart';
import '../utils/morph_menu_overlay_rect.dart';
import 'morph_menu_content.dart';
import 'morph_menu_item.dart';
import 'morph_menu_key_registration.dart';
import 'morph_menu_style_scope.dart';

/// Builds leaf [MorphMenuNode] widgets for [MorphMenuContent].
abstract final class MorphMenuNodeBuilders {
  const MorphMenuNodeBuilders._();

  /// entry.
  static Widget entry(
    MorphMenuEntry entry, {
    required bool autofocus,
    required MorphMenuSelectCallback onSelect,
  }) {
    return MorphMenuKeyRegistration(
      label: entry.label,
      enabled: entry.enabled,
      builder: (FocusNode node) {
        return MorphMenuItem(
          label: entry.label,
          leading: entry.leading,
          trailing: entry.trailing,
          trailingText: entry.trailingText,
          badge: entry.badge,
          supportingText: entry.supportingText,
          enabled: entry.enabled,
          isDestructive: entry.isDestructive,
          shape: entry.shape,
          autofocus: autofocus,
          focusNode: node,
          onTap: entry.enabled
              ? () {
                  entry.onPressed?.call();
                  onSelect(entry.value);
                }
              : null,
        );
      },
    );
  }

  /// selectable.
  static Widget selectable(
    MorphMenuSelectable item, {
    required bool selected,
    required bool autofocus,
    required MorphMenuTheme menuTheme,
    required MorphMenuSelectCallback onSelect,
  }) {
    return MorphMenuKeyRegistration(
      label: item.label,
      enabled: item.enabled,
      builder: (FocusNode node) {
        return MorphMenuItem(
          label: item.label,
          leading:
              item.leading ??
              (selected
                  ? Icon(
                      MorphIcons.check_rounded,
                      size: menuTheme.iconSize * 0.9,
                    )
                  : null),
          trailing: item.trailing,
          trailingText: item.trailingText,
          badge: item.badge,
          supportingText: item.supportingText,
          enabled: item.enabled,
          selected: selected,
          shape: item.shape,
          autofocus: autofocus,
          focusNode: node,
          onTap: item.enabled
              ? () {
                  item.onPressed?.call();
                  onSelect(item.value);
                }
              : null,
        );
      },
    );
  }

  /// toggleable.
  static Widget toggleable(
    MorphMenuToggleable item, {
    required bool autofocus,
    required MorphMenuTheme menuTheme,
    required MorphMenuSelectCallback onSelect,
  }) {
    return MorphMenuKeyRegistration(
      label: item.label,
      enabled: item.enabled,
      builder: (FocusNode node) {
        return MorphMenuItem(
          label: item.label,
          leading:
              item.leading ??
              Icon(
                item.checked
                    ? MorphIcons.check_box_rounded
                    : MorphIcons.check_box_outline_blank_rounded,
                size: menuTheme.iconSize,
              ),
          trailing: item.trailing,
          trailingText: item.trailingText,
          badge: item.badge,
          supportingText: item.supportingText,
          enabled: item.enabled,
          selected: item.checked,
          shape: item.shape,
          autofocus: autofocus,
          focusNode: node,
          onTap: item.enabled
              ? () {
                  final next = !item.checked;
                  item.onChanged?.call(next);
                  onSelect(next);
                }
              : null,
        );
      },
    );
  }

  /// submenu.
  static Widget submenu(
    MorphMenuSubmenu item, {
    required bool autofocus,
    required MorphMenuTheme menuTheme,
    required MorphMenuOpenSubmenuCallback? onOpenSubmenu,
  }) {
    return Builder(
      builder: (BuildContext itemContext) {
        void open() {
          final Rect? rect = morphOverlayRectFor(itemContext);
          if (rect == null || onOpenSubmenu == null) {
            return;
          }
          onOpenSubmenu(rect, item.children);
        }

        return MorphMenuKeyRegistration(
          label: item.label,
          enabled: item.enabled,
          onOpenSubmenu: item.enabled ? open : null,
          builder: (FocusNode node) {
            return MorphMenuItem(
              label: item.label,
              leading: item.leading,
              badge: item.badge,
              trailing: Icon(
                MorphIcons.arrow_right_rounded,
                size: menuTheme.iconSize,
              ),
              enabled: item.enabled,
              shape: item.shape,
              autofocus: autofocus,
              focusNode: node,
              onTap: item.enabled && onOpenSubmenu != null ? open : null,
            );
          },
        );
      },
    );
  }

  /// customWidget.
  static Widget customWidget(
    BuildContext context,
    MorphMenuWidget item, {
    required bool autofocus,
    required MorphMenuTheme menuTheme,
    required MorphMenuSelectCallback onSelect,
  }) {
    final scheme = MorphTheme.of(context).colorScheme;
    final style = MorphMenuStyleScope.styleOf(context);
    final palette =
        MorphMenuStyleScope.colorsOf(context) ??
        menuTheme.colors(scheme, style);
    final radius = menuTheme.itemBorderRadius;
    return MorphMenuKeyRegistration(
      label: item.semanticLabel ?? 'menu item',
      enabled: item.enabled,
      builder: (FocusNode node) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: menuTheme.stateLayerInset),
          child: MorphTappable(
            enabled: item.enabled,
            autofocus: autofocus,
            focusNode: node,
            semanticLabel: item.semanticLabel,
            materialInk: true,
            onTap: item.enabled
                ? () {
                    item.onPressed?.call();
                    onSelect(item.value);
                  }
                : null,
            builder: (BuildContext context, MorphInteractionState state) {
              return MorphFocusRing(
                focused: state.focused,
                radius: radius,
                width: menuTheme.focusIndicatorWidth,
                gap: menuTheme.focusIndicatorOffset,
                color: menuTheme.focusRingColor(scheme),
                child: MorphStateLayerOverlay(
                  state: state,
                  color: item.selected
                      ? palette.selectedContent
                      : palette.stateLayer,
                  shape: RoundedRectangleBorder(borderRadius: radius),
                  child: _customWidgetBody(
                    context,
                    item,
                    menuTheme: menuTheme,
                    scheme: scheme,
                    style: style,
                    palette: palette,
                    radius: radius,
                    state: state,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  static Widget _customWidgetBody(
    BuildContext context,
    MorphMenuWidget item, {
    required MorphMenuTheme menuTheme,
    required MorphColorScheme scheme,
    required MorphMenuColorStyle style,
    required MorphMenuColors palette,
    required BorderRadius radius,
    required MorphInteractionState state,
  }) {
    Color background = item.selected
        ? palette.selectedContainer
        : const Color(0x00000000);
    if (item.selected && !item.enabled) {
      background = background.withValues(alpha: menuTheme.disabledOpacity);
    }
    if (state.focused) {
      final Color layer = item.selected
          ? palette.selectedContent
          : palette.stateLayer;
      background = Color.alphaBlend(
        layer.withValues(alpha: MorphStateOpacity.focus),
        background,
      );
    }
    return Container(
      constraints: BoxConstraints(minHeight: menuTheme.entryHeight),
      padding: EdgeInsets.symmetric(
        horizontal: menuTheme.entryHorizontalPadding,
        vertical: menuTheme.entryVerticalPadding,
      ),
      decoration: BoxDecoration(color: background, borderRadius: radius),
      child: Row(
        children: <Widget>[
          Expanded(
            child: IconTheme.merge(
              data: IconThemeData(
                color: menuTheme.entryIconForegroundColor(
                  scheme,
                  enabled: item.enabled,
                  selected: item.selected,
                  hovered: state.hovered,
                  focused: state.focused,
                  pressed: state.pressed,
                  style: style,
                ),
                size: menuTheme.iconSize,
              ),
              child: DefaultTextStyle.merge(
                style: menuTheme.entryLabelStyle(
                  MorphTheme.of(context).typeScale,
                  scheme,
                  enabled: item.enabled,
                  selected: item.selected,
                  style: style,
                ),
                child: item.child,
              ),
            ),
          ),
          if (item.selected)
            Padding(
              padding: EdgeInsets.only(left: menuTheme.iconGap),
              child: Icon(
                MorphIcons.check_rounded,
                size: menuTheme.iconSize * 0.9,
                color: menuTheme.entryIconForegroundColor(
                  scheme,
                  enabled: item.enabled,
                  selected: true,
                  hovered: state.hovered,
                  focused: state.focused,
                  pressed: state.pressed,
                  style: style,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
