// ignore_for_file: invalid_use_of_protected_member
// helpers del estado original; se revisaran durante la migracion de motion

part of '../morph_lists.dart';

/// Expand/collapse and container-transform behavior for [_MorphListState],
/// plus the snap-collapse/settle glue used while a row is reordered.
extension _MorphListExpand on _MorphListState {
  void _bindExpandController(MorphExpandableListController? controller) {
    controller?.attach(open: openTransform, close: closeTransform);
  }

  Widget _expandable(
    BuildContext context,
    int index, {
    bool suppressOwnGap = false,
  }) {
    final MorphListExpandableTheme expandable = MorphTheme.of(context)
        .listTheme
        .expandable;
    final MorphExpandableExpanded? expanded = _expandedAt(index);
    final bool hasList = expanded != null && expanded.isList;
    final MorphExpandableStyle decoration = _decoration(context, expandable);
    final MorphSpring expandMotion = _resolveExpandMotion(
      widget.expandMotion,
      hasList,
      expandable.expandMotion,
    );
    final MorphSpring collapseMotion = _resolveExpandMotion(
      widget.collapseMotion,
      hasList,
      expandable.collapseMotion,
    );
    final bool allowMultiple =
        widget.allowMultipleExpanded ?? expandable.allowMultipleExpanded;
    final MorphListCardListTheme cardList = MorphTheme.of(context)
        .listTheme
        .cardList;
    return _buildExpandableItem(
      context: context,
      index: index,
      expanded: expanded,
      decoration: decoration,
      expandMotion: expandMotion,
      collapseMotion: collapseMotion,
      allowMultiple: allowMultiple,
      cardList: cardList,
      suppressOwnGap: suppressOwnGap,
    );
  }

  Widget _buildExpandableItem({
    required BuildContext context,
    required int index,
    required MorphExpandableExpanded? expanded,
    required MorphExpandableStyle decoration,
    required MorphSpring expandMotion,
    required MorphSpring collapseMotion,
    required bool allowMultiple,
    required MorphListCardListTheme cardList,
    bool suppressOwnGap = false,
  }) {
    return MorphExpandableItem(
      index: index,
      totalCount: widget.itemCount,
      isExpanded: _expandedIndices.contains(index),
      headerBuilder: (BuildContext context, int i, double progress) =>
          _expandHeaderAt(i),
      bodyBuilder: (BuildContext context, int i, double progress) {
        return _expandBody(context, i, progress, decoration);
      },
      expanded: expanded,
      decoration: decoration,
      expandMotion: expandMotion,
      collapseMotion: collapseMotion,
      nestVariant: _variant(context, cardList),
      // Reorder rows get their trailing gap from the reorder host instead
      // (see `_reorder`), so it sits detached from the dragged card. The
      // decoration's own gap still separates a header from its own nested
      // sublist (MorphExpandableSublist), and must stay intact.
      trailingGap: suppressOwnGap ? 0 : null,
      onToggle: () => _handleExpandToggle(
        index,
        expanded,
        allowMultiple,
        decoration.haptic,
      ),
      onTransform: () => openTransform(index),
      onTransformAnchor: (BuildContext anchor) {
        _transformAnchors[index] = anchor;
      },
    );
  }

  MorphSpring _resolveExpandMotion(
    MorphSpring? override,
    bool hasList,
    MorphSpring themeMotion,
  ) {
    return override ??
        (hasList ? MorphMotion.expressiveSpatialPress : themeMotion);
  }

  Widget _expandHeaderAt(int i) {
    if (i < 0 || i >= _built.length) {
      return const SizedBox.shrink();
    }
    return _built[i];
  }

  void _handleExpandToggle(
    int index,
    MorphExpandableExpanded? expanded,
    bool allowMultiple,
    MorphHapticFeedback haptic,
  ) {
    if (!_enabledAt(index)) {
      return;
    }
    if (expanded != null && expanded.isTransform) {
      openTransform(index);
      return;
    }
    _toggle(index, allowMultiple: allowMultiple, haptic: haptic);
  }

  MorphExpandableStyle _decoration(
    BuildContext context,
    MorphListExpandableTheme expandable,
  ) {
    final MorphExpandableStyle base =
        widget.expandStyle ?? MorphExpandableStyle.fromTheme(expandable);
    final Color? color = widget.color;
    if (color == null) {
      return base;
    }
    return base.copyWith(color: color);
  }

