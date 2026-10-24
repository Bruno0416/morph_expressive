import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart'
    show
        Align,
        Alignment,
        AlwaysStoppedAnimation,
        AnimatedBuilder,
        AnimatedRotation,
        Animation,
        AutovalidateMode,
        Axis,
        BorderRadius,
        BorderRadiusTween,
        BorderSide,
        BoxConstraints,
        BuildContext,
        Builder,
        CallbackShortcuts,
        Center,
        CircularProgressIndicator,
        Clip,
        ClipRect,
        Color,
        Colors,
        Column,
        CompositedTransformFollower,
        CompositedTransformTarget,
        ConstrainedBox,
        CrossAxisAlignment,
        Directionality,
        EdgeInsets,
        Expanded,
        Flexible,
        Flow,
        Focus,
        FocusHighlightMode,
        FocusManager,
        FocusNode,
        FocusScope,
        FocusScopeNode,
        FocusTraversalGroup,
        FormField,
        FormFieldState,
        GlobalKey,
        HitTestBehavior,
        Icon,
        IconButton,
        InkWell,
        InputDecoration,
        InteractiveInkFeatureFactory,
        KeyEvent,
        KeyEventResult,
        LayerLink,
        ListView,
        Listenable,
        ListenableBuilder,
        Listener,
        MainAxisSize,
        Material,
        MediaQuery,
        NoSplash,
        Offset,
        Opacity,
        OutlineInputBorder,
        OverlayPortal,
        OverlayPortalController,
        Padding,
        PointerDownEvent,
        Positioned,
        ReadingOrderTraversalPolicy,
        RenderBox,
        RepaintBoundary,
        RoundedRectangleBorder,
        Router,
        Row,
        Semantics,
        ShortcutActivator,
        SingleActivator,
        SingleChildScrollView,
        Size,
        SizedBox,
        Stack,
        State,
        StatefulWidget,
        SystemMouseCursors,
        TapDownDetails,
        TapUpDetails,
        Text,
        TextEditingController,
        TextField,
        TextOverflow,
        TextStyle,
        TickerProviderStateMixin,
        Transform,
        TweenAnimationBuilder,
        ValueChanged,
        ValueKey,
        ValueNotifier,
        VoidCallback,
        Widget,
        WidgetBuilder,
        WidgetState,
        WidgetStateProperty,
        WidgetsBinding,
        Wrap,
        WrapCrossAlignment,
        debugPrint;
import 'package:motor/motor.dart';

import '../../foundations/interaction/morph_motion_controller.dart';
import '../../foundations/foundations.dart';
import '../tooltips/morph_tooltips.dart';
import 'components/morph_dropdown_chips.dart';
import 'components/morph_dropdown_menu_item.dart';
import 'controllers/morph_dropdown_controller.dart';
import 'enums/morph_dropdown_expand_direction.dart';
import 'models/morph_dropdown_item.dart';
import 'styles/morph_dropdown_chip_style.dart';
import 'styles/morph_dropdown_field_style.dart';
import 'styles/morph_dropdown_item_style.dart';
import 'styles/morph_dropdown_menu_theme.dart';
import 'styles/morph_dropdown_panel_style.dart';
import 'styles/morph_dropdown_search_style.dart';
import 'utils/morph_dropdown_spring_motion.dart';
import 'utils/morph_dropdown_geometry.dart';

export 'controllers/morph_dropdown_controller.dart';
export 'enums/morph_dropdown_expand_direction.dart';
export 'models/morph_dropdown_item.dart';
export 'styles/morph_dropdown_chip_style.dart';
export 'styles/morph_dropdown_field_style.dart';
export 'styles/morph_dropdown_item_style.dart';
export 'styles/morph_dropdown_menu_theme.dart';
export 'styles/morph_dropdown_panel_style.dart';
export 'styles/morph_dropdown_search_style.dart';

part 'components/morph_dropdown_menu_lifecycle.dart';
part 'components/morph_dropdown_menu_actions.dart';
part 'components/morph_dropdown_menu_field.dart';
part 'components/morph_dropdown_menu_chip_build.dart';
part 'components/morph_dropdown_menu_panel.dart';

