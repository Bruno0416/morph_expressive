import 'dart:async';

import 'package:flutter/gestures.dart' show PointerDeviceKind, kPrimaryButton;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:morph_expressive/components/menus/morph_menus.dart'
    show MorphMenu;
import 'package:morph_expressive/morph_components.dart' show MorphMenu;
import 'package:motor/motor.dart';

import '../../../foundations/interaction/morph_motion_controller.dart';
import '../../../foundations/foundations.dart';
import '../../../foundations/surface/morph_glass_surface.dart';
import '../enums/morph_menu_anchor_position.dart';
import '../enums/morph_menu_color_style.dart';
import '../enums/morph_menu_selection_mode.dart';
import '../enums/morph_menu_variant.dart';
import '../models/morph_menu_node.dart';
import '../models/morph_menu_submenu_behavior.dart';
import '../styles/morph_menu_theme.dart';
import '../utils/morph_menu_overlay_rect.dart';
import '../utils/morph_menu_placer.dart';
import '../utils/morph_menu_spring_motion.dart';
import 'morph_menu_content.dart';
import 'morph_menu_key_scope.dart';
import 'morph_menu_key_target.dart';
import 'morph_menu_style_scope.dart';

part 'morph_menu_popup_build.dart';

/// Shows an expressive menu popup anchored to [anchor].
///
/// Returns the selected value from a [MorphMenuSelectable] / [MorphMenuEntry.value],
/// or `null` if dismissed.
Future<T?> showMorphMenu<T>({
  required BuildContext context,
  required Rect anchor,
  required List<MorphMenuNode> children,
  MorphMenuAnchorPosition position = MorphMenuAnchorPosition.bottomEnd,
  MorphMenuColorStyle colorStyle = MorphMenuColorStyle.standard,
  MorphMenuVariant variant = MorphMenuVariant.vertical,
  MorphMenuSelectionMode selectionMode = MorphMenuSelectionMode.single,
  T? selectedValue,
  bool closeOnSelect = true,
  double? preferredWidth,
  MorphDropdownMotionStyle motionStyle = MorphDropdownMotionStyle.centered,
  double organicStretchIntensity = 0.35,
  Offset? tapPosition,
  FocusNode? callerFocusNode,
  MorphMenuTheme? themeOverride,
  MorphSurfaceGlass? glass,
  List<MorphMenuNode> Function()? readChildren,
  ValueChanged<Object?>? onItemChosen,
  void Function(OverlayEntry entry)? onEntry,
  MorphMenuSubmenuBehavior submenuBehavior = const MorphMenuSubmenuBehavior(),
}) {
  assert(organicStretchIntensity >= 0 && organicStretchIntensity <= 1);
  final completer = Completer<T?>();
  final ModalRoute<dynamic>? historyRoute = ModalRoute.of(context);
  final OverlayState overlay = Overlay.of(context, rootOverlay: true);
  final _MorphMenuSession<T> session = _MorphMenuSession<T>(
    coordinator: _MorphMenuCoordinator.of(overlay),
    completer: completer,
  );
  final OverlayEntry entry = OverlayEntry(
    builder: (BuildContext overlayContext) {
      return MorphMenuPopup<T>(
        key: session.key,
        anchor: anchor,
        children: readChildren?.call() ?? children,
        position: position,
        colorStyle: colorStyle,
        variant: variant,
        selectionMode: selectionMode,
        selectedValue: selectedValue,
        closeOnSelect: closeOnSelect,
        preferredWidth: preferredWidth,
        motionStyle: motionStyle,
        organicStretchIntensity: organicStretchIntensity,
        submenuBehavior: submenuBehavior,
        originX: tapPosition == null || anchor.width <= 0
            ? 0.5
            : ((tapPosition.dx - anchor.left) / anchor.width)
                  .clamp(0.0, 1.0)
                  .toDouble(),
        callerFocusNode: callerFocusNode,
        themeOverride: themeOverride,
        glass: glass,
        historyRoute: historyRoute,
        onItemChosen: onItemChosen,
        onSelected: (Object? value) => _completeOnce(completer, value as T?),
        onDismiss: () => _completeOnce(completer, null),
        onRemove: session.finish,
      );
    },
  );
  session.entry = entry;
  // Replaces (and instantly closes) any menu still open in this overlay.
  session.coordinator.present(session);
  overlay.insert(entry);
  onEntry?.call(entry);
  return completer.future;
}

