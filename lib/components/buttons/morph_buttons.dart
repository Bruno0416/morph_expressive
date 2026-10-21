import 'package:flutter/foundation.dart';
import 'package:morph_expressive/components/buttons/models/morph_button_measurements.dart';
import 'package:morph_expressive/components/buttons/res/morph_button_constants.dart';
import 'package:morph_expressive/components/buttons/styles/morph_button_decoration.dart';
import 'package:morph_expressive/components/buttons/styles/morph_button_decoration_scope.dart';
import 'package:morph_expressive/components/buttons/styles/morph_button_motion.dart';
import 'package:morph_expressive/components/buttons/styles/morph_button_theme.dart';
import 'package:morph_expressive/foundations/foundations.dart';
import 'package:material_ui/material_ui.dart'
    show
        Align,
        Alignment,
        BorderRadius,
        BorderRadiusDirectional,
        BorderSide,
        BoxFit,
        BuildContext,
        ButtonLayerBuilder,
        ButtonStyle,
        Clip,
        ClipRRect,
        ClipRect,
        Color,
        ColorTween,
        ColoredBox,
        Colors,
        DefaultTextStyle,
        Directionality,
        EdgeInsets,
        EdgeInsetsGeometry,
        ElevatedButton,
        ExcludeSemantics,
        FilledButton,
        FittedBox,
        Flexible,
        FocusNode,
        IconAlignment,
        IconTheme,
        IconThemeData,
        IgnorePointer,
        InkSparkle,
        InteractiveInkFeatureFactory,
        Key,
        KeyedSubtree,
        LayoutBuilder,
        MainAxisAlignment,
        MainAxisSize,
        MediaQuery,
        MouseCursor,
        NoSplash,
        Offset,
        Opacity,
        OutlinedBorder,
        OutlinedButton,
        Positioned,
        Radius,
        RepaintBoundary,
        RoundedRectangleBorder,
        Row,
        Semantics,
        Size,
        SizedBox,
        Stack,
        StackFit,
        State,
        StatefulWidget,
        StatelessWidget,
        SystemMouseCursors,
        TextButton,
        TextOverflow,
        Transform,
        TweenAnimationBuilder,
        ValueChanged,
        ValueKey,
        VisualDensity,
        VoidCallback,
        Widget,
        WidgetState,
        WidgetStateProperty,
        WidgetStatePropertyAll,
        WidgetStatesController;
import 'package:motor/motor.dart';

import '../tooltips/morph_tooltips.dart';
import 'components/morph_base_button_state.dart';
import 'components/morph_radius_and_padding_motion.dart';
import 'enums/morph_button_enums.dart';
import 'utils/morph_button_gradient_layer.dart';

export 'components/morph_no_overflow_strategy.dart';
export 'components/morph_overflow_strategy.dart';
export 'components/morph_scroll_overflow_strategy.dart';
export 'enums/morph_button_enums.dart';
export 'models/morph_button_measurements.dart';
export 'res/morph_button_constants.dart';
export 'styles/morph_button_decoration.dart';
export 'styles/morph_button_decoration_scope.dart';
export 'styles/morph_button_motion.dart';
export 'styles/morph_button_theme.dart';
export 'styles/morph_overflow_bottom_sheet_decoration.dart';
export 'styles/morph_overflow_popup_decoration.dart';
export 'utils/morph_button_gradient_layer.dart';

part 'components/morph_button_state.dart';
part 'components/morph_button_style.dart';
part 'components/morph_button_content.dart';
part 'components/morph_button_selection_content.dart';
part 'components/morph_button_selection_shape.dart';

const Alignment _kAlignmentCenter = Alignment.center;
const VisualDensity _kVisualDensityStandard = VisualDensity.standard;
const Duration _kDurationZero = Duration.zero;
const bool _kDefaultEnableFeedback = true;

/// MorphButton.