  Widget _expandBody(
    BuildContext context,
    int index,
    double progress,
    MorphExpandableStyle decoration,
  ) {
    final MorphExpandableExpanded? expanded = _expandedAt(index);
    if (expanded == null ||
        expanded.isList ||
        expanded.isTransform ||
        progress <= 0) {
      return const SizedBox.shrink();
    }
    return ClipRect(
      child: Align(
        alignment: decoration.bodyAlignment,
        heightFactor: progress.clamp(0.0, 1.0),
        child: expanded.child,
      ),
    );
  }

  void _toggle(
    int index, {
    required bool allowMultiple,
    required MorphHapticFeedback haptic,
  }) {
    MorphHaptics.triggerFor(context, haptic);
    final bool opening = !_expandedIndices.contains(index);
    setState(() {
      if (opening) {
        if (!allowMultiple) {
          _expandedIndices.clear();
        }
        _expandedIndices.add(index);
      } else {
        _expandedIndices.remove(index);
      }
    });
    widget.onExpansionChanged?.call(index, isExpanded: opening);
  }

  /// Morphs [index] into its transform destination.
  void openTransform(int index) {
    final BuildContext? itemContext = _transformAnchors[index];
    if (itemContext == null || !itemContext.mounted) {
      return;
    }
    final RenderObject? object = itemContext.findRenderObject();
    if (object is! RenderBox || !object.hasSize) {
      return;
    }
    final MorphExpandableExpanded? expanded = _expandedAt(index);
    final Widget? destination = expanded != null && expanded.isTransform
        ? expanded.child
        : (index >= 0 && index < _transforms.length
              ? _transforms[index]
              : null);
    if (destination == null) {
      return;
    }
    final MorphThemeData theme = MorphTheme.of(itemContext);
    final MorphCardContainerTransformHandle<void>? previous = _transformHandle;
    _transformHandle = null;
    previous?.close();
    final MorphCardContainerTransformHandle<void> handle =
        MorphCardContainerTransform.show<void>(
          context: itemContext,
          origin: object.localToGlobal(Offset.zero) & object.size,
          originRadius: theme.listTheme.cardList.outerRadius,
          originColor: theme.colorScheme.surfaceContainerHighest,
          builder: (BuildContext context) => destination,
        );
    _transformHandle = handle;
    handle.future.whenComplete(() {
      if (identical(_transformHandle, handle)) {
        _transformHandle = null;
      }
    });
  }

  /// Reverses the open container transform.
  void closeTransform() {
    _transformHandle?.close();
    _transformHandle = null;
  }

  /// Snap-collapses [index] so reorder can measure the header.
  Future<void> prepareReorderDrag(int index) async {
    _collapsedForReorder = null;
    if (!_expandedIndices.contains(index)) {
      return;
    }
    _collapsedForReorder = index;
    _snapCollapse = true;
    setState(() => _expandedIndices.remove(index));
    await WidgetsBinding.instance.endOfFrame;
    if (!mounted) {
      return;
    }
    await WidgetsBinding.instance.endOfFrame;
  }

  /// Restores a row collapsed for reorder and remaps indices.
  void settleReorderDrag(int from, int to) {
    final int? pending = _collapsedForReorder;
    _collapsedForReorder = null;
    _snapCollapse = false;
    setState(() {
      _expandedIndices = _expandedIndices
          .map((int i) => _remapListIndex(i, from, to))
          .toSet();
      if (pending != null && pending == from) {
        _expandedIndices.add(to);
      }
    });
    if (from != to) {
      _remapSelection(from, to);
    }
  }

  void _remapSelection(int from, int to) {
    final MorphListFeatureScope? scope = MorphListFeatureScope.maybeOf(context);
    final MorphSelectionController? controller = scope?.controller;
    if (controller == null || scope == null || !scope.selectionEnabled) {
      return;
    }
    final Set<int> remapped = controller.selectedIndices
        .map((int i) => _remapListIndex(i, from, to))
        .toSet();
    if (remapped.length == controller.selectedIndices.length &&
        remapped.containsAll(controller.selectedIndices)) {
      return;
    }
    controller.clear();
    remapped.forEach(controller.select);
    widget.onSelectionChanged?.call(controller.selectedIndices);
  }
}
