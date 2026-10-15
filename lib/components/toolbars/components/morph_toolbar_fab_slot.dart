// Adjacent FAB slot — size morphs with FAB-driven toolbar expand progress.

import 'package:flutter/widgets.dart';

import '../../../foundations/foundations.dart';
import '../../floating_action_buttons/morph_floating_action_buttons.dart';
import '../res/morph_toolbar_tokens.dart';

/// Hosts an adjacent [MorphFab], optionally sized for expand morph.
class MorphToolbarFabSlot extends StatelessWidget {
  /// MorphToolbarFabSlot.
  const MorphToolbarFabSlot({
    this.fab,
    this.icon,
    this.onPressed,
    this.color = MorphFabColor.secondary,
    this.containerSize,
    this.iconSize = MorphToolbarTokens.fabExpandedIcon,
    this.cornerRadius,
    super.key,
  });

  /// Custom FAB widget. When null, builds a default [MorphFab] from [icon].
  final Widget? fab;

  /// icon.
  final Widget? icon;

  /// onPressed.
  final VoidCallback? onPressed;

  /// color.
  final MorphFabColor color;

  /// When set, sizes the default FAB to this square (80 collapsed → 56
  /// expanded). Ignored when [fab] is provided (parent tight-lays out child).
  final double? containerSize;

  /// Icon size inside the default FAB. 28 collapsed, 24 expanded.
  final double iconSize;

  /// Corner radius of the default FAB. Falls back to the FAB theme.
  final double? cornerRadius;

  @override
  Widget build(BuildContext context) {
    if (fab != null) {
      final double? size = containerSize;
      if (size == null) {
        return fab!;
      }
      return SizedBox(
        width: size,
        height: size,
        child: FittedBox(child: fab),
      );
    }

    final double size = containerSize ?? MorphToolbarTokens.fabBaseline;
    final MorphThemeData theme = MorphTheme.of(context);
    final Widget button = MorphTheme(
      data: theme.copyWith(
        fabTheme: theme.fabTheme.copyWith(
          regularContainer: size,
          regularIconSize: iconSize,
          regularRadius: cornerRadius ?? theme.fabTheme.regularRadius,
        ),
      ),
      child: MorphFab(
        icon: icon ?? const SizedBox.shrink(),
        onPressed: onPressed,
        color: color,
        size: MorphFabSize.regular,
      ),
    );
    return SizedBox(width: size, height: size, child: button);
  }
}
