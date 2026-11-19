import 'dart:async' show scheduleMicrotask;

import 'package:flutter/gestures.dart'
    show
        LongPressGestureRecognizer,
        LongPressStartDetails,
        PointerDeviceKind,
        PointerDownEvent,
        kSecondaryButton;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../foundations/foundations.dart';
import 'components/morph_menu_popup.dart';
import 'enums/morph_menu_anchor_position.dart';
import 'enums/morph_menu_color_style.dart';
import 'enums/morph_menu_presentation.dart';
import 'models/morph_menu_node.dart';
import 'models/morph_menu_submenu_behavior.dart';
import 'styles/morph_menu_theme.dart';

/// Opens a context menu at [position] (global coordinates).
///
/// Desktop presentation by default: the menu's top-left corner is at
/// [position] and it flips left / above only when it would leave the
/// viewport. Returns the chosen [MorphMenuEntry.value] / selectable value, or
/// `null` when dismissed. Pass [callerFocusNode] to get focus back on Escape or
/// selection when the menu was opened from the keyboard, and
/// [autofocusFirstItem] to highlight the first row immediately (keyboard
/// opening) instead of waiting for the pointer or an arrow key.
Future<T?> showMorphContextMenu<T>({
  required BuildContext context,
  required Offset position,
  required List<MorphMenuNode> children,
  MorphMenuPresentation presentation = MorphMenuPresentation.desktop,
  MorphMenuColorStyle colorStyle = MorphMenuColorStyle.standard,
  MorphSurfaceGlass? glass,
  MorphDensity? density,
  FocusNode? callerFocusNode,
  bool autofocusFirstItem = false,
  MorphMenuSubmenuBehavior submenuBehavior = const MorphMenuSubmenuBehavior(),
  MorphMenuTheme? themeOverride,
}) {
  return showMorphMenu<T>(
    context: context,
    anchor: position & const Size(1, 1),
    children: children,
    position: MorphMenuAnchorPosition.bottomStart,
    colorStyle: colorStyle,
    glass: glass,
    density: density,
    presentation: presentation,
    callerFocusNode: callerFocusNode,
    autofocusFirstItem: autofocusFirstItem,
    submenuBehavior: submenuBehavior,
    themeOverride: themeOverride,
    tapPosition: presentation == MorphMenuPresentation.standard
        ? position
        : null,
  );
}

/// Wraps [child] so it opens a context menu.
///
/// * Secondary click (mouse / trackpad) opens the compact desktop menu with its
///   top-left corner at the pointer.
/// * Long press (touch / stylus) opens the standard presentation, unless
///   [openOnLongPress] is false.
/// * With focus inside the region, Shift+F10 and the Menu / ContextMenu key
///   open the desktop menu at the focused widget's rect and focus returns to
///   it when the menu closes.
///
/// Give the region a [focusNode] (or focus a descendant) to receive the key
/// shortcuts. Provide either [children] or [menuBuilder].
class MorphContextMenuRegion<T> extends StatefulWidget {
  /// Creates a context-menu region.
  const MorphContextMenuRegion({
    required this.child,
    this.children,
    this.menuBuilder,
    this.onSelected,
    this.enabled = true,
    this.openOnLongPress = true,
    this.colorStyle = MorphMenuColorStyle.standard,
    this.glass,
    this.focusNode,
    this.density,
    this.submenuBehavior = const MorphMenuSubmenuBehavior(),
    super.key,
  }) : assert(
         (children != null) != (menuBuilder != null),
         'Provide exactly one of children or menuBuilder.',
       );

  /// The widget that receives the context menu.
  final Widget child;

  /// Static menu content.
  final List<MorphMenuNode>? children;

  /// Builds the menu content each time the menu opens.
  final List<MorphMenuNode> Function(BuildContext context)? menuBuilder;

  /// Called with the chosen value (not for dismissal).
  final ValueChanged<T>? onSelected;

  /// When false the region is inert.
  final bool enabled;

  /// Whether a touch / stylus long press opens the (standard) menu.
  final bool openOnLongPress;

  /// Standard (surface) vs vibrant (tertiary) menu colors.
  final MorphMenuColorStyle colorStyle;

  /// Frosted-glass treatment; null inherits the floating-surface glass.
  final MorphSurfaceGlass? glass;

  /// Focus node of the region. When null the region owns a non-traversable
  /// node that still receives key events bubbling from focused descendants.
  final FocusNode? focusNode;

  /// Density of the desktop menu. Null follows `MorphThemeData.density`.
  final MorphDensity? density;

  /// Submenu hover policy (null policy resolves to the desktop timings).
  final MorphMenuSubmenuBehavior submenuBehavior;

  @override
  State<MorphContextMenuRegion<T>> createState() =>
      _MorphContextMenuRegionState<T>();
}

