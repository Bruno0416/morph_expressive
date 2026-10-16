part of 'morph_dismissible_card_controller.dart';

/// MorphDismissibleCardBuildMixin.

mixin MorphDismissibleCardBuildMixin<T extends StatefulWidget>
    on MorphDismissibleCardMixin<T>, MorphDismissibleCardDragMixin<T> {
  @override
  Widget buildSlot(
    BuildContext context,
    int slotIndex, {
    List<int>? visible,
    bool suppressOwnGap = false,
  }) {
    final slot = _slots[slotIndex];
    if (slot.isCollapsing) {
      return _buildCollapsingCard(context, slotIndex);
    }
    return _buildActiveCard(
      context,
      slotIndex,
      visible ?? computeVisibleIndices(),
      suppressOwnGap: suppressOwnGap,
    );
  }

  MorphCardPosition _cardPositionFor(int slotPos, int total) {
    if (total == 1) {
      return MorphCardPosition.single;
    }
    if (slotPos == 0) {
      return MorphCardPosition.first;
    }
    if (slotPos == total - 1) {
      return MorphCardPosition.last;
    }
    return MorphCardPosition.middle;
  }

  Widget _buildActiveCard(
    BuildContext context,
    int slotIndex,
    List<int> visible, {
    bool suppressOwnGap = false,
  }) {
    final slot = _slots[slotIndex];
    final s = style;
    final slotPos = visible.indexOf(slotIndex);
    if (slotPos < 0 || slotPos >= swipeItemCount) {
      return const SizedBox.shrink();
    }

    final total = visible.length;
    final isLast = slotPos == total - 1;
    final isDragged = slotIndex == _dragSlotIndex;
    final dragPos = _dragSlotIndex >= 0 ? visible.indexOf(_dragSlotIndex) : -1;
    final position = _cardPositionFor(slotPos, total);
    final BorderRadius layoutRadius =
        borderRadiusBuilder?.call(slotPos, position) ??
        computeRadius(slotIndex, slotPos, dragPos, visible);
    final nOff = computeNeighbourOffset(slotPos, dragPos);
    final swipingRight = _dragOffset > 0;
    final List<MorphListSwipeAction> actionList = actionsFor(
      slotPos,
      swipingRight: swipingRight,
    );
    final bool hasActions = actionList.isNotEmpty;
    final Widget? activeBg = hasActions
        ? null
        : (swipingRight
              ? s.background
              : (s.secondaryBackground ?? s.background));
    final bgRadius = swipingRight
        ? s.backgroundBorderRadius
        : (s.secondaryBackgroundBorderRadius ?? s.backgroundBorderRadius);
    final revealed = _dragOffset.abs();
    final actionWidth = (revealed - (hasActions ? 0 : s.actionGap)).clamp(
      0.0,
      revealed,
    );
    final bool showReveal =
        isDragged && (actionWidth > 0 || _pastActionThreshold);

    return RepaintBoundary(
      child: Padding(
        padding: s.margin ?? EdgeInsets.zero,
        child: Stack(
          clipBehavior: Clip.none,
          children: _buildActiveRevealLayers(
            context,
            slot: slot,
            slotPos: slotPos,
            position: position,
            isLast: isLast,
            isDragged: isDragged,
            layoutRadius: layoutRadius,
            neighbourOffset: nOff,
            style: s,
            showReveal: showReveal,
            hasActions: hasActions,
            actionList: actionList,
            activeBg: activeBg,
            bgRadius: bgRadius,
            actionWidth: actionWidth,
            swipingRight: swipingRight,
            suppressOwnGap: suppressOwnGap,
          ),
        ),
      ),
    );
  }

  List<Widget> _buildActiveRevealLayers(
    BuildContext context, {
    required MorphDismissibleSlot slot,
    required int slotPos,
    required MorphCardPosition position,
    required bool isLast,
    required bool isDragged,
    required BorderRadius layoutRadius,
    required double neighbourOffset,
    required MorphDismissibleListStyle style,
    required bool showReveal,
    required bool hasActions,
    required List<MorphListSwipeAction> actionList,
    required Widget? activeBg,
    required double bgRadius,
    required double actionWidth,
    required bool swipingRight,
    bool suppressOwnGap = false,
  }) {
    // Reorder rows get their gap from the reorder host instead (see
    // `MorphListReorderHost`), so it can sit detached from the dragged card.
    final double gap = suppressOwnGap ? 0 : style.gap;
    return [
      if (showReveal && hasActions)
        _buildActiveActionsReveal(
          slot: slot,
          isLast: isLast,
          swipingRight: swipingRight,
          actionList: actionList,
          gap: gap,
        )
      else if (showReveal && activeBg != null)
        _buildActiveActionBackground(
          isLast: isLast,
          swipingRight: swipingRight,
          bgRadius: bgRadius,
          actionWidth: actionWidth,
          activeBg: activeBg,
          gap: gap,
        ),
      _buildActiveForegroundCard(
        context,
        slot: slot,
        slotPos: slotPos,
        position: position,
        isLast: isLast,
        isDragged: isDragged,
        layoutRadius: layoutRadius,
        neighbourOffset: neighbourOffset,
        style: style,
        gap: gap,
      ),
    ];
  }

  Widget _buildActiveActionsReveal({
    required MorphDismissibleSlot slot,
    required bool isLast,
    required bool swipingRight,
    required List<MorphListSwipeAction> actionList,
    required double gap,
  }) {
    final double actionsWidth = _computeActionsWidth(actionList);
    final double currentOffset = _pastActionThreshold
        ? math.max(_dragOffset.abs(), actionsWidth)
        : _dragOffset.abs();
    final double bgW = currentOffset.clamp(0.0, double.infinity);
    if (bgW <= 0) {
      return const SizedBox.shrink();
    }

    return Positioned.fill(
      bottom: isLast ? 0 : gap,
      child: RepaintBoundary(
        child: Align(
          alignment: swipingRight
              ? Alignment.centerLeft
              : Alignment.centerRight,
          child: SizedBox(
            width: bgW,
            height: double.infinity,
            child: _buildActionsRow(
              actionList: actionList,
              swipingRight: swipingRight,
              currentOffset: currentOffset,
              baseWidth: actionsWidth,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionsRow({
    required List<MorphListSwipeAction> actionList,
    required bool swipingRight,
    required double currentOffset,
    required double baseWidth,
  }) {
    final double spacing = style.actionSpacing;
    final double edgePad = style.actionEdgePadding;
    final int numActions = actionList.length;
    final double revealProgress = baseWidth > 0
        ? (currentOffset / baseWidth).clamp(0.0, 1.0)
        : 1.0;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double availableHeight = constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : 64.0;
        final double availableWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : 0.0;
        if (availableWidth <= 0 || numActions == 0) {
          return const SizedBox.shrink();
        }

        final double horizontalPad = math.min(edgePad, availableWidth / 2);
        final double innerWidth = math.max(
          0,
          availableWidth - 2 * horizontalPad,
        );
        if (innerWidth <= 0) {
          return const SizedBox.shrink();
        }

        final int gapCount = numActions - 1;
        final double rawGaps = gapCount > 0 ? spacing * gapCount : 0.0;
        // Drop inter-action gaps until the reveal is wide enough to fit them.
        final usedGaps = rawGaps <= innerWidth ? rawGaps : 0.0;
        final double gapBetween = gapCount > 0 ? usedGaps / gapCount : 0.0;
        final double buttonHeight = math.max(
          style.actionMinHeight,
          availableHeight - style.actionVerticalInset,
        );

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPad),
          child: Row(
            mainAxisAlignment: swipingRight
                ? MainAxisAlignment.start
                : MainAxisAlignment.end,
            children: <Widget>[
              for (int i = 0; i < actionList.length; i++) ...<Widget>[
                if (i > 0) SizedBox(width: gapBetween),
                Expanded(
                  child: LayoutBuilder(
                    builder: (BuildContext context, BoxConstraints cell) {
                      final MorphListSwipeAction action = actionList[i];
                      final double resolvedHeight =
                          action.height ?? buttonHeight;
                      return Opacity(
                        opacity: revealProgress,
                        child: MorphListSwipeActionButton(
                          action: action,
                          width: cell.maxWidth,
                          height: resolvedHeight,
                          minWidth: style.actionMinWidth,
                          onTriggered: closeActionPreview,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildActiveActionBackground({
    required bool isLast,
    required bool swipingRight,
    required double bgRadius,
    required double actionWidth,
    required Widget activeBg,
    required double gap,
  }) {
    final double edgePad = style.actionEdgePadding;

    return Positioned.fill(
      bottom: isLast ? 0 : gap,
      child: RepaintBoundary(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final double availableHeight = constraints.maxHeight.isFinite
                ? constraints.maxHeight
                : 64.0;
            final double pillHeight = math.max(
              style.actionMinHeight,
              availableHeight - style.actionVerticalInset,
            );
            final double pillWidth = math.max(0, actionWidth - 2 * edgePad);

            return Align(
              alignment: swipingRight
                  ? Alignment.centerLeft
                  : Alignment.centerRight,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: edgePad),
                child: SizedBox(
                  width: pillWidth,
                  height: pillHeight,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(pillHeight / 2),
                    child: activeBg,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildActiveForegroundCard(
    BuildContext context, {
    required MorphDismissibleSlot slot,
    required int slotPos,
    required MorphCardPosition position,
    required bool isLast,
    required bool isDragged,
    required BorderRadius layoutRadius,
    required double neighbourOffset,
    required MorphDismissibleListStyle style,
    required double gap,
  }) {
    final s = style;

    final bool childOwnsSurface = swipeItemPaintsSurface(slotPos);
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : gap),
      child: Transform.translate(
        offset: Offset(
          isDragged ? _dragOffset + _detachPush : neighbourOffset,
          0,
        ),
        child: Builder(
          builder: (BuildContext context) => _buildForegroundCardChild(
            context,
            slot: slot,
            slotPos: slotPos,
            layoutRadius: layoutRadius,
            style: s,
            childOwnsSurface: childOwnsSurface,
          ),
        ),
      ),
    );
  }

  Widget _buildForegroundCardChild(
    BuildContext context, {
    required MorphDismissibleSlot slot,
    required int slotPos,
    required BorderRadius layoutRadius,
    required MorphDismissibleListStyle style,
    required bool childOwnsSurface,
  }) {
    final Widget surface = Builder(
      builder: (BuildContext context) => _buildForegroundCardSurface(
        context,
        slot: slot,
        slotPos: slotPos,
        layoutRadius: layoutRadius,
        style: style,
      ),
    );
    if (childOwnsSurface) {
      return surface;
    }
    return GestureDetector(
      onHorizontalDragStart: (_) => _onForegroundDragStart(context, slot),
      onHorizontalDragUpdate: (DragUpdateDetails details) =>
          _onForegroundDragUpdate(context, slot, details),
      onHorizontalDragEnd: (DragEndDetails details) =>
          _onForegroundDragEnd(context, details),
      child: surface,
    );
  }

  void _onForegroundDragStart(BuildContext context, MorphDismissibleSlot slot) {
    _dismissDxAcc = 0;
    // With reorder, wait for real horizontal travel so a long-press hold
    // cannot lock dismiss and block reorder — unless preview is already open.
    if (listReorderEnabled && !isActionPreviewOpen) {
      return;
    }
    if (MorphListReorderSessionScope.isActive(context) ||
        _collapsingCount > 0) {
      return;
    }
    handleDragStart(slot);
  }

  void _onForegroundDragUpdate(
    BuildContext context,
    MorphDismissibleSlot slot,
    DragUpdateDetails details,
  ) {
    if (MorphListReorderSessionScope.isActive(context)) {
      return;
    }
    if (_dragSlotRef == null) {
      if (!listReorderEnabled) {
        return;
      }
      _dismissDxAcc += details.delta.dx;
      if (_dismissDxAcc.abs() < kTouchSlop || _collapsingCount > 0) {
        return;
      }
      handleDragStart(slot);
      if (_dragSlotRef == null) {
        return;
      }
    }
    handleDragUpdate(details);
  }

  void _onForegroundDragEnd(BuildContext context, DragEndDetails details) {
    _dismissDxAcc = 0;
    if (_dragSlotRef == null ||
        MorphListReorderSessionScope.isActive(context)) {
      return;
    }
    handleDragEnd(details);
  }

  Widget _buildForegroundCardSurface(
    BuildContext context, {
    required MorphDismissibleSlot slot,
    required int slotPos,
    required BorderRadius layoutRadius,
    required MorphDismissibleListStyle style,
  }) {
    final features = MorphListFeatureScope.maybeOf(context);
    final VoidCallback? userTap = onTapCallback == null
        ? null
        : () => onTapCallback!(slotPos);
    final VoidCallback? selectionTap = _resolveSelectionTap(
      features: features,
      index: slotPos,
      userTap: userTap,
    );
    final VoidCallback? onDoubleTap = _selectionDoubleTapFor(features, slotPos);
    final VoidCallback? boundPress = _collapsingCount > 0
        ? null
        : _bindSelectionTaps(
            index: slotPos,
            onTap: selectionTap,
            onDoubleTap: onDoubleTap,
          );
    final VoidCallback? onPressed = _foregroundPress(slotPos, boundPress);
    final suppressHover = _suppressCardHover;
    final BorderRadius radius =
        morphSelectionRadius(
          context,
          slotPos,
          outerRadius: style.outerRadius,
        ) ??
        layoutRadius;
    final selected = morphSelectionFill(context, slotPos) != null;
    final inDragProxy = MorphListDragProxyScope.maybeOf(context) != null;
    if (swipeItemPaintsSurface(slotPos)) {
      return _buildSwipeItemPointerSurface(
        context,
        slot: slot,
        slotPos: slotPos,
        inDragProxy: inDragProxy,
      );
    }

    return MorphCardRadiusMotion(
      snap: _dragSlotRef != null || selected,
      radius: radius,
      builder: (BuildContext context, BorderRadius animatedRadius) {
        return _buildForegroundMorphCard(
          context,
          slot: slot,
          slotPos: slotPos,
          style: style,
          animatedRadius: animatedRadius,
          inDragProxy: inDragProxy,
          suppressHover: suppressHover,
          onPressed: onPressed,
        );
      },
    );
  }

  Widget _buildSwipeItemPointerSurface(
    BuildContext context, {
    required MorphDismissibleSlot slot,
    required int slotPos,
    required bool inDragProxy,
  }) {
    return KeyedSubtree(
      key: inDragProxy ? null : _measureKey(slot),
      child: Listener(
        onPointerDown: (_) => _dismissDxAcc = 0,
        onPointerMove: (PointerMoveEvent event) =>
            _onSwipeItemPointerMove(context, slot, event),
        onPointerUp: (PointerUpEvent event) => _onForegroundDragEnd(
          context,
          DragEndDetails(primaryVelocity: event.delta.dx),
        ),
        onPointerCancel: (_) => _onForegroundDragEnd(context, DragEndDetails()),
        child: _swipeOverflow(slotPos, swipeItemBuilder(context, slotPos)),
      ),
    );
  }

  void _onSwipeItemPointerMove(
    BuildContext context,
    MorphDismissibleSlot slot,
    PointerMoveEvent event,
  ) {
    if (_dragSlotRef == null) {
      _dismissDxAcc += event.delta.dx;
      if (_dismissDxAcc.abs() < kTouchSlop ||
          event.delta.dx.abs() < event.delta.dy.abs()) {
        return;
      }
      _onForegroundDragStart(context, slot);
    }
    _onForegroundDragUpdate(
      context,
      slot,
      DragUpdateDetails(
        globalPosition: event.position,
        localPosition: event.localPosition,
        delta: event.delta,
        primaryDelta: event.delta.dx,
      ),
    );
  }

  VoidCallback? _selectionDoubleTapFor(
    MorphListFeatureScope? features,
    int slotPos,
  ) {
    if (features == null ||
        !features.selectionEnabled ||
        features.selectionState.trigger !=
            MorphListSelectionTrigger.doubleTap) {
      return null;
    }
    return () => features.onToggleSelection(slotPos);
  }

  VoidCallback? _foregroundPress(int slotPos, VoidCallback? boundPress) {
    if (_collapsingCount > 0 && !isActionPreviewOpen) {
      return null;
    }
    // Without a tap of its own the row reveals its actions or does nothing;
    // either way it stays focusable for the keyboard.
    final VoidCallback press = boundPress ?? _revealFor(slotPos) ?? () {};
    return () => isActionPreviewOpen ? closeActionPreview() : press();
  }

  /// Toggles the action preview, or null when the row has no actions.
  VoidCallback? _revealFor(int slotPos) {
    final bool leading = actionsFor(slotPos, swipingRight: true).isNotEmpty;
    final bool trailing = actionsFor(slotPos, swipingRight: false).isNotEmpty;
    if (!leading && !trailing) {
      return null;
    }
    return () {
      if (isActionPreviewOpen) {
        closeActionPreview();
        return;
      }
      _revealIndex(slotPos, leading: leading && !trailing);
    };
  }

  Widget _swipeOverflow(int slotPos, Widget child) {
    return MorphListSwipeOverflow(onReveal: _revealFor(slotPos), child: child);
  }

  Widget _buildForegroundMorphCard(
    BuildContext context, {
    required MorphDismissibleSlot slot,
    required int slotPos,
    required MorphDismissibleListStyle style,
    required BorderRadius animatedRadius,
    required bool inDragProxy,
    required bool suppressHover,
    required VoidCallback? onPressed,
  }) {
    final EdgeInsetsGeometry pad = style.padding ?? EdgeInsets.zero;
    final parentPads = pad != EdgeInsets.zero;
    return KeyedSubtree(
      key: inDragProxy ? null : _measureKey(slot),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: AbsorbPointer(
          absorbing: suppressHover && !_isDismissDragging,
          child: MorphListRowSurface(
            index: slotPos,
            radius: animatedRadius,
            color:
                colorBuilder?.call(slotPos) ??
                morphSelectionFill(context, slotPos) ??
                style.color ??
                MorphTheme.of(context).colorScheme.surfaceContainerHighest,
            border: style.border,
            onTap: onPressed,
            onLongPress: _foregroundLongPress(slotPos, suppressHover),
            suppressHover: suppressHover,
            mouseCursor: SystemMouseCursors.click,
            dragged: inDragProxy,
            haptic: style.hapticOnTap,
            child: Padding(
              padding: pad,
              child: MorphListItemScope(
                padsChild: parentPads,
                child: _swipeOverflow(
                  slotPos,
                  swipeItemBuilder(context, slotPos),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  VoidCallback? _foregroundLongPress(int slotPos, bool suppressHover) {
    if (suppressHover ||
        isInteractionLocked ||
        listReorderEnabled ||
        onLongPressCallback == null) {
      return null;
    }
    return () => onLongPressCallback!(slotPos);
  }

  /// Matches card-list tap routing using a context under the feature host.
  VoidCallback? _resolveSelectionTap({
    required MorphListFeatureScope? features,
    required int index,
    required VoidCallback? userTap,
  }) {
    if (features == null || !features.selectionEnabled) {
      return userTap;
    }
    return () {
      final bool inMode = features.controller?.isSelectionMode ?? false;
      if (inMode) {
        features.onToggleSelection(index);
        return;
      }
      userTap?.call();
    };
  }

  DateTime? _lastSelectionTapAt;
  int? _lastSelectionTapIndex;

  /// Immediate tap + optional double-tap, surviving mid-tap rebuilds.
  VoidCallback? _bindSelectionTaps({
    required int index,
    required VoidCallback? onTap,
    required VoidCallback? onDoubleTap,
  }) {
    if (onTap == null && onDoubleTap == null) {
      return null;
    }
    return () {
      final now = DateTime.now();
      if (onDoubleTap != null &&
          _lastSelectionTapIndex == index &&
          _lastSelectionTapAt != null &&
          now.difference(_lastSelectionTapAt!) <=
              const Duration(milliseconds: 280)) {
        _lastSelectionTapAt = null;
        _lastSelectionTapIndex = null;
        onDoubleTap();
        return;
      }
      _lastSelectionTapAt = now;
      _lastSelectionTapIndex = index;
      onTap?.call();
    };
  }
}
