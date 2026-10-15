part of '../morph_split_buttons.dart';

/// Layout values computed once per split-button rebuild.
class _MorphSplitContentMetrics {
  const _MorphSplitContentMetrics({
    required this.dir,
    required this.size,
    required this.minTap,
    required this.gap,
    required this.pressedRadius,
    required this.cont,
    required this.onCont,
    required this.leadingHeight,
    required this.trailingHeight,
    required this.leadingCont,
    required this.leadingOnCont,
    required this.leadingOutline,
    required this.trailingCont,
    required this.trailingOnCont,
    required this.trailingOutline,
    required this.leadingRadius,
    required this.trailingRadius,
    required this.trailingFixedWidth,
    required this.trailingLeftPad,
    required this.trailingRightPad,
    required this.chevronTargetTurns,
    required this.chevronDxOffset,
    required this.leadingCustomSize,
    required this.trailingCustomSize,
    required this.leadingEnabled,
    required this.trailingEnabled,
    required this.leadingPressed,
    required this.trailingPressed,
    required this.leadingHovered,
    required this.trailingHovered,
    required this.focused,
  });

  final TextDirection dir;
  final MorphButtonSize size;
  final double minTap;
  final double gap;
  final double pressedRadius;
  final Color cont;
  final Color onCont;
  final double leadingHeight;
  final double trailingHeight;
  final Color leadingCont;
  final Color leadingOnCont;
  final BorderSide? leadingOutline;
  final Color trailingCont;
  final Color trailingOnCont;
  final BorderSide? trailingOutline;
  final _CornerRadii leadingRadius;
  final _CornerRadii trailingRadius;
  final double trailingFixedWidth;
  final double trailingLeftPad;
  final double trailingRightPad;
  final double chevronTargetTurns;
  final double chevronDxOffset;
  final MorphButtonSize? leadingCustomSize;
  final MorphButtonSize? trailingCustomSize;
  final bool leadingEnabled;
  final bool trailingEnabled;
  final bool leadingPressed;
  final bool trailingPressed;
  final bool leadingHovered;
  final bool trailingHovered;
  final bool focused;
}

/// Content layout helpers for [_MorphSplitButtonState].
extension _MorphSplitButtonContent<T> on _MorphSplitButtonState<T> {
  Widget _buildContent(
    BuildContext context,
    bool pressed,
    bool hovered,
    bool focused,
  ) {
    final metrics = _computeContentMetrics(
      context,
      pressed: pressed,
      hovered: hovered,
      focused: focused,
    );
    return _wrapSplitContent(
      context,
      metrics: metrics,
      leading: _buildLeadingFromMetrics(context, metrics),
      trailing: _buildTrailingFromMetrics(context, metrics),
    );
  }

  Widget _buildLeadingFromMetrics(
    BuildContext context,
    _MorphSplitContentMetrics m,
  ) {
    return _buildLeadingSegment(
      context: context,
      height: m.leadingHeight,
      minTap: m.minTap,
      color: m.leadingCont,
      onColor: m.leadingOnCont,
      elevation: _segmentElevation(
        hovered: m.leadingHovered,
        pressed: m.leadingPressed,
        segmentEnabled: m.leadingEnabled,
      ),
      outlineSide: m.leadingOutline,
      radius: m.leadingRadius,
      customSize: m.leadingCustomSize,
      focused: m.focused,
      hovered: m.leadingHovered,
      pressed: m.leadingPressed,
      enabled: m.leadingEnabled,
    );
  }

