import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart'
    show
        AnimatedRotation,
        BlendMode,
        Border,
        BorderRadius,
        BorderRadiusDirectional,
        BorderSide,
        BoxConstraints,
        BoxDecoration,
        BoxShadow,
        BuildContext,
        Canvas,
        Center,
        Clip,
        ClipRRect,
        Color,
        Colors,
        ConstrainedBox,
        Container,
        CustomPaint,
        CustomPainter,
        DefaultTextStyle,
        Directionality,
        EdgeInsets,
        EdgeInsetsDirectional,
        Flexible,
        Focus,
        FocusNode,
        FocusTraversalGroup,
        GlobalKey,
        Gradient,
        Icon,
        IconData,
        IconTheme,
        IconThemeData,
        IgnorePointer,
        InkSparkle,
        InkWell,
        InteractiveInkFeatureFactory,
        Key,
        KeyEvent,
        KeyEventResult,
        KeyedSubtree,
        MainAxisSize,
        Material,
        MediaQuery,
        MouseCursor,
        NoSplash,
        Offset,
        Overlay,
        Padding,
        Paint,
        PaintingStyle,
        PopupMenuEntry,
        PopupMenuTheme,
        PopupMenuThemeData,
        RRect,
        Radius,
        ReadingOrderTraversalPolicy,
        Rect,
        RelativeRect,
        RenderBox,
        RoundedRectangleBorder,
        Row,
        Semantics,
        ShaderMask,
        Size,
        SizedBox,
        State,
        StatefulWidget,
        StatelessWidget,
        SystemMouseCursors,
        TapRegion,
        Text,
        TextDirection,
        TextOverflow,
        TextStyle,
        Transform,
        ValueChanged,
        VoidCallback,
        Widget,
        WidgetState,
        WidgetStateProperty,
        WidgetStatePropertyAll,
        WidgetStatesController,
        debugPrint,
        showMenu;

import '../../foundations/foundations.dart';
import '../buttons/components/morph_base_button_state.dart';
import '../buttons/components/morph_radius_and_padding_motion.dart';
import '../buttons/enums/morph_button_enums.dart';
import '../buttons/res/morph_button_constants.dart';
import '../buttons/styles/morph_button_motion.dart';
import '../buttons/styles/morph_button_theme.dart';
import '../buttons/utils/morph_button_gradient_layer.dart';
import '../menus/morph_menus.dart';
import '../dropdown_menus/utils/morph_dropdown_geometry.dart';
import '../tooltips/morph_tooltips.dart';
import 'components/morph_split_button_bottom_sheet.dart';
import 'enums/morph_split_button_menu_style.dart';
import 'enums/morph_split_button_selection_mode.dart';
import 'enums/morph_split_button_trailing_alignment.dart';
import 'models/morph_split_button_item.dart';
import 'styles/morph_split_button_bottom_sheet_decoration.dart';
import 'styles/morph_split_button_decoration.dart';
import 'styles/morph_split_button_popup_decoration.dart';
import 'styles/morph_split_button_theme.dart';

export '../menus/models/morph_menu_node.dart';
export 'enums/morph_split_button_menu_style.dart';
export 'enums/morph_split_button_selection_mode.dart';
export 'enums/morph_split_button_trailing_alignment.dart';
export 'models/morph_split_button_item.dart';
export 'styles/morph_split_button_bottom_sheet_decoration.dart';
export 'styles/morph_split_button_checkbox_style.dart';
export 'styles/morph_split_button_decoration.dart';
export 'styles/morph_split_button_popup_decoration.dart';
export 'styles/morph_split_button_theme.dart';

part 'components/morph_split_button_widgets.dart';
part 'components/morph_split_button_style.dart';
part 'components/morph_split_button_content.dart';
part 'components/morph_split_button_segments.dart';
part 'components/morph_split_button_menu.dart';
part 'components/morph_split_button_gradient.dart';

const bool _kDefaultEnableFeedback = true;

