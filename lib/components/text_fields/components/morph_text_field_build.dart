part of '../morph_text_fields.dart';

/// Layout and paint helpers for [MorphTextField].
extension _MorphTextFieldBuild on _MorphTextFieldState {
  bool get _outlined => widget.variant == MorphTextFieldVariant.outlined;

  // The filled floating label is one logical pixel larger than bodyMedium.
  // Both the per-widget style and the field theme take precedence; outlined
  // retains bodySmall without the filled-only adjustment.
  TextStyle _floatingLabelStyle(
    MorphThemeData theme,
    MorphTextFieldTheme fieldTheme,
  ) => widget.floatingLabelTextStyle ??
      fieldTheme.floatingLabelTextStyle ??
      (_outlined
          ? theme.typeScale.bodySmall
          : theme.typeScale.bodyMedium.copyWith(
              fontSize: (theme.typeScale.bodyMedium.fontSize ?? 14) + 1,
            ));

  /// Row alignment for [alignment]; [baseline] lines text up on its first line.
  static CrossAxisAlignment _crossAxisFor(
    MorphTextFieldSlotAlignment alignment, {
    bool baseline = false,
  }) {
    return switch (alignment) {
      MorphTextFieldSlotAlignment.firstLine =>
        baseline ? CrossAxisAlignment.baseline : CrossAxisAlignment.start,
      MorphTextFieldSlotAlignment.center => CrossAxisAlignment.center,
      MorphTextFieldSlotAlignment.bottom => CrossAxisAlignment.end,
    };
  }