/// Signature for a function that asynchronously returns dropdown items.
typedef MorphDropdownFutureRequest<T> =
    Future<List<MorphDropdownItem<T>>> Function();

/// Signature for a custom item builder inside the dropdown list.
typedef MorphDropdownItemBuilder<T> = Widget Function(
  MorphDropdownItem<T> item, {
  required bool selected,
  required VoidCallback onTap,
});

/// A Material 3 Expressive dropdown menu.
///
/// Features Morph‑style outer / inner radius, spring animation powered by the
/// `motor` package, optional multi‑select, search, chip display, async data
/// loading, and customisable trailing icon with animated rotation.
///
/// ## Basic usage
///
/// ```dart
/// MorphDropdownMenu<String>(
///   items: [
///     MorphDropdownItem(label: 'Apple', value: 'apple'),
///     MorphDropdownItem(label: 'Banana', value: 'banana'),
///   ],
///   onSelectionChanged: (items) => print(items),
/// )
/// ```
///
/// ## Async data loading
///
/// ```dart
/// MorphDropdownMenu<int>.future(
///   future: () async {
///     final data = await fetchItems();
///     return data.map((e) => MorphDropdownItem(label: e.name, value: e.id)).toList();
///   },
/// )
/// ```
class MorphDropdownMenu<T> extends StatefulWidget {
  // ── Data ──

  /// The list of items. Ignored when using the [MorphDropdownMenu.future]
  /// constructor (items will be loaded asynchronously).
  final List<MorphDropdownItem<T>> items;

  /// Async item provider. When non-null the dropdown starts in a loading
  /// state and populates items once the future completes.
  final MorphDropdownFutureRequest<T>? future;

  // ── Behaviour ──

  /// When `true`, only a single item can be selected at a time.
  ///
  /// Defaults to `false` (multi-select).
  final bool singleSelect;

  /// Whether to show a search field inside the dropdown.
  final bool searchEnabled;

  /// Whether to show selected items as chips inside the field.
  /// Defaults to `true` when using the default [selectedItemBuilder] to allow the builder to take advantage of chip animations, but can be set to `false` to disable animations while keeping custom rendering.
  final bool showChipAnimation;

  /// Maximum number of selectable items. `0` means unlimited.
  final int maxSelections;

  /// Maximum number of selections when multi-select applies.
  ///
  /// `null` (default) means unlimited. When non-null, must be greater than
  /// zero. Takes precedence over [maxSelections] when set.
  final int? limit;

  /// Called whenever the selection changes.
  final ValueChanged<List<MorphDropdownItem<T>>>? onSelectionChanged;

  /// Called when the search text changes.
  final ValueChanged<String>? onSearchChanged;

  /// Optional programmatic controller.
  final MorphDropdownController<T>? controller;

  /// Whether the dropdown is enabled.
  final bool enabled;

  // ── Shape ──

  /// Radius applied to the dropdown panel container and (when no
  /// [MorphDropdownFieldStyle.borderRadius] is set) the field.
  ///
  /// Defaults to `28.0`.
  final double containerRadius;

  // ── Styling ──

  /// Field style.
  final MorphDropdownFieldStyle fieldStyle;

  /// Dropdown panel style.
  final MorphDropdownPanelStyle dropdownStyle;

  /// Chip style (only used when [showChipAnimation] is true).
  final MorphDropdownChipStyle chipStyle;

  /// Search field style (only used when [searchEnabled] is true).
  final MorphDropdownSearchStyle searchStyle;

  /// Item style.
  final MorphDropdownItemStyle itemStyle;

  /// Optional builder for each dropdown item – overrides default rendering.
  final MorphDropdownItemBuilder<T>? itemBuilder;

  /// Optional builder for the empty state when no items match the filter.
  final WidgetBuilder? emptyBuilder;

  /// Optional builder for each selected item in the field.
  ///
  /// If provided, replaces the default chip rendering. When using this,
  /// [showChipAnimation] should be `true` for the builder to take animations from chips.
  /// Defaut is `true` to allow the builder to take advantage of chip animations, but can be set to `false` to disable animations while keeping custom rendering.
  final Widget Function(MorphDropdownItem<T> item)? selectedItemBuilder;

