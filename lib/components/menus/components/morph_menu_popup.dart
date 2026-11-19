import 'dart:async';

import 'package:flutter/gestures.dart'
    show PointerDeviceKind, PointerHoverEvent, kPrimaryButton;
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
import '../enums/morph_menu_presentation.dart';
import '../enums/morph_menu_selection_mode.dart';
import '../enums/morph_menu_variant.dart';
import '../models/morph_menu_node.dart';
import '../models/morph_menu_submenu_behavior.dart';
import '../styles/morph_menu_theme.dart';
import '../utils/morph_menu_desktop_layout.dart';
import '../utils/morph_menu_overlay_rect.dart';
import '../utils/morph_menu_placer.dart';
import '../utils/morph_menu_spring_motion.dart';
import 'morph_menu_content.dart';
import 'morph_menu_key_scope.dart';
import 'morph_menu_key_target.dart';
import 'morph_menu_presentation_scope.dart';
import 'morph_menu_style_scope.dart';

part 'morph_menu_popup_build.dart';

/// Shows an expressive menu popup anchored to [anchor].
///
/// Returns the selected value from a [MorphMenuSelectable] / [MorphMenuEntry.value],
/// or `null` if dismissed.
///
/// [presentation] defaults to [MorphMenuPresentation.standard] (the expressive
/// geometry, unchanged). [MorphMenuPresentation.desktop] opens a compact,
/// content-fitted desktop context menu whose top-left corner sits at
/// [anchor]'s top-left (flipping only on collision); its geometry follows
/// [density] (default: the ambient `MorphThemeData.density`). Prefer
/// `showMorphContextMenu` / `MorphContextMenuRegion` for context menus.
/// [autofocusFirstItem] defaults to true for standard menus and false for
/// desktop ones (the first arrow key then lands on the first row).
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
  MorphMenuPresentation presentation = MorphMenuPresentation.standard,
  MorphDensity? density,
  bool? autofocusFirstItem,
}) {
  assert(organicStretchIntensity >= 0 && organicStretchIntensity <= 1);
  final bool desktop = presentation == MorphMenuPresentation.desktop;
  // Desktop menus use the bounded fade + scale motion and their own, faster
  // submenu hover timings unless the caller picked a custom policy.
  final MorphDropdownMotionStyle effectiveMotion = desktop
      ? MorphDropdownMotionStyle.centered
      : motionStyle;
  final MorphMenuSubmenuBehavior effectiveSubmenu =
      desktop && submenuBehavior == const MorphMenuSubmenuBehavior()
      ? MorphMenuSubmenuBehavior.desktop
      : submenuBehavior;
  final completer = Completer<T?>();
  final ModalRoute<dynamic>? historyRoute = ModalRoute.of(context);
  final OverlayState overlay = Overlay.of(context, rootOverlay: true);
  final _MorphMenuSession<T> session = _MorphMenuSession<T>(
    coordinator: _MorphMenuCoordinator.of(overlay),
    completer: completer,
  );
  final OverlayEntry entry = OverlayEntry(
    builder: (BuildContext overlayContext) {
      return _MorphMenuCallerTheme(
        caller: context,
        child: MorphMenuPopup<T>(
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
          motionStyle: effectiveMotion,
          organicStretchIntensity: organicStretchIntensity,
          submenuBehavior: effectiveSubmenu,
          presentation: presentation,
          density: density,
          autofocusFirstItem: autofocusFirstItem,
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
        ),
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

/// Carries the caller's [MorphTheme] into a menu mounted in the root overlay.
///
/// Menus live in the root overlay, above any nested `MorphTheme` the caller
/// sits under (a density, brightness or color override on one screen area).
/// This reads the caller's theme at build time, so density, colors and
/// brightness follow the caller; root theme changes rebuild it, and when the
/// caller has no nested theme it adds nothing.
class _MorphMenuCallerTheme extends StatefulWidget {
  const _MorphMenuCallerTheme({required this.caller, required this.child});

  final BuildContext caller;
  final Widget child;

  @override
  State<_MorphMenuCallerTheme> createState() => _MorphMenuCallerThemeState();
}

class _MorphMenuCallerThemeState extends State<_MorphMenuCallerTheme> {
  bool _firstDependencies = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_firstDependencies) {
      _firstDependencies = false;
      return;
    }
    // The caller's subtree rebuilds after the overlay in the same frame; read
    // its theme again once it has.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final MorphThemeData root = MorphTheme.of(context); // Subscribes to root.
    final BuildContext caller = widget.caller;
    final MorphThemeData? nested = caller.mounted
        ? MorphTheme.maybeOf(caller)
        : null;
    if (nested == null || identical(nested, root)) {
      return widget.child;
    }
    return MorphTheme(data: nested, child: widget.child);
  }
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
    this.presentation = MorphMenuPresentation.standard,
    this.density,
    this.autofocusFirstItem,
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

  /// Standard (default) or compact desktop presentation.
  final MorphMenuPresentation presentation;

  /// Density used by the desktop presentation. Null follows the ambient
  /// `MorphThemeData.density`.
  final MorphDensity? density;

  /// Whether the first enabled row takes focus when the menu opens. Null is
  /// true for standard and false for desktop presentation.
  final bool? autofocusFirstItem;

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

  bool get _desktop => widget.presentation == MorphMenuPresentation.desktop;

  bool get _wantsFirstFocus => widget.autofocusFirstItem ?? !_desktop;

  /// Key of the open child submenu, to reach its panel rect and focus.
  final GlobalKey<_MorphMenuPopupState<T>> _submenuKey =
      GlobalKey<_MorphMenuPopupState<T>>();

  /// Key of this popup's panel (the positioned, constrained surface box).
  final GlobalKey _panelKey = GlobalKey(debugLabel: 'MorphMenuPanel');

  /// Focus node of the row whose submenu is open; drives the owner row's
  /// persistent highlight (desktop).
  final ValueNotifier<FocusNode?> _expandedNode = ValueNotifier<FocusNode?>(
    null,
  );

  bool _disposing = false;

  /// Row most recently hovered (desktop).
  MorphMenuKeyTarget? _hoverTarget;

  /// Row whose submenu is open; focus returns to it when the submenu closes.
  MorphMenuKeyTarget? _submenuOwner;

  /// Last pointer position over this panel, and the last one inside the row
  /// that owns the open submenu (apex of the safe triangle).
  Offset? _lastHover;
  Offset? _apex;

  /// Content-fitted desktop geometry computed by the latest build.
  MorphMenuDesktopLayout? _layout;

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

  /// Desktop row hover: the hovered row takes the (single) highlight, an open
  /// submenu is kept while the pointer travels toward it (safe triangle) and
  /// otherwise follows the pointer after the grace period.
  void _onRowEnterAt(
    BuildContext rowContext,
    List<MorphMenuNode>? submenu,
    Offset position,
  ) {
    if (!_desktop) {
      _onRowEnter(rowContext, submenu);
      return;
    }
    if (_removed || _isDismissing) {
      return;
    }
    _focusHovered(rowContext);
    if (!_hoverMode) {
      return;
    }
    _overSelf = true;
    _hoverCloseTimer?.cancel();
    _hoverCloseTimer = null;
    _hoverOpenTimer?.cancel();
    _hoverOpenTimer = null;
    final Rect? rowRect = morphOverlayRectFor(rowContext);
    if (_submenuEntry != null && _isOpenFor(rowRect)) {
      return; // Pointer is on the row that owns the open submenu.
    }
    if (_submenuEntry != null && _inSafeTriangle(position)) {
      // Heading for the submenu: grace period before following the pointer.
      _hoverCloseTimer = Timer(widget.submenuBehavior.closeDelay, () {
        _hoverCloseTimer = null;
        _followPointer(rowContext, submenu);
      });
      return;
    }
    _followPointer(rowContext, submenu);
  }

  /// Applies what hovering [rowContext] means: open its submenu after the
  /// hover delay, or close the open submenu after the grace period.
  void _followPointer(BuildContext rowContext, List<MorphMenuNode>? submenu) {
    if (!mounted || _removed || _isDismissing || _overSubmenu) {
      return;
    }
    if (submenu == null) {
      if (_submenuEntry != null) {
        _hoverCloseTimer?.cancel();
        _hoverCloseTimer = Timer(widget.submenuBehavior.closeDelay, () {
          _hoverCloseTimer = null;
          if (mounted && !_overSubmenu) {
            _removeSubmenu();
          }
        });
      }
      return;
    }
    _hoverOpenTimer?.cancel();
    _hoverOpenTimer = Timer(widget.submenuBehavior.hoverDelay, () {
      _hoverOpenTimer = null;
      if (!mounted || _removed || _isDismissing || !rowContext.mounted) {
        return;
      }
      final Rect? rect = morphOverlayRectFor(rowContext);
      if (rect != null) {
        _openSubmenu(rect, submenu, focusFirst: false, owner: _hoverTarget);
      }
    });
  }

  void _onPanelHover(PointerHoverEvent event) {
    _lastHover = event.position;
    if (_openSubmenuAnchor?.contains(event.position) ?? false) {
      _apex = event.position;
    }
  }

  /// True when [position] lies in the triangle between the last pointer
  /// position over the owner row and the near edge of the open submenu.
  bool _inSafeTriangle(Offset position) {
    final Offset? apex = _apex;
    final BuildContext? panel =
        _submenuKey.currentState?._panelKey.currentContext;
    final Rect? anchor = _openSubmenuAnchor;
    if (apex == null || panel == null || anchor == null) {
      return false;
    }
    final Rect? sub = morphOverlayRectFor(panel);
    if (sub == null) {
      return false;
    }
    final double edgeX = sub.center.dx >= anchor.center.dx
        ? sub.left
        : sub.right;
    final Offset a = Offset(edgeX, sub.top);
    final Offset b = Offset(edgeX, sub.bottom);
    double side(Offset p1, Offset p2, Offset p3) =>
        (p1.dx - p3.dx) * (p2.dy - p3.dy) - (p2.dx - p3.dx) * (p1.dy - p3.dy);
    final double d1 = side(position, apex, a);
    final double d2 = side(position, a, b);
    final double d3 = side(position, b, apex);
    final bool hasNeg = d1 < 0 || d2 < 0 || d3 < 0;
    final bool hasPos = d1 > 0 || d2 > 0 || d3 > 0;
    return !(hasNeg && hasPos);
  }

  bool _isDescendantOf(BuildContext child, BuildContext ancestor) {
    var found = false;
    child.visitAncestorElements((Element element) {
      if (identical(element, ancestor)) {
        found = true;
        return false;
      }
      return true;
    });
    return found;
  }

  MorphMenuKeyTarget? _targetFor(BuildContext rowContext) {
    for (final MorphMenuKeyTarget target in _targets) {
      final BuildContext? context = target.node.context;
      if (context != null && _isDescendantOf(context, rowContext)) {
        return target;
      }
    }
    return null;
  }

  void _focusHovered(BuildContext rowContext) {
    final MorphMenuKeyTarget? target = _targetFor(rowContext);
    _hoverTarget = target;
    if (target != null && target.enabled && !target.node.hasPrimaryFocus) {
      target.node.requestFocus();
    }
  }

  MorphMenuKeyTarget? get _focusedTarget {
    for (final MorphMenuKeyTarget target in _targets) {
      if (target.node.hasFocus) {
        return target;
      }
    }
    return null;
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
    final MorphThemeData data = MorphTheme.of(context);
    if (_desktop) {
      return (widget.themeOverride ?? data.menuTheme).forDesktop(
        widget.density ?? data.density,
      );
    }
    return widget.themeOverride ?? data.menuTheme.metricsFor(widget.variant);
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
      // Standard: 300 ms opening / 250 ms closing. Desktop: a short 140 ms
      // fade + scale from the pointer and a faster 90 ms close.
      duration: _desktop
          ? const Duration(milliseconds: 140)
          : MorphMotion.medium2,
      reverseDuration: _desktop
          ? const Duration(milliseconds: 90)
          : MorphMotion.medium1,
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
        if (_desktop) {
          _heightCtrl.value = 1; // No vertical reveal on desktop.
        } else {
          _heightCtrl.forward();
        }
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
    _disposing = true;
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
    _expandedNode.dispose();
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
    _apex = null;
    if (!_disposing && mounted && _expandedNode.value != null) {
      _expandedNode.value = null;
    }
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

  void _openSubmenu(
    Rect itemRect,
    List<MorphMenuNode> children, {
    bool focusFirst = true,
    MorphMenuKeyTarget? owner,
  }) {
    // A click / key on a row whose submenu is already open keeps it open (no
    // toggling, no flicker); it also supersedes a pending hover open.
    _hoverOpenTimer?.cancel();
    _hoverOpenTimer = null;
    if (_isOpenFor(itemRect)) {
      if (focusFirst && _desktop) {
        _submenuKey.currentState?._focusFirstEnabled(force: true);
      }
      return;
    }
    _removeSubmenu();
    _openSubmenuAnchor = itemRect;
    _submenuOwner = owner ?? _focusedTarget ?? _hoverTarget;
    final Offset? hover = _lastHover;
    if (_desktop) {
      _expandedNode.value = _submenuOwner?.node;
    }
    _apex = hover != null && itemRect.contains(hover) ? hover : itemRect.center;
    final MorphMenuVariant childVariant = widget.variant;
    late OverlayEntry entry;
    final BuildContext callerContext = context;
    entry = OverlayEntry(
      builder: (BuildContext context) {
        return _MorphMenuCallerTheme(
          caller: callerContext,
          child: MorphMenuPopup<T>(
            key: _submenuKey,
            anchor: itemRect,
            children: children,
            position: MorphMenuAnchorPosition.end,
            presentation: widget.presentation,
            density: widget.density,
            autofocusFirstItem: focusFirst,
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
              if (identical(_submenuEntry, entry)) {
                final bool hadFocus =
                    _submenuKey.currentState?._focusScopeNode.hasFocus ?? false;
                final MorphMenuKeyTarget? owner = _submenuOwner;
                _removeSubmenu();
                if (_desktop && hadFocus && owner != null && owner.enabled) {
                  owner.node.requestFocus();
                }
              }
            },
            onRemove: () {
              if (identical(_submenuEntry, entry)) _removeSubmenu();
            },
          ),
        );
      },
    );
    _submenuEntry = entry;
    Overlay.of(context, rootOverlay: true).insert(entry);
  }

  void _focusFirstEnabled({bool force = false}) {
    if (_didInitialFocus && !force) {
      return;
    }
    if (!force && !_wantsFirstFocus) {
      // Pointer-opened desktop menu: no row is highlighted until the pointer
      // or an arrow key picks one; the menu still owns keyboard focus.
      _didInitialFocus = true;
      if (!widget.isSubmenu) {
        // A hover-opened submenu leaves the highlight with its owner row.
        _keyFocus.requestFocus();
      }
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
    final int next = current < 0
        ? (delta > 0 || !_desktop ? 0 : enabled.length - 1)
        : (current + delta) % enabled.length;
    enabled[next].node.requestFocus();
  }

  void _focusEdge({required bool first}) {
    final List<MorphMenuKeyTarget> enabled = _enabledTargets;
    if (enabled.isEmpty) {
      return;
    }
    (first ? enabled.first : enabled.last).node.requestFocus();
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
