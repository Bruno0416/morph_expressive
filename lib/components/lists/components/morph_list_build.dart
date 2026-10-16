part of '../morph_lists.dart';

/// Row-tree construction for [_MorphListState]: snapshotting item builders,
/// laying out the column/scrollable/sliver/reorder body, and building each
/// row's card or expandable wrapper.
extension _MorphListBuild on _MorphListState {
  void _snapshot(BuildContext context) {
    _built.clear();
    _swipes.clear();
    _expanded.clear();
    _transforms.clear();
    for (var index = 0; index < widget.itemCount; index++) {
      final child = widget.itemBuilder(context, index);
      _built.add(child);
      if (child is MorphListItem) {
        _swipes.add(child.swipe);
        _expanded.add(child.expanded);
        _transforms.add(child.transform);
      } else {
        _swipes.add(null);
        _expanded.add(null);
        _transforms.add(null);
      }
    }
  }

  Widget _buildList(BuildContext context) {
    _snapshot(context);
    final MorphExpandableNestScope? nest = MorphExpandableNestScope.maybeOf(
      context,
    );
    _embeddedActive = widget.embedded || nest != null;
    final Widget? empty = _empty();
    if (empty != null) {
      return empty;
    }
    Widget list = MorphListKeyboardGroup(
      itemCount: widget.itemCount,
      semanticsLabel: widget.semanticsLabel,
      sliver: _isSliver,
      child: _layout(context),
    );
    if (widget.selection || widget.reorder) {
      list = MorphListFeatureHost(
        itemCount: widget.itemCount,
        selection: widget.selection,
        reorder: widget.reorder,
        selectionController: widget.selectionController,
        onSelectionChanged: widget.onSelectionChanged,
        selectionState: widget.selectionState,
        reorderState: widget.reorderState,
        child: list,
      );
    }
    list = MorphExpandableSnapCollapse(snap: _snapCollapse, child: list);
    return _margin(list);
  }

  Widget? _empty() {
    final Widget? empty = widget.emptyBuilder;
    if (widget.itemCount != 0 || empty == null) {
      return null;
    }
    return _margin(_isSliver ? SliverToBoxAdapter(child: empty) : empty);
  }

  bool get _isSliver => widget._layout == _MorphListLayout.sliver;

  Widget _margin(Widget child) {
    final EdgeInsetsGeometry? margin = widget.margin;
    if (margin == null) {
      return child;
    }
    if (_isSliver) {
      return SliverPadding(padding: margin, sliver: child);
    }
    return Padding(padding: margin, child: child);
  }