  /// An optional widget placed between dropdown items.
  ///
  /// When non-null, overrides `itemGap` inside [MorphDropdownItemStyle.itemGap] and is used as the separator in
  /// the dropdown item list.
  final Widget? itemSeparator;

  // ── Form ──

  /// Optional validator for form integration.
  ///
  /// Return a non-null string to indicate a validation error.
  final String? Function(List<MorphDropdownItem<T>>? selectedOptions)?
  validator;

  /// The autovalidate mode for the dropdown when used inside a [Form].
  final AutovalidateMode autovalidateMode;

  // ── Focus ──

  /// An optional [FocusNode] for the dropdown field.
  final FocusNode? focusNode;

  /// Whether to close the dropdown when the system back button is pressed.
  ///
  /// Note: This requires the app to use a [Router] (e.g. `MaterialApp.router`).
  final bool closeOnBackButton;

  // ── Animation ──

  /// The spring motion for the expand animation.
  ///
  /// When null, uses [MorphDropdownMenuTheme.openSpring].
  final MorphSpring? openMotion;

  /// The spring motion for the collapse animation.
  ///
  /// When null, uses [MorphDropdownMenuTheme.closeSpring].
  final MorphSpring? closeMotion;

  // ── Splash ──

  /// The [InteractiveInkFeatureFactory] used for tap feedback on the field
  /// and dropdown items.
  ///
  /// Defaults to [NoSplash.splashFactory] (no ripple). Pass
  /// [InkSplash.splashFactory] or [InkRipple.splashFactory] to restore
  /// material splash feedback.
  final InteractiveInkFeatureFactory? splashFactory;

  // ── Haptics ──

  /// Haptic feedback level on tap.
  final MorphHapticFeedback haptic;

  /// Creates an [MorphDropdownMenu] with a static list of items.
  const MorphDropdownMenu({
    super.key,
    required this.items,
    this.singleSelect = false,
    this.searchEnabled = false,
    this.showChipAnimation = true,
    this.maxSelections = 0,
    this.limit,
    this.onSelectionChanged,
    this.onSearchChanged,
    this.controller,
    this.enabled = true,
    this.containerRadius = 28.0,
    this.fieldStyle = const MorphDropdownFieldStyle(),
    this.dropdownStyle = const MorphDropdownPanelStyle(),
    this.chipStyle = const MorphDropdownChipStyle(),
    this.searchStyle = const MorphDropdownSearchStyle(),
    this.itemStyle = const MorphDropdownItemStyle(),
    this.itemBuilder,
    this.emptyBuilder,
    this.selectedItemBuilder,
    this.itemSeparator,
    this.validator,
    this.autovalidateMode = AutovalidateMode.disabled,
    this.focusNode,
    this.closeOnBackButton = false,
    this.openMotion,
    this.closeMotion,
    this.splashFactory = NoSplash.splashFactory,
    this.haptic = MorphHapticFeedback.inherit,
  }) : future = null,
       assert(
         limit == null || limit > 0,
         'limit must be null or greater than 0',
       );

  /// Creates an [MorphDropdownMenu] that loads items asynchronously.
  const MorphDropdownMenu.future({
    super.key,
    required this.future,
    this.singleSelect = false,
    this.searchEnabled = false,
    this.showChipAnimation = false,
    this.maxSelections = 0,
    this.limit,
    this.onSelectionChanged,
    this.onSearchChanged,
    this.controller,
    this.enabled = true,
    this.containerRadius = 28.0,
    this.fieldStyle = const MorphDropdownFieldStyle(),
    this.dropdownStyle = const MorphDropdownPanelStyle(),
    this.chipStyle = const MorphDropdownChipStyle(),
    this.searchStyle = const MorphDropdownSearchStyle(),
    this.itemStyle = const MorphDropdownItemStyle(),
    this.itemBuilder,
    this.emptyBuilder,
    this.selectedItemBuilder,
    this.itemSeparator,
    this.validator,
    this.autovalidateMode = AutovalidateMode.disabled,
    this.focusNode,
    this.closeOnBackButton = false,
    this.openMotion,
    this.closeMotion,
    this.splashFactory = NoSplash.splashFactory,
    this.haptic = MorphHapticFeedback.inherit,
  }) : items = const [],
       assert(
         limit == null || limit > 0,
         'limit must be null or greater than 0',
       );

