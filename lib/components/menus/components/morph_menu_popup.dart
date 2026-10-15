import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:morph_expressive/components/menus/morph_menus.dart'
    show MorphMenu;
import 'package:morph_expressive/morph_components.dart' show MorphMenu;
import 'package:motor/motor.dart';

import '../../../foundations/foundations.dart';
import '../enums/morph_menu_anchor_position.dart';
import '../enums/morph_menu_color_style.dart';
import '../enums/morph_menu_selection_mode.dart';
import '../enums/morph_menu_variant.dart';
import '../models/morph_menu_node.dart';
import '../styles/morph_menu_theme.dart';
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
  FocusNode? callerFocusNode,
  MorphMenuTheme? themeOverride,
  List<MorphMenuNode> Function()? readChildren,
  ValueChanged<Object?>? onItemChosen,
  void Function(OverlayEntry entry)? onEntry,
}) {
  final completer = Completer<T?>();
  final ModalRoute<dynamic>? historyRoute = ModalRoute.of(context);
  late OverlayEntry entry;
  entry = OverlayEntry(
    builder: (BuildContext overlayContext) {
      return MorphMenuPopup<T>(
        anchor: anchor,
        children: readChildren?.call() ?? children,
        position: position,
        colorStyle: colorStyle,
        variant: variant,
        selectionMode: selectionMode,
        selectedValue: selectedValue,
        closeOnSelect: closeOnSelect,
        preferredWidth: preferredWidth,
        callerFocusNode: callerFocusNode,
        themeOverride: themeOverride,
        historyRoute: historyRoute,
        onItemChosen: onItemChosen,
        onSelected: (Object? value) => _completeOnce(completer, value as T?),
        onDismiss: () => _completeOnce(completer, null),
        onRemove: () => entry.remove(),
      );
    },
  );
  Overlay.of(context, rootOverlay: true).insert(entry);
  onEntry?.call(entry);
  return completer.future;
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
    this.callerFocusNode,
    this.themeOverride,
    this.historyRoute,
    this.onItemChosen,
    this.isSubmenu = false,
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

  /// callerFocusNode.
  final FocusNode? callerFocusNode;

  /// themeOverride.
  final MorphMenuTheme? themeOverride;

  /// Route that owns this popup's local-history entry.
  ///
  /// Submenus reuse the same route so back closes from the inside out.
  final ModalRoute<dynamic>? historyRoute;

  /// Called when a choice should not close the menu.
  final ValueChanged<Object?>? onItemChosen;

  /// True when this popup was opened from another menu row.
  final bool isSubmenu;

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
    with SingleTickerProviderStateMixin {
  late final SingleMotionController _expandCtrl;
  bool _isDismissing = false;
  bool _selected = false;
  bool _removed = false;
  late final bool _keyboardActivated;

  OverlayEntry? _submenuEntry;
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

    _expandCtrl = SingleMotionController(
      motion: MorphMotion.expressiveSpatialDefault.toMotion(),
      vsync: this,
    )..addListener(_onExpandTick);
    if (widget.themeOverride?.openInstantly ?? false) {
      _expandCtrl.value = 1;
    } else {
      _expandCtrl.animateTo(1);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      final MorphMenuTheme openTheme = _resolvedTheme(context);
      if (openTheme.openInstantly) {
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
    _typeaheadTimer?.cancel();
    _releaseOverlayHistory();
    _expandCtrl
      ..removeListener(_onExpandTick)
      ..dispose();
    _removeSubmenu();
    _focusScopeNode.dispose();
    _keyFocus.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _onExpandTick() {
    if (_isDismissing && !_removed && _expandCtrl.value <= 0.01 && mounted) {
      _removed = true;
      widget.onRemove();
    }
  }

  void _removeSubmenu() {
    _submenuEntry?.remove();
    _submenuEntry = null;
  }

  void _dismiss({bool restoreFocus = false}) {
    if (_isDismissing) {
      return;
    }
    _releaseOverlayHistory();
    _removeSubmenu();
    if (!_selected) {
      widget.onDismiss();
    }
    _isDismissing = true;
    if (_keyboardActivated && restoreFocus) {
      widget.callerFocusNode?.requestFocus();
    }
    if (_resolvedTheme(context).openInstantly) {
      _removed = true;
      widget.onRemove();
      return;
    }
    _expandCtrl.motion = _resolvedTheme(context).closeMotion.toMotion();
    _expandCtrl.animateTo(0);
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
    _removeSubmenu();
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
          historyRoute: widget.historyRoute,
          onItemChosen: widget.onItemChosen,
          isSubmenu: true,
          onSelected: (Object? value) {
            _selected = true;
            widget.onSelected(value);
            _dismiss(restoreFocus: _focusScopeNode.hasFocus);
          },
          onDismiss: () {
            entry.remove();
            _submenuEntry = null;
          },
          onRemove: () {
            entry.remove();
            _submenuEntry = null;
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
