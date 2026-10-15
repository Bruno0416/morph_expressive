// Derived from Material 3 Expressive by Paa Developments (MIT), modified
// in 2026 for Morph Expressive (naming, layout, styling and/or motion).
// Follows Material 3 Compose design/reference patterns; direct inclusion
// of Android Open Source Project Apache-2.0 code is not established here.
// See NOTICE for original copyright and third-party attribution.

// ignore_for_file: invalid_use_of_protected_member
// helpers del estado original; se revisaran durante la migracion de motion

part of '../morph_sliders.dart';

/// Drag/tap callbacks for an [MorphSlider] gesture layer.
class _MorphSliderGestures {
  const _MorphSliderGestures({
    this.onHorizontalDragStart,
    this.onHorizontalDragUpdate,
    this.onHorizontalDragEnd,
    this.onHorizontalDragCancel,
    this.onVerticalDragStart,
    this.onVerticalDragUpdate,
    this.onVerticalDragEnd,
    this.onVerticalDragCancel,
    this.onTapDown,
    this.onTapUp,
    this.onTapCancel,
  });

  final GestureDragStartCallback? onHorizontalDragStart;
  final GestureDragUpdateCallback? onHorizontalDragUpdate;
  final GestureDragEndCallback? onHorizontalDragEnd;
  final GestureDragCancelCallback? onHorizontalDragCancel;
  final GestureDragStartCallback? onVerticalDragStart;
  final GestureDragUpdateCallback? onVerticalDragUpdate;
  final GestureDragEndCallback? onVerticalDragEnd;
  final GestureDragCancelCallback? onVerticalDragCancel;
  final GestureTapDownCallback? onTapDown;
  final GestureTapUpCallback? onTapUp;
  final GestureTapCancelCallback? onTapCancel;
}

/// Resolved theme values for [MorphSlider] layout.
class _MorphSliderResolved {
  const _MorphSliderResolved({
    required this.sliderTheme,
    required this.colors,
    required this.direction,
    required this.reverse,
    required this.handleThickness,
    required this.indicatorLabel,
    required this.wavelength,
    required this.waveSpeed,
    required this.amplitudeFactor,
    required this.trackThickness,
    required this.cornerRadius,
    required this.thumbLength,
    required this.dotSize,
    required this.dotSpacing,
    required this.tickSize,
    required this.useCustomDots,
  });

  final MorphSliderTheme sliderTheme;
  final MorphSliderColors colors;
  final TextDirection direction;
  final bool reverse;
  final double handleThickness;
  final String indicatorLabel;
  final double wavelength;
  final double waveSpeed;
  final double amplitudeFactor;
  final double trackThickness;
  final double cornerRadius;
  final double thumbLength;
  final double dotSize;
  final double dotSpacing;
  final double tickSize;
  final bool useCustomDots;
}

extension on _MorphSliderState {
  _MorphSliderResolved _resolve(BuildContext context) {
    final MorphThemeData theme = MorphTheme.of(context);
    final MorphSliderTheme sliderTheme = theme.sliderTheme.applyingSize(
      widget.size,
    );
    final MorphSliderColors colors = sliderTheme.colors(
      theme.colorScheme,
      enabled: _enabled,
    );
    final TextDirection direction = Directionality.of(context);
    final bool rtl = !_vertical && direction == TextDirection.rtl;
    final bool reverse = _vertical ? !widget.topToBottom : rtl;
    final double handleThickness = _pressed || _showFocusOutline
        ? sliderTheme.focusHandleWidth
        : (_vertical
              ? MorphSliderTokens.verticalHandleHeight
              : sliderTheme.handleWidth);
    final String indicatorLabel =
        widget.label ??
        (widget.divisions != null
            ? widget.value.round().toString()
            : widget.value.toStringAsFixed(2));
    final double wavelength = widget.wavelength ?? sliderTheme.wavelength;
    final double waveSpeed = widget.waveSpeed ?? wavelength;
    return _MorphSliderResolved(
      sliderTheme: sliderTheme,
      colors: colors,
      direction: direction,
      reverse: reverse,
      handleThickness: handleThickness,
      indicatorLabel: indicatorLabel,
      wavelength: wavelength,
      waveSpeed: waveSpeed,
      amplitudeFactor: _amplitudeFactor(sliderTheme),
      trackThickness: widget.trackThickness ?? sliderTheme.trackHeight,
      cornerRadius: widget.cornerRadius ?? sliderTheme.trackCornerRadius,
      thumbLength: widget.thumbLength ?? sliderTheme.handleHeight,
      dotSize: widget.dotSize ?? sliderTheme.stopIndicatorSize,
      dotSpacing: widget.dotSpacing ?? sliderTheme.stopIndicatorTrailingSpace,
      tickSize: sliderTheme.tickSize,
      useCustomDots: widget.dotBuilder != null,
    );
  }

