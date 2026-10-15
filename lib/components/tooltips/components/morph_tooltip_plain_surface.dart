import 'package:flutter/widgets.dart';

import '../../../foundations/foundations.dart';

/// Superficie visual compartida por el tooltip simple y el valor del slider.
/// Hereda forma, color y tipografia del tema configurado en MorphTooltip.
class MorphTooltipPlainSurface extends StatelessWidget {
  const MorphTooltipPlainSurface({
    required this.message,
    this.shape,
    super.key,
  });

  final String message;
  final ShapeBorder? shape;

  @override
  Widget build(BuildContext context) {
    final theme = MorphTheme.of(context);
    final tokens = theme.tooltipTheme;
    return Container(
      constraints: BoxConstraints(
        maxWidth: tokens.plainMaxWidth,
        minHeight: tokens.plainMinHeight,
      ),
      padding: tokens.plainPadding,
      decoration: ShapeDecoration(
        color: tokens.plainContainerColor(theme.colorScheme),
        shape: shape ?? tokens.plainShape,
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: tokens.plainMessageStyle(theme.typeScale, theme.colorScheme),
      ),
    );
  }
}