/// Tracks the root menu currently open in one [Overlay].
///
/// Scoped per overlay (not global): opening a menu closes the previous one in
/// the same overlay synchronously, so right-click A -> B -> C replaces menus
/// without outside clicks and without stale close callbacks.
class _MorphMenuCoordinator {
  _MorphMenuCoordinator();

  static final Expando<_MorphMenuCoordinator> _scopes =
      Expando<_MorphMenuCoordinator>('MorphMenuCoordinator');

  static _MorphMenuCoordinator of(OverlayState overlay) =>
      _scopes[overlay] ??= _MorphMenuCoordinator();

  _MorphMenuSession<Object?>? _current;

  void present(_MorphMenuSession<Object?> next) {
    final _MorphMenuSession<Object?>? previous = _current;
    _current = next;
    previous?.closeNow();
  }

  void release(_MorphMenuSession<Object?> session) {
    if (identical(_current, session)) {
      _current = null;
    }
  }
}

/// One root menu: its overlay entry, result completer and close hooks.
class _MorphMenuSession<T> {
  _MorphMenuSession({required this.coordinator, required this.completer});

  final _MorphMenuCoordinator coordinator;
  final Completer<T?> completer;
  final GlobalKey<_MorphMenuPopupState<T>> key =
      GlobalKey<_MorphMenuPopupState<T>>();
  late final OverlayEntry entry;
  bool _finished = false;

  /// Closes without animation. Safe to call repeatedly or before first build.
  void closeNow() {
    if (_finished) {
      return;
    }
    final _MorphMenuPopupState<T>? state = key.currentState;
    if (state != null) {
      state._closeNow();
    } else {
      _completeOnce(completer, null);
      finish();
    }
  }

  /// Removes the entry exactly once.
  void finish() {
    if (_finished) {
      return;
    }
    _finished = true;
    coordinator.release(this as _MorphMenuSession<Object?>);
    entry.remove();
  }
}

void _completeOnce<T>(Completer<T?> completer, T? value) {
  if (!completer.isCompleted) {
    completer.complete(value);
  }
}

/// Overlay surface for [showMorphMenu] / [MorphMenu] (Compose `DropdownMenuPopup`).
class MorphMenuPopup<T> extends StatefulWidget {
  /// MorphMenuPopup.
  const MorphMenuPopup({
    required this.anchor,
    required this.children,
    required this.onSelected,
    required this.onDismiss,
    required this.onRemove,
    this.position = MorphMenuAnchorPosition.bottomEnd,
    this.colorStyle = MorphMenuColorStyle.standard,
    this.variant = MorphMenuVariant.vertical,
    this.selectionMode = MorphMenuSelectionMode.single,
    this.selectedValue,
    this.closeOnSelect = true,
    this.preferredWidth,
    this.motionStyle = MorphDropdownMotionStyle.centered,
    this.organicStretchIntensity = 0.35,
    this.originX = 0.5,
    this.callerFocusNode,
    this.themeOverride,
    this.glass,
    this.historyRoute,
    this.onItemChosen,
    this.isSubmenu = false,
    this.submenuBehavior = const MorphMenuSubmenuBehavior(),
    this.onPointerInside,
    super.key,
  });

  /// anchor.

  final Rect anchor;

  /// children.
  final List<MorphMenuNode> children;

  /// position.
  final MorphMenuAnchorPosition position;

  /// colorStyle.
  final MorphMenuColorStyle colorStyle;

  /// variant.
  final MorphMenuVariant variant;

  /// selectionMode.
  final MorphMenuSelectionMode selectionMode;

  /// selectedValue.
  final T? selectedValue;

  /// closeOnSelect.
  final bool closeOnSelect;

  /// preferredWidth.
  final double? preferredWidth;