/// Material 3 Expressive Split Button.
class MorphSplitButton<T> extends StatefulWidget {
  /// const.
  const MorphSplitButton({
    super.key,
    required this.items,
    this.onSelected,
    this.onPressed,
    this.label,
    this.leadingIcon,
    this.size = MorphButtonSize.sm,
    this.shape = MorphButtonShape.round,
    this.style = MorphButtonStyle.filled,
    this.trailingAlignment = MorphSplitButtonTrailingAlignment.opticalCenter,
    this.leadingTooltip,
    this.trailingTooltip,
    this.enabled = true,
    this.menuBuilder,
    this.morphMenuBuilder,
    this.decoration,
    this.mouseCursor,
    this.statesController,
    this.focusNode,
    this.autofocus = false,
    this.onFocusChange,
    this.selectedValue,
    this.onMultiSelected,
    this.onLongPress,
    this.onHover,
    this.enableFeedback = _kDefaultEnableFeedback,
    this.splashFactory,
  }) : assert(
         items != null || menuBuilder != null || morphMenuBuilder != null,
         'Provide either `items`, `menuBuilder`, or `morphMenuBuilder`.',
       ),
       assert(
         style != MorphButtonStyle.text,
         'MorphSplitButton does not support MorphButtonStyle.text.',
       ),
       assert(
         !enabled ||
             onPressed != null ||
             onSelected != null ||
             menuBuilder != null ||
             morphMenuBuilder != null,
         'Provide either onPressed, onSelected, menuBuilder, or morphMenuBuilder when the split button is enabled.',
       );

  /// A filled split button (highest emphasis).
  const MorphSplitButton.filled({
    super.key,
    required this.items,
    this.onSelected,
    this.onPressed,
    this.label,
    this.leadingIcon,
    this.size = MorphButtonSize.sm,
    this.shape = MorphButtonShape.round,
    this.trailingAlignment = MorphSplitButtonTrailingAlignment.opticalCenter,
    this.leadingTooltip,
    this.trailingTooltip,
    this.enabled = true,
    this.menuBuilder,
    this.morphMenuBuilder,
    this.decoration,
    this.mouseCursor,
    this.statesController,
    this.focusNode,
    this.autofocus = false,
    this.onFocusChange,
    this.selectedValue,
    this.onMultiSelected,
    this.onLongPress,
    this.onHover,
    this.enableFeedback = _kDefaultEnableFeedback,
    this.splashFactory,
  }) : style = MorphButtonStyle.filled,
       assert(
         items != null || menuBuilder != null || morphMenuBuilder != null,
         'Provide either `items`, `menuBuilder`, or `morphMenuBuilder`.',
       );

  /// A tonal split button (medium emphasis).
  const MorphSplitButton.tonal({
    super.key,
    required this.items,
    this.onSelected,
    this.onPressed,
    this.label,
    this.leadingIcon,
    this.size = MorphButtonSize.sm,
    this.shape = MorphButtonShape.round,
    this.trailingAlignment = MorphSplitButtonTrailingAlignment.opticalCenter,
    this.leadingTooltip,
    this.trailingTooltip,
    this.enabled = true,
    this.menuBuilder,
    this.morphMenuBuilder,
    this.decoration,
    this.mouseCursor,
    this.statesController,
    this.focusNode,
    this.autofocus = false,
    this.onFocusChange,
    this.selectedValue,
    this.onMultiSelected,
    this.onLongPress,
    this.onHover,
    this.enableFeedback = _kDefaultEnableFeedback,
    this.splashFactory,
  }) : style = MorphButtonStyle.tonal,
       assert(
         items != null || menuBuilder != null || morphMenuBuilder != null,
         'Provide either `items`, `menuBuilder`, or `morphMenuBuilder`.',
       );

  /// An elevated split button (medium emphasis with a shadow).
  const MorphSplitButton.elevated({
    super.key,
    required this.items,
    this.onSelected,
    this.onPressed,
    this.label,
    this.leadingIcon,
    this.size = MorphButtonSize.sm,
    this.shape = MorphButtonShape.round,
    this.trailingAlignment = MorphSplitButtonTrailingAlignment.opticalCenter,
    this.leadingTooltip,
    this.trailingTooltip,
    this.enabled = true,
    this.menuBuilder,
    this.morphMenuBuilder,
    this.decoration,
    this.mouseCursor,
    this.statesController,
    this.focusNode,
    this.autofocus = false,
    this.onFocusChange,
    this.selectedValue,
    this.onMultiSelected,
    this.onLongPress,
    this.onHover,
    this.enableFeedback = _kDefaultEnableFeedback,
    this.splashFactory,
  }) : style = MorphButtonStyle.elevated,
       assert(
         items != null || menuBuilder != null || morphMenuBuilder != null,
         'Provide either `items`, `menuBuilder`, or `morphMenuBuilder`.',
       );

