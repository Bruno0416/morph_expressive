import 'package:flutter/widgets.dart';

import '../../icon_buttons/morph_icon_buttons.dart';

/// A trailing icon slot of `MorphTextField`: error icon, clear or password
/// toggle.
///
/// With [onPressed] it is an icon button labelled by [semanticLabel]. Without
/// it, it is a non-actionable icon (such as the error icon) labelled by
/// [semanticLabel].
class MorphTextFieldAffordance extends StatelessWidget {
  /// Creates a trailing affordance.
  const MorphTextFieldAffordance({
    required this.icon,
    required this.color,
    required this.iconSize,
    required this.semanticLabel,
    this.onPressed,
    super.key,
  });

  /// Glyph.
  final IconData icon;

  /// Icon color.
  final Color color;

  /// Icon size.
  final double iconSize;

  /// Accessibility label.
  final String semanticLabel;

  /// Press handler; null for a non-actionable icon.
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    if (onPressed == null) {
      return Semantics(
        label: semanticLabel,
        child: ExcludeSemantics(
          child: Icon(icon, size: iconSize, color: color),
        ),
      );
    }
    return MorphIconButton(
      icon: Icon(icon, size: iconSize),
      onPressed: onPressed,
      semanticLabel: semanticLabel,
      variant: MorphIconButtonVariant.standard,
      decoration: MorphIconButtonDecoration(
        foregroundColor: WidgetStatePropertyAll<Color?>(color),
      ),
    );
  }
}
