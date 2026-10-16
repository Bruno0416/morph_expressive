import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../../../foundations/foundations.dart';
import '../../icon_buttons/morph_icon_buttons.dart';
import '../models/morph_list_swipe_action.dart';

/// Renders a [MorphListSwipeAction] with [MorphIconButton].
class MorphListSwipeActionButton extends StatelessWidget {
  /// Creates a swipe action button.
  const MorphListSwipeActionButton({
    required this.action,
    required this.onTriggered,
    required this.width,
    required this.height,
    this.minWidth = 40,
    super.key,
  });

  /// Action model.
  final MorphListSwipeAction action;

  /// Called after [MorphListSwipeAction.onPressed] (e.g. close preview).
  final VoidCallback onTriggered;

  /// Allocated cell width — fills the reveal slot.
  final double width;

  /// Visual height — typically the list row reveal height.
  final double height;

  /// Minimum visual width so the icon stays inside the pill while revealing.
  final double minWidth;

  @override
  Widget build(BuildContext context) {
    final double resolvedHeight = action.height ?? height;
    final double visualWidth = math.max(width, minWidth);
    final MorphIconButtonVariant variant = action.isPrimary
        ? MorphIconButtonVariant.filled
        : MorphIconButtonVariant.tonal;

    void handlePress() {
      MorphHaptics.triggerFor(context, action.haptic);
      action.onPressed?.call();
      if (action.autoClose) {
        onTriggered();
      }
    }

    final Color? bg = action.backgroundColor;
    final Color? fg = action.foregroundColor;
    final MorphIconButtonDecoration? decoration = (bg == null && fg == null)
        ? null
        : MorphIconButtonDecoration(
            backgroundColor: bg == null
                ? null
                : WidgetStatePropertyAll<Color?>(bg),
            foregroundColor: fg == null
                ? null
                : WidgetStatePropertyAll<Color?>(fg),
          );

    return SizedBox(
      width: width,
      height: resolvedHeight,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(resolvedHeight / 2),
        child: OverflowBox(
          minWidth: visualWidth,
          maxWidth: visualWidth,
          minHeight: resolvedHeight,
          maxHeight: resolvedHeight,
          child: MorphIconButton(
            icon: action.icon,
            onPressed: action.enabled ? handlePress : null,
            tooltip: action.tooltip,
            semanticLabel: action.semanticLabel,
            haptic: MorphHapticFeedback.none,
            variant: variant,
            enableFeedback: false,
            visualSize: Size(visualWidth, resolvedHeight),
            decoration: decoration,
          ),
        ),
      ),
    );
  }
}