  /// An outlined split button (medium emphasis with a border).
  const MorphSplitButton.outlined({
    super.key,
    required this.items,
    this.onSelected,
    this.onPressed,
    this.label,
    this.leadingIcon,
    this.size = MorphButtonSize.sm,
    this.shape = MorphButtonShape.round,
    this.trailingAlignment = MorphSplitButtonTrailingAlignment.opticalCenter,
    this.leadingTooltip,
    this.trailingTooltip,
    this.enabled = true,
    this.menuBuilder,
    this.morphMenuBuilder,
    this.decoration,
    this.mouseCursor,
    this.statesController,
    this.focusNode,
    this.autofocus = false,
    this.onFocusChange,
    this.selectedValue,
    this.onMultiSelected,
    this.onLongPress,
    this.onHover,
    this.enableFeedback = _kDefaultEnableFeedback,
    this.splashFactory,
  }) : style = MorphButtonStyle.outlined,
       assert(
         items != null || menuBuilder != null || morphMenuBuilder != null,
         'Provide either `items`, `menuBuilder`, or `morphMenuBuilder`.',
       );

  /// final.

  final List<MorphSplitButtonItem<T>>? items;

  /// final.
  final ValueChanged<T>? onSelected;

  /// final.
  final VoidCallback? onPressed;

  /// final.
  final String? label;

  /// final.
  final IconData? leadingIcon;

  /// final.
  final MorphButtonSize size;

  /// final.
  final MorphButtonShape shape;

  /// final.
  final MorphButtonStyle style;

  /// final.
  final MorphSplitButtonTrailingAlignment trailingAlignment;

  /// final.
  final String? leadingTooltip;

  /// final.
  final String? trailingTooltip;

  /// final.
  final bool enabled;

  /// Flutter [PopupMenuEntry] builder. Uses Material [showMenu] (not Morph).
  ///
  /// When set, takes priority over [morphMenuBuilder] and [items].
  final List<PopupMenuEntry<T>> Function(BuildContext)? menuBuilder;

  /// Rich Morph menu tree. Respects [MorphSplitButtonDecoration.menuStyle] for
  /// popup / native paths. Ignored when [menuBuilder] is set.
  ///
  /// Bottom-sheet [MorphSplitButtonMenuStyle.bottomSheet] is not supported for
  /// custom trees — falls back to the spring popup.
  final List<MorphMenuNode> Function(BuildContext)? morphMenuBuilder;

  /// final.
  final MorphSplitButtonDecoration? decoration;

  /// final.
  final MouseCursor? mouseCursor;

  /// final.
  final WidgetStatesController? statesController;

  /// final.
  final FocusNode? focusNode;

  /// final.
  final bool autofocus;

  /// final.
  final ValueChanged<bool>? onFocusChange;

  /// final.
  final T? selectedValue;

  /// final.
  final void Function(Set<T>)? onMultiSelected;

  /// final.
  final VoidCallback? onLongPress;

  /// final.
  final ValueChanged<bool>? onHover;

  /// final.
  final bool enableFeedback;

  /// final.
  final InteractiveInkFeatureFactory? splashFactory;

  /// WidgetStateProperty.

  WidgetStateProperty<Color?>? get decorationBackgroundColor =>
      decoration?.backgroundColor;

  /// WidgetStateProperty.
  WidgetStateProperty<Color?>? get decorationForegroundColor =>
      decoration?.foregroundColor;

  /// Color.
  Color? get decorationTrailingBackgroundColor =>
      decoration?.trailingBackgroundColor;

  /// Color.
  Color? get decorationTrailingForegroundColor =>
      decoration?.trailingForegroundColor;

  /// MorphButtonSize.
  MorphButtonSize? get decorationLeadingCustomSize =>
      decoration?.leadingCustomSize;

  /// MorphButtonSize.
  MorphButtonSize? get decorationTrailingCustomSize =>
      decoration?.trailingCustomSize;

