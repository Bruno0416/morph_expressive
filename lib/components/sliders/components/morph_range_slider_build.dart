// Derived from Material 3 Expressive by Paa Developments (MIT), modified
// in 2026 for Morph Expressive (naming, layout, styling and/or motion).
// Follows Material 3 Compose design/reference patterns; direct inclusion
// of Android Open Source Project Apache-2.0 code is not established here.
// See NOTICE for original copyright and third-party attribution.

// ignore_for_file: invalid_use_of_protected_member
// helpers del estado original; se revisaran durante la migracion de motion

part of '../morph_range_slider.dart';

/// Resolved theme values for [MorphRangeSlider] layout.
class _MorphRangeSliderResolved {
  const _MorphRangeSliderResolved({
    required this.sliderTheme,
    required this.colors,
    required this.direction,
    required this.rtl,
    required this.handleThickness,
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
  final bool rtl;
  final double handleThickness;
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

extension on _MorphRangeSliderState {
  _MorphRangeSliderResolved _resolve(BuildContext context) {
    final MorphThemeData theme = MorphTheme.of(context);
    final MorphSliderTheme sliderTheme = theme.sliderTheme.applyingSize(
      widget.size,
    );
    final MorphSliderColors colors = sliderTheme.colors(
      theme.colorScheme,
      enabled: _enabled,
    );
    final TextDirection direction = Directionality.of(context);
    final double wavelength = widget.wavelength ?? sliderTheme.wavelength;
    return _MorphRangeSliderResolved(
      sliderTheme: sliderTheme,
      colors: colors,
      direction: direction,
      rtl: direction == TextDirection.rtl,
      handleThickness: _pressed || _showFocusOutline
          ? sliderTheme.focusHandleWidth
          : sliderTheme.handleWidth,
      wavelength: wavelength,
      waveSpeed: widget.waveSpeed ?? wavelength,
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
    _MorphRangeSliderResolved resolved,
  ) {
    final double width = constraints.maxWidth;
    final double height = math.max(
      resolved.sliderTheme.height,
      resolved.thumbLength,
    );
    final Widget track = _buildTrackLayer(resolved);
    final double startX = _thumbX(_startFraction, width, resolved.rtl);
    final double endX = _thumbX(_endFraction, width, resolved.rtl);

    final Widget stackBody = _buildStackBody(
      width: width,
      height: height,
      track: track,
      startX: startX,
      endX: endX,
      resolved: resolved,
    );
    final Widget gestureDetector = _buildGestureDetector(
      width: width,
      startX: startX,
      endX: endX,
      resolved: resolved,
      child: stackBody,
    );
    return _buildFocusRegion(gestureDetector);
  }

  Widget _buildGestureDetector({
    required double width,
    required double startX,
    required double endX,
    required _MorphRangeSliderResolved resolved,
    required Widget child,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onHorizontalDragStart: !_enabled
          ? null
          : (DragStartDetails d) =>
                _selectThumb(d.localPosition.dx, startX, endX),
      onHorizontalDragUpdate: !_enabled
          ? null
          : (DragUpdateDetails d) =>
                _update(d.localPosition.dx, width, resolved.rtl),
      onHorizontalDragEnd: !_enabled ? null : (_) => _endInteraction(),
      onHorizontalDragCancel: !_enabled ? null : _endInteraction,
      onTapDown: !_enabled
          ? null
          : (TapDownDetails d) {
              _selectThumb(d.localPosition.dx, startX, endX);
              _update(d.localPosition.dx, width, resolved.rtl);
            },
      onTapUp: !_enabled ? null : (_) => _endInteraction(),
      onTapCancel: !_enabled ? null : _endInteraction,
      child: child,
    );
  }

  Widget _buildFocusRegion(Widget gestureDetector) {
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

  void _setHovered(bool value) {
    if (_hovered == value || !mounted) {
      return;
    }
    setState(() => _hovered = value);
  }

  void _selectThumb(double dx, double startX, double endX) {
    _isFocusedFromPointer = true;
    MorphFocusInteraction.instance.notePointerInteraction();
    _focusNode.requestFocus();
    _dragging = true;
    final double distStart = (dx - startX).abs();
    final double distEnd = (dx - endX).abs();
    setState(() {
      _activeThumb = distStart <= distEnd
          ? _MorphRangeThumb.start
          : _MorphRangeThumb.end;
    });
  }

  double _thumbX(double fraction, double width, bool rtl) {
    final double f = rtl ? 1.0 - fraction : fraction;
    return f * width;
  }

  Widget _buildTrackLayer(_MorphRangeSliderResolved resolved) {
    Widget buildTrack({required double phase}) {
      return MorphRangeSliderTrack(
        startFraction: _startFraction,
        endFraction: _endFraction,
        tickFractions: _ticks,
        colors: resolved.colors,
        theme: resolved.sliderTheme,
        axis: Axis.horizontal,
        textDirection: resolved.direction,
        handleThickness: resolved.handleThickness,
        trackHeight: resolved.trackThickness,
        cornerRadius: resolved.cornerRadius,
        stopIndicatorSize: resolved.dotSize,
        tickSize: resolved.tickSize,
        edgeInset: resolved.dotSpacing,
        drawDots: !resolved.useCustomDots,
        isWavy: widget.wavy,
        waveAmplitude: resolved.sliderTheme.waveAmplitude,
        wavelength: resolved.wavelength,
        phase: phase,
        amplitudeFactor: resolved.amplitudeFactor,
      );
    }

    final Widget track = widget.wavy
        ? AnimatedBuilder(
            animation: _waveController,
            builder: (BuildContext context, Widget? child) {
              return buildTrack(
                phase: _phase(resolved.wavelength, resolved.waveSpeed),
              );
            },
          )
        : buildTrack(phase: 0);

    if (!resolved.useCustomDots) {
      return track;
    }
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        track,
        MorphSliderDotOverlay(
          builder: widget.dotBuilder!,
          mode: MorphSliderPaintMode.range,
          trackKind: MorphSliderTrackKind.standard,
          activeStartFraction: _startFraction,
          activeEndFraction: _endFraction,
          tickFractions: _ticks,
          colors: resolved.colors,
          trackHeight: resolved.trackThickness,
          handleGap: resolved.sliderTheme.handleGap,
          handleThickness: resolved.handleThickness,
          stopIndicatorSize: resolved.dotSize,
          tickSize: resolved.tickSize,
          edgeInset: resolved.dotSpacing,
          axis: Axis.horizontal,
          textDirection: resolved.direction,
        ),
      ],
    );
  }

  Widget _buildThumb({
    required bool pressed,
    required bool focused,
    required bool overlap,
    required _MorphRangeSliderResolved resolved,
  }) {
    return MorphSliderThumb(
      color: resolved.colors.thumb,
      pressed: pressed,
      focused: focused,
      hovered: _hovered,
      overlap: overlap,
      overlapColor: MorphTheme.of(context).colorScheme.onPrimary,
      width: resolved.sliderTheme.handleWidth,
      height: resolved.thumbLength,
      pressedThickness: resolved.sliderTheme.focusHandleWidth,
    );
  }

  Widget _buildStackBody({
    required double width,
    required double height,
    required Widget track,
    required double startX,
    required double endX,
    required _MorphRangeSliderResolved resolved,
  }) {
    final overlap = (endX - startX).abs() <= resolved.sliderTheme.handleWidth;
    final showValue = _pressed || _showFocusOutline;
    final valueX = _keyboardThumb == _MorphRangeThumb.start ? startX : endX;
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: <Widget>[
          Positioned.fill(child: track),
          Positioned(
            left: startX - 12,
            width: 24,
            height: height,
            child: Center(
              child: _buildThumb(
                pressed: _activeThumb == _MorphRangeThumb.start,
                focused:
                    _showFocusOutline && _keyboardThumb == _MorphRangeThumb.start,
                overlap: overlap,
                resolved: resolved,
              ),
            ),
          ),
          Positioned(
            left: endX - 12,
            width: 24,
            height: height,
            child: Center(
              child: _buildThumb(
                pressed: _activeThumb == _MorphRangeThumb.end,
                focused:
                    _showFocusOutline && _keyboardThumb == _MorphRangeThumb.end,
                overlap: overlap,
                resolved: resolved,
              ),
            ),
          ),
          if (showValue)
            Positioned(
              left: valueX - MorphSliderValueIndicator.widthFor(
                    context, _indicatorLabel(), resolved.sliderTheme,
                  ) / 2,
              bottom:
                  height / 2 +
                  resolved.thumbLength / 2 +
                  resolved.sliderTheme.valueIndicatorBottomSpace,
              child: MorphSliderValueIndicator(
                label: _indicatorLabel(),
                colors: resolved.colors,
              ),
            ),
        ],
      ),
    );
  }
}
