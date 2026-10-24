part of '../morph_refresh_indicator.dart';

/// Indicator geometry and spinner builders for [MorphRefreshIndicatorState].
extension _MorphRefreshIndicatorBuild on MorphRefreshIndicatorState {
  /// Resting top inset / max downward travel of the spinner.
  double _maxVisualPull(BuildContext context) {
    if (widget.displacement > 0) {
      return widget.displacement;
    }
    return widget.indicatorPadding;
  }

  /// Current list pad (capped), used for reveal delay timing.
  double _currentPad(BuildContext context) {
    switch (_status) {
      case MorphRefreshStatus.drag:
      case MorphRefreshStatus.armed:
        return math.min(
          math.max(0, _dragOffset ?? 0.0),
          _resolvedContentDragOffset(context),
        );
      case MorphRefreshStatus.snap:
      case MorphRefreshStatus.refresh:
      case MorphRefreshStatus.done:
      case MorphRefreshStatus.canceled:
        return math.max(0, _contentPadController.value);
      case null:
        return 0;
    }
  }

  /// 0–1 progress after the pad passes twice the indicator padding.
  ///
  /// At 1 the spinner is fully scaled/faded and at its resting displacement.
  double _revealProgress(BuildContext context) {
    switch (_status) {
      case MorphRefreshStatus.refresh:
      case MorphRefreshStatus.snap:
        return 1;
      case MorphRefreshStatus.done:
        return _scaleFactor.value.clamp(0.0, 1.0);
      case MorphRefreshStatus.drag:
      case MorphRefreshStatus.armed:
      case MorphRefreshStatus.canceled:
        final double pad = _currentPad(context);
        final double delay = _revealDelayPx;
        final double maxPad = _resolvedContentDragOffset(context);
        final double extent = math.max(0, maxPad - delay);
        if (extent <= 0) {
          return pad > 0 ? 1.0 : 0.0;
        }
        return ((pad - delay) / extent).clamp(0.0, 1.0);
      case null:
        return 0;
    }
  }

  bool _isFullyRevealed(BuildContext context) =>
      _revealProgress(context) >= 1.0;

  /// Drag-driven spinner turns while pulling; auto spin once loading starts.
  double? _dragRotationTurns(BuildContext context) {
    switch (_status) {
      case MorphRefreshStatus.drag:
      case MorphRefreshStatus.armed:
        return math.max(0, _dragOffset ?? 0) / 80;
      case MorphRefreshStatus.snap:
      case MorphRefreshStatus.refresh:
      case MorphRefreshStatus.done:
      case MorphRefreshStatus.canceled:
      case null:
        return null;
    }
  }

  /// Indicator top inset: tracks reveal up to resting displacement, then locked.
  double _indicatorInset(BuildContext context) {
    switch (_status) {
      case MorphRefreshStatus.refresh:
      case MorphRefreshStatus.snap:
      case MorphRefreshStatus.done:
        return _restingInset ?? _maxVisualPull(context);
      case MorphRefreshStatus.drag:
      case MorphRefreshStatus.armed:
      case MorphRefreshStatus.canceled:
        return _revealProgress(context) * _maxVisualPull(context);
      case null:
        return 0;
    }
  }

  Widget _buildPositionedIndicator(BuildContext context) {
    if (kIsWeb) {
      return _buildPositionedIndicatorWeb(context);
    }

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
              child: _buildIndicator(context, showIndeterminate),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIndicator(BuildContext context, bool showIndeterminate) {
    switch (widget._indicatorType) {
      case _IndicatorType.expressive:
      case _IndicatorType.contained:
        return _withRefreshRing(_buildContainedLoadingIndicator());
      case _IndicatorType.material:
        return _buildMaterialIndicator(context, showIndeterminate);
      case _IndicatorType.adaptive:
        return _buildAdaptiveIndicator(context, showIndeterminate);
      case _IndicatorType.noSpinner:
        return const SizedBox.shrink();
    }
  }

  /// Displays pull progress around the filled expressive spinner. On refresh
  /// the ring becomes indeterminate; at completion it becomes a full ring.
  Widget _withRefreshRing(Widget indicator) {
    final loading = MorphTheme.of(context).loadingIndicatorTheme;
    final maxWidth = widget.indicatorConstraints?.maxWidth;
    final maxHeight = widget.indicatorConstraints?.maxHeight;
    final outer = math.max(
      maxWidth != null && maxWidth.isFinite ? maxWidth : loading.containerWidth,
      maxHeight != null && maxHeight.isFinite
          ? maxHeight
          : loading.containerHeight,
    );
    final size = outer + 12;
    final refreshing =
        _status == MorphRefreshStatus.refresh ||
        _status == MorphRefreshStatus.snap;
    final progress = refreshing
        ? null
        : (_status == MorphRefreshStatus.done ? 1.0 : _revealProgress(context));
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          MorphProgressIndicator.circular(
            value: progress,
            size: size,
            strokeWidth: 2.5,
            trackStrokeWidth: 2,
            color: _effectiveValueColor,
            trackColor: _effectiveValueColor.withValues(alpha: 0.16),
          ),
          indicator,
        ],
      ),
    );
  }

  /// Contained loading spinner for expressive and contained refresh kinds.
  Widget _buildContainedLoadingIndicator({Key? key, bool freezeMorph = false}) {
    final theme = MorphTheme.of(context);
    final indicator = MorphLoadingIndicator(
      key: key,
      variant: MorphLoadingIndicatorVariant.contained,
      color: _effectiveValueColor,
      containerColor: _effectiveContainerColor,
      polygons: widget.polygons,
      constraints: widget.indicatorConstraints,
      semanticLabel: widget.semanticsLabel,
      semanticValue: widget.semanticsValue,
      rotationTurns: freezeMorph ? 0 : _dragRotationTurns(context),
    );
    if (widget.elevation <= 0) {
      return indicator;
    }
    return DecoratedBox(
      decoration: ShapeDecoration(
        shape: theme.loadingIndicatorTheme.containerShape,
        shadows: MorphElevation.shadows(
          widget.elevation,
          shadowColor: theme.colorScheme.shadow,
        ),
      ),
      child: indicator,
    );
  }

  Widget _buildMaterialIndicator(BuildContext context, bool showIndeterminate) {
    return RefreshProgressIndicator(
      semanticsLabel:
          widget.semanticsLabel ??
          MaterialLocalizations.of(context).refreshIndicatorSemanticLabel,
      semanticsValue: widget.semanticsValue,
      value: showIndeterminate ? null : _value.value,
      valueColor: _valueColor,
      backgroundColor: widget.backgroundColor,
      strokeWidth: widget.strokeWidth,
      elevation: widget.elevation,
    );
  }

  Widget _buildAdaptiveIndicator(BuildContext context, bool showIndeterminate) {
    switch (MorphTheme.platformOf(context)) {
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        return _buildMaterialIndicator(context, showIndeterminate);
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return CupertinoActivityIndicator(color: widget.color);
    }
  }
}