  /// MorphButtonMotion.
  MorphButtonMotion? get decorationMotion => decoration?.motion;

  /// double.
  double? get decorationGap => decoration?.gap;

  /// Color.
  Color? get decorationMenuBackgroundColor => decoration?.menuBackgroundColor;

  /// Color.
  Color? get decorationMenuForegroundColor => decoration?.menuForegroundColor;

  /// WidgetStateProperty.
  WidgetStateProperty<BorderSide?>? get decorationBorderSide =>
      decoration?.side;

  /// MorphHapticFeedback.
  MorphHapticFeedback get decorationHaptic =>
      decoration?.haptic ?? MorphHapticFeedback.inherit;

  /// Duration. Zero keeps the segment clip on the spring, not Material's tween.
  Duration get decorationAnimationDuration =>
      decoration?.animationDuration ?? Duration.zero;

  /// double.
  double? get decorationBorderRadius => decoration?.borderRadius;

  /// WidgetStateProperty.
  WidgetStateProperty<Color?>? get decorationOverlayColor =>
      decoration?.overlayColor;

  /// WidgetStateProperty.
  WidgetStateProperty<Color?>? get decorationSurfaceTintColor =>
      decoration?.surfaceTintColor;

  @override
  State<MorphSplitButton<T>> createState() => _MorphSplitButtonState<T>();
}

class _MorphSplitButtonState<T> extends State<MorphSplitButton<T>>
    with MorphBaseButtonState<MorphSplitButton<T>> {
  bool _menuOpen = false;
  bool _leadingPressed = false;
  bool _trailingPressed = false;
  bool _isTrailingHovered = false;
  bool _isTrailingFocused = false;
  late FocusNode _trailingFocusNode;

  void _closeMenu() {
    if (!mounted) {
      return;
    }
    isPointerDownNotifier.value = false;
    setState(() {
      _menuOpen = false;
      _trailingPressed = false;
    });
  }

  Set<T>? _selectedValues;
  final GlobalKey _trailingKey = GlobalKey();
  final GlobalKey _splitGradientHostKey = GlobalKey();

  @override
  MorphButtonSize get buttonSize => widget.size;

  @override
  WidgetStatesController? get externalStatesController =>
      widget.statesController;

  @override
  FocusNode? get externalFocusNode => widget.focusNode;

  @override
  MorphButtonMotion? get effectiveMotion => widget.decorationMotion;

  MorphButtonTheme get _buttonTheme => MorphTheme.of(context).buttonTheme;

  MorphSplitButtonTheme get _splitTheme =>
      MorphTheme.of(context).splitButtonTheme;

  MorphColorScheme get _scheme => MorphTheme.of(context).colorScheme;

  @override
  void initState() {
    super.initState();
    initBaseButtonState();
    _trailingFocusNode = FocusNode(debugLabel: 'MorphSplitButton.trailing');
    _trailingFocusNode.addListener(_onTrailingFocusChanged);
    MorphFocusInteraction.instance.addListener(_onTrailingFocusChanged);
  }

  void _onTrailingFocusChanged() {
    if (!mounted) {
      return;
    }
    final focused = MorphFocusRing.shouldShow(_trailingFocusNode, context);
    if (_isTrailingFocused != focused) {
      setState(() => _isTrailingFocused = focused);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    updateSpringMotion();
  }

  @override
  void didUpdateWidget(covariant MorphSplitButton<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    handleStatesControllerUpdate(
      oldWidget.statesController,
      widget.statesController,
    );
    handleFocusNodeUpdate(oldWidget.focusNode, widget.focusNode);

    if (widget.decoration?.motion != oldWidget.decoration?.motion) {
      updateSpringMotion();
    }
  }

  @override
  void dispose() {
    MorphFocusInteraction.instance.removeListener(_onTrailingFocusChanged);
    _trailingFocusNode
      ..removeListener(_onTrailingFocusChanged)
      ..dispose();
    disposeBaseButtonState();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MorphComponentTheme(
      builder: (context) => buildAnimatedContent(
        builder:
            (
              context, {
              required isPressed,
              required isHovered,
              required isFocused,
            }) {
              return _buildContent(context, isPressed, isHovered, isFocused);
            },
      ),
    );
  }
}