class MorphButton extends StatefulWidget {
  /// MorphButton.
  const MorphButton({
    super.key,
    required this.onPressed,
    this.child,
    this.icon,
    this.label,
    this.selectedIcon,
    this.selectedLabel,
    this.isSelected,
    this.style = MorphButtonStyle.filled,
    this.size = MorphButtonSize.sm,
    this.shape = MorphButtonShape.round,
    this.enabled = true,
    this.isGroupConnected = false,
    this.isFirstInGroup = true,
    this.isLastInGroup = true,
    this.statesController,
    this.decoration,
    this.focusNode,
    this.autofocus = false,
    this.onFocusChange,
    this.semanticLabel,
    this.tooltip,
    this.mouseCursor = SystemMouseCursors.click,
    this.onLongPress,
    this.onHover,
    this.enableFeedback = _kDefaultEnableFeedback,
    this.splashFactory,
  });

  /// Factory for a button with an icon and label.
  factory MorphButton.icon({
    Key? key,
    required VoidCallback? onPressed,
    required Widget icon,
    required Widget label,
    Widget? selectedIcon,
    Widget? selectedLabel,
    bool? isSelected,
    MorphButtonStyle style = MorphButtonStyle.filled,
    MorphButtonSize size = MorphButtonSize.sm,
    MorphButtonShape shape = MorphButtonShape.round,
    bool enabled = true,
    bool isGroupConnected = false,
    bool isFirstInGroup = true,
    bool isLastInGroup = true,
    WidgetStatesController? statesController,
    MorphButtonDecoration? decoration,
    FocusNode? focusNode,
    bool autofocus = false,
    ValueChanged<bool>? onFocusChange,
    String? semanticLabel,
    String? tooltip,
    MouseCursor mouseCursor = SystemMouseCursors.click,
    VoidCallback? onLongPress,
    ValueChanged<bool>? onHover,
    bool enableFeedback = _kDefaultEnableFeedback,
    InteractiveInkFeatureFactory? splashFactory,
  }) {
    return MorphButton(
      key: key,
      onPressed: onPressed,
      style: style,
      size: size,
      shape: shape,
      enabled: enabled,
      isGroupConnected: isGroupConnected,
      isFirstInGroup: isFirstInGroup,
      isLastInGroup: isLastInGroup,
      statesController: statesController,
      decoration: decoration,
      focusNode: focusNode,
      autofocus: autofocus,
      onFocusChange: onFocusChange,
      semanticLabel: semanticLabel,
      tooltip: tooltip,
      mouseCursor: mouseCursor,
      onLongPress: onLongPress,
      onHover: onHover,
      enableFeedback: enableFeedback,
      splashFactory: splashFactory,
      icon: icon,
      label: label,
      selectedIcon: selectedIcon,
      selectedLabel: selectedLabel,
      isSelected: isSelected,
    );
  }

  /// A filled button (highest emphasis).
  const MorphButton.filled({
    super.key,
    required this.onPressed,
    this.child,
    this.icon,
    this.label,
    this.selectedIcon,
    this.selectedLabel,
    this.isSelected,
    this.size = MorphButtonSize.sm,
    this.shape = MorphButtonShape.round,
    this.enabled = true,
    this.isGroupConnected = false,
    this.isFirstInGroup = true,
    this.isLastInGroup = true,
    this.statesController,
    this.decoration,
    this.focusNode,
    this.autofocus = false,
    this.onFocusChange,
    this.semanticLabel,
    this.tooltip,
    this.mouseCursor = SystemMouseCursors.click,
    this.onLongPress,
    this.onHover,
    this.enableFeedback = _kDefaultEnableFeedback,
    this.splashFactory,
  }) : style = MorphButtonStyle.filled;

