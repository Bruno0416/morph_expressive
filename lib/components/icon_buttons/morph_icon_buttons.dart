import 'dart:math' as math;

import 'package:material_ui/material_ui.dart'
    show
        Badge,
        BorderRadius,
        BorderRadiusDirectional,
        BorderSide,
        BoxConstraints,
        BuildContext,
        ButtonStyle,
        Center,
        Clip,
        Color,
        Colors,
        Directionality,
        EdgeInsets,
        FlutterError,
        FocusHighlightMode,
        FocusManager,
        FocusNode,
        Gradient,
        HitTestBehavior,
        IconButton,
        IconTheme,
        IconThemeData,
        InkSparkle,
        LayoutBuilder,
        Listenable,
        ListenableBuilder,
        Listener,
        NoSplash,
        PointerCancelEvent,
        PointerDownEvent,
        PointerUpEvent,
        PositionedDirectional,
        Radius,
        RoundedRectangleBorder,
        Semantics,
        Size,
        SizedBox,
        Stack,
        State,
        StatefulWidget,
        SystemMouseCursors,
        TapRegion,
        Text,
        ValueChanged,
        ValueNotifier,
        VisualDensity,
        VoidCallback,
        Widget,
        WidgetState,
        WidgetStateProperty,
        WidgetStatePropertyAll,
        WidgetStatesController;

import '../../foundations/foundations.dart';
import '../buttons/components/morph_radius_and_padding_motion.dart';
import '../buttons/enums/morph_button_enums.dart';
import '../buttons/utils/morph_button_gradient_layer.dart';
import '../tooltips/morph_tooltips.dart';
import 'enums/morph_icon_button_enums.dart';
import 'styles/morph_icon_button_decoration.dart';
import 'styles/morph_icon_button_shapes.dart';
import 'styles/morph_icon_button_theme.dart';

export 'enums/morph_icon_button_enums.dart';
export 'styles/morph_icon_button_decoration.dart';
export 'styles/morph_icon_button_shapes.dart';
export 'styles/morph_icon_button_theme.dart';

part 'components/morph_icon_button_build.dart';

/// Material 3 Expressive Icon Button
///
/// - Visual sizes are defined by [MorphIconButtonTheme.visual] (per size × width)
/// - Tap target respects [MorphIconButtonTheme.target] with a minimum of 48×48 on XS/SM
/// - Variants: standard, filled, tonal, outlined
/// - Shapes: round (pill) or square (rounded rect). Toggle can flip shape when selected.
/// - Widths: default, narrow, wide
/// - Toggle: [isSelected] + [selectedIcon]
///  - Badge: [String] or [num]
class MorphIconButton extends StatefulWidget {
  /// MorphIconButton.
  const MorphIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.tooltip,
    this.semanticLabel,
    this.variant = MorphIconButtonVariant.filled,
    this.size = MorphIconButtonSize.sm,
    this.shape = MorphIconButtonShapeVariant.round,
    this.width = MorphIconButtonWidth.defaultWidth,
    this.isSelected,
    this.selectedIcon,
    this.enableFeedback,
    this.haptic = MorphHapticFeedback.inherit,
    this.badgeValue,
    this.suppressInk = false,
    this.visualSize,
    this.decoration,
    this.isGroupConnected = false,
    this.isFirstInGroup = true,
    this.isLastInGroup = true,
    this.inflateHitTarget = true,
    this.matchParentConstraints = false,
    this.statesController,
    this.focusNode,
    this.autofocus = false,
    this.onFocusChange,
  });

  /// icon.

  final Widget icon;

  /// onPressed.
  final VoidCallback? onPressed;

  /// tooltip.
  final String? tooltip;

  /// semanticLabel.
  final String? semanticLabel;

  /// variant.
  final MorphIconButtonVariant variant;

  /// size.
  final MorphIconButtonSize size;

  /// shape.
  final MorphIconButtonShapeVariant shape;

  /// width.
  final MorphIconButtonWidth width;

  /// isSelected.
  final bool? isSelected;

  /// selectedIcon.
  final Widget? selectedIcon;

  /// enableFeedback.
  final bool? enableFeedback;

  /// Haptic intensity on press. Defaults to [MorphHapticFeedback.inherit].
  final MorphHapticFeedback haptic;

  /// badgeValue.
  final Object? badgeValue;

  /// When true, suppresses splash/hover ink effects.
  final bool suppressInk;

  /// Overrides theme visual size when non-null (e.g. sprung toolbar label width).
  ///
  /// Height should typically match [MorphIconButtonTheme.visual] height for
  /// [size]/[width]. The outer tap target uses at least the theme target,
  /// or this size when larger.
  final Size? visualSize;

  /// Optional decoration for solid and gradient surfaces.
  final MorphIconButtonDecoration? decoration;

  /// Whether this icon button belongs to a connected button group.
  final bool isGroupConnected;

  /// Whether this is the first visual item in its connected group.
  final bool isFirstInGroup;

  /// Whether this is the last visual item in its connected group.
  final bool isLastInGroup;

  /// When true (default), XS/S outer layout uses the 48dp target.
  ///
  /// Button groups set this to false so icon actions share the group's
  /// visual height with labeled button siblings.
  final bool inflateHitTarget;

  /// When true, visual width/height track the parent's max constraints.
  ///
  /// Button groups enable this so icon actions expand and shrink with
  /// neighbor-squish slot sizes (same as labeled button actions).
  final bool matchParentConstraints;

  /// Optional externally owned state controller.
  final WidgetStatesController? statesController;

  /// Optional externally owned focus node.
  final FocusNode? focusNode;

  /// Whether this icon button requests focus initially.
  final bool autofocus;

  /// Called when this icon button gains or loses focus.
  final ValueChanged<bool>? onFocusChange;

  @override
  State<MorphIconButton> createState() => _MorphIconButtonState();
}

