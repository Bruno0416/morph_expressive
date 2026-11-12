import 'dart:async';
import 'dart:ui' show lerpDouble;

import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart'
    show
        Align,
        BorderSide,
        Alignment,
        AnimatedBuilder,
        BlendMode,
        BorderRadius,
        BoxDecoration,
        BuildContext,
        CallbackShortcuts,
        Clip,
        ClipRRect,
        Color,
        ColoredBox,
        Column,
        CompositedTransformFollower,
        CompositedTransformTarget,
        Center,
        InkWell,
        MaterialType,
        Overlay,
        WidgetState,
        Listenable,
        CrossAxisAlignment,
        DecoratedBox,
        EdgeInsets,
        EdgeInsetsDirectional,
        ExcludeSemantics,
        FocusNode,
        FocusScope,
        FocusScopeNode,
        FocusTraversalGroup,
        FocusTraversalOrder,
        GestureDetector,
        GlobalKey,
        Gradient,
        HitTestBehavior,
        Icon,
        IconTheme,
        IconThemeData,
        IgnorePointer,
        KeyedSubtree,
        LayerLink,
        MainAxisSize,
        Material,
        MediaQuery,
        NumericFocusOrder,
        Offset,
        Opacity,
        OrderedTraversalPolicy,
        OverlayPortal,
        OverlayPortalController,
        Padding,
        Positioned,
        Rect,
        RenderBox,
        RenderObject,
        Row,
        Semantics,
        ShaderMask,
        ShortcutActivator,
        SingleActivator,
        SingleChildScrollView,
        SizedBox,
        Stack,
        StadiumBorder,
        State,
        StatefulWidget,
        Text,
        TickerProviderStateMixin,
        Transform,
        TraversalEdgeBehavior,
        ValueKey,
        ValueListenableBuilder,
        ValueNotifier,
        VoidCallback,
        Widget,
        WidgetsBinding;
import 'package:motor/motor.dart';

import '../../foundations/interaction/morph_motion_controller.dart';
import '../../foundations/foundations.dart';
import '../../foundations/surface/morph_glass_surface.dart';
import '../buttons/utils/morph_button_gradient_layer.dart';
import '../floating_action_buttons/components/morph_fab_container_transform.dart';
import '../floating_action_buttons/morph_floating_action_buttons.dart';
import 'controllers/morph_fab_menu_controller.dart';
import 'enums/morph_fab_menu_color_set.dart';
import 'enums/morph_fab_menu_position.dart';
import 'models/morph_fab_menu_item.dart';
import 'styles/morph_fab_menu_theme.dart';

export 'controllers/morph_fab_menu_controller.dart';
export 'enums/morph_fab_menu_color_set.dart';
export 'enums/morph_fab_menu_position.dart';
export 'models/morph_fab_menu_item.dart';
export 'styles/morph_fab_menu_theme.dart';

part 'components/morph_fab_menu_trigger.dart';
part 'components/morph_fab_menu_overlay.dart';
part 'components/morph_fab_menu_items.dart';

/// A Material 3 Expressive FAB menu.
///
/// Opens from a FAB to show 2–6 related actions. The FAB morphs into a 56dp
/// circular close button while menu pills spring in from the trailing edge.
/// When viewport height is limited, items scroll behind the close button.
class MorphFabMenu extends StatefulWidget {
  /// Creates a FAB menu.
  const MorphFabMenu({
    required this.items,
    this.icon = const Icon(MorphIcons.add),
    this.closeIcon = const Icon(MorphIcons.close),
    this.expandIcon,
    this.collapseIcon,
    this.color = MorphFabColor.primary,
    this.size = MorphFabSize.medium,
    this.position = MorphFabMenuPosition.right,
    this.decoration,
    this.glass,
    this.controller,
    this.renderer = MorphShapeRenderer.auto,
    this.onRendererChanged,
    super.key,
  }) : assert(
         items.length >= 2 && items.length <= 6,
         'A FAB menu needs 2–6 items.',
       );

  /// Menu actions (2–6).
  final List<MorphFabMenuItem> items;

  /// Closed-state FAB icon (alias for [expandIcon] when that is null).
  final Widget icon;

