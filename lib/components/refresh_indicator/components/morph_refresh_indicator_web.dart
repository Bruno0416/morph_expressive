part of '../morph_refresh_indicator.dart';

/// Web-only helpers. Host (non-web) code paths must not call these.
extension _MorphRefreshIndicatorWeb on MorphRefreshIndicatorState {
  /// Same pad/position math as the host checkDragOffset. Skips the host's
  /// empty setState at the visual cap (that freezes CanvasKit).
  void _checkDragOffsetWeb() {
    assert(
      _status == MorphRefreshStatus.drag || _status == MorphRefreshStatus.armed,
      'assertion failed',
    );
    final double maxPad = _resolvedContentDragOffset(context);
    _contentPadController.value = math.min(
      math.max(0, _dragOffset ?? 0),
      maxPad,
    );

    final double reveal = _revealProgress(context);
    final double limit = MorphRefreshIndicatorTheme.kDragSizeFactorLimit;
    final double target = reveal / limit;
    if (target != _positionController.value) {
      _positionController.value = clampDouble(target, 0, 1);
    }

    if (_status == MorphRefreshStatus.drag && reveal >= 1.0) {
      _status = MorphRefreshStatus.armed;
      widget.onStatusChange?.call(_status);
    } else if (_status == MorphRefreshStatus.armed && reveal < 1.0) {
      _status = MorphRefreshStatus.drag;
      widget.onStatusChange?.call(_status);
    }
  }

  /// Enables mouse drag and clamps leading underscroll while pulling so the
  /// only list gap is our capped pad (web + native desktop).
  Widget _wrapPointerPullScrollBehavior(Widget child) {
    final ScrollBehavior behavior = ScrollConfiguration.of(context);
    return ScrollConfiguration(
      behavior: behavior.copyWith(
        dragDevices: <PointerDeviceKind>{
          ...behavior.dragDevices,
          PointerDeviceKind.mouse,
        },
        physics: _MorphPullLeadingClampScrollPhysics(
          shouldClampLeading: _shouldClampLeadingOverscrollForPull,
          parent: behavior.getScrollPhysics(context),
        ),
      ),
      child: child,
    );
  }

  bool _shouldClampLeadingOverscrollForPull() {
    return _status == MorphRefreshStatus.drag ||
        _status == MorphRefreshStatus.armed;
  }

