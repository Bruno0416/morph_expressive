import 'package:material_ui/material_ui.dart'
    show FocusNode, ValueChanged, Widget;

import '../../buttons/styles/morph_button_decoration.dart';

/// Declarative description of one action in an `MorphButtonGroup`.
///
/// Each action is rendered as an `MorphButton`. Provide [icon] and/or [label].
class MorphButtonGroupAction {
  /// Creates a group action.
  ///
  /// [minWidth] sets a resting main-axis floor (e.g. icon-only narrow / wide).
  /// [width] forces a fixed main-axis size via a custom button size.
  const MorphButtonGroupAction({
    this.icon,
    this.selectedIcon,
    this.label,
    this.selectedLabel,
    this.isSelected,
    this.enabled = true,
    this.decoration,
    this.minWidth,
    this.width,
    this.focusNode,
    this.autofocus = false,
    this.onFocusChange,
    this.semanticLabel,
    this.tooltip,
    this.enableFeedback,
  }) : assert(
         icon != null || label != null,
         'MorphButtonGroupAction must have either an icon or a label.',
       );

  /// Leading / only icon when unselected.
  final Widget? icon;

  /// Icon shown when this action is selected; falls back to [icon].
  final Widget? selectedIcon;

  /// Label when unselected.
  final Widget? label;

  /// Label when selected; falls back to [label].
  final Widget? selectedLabel;

  /// Uncontrolled selection flag when the group has no selection callbacks.
  ///
  /// Must be null when the group uses controlled `selectedIndex` /
  /// `selectedIndices`.
  final bool? isSelected;

  /// Whether the action can be pressed.
  final bool enabled;

  /// Per-action style overrides; merges over the group decoration.
  final MorphButtonDecoration? decoration;

  /// Resting minimum main-axis extent. Content may grow beyond this.
  final double? minWidth;

  /// Fixed main-axis extent when non-null.
  final double? width;

  /// Optional focus node; the group supplies one when null.
  final FocusNode? focusNode;

  /// Whether this action requests initial focus.
  final bool autofocus;

  /// Called when focus enters or leaves this action.
  final ValueChanged<bool>? onFocusChange;

  /// Accessibility label when the visual child is not self-describing.
  final String? semanticLabel;

  /// Optional tooltip for this action.
  final String? tooltip;

  /// Whether to play platform feedback; falls back to the group setting.
  final bool? enableFeedback;

  /// Whether this action has an icon and no label.
  bool get isIconOnly => icon != null && label == null && selectedLabel == null;
}