  Widget _buildTrailingFromMetrics(
    BuildContext context,
    _MorphSplitContentMetrics m,
  ) {
    return _buildTrailingSegment(
      context: context,
      height: m.trailingHeight,
      minTap: m.minTap,
      fixedWidth: m.trailingFixedWidth,
      color: m.trailingCont,
      onColor: m.trailingOnCont,
      elevation: _segmentElevation(
        hovered: m.trailingHovered,
        pressed: m.trailingPressed,
        segmentEnabled: m.trailingEnabled,
      ),
      outlineSide: m.trailingOutline,
      radius: m.trailingRadius,
      trailingLeftPad: m.trailingLeftPad,
      trailingRightPad: m.trailingRightPad,
      chevronTargetTurns: m.chevronTargetTurns,
      chevronDxOffset: m.chevronDxOffset,
      customSize: m.trailingCustomSize,
      focused: _isTrailingFocused,
      hovered: m.trailingHovered,
      pressed: m.trailingPressed,
      enabled: m.trailingEnabled,
    );
  }

  Widget _wrapSplitContent(
    BuildContext context, {
    required _MorphSplitContentMetrics metrics,
    required Widget leading,
    required Widget trailing,
  }) {
    final morphTheme = MorphTheme.of(context);
    final scheme = _scheme;
    final splitTheme = _splitTheme;
    final contIsTransparent = metrics.cont.a == 0.0;
    final Color menuColor =
        widget.decorationMenuBackgroundColor ??
        splitTheme.menuBackgroundColor(
          scheme,
          containerIsTransparent: contIsTransparent,
          containerColor: metrics.cont,
        );
    final Color menuTextColor =
        widget.decorationMenuForegroundColor ??
        splitTheme.menuForegroundColor(
          scheme,
          containerIsTransparent: contIsTransparent,
          onContainerColor: metrics.onCont,
        );

    return PopupMenuTheme(
      data: PopupMenuThemeData(
        color: menuColor,
        textStyle: morphTheme.typeScale.labelLarge.copyWith(color: menuTextColor),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(metrics.pressedRadius),
        ),
      ),
      child: TapRegion(
        onTapOutside: (_) {
          MorphFocusInteraction.instance.notePointerInteraction();
          if (effectiveFocusNode.hasFocus) {
            effectiveFocusNode.unfocus();
          }
          if (_trailingFocusNode.hasFocus) {
            _trailingFocusNode.unfocus();
          }
        },
        child: FocusTraversalGroup(
          policy: ReadingOrderTraversalPolicy(),
          child: IgnorePointer(
            ignoring: !widget.enabled,
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: metrics.minTap),
              child: Row(
                key: _splitGradientHostKey,
                mainAxisSize: MainAxisSize.min,
                textDirection: metrics.dir,
                children: [
                  leading,
                  SizedBox(width: metrics.gap),
                  trailing,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  _MorphSplitContentMetrics _computeContentMetrics(
    BuildContext context, {
    required bool pressed,
    required bool hovered,
    required bool focused,
  }) {
    final dir = Directionality.of(context);
    final size = widget.size;
    final leadingEnabled = widget.enabled;
    final trailingEnabled = widget.enabled;

    final (cont, onCont, _, _) = _resolveColorsAndShapes(
      context,
      segmentEnabled: widget.enabled,
    );
    final (leadingCont, leadingOnCont, leadingOutline, _) =
        _resolveColorsAndShapes(context, segmentEnabled: leadingEnabled);
    final (
      trailingCont,
      trailingOnCont,
      trailingOutline,
      _,
    ) = _resolveColorsAndShapes(
      context,
      segmentEnabled: trailingEnabled,
      trailing: true,
    );

    final geometry = _computeSegmentGeometry(
      size: size,
      dir: dir,
      pressed: pressed,
      hovered: hovered,
      focused: focused,
      leadingEnabled: leadingEnabled,
      trailingEnabled: trailingEnabled,
    );

    return _MorphSplitContentMetrics(
      dir: dir,
      size: size,
      minTap: geometry.minTap,
      gap: geometry.gap,
      pressedRadius: geometry.pressedRadius,
      cont: cont,
      onCont: onCont,
      leadingHeight: geometry.leadingHeight,
      trailingHeight: geometry.trailingHeight,
      leadingCont: leadingCont,
      leadingOnCont: leadingOnCont,
      leadingOutline: leadingOutline,
      trailingCont: trailingCont,
      trailingOnCont: trailingOnCont,
      trailingOutline: trailingOutline,
      leadingRadius: geometry.leadingRadius,
      trailingRadius: geometry.trailingRadius,
      trailingFixedWidth: geometry.trailingFixedWidth,
      trailingLeftPad: geometry.trailingLeftPad,
      trailingRightPad: geometry.trailingRightPad,
      chevronTargetTurns: geometry.chevronTargetTurns,
      chevronDxOffset: geometry.chevronDxOffset,
      leadingCustomSize: geometry.leadingCustomSize,
      trailingCustomSize: geometry.trailingCustomSize,
      leadingEnabled: leadingEnabled,
      trailingEnabled: trailingEnabled,
      leadingPressed: geometry.leadingPressed,
      trailingPressed: geometry.trailingPressed,
      leadingHovered: geometry.leadingHovered,
      trailingHovered: geometry.trailingHovered,
      focused: focused,
    );
  }

  _MorphSplitSegmentGeometry _computeSegmentGeometry({
    required MorphButtonSize size,
    required TextDirection dir,
    required bool pressed,
    required bool hovered,
    required bool focused,
    required bool leadingEnabled,
    required bool trailingEnabled,
  }) {
    final radii = _computeRadii(size: size);
    final leadingCustomSize = widget.decorationLeadingCustomSize;
    final trailingCustomSize = widget.decorationTrailingCustomSize;
    final leadingHeight =
        leadingCustomSize?.height ?? _splitTheme.splitHeight(size);
    final trailingHeight =
        trailingCustomSize?.height ?? _splitTheme.splitHeight(size);
    final minTap = _splitTheme.minTapTarget;
    final trailingSelectedRadius =
        widget.decoration?.trailingSelectedRadius ??
        radii.explicitBorderRadius ??
        trailingHeight * (_splitTheme.trailingInnerSelectedCornerPercent / 100);

    final gap =
        widget.decorationGap ??
        (widget.style == MorphButtonStyle.elevated
            ? _splitTheme.elevatedInnerGap
            : _splitTheme.innerGap);

    final leadingPressed = leadingEnabled && (pressed || _leadingPressed);
    final trailingPressed = trailingEnabled && _trailingPressed;
    final leadingHovered = leadingEnabled && hovered && !leadingPressed;
    final trailingHovered =
        trailingEnabled &&
        _isTrailingHovered &&
        !_menuOpen &&
        !_trailingPressed;

    final trailing = _computeTrailingGeometry(
      size: size,
      trailingHeight: trailingHeight,
      trailingCustomSize: trailingCustomSize,
      outerRadius: radii.outerRadius,
      innerRadius: radii.innerRadius,
      hoveredInnerRadius: radii.hoveredInnerRadius,
      pressedRadius: radii.pressedRadius,
      trailingSelectedRadius: trailingSelectedRadius,
      trailingHovered: trailingHovered,
      trailingPressed: trailingPressed,
      trailingFocused: _isTrailingFocused,
      dir: dir,
    );

    final leadingMorphHovered = (leadingHovered || focused) && !leadingPressed;

    return _MorphSplitSegmentGeometry(
      minTap: minTap,
      gap: gap,
      pressedRadius: radii.pressedRadius,
      leadingHeight: leadingHeight,
      trailingHeight: trailingHeight,
      leadingCustomSize: leadingCustomSize,
      trailingCustomSize: trailingCustomSize,
      leadingPressed: leadingPressed,
      trailingPressed: trailingPressed,
      leadingHovered: leadingHovered,
      trailingHovered: trailingHovered,
      leadingRadius: _leadingRadii(
        dir: dir,
        outer: radii.outerRadius,
        inner: radii.innerRadius,
        hovered: leadingMorphHovered ? radii.hoveredInnerRadius : null,
        pressed: leadingPressed ? radii.pressedRadius : null,
      ),
      trailingRadius: trailing.radius,
      trailingFixedWidth: trailing.fixedWidth,
      trailingLeftPad: trailing.leftPad,
      trailingRightPad: trailing.rightPad,
      chevronTargetTurns: _menuOpen ? _splitTheme.chevronOpenTurns : 0.0,
      chevronDxOffset: trailing.chevronDxOffset,
    );
  }

  _MorphSplitRadii _computeRadii({required MorphButtonSize size}) {
    final leadingCustomSize = widget.decorationLeadingCustomSize;
    final trailingCustomSize = widget.decorationTrailingCustomSize;
    final leadingHeight =
        leadingCustomSize?.height ?? _splitTheme.splitHeight(size);
    final trailingHeight =
        trailingCustomSize?.height ?? _splitTheme.splitHeight(size);
    final maxSegmentHeight = leadingHeight > trailingHeight
        ? leadingHeight
        : trailingHeight;
    final double? explicitBorderRadius = widget.decorationBorderRadius;
    final outerRadius =
        explicitBorderRadius ??
        (widget.shape == MorphButtonShape.round
            ? maxSegmentHeight / 2
            : _splitTheme.splitOuterRadiusSquare(size));
    final pressedRadius =
        widget.decoration?.pressedRadius ??
        explicitBorderRadius ??
        _splitTheme.splitPressedRadius(size);
    final innerRadius =
        explicitBorderRadius ?? _splitTheme.splitInnerCornerRadius(size);
    final hoveredInnerRadius =
        widget.decoration?.hoveredRadius ??
        explicitBorderRadius ??
        _splitTheme.splitHoveredInnerCornerRadius(size);

    return _MorphSplitRadii(
      explicitBorderRadius: explicitBorderRadius,
      outerRadius: outerRadius,
      pressedRadius: pressedRadius,
      innerRadius: innerRadius,
      hoveredInnerRadius: hoveredInnerRadius,
    );
  }

  _MorphSplitTrailingGeometry _computeTrailingGeometry({
    required MorphButtonSize size,
    required double trailingHeight,
    required MorphButtonSize? trailingCustomSize,
    required double outerRadius,
    required double innerRadius,
    required double hoveredInnerRadius,
    required double pressedRadius,
    required double trailingSelectedRadius,
    required bool trailingHovered,
    required bool trailingPressed,
    required bool trailingFocused,
    required TextDirection dir,
  }) {
    final bool allowCircle =
        size == MorphButtonSize.md ||
        size == MorphButtonSize.lg ||
        size == MorphButtonSize.xl;
    final bool circleTrailing =
        widget.decorationBorderRadius == null &&
        widget.shape == MorphButtonShape.round &&
        allowCircle &&
        _menuOpen;

    final pads = _trailingPadsAndWidth(
      size: size,
      trailingHeight: trailingHeight,
      trailingCustomSize: trailingCustomSize,
      circleTrailing: circleTrailing,
    );

    final trailingMorphHovered =
        (trailingHovered || trailingFocused) && !trailingPressed && !_menuOpen;

    final radius = circleTrailing
        ? _CornerRadii(
            topStart: trailingSelectedRadius,
            bottomStart: trailingSelectedRadius,
            topEnd: trailingSelectedRadius,
            bottomEnd: trailingSelectedRadius,
          )
        : _trailingRadii(
            dir: dir,
            outer: outerRadius,
            inner: innerRadius,
            hovered: trailingMorphHovered ? hoveredInnerRadius : null,
            pressed: trailingPressed ? pressedRadius : null,
            selected: _menuOpen ? trailingSelectedRadius : null,
          );

    final iconOffsetBase =
        (widget.trailingAlignment ==
                MorphSplitButtonTrailingAlignment.opticalCenter &&
            !_menuOpen)
        ? _splitTheme.splitMenuIconOffset(size)
        : 0.0;

    return _MorphSplitTrailingGeometry(
      fixedWidth: pads.fixedWidth,
      leftPad: pads.leftPad,
      rightPad: pads.rightPad,
      radius: radius,
      chevronDxOffset: circleTrailing ? 0.0 : iconOffsetBase,
    );
  }

  ({double fixedWidth, double leftPad, double rightPad}) _trailingPadsAndWidth({
    required MorphButtonSize size,
    required double trailingHeight,
    required MorphButtonSize? trailingCustomSize,
    required bool circleTrailing,
  }) {
    final useOptical =
        !_menuOpen &&
        widget.trailingAlignment ==
            MorphSplitButtonTrailingAlignment.opticalCenter;
    final double leadingPad = useOptical
        ? _splitTheme.splitTrailingOpticalLeading(size)
        : _splitTheme.splitTrailingButtonLeadingSpace(size);
    final double trailingPad = useOptical
        ? _splitTheme.splitTrailingOpticalTrailing(size)
        : _splitTheme.splitTrailingButtonTrailingSpace(size);
    final double openPad = _splitTheme.splitSidePaddingSelected(size);

    final trailingWidthUnselected =
        (trailingCustomSize?.hPadding ?? leadingPad) +
        (trailingCustomSize?.iconSize ??
            _splitTheme.splitTrailingIconSize(size)) +
        (trailingCustomSize?.hPadding ?? trailingPad);
    final trailingWidthSelected =
        (trailingCustomSize?.hPadding ?? openPad) * 2 +
        (trailingCustomSize?.iconSize ??
            _splitTheme.splitTrailingIconSize(size));

    final fixedWidth = circleTrailing
        ? trailingHeight
        : (trailingCustomSize?.width ??
              (_menuOpen ? trailingWidthSelected : trailingWidthUnselected));

    final leftPad = circleTrailing
        ? 0.0
        : (_menuOpen
              ? (trailingCustomSize?.hPadding ?? openPad)
              : (trailingCustomSize?.hPadding ?? leadingPad));
    final rightPad = circleTrailing
        ? 0.0
        : (_menuOpen
              ? (trailingCustomSize?.hPadding ?? openPad)
              : (trailingCustomSize?.hPadding ?? trailingPad));

    return (fixedWidth: fixedWidth, leftPad: leftPad, rightPad: rightPad);
  }
}

class _MorphSplitRadii {
  const _MorphSplitRadii({
    required this.explicitBorderRadius,
    required this.outerRadius,
    required this.pressedRadius,
    required this.innerRadius,
    required this.hoveredInnerRadius,
  });

  final double? explicitBorderRadius;
  final double outerRadius;
  final double pressedRadius;
  final double innerRadius;
  final double hoveredInnerRadius;
}

class _MorphSplitSegmentGeometry {
  const _MorphSplitSegmentGeometry({
    required this.minTap,
    required this.gap,
    required this.pressedRadius,
    required this.leadingHeight,
    required this.trailingHeight,
    required this.leadingCustomSize,
    required this.trailingCustomSize,
    required this.leadingPressed,
    required this.trailingPressed,
    required this.leadingHovered,
    required this.trailingHovered,
    required this.leadingRadius,
    required this.trailingRadius,
    required this.trailingFixedWidth,
    required this.trailingLeftPad,
    required this.trailingRightPad,
    required this.chevronTargetTurns,
    required this.chevronDxOffset,
  });

  final double minTap;
  final double gap;
  final double pressedRadius;
  final double leadingHeight;
  final double trailingHeight;
  final MorphButtonSize? leadingCustomSize;
  final MorphButtonSize? trailingCustomSize;
  final bool leadingPressed;
  final bool trailingPressed;
  final bool leadingHovered;
  final bool trailingHovered;
  final _CornerRadii leadingRadius;
  final _CornerRadii trailingRadius;
  final double trailingFixedWidth;
  final double trailingLeftPad;
  final double trailingRightPad;
  final double chevronTargetTurns;
  final double chevronDxOffset;
}

class _MorphSplitTrailingGeometry {
  const _MorphSplitTrailingGeometry({
    required this.fixedWidth,
    required this.leftPad,
    required this.rightPad,
    required this.radius,
    required this.chevronDxOffset,
  });

  final double fixedWidth;
  final double leftPad;
  final double rightPad;
  final _CornerRadii radius;
  final double chevronDxOffset;
}
