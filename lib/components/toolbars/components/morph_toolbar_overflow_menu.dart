import 'package:flutter/widgets.dart';

import '../../../foundations/foundations.dart';
import '../../icon_buttons/morph_icon_buttons.dart';
import '../../menus/morph_menus.dart';
import '../models/morph_toolbar_item.dart';

/// Overflow menu for toolbar actions beyond the inline limit.
class MorphToolbarOverflowMenu extends StatelessWidget {
  /// MorphToolbarOverflowMenu.
  const MorphToolbarOverflowMenu({
    required this.actions,
    required this.icon,
    required this.iconButtonSize,
    this.textStyle,
    this.destructiveColor,
    this.shape = MorphIconButtonShapeVariant.round,
    super.key,
  });

  /// actions.

  final List<MorphToolbarAction> actions;

  /// icon.
  final Widget icon;

  /// iconButtonSize.
  final MorphIconButtonSize iconButtonSize;

  /// textStyle.
  final TextStyle? textStyle;

  /// destructiveColor.
  final Color? destructiveColor;

  /// shape.
  final MorphIconButtonShapeVariant shape;

  @override
  Widget build(BuildContext context) {
    final theme = MorphTheme.of(context);
    final errorColor = destructiveColor ?? theme.colorScheme.error;

    Widget menu = MorphMenu(
      position: MorphMenuAnchorPosition.bottomEnd,
      children: <MorphMenuNode>[
        for (var i = 0; i < actions.length; i++)
          MorphMenuEntry(
            label:
                actions[i].label ??
                actions[i].tooltip ??
                actions[i].semanticLabel ??
                'Action ${i + 1}',
            enabled: actions[i].enabled,
            isDestructive: actions[i].isDestructive,
            onPressed: actions[i].onPressed,
          ),
      ],
      anchorBuilder: (BuildContext context, VoidCallback open) {
        return MorphIconButton(
          variant: MorphIconButtonVariant.standard,
          icon: icon,
          size: iconButtonSize,
          shape: shape,
          tooltip: 'More options',
          onPressed: open,
        );
      },
    );

    if (textStyle != null) {
      menu = DefaultTextStyle.merge(style: textStyle, child: menu);
    }

    // Tint destructive labels when a custom error color is supplied.
    if (destructiveColor != null) {
      menu = IconTheme.merge(
        data: IconThemeData(color: errorColor),
        child: menu,
      );
    }

    return menu;
  }
}