class _MorphIconButtonState extends State<MorphIconButton> {
  late final WidgetStatesController _internalStatesController;
  late final ValueNotifier<bool> _isPointerDownNotifier;
  late final ValueNotifier<bool> _isHoveredNotifier;
  late final ValueNotifier<bool> _isPressedNotifier;
  late final ValueNotifier<bool> _showFocusRingNotifier;
  final FocusNode _internalFocusNode = FocusNode(debugLabel: 'MorphIconButton');

  WidgetStatesController get _statesController =>
      widget.statesController ?? _internalStatesController;

  FocusNode get _focusNode => widget.focusNode ?? _internalFocusNode;

  @override
  void initState() {
    super.initState();
    _internalStatesController = WidgetStatesController();
    _statesController.addListener(_onStatesChanged);
    _focusNode.addListener(_onFocusChanged);
    _isPointerDownNotifier = ValueNotifier(false);
    _isHoveredNotifier = ValueNotifier(false);
    _isPressedNotifier = ValueNotifier(false);
    _showFocusRingNotifier = ValueNotifier(false);
    FocusManager.instance.addHighlightModeListener(_onHighlightModeChanged);
    MorphFocusInteraction.instance.addListener(_onFocusInteractionChanged);
  }

  @override
  void didUpdateWidget(covariant MorphIconButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.statesController != widget.statesController) {
      (oldWidget.statesController ?? _internalStatesController).removeListener(
        _onStatesChanged,
      );
      _statesController.addListener(_onStatesChanged);
    }
    if (oldWidget.focusNode != widget.focusNode) {
      (oldWidget.focusNode ?? _internalFocusNode).removeListener(
        _onFocusChanged,
      );
      _focusNode.addListener(_onFocusChanged);
    }
  }

  @override
  void dispose() {
    FocusManager.instance.removeHighlightModeListener(_onHighlightModeChanged);
    MorphFocusInteraction.instance.removeListener(_onFocusInteractionChanged);
    _statesController.removeListener(_onStatesChanged);
    _focusNode.removeListener(_onFocusChanged);
    _internalStatesController.dispose();
    _isPointerDownNotifier.dispose();
    _isHoveredNotifier.dispose();
    _isPressedNotifier.dispose();
    _showFocusRingNotifier.dispose();
    _internalFocusNode.dispose();
    super.dispose();
  }

  void _onFocusInteractionChanged() {
    _syncFocusRing();
  }

  void _onFocusChanged() {
    _syncFocusRing();
    widget.onFocusChange?.call(_focusNode.hasFocus);
  }

  void _onStatesChanged() {
    if (!mounted) {
      return;
    }
    final Set<WidgetState> states = _statesController.value;
    _isHoveredNotifier.value = states.contains(WidgetState.hovered);
    _isPressedNotifier.value = states.contains(WidgetState.pressed);
    _syncFocusRing();
  }

  void _onHighlightModeChanged(FocusHighlightMode mode) {
    _syncFocusRing();
  }

  void _syncFocusRing() {
    if (!mounted) {
      return;
    }
    final show = MorphFocusRing.shouldShow(_focusNode, context);
    if (_showFocusRingNotifier.value != show) {
      _showFocusRingNotifier.value = show;
    }
  }

  void _setPointerDown(bool down) {
    if (_isPointerDownNotifier.value == down) {
      return;
    }
    _isPointerDownNotifier.value = down;
  }

  @override
  Widget build(BuildContext context) {
    return MorphComponentTheme(builder: _buildContent);
  }
}
