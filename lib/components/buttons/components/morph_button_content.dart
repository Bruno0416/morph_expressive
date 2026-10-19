// ignore_for_file: invalid_use_of_protected_member
// helpers del estado original; se revisaran durante la migracion de motion

// Button build / core widget assembly for function_length.
part of '../morph_buttons.dart';

extension _MorphButtonContent on _MorphButtonState {
  Widget _buildContent(BuildContext context) {
    final m = _measurements;
    final baseInternalPadding = EdgeInsets.symmetric(
      horizontal: _usesSelection && !_hasSelectionLabel
          ? m.hPadding / 2
          : m.hPadding,
    );
    final shapes = _usesSelection
        ? _resolveSelectionShapes(m)
        : _resolveShapes(m);
    final baseStyle = _buildBaseStyle();

    return wrapWithPointerPressTracking(
      enabled: widget.enabled && widget.onPressed != null,
      child: buildAnimatedContent(
        builder:
            (
              context, {
              required isPressed,
              required isHovered,
              required isFocused,
            }) {
              return _buildAnimatedCore(
                m: m,
                baseStyle: baseStyle,
                baseInternalPadding: baseInternalPadding,
                shapes: shapes,
                isPressed: isPressed,
                isHovered: isHovered,
                isFocused: isFocused,
              );
            },
      ),
    );
  }

  ({
    BorderRadius defaultShape,
    BorderRadius pressedShape,
    BorderRadius hoveredShape,
    bool freezeLeft,
    bool freezeRight,
  })
  _resolveShapes(MorphButtonMeasurements m) {
    final fullyRound = BorderRadius.circular(m.height / 2);
    final explicitBorderRadius = _decoration?.borderRadius;
    final tokenPressed = _buttonTheme.pressedRadius(widget.size);
    final defaultShape = explicitBorderRadius != null
        ? BorderRadius.circular(explicitBorderRadius)
        : widget.shape == MorphButtonShape.round
        ? fullyRound
        : BorderRadius.circular(_buttonTheme.squareRadius(widget.size));

    final explicitPressed = _decoration?.pressedRadius;
    final pressedShape = explicitPressed != null
        ? BorderRadius.circular(explicitPressed)
        : explicitBorderRadius != null
        ? BorderRadius.circular(explicitBorderRadius)
        : BorderRadius.circular(tokenPressed);

    // Spec: hover keeps resting shape; only press morphs unless overridden.
    final explicitHovered = _decoration?.hoveredRadius;
    final hoveredShape = explicitHovered != null
        ? BorderRadius.circular(explicitHovered)
        : defaultShape;

    return (
      defaultShape: defaultShape,
      pressedShape: pressedShape,
      hoveredShape: hoveredShape,
      freezeLeft: false,
      freezeRight: false,
    );
  }

  BorderRadius _targetShape({
    required bool effectivelyEnabled,
    required bool isPressed,
    required bool isHovered,
    required ({
      BorderRadius defaultShape,
      BorderRadius pressedShape,
      BorderRadius hoveredShape,
      bool freezeLeft,
      bool freezeRight,
    })
    shapes,
  }) {
    if (effectivelyEnabled && isPressed) {
      return shapes.pressedShape;
    }
    if (effectivelyEnabled && isHovered) {
      return shapes.hoveredShape;
    }
    return shapes.defaultShape;
  }

  Widget _buildAnimatedCore({
    required MorphButtonMeasurements m,
    required ButtonStyle baseStyle,
    required EdgeInsets baseInternalPadding,
    required ({
      BorderRadius defaultShape,
      BorderRadius pressedShape,
      BorderRadius hoveredShape,
      bool freezeLeft,
      bool freezeRight,
    })
    shapes,
    required bool isPressed,
    required bool isHovered,
    required bool isFocused,
  }) {
    final effectivelyEnabled = widget.enabled && widget.onPressed != null;
    final targetRadius = _targetShape(
      effectivelyEnabled: effectivelyEnabled,
      isPressed: isPressed,
      isHovered: isHovered,
      shapes: shapes,
    );

    Widget core = RepaintBoundary(
      child: MorphRadiusAndPaddingMotion(
        motion: springMotion,
        internalLeft: baseInternalPadding.left,
        internalRight: baseInternalPadding.right,
        internalTop: baseInternalPadding.top,
        internalBottom: baseInternalPadding.bottom,
        targetRadius: targetRadius,
        pressed: isPressed,
        snapToTarget: MediaQuery.maybeDisableAnimationsOf(context) ?? false,
        freezeTopLeft: widget.isGroupConnected && shapes.freezeLeft,
        freezeBottomLeft: widget.isGroupConnected && shapes.freezeLeft,
        freezeTopRight: widget.isGroupConnected && shapes.freezeRight,
        freezeBottomRight: widget.isGroupConnected && shapes.freezeRight,
        builder: (animatedInternal, animatedRadius) {
          final buttonCore = _buildButtonCore(
            m,
            baseStyle,
            animatedInternal,
            animatedRadius,
          );
          return MorphFocusRing(
            focused: isFocused,
            radius: animatedRadius,
            child: buttonCore,
          );
        },
      ),
    );

    final dec = _decoration;
    final hasDecorationSize =
        dec?.fixedSize != null ||
        dec?.minimumSize != null ||
        dec?.maximumSize != null;
    final fixedWidth = hasDecorationSize ? null : widget.size.width;
    if (fixedWidth != null) {
      core = SizedBox(width: fixedWidth, child: core);
    }
    return core;
  }