  /// Split list pad vs indicator listenables so the pad spring during refresh
  /// does not rebuild the morph spinner every frame (CanvasKit freeze).
  Widget _buildWebTree(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        AnimatedBuilder(
          animation: _contentPadController,
          builder: (BuildContext context, Widget? _) {
            // Pad is only ever written capped in checkDragOffsetWeb / springs.
            final double maxPad = _resolvedContentDragOffset(context);
            final double pad = math.min(
              math.max(0, _contentPadController.value),
              maxPad,
            );
            return NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification n) =>
                  _handleScrollNotification(n),
              child: NotificationListener<OverscrollIndicatorNotification>(
                onNotification: (OverscrollIndicatorNotification n) =>
                    _handleIndicatorNotification(n),
                child: Padding(
                  padding: EdgeInsets.only(
                    top: (_isIndicatorAtTop ?? false) ? pad : 0,
                    bottom: _isIndicatorAtTop == false ? pad : 0,
                  ),
                  child: widget.child,
                ),
              ),
            );
          },
        ),
        // Do not listen to [_contentPadController] here — its spring during
        // [onRefresh] rebuilds the indicator every frame and freezes CanvasKit.
        AnimatedBuilder(
          animation: Listenable.merge(<Listenable>[
            _positionController,
            _scaleController,
            _bubbleController,
          ]),
          builder: (BuildContext context, Widget? _) {
            if (_status == null) {
              return const SizedBox.shrink();
            }
            return _buildPositionedIndicatorWeb(context);
          },
        ),
      ],
    );
  }

  /// Snap pad spring to 0 once visually settled so list layout stops thrashing.
  Future<void> _springContentPadToZeroWeb() async {
    void stopper() {
      if (_contentPadController.value > 0.5) {
        return;
      }
      _contentPadController.removeListener(stopper);
      if (_contentPadController.isAnimating) {
        _contentPadController.stop(canceled: false);
      }
      _contentPadController.value = 0;
    }

    _contentPadController.addListener(stopper);
    try {
      await _springTo(_contentPadController, target: 0);
    } finally {
      _contentPadController.removeListener(stopper);
      if (_contentPadController.value != 0) {
        _contentPadController.value = 0;
      }
    }
  }

  /// Done dismiss: snap scale once nearly hidden so morph stops painting.
  Future<void> _animateDismissWeb() async {
    switch (_status!) {
      case MorphRefreshStatus.done:
        void stopper() {
          if (_scaleController.value < 0.97) {
            return;
          }
          _scaleController.removeListener(stopper);
          if (_scaleController.isAnimating) {
            _scaleController.stop(canceled: false);
          }
          _scaleController.value = 1;
          if (_contentPadController.isAnimating) {
            _contentPadController.stop(canceled: false);
          }
          _contentPadController.value = 0;
        }

        _scaleController.addListener(stopper);
        try {
          await Future.wait(<Future<void>>[
            _springTo(_scaleController, target: 1),
            _springTo(_contentPadController, target: 0),
          ]);
        } finally {
          _scaleController.removeListener(stopper);
        }
      case MorphRefreshStatus.canceled:
        await Future.wait(<Future<void>>[
          _springTo(_contentPadController, target: 0),
          _springTo(_positionController, target: 0),
        ]);
      case MorphRefreshStatus.armed:
      case MorphRefreshStatus.drag:
      case MorphRefreshStatus.refresh:
      case MorphRefreshStatus.snap:
        assert(false, 'assertion failed');
    }
  }

  /// Web indicator: host Opacity + scale reveal; contained loading spinner
  /// with host elevation (cached in RepaintBoundary).
  Widget _buildPositionedIndicatorWeb(BuildContext context) {
    final bool atTop = _isIndicatorAtTop!;
    final bool showIndeterminate =
        _status == MorphRefreshStatus.refresh ||
        _status == MorphRefreshStatus.done;
    final double reveal = _revealProgress(context);
    final double inset = _indicatorInset(context);
    final double bubble = switch (_status) {
      MorphRefreshStatus.refresh ||
      MorphRefreshStatus.snap => _bubbleController.value,
      _ => 1.0,
    };
    final bool dragDriven = switch (_status) {
      MorphRefreshStatus.drag ||
      MorphRefreshStatus.armed ||
      MorphRefreshStatus.canceled => true,
      _ => false,
    };

    return Positioned(
      top: atTop ? widget.edgeOffset + inset : null,
      bottom: atTop ? null : widget.edgeOffset + inset,
      left: 0,
      right: 0,
      child: IgnorePointer(
        child: Align(
          alignment: atTop ? Alignment.topCenter : Alignment.bottomCenter,
          child: Opacity(
            opacity: reveal.clamp(0.0, 1.0),
            child: Transform.scale(
              scale: reveal * bubble,
              alignment: atTop ? Alignment.topCenter : Alignment.bottomCenter,
              child: _buildWebIndicatorChild(
                context,
                showIndeterminate,
                dragDriven,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWebIndicatorChild(
    BuildContext context,
    bool showIndeterminate,
    bool dragDriven,
  ) {
    if (!_usesContainedLoadingIndicator) {
      _clearWebSpinnerCache();
      return _buildIndicator(context, showIndeterminate);
    }

    final _WebSpinnerPhase phase = dragDriven
        ? _WebSpinnerPhase.drag
        : _WebSpinnerPhase.refresh;
    final Widget cached;
    final Widget? existing = _webSpinnerCache;
    if (existing == null ||
        _webSpinnerPhase != phase ||
        _webSpinnerType != widget._indicatorType) {
      _webSpinnerPhase = phase;
      _webSpinnerType = widget._indicatorType;
      cached = RepaintBoundary(
        child: _buildContainedLoadingIndicator(
          key: ValueKey<String>(
            dragDriven
                ? 'morph_refresh_web_drag_spinner'
                : 'morph_refresh_web_refresh_spinner',
          ),
          freezeMorph: dragDriven,
        ),
      );
      _webSpinnerCache = cached;
    } else {
      cached = existing;
    }
    final spinner = !dragDriven
        ? cached
        : Transform.rotate(
            angle: math.max(0, _dragOffset ?? 0) / 80 * 2 * math.pi,
            child: cached,
          );
    // Keep the expensive morph cached, but update the cheap ring with pull
    // progress rather than freezing it at the cache's creation value.
    return _withRefreshRing(spinner);
  }

  bool get _usesContainedLoadingIndicator => switch (widget._indicatorType) {
    _IndicatorType.expressive || _IndicatorType.contained => true,
    _ => false,
  };

  void _clearWebSpinnerCache() {
    _webSpinnerCache = null;
    _webSpinnerPhase = _WebSpinnerPhase.none;
    _webSpinnerType = null;
  }
}

/// Blocks new leading underscroll while pulling so list gap is only our pad.
///
/// Only rejects movement from a valid position into underscroll. Does not run
/// when pixels are already past min (that caused AlwaysScrollable ballistic
/// "invalid overscroll" asserts).
class _MorphPullLeadingClampScrollPhysics extends ScrollPhysics {
  const _MorphPullLeadingClampScrollPhysics({
    required this.shouldClampLeading,
    super.parent,
  });

  final bool Function() shouldClampLeading;

  @override
  _MorphPullLeadingClampScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return _MorphPullLeadingClampScrollPhysics(
      shouldClampLeading: shouldClampLeading,
      parent: buildParent(ancestor),
    );
  }

  @override
  double applyBoundaryConditions(ScrollMetrics position, double value) {
    if (shouldClampLeading() &&
        position.pixels >= position.minScrollExtent &&
        value < position.minScrollExtent) {
      return value - position.minScrollExtent;
    }
    return super.applyBoundaryConditions(position, value);
  }
}
