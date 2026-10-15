import 'package:flutter/widgets.dart';

import '../../../foundations/foundations.dart';
import '../../selection/components/morph_selection_scope.dart';
import '../../selection/controllers/morph_selection_controller.dart';
import '../styles/morph_list_reorder_state.dart';
import '../styles/morph_list_selection_state.dart';
import '../utils/morph_list_selection_binding.dart';
import 'morph_list_feature_scope.dart';

/// Owns or binds selection state and exposes [MorphListFeatureScope].
class MorphListFeatureHost extends StatefulWidget {
  /// Creates a list feature host.
  const MorphListFeatureHost({
    required this.itemCount,
    required this.selection,
    required this.reorder,
    required this.child,
    this.selectionController,
    this.onSelectionChanged,
    this.selectionState,
    this.reorderState,
    super.key,
  });

  /// Top-level item count.
  final int itemCount;

  /// Whether selection is enabled.
  final bool selection;

  /// Whether reorder is enabled.
  final bool reorder;

  /// Optional external controller (ignored when ancestor scope exists).
  final MorphSelectionController? selectionController;

  /// Fired when selection indices change.
  final ValueChanged<Set<int>>? onSelectionChanged;

  /// Optional selection state override.
  final MorphListSelectionState? selectionState;

  /// Optional reorder state override.
  final MorphListReorderState? reorderState;

  /// List body.
  final Widget child;

  @override
  State<MorphListFeatureHost> createState() => _MorphListFeatureHostState();
}

class _MorphListFeatureHostState extends State<MorphListFeatureHost> {
  MorphSelectionController? _owned;
  MorphSelectionController? _listening;
  void _onControllerTick() {
    if (mounted) {
      setState(() {});
    }
  }

  MorphSelectionController? get _active {
    if (!widget.selection) {
      return null;
    }
    final MorphSelectionScope? scope = MorphSelectionScope.maybeOf(context);
    if (scope != null) {
      return scope.controller;
    }
    if (widget.selectionController != null) {
      return widget.selectionController;
    }
    return _owned ??= MorphSelectionController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncListener();
  }

  @override
  void didUpdateWidget(MorphListFeatureHost oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selection != widget.selection ||
        oldWidget.selectionController != widget.selectionController) {
      _syncListener();
    }
  }

  void _syncListener() {
    final MorphSelectionController? next = _active;
    if (identical(next, _listening)) {
      return;
    }
    _listening?.removeListener(_onControllerTick);
    _listening = next;
    _listening?.addListener(_onControllerTick);

    // Drop owned controller when an ancestor/external controller is used.
    if (_owned != null && !identical(_owned, next)) {
      _owned!.dispose();
      _owned = null;
    }
  }

  @override
  void dispose() {
    _listening?.removeListener(_onControllerTick);
    _owned?.dispose();
    super.dispose();
  }

  void _toggle(int index) {
    final MorphSelectionController? controller = _active;
    if (controller == null) {
      return;
    }
    final MorphListSelectionState state = mergeListSelectionState(
      theme: MorphTheme.of(context).listTheme.selection,
      override: widget.selectionState,
    );
    applyListSelectionToggle(
      controller: controller,
      index: index,
      mode: state.mode,
      onChanged: widget.onSelectionChanged,
    );
  }

  @override
  Widget build(BuildContext context) {
    _syncListener();
    final listTheme = MorphTheme.of(context).listTheme;
    final MorphListSelectionState selectionState = mergeListSelectionState(
      theme: listTheme.selection,
      override: widget.selectionState,
    );
    final MorphListReorderState reorderState =
        widget.reorderState ?? listTheme.reorder;

    return MorphListFeatureScope(
      selectionEnabled: widget.selection,
      reorderEnabled: widget.reorder,
      selectionState: selectionState,
      reorderState: reorderState,
      controller: _active,
      itemCount: widget.itemCount,
      onToggleSelection: _toggle,
      child: widget.child,
    );
  }
}