  Widget _layout(BuildContext context) {
    if (widget.reorder && widget._layout != _MorphListLayout.sliver) {
      return _reorder(context);
    }
    switch (widget._layout) {
      case _MorphListLayout.column:
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: _children(context),
        );
      case _MorphListLayout.scrollable:
        return ListView.builder(
          controller: widget.controller,
          physics: widget.physics,
          shrinkWrap: widget.shrinkWrap,
          padding: widget.listPadding,
          clipBehavior: widget.clipBehavior,
          itemCount: slots.length,
          itemBuilder: (BuildContext context, int index) =>
              _row(context, index),
        );
      case _MorphListLayout.sliver:
        return SliverList.builder(
          itemCount: slots.length,
          itemBuilder: (BuildContext context, int index) =>
              _row(context, index),
        );
    }
  }

  List<Widget> _children(BuildContext context) {
    return <Widget>[
      for (int index = 0; index < slots.length; index++) _row(context, index),
    ];
  }

  Widget _reorder(BuildContext context) {
    final MorphListReorderState reorderState =
        widget.reorderState ?? MorphTheme.of(context).listTheme.reorder;
    final MorphListItemTheme itemTheme = MorphTheme.of(context).listTheme.item;
    // Rows built for the reorder host suppress their own trailing gap (see
    // `_card`/`_expandable`) so the host can apply it as a detached spacer
    // instead — otherwise the gap paints as part of the dragged card.
    final double resolvedGap = _baselineOr(
      itemTheme,
      widget.gap,
      MorphListCardListTheme.defaultGap,
    );
    return MorphListReorderHost(
      itemCount: slots.length,
      onReorder: widget.onReorder!,
      reorderState: reorderState,
      gap: resolvedGap,
      scrollable: widget._layout == _MorphListLayout.scrollable,
      controller: widget.controller,
      physics: widget.physics,
      shrinkWrap: widget.shrinkWrap,
      padding: widget.listPadding,
      prepareDrag: prepareReorderDrag,
      onDragSettled: settleReorderDrag,
      canStartDrag: (int index) =>
          !isInteractionLocked &&
          index >= 0 &&
          index < slots.length &&
          slots[index].isVisible,
      itemBuilder: (BuildContext context, int index) =>
          _row(context, index, suppressOwnGap: true),
    );
  }

  Widget _row(
    BuildContext context,
    int slotIndex, {
    bool suppressOwnGap = false,
  }) {
    return Builder(
      builder: (BuildContext context) =>
          _rowBuilt(context, slotIndex, suppressOwnGap: suppressOwnGap),
    );
  }

  Widget _rowBuilt(
    BuildContext context,
    int slotIndex, {
    bool suppressOwnGap = false,
  }) {
    final List<int> visible = computeVisibleIndices();
    final int dataIndex = visible.indexOf(slotIndex);
    final bool collapsing =
        slotIndex >= 0 &&
        slotIndex < slots.length &&
        !slots[slotIndex].isVisible;
    if (collapsing || (dataIndex >= 0 && _swipeAt(dataIndex) != null)) {
      return buildSlot(
        context,
        slotIndex,
        visible: visible,
        suppressOwnGap: suppressOwnGap,
      );
    }
    if (dataIndex < 0) {
      return const SizedBox.shrink();
    }
    return _plain(
      context,
      dataIndex,
      visible.length,
      suppressOwnGap: suppressOwnGap,
    );
  }

  Widget _plain(
    BuildContext context,
    int index,
    int total, {
    bool suppressOwnGap = false,
  }) {
    if (_expandedAt(index) != null) {
      return MorphListItemIndex(
        index: index,
        child: _expandable(context, index, suppressOwnGap: suppressOwnGap),
      );
    }
    return _card(context, index, total, suppressOwnGap: suppressOwnGap);
  }

  Widget _childAt(BuildContext context, int index) {
    if (_expandedAt(index) != null) {
      return _expandable(context, index);
    }
    if (index < 0 || index >= _built.length) {
      return const SizedBox.shrink();
    }
    return _built[index];
  }

  Widget _card(
    BuildContext context,
    int index,
    int total, {
    bool suppressOwnGap = false,
  }) {
    final MorphListItemTheme itemTheme = MorphTheme.of(context).listTheme.item;
    final MorphListCardListTheme cardList = MorphTheme.of(context)
        .listTheme
        .cardList;
    final double usedOuter = _baselineOr(
      itemTheme,
      widget.outerRadius,
      MorphListCardListTheme.defaultOuterRadius,
    );
    final double usedInner = _baselineOr(
      itemTheme,
      widget.innerRadius,
      MorphListCardListTheme.defaultInnerRadius,
    );
    // Reorder rows get their gap from the reorder host instead (see
    // `_reorder`), so it can sit detached from the dragged card.
    final double usedGap = suppressOwnGap
        ? 0
        : _baselineOr(itemTheme, widget.gap, MorphListCardListTheme.defaultGap);
    final MorphCardPosition position = calculateCardPosition(index, total);
    final MorphListFeatureScope? features = MorphListFeatureScope.maybeOf(
      context,
    );
    final bool enabled = _enabledAt(index);
    return MorphListTapBinder(
      onTap: _tapFor(features, index),
      onDoubleTap: _doubleTap(features, index),
      builder: (BuildContext context, VoidCallback? onPressed) {
        return MorphCardListItem(
          index: index,
          position: position,
          outerRadius: usedOuter,
          innerRadius: usedInner,
          gap: usedGap,
          embedded: _embeddedActive,
          color: widget.color,
          resolvedColor:
              widget.colorBuilder?.call(index) ??
              morphSelectionFill(context, index),
          resolvedBorderRadius:
              widget.borderRadiusBuilder?.call(index, position) ??
              morphSelectionRadius(
                context,
                index,
                outerRadius: itemTheme.selectedRadius,
              ),
          padding: widget.padding,
          onTap: !enabled || onPressed == null ? null : (_) => onPressed(),
          onLongPress: widget.reorder ? null : widget.onLongPress,
          semanticLabel: widget.semanticLabelBuilder?.call(index),
          mouseCursor: widget.mouseCursor,
          haptic: widget.haptic,
          variant: _variant(context, cardList),
          border: widget.border ?? cardList.border,
          child: MorphListItemIndex(
            index: index,
            child: index < _built.length
                ? _built[index]
                : const SizedBox.shrink(),
          ),
        );
      },
    );
  }

  MorphCardVariant _variant(
    BuildContext context,
    MorphListCardListTheme cardList,
  ) {
    final MorphExpandableNestScope? nest = MorphExpandableNestScope.maybeOf(
      context,
    );
    return widget.variant ?? nest?.variant ?? cardList.variant;
  }

  double _baselineOr(
    MorphListItemTheme theme,
    double value,
    double specDefault,
  ) {
    if (theme.isBaseline && value == specDefault) {
      return 0;
    }
    return value;
  }

  VoidCallback? _tapFor(MorphListFeatureScope? features, int index) {
    if (features == null || !features.selectionEnabled) {
      if (widget.onTap == null) {
        return null;
      }
      return () => widget.onTap!(index);
    }
    return () {
      final bool inMode = features.controller?.isSelectionMode ?? false;
      if (inMode) {
        features.onToggleSelection(index);
        return;
      }
      widget.onTap?.call(index);
    };
  }

  VoidCallback? _doubleTap(MorphListFeatureScope? features, int index) {
    if (features == null || !features.selectionEnabled) {
      return null;
    }
    if (features.selectionState.trigger !=
        MorphListSelectionTrigger.doubleTap) {
      return null;
    }
    return () => features.onToggleSelection(index);
  }
}