  /// Centered and liquid use centered fade + scale for popup menus;
  /// legacy retains the old anchored spring.
  final MorphDropdownMotionStyle motionStyle;
  final double organicStretchIntensity;
  final double originX;

  /// callerFocusNode.
  final FocusNode? callerFocusNode;

  /// themeOverride.
  final MorphMenuTheme? themeOverride;

  /// Frosted-glass treatment for this menu's surfaces.
  ///
  /// When null the popup inherits [MorphThemeData.floatingSurfaceGlass];
  /// when that is also null the original opaque surfaces are kept. Submenus
  /// inherit this same value.
  final MorphSurfaceGlass? glass;

  /// Route that owns this popup's local-history entry.
  ///
  /// Submenus reuse the same route so back closes from the inside out.
  final ModalRoute<dynamic>? historyRoute;

  /// Called when a choice should not close the menu.
  final ValueChanged<Object?>? onItemChosen;

  /// True when this popup was opened from another menu row.
  final bool isSubmenu;

  /// Submenu opening policy (hover / click and delays).
  final MorphMenuSubmenuBehavior submenuBehavior;

  /// Submenus report whether the pointer is over them, so the parent can keep
  /// them open while the pointer crosses from the parent row.
  final ValueChanged<bool>? onPointerInside;

  /// onSelected.
  final ValueChanged<Object?> onSelected;

  /// onDismiss.
  final VoidCallback onDismiss;

  /// onRemove.
  final VoidCallback onRemove;

  @override
  State<MorphMenuPopup<T>> createState() => _MorphMenuPopupState<T>();
}

