part of '../morph_tabs.dart';

/// Focus nodes, controller binding, measurement, indicator state and
/// scroll-reveal for [MorphTabs].
///
/// Who moves the indicator:
/// * rest: the measured extent of the selected tab;
/// * page position published by a `MorphTabsView`: a pure function of that
///   position (drag, fling and animated page changes alike);
/// * otherwise a tap animation `_from` -> live destination, started from the
///   currently visible extent so a retarget never jumps.
extension _MorphTabsIndicator on _MorphTabsState {
  void _alloc(int count) {
    _slotKeys = List<GlobalKey>.generate(count, (_) => GlobalKey());
    _contentKeys = List<GlobalKey>.generate(count, (_) => GlobalKey());
    _nodes = List<FocusNode>.generate(count, (int i) {
      return FocusNode(debugLabel: 'tab $i')..addListener(() => _onFocus(i));
    });
  }

  void _disposeNodes() {
    for (final FocusNode node in _nodes) {
      node.dispose();
    }
  }

  void _bindController() {
    final MorphTabsController? next = widget.controller;
    if (identical(_bound, next)) {
      _bound?.updateIndex(_index);
      return;
    }
    _bound?.detach(_controllerSelect);
    _bound?.position.removeListener(_positionListener);
    _bound = next;
    next?.attach(_controllerSelect, _index);
    next?.position.addListener(_positionListener);
  }

  void _selectFromController(int index) {
    widget.onTabSelected(index);
  }

  // ---------------------------------------------------------------------
  // Visible state.

  MorphTabsMotionParams get _params => (
    motion: _spec.motion,
    elasticity: MorphMotion.reduceMotionOf(context) ? 0 : _spec.elasticity,
  );

  /// Extent the indicator shows now, in track coordinates.
  MorphTabsEdges? _visibleEdges() {
    if (_stale || _targets.isEmpty) {
      return _shown;
    }
    final MorphTabsPosition? pos = _bound?.position.value;
    final MorphTabsMotionParams params = _params;
    late final MorphTabsEdges edges;
    if (pos != null) {
      edges = MorphTabsGeometry.atPosition(
        _targets,
        pos.value,
        motion: params.motion,
        elasticity: params.elasticity,
      );
    } else if (_from != null) {
      edges = MorphTabsGeometry.between(
        _from!,
        _targets[_toIndex.clamp(0, _targets.length - 1)],
        _spec.curve.transform(_anim.value),
        motion: params.motion,
        elasticity: params.elasticity,
      );
    } else {
      // At rest the indicator sits on the tab it last settled on. A selection
      // that just changed is picked up by `_sync`, which starts the motion from
      // here; reading the new index would teleport the indicator.
      edges = _targets[_lastIndex.clamp(0, _targets.length - 1)];
    }
    return _shown = edges;
  }

  /// Selection weight of every tab: 1 for selected, 0 otherwise, in between
  /// while the indicator travels. Only colours use it, never layout.
  List<double> _weights() {
    final int n = widget.tabs.length;
    final MorphTabsPosition? pos = _bound?.position.value;
    if (pos != null) {
      return MorphTabsGeometry.weights(
        n,
        pos.value,
        from: pos.from,
        to: pos.to,
      );
    }
    if (_from != null && _fromWeights.length == n) {
      final double t = _spec.curve.transform(_anim.value);
      return <double>[
        for (var i = 0; i < n; i++)
          _fromWeights[i] + ((i == _toIndex ? 1.0 : 0.0) - _fromWeights[i]) * t,
      ];
    }
    return <double>[for (var i = 0; i < n; i++) i == _index ? 1.0 : 0.0];
  }

  double _weightOf(int index) {
    final List<double> all = _weights();
    return index < all.length ? all[index] : 0;
  }

