import 'package:flutter/widgets.dart';

import '../../../foundations/foundations.dart';

/// A swipe action revealed beside a dismissible list row.
class MorphListSwipeAction {
  /// Creates a swipe action.
  const MorphListSwipeAction({
    required this.icon,
    this.backgroundColor,
    this.foregroundColor,
    this.onPressed,
    this.tooltip,
    this.semanticLabel,
    this.enabled = true,
    this.autoClose = true,
    this.isPrimary = false,
    this.width = 52,
    this.height,
    this.haptic = MorphHapticFeedback.medium,
  });

  /// Icon for the action.
  final Widget icon;

  /// Optional background override.
  final Color? backgroundColor;

  /// Optional foreground override.
  final Color? foregroundColor;

  /// Called when the action is invoked.
  final VoidCallback? onPressed;

  /// Tooltip shown on hover or long-press; also used as a semantic label.
  final String? tooltip;

  /// Accessibility description (overrides [tooltip] for semantics).
  final String? semanticLabel;

  /// Whether this action is interactive.
  final bool enabled;

  /// Close an open action preview after activating this action.
  final bool autoClose;

  /// Primary end-aligned action for auto-execute on full dismiss.
  final bool isPrimary;

  /// Preferred cell width used for snap / preview extent (not a visual max).
  final double width;

  /// Optional fixed height; otherwise fills the list row reveal height.
  final double? height;

  /// Haptic level when the action is pressed.
  final MorphHapticFeedback haptic;
}