  Widget _buildInteractive(MorphThemeData theme, MorphTextFieldTheme fieldTheme) {
    final bool enabled = widget.enabled;
    Widget field = ListenableBuilder(
      listenable: _motion,
      builder: (BuildContext context, Widget? _) {
        final Widget container = _buildContainer(theme, fieldTheme);
        if (_outlined) return container;

        // Filled labels live outside the painted surface once focused or
        // populated. Grow their reserved area using the existing label spring.
        final double floatingLine = MorphTextFieldTheme.lineHeightOf(
          _floatingLabelStyle(theme, fieldTheme),
        );
        final double topInset = widget.label == null
            ? 0
            : (floatingLine + fieldTheme.supportingTopPadding) *
                _labelMotion.value.clamp(0.0, 1.0);
        return Padding(
          padding: EdgeInsets.only(top: topInset),
          child: MorphFocusRing(
            focused: _showFocusRing,
            radius: fieldTheme.shapeAt(widget.variant, _shapeMotion.value),
            color: _toColors?.focusRing,
            width: fieldTheme.focusRingWidth,
            gap: fieldTheme.focusRingGap,
            child: container,
          ),
        );
      },
    );
    // Outlined labels float on the top edge; keep them inside the bounds.
    if (_outlined && widget.label != null) {
      final double floatingLine = MorphTextFieldTheme.lineHeightOf(
        fieldTheme.resolveFloatingLabelStyle(theme.typeScale),
      );
      field = Padding(
        padding: EdgeInsets.only(top: floatingLine / 2),
        child: field,
      );
    }
    return TextFieldTapRegion(
      enabled: enabled,
      onTapOutside:
          widget.onTapOutside ?? MorphFocus.tapOutsideHandler(_focusNode),
      child: ExcludeFocus(
        excluding: !enabled,
        child: MouseRegion(
          cursor:
              widget.mouseCursor ??
              (enabled ? SystemMouseCursors.text : SystemMouseCursors.basic),
          onEnter: (_) => _updateHover(hovered: true),
          onExit: (_) => _updateHover(hovered: false),
          child: Listener(
            behavior: HitTestBehavior.translucent,
            // Pointer input hides keyboard focus rings right away; a tap on
            // a focused field may not schedule the frame a deferred
            // notification waits for. The field tree is stable, so the
            // rebuild cannot cancel the tap.
            onPointerDown: (_) => MorphFocusInteraction.instance
                .notePointerInteraction(immediate: true),
            child: IgnorePointer(
              ignoring: !enabled,
              child: _selectionBuilder.buildGestureDetector(
                behavior: HitTestBehavior.translucent,
                child: _outlined
                    ? AnimatedBuilder(
                        animation: _shapeMotion,
                        child: field,
                        builder: (context, child) => MorphFocusRing(
                          focused: _showFocusRing,
                          radius: fieldTheme.shapeAt(
                            widget.variant,
                            _shapeMotion.value,
                          ),
                          color: _toColors?.focusRing,
                          width: fieldTheme.focusRingWidth,
                          gap: fieldTheme.focusRingGap,
                          child: child!,
                        ),
                      )
                    : field,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContainer(MorphThemeData theme, MorphTextFieldTheme fieldTheme) {
    final MorphTextFieldColors colors = _currentColors;
    final int density = _densityOf(fieldTheme);
    final double height = fieldTheme.heightFor(density);
    final List<Widget> trailing = _trailingSlots(fieldTheme, colors, height);
    final bool hasLeading = widget.leading != null || _hasPrefixErrorIcon;
    final double start = !hasLeading
        ? fieldTheme.horizontalPadding
        : fieldTheme.iconSlotWidth *
                  ((widget.leading != null ? 1 : 0) +
                      (_hasPrefixErrorIcon ? 1 : 0)) +
              fieldTheme.iconSlotTextPadding;
    final double end = trailing.isEmpty
        ? fieldTheme.horizontalPadding
        : fieldTheme.iconSlotWidth * trailing.length +
              fieldTheme.iconSlotTextPadding;
    final double progress = _labelMotion.value;
    final radius = fieldTheme.shapeAt(widget.variant, _shapeMotion.value);
    // El notch debe empezar en el tramo recto del borde superior; con
    // esquinas Morph de 24 dp no puede comenzar en x=12 como en MD3E.
    final floatingStart = _outlined
        ? (radius.topLeft.x + fieldTheme.notchPadding +
                colors.strokeWidth / 2).clamp(start, double.infinity).toDouble()
        : 0.0; // Align with the parent field column, not the input/icon slot.
    final labelStart = lerpDouble(start, floatingStart, progress)!;
    final _MorphTextFieldNotch notch =
        _notch(theme, fieldTheme, labelStart, progress);

    return CustomPaint(
      painter: MorphTextFieldContainerPainter(
        outlined: _outlined,
        shape: radius,
        containerColor: colors.container,
        stateLayerColor: colors.stateLayer,
        strokeColor: colors.stroke,
        strokeWidth: colors.strokeWidth,
        textDirection: Directionality.of(context),
        notchStart: notch.start,
        notchWidth: notch.width,
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          ConstrainedBox(
            constraints: BoxConstraints(minHeight: height),
            // Icon slots are one single-line field tall, so `start` keeps
            // them level with the first line as the field grows.
            child: Row(
              crossAxisAlignment: _crossAxisFor(
                widget.iconAlignment ?? fieldTheme.iconAlignment,
              ),
              children: <Widget>[
                ..._leadingSlot(fieldTheme, colors, height),
                Expanded(
                  child: _buildInputArea(theme, fieldTheme, colors, height),
                ),
                if (trailing.isEmpty)
                  SizedBox(width: fieldTheme.horizontalPadding)
                else ...<Widget>[
                  SizedBox(width: fieldTheme.iconSlotTextPadding),
                  ...trailing,
                ],
              ],
            ),
          ),
          if (widget.label != null)
            _buildLabel(theme, fieldTheme, colors, height, labelStart, end),
        ],
      ),
    );
  }

  Widget _buildLabel(
    MorphThemeData theme,
    MorphTextFieldTheme fieldTheme,
    MorphTextFieldColors colors,
    double height,
    double start,
    double end,
  ) {
    final TextStyle resting = fieldTheme.resolveLabelStyle(theme.typeScale);
    final TextStyle floating = _floatingLabelStyle(theme, fieldTheme);
    final double restingTop =
        (height - MorphTextFieldTheme.lineHeightOf(resting)) / 2;
    final double floatingTop = _outlined
        ? -MorphTextFieldTheme.lineHeightOf(floating) / 2
        : -(MorphTextFieldTheme.lineHeightOf(floating) +
              fieldTheme.supportingTopPadding);
    final double progress = _labelMotion.value;
    return PositionedDirectional(
      start: start,
      end: end,
      top: lerpDouble(restingTop, floatingTop, progress),
      // Tight width so the label keeps its intrinsic size.
      child: Align(
        alignment: AlignmentDirectional.topStart,
        heightFactor: 1,
        child: IgnorePointer(
          child: MorphTextFieldLabel(
            text: widget.label!,
            progress: progress,
            restingStyle: resting,
            floatingStyle: floating,
            color: colors.label,
            isRequired: widget.isRequired,
          ),
        ),
      ),
    );
  }

  /// Outlined top-edge gap; opens from its center as the label floats.
  _MorphTextFieldNotch _notch(
    MorphThemeData theme,
    MorphTextFieldTheme fieldTheme,
    double labelStart,
    double progress,
  ) {
    if (!_outlined || widget.label == null) {
      return const _MorphTextFieldNotch(0, 0);
    }
    final painter = TextPainter(
      text: TextSpan(
        text: MorphTextFieldLabel.compose(
          widget.label!,
          isRequired: widget.isRequired,
        ),
        style: fieldTheme.resolveFloatingLabelStyle(theme.typeScale),
      ),
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
      maxLines: 1,
    )..layout();
    final double full = painter.width + fieldTheme.notchPadding * 2;
    painter.dispose();
    final double width = full * progress.clamp(0, 1);
    return _MorphTextFieldNotch(
      labelStart - fieldTheme.notchPadding + (full - width) / 2,
      width,
    );
  }

  /// Both error-placement options are available in filled and outlined fields.
  /// The default is no icon at all, even when there is validation error text.
  bool get _hasErrorGlyph => widget.hasError &&
      (widget.errorIcon != null ||
          (widget.showErrorIcon && widget.trailing == null));

  bool get _hasPrefixErrorIcon => _hasErrorGlyph &&
      widget.errorIconPosition == MorphTextFieldErrorIconPosition.prefix;

  bool get _hasSuffixErrorIcon => _hasErrorGlyph &&
      widget.errorIconPosition == MorphTextFieldErrorIconPosition.suffix;

  Widget _errorGlyph(MorphTextFieldTheme fieldTheme, MorphTextFieldColors colors) {
    return Semantics(
      label: widget.errorIconSemanticsLabel,
      child: ExcludeSemantics(
        child: IconTheme.merge(
          data: IconThemeData(
            color: colors.trailingIcon,
            size: fieldTheme.iconSize,
          ),
          child: widget.errorIcon ?? const Icon(MorphIcons.error),
        ),
      ),
    );
  }

  Widget _iconSlot(Widget content, MorphTextFieldTheme theme, double height) {
    return SizedBox(
      width: theme.iconSlotWidth,
      height: height,
      child: Center(child: content),
    );
  }

  List<Widget> _leadingSlot(
    MorphTextFieldTheme fieldTheme,
    MorphTextFieldColors colors,
    double height,
  ) {
    if (widget.leading == null && !_hasPrefixErrorIcon) {
      return <Widget>[SizedBox(width: fieldTheme.horizontalPadding)];
    }
    return <Widget>[
      if (widget.leading != null)
        _iconSlot(
          IconTheme.merge(
            data: IconThemeData(
              color: colors.leadingIcon,
              size: fieldTheme.iconSize,
            ),
            child: widget.leading!,
          ),
          fieldTheme,
          height,
        ),
      if (_hasPrefixErrorIcon)
        _iconSlot(_errorGlyph(fieldTheme, colors), fieldTheme, height),
      SizedBox(width: fieldTheme.iconSlotTextPadding),
    ];
  }

  /// Clear, password toggle, then the custom trailing or error icon.
  List<Widget> _trailingSlots(
    MorphTextFieldTheme fieldTheme,
    MorphTextFieldColors colors,
    double height,
  ) {
    final bool canClear =
        widget.showClearButton &&
        _populated &&
        widget.enabled &&
        !widget.readOnly;
    final slots = <Widget>[
      if (canClear)
        _affordance(
          fieldTheme,
          colors,
          icon: MorphIcons.cancel,
          label: widget.clearButtonSemanticsLabel,
          onPressed: _clear,
        ),
      if (widget.showPasswordToggle)
        _affordance(
          fieldTheme,
          colors,
          icon: _isObscured ? MorphIcons.visibility : MorphIcons.visibility_off,
          label: _isObscured
              ? widget.showPasswordSemanticsLabel
              : widget.hidePasswordSemanticsLabel,
          onPressed: _toggleObscured,
        ),
      if (widget.trailing != null)
        IconTheme.merge(
          data: IconThemeData(
            color: colors.trailingIcon,
            size: fieldTheme.iconSize,
          ),
          child: widget.trailing!,
        ),
      // Explicit icons may coexist with a trailing action; the legacy
      // showErrorIcon fallback still yields to custom trailing content.
      if (_hasSuffixErrorIcon)
        _errorGlyph(fieldTheme, colors),
    ];
    return <Widget>[
      for (final Widget slot in slots)
        SizedBox(
          width: fieldTheme.iconSlotWidth,
          height: height,
          child: Center(child: slot),
        ),
    ];
  }

  Widget _affordance(
    MorphTextFieldTheme fieldTheme,
    MorphTextFieldColors colors, {
    required IconData icon,
    required String label,
    VoidCallback? onPressed,
  }) {
    return MorphTextFieldAffordance(
      icon: icon,
      color: colors.trailingIcon,
      iconSize: fieldTheme.iconSize,
      semanticLabel: label,
      onPressed: onPressed,
    );
  }

  Widget _buildInputArea(
    MorphThemeData theme,
    MorphTextFieldTheme fieldTheme,
    MorphTextFieldColors colors,
    double height,
  ) {
    final TextStyle input = fieldTheme
        .resolveInputStyle(theme.typeScale)
        .copyWith(color: colors.inputText);
    final double inputLine = MorphTextFieldTheme.lineHeightOf(input);
    final double centered = (height - inputLine) / 2;
    // Both variants center the editable content in the painted surface.
    // Filled's floating label is animated entirely outside that surface.
    final padding = EdgeInsets.symmetric(vertical: centered);
    return Padding(
      padding: padding,
      child: _buildInputRow(theme, fieldTheme, colors, input),
    );
  }

  Widget _buildInputRow(
    MorphThemeData theme,
    MorphTextFieldTheme fieldTheme,
    MorphTextFieldColors colors,
    TextStyle input,
  ) {
    // Prefix and suffix appear once the label has floated.
    final double affixOpacity = widget.label == null
        ? 1
        : _labelMotion.value.clamp(0, 1);
    final TextStyle affix = input.copyWith(color: colors.affix);
    final bool showPlaceholder =
        widget.placeholder != null &&
        !_populated &&
        (widget.label == null || (_focused && widget.enabled));
    return Row(
      crossAxisAlignment: _crossAxisFor(
        widget.affixAlignment ?? fieldTheme.affixAlignment,
        baseline: true,
      ),
      textBaseline: TextBaseline.alphabetic,
      children: <Widget>[
        if (widget.prefixText != null)
          _affix(
            widget.prefixText!,
            widget.prefixSemanticsLabel,
            affix,
            affixOpacity,
          ),
        Expanded(
          child: Stack(
            children: <Widget>[
              _buildEditable(theme, fieldTheme, colors, input),
              if (showPlaceholder)
                Positioned.fill(
                  child: IgnorePointer(
                    child: ExcludeSemantics(
                      child: Text(
                        widget.placeholder!,
                        style: affix,
                        textAlign: widget.textAlign,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (widget.suffixText != null)
          _affix(
            widget.suffixText!,
            widget.suffixSemanticsLabel,
            affix,
            affixOpacity,
          ),
      ],
    );
  }

  Widget _affix(
    String text,
    String? semanticsLabel,
    TextStyle style,
    double opacity,
  ) {
    return Opacity(
      opacity: opacity,
      child: Semantics(
        label: semanticsLabel ?? text,
        child: ExcludeSemantics(child: Text(text, style: style)),
      ),
    );
  }

  Widget _buildEditable(
    MorphThemeData theme,
    MorphTextFieldTheme fieldTheme,
    MorphTextFieldColors colors,
    TextStyle input,
  ) {
    final String? label = widget.label == null
        ? null
        : MorphTextFieldLabel.compose(
            widget.label!,
            isRequired: widget.isRequired,
          );
    final int? maxLength = widget.maxLength;
    return Semantics(
      label: label,
      hint: widget.errorText ?? _visibleSupportingText,
      enabled: widget.enabled,
      child: CallbackShortcuts(
        bindings: MorphFocus.editableInputShortcuts(_focusNode),
        child: EditableText(
          key: _editableKey,
          controller: _controller,
          focusNode: _focusNode,
          readOnly: widget.readOnly || !widget.enabled,
          obscureText: _isObscured,
          autofocus: widget.autofocus,
          maxLines: widget.maxLines,
          minLines: widget.minLines,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          textCapitalization: widget.textCapitalization,
          textAlign: widget.textAlign,
          inputFormatters: <TextInputFormatter>[
            ...?widget.inputFormatters,
            if (maxLength != null) LengthLimitingTextInputFormatter(maxLength),
          ],
          onSubmitted: widget.onSubmitted,
          onEditingComplete: widget.onEditingComplete,
          onTapOutside: (_) {},
          style: input,
          cursorColor: colors.caret,
          backgroundCursorColor: theme.colorScheme.outlineVariant,
          selectionColor: theme.colorScheme.primary.withValues(
            alpha: fieldTheme.selectionOpacity,
          ),
          selectionControls: morphTextFieldSelectionControls(
            defaultTargetPlatform,
          ),
          showSelectionHandles: _showSelectionHandles,
          onSelectionChanged: _handleSelectionChanged,
          onSelectionHandleTapped: _handleSelectionHandleTapped,
          contextMenuBuilder: widget.contextMenuBuilder,
          autofillClient: _autofillClient,
          rendererIgnoresPointer: true,
        ),
      ),
    );
  }

  String? get _visibleSupportingText =>
      !widget.supportingTextOnFocusOnly || _focused
      ? widget.supportingText
      : null;

  Widget _buildSupporting(MorphThemeData theme, MorphTextFieldTheme fieldTheme) {
    final int? maxLength = widget.maxLength;
    final bool counter = maxLength != null && (widget.showCounter ?? true);
    final int count = _controller.text.characters.length;
    return MorphTextFieldSupportingRow(
      style: fieldTheme.resolveSupportingStyle(theme.typeScale),
      color: _currentColors.supportingText,
      padding: EdgeInsetsDirectional.only(
        start: fieldTheme.supportingHorizontalPadding,
        top: fieldTheme.supportingTopPadding,
        end: fieldTheme.supportingHorizontalPadding,
      ),
      counterGap: fieldTheme.supportingCounterGap,
      supportingText: _visibleSupportingText,
      errorText: widget.errorText,
      counterText: counter ? '$count/$maxLength' : null,
      counterSemanticsLabel: counter
          ? widget.counterSemanticsLabelBuilder(count, maxLength)
          : null,
    );
  }
}

/// Outlined notch geometry from the leading edge.
@immutable
class _MorphTextFieldNotch {
  const _MorphTextFieldNotch(this.start, this.width);

  final double start;

  final double width;
}