  /// A tonal button (medium emphasis).
  const MorphButton.tonal({
    super.key,
    required this.onPressed,
    this.child,
    this.icon,
    this.label,
    this.selectedIcon,
    this.selectedLabel,
    this.isSelected,
    this.size = MorphButtonSize.sm,
    this.shape = MorphButtonShape.round,
    this.enabled = true,
    this.isGroupConnected = false,
    this.isFirstInGroup = true,
    this.isLastInGroup = true,
    this.statesController,
    this.decoration,
    this.focusNode,
    this.autofocus = false,
    this.onFocusChange,
    this.semanticLabel,
    this.tooltip,
    this.mouseCursor = SystemMouseCursors.click,
    this.onLongPress,
    this.onHover,
    this.enableFeedback = _kDefaultEnableFeedback,
    this.splashFactory,
  }) : style = MorphButtonStyle.tonal;

  /// An elevated button (medium emphasis with a shadow).
  const MorphButton.elevated({
    super.key,
    required this.onPressed,
    this.child,
    this.icon,
    this.label,
    this.selectedIcon,
    this.selectedLabel,
    this.isSelected,
    this.size = MorphButtonSize.sm,
    this.shape = MorphButtonShape.round,
    this.enabled = true,
    this.isGroupConnected = false,
    this.isFirstInGroup = true,
    this.isLastInGroup = true,
    this.statesController,
    this.decoration,
    this.focusNode,
    this.autofocus = false,
    this.onFocusChange,
    this.semanticLabel,
    this.tooltip,
    this.mouseCursor = SystemMouseCursors.click,
    this.onLongPress,
    this.onHover,
    this.enableFeedback = _kDefaultEnableFeedback,
    this.splashFactory,
  }) : style = MorphButtonStyle.elevated;

  /// An outlined button (medium emphasis with a border).
  const MorphButton.outlined({
    super.key,
    required this.onPressed,
    this.child,
    this.icon,
    this.label,
    this.selectedIcon,
    this.selectedLabel,
    this.isSelected,
    this.size = MorphButtonSize.sm,
    this.shape = MorphButtonShape.round,
    this.enabled = true,
    this.isGroupConnected = false,
    this.isFirstInGroup = true,
    this.isLastInGroup = true,
    this.statesController,
    this.decoration,
    this.focusNode,
    this.autofocus = false,
    this.onFocusChange,
    this.semanticLabel,
    this.tooltip,
    this.mouseCursor = SystemMouseCursors.click,
    this.onLongPress,
    this.onHover,
    this.enableFeedback = _kDefaultEnableFeedback,
    this.splashFactory,
  }) : style = MorphButtonStyle.outlined;

  /// A text button (lowest emphasis).
  const MorphButton.text({
    super.key,
    required this.onPressed,
    this.child,
    this.size = MorphButtonSize.sm,
    this.shape = MorphButtonShape.round,
    this.enabled = true,
    this.statesController,
    this.decoration,
    this.focusNode,
    this.autofocus = false,
    this.onFocusChange,
    this.semanticLabel,
    this.tooltip,
    this.mouseCursor = SystemMouseCursors.click,
    this.onLongPress,
    this.onHover,
    this.enableFeedback = _kDefaultEnableFeedback,
    this.splashFactory,
  }) : icon = null,
       label = null,
       selectedIcon = null,
       selectedLabel = null,
       isSelected = null,
       isGroupConnected = false,
       isFirstInGroup = true,
       isLastInGroup = true,
       style = MorphButtonStyle.text;

  /// Callback invoked when the button is pressed. Null disables the button.
  final VoidCallback? onPressed;

  /// The child content of the button.
  final Widget? child;

  /// Icon displayed by selection-capable buttons.
  final Widget? icon;

  /// Label displayed by selection-capable buttons.
  final Widget? label;

  /// Icon displayed when [isSelected] is true. Falls back to [icon].
  final Widget? selectedIcon;

  /// Label displayed when [isSelected] is true. Falls back to [label].
  final Widget? selectedLabel;

  /// Selection state. Null keeps default, non-toggle button behavior.
  final bool? isSelected;

