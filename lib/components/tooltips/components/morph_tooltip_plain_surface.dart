import 'package:flutter/widgets.dart';

import '../../../foundations/foundations.dart';
import '../../../foundations/surface/morph_glass_surface.dart';

/// Superficie visual compartida por el tooltip simple y el valor del slider.
/// Hereda forma, color y tipografia del tema configurado en MorphTooltip.
class MorphTooltipPlainSurface extends StatelessWidget {
  const MorphTooltipPlainSurface({
    required this.message,
    this.shape,
    this.glass,
    super.key,
  });

  final String message;
  final ShapeBorder? shape;

  /// Frosted override for this bubble; null inherits the theme global.
  final MorphSurfaceGlass? glass;

  @override
  Widget build(BuildContext context) {
    final theme = MorphTheme.of(context);
    final tokens = theme.tooltipTheme;
    final content = Padding(
      padding: tokens.plainPadding,
      child: Text(
        message,
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: tokens.plainMessageStyle(theme.typeScale, theme.colorScheme),
      ),
    );
    final resolved = MorphGlassSurface.resolve(context, glass);
    final Widget bubble = resolved == null
        ? DecoratedBox(
            decoration: ShapeDecoration(
              color: tokens.plainContainerColor(theme.colorScheme),
              shape: shape ?? tokens.plainShape,
            ),
            child: content,
          )
        : MorphGlassSurface(
            glass: resolved,
            baseColor: tokens.plainContainerColor(theme.colorScheme),
            shape: shape ?? tokens.plainShape,
            tintMode: MorphGlassTintMode.alpha,
            child: content,
          );
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: tokens.plainMaxWidth,
        minHeight: tokens.plainMinHeight,
      ),
      child: bubble,
    );
  }
}