class _MorphMenuPopupState<T> extends State<MorphMenuPopup<T>>
    with TickerProviderStateMixin {
  late final SingleMotionController _expandCtrl;
  // Unlike the legacy spring, bounded timelines keep centered fade +
  // 80%-to-100% scale and the faster vertical reveal independently reversible.
  late final AnimationController _popupCtrl;
  late final AnimationController _heightCtrl;
  static const double _contentFraction = 0.35; // 65% shorter than the panel.

  bool _isDismissing = false;
  final ValueNotifier<bool> _dismissing = ValueNotifier<bool>(false);
  bool _selected = false;
  bool _removed = false;
  late final bool _keyboardActivated;

  OverlayEntry? _submenuEntry;
  Rect? _openSubmenuAnchor;
  Timer? _hoverOpenTimer;
  Timer? _hoverCloseTimer;
  bool _overSelf = false;
  bool _overSubmenu = false;

  bool get _hoverMode =>
      widget.submenuBehavior.mode == MorphMenuSubmenuOpenMode.hover;

  void _cancelHoverTimers() {
    _hoverOpenTimer?.cancel();
    _hoverOpenTimer = null;
    _hoverCloseTimer?.cancel();
    _hoverCloseTimer = null;
  }

  /// Mouse entered a row. [submenu] is non-null for submenu rows.
  void _onRowEnter(BuildContext rowContext, List<MorphMenuNode>? submenu) {
    if (!_hoverMode || _removed || _isDismissing) {
      return;
    }
    _overSelf = true;
    _hoverCloseTimer?.cancel();
    _hoverCloseTimer = null;
    // Entering another row always cancels what the previous row had pending.
    _hoverOpenTimer?.cancel();
    _hoverOpenTimer = null;
    if (submenu == null) {
      if (_submenuEntry != null) {
        _scheduleSubmenuClose();
      }
      return;
    }
    if (_isOpenFor(morphOverlayRectFor(rowContext))) {
      return; // already open for this row
    }
    _hoverOpenTimer = Timer(widget.submenuBehavior.hoverDelay, () {
      _hoverOpenTimer = null;
      if (!mounted || _removed || _isDismissing || !rowContext.mounted) {
        return;
      }
      final Rect? rect = morphOverlayRectFor(rowContext);
      if (rect != null) {
        _openSubmenu(rect, submenu);
      }
    });
  }

  /// Rows are rebuilt (new node instances), so identity is the row's rect.
  bool _isOpenFor(Rect? rect) {
    final Rect? open = _openSubmenuAnchor;
    return _submenuEntry != null &&
        rect != null &&
        open != null &&
        (open.top - rect.top).abs() < 1 &&
        (open.left - rect.left).abs() < 1;
  }

  void _onSelfPointer(bool inside) {
    if (!_hoverMode) {
      return;
    }
    _overSelf = inside;
    if (inside) {
      _hoverCloseTimer?.cancel();
      _hoverCloseTimer = null;
    } else {
      _hoverOpenTimer?.cancel();
      _hoverOpenTimer = null;
      if (_submenuEntry != null) {
        _scheduleSubmenuClose();
      }
    }
  }

  void _onSubmenuPointer(bool inside) {
    _overSubmenu = inside;
    if (inside) {
      _hoverCloseTimer?.cancel();
      _hoverCloseTimer = null;
    } else if (_submenuEntry != null) {
      _scheduleSubmenuClose();
    }
    // Keep the parent chain alive while a descendant is hovered.
    widget.onPointerInside?.call(inside || _overSelf);
  }

  void _scheduleSubmenuClose() {
    _hoverCloseTimer?.cancel();
    _hoverCloseTimer = Timer(widget.submenuBehavior.closeDelay, () {
      _hoverCloseTimer = null;
      if (!mounted || _overSelf || _overSubmenu) {
        return;
      }
      _removeSubmenu();
    });
  }

  MorphOverlayHistory? _overlayHistory;

  final FocusScopeNode _focusScopeNode = FocusScopeNode(
    debugLabel: 'MorphMenuPopup',
  );
  final FocusNode _keyFocus = FocusNode(
    skipTraversal: true,
    debugLabel: 'MorphMenuKeys',
  );
  final ScrollController _scroll = ScrollController();
  final List<MorphMenuKeyTarget> _targets = <MorphMenuKeyTarget>[];
  Timer? _typeaheadTimer;
  String _typeaheadQuery = '';
  bool _didInitialFocus = false;

  MorphMenuTheme _resolvedTheme(BuildContext context) {
    final MorphMenuTheme ambient = MorphTheme.of(context).menuTheme;
    return widget.themeOverride ?? ambient.metricsFor(widget.variant);
  }

  @override
  void initState() {
    super.initState();
    _keyboardActivated = widget.callerFocusNode?.hasFocus ?? false;
    _overlayHistory = MorphOverlayHistory.registerRoute(
      widget.historyRoute,
      onBack: () => _dismiss(),
    );

    _popupCtrl = AnimationController(
      vsync: this,
      duration: MorphMotion.medium2, // 300 ms opening.
      reverseDuration: MorphMotion.medium1, // 250 ms closing.
    )..addStatusListener(_onPopupStatus);
    _heightCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 240),
      reverseDuration: const Duration(milliseconds: 200),
    );
    _expandCtrl = MorphMotionController(
      motion: MorphMotion.expressiveSpatialDefault.toMotion(),
      vsync: this,
    )..addListener(_onExpandTick);

    if (widget.motionStyle != MorphDropdownMotionStyle.legacy) {
      _expandCtrl.value = 1; // Legacy spring is inactive in liquid mode.
      if (widget.themeOverride?.openInstantly ?? false) {
        _popupCtrl.value = 1;
        _heightCtrl.value = 1;
      } else {
        _popupCtrl.forward();
        _heightCtrl.forward();
      }
    } else if (widget.themeOverride?.openInstantly ?? false) {
      _expandCtrl.value = 1;
    } else {
      _expandCtrl.animateTo(1);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      final MorphMenuTheme openTheme = _resolvedTheme(context);
      if (widget.motionStyle != MorphDropdownMotionStyle.legacy) {
        // Do not restart the opening after the first frame. That caused the
        // initial transition to appear instant or invisible.
        if (openTheme.openInstantly || MorphMotion.reduceMotionOf(context)) {
          _popupCtrl.value = 1;
          _heightCtrl.value = 1;
        }
      } else if (openTheme.openInstantly) {
        _expandCtrl.value = 1;
      } else if (_expandCtrl.value < 1) {
        _expandCtrl.motion = openTheme.openMotion.toMotion();
        _expandCtrl.animateTo(1);
      }
      _focusFirstEnabled();
    });
  }

  void _releaseOverlayHistory() {
    final MorphOverlayHistory? history = _overlayHistory;
    _overlayHistory = null;
    history?.release();
  }

  @override
  void dispose() {
    _cancelHoverTimers();
    _typeaheadTimer?.cancel();
    _releaseOverlayHistory();
    _expandCtrl
      ..removeListener(_onExpandTick)
      ..dispose();
    _popupCtrl
      ..removeStatusListener(_onPopupStatus)
      ..dispose();
    _heightCtrl.dispose();
    _removeSubmenu();
    _dismissing.dispose();
    _focusScopeNode.dispose();
    _keyFocus.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _onExpandTick() {
    if (widget.motionStyle == MorphDropdownMotionStyle.legacy &&
        _isDismissing &&
        !_removed &&
        _expandCtrl.value <= 0.01 &&
        mounted) {
      _removed = true;
      widget.onRemove();
    }
  }

  void _onPopupStatus(AnimationStatus status) {
    if (status == AnimationStatus.dismissed &&
        _isDismissing &&
        !_removed &&
        mounted) {
      _removed = true;
      widget.onRemove();
    }
  }

  // Both fades use a 35% window. On exit the content becomes invisible
  // during the FIRST 35% of closing, while the panel continues to 0%.
  double _popupContentOpacity(double progress) {
    final t = progress.clamp(0.0, 1.0).toDouble();
    if (_isDismissing) {
      final exit = ((1 - t) / _contentFraction).clamp(0.0, 1.0).toDouble();
      return 1 - MorphMotion.exit.transform(exit);
    }
    final enter = (t / _contentFraction).clamp(0.0, 1.0).toDouble();
    return MorphMotion.enter.transform(enter);
  }

  void _removeSubmenu() {
    _submenuEntry?.remove();
    _submenuEntry = null;
    _openSubmenuAnchor = null;
    _overSubmenu = false;
  }

  /// Closes immediately (no exit animation), e.g. when another menu replaces
  /// this one. Idempotent.
  void _closeNow() {
    if (_removed) {
      return;
    }
    _cancelHoverTimers();
    _releaseOverlayHistory();
    _removeSubmenu();
    if (!_isDismissing && !_selected) {
      widget.onDismiss();
    }
    _isDismissing = true;
    _dismissing.value = true;
    _removed = true;
    widget.onRemove();
  }

  void _dismiss({bool restoreFocus = false}) {
    if (_isDismissing || _removed) {
      return;
    }
    _cancelHoverTimers();
    _dismissing.value = true;
    _releaseOverlayHistory();
    _removeSubmenu();
    if (!_selected) {
      widget.onDismiss();
    }
    _isDismissing = true;
    if (_keyboardActivated && restoreFocus) {
      widget.callerFocusNode?.requestFocus();
    }
    if (_resolvedTheme(context).openInstantly ||
        MorphMotion.reduceMotionOf(context)) {
      _removed = true;
      widget.onRemove();
      return;
    }
    if (widget.motionStyle != MorphDropdownMotionStyle.legacy) {
      _popupCtrl.reverse();
      _heightCtrl.reverse();
    } else {
      _expandCtrl.motion = _resolvedTheme(context).closeMotion.toMotion();
      _expandCtrl.animateTo(0);
    }
  }

  void _handleSelect(Object? value) {
    final bool stayOpen =
        widget.selectionMode == MorphMenuSelectionMode.multi ||
        !widget.closeOnSelect;
    if (stayOpen) {
      widget.onItemChosen?.call(value);
      return;
    }
    _selected = true;
    widget.onSelected(value);
    _dismiss(restoreFocus: _focusScopeNode.hasFocus);
  }

  void _openSubmenu(Rect itemRect, List<MorphMenuNode> children) {
    // A click / key on a row whose submenu is already open keeps it open (no
    // toggling, no flicker); it also supersedes a pending hover open.
    _hoverOpenTimer?.cancel();
    _hoverOpenTimer = null;
    if (_isOpenFor(itemRect)) {
      return;
    }
    _removeSubmenu();
    _openSubmenuAnchor = itemRect;
    final MorphMenuVariant childVariant = widget.variant;
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (BuildContext context) {
        return MorphMenuPopup<T>(
          anchor: itemRect,
          children: children,
          position: MorphMenuAnchorPosition.end,
          colorStyle: widget.colorStyle,
          variant: childVariant,
          selectionMode: widget.selectionMode,
          selectedValue: widget.selectedValue,
          closeOnSelect: widget.closeOnSelect,
          callerFocusNode: widget.callerFocusNode,
          themeOverride: widget.themeOverride,
          motionStyle: widget.motionStyle,
          organicStretchIntensity: widget.organicStretchIntensity,
          glass: widget.glass,
          historyRoute: widget.historyRoute,
          onItemChosen: widget.onItemChosen,
          isSubmenu: true,
          submenuBehavior: widget.submenuBehavior,
          onPointerInside: _onSubmenuPointer,
          onSelected: (Object? value) {
            _selected = true;
            widget.onSelected(value);
            _dismiss(restoreFocus: _focusScopeNode.hasFocus);
          },
          onDismiss: () {
            if (identical(_submenuEntry, entry)) _removeSubmenu();
          },
          onRemove: () {
            if (identical(_submenuEntry, entry)) _removeSubmenu();
          },
        );
      },
    );
    _submenuEntry = entry;
    Overlay.of(context, rootOverlay: true).insert(entry);
  }

  void _focusFirstEnabled() {
    if (_didInitialFocus) {
      return;
    }
    for (final MorphMenuKeyTarget target in _targets) {
      if (target.enabled) {
        target.node.requestFocus();
        _didInitialFocus = true;
        return;
      }
    }
  }

  void _exitMenu({required bool forward}) {
    final FocusNode? caller = widget.callerFocusNode;
    _dismiss();
    if (caller == null) {
      return;
    }
    if (forward) {
      caller.nextFocus();
    } else {
      caller.previousFocus();
    }
  }

  List<MorphMenuKeyTarget> get _enabledTargets => _targets
      .where((MorphMenuKeyTarget target) => target.enabled)
      .toList(growable: false);

  void _move(int delta) {
    final List<MorphMenuKeyTarget> enabled = _enabledTargets;
    if (enabled.isEmpty) {
      return;
    }
    final int current = enabled.indexWhere(
      (MorphMenuKeyTarget target) => target.node.hasFocus,
    );
    final int next = current < 0 ? 0 : (current + delta) % enabled.length;
    enabled[next].node.requestFocus();
  }

  void _openFocusedSubmenu() {
    for (final MorphMenuKeyTarget target in _targets) {
      if (target.node.hasFocus) {
        target.onOpenSubmenu?.call();
        return;
      }
    }
  }

  void _typeahead(String character) {
    _typeaheadTimer?.cancel();
    _typeaheadQuery = (_typeaheadQuery + character).toLowerCase();
    _typeaheadTimer = Timer(MorphMotion.long2, () {
      _typeaheadQuery = '';
    });
    final List<MorphMenuKeyTarget> enabled = _enabledTargets;
    if (enabled.isEmpty) {
      return;
    }
    final int current = enabled.indexWhere(
      (MorphMenuKeyTarget target) => target.node.hasFocus,
    );
    for (var step = 1; step <= enabled.length; step++) {
      final int index = (current + step) % enabled.length;
      if (enabled[index].label.toLowerCase().startsWith(_typeaheadQuery)) {
        enabled[index].node.requestFocus();
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_didInitialFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _focusFirstEnabled();
        }
      });
    }
    final MorphThemeData ambient = MorphTheme.of(context);
    final MorphMenuTheme menuTheme = _resolvedTheme(context);
    return MorphTheme(
      data: ambient.copyWith(menuTheme: menuTheme),
      child: _buildPopup(context, menuTheme, ambient.colorScheme),
    );
  }
}