  /// Visual style of the button.
  ///
  /// See [MorphButtonStyle] for available styles (filled, outlined, tonal, etc.).
  final MorphButtonStyle style;

  /// Size variant of the button.
  ///
  /// See [MorphButtonSize] for available sizes (xs, sm, md, lg, xl).
  final MorphButtonSize size;

  /// Corner radius strategy for the button.
  ///
  /// See [MorphButtonShape] for available shapes (round, square).
  final MorphButtonShape shape;

  /// Whether the button is enabled. Defaults to true.
  final bool enabled;

  /// Whether this button is part of a connected button group.
  final bool isGroupConnected;

  /// Whether this is the first button in a connected group.
  final bool isFirstInGroup;

  /// Whether this is the last button in a connected group.
  final bool isLastInGroup;

  /// Optional controller for managing widget states externally.
  ///
  /// Allows programmatic control of pressed, hovered, focused states.
  final WidgetStatesController? statesController;

  /// Optional decoration that bundles styling properties together.
  ///
  /// When provided, decoration values take precedence over individual flat
  /// parameters (e.g. `backgroundColor`, `foregroundColor`, etc.).
  final MorphButtonDecoration? decoration;

  /// External focus node for keyboard navigation.
  final FocusNode? focusNode;

  /// Whether this button should focus itself on mount.
  final bool autofocus;

  /// Callback fired when focus state changes.
  final ValueChanged<bool>? onFocusChange;

  /// Accessibility label. Merged on top of the button's own semantics.
  final String? semanticLabel;

  /// Tooltip text.
  final String? tooltip;

  /// Custom mouse cursor.
  final MouseCursor mouseCursor;

  /// Callback invoked when the button is long-pressed.
  final VoidCallback? onLongPress;

  /// Callback invoked when the hover state changes.
  final ValueChanged<bool>? onHover;

  /// Whether to show a ripple/splash effect and haptic feedback on press.
  ///
  /// Defaults to true.
  final bool enableFeedback;

  /// The splash factory for the ink ripple effect.
  ///
  /// See [InteractiveInkFeatureFactory] for available options.
  final InteractiveInkFeatureFactory? splashFactory;

  /// decorationBackgroundColor.

  // ── Decoration property helpers ───────────────────────────────────────────

  WidgetStateProperty<Color?>? get decorationBackgroundColor =>
      decoration?.backgroundColor;

  /// decorationForegroundColor.
  WidgetStateProperty<Color?>? get decorationForegroundColor =>
      decoration?.foregroundColor;

  /// decorationBorderSide.
  WidgetStateProperty<BorderSide?>? get decorationBorderSide =>
      decoration?.side;

  /// decorationMotion.
  MorphButtonMotion? get decorationMotion => decoration?.motion;

  /// decorationHaptic.
  MorphHapticFeedback get decorationHaptic =>
      decoration?.haptic ?? MorphHapticFeedback.inherit;

  /// decorationMouseCursor.
  WidgetStateProperty<MouseCursor?>? get decorationMouseCursor =>
      decoration?.mouseCursor;

  /// decorationPressedRadius.
  double? get decorationPressedRadius => decoration?.pressedRadius;

  /// decorationBorderRadius.
  double? get decorationBorderRadius => decoration?.borderRadius;

  /// Radius used by the selected resting shape.
  double? get decorationSelectedRadius => decoration?.selectedRadius;

  /// Radius used by the unselected resting shape.
  double? get decorationUnselectedRadius => decoration?.unselectedRadius;

  /// Radius used on connected inner corners.
  double? get decorationConnectedInnerRadius =>
      decoration?.connectedInnerRadius;

  /// decorationOverlayColor.
  WidgetStateProperty<Color?>? get decorationOverlayColor =>
      decoration?.overlayColor;

  /// decorationSurfaceTintColor.
  WidgetStateProperty<Color?>? get decorationSurfaceTintColor =>
      decoration?.surfaceTintColor;

  @override
  State<MorphButton> createState() => _MorphButtonState();
}