  /// Open-state FAB icon (alias for [collapseIcon] when that is null).
  final Widget closeIcon;

  /// Icon when the menu is closed. Defaults to [icon] (add).
  final Widget? expandIcon;

  /// Icon when the menu is open. Defaults to [closeIcon] (close).
  final Widget? collapseIcon;

  /// FAB / menu color style. Maps to a primary/secondary/tertiary set.
  final MorphFabColor color;

  /// Closed FAB size. Open close button is always 56dp.
  final MorphFabSize size;

  /// Which horizontal corner the open FAB morphs toward.
  final MorphFabMenuPosition position;

  /// Styling for the trigger FAB. Menu items use [MorphFabMenuTheme].
  final MorphFabDecoration? decoration;

  /// Optional controller for programmatic open / close.
  final MorphFabMenuController? controller;

  /// Frosted-glass treatment for the menu item pills.
  ///
  /// When null the items inherit [MorphThemeData.floatingSurfaceGlass].
  /// Item background gradients from the theme take precedence over the
  /// frosted fill. Pass [MorphSurfaceGlass.disabled] for the classic
  /// opaque pills.
  final MorphSurfaceGlass? glass;

  /// Renderer requested for the main surface: [MorphShapeRenderer.shader] /
  /// [MorphShapeRenderer.auto] use the rounded-rectangle shader when it is
  /// loaded; [MorphShapeRenderer.canvas] (and any fallback, e.g. a gradient
  /// fill or a failed load) draws the equivalent `RRect` on Canvas.
  final MorphShapeRenderer renderer;

  /// Reports the renderer actually used by the main surface.
  final ValueChanged<MorphShapeRenderStatus>? onRendererChanged;

  @override
  State<MorphFabMenu> createState() => _MorphFabMenuState();
}