class _MorphContextMenuRegionState<T> extends State<MorphContextMenuRegion<T>> {
  /// The pointer whose press an inner region already consumed, so nested
  /// regions open only the innermost menu.
  static int? _handledPointer;

  FocusNode? _ownNode;
  int _ticket = 0;

  FocusNode get _node =>
      widget.focusNode ??
      (_ownNode ??= FocusNode(debugLabel: 'MorphContextMenu'));

  @override
  void dispose() {
    _ownNode?.dispose();
    super.dispose();
  }

  void _onPointerDown(PointerDownEvent event) {
    if (!widget.enabled || _handledPointer == event.pointer) {
      return;
    }
    final bool pointer =
        event.kind == PointerDeviceKind.mouse ||
        event.kind == PointerDeviceKind.trackpad;
    if (!pointer || (event.buttons & kSecondaryButton) == 0) {
      return;
    }
    _handledPointer = event.pointer;
    scheduleMicrotask(() => _handledPointer = null);
    _show(event.position, MorphMenuPresentation.desktop, keyboard: false);
  }

  void _onLongPress(LongPressStartDetails details) {
    if (!widget.enabled) {
      return;
    }
    _show(
      details.globalPosition,
      MorphMenuPresentation.standard,
      keyboard: false,
    );
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (!widget.enabled || event is! KeyDownEvent) {
      return KeyEventResult.ignored;
    }
    final LogicalKeyboardKey key = event.logicalKey;
    final bool shiftF10 =
        key == LogicalKeyboardKey.f10 &&
        HardwareKeyboard.instance.isShiftPressed;
    if (!shiftF10 && key != LogicalKeyboardKey.contextMenu) {
      return KeyEventResult.ignored;
    }
    _show(
      _keyboardPosition(node),
      MorphMenuPresentation.desktop,
      keyboard: true,
    );
    return KeyEventResult.handled;
  }

  /// Bottom-left of the focused widget's rect (the region's rect when the
  /// focus is the region itself or not found).
  Offset _keyboardPosition(FocusNode regionNode) {
    final FocusNode? primary = FocusManager.instance.primaryFocus;
    Rect? rect;
    if (primary != null &&
        primary.context != null &&
        primary.ancestors.contains(regionNode)) {
      rect = primary.rect;
    }
    if (rect == null) {
      final RenderObject? object = context.findRenderObject();
      if (object is RenderBox && object.hasSize && object.attached) {
        rect = object.localToGlobal(Offset.zero) & object.size;
      }
    }
    if (rect == null) {
      return Offset.zero;
    }
    if (rect.height > 96) {
      return rect.topLeft + const Offset(16, 16);
    }
    return rect.bottomLeft;
  }

  Future<void> _show(
    Offset position,
    MorphMenuPresentation presentation, {
    required bool keyboard,
  }) async {
    final List<MorphMenuNode> nodes =
        widget.menuBuilder?.call(context) ?? widget.children!;
    if (nodes.isEmpty) {
      return;
    }
    final FocusNode? previous = FocusManager.instance.primaryFocus;
    final int ticket = ++_ticket;
    final T? result = await showMorphContextMenu<T>(
      context: context,
      position: position,
      children: nodes,
      presentation: presentation,
      colorStyle: widget.colorStyle,
      glass: widget.glass,
      density: widget.density,
      callerFocusNode: _node,
      autofocusFirstItem: keyboard,
      submenuBehavior: widget.submenuBehavior,
    );
    if (!mounted) {
      return;
    }
    if (ticket == _ticket) {
      _restoreFocus(previous, keyboard);
    }
    if (result != null) {
      widget.onSelected?.call(result);
    }
  }

  void _restoreFocus(FocusNode? previous, bool keyboard) {
    if (previous != null &&
        previous.context != null &&
        previous.canRequestFocus) {
      previous.requestFocus();
    } else if (keyboard && _node.canRequestFocus) {
      _node.requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content = widget.child;
    if (widget.openOnLongPress && widget.enabled) {
      content = RawGestureDetector(
        behavior: HitTestBehavior.translucent,
        gestures: <Type, GestureRecognizerFactory>{
          LongPressGestureRecognizer:
              GestureRecognizerFactoryWithHandlers<LongPressGestureRecognizer>(
                () => LongPressGestureRecognizer(
                  supportedDevices: const <PointerDeviceKind>{
                    PointerDeviceKind.touch,
                    PointerDeviceKind.stylus,
                    PointerDeviceKind.invertedStylus,
                  },
                ),
                (LongPressGestureRecognizer instance) {
                  instance.onLongPressStart = _onLongPress;
                },
              ),
        },
        child: content,
      );
    }
    return Focus(
      focusNode: _node,
      canRequestFocus: widget.focusNode == null ? true : null,
      skipTraversal: widget.focusNode == null ? true : null,
      onKeyEvent: _onKey,
      child: Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: _onPointerDown,
        child: content,
      ),
    );
  }
}