  Widget _buildButtonCore(
    MorphButtonMeasurements m,
    ButtonStyle baseStyle,
    EdgeInsets internalPadding,
    BorderRadius animatedRadius,
  ) {
    Widget child = _usesSelection
        ? _buildSelectionContent(m)
        : widget.icon != null && widget.label != null
        ? _MorphButtonIconLayout(
            icon: widget.icon!,
            label: widget.label!,
            size: widget.size,
            iconAlignment: _decoration?.iconAlignment ?? IconAlignment.start,
          )
        : widget.child ??
              widget.label ??
              widget.icon ??
              const SizedBox.shrink();
    if (widget.semanticLabel != null) {
      child = ExcludeSemantics(child: child);
    }

    final style = baseStyle.copyWith(
      padding: _decoration?.padding != null
          ? WidgetStateProperty.all<EdgeInsetsGeometry>(_decoration!.padding!)
          : WidgetStateProperty.all<EdgeInsetsGeometry>(internalPadding),
      shape: WidgetStateProperty.all<OutlinedBorder>(
        RoundedRectangleBorder(borderRadius: animatedRadius),
      ),
      backgroundBuilder: _withStateLayer(
        animatedRadius,
        morphGradientSurfaceBuilder(
          clipRadius: animatedRadius,
          backgroundGradient: _decoration?.backgroundGradient,
          overlayGradient: _decoration?.overlayGradient,
          outlineGradient: _decoration?.outlineGradient,
          outlineSide: _decoration?.side,
          explicitBuilder: _decoration?.backgroundBuilder,
        ),
      ),
      foregroundBuilder: morphGradientForegroundBuilder(
        clipRadius: animatedRadius,
        gradient: _decoration?.foregroundGradient,
        explicitBuilder: _decoration?.foregroundBuilder,
      ),
    );

    final button = _createMaterialButton(
      style: style,
      onPressed: _effectiveOnPressed,
      onLongPress: widget.enabled && widget.onLongPress != null
          ? () {
              if (widget.enableFeedback) {
                MorphHaptics.triggerFor(
                  context,
                  _decoration?.haptic ?? MorphHapticFeedback.inherit,
                );
              }
              widget.onLongPress?.call();
            }
          : null,
      child: child,
    );

    return _wrapButtonChrome(button);
  }

  VoidCallback? get _effectiveOnPressed {
    if (!widget.enabled || widget.onPressed == null) {
      return null;
    }
    return () {
      if (widget.enableFeedback) {
        MorphHaptics.triggerFor(
          context,
          _decoration?.haptic ?? MorphHapticFeedback.inherit,
        );
      }
      // Pointer taps hide rings in the press listener. Take focus here so the
      // next Tab continues from this button without painting a ring.
      effectiveFocusNode.requestFocus();
      widget.onPressed?.call();
    };
  }

  Widget _createMaterialButton({
    required ButtonStyle style,
    required VoidCallback? onPressed,
    required VoidCallback? onLongPress,
    required Widget child,
  }) {
    switch (widget.style) {
      case MorphButtonStyle.filled:
        return FilledButton(
          style: style,
          onPressed: onPressed,
          onLongPress: onLongPress,
          onHover: widget.onHover,
          statesController: statesController,
          focusNode: effectiveFocusNode,
          autofocus: widget.autofocus,
          onFocusChange: widget.onFocusChange,
          child: child,
        );
      case MorphButtonStyle.tonal:
        return FilledButton.tonal(
          style: style,
          onPressed: onPressed,
          onLongPress: onLongPress,
          onHover: widget.onHover,
          statesController: statesController,
          focusNode: effectiveFocusNode,
          autofocus: widget.autofocus,
          onFocusChange: widget.onFocusChange,
          child: child,
        );
      case MorphButtonStyle.elevated:
        return ElevatedButton(
          style: style,
          onPressed: onPressed,
          onLongPress: onLongPress,
          onHover: widget.onHover,
          statesController: statesController,
          focusNode: effectiveFocusNode,
          autofocus: widget.autofocus,
          onFocusChange: widget.onFocusChange,
          child: child,
        );
      case MorphButtonStyle.outlined:
        return OutlinedButton(
          style: style,
          onPressed: onPressed,
          onLongPress: onLongPress,
          onHover: widget.onHover,
          statesController: statesController,
          focusNode: effectiveFocusNode,
          autofocus: widget.autofocus,
          onFocusChange: widget.onFocusChange,
          child: child,
        );
      case MorphButtonStyle.text:
        return TextButton(
          style: style,
          onPressed: onPressed,
          onLongPress: onLongPress,
          onHover: widget.onHover,
          statesController: statesController,
          focusNode: effectiveFocusNode,
          autofocus: widget.autofocus,
          onFocusChange: widget.onFocusChange,
          child: child,
        );
    }
  }

  Widget _wrapButtonChrome(Widget button) {
    final dec = _decoration;
    Color inkSplashColor = _selectionForegroundColor();
    if (dec?.foregroundColor != null) {
      inkSplashColor =
          dec!.foregroundColor!.resolve(
            _isSelected
                ? const <WidgetState>{WidgetState.selected}
                : const <WidgetState>{},
          ) ??
          inkSplashColor;
    }

    Widget result = MorphInkSplashTheme(color: inkSplashColor, child: button);
    if (widget.tooltip != null) {
      result = MorphTooltip(message: widget.tooltip, child: result);
    }
    if (widget.semanticLabel != null) {
      result = Semantics(label: widget.semanticLabel, child: result);
    }
    if (_usesSelection) {
      result = Semantics(selected: _isSelected, child: result);
    }
    return result;
  }
}