  @override
  State<MorphDropdownMenu<T>> createState() => _MorphDropdownMenuState<T>();
}

class _MorphDropdownMenuState<T> extends State<MorphDropdownMenu<T>>
    with TickerProviderStateMixin {
  late MorphDropdownController<T> _controller;
  bool _ownController = false;

  bool _isHoveredField = false;
  bool _isPressedField = false;
  bool _lastIsOpen = false;
  bool _closingPanel = false;

  final Map<Object, SingleMotionController> _chipSlideControllers = {};
  final Map<Object, GlobalKey<MorphSpringChipState>> _chipKeys = {};
  final Set<Object> _removingChips = {};
  List<Object> _previousChipOrder = [];
  bool _isMoreChipsRemoving = false;
  int _moreChipsLastCount = 0;

  final LayerLink _layerLink = LayerLink();
  final OverlayPortalController _portalController = OverlayPortalController();
  MorphOverlayHistory? _overlayHistory;
  final GlobalKey<FormFieldState<List<MorphDropdownItem<T>>?>> _formFieldKey =
      GlobalKey();
  final GlobalKey<MorphMoreChipsIndicatorState> _moreKey = GlobalKey();

  late FocusNode _focusNode;
  final FocusScopeNode _focusTrapScope = FocusScopeNode(
    debugLabel: 'MorphDropdownMenu.trap',
  );
  bool? _openingShowOnTop;

  final TextEditingController _searchTextController = TextEditingController();
  Timer? _searchDebounce;

  bool _isLoading = false;
  String? _errorMessage;

  late final SingleMotionController _expandCtrl;
  late final SingleMotionController _arrowCtrl;
  late final ValueNotifier<bool> _loadingNotifier;

  /// Whether the field should paint the keyboard focus ring.
  late final ValueNotifier<bool> _focusRingNotifier;
  late final Listenable _listenable;

  MorphSpring get _resolvedOpenMotion =>
      widget.openMotion ?? MorphTheme.of(context).dropdownMenuTheme.openSpring;

  MorphSpring get _resolvedCloseMotion =>
      widget.closeMotion ??
      MorphTheme.of(context).dropdownMenuTheme.closeSpring;

  @override
  void initState() {
    super.initState();
    _initControllers();
    _initFocusAndLoading();
    if (widget.future != null) {
      unawaited(_loadAsync());
    }
  }

  @override
  void didUpdateWidget(covariant MorphDropdownMenu<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncItemsFromWidget(oldWidget);
    _syncControllerFromWidget(oldWidget);
    _syncFocusNodeFromWidget(oldWidget);
    _syncMotionFromWidget(oldWidget);
  }

  @override
  void dispose() {
    _releaseOverlayHistory();
    _expandCtrl
      ..removeListener(_onExpandAnimationTick)
      ..dispose();
    _arrowCtrl.dispose();
    _searchDebounce?.cancel();
    _searchTextController.dispose();
    _loadingNotifier.dispose();
    _controller.removeListener(_onControllerChanged);
    if (_ownController) {
      _controller.dispose();
    }
    FocusManager.instance.removeHighlightModeListener(
      _onFocusHighlightModeChanged,
    );
    MorphFocusInteraction.instance.removeListener(_syncFieldFocusRing);
    _focusNode.removeListener(_syncFieldFocusRing);
    _focusRingNotifier.dispose();
    _focusTrapScope.dispose();
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MorphComponentTheme(
      builder: (context) => FormField<List<MorphDropdownItem<T>>?>(
        key: _formFieldKey,
        validator: widget.validator ?? (_) => null,
        autovalidateMode: widget.autovalidateMode,
        initialValue: _controller.selectedItems,
        enabled: widget.enabled,
        builder: _buildFormField,
      ),
    );
  }
}
