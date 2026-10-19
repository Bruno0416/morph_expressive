part of '../morph_icon_buttons.dart';

extension _MorphIconButtonBuild on _MorphIconButtonState {
  Widget _buildContent(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) =>
          _buildConstrainedContent(context, constraints),
    );
  }

  Widget _buildConstrainedContent(
    BuildContext context,
    BoxConstraints constraints,
  ) {
    final theme = MorphTheme.of(context);
    final iconButtonTheme = theme.iconButtonTheme;
    final scheme = theme.colorScheme;
    final ({Size visual, Size target}) sizes = _resolveLayoutSizes(
      iconButtonTheme,
      constraints,
    );
    final selected = widget.isSelected ?? false;
    // Toggle colors/shape only when [isSelected] is set (default vs toggle).
    final isToggle = widget.isSelected != null;
    final outlineW = iconButtonTheme.outlineWidthFor(widget.size);
    final ({Color bg, Color fg, BorderSide? side}) colors = _resolveColors(
      scheme,
      selected: selected,
      isToggle: isToggle,
      outlineWidth: outlineW,
    );
    final iconSize = iconButtonTheme.iconSize(widget.size);
    final iconTheme = IconThemeData(size: iconSize, color: colors.fg);
    final Widget themedIcon = IconTheme.merge(
      data: iconTheme,
      child: widget.icon,
    );
    final Widget? themedSelectedIcon = widget.selectedIcon == null
        ? null
        : IconTheme.merge(data: iconTheme, child: widget.selectedIcon!);
    Widget paintedButton = SizedBox(
      width: sizes.visual.width,
      height: sizes.visual.height,
      child: _wrapWithBadge(
        theme,
        scheme,
        _buildMorphingFace(
          iconButtonTheme: iconButtonTheme,
          visual: sizes.visual,
          colors: colors,
          isToggle: isToggle,
          selected: selected,
          iconSize: iconSize,
          icon: themedIcon,
          selectedIcon: themedSelectedIcon,
        ),
      ),
    );
    paintedButton = _wrapPointerTracking(paintedButton);
    final layout = widget.inflateHitTarget ? sizes.target : sizes.visual;
    Widget result = Semantics(
      button: true,
      selected: selected,
      label: widget.semanticLabel ?? widget.tooltip,
      child: SizedBox(
        width: layout.width,
        height: layout.height,
        child: Center(child: paintedButton),
      ),
    );
    final String? tooltip = widget.tooltip;
    if (tooltip != null) {
      result = MorphTooltip(
        message: tooltip,
        dismissDelay: Duration.zero,
        child: result,
      );
    }
    return result;
  }

  ({Size visual, Size target}) _resolveLayoutSizes(
    MorphIconButtonTheme iconButtonTheme,
    BoxConstraints constraints,
  ) {
    final Size themeVisual = iconButtonTheme.visual(widget.size, widget.width);
    final Size themeTarget = iconButtonTheme.target(widget.size, widget.width);
    var visual = widget.visualSize ?? themeVisual;
    // Fill the allocated slot when the parent drives width (connected equal
    // flex or standard neighbor-squish). Do not use unbounded max sizes from
    // loose parents (e.g. centered scaffolding).
    final bool fillWidth =
        constraints.hasBoundedWidth &&
        (widget.matchParentConstraints ||
            widget.isGroupConnected ||
            constraints.maxWidth < visual.width);
    final bool fillHeight =
        constraints.hasBoundedHeight &&
        (widget.matchParentConstraints ||
            widget.isGroupConnected ||
            constraints.maxHeight < visual.height);
    if (fillWidth) {
      visual = Size(math.max(0, constraints.maxWidth), visual.height);
    }
    if (fillHeight) {
      visual = Size(visual.width, math.max(0, constraints.maxHeight));
    }
    return (
      visual: visual,
      target: Size(
        math.max(themeTarget.width, visual.width),
        math.max(themeTarget.height, visual.height),
      ),
    );
  }

  Widget _buildMorphingFace({
    required MorphIconButtonTheme iconButtonTheme,
    required Size visual,
    required ({Color bg, Color fg, BorderSide? side}) colors,
    required bool isToggle,
    required bool selected,
    required double iconSize,
    required Widget icon,
    required Widget? selectedIcon,
  }) {
    return ListenableBuilder(
      listenable: Listenable.merge(<Listenable>[
        _isPointerDownNotifier,
        _isHoveredNotifier,
        _isPressedNotifier,
        _showFocusRingNotifier,
      ]),
      builder: (BuildContext context, Widget? child) {
        final bool pressed =
            widget.onPressed != null &&
            (_isPointerDownNotifier.value || _isPressedNotifier.value);
        final morphStates = <WidgetState>{
          if (pressed) WidgetState.pressed,
          if (_isHoveredNotifier.value) WidgetState.hovered,
        };
        return _buildMorphButton(
          visual: visual,
          colors: colors,
          targetRadius: widget.isGroupConnected
              ? _connectedRadius(
                  visual: visual,
                  selected: selected,
                  pressed: pressed,
                )
              : BorderRadius.circular(
                  MorphIconButtonShapes.effectiveRadius(
                    theme: iconButtonTheme,
                    size: widget.size,
                    baseVariant: widget.shape,
                    isToggle: isToggle,
                    isSelected: selected,
                    states: morphStates,
                  ),
                ),
          iconSize: iconSize,
          icon: icon,
          selectedIcon: selectedIcon,
          morphStates: morphStates,
          showFocusRing: _showFocusRingNotifier.value,
        );
      },
    );
  }

  BorderRadius _connectedRadius({
    required Size visual,
    required bool selected,
    required bool pressed,
  }) {
    final groupTheme = MorphTheme.of(context).buttonGroupTheme;
    final buttonSize = switch (widget.size) {
      MorphIconButtonSize.xs => MorphButtonSize.xs,
      MorphIconButtonSize.sm => MorphButtonSize.sm,
      MorphIconButtonSize.md => MorphButtonSize.md,
      MorphIconButtonSize.lg => MorphButtonSize.lg,
      MorphIconButtonSize.xl => MorphButtonSize.xl,
    };
    if (selected) {
      return BorderRadius.circular(
        groupTheme.connectedSelectedInnerRadiusFor(visual.height),
      );
    }
    final outer = widget.shape == MorphIconButtonShapeVariant.round
        ? visual.height / 2
        : groupTheme.connectedOuterSquareRadiusFor(buttonSize);
    final inner = pressed
        ? groupTheme.connectedPressedInnerRadiusFor(buttonSize)
        : groupTheme.connectedInnerRadiusFor(buttonSize);
    return BorderRadiusDirectional.horizontal(
      start: Radius.circular(widget.isFirstInGroup ? outer : inner),
      end: Radius.circular(widget.isLastInGroup ? outer : inner),
    ).resolve(Directionality.of(context));
  }

  Widget _wrapPointerTracking(Widget child) {
    if (widget.onPressed == null) {
      return child;
    }
    return TapRegion(
      onTapOutside: _onTapOutside,
      child: Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: _onPointerDown,
        onPointerUp: _onPointerUp,
        onPointerCancel: _onPointerCancel,
        child: child,
      ),
    );
  }

  void _onTapOutside(PointerDownEvent _) {
    MorphFocusInteraction.instance.notePointerInteraction();
    if (_focusNode.hasPrimaryFocus) {
      _focusNode.unfocus();
    }
  }

  void _onPointerDown(PointerDownEvent _) {
    MorphFocusInteraction.instance.notePointerInteraction();
    _setPointerDown(true);
  }

  void _onPointerUp(PointerUpEvent _) {
    _setPointerDown(false);
  }

  void _onPointerCancel(PointerCancelEvent _) {
    _setPointerDown(false);
  }

  ({Color bg, Color fg, BorderSide? side}) _resolveColors(
    MorphColorScheme scheme, {
    required bool selected,
    required bool isToggle,
    required double outlineWidth,
  }) {
    final ({Color bg, Color fg, BorderSide? side}) defaults = _variantColors(
      scheme,
      selected: selected,
      isToggle: isToggle,
      outlineWidth: outlineWidth,
    );
    final dec = widget.decoration;
    final disabled = widget.onPressed == null;
    final states = <WidgetState>{
      if (disabled) WidgetState.disabled,
      if (selected) WidgetState.selected,
    };
    final useFgGradient = dec?.foregroundGradient != null;
    final paintInnerOutline = dec?.outlineGradient != null || dec?.side != null;

    var bg = dec?.backgroundColor?.resolve(states) ?? defaults.bg;
    var fg = useFgGradient
        ? morphGradientForegroundSourceColor
        : (dec?.foregroundColor?.resolve(states) ?? defaults.fg);
    var side = paintInnerOutline
        ? null
        : (dec?.side?.resolve(states) ?? defaults.side);

    if (disabled) {
      final onSurface = scheme.onSurface;
      final isTransparent =
          widget.variant == MorphIconButtonVariant.standard ||
          (widget.variant == MorphIconButtonVariant.outlined &&
              !(isToggle && selected));
      bg = isTransparent
          ? Colors.transparent
          : onSurface.withValues(
              alpha: MorphIconButtonTheme.disabledContainerAlpha,
            );
      if (!useFgGradient) {
        fg = onSurface.withValues(
          alpha: MorphIconButtonTheme.disabledForegroundAlpha,
        );
      }
      if (side != null && !paintInnerOutline) {
        side = BorderSide(
          color: onSurface.withValues(
            alpha: MorphIconButtonTheme.disabledContainerAlpha,
          ),
          width: side.width,
        );
      }
    }

    return (bg: bg, fg: fg, side: side);
  }

  ({Color bg, Color fg, BorderSide? side}) _variantColors(
    MorphColorScheme scheme, {
    required bool selected,
    required bool isToggle,
    required double outlineWidth,
  }) {
    switch (widget.variant) {
      case MorphIconButtonVariant.standard:
        return (
          bg: Colors.transparent,
          fg: (isToggle && selected) ? scheme.primary : scheme.onSurfaceVariant,
          side: null,
        );
      case MorphIconButtonVariant.filled:
        return _filledColors(scheme, isToggle: isToggle, selected: selected);
      case MorphIconButtonVariant.tonal:
        return _tonalColors(scheme, isToggle: isToggle, selected: selected);
      case MorphIconButtonVariant.outlined:
        return _outlinedColors(
          scheme,
          isToggle: isToggle,
          selected: selected,
          outlineWidth: outlineWidth,
        );
    }
  }

  ({Color bg, Color fg, BorderSide? side}) _filledColors(
    MorphColorScheme scheme, {
    required bool isToggle,
    required bool selected,
  }) {
    if (isToggle && !selected) {
      return (
        bg: scheme.surfaceContainer,
        fg: scheme.onSurfaceVariant,
        side: null,
      );
    }
    return (bg: scheme.primary, fg: scheme.onPrimary, side: null);
  }

  ({Color bg, Color fg, BorderSide? side}) _tonalColors(
    MorphColorScheme scheme, {
    required bool isToggle,
    required bool selected,
  }) {
    if (isToggle && selected) {
      return (bg: scheme.secondary, fg: scheme.onSecondary, side: null);
    }
    return (
      bg: scheme.secondaryContainer,
      fg: scheme.onSecondaryContainer,
      side: null,
    );
  }

  ({Color bg, Color fg, BorderSide? side}) _outlinedColors(
    MorphColorScheme scheme, {
    required bool isToggle,
    required bool selected,
    required double outlineWidth,
  }) {
    if (isToggle && selected) {
      return (
        bg: scheme.inverseSurface,
        fg: scheme.onInverseSurface,
        side: null,
      );
    }
    return (
      bg: Colors.transparent,
      fg: scheme.onSurfaceVariant,
      side: BorderSide(color: scheme.outlineVariant, width: outlineWidth),
    );
  }

  Widget _buildMorphButton({
    required Size visual,
    required ({Color bg, Color fg, BorderSide? side}) colors,
    required BorderRadius targetRadius,
    required double iconSize,
    required Widget icon,
    required Widget? selectedIcon,
    required Set<WidgetState> morphStates,
    required bool showFocusRing,
  }) {
    final morphSpring = MorphTheme.of(context).iconButtonTheme.morphSpring;
    return MorphRadiusAndPaddingMotion(
      motion: MorphMotion.springMotion(morphSpring),
      internalLeft: 0,
      internalRight: 0,
      internalTop: 0,
      internalBottom: 0,
      targetRadius: targetRadius,
      pressed: morphStates.contains(WidgetState.pressed),
      snapToTarget: MediaQuery.maybeDisableAnimationsOf(context) ?? false,
      builder: (padding, animatedRadius) {
        final dec = widget.decoration;
        final fill =
            dec?.backgroundGradient?.resolve(morphStates) ??
            _themeGradientForVariant(MorphTheme.of(context).iconButtonTheme);
        final useGradient = fill != null;
        final gradientOverlay = morphUsesGradientOverlay(dec?.overlayGradient);
        var displayIcon = icon;
        var displaySelectedIcon = selectedIcon;
        final fgGradient = dec?.foregroundGradient?.resolve(morphStates);
        if (fgGradient != null) {
          displayIcon = morphGradientForegroundLayer(
            clipRadius: animatedRadius,
            gradient: fgGradient,
            child: displayIcon,
          );
          if (displaySelectedIcon != null) {
            displaySelectedIcon = morphGradientForegroundLayer(
              clipRadius: animatedRadius,
              gradient: fgGradient,
              child: displaySelectedIcon,
            );
          }
        }
        return MorphFocusRing(
          focused: showFocusRing,
          radius: animatedRadius,
          child: MorphInkSplashTheme(
            color: colors.fg,
            child: IconButton(
              focusNode: _focusNode,
              autofocus: widget.autofocus,
              onPressed: widget.onPressed == null
                  ? null
                  : () {
                      if (widget.enableFeedback != false) {
                        MorphHaptics.triggerFor(context, widget.haptic);
                      }
                      widget.onPressed!();
                    },
              isSelected: widget.isSelected,
              iconSize: iconSize,
              selectedIcon: displaySelectedIcon,
              icon: displayIcon,
              enableFeedback: false,
              statesController: _statesController,
              style: _morphButtonStyle(
                visual: visual,
                colors: colors,
                animatedRadius: animatedRadius,
                iconSize: iconSize,
                fill: fill,
                useGradient: useGradient,
                gradientOverlay: gradientOverlay,
              ),
            ),
          ),
        );
      },
    );
  }

  ButtonStyle _morphButtonStyle({
    required Size visual,
    required ({Color bg, Color fg, BorderSide? side}) colors,
    required BorderRadius animatedRadius,
    required double iconSize,
    required Gradient? fill,
    required bool useGradient,
    required bool gradientOverlay,
  }) {
    final dec = widget.decoration;
    final outlineFallback = MorphTheme.of(context).iconButtonTheme
        .outlineWidthFor(widget.size);
    return ButtonStyle(
      fixedSize: WidgetStateProperty.all(visual),
      padding: WidgetStateProperty.all(EdgeInsets.zero),
      iconSize: WidgetStateProperty.all(iconSize),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(borderRadius: animatedRadius),
      ),
      backgroundColor: WidgetStateProperty.all(
        useGradient ? Colors.transparent : colors.bg,
      ),
      backgroundBuilder: morphGradientSurfaceBuilder(
        clipRadius: animatedRadius,
        backgroundGradient: fill == null
            ? null
            : WidgetStatePropertyAll<Gradient?>(fill),
        overlayGradient: dec?.overlayGradient,
        outlineGradient: dec?.outlineGradient,
        outlineSide: dec?.side,
        outlineFallbackWidth: outlineFallback,
      ),
      foregroundColor: WidgetStateProperty.resolveWith((_) => colors.fg),
      side: WidgetStateProperty.resolveWith((_) => colors.side),
      splashFactory: widget.suppressInk || gradientOverlay
          ? NoSplash.splashFactory
          : InkSparkle.splashFactory,
      overlayColor: widget.suppressInk || gradientOverlay
          ? WidgetStateProperty.all(Colors.transparent)
          : (dec?.overlayColor ??
                WidgetStateProperty.resolveWith((Set<WidgetState> states) {
                  if (states.contains(WidgetState.disabled)) {
                    return null;
                  }
                  // Keyboard focus uses the outset ring only.
                  final overlayStates = Set<WidgetState>.of(states)
                    ..remove(WidgetState.focused);
                  return MorphStateLayer.resolveOverlayColor(
                    colors.fg,
                    overlayStates,
                  );
                })),
      mouseCursor: WidgetStateProperty.resolveWith((Set<WidgetState> states) {
        if (states.contains(WidgetState.disabled) || widget.onPressed == null) {
          return SystemMouseCursors.basic;
        }
        return SystemMouseCursors.click;
      }),
      animationDuration: Duration.zero,
      visualDensity: VisualDensity.standard,
    );
  }

  Gradient? _themeGradientForVariant(MorphIconButtonTheme theme) {
    return switch (widget.variant) {
      MorphIconButtonVariant.filled => theme.filledBackgroundGradient,
      MorphIconButtonVariant.tonal => theme.tonalBackgroundGradient,
      MorphIconButtonVariant.standard ||
      MorphIconButtonVariant.outlined => null,
    };
  }

  Widget _wrapWithBadge(
    MorphThemeData theme,
    MorphColorScheme scheme,
    Widget button,
  ) {
    final Widget? badge = _buildBadge(theme, scheme);
    if (badge == null) {
      return button;
    }
    return Stack(
      clipBehavior: Clip.none,
      children: [
        button,
        PositionedDirectional(top: 0, end: 0, child: badge),
      ],
    );
  }

  Widget? _buildBadge(MorphThemeData theme, MorphColorScheme scheme) {
    final Object? v = widget.badgeValue;
    if (v == null) {
      return null;
    }
    if (v is num) {
      final int c = v.round().clamp(0, 999999);
      if (c == 0) {
        return Badge(
          smallSize: 8,
          backgroundColor: scheme.primary,
          textColor: scheme.onPrimary,
        );
      }
      return Badge.count(
        count: c,
        backgroundColor: scheme.primary,
        textColor: scheme.onPrimary,
      );
    }
    if (v is String) {
      if (v.isEmpty) {
        return null;
      }
      return Badge(
        label: Text(
          v,
          style: theme.typeScale.labelSmall.copyWith(color: scheme.onPrimary),
        ),
        backgroundColor: scheme.primary,
        textColor: scheme.onPrimary,
      );
    }
    assert(() {
      throw FlutterError(
        "MorphIconButton.badgeValue must be a String or num, but got '${v.runtimeType}'.",
      );
    }(), 'badgeValue must be String or num');
    return null;
  }
}
