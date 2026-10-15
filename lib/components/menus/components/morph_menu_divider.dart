import 'package:flutter/widgets.dart';

import '../../../foundations/foundations.dart';
import 'morph_menu_style_scope.dart';

/// Horizontal divider between menu items inside one elevated surface.
class MorphMenuDividerWidget extends StatelessWidget {
  /// MorphMenuDividerWidget.
  const MorphMenuDividerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = MorphTheme.of(context);
    final menuTheme = theme.menuTheme;
    final style = MorphMenuStyleScope.styleOf(context);
    final Color color = menuTheme.dividerColor(theme.colorScheme, style);
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: menuTheme.dividerVerticalPadding,
        horizontal: menuTheme.stateLayerInset,
      ),
      child: SizedBox(
        height: menuTheme.dividerThickness,
        child: ColoredBox(color: color),
      ),
    );
  }
}