class _MorphFabMenuState extends State<MorphFabMenu>
    with TickerProviderStateMixin
    implements MorphFabMenuControllerClient {
  final LayerLink _link = LayerLink();
  final GlobalKey _fabKey = GlobalKey();
  final OverlayPortalController _portal = OverlayPortalController();
  final FocusNode _closeFocusNode = FocusNode(debugLabel: 'MorphFabMenuClose');

  late List<SingleMotionController> _itemCtrls;
  late List<bool> _itemVisible;
  late List<GlobalKey> _itemKeys;
  final GlobalKey _itemsStackKey = GlobalKey();

  final ValueNotifier<int?> _focusedItemIndex = ValueNotifier<int?>(null);
  final ValueNotifier<bool> _surfaceFocused = ValueNotifier<bool>(false);
  late SingleMotionController _fabShapeCtrl;
  final List<Timer> _staggerTimers = <Timer>[];
  final FocusScopeNode _menuFocusScope = FocusScopeNode(
    debugLabel: 'MorphFabMenu',
    skipTraversal: true,
  );

  bool _open = false;
  MorphOverlayHistory? _overlayHistory;
  MorphFabContainerTransformHandle<dynamic>? _transformHandle;

  SpringMotion _springMotion(MorphSpring spring) =>
      MorphMotion.springMotion(spring);

  SpringMotion get _expandMotion =>
      _springMotion(MorphTheme.of(context).fabMenuTheme.expandSpring);

  SpringMotion get _fabShapeMotion =>
      _springMotion(MorphTheme.of(context).fabMenuTheme.fabShapeSpring);

  Duration get _stagger => MorphTheme.of(context).fabMenuTheme.expandStagger;

  static const double _openWidthStart = 0.5;

  Widget get _resolvedExpandIcon => widget.expandIcon ?? widget.icon;

  Widget get _resolvedCollapseIcon => widget.collapseIcon ?? widget.closeIcon;

  bool get _isRight => widget.position == MorphFabMenuPosition.right;

  Alignment get _fabAlign => _isRight ? Alignment.topRight : Alignment.topLeft;

  Alignment get _menuItemAlign =>
      _isRight ? Alignment.centerRight : Alignment.centerLeft;

  MorphFabMenuColorSet get _colorSet =>
      MorphFabMenuTheme.colorSetFor(widget.color);

  @override
  void initState() {
    super.initState();
    _itemCtrls = _createControllers(widget.items.length);
    _itemVisible = List<bool>.filled(widget.items.length, false);
    _itemKeys = List<GlobalKey>.generate(
      widget.items.length,
      (_) => GlobalKey(),
    );
    _fabShapeCtrl = MorphMotionController(
      motion: _springMotion(MorphFabMenuTheme.defaults.fabShapeSpring),
      vsync: this,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_portal.isShowing) {
        _portal.show();
        setState(() {});
      }
    });
    MorphFocusInteraction.instance.addListener(_onFocusInteractionChanged);
    widget.controller?.attachClient(this);
    widget.controller?.updateOpen(open: false);
  }

  void _onFocusInteractionChanged() {
    if (!MorphFocusInteraction.instance.ringsAllowed) {
      _focusedItemIndex.value = null;
    }
  }

  @override
  void didUpdateWidget(covariant MorphFabMenu oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.detachClient(this);
      widget.controller?.attachClient(this);
      widget.controller?.updateOpen(open: _open);
    }
    if (oldWidget.items.length != widget.items.length) {
      _disposeItemControllers();
      _itemCtrls = _createControllers(widget.items.length);
      _itemVisible = List<bool>.filled(widget.items.length, _open);
      _itemKeys = List<GlobalKey>.generate(
        widget.items.length,
        (_) => GlobalKey(),
      );
      _focusedItemIndex.value = null;
      if (_open) {
        for (final SingleMotionController c in _itemCtrls) {
          c.value = 1;
        }
      }
    }
  }

  void _holdOverlayHistory() {
    _overlayHistory ??= MorphOverlayHistory.register(context, onBack: _close);
  }

  void _releaseOverlayHistory() {
    final MorphOverlayHistory? history = _overlayHistory;
    _overlayHistory = null;
    history?.release();
  }

  @override
  void dispose() {
    _releaseOverlayHistory();
    widget.controller?.detachClient(this);
    MorphFocusInteraction.instance.removeListener(_onFocusInteractionChanged);
    _cancelStagger();
    _disposeItemControllers();
    _fabShapeCtrl.dispose();
    _menuFocusScope.dispose();
    _closeFocusNode.dispose();
    _focusedItemIndex.dispose();
    _surfaceFocused.dispose();
    _transformHandle?.close();
    super.dispose();
  }

  List<SingleMotionController> _createControllers(int count) {
    final motion = _springMotion(MorphFabMenuTheme.defaults.expandSpring);
    return List<SingleMotionController>.generate(
      count,
      (_) => MorphMotionController(motion: motion, vsync: this),
    );
  }

  void _disposeItemControllers() {
    for (final SingleMotionController c in _itemCtrls) {
      c.dispose();
    }
  }

  void _cancelStagger() {
    for (final Timer t in _staggerTimers) {
      t.cancel();
    }
    _staggerTimers.clear();
  }

  @override
  void onOpenRequested() => _openMenu();

  @override
  void onCloseRequested() => _close();

  void _toggle() {
    if (_open) {
      _close();
    } else {
      _openMenu();
    }
  }

  void _scheduleItemReveal(int itemIndex, int delayMs) {
    _staggerTimers.add(
      Timer(Duration(milliseconds: delayMs), () {
        if (!mounted || !_open) {
          return;
        }
        setState(() => _itemVisible[itemIndex] = true);
        // No reset to 0: an interrupted close continues from the visible value.
        _itemCtrls[itemIndex]
          ..motion = _expandMotion
          ..animateTo(1);
        if (itemIndex == 0) {
          _focusSurfaceAfterFrame();
        }
      }),
    );
  }

  void _focusSurfaceAfterFrame() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_open) {
        return;
      }
      _closeFocusNode.requestFocus();
    });
  }

  void _revealMenuItems() {
    // Cascade from the FAB upward: bottom item (nearest FAB) first.
    final int count = _itemCtrls.length;
    final int staggerMs = _stagger.inMilliseconds;
    for (var i = 0; i < count; i++) {
      final int fromFab = count - 1 - i;
      _scheduleItemReveal(i, fromFab * staggerMs);
    }
  }

  /// The scrim/items layer exists while open or while anything is still
  /// collapsing, so closing is as continuous as opening.
  bool get _menuLayerVisible {
    if (_open || _fabShapeCtrl.value > 0.002) {
      return true;
    }
    for (final SingleMotionController c in _itemCtrls) {
      if (c.value > 0.002) {
        return true;
      }
    }
    return false;
  }

  bool _itemShown(int i) => _itemVisible[i] || _itemCtrls[i].value > 0.002;

  void _onSurfacePressed() {
    MorphHaptics.triggerFor(context);
    _toggle();
  }

  void _onSurfaceRenderer(MorphShapeRenderStatus status) =>
      widget.onRendererChanged?.call(status);

  void _close() {
    if (!_open) {
      return;
    }
    _releaseOverlayHistory();
    _cancelStagger();
    final bool hadMenuFocus = _menuFocusScope.hasFocus;
    _itemVisible = List<bool>.filled(_itemCtrls.length, false);
    _focusedItemIndex.value = null;
    _menuFocusScope.traversalEdgeBehavior = TraversalEdgeBehavior.parentScope;
    setState(() => _open = false);
    widget.controller?.updateOpen(open: false);
    // Items collapse (from the current value, interruptible) together with
    // the surface returning to its closed shape.
    for (final SingleMotionController c in _itemCtrls) {
      c
        ..motion = _expandMotion
        ..animateTo(0);
    }
    _fabShapeCtrl
      ..motion = _fabShapeMotion
      ..animateTo(0);
    if (hadMenuFocus) {
      // Focus returns to the (same) main control.
      _closeFocusNode.requestFocus();
    }
  }

  void _openMenu() {
    if (_open) {
      return;
    }
    _cancelStagger();
    _focusedItemIndex.value = null;
    _menuFocusScope.traversalEdgeBehavior = TraversalEdgeBehavior.closedLoop;
    setState(() => _open = true);
    _holdOverlayHistory();
    widget.controller?.updateOpen(open: true);
    _fabShapeCtrl
      ..motion = _fabShapeMotion
      ..animateTo(1);
    _revealMenuItems();
  }

  Future<void> _openItemTransform(MorphFabMenuItem item, int index) async {
    if (_transformHandle != null || item.openBuilder == null) {
      return;
    }
    final BuildContext? originContext = _itemKeys[index].currentContext;
    if (originContext == null || !originContext.mounted) {
      return;
    }
    final RenderObject? renderObject = originContext.findRenderObject();
    if (renderObject is! RenderBox || !renderObject.hasSize) {
      return;
    }
    final theme = MorphTheme.of(context);
    final fabMenuTheme = theme.fabMenuTheme;
    final Rect origin =
        renderObject.localToGlobal(Offset.zero) & renderObject.size;
    final handle = MorphFabContainerTransform.show(
      context: context,
      origin: origin,
      originRadius: fabMenuTheme.itemHeight / 2,
      originColor: fabMenuTheme.itemContainerColor(
        theme.colorScheme,
        _colorSet,
      ),
      openColor: item.openColor,
      scrimColor: item.transformScrimColor,
      builder: item.openBuilder!,
    );
    _transformHandle = handle;
    item.onPressed?.call();
    await handle.future;
    _transformHandle = null;
  }

  Future<void> _onItemTap(MorphFabMenuItem item, int index) async {
    if (item.openBuilder != null) {
      await _openItemTransform(item, index);
    } else {
      item.onPressed?.call();
    }
    if (mounted) {
      _close();
    }
  }

  @override
  Widget build(BuildContext context) =>
      _MorphFabMenuTrigger(this).build(context);

  void _setItemFocused(int index, bool focused) {
    final bool show = focused && MorphFocusInteraction.instance.ringsAllowed;
    final int? next = show ? index : null;
    if (_focusedItemIndex.value == next) {
      return;
    }
    if (!show && _focusedItemIndex.value != index) {
      return;
    }
    _focusedItemIndex.value = next;
  }

  double _widthFactor(double t) =>
      _openWidthStart + (1.0 - _openWidthStart) * t;
}