  Widget _buildLayout(
    BuildContext context,
    BoxConstraints constraints,
    _MorphSliderResolved resolved,
  ) {
    final double extent = _vertical
        ? constraints.maxHeight
        : constraints.maxWidth;
    final double cross = _vertical
        ? (constraints.maxWidth.isFinite
              ? constraints.maxWidth
              : math.max(resolved.sliderTheme.height, resolved.thumbLength))
        : math.max(resolved.sliderTheme.height, resolved.thumbLength);

    Widget trackLayer = _buildTrackLayer(context, resolved);
    if (_vertical && resolved.reverse) {
      trackLayer = Transform.flip(flipY: true, child: trackLayer);
    }

    final Widget thumb = _buildThumb(context, resolved);
    final double thumbPrimary = resolved.reverse
        ? (1.0 - _fraction) * extent
        : _fraction * extent;

    return _buildGestureStack(
      context: context,
      extent: extent,
      cross: cross,
      trackLayer: trackLayer,
      thumb: thumb,
      thumbPrimary: thumbPrimary,
      resolved: resolved,
    );
  }

  Widget _buildTrackLayer(BuildContext context, _MorphSliderResolved resolved) {
    Widget buildTrack({required double phase}) {
      return widget.trackBuilder?.call(
            context: context,
            colors: resolved.colors,
            theme: resolved.sliderTheme,
            fraction: _fraction,
            tickFractions: _ticks,
            handleThickness: resolved.handleThickness,
          ) ??
          _defaultTrack(resolved, phase: phase);
    }

    Widget track = widget.wavy
        ? AnimatedBuilder(
            animation: _waveController,
            builder: (BuildContext context, Widget? child) {
              return buildTrack(
                phase: _phase(resolved.wavelength, resolved.waveSpeed),
              );
            },
          )
        : buildTrack(phase: 0);

    if (widget.trackIcons != null && widget.trackIcons!.hasAny) {
      track = _TrackIconsOverlay(
        icons: widget.trackIcons!,
        fraction: _fraction,
        trackKind: widget.trackKind,
        axis: widget.axis,
        child: track,
      );
    }

    // Relocating track icon replaces end stop markers.
    if (!resolved.useCustomDots || widget.icon != null) {
      return track;
    }
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        track,
        MorphSliderDotOverlay(
          builder: widget.dotBuilder!,
          mode: MorphSliderPaintMode.single,
          trackKind: widget.trackKind,
          activeStartFraction: 0,
          activeEndFraction: _fraction,
          tickFractions: _ticks,
          colors: resolved.colors,
          trackHeight: resolved.trackThickness,
          handleGap: resolved.sliderTheme.handleGap,
          handleThickness: resolved.handleThickness,
          stopIndicatorSize: resolved.dotSize,
          tickSize: resolved.tickSize,
          edgeInset: resolved.dotSpacing,
          axis: widget.axis,
          textDirection: resolved.direction,
        ),
      ],
    );
  }

  Widget _defaultTrack(_MorphSliderResolved resolved, {required double phase}) {
    if (widget.trackKind == MorphSliderTrackKind.centered) {
      return MorphSliderCenteredTrack(
        fraction: _fraction,
        tickFractions: _ticks,
        colors: resolved.colors,
        theme: resolved.sliderTheme,
        axis: widget.axis,
        textDirection: resolved.direction,
        handleThickness: resolved.handleThickness,
        trackHeight: resolved.trackThickness,
        cornerRadius: resolved.cornerRadius,
        stopIndicatorSize: resolved.dotSize,
        tickSize: resolved.tickSize,
        edgeInset: resolved.dotSpacing,
        drawDots: !resolved.useCustomDots && widget.icon == null,
        isWavy: widget.wavy,
        waveAmplitude: resolved.sliderTheme.waveAmplitude,
        wavelength: resolved.wavelength,
        phase: phase,
        amplitudeFactor: resolved.amplitudeFactor,
      );
    }
    return MorphSliderTrack(
      fraction: _fraction,
      tickFractions: _ticks,
      colors: resolved.colors,
      theme: resolved.sliderTheme,
      axis: widget.axis,
      textDirection: resolved.direction,
      handleThickness: resolved.handleThickness,
      trackHeight: resolved.trackThickness,
      cornerRadius: resolved.cornerRadius,
      stopIndicatorSize: resolved.dotSize,
      tickSize: resolved.tickSize,
      edgeInset: resolved.dotSpacing,
      drawDots: !resolved.useCustomDots && widget.icon == null,
      isWavy: widget.wavy,
      waveAmplitude: resolved.sliderTheme.waveAmplitude,
      wavelength: resolved.wavelength,
      phase: phase,
      amplitudeFactor: resolved.amplitudeFactor,
    );
  }

  Widget _buildThumb(BuildContext context, _MorphSliderResolved resolved) {
    return widget.thumbBuilder?.call(
          context: context,
          colors: resolved.colors,
          pressed: _pressed,
        ) ??
        MorphSliderThumb(
          color: resolved.colors.thumb,
          pressed: _pressed,
          focused: _showFocusOutline,
          hovered: _hovered,
          axis: widget.axis,
          width: _vertical
              ? resolved.thumbLength
              : resolved.sliderTheme.handleWidth,
          height: _vertical
              ? MorphSliderTokens.verticalHandleHeight
              : resolved.thumbLength,
          pressedThickness: resolved.sliderTheme.focusHandleWidth,
        );
  }

  Widget _buildGestureStack({
    required BuildContext context,
    required double extent,
    required double cross,
    required Widget trackLayer,
    required Widget thumb,
    required double thumbPrimary,
    required _MorphSliderResolved resolved,
  }) {
    final gestures = _gestureCallbacks(extent, resolved.reverse);
    final Widget gestureDetector = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onHorizontalDragStart: gestures.onHorizontalDragStart,
      onHorizontalDragUpdate: gestures.onHorizontalDragUpdate,
      onHorizontalDragEnd: gestures.onHorizontalDragEnd,
      onHorizontalDragCancel: gestures.onHorizontalDragCancel,
      onVerticalDragStart: gestures.onVerticalDragStart,
      onVerticalDragUpdate: gestures.onVerticalDragUpdate,
      onVerticalDragEnd: gestures.onVerticalDragEnd,
      onVerticalDragCancel: gestures.onVerticalDragCancel,
      onTapDown: gestures.onTapDown,
      onTapUp: gestures.onTapUp,
      onTapCancel: gestures.onTapCancel,
      child: _buildStackBody(
        context: context,
        extent: extent,
        cross: cross,
        trackLayer: trackLayer,
        thumb: thumb,
        thumbPrimary: thumbPrimary,
        resolved: resolved,
      ),
    );
    return TapRegion(
      onTapOutside: MorphFocus.tapOutsideHandler(_focusNode),
      child: Focus(
        focusNode: _focusNode,
        autofocus: widget.autofocus,
        canRequestFocus: _enabled,
        onKeyEvent: _handleKeyEvent,
        child: MouseRegion(
          cursor: _enabled
              ? SystemMouseCursors.click
              : SystemMouseCursors.basic,
          onEnter: (_) => _setHovered(true),
          onExit: (_) => _setHovered(false),
          child: gestureDetector,
        ),
      ),
    );
  }

  _MorphSliderGestures _gestureCallbacks(double extent, bool reverse) {
    if (!_enabled) {
      return const _MorphSliderGestures();
    }
    if (_vertical) {
      return _verticalGestures(extent, reverse);
    }
    return _horizontalGestures(extent, reverse);
  }

  _MorphSliderGestures _verticalGestures(double extent, bool reverse) {
    return _MorphSliderGestures(
      onVerticalDragStart: _pressStart,
      onVerticalDragUpdate: _verticalDragUpdate(extent, reverse),
      onVerticalDragEnd: _dragEnd,
      onVerticalDragCancel: _endInteraction,
      onTapDown: _tapDown(extent, reverse),
      onTapUp: _tapUp,
      onTapCancel: _endInteraction,
    );
  }

  _MorphSliderGestures _horizontalGestures(double extent, bool reverse) {
    return _MorphSliderGestures(
      onHorizontalDragStart: _pressStart,
      onHorizontalDragUpdate: _horizontalDragUpdate(extent, reverse),
      onHorizontalDragEnd: _dragEnd,
      onHorizontalDragCancel: _endInteraction,
      onTapDown: _tapDown(extent, reverse),
      onTapUp: _tapUp,
      onTapCancel: _endInteraction,
    );
  }

  void _setHovered(bool value) {
    if (_hovered == value || !mounted) {
      return;
    }
    setState(() => _hovered = value);
  }

  void _pressStart(DragStartDetails details) {
    _requestPointerFocus();
    _dragging = true;
    setState(() => _pressed = true);
  }

  void _requestPointerFocus() {
    _isFocusedFromPointer = true;
    MorphFocusInteraction.instance.notePointerInteraction();
    _focusNode.requestFocus();
  }

  void _dragEnd(DragEndDetails details) {
    _endInteraction();
  }

  void _tapUp(TapUpDetails details) {
    _endInteraction();
  }

  GestureDragUpdateCallback _verticalDragUpdate(double extent, bool reverse) {
    return (DragUpdateDetails d) {
      _update(d.localPosition.dy, extent, reverse);
    };
  }

  GestureDragUpdateCallback _horizontalDragUpdate(double extent, bool reverse) {
    return (DragUpdateDetails d) {
      _update(d.localPosition.dx, extent, reverse);
    };
  }

  GestureTapDownCallback _tapDown(double extent, bool reverse) {
    return (TapDownDetails d) {
      _onTapDown(d, extent, reverse);
    };
  }

  void _onTapDown(TapDownDetails d, double extent, bool reverse) {
    _requestPointerFocus();
    _dragging = true;
    setState(() => _pressed = true);
    final double primary = _vertical ? d.localPosition.dy : d.localPosition.dx;
    _update(primary, extent, reverse);
  }

  Widget _buildStackBody({
    required BuildContext context,
    required double extent,
    required double cross,
    required Widget trackLayer,
    required Widget thumb,
    required double thumbPrimary,
    required _MorphSliderResolved resolved,
  }) {
    final Widget? iconOverlay = _buildRelocatingIcon(
      context: context,
      extent: extent,
      cross: cross,
      thumbPrimary: thumbPrimary,
      resolved: resolved,
    );
    return SizedBox(
      width: _vertical ? cross : extent,
      height: _vertical ? extent : cross,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: <Widget>[
          Positioned.fill(child: trackLayer),
          Positioned(
            left: _vertical ? null : thumbPrimary - 12,
            top: _vertical ? thumbPrimary - 12 : null,
            width: _vertical ? cross : 24,
            height: _vertical ? 24 : cross,
            child: Center(child: thumb),
          ),
          ?iconOverlay,
          if (_pressed || _showFocusOutline)
            Positioned(
              left: _vertical
                  ? cross / 2 + resolved.thumbLength / 2 + 8
                  : thumbPrimary - MorphSliderValueIndicator.widthFor(
                      context, resolved.indicatorLabel, resolved.sliderTheme,
                    ) / 2,
              bottom: _vertical
                  ? null
                  : cross / 2 +
                        resolved.thumbLength / 2 +
                        resolved.sliderTheme.valueIndicatorBottomSpace,
              top: _vertical
                  ? thumbPrimary - resolved.sliderTheme.valueIndicatorHeight / 2
                  : null,
              child: MorphSliderValueIndicator(
                label: resolved.indicatorLabel,
                colors: resolved.colors,
              ),
            ),
        ],
      ),
    );
  }

  /// Icon that rests at [MorphSlider.iconPosition] and springs to the other side
  /// of the thumb when that resting spot no longer fits. Standard track only.
  Widget? _buildRelocatingIcon({
    required BuildContext context,
    required double extent,
    required double cross,
    required double thumbPrimary,
    required _MorphSliderResolved resolved,
  }) {
    if (widget.icon == null ||
        widget.trackKind != MorphSliderTrackKind.standard) {
      return null;
    }
    final double iconSize = widget.iconSize ?? resolved.sliderTheme.iconSize;
    final double iconHalf = iconSize / 2;
    final double edgeInset =
        widget.iconEdgeInset ?? resolved.sliderTheme.iconEdgeInset;
    final double thumbHalf = resolved.handleThickness / 2;
    final bool reverse = resolved.reverse;
    final restAtEnd =
        (widget.iconPosition == MorphSliderIconPosition.end) != reverse;
    final double restingCenter = restAtEnd
        ? extent - edgeInset - iconHalf
        : edgeInset + iconHalf;

    final double dockDistanceLimit = thumbHalf + iconHalf + 8;
    final bool isDocked =
        (thumbPrimary - restingCenter).abs() <= dockDistanceLimit;
    _updateIconDock(isDocked);

    final double dockOffset = thumbHalf + iconHalf + 12;
    final double dockedTarget = restAtEnd
        ? thumbPrimary - dockOffset
        : thumbPrimary + dockOffset;
    final double iconCenter = lerpDouble(
      restingCenter,
      dockedTarget,
      _dockController.value,
    )!.clamp(iconHalf, extent - iconHalf);
    final bool overActive = reverse
        ? iconCenter >= thumbPrimary
        : iconCenter <= thumbPrimary;

    final MorphThemeData theme = MorphTheme.of(context);
    final Color iconColor = !_enabled
        ? MorphColorUtils.withOpacity(
            theme.colorScheme.onSurface,
            resolved.sliderTheme.disabledActiveOpacity,
          )
        : overActive
        ? theme.colorScheme.onPrimary
        : theme.colorScheme.onSecondaryContainer;

    return Positioned(
      left: _vertical ? (cross - iconSize) / 2 : iconCenter - iconHalf,
      top: _vertical ? iconCenter - iconHalf : (cross - iconSize) / 2,
      width: iconSize,
      height: iconSize,
      child: IconTheme.merge(
        data: IconThemeData(size: iconSize, color: iconColor),
        child: widget.icon!,
      ),
    );
  }

  void _updateIconDock(bool isDocked) {
    if (isDocked == _iconDocked) {
      return;
    }
    _iconDocked = isDocked;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || isDocked != _iconDocked) {
        return;
      }
      final spring = MorphTheme.of(context).sliderTheme.dockSpring;
      _dockController
        ..motion = MorphMotion.springMotion(spring)
        ..animateTo(isDocked ? 1.0 : 0.0);
    });
  }
}