  void _onAnimStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      _from = null;
      _pulse.pulse();
    }
  }

  void _startTap(int index, MorphTabsEdges from) {
    _fromWeights = _weights();
    _from = from;
    _toIndex = index;
    final Duration duration = MorphMotion.durationOf(context, _spec.duration);
    if (duration == Duration.zero) {
      _anim.stop();
      _from = null;
      _pulse.pulse();
      return;
    }
    _anim
      ..duration = duration
      ..forward(from: 0);
  }

  void _onPosition() {
    final MorphTabsPosition? pos = _bound?.position.value;
    if (pos != null) {
      if (_from != null) {
        _anim.stop();
        _from = null;
      }
      _pageActive = true;
      final int near = pos.value.round();
      if (near != _revealed) {
        _revealed = near;
        _revealIndex(near);
      }
    } else if (_pageActive) {
      _pageActive = false;
      _settled = true;
      _scheduleSync();
    }
    _pulse.pulse();
  }

  // ---------------------------------------------------------------------
  // Measurement and synchronisation.

  void _scheduleSync() {
    if (_syncScheduled) {
      return;
    }
    _syncScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncScheduled = false;
      if (mounted) {
        _sync();
      }
    });
  }

  /// Records what could invalidate the measurement. Runs from build, only
  /// schedules work when a signature actually changed.
  void _observe(Object layoutSig, Object contentSig) {
    if (layoutSig != _layoutSig) {
      _layoutSig = layoutSig;
      _layoutChanged = true;
      _scheduleSync();
    }
    if (contentSig != _contentSig) {
      _contentSig = contentSig;
      _contentChanged = true;
      _scheduleSync();
    }
  }

  void _sync() {
    _checkSelectionPolicy();
    if (!mounted) {
      return;
    }
    final MorphTabsEdges? before = _visibleEdges();
    if (!_measure()) {
      if (_syncRetries++ < 3) {
        _scheduleSync();
      }
      return;
    }
    _syncRetries = 0;
    final int i = _index.clamp(0, _targets.length - 1);
    final bool contentChanged = _contentChanged;
    final bool layoutChanged = _layoutChanged;
    final bool settled = _settled;
    _contentChanged = false;
    _layoutChanged = false;
    _settled = false;
    if (!_placed) {
      _placed = true;
      _shown = _targets[i];
      _lastIndex = i;
      _revealIndex(i, animate: false);
      _pulse.pulse();
      return;
    }
    if (_pageActive || (_bound?.isPageDriven ?? false)) {
      // The pages own the position. Never fight them.
      _lastIndex = i;
      _pulse.pulse();
      return;
    }
    final bool selectionChanged = i != _lastIndex;
    _lastIndex = i;
    final MorphTabsEdges target = _targets[i];
    final MorphTabsEdges from = before ?? target;
    final bool animatingThere = _from != null && _toIndex == i;
    final bool snap =
        layoutChanged && !contentChanged && !selectionChanged && !settled;
    if (!animatingThere &&
        !snap &&
        (selectionChanged || contentChanged || settled) &&
        !from.near(target)) {
      _startTap(i, from);
    }
    if (selectionChanged || settled) {
      _revealIndex(i);
    }
    _pulse.pulse();
  }

  /// Reads the real layout of every tab (text with its scale and typography,
  /// icon, badge, gaps, padding). Returns false when it is not laid out yet.
  bool _measure() {
    final RenderObject? trackObject = _trackKey.currentContext
        ?.findRenderObject();
    if (trackObject is! RenderBox || !trackObject.hasSize) {
      return false;
    }
    final List<MorphTabsEdges> next = <MorphTabsEdges>[];
    final double trackWidth = trackObject.size.width;
    for (var i = 0; i < widget.tabs.length; i++) {
      final RenderObject? slotObject = _slotKeys[i].currentContext
          ?.findRenderObject();
      final RenderObject? contentObject = _contentKeys[i].currentContext
          ?.findRenderObject();
      if (slotObject is! RenderBox ||
          contentObject is! RenderBox ||
          !slotObject.hasSize ||
          !contentObject.hasSize ||
          !slotObject.attached ||
          !contentObject.attached) {
        return false;
      }
      final double slotLeft = slotObject
          .localToGlobal(Offset.zero, ancestor: trackObject)
          .dx;
      final double contentLeft = contentObject
          .localToGlobal(Offset.zero, ancestor: trackObject)
          .dx;
      next.add(
        _edgesFor(
          slotLeft: slotLeft,
          slotWidth: slotObject.size.width,
          contentLeft: contentLeft,
          contentWidth: contentObject.size.width,
          trackWidth: trackWidth,
        ),
      );
    }
    _targets = next;
    _stale = false;
    return true;
  }

  MorphTabsEdges _edgesFor({
    required double slotLeft,
    required double slotWidth,
    required double contentLeft,
    required double contentWidth,
    required double trackWidth,
  }) {
    final MorphTabIndicatorSpec spec = _spec;
    double left;
    double right;
    if (spec.fit == MorphTabsIndicatorFit.tab) {
      final double inset = spec.isSurface ? spec.surfaceInset : spec.tabInset;
      left = slotLeft + inset;
      right = slotLeft + slotWidth - inset;
      if (right < left) {
        left = right = slotLeft + slotWidth / 2;
      }
    } else if (spec.isSurface) {
      left = contentLeft - spec.padding;
      right = contentLeft + contentWidth + spec.padding;
    } else {
      final double width = math.max(
        spec.minLength,
        contentWidth - spec.contentInset * 2,
      );
      left = contentLeft + (contentWidth - width) / 2;
      right = left + width;
    }
    left = math.max(0, left);
    right = math.min(trackWidth, right);
    return MorphTabsEdges(left, right);
  }

  // ---------------------------------------------------------------------
  // Selection policy for list changes.

  bool _allIds(List<MorphTab> tabs) =>
      tabs.every((MorphTab tab) => tab.id != null);

  void _checkSelectionPolicy() {
    final int n = widget.tabs.length;
    final int requested = widget.selectedIndex;
    if (requested < 0 || requested >= n) {
      if (_reportedInvalid != requested) {
        _reportedInvalid = requested;
        widget.onTabSelected(_index);
      }
      return;
    }
    _reportedInvalid = null;
    final List<MorphTab>? previous = _prevTabs;
    final int? previousSelected = _prevSelected;
    if (previous != null &&
        previousSelected != null &&
        previousSelected < previous.length &&
        requested == previousSelected &&
        _allIds(previous) &&
        _allIds(widget.tabs)) {
      final Object? id = previous[previousSelected].id;
      if (widget.tabs[requested].id != id) {
        final int moved = widget.tabs.indexWhere((MorphTab t) => t.id == id);
        if (moved >= 0) {
          _prevTabs = widget.tabs;
          _prevSelected = requested;
          widget.onTabSelected(moved);
          return;
        }
      }
    }
    _prevTabs = widget.tabs;
    _prevSelected = requested;
  }

  // ---------------------------------------------------------------------
  // Scrolling bar.

  /// Brings the slot of [index] into the bar viewport without touching any
  /// other scrollable and without fighting a manual scroll.
  void _revealIndex(int index, {bool animate = true}) {
    if (!_scroll.hasClients || _userScrolling) {
      return;
    }
    if (index < 0 || index >= _slotKeys.length) {
      return;
    }
    final RenderObject? object = _slotKeys[index].currentContext
        ?.findRenderObject();
    if (object is! RenderBox || !object.attached) {
      return;
    }
    final RenderAbstractViewport? viewport = RenderAbstractViewport.maybeOf(
      object,
    );
    final ScrollPosition position = _scroll.position;
    if (viewport == null || position.maxScrollExtent <= 0) {
      return;
    }
    final double a = viewport.getOffsetToReveal(object, 0).offset;
    final double b = viewport.getOffsetToReveal(object, 1).offset;
    final double low = math.min(a, b);
    final double high = math.max(a, b);
    if (position.pixels >= low - 0.5 && position.pixels <= high + 0.5) {
      return;
    }
    final double target = viewport
        .getOffsetToReveal(object, 0.5)
        .offset
        .clamp(position.minScrollExtent, position.maxScrollExtent)
        .toDouble();
    final Duration duration = MorphMotion.durationOf(
      context,
      MorphMotion.short4,
    );
    if (!animate || duration == Duration.zero) {
      position.jumpTo(target);
      return;
    }
    position.animateTo(target, duration: duration, curve: MorphMotion.enter);
  }

  bool _onScrollNotification(ScrollNotification notification) {
    if (notification.depth != 0) {
      return false;
    }
    if (notification is ScrollStartNotification) {
      _userScrolling = notification.dragDetails != null;
    } else if (notification is ScrollUpdateNotification &&
        notification.dragDetails != null) {
      _userScrolling = true;
    } else if (notification is ScrollEndNotification) {
      _userScrolling = false;
    }
    return false;
  }

  // ---------------------------------------------------------------------
  // Focus and keyboard.

  void _onFocus(int index) {
    final bool any = _nodes.any((FocusNode node) => node.hasFocus);
    if (!any) {
      _inside = false;
      return;
    }
    if (_redirecting) {
      _reveal(index);
      return;
    }
    if (!_inside) {
      _inside = true;
      if (index != _index) {
        _redirecting = true;
        _nodes[_index].requestFocus();
        _redirecting = false;
        return;
      }
    }
    _reveal(index);
  }

  void _reveal(int index) {
    if (_userScrolling) {
      return;
    }
    if (widget.autoScrollToFocusedTab) {
      final BuildContext? target = _slotKeys[index].currentContext;
      if (target == null) {
        return;
      }
      Scrollable.ensureVisible(
        target,
        alignment: 0.5,
        duration: MorphMotion.durationOf(context, MorphMotion.short4),
        curve: MorphMotion.enter,
      );
      return;
    }
    // Focus moves never scroll other scrollables, but the bar itself keeps the
    // focused tab reachable.
    _revealIndex(index);
  }

  void _move(int delta) {
    final int current = _nodes.indexWhere((FocusNode node) => node.hasFocus);
    if (current < 0) {
      return;
    }
    final int next = current + delta;
    if (next < 0 || next >= _nodes.length) {
      return;
    }
    _inside = true;
    _nodes[next].requestFocus();
  }

  int _step(int towardTrailing) {
    final rtl = Directionality.of(context) == TextDirection.rtl;
    return rtl ? -towardTrailing : towardTrailing;
  }
}

/// Motion profile values read once per frame.
typedef MorphTabsMotionParams = ({
  MorphTabsIndicatorMotion motion,
  double elasticity,
});
