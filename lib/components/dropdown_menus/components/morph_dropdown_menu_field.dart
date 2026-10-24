// ignore_for_file: invalid_use_of_protected_member
// helpers del estado original; se revisaran durante la migracion de motion

part of '../morph_dropdown_menus.dart';

/// Field builders for [_MorphDropdownMenuState].
extension _MorphDropdownMenuField<T> on _MorphDropdownMenuState<T> {
  BorderRadius _buildEffectiveFieldRadius() {
    final fd = widget.fieldStyle;
    final baseRadius = _controller.isOpen && fd.selectedBorderRadius != null
        ? BorderRadius.circular(fd.selectedBorderRadius!)
        : (fd.borderRadius ??
              BorderRadius.circular(
                widget.dropdownStyle.containerRadius ?? widget.containerRadius,
              ));

    if (_isPressedField && fd.pressedRadius != null) {
      return BorderRadius.circular(fd.pressedRadius!);
    }
    if (_isHoveredField && fd.hoverRadius != null) {
      return BorderRadius.circular(fd.hoverRadius!);
    }
    return baseRadius;
  }

  Widget _buildField(
    BuildContext context,
    FormFieldState<List<MorphDropdownItem<T>>?> formState,
  ) {
    final morphTheme = MorphTheme.of(context);
    final menuTheme = morphTheme.dropdownMenuTheme;
    final scheme = morphTheme.colorScheme;
    final type = morphTheme.typeScale;
    final fd = widget.fieldStyle;

    final bgColor =
        fd.backgroundColor ?? menuTheme.fieldBackgroundColor(scheme);
    final fgColor =
        fd.foregroundColor ?? menuTheme.fieldForegroundColor(scheme);
    // Keyboard focus counts as focused even while the menu is closed.
    final isFieldFocused = _controller.isOpen || _focusRingNotifier.value;
    final borderSide =
        (formState.hasError
            ? fd.errorBorder
            : (isFieldFocused ? fd.focusedBorder : fd.border)) ??
        BorderSide.none;

    final isOpenChanged = _lastIsOpen != _controller.isOpen;
    _lastIsOpen = _controller.isOpen;

    final trailing = _buildFieldTrailing(context, fgColor);
    final content = _buildFieldContent(
      context,
      fgColor,
      menuTheme,
      type,
      scheme,
    );

    return Padding(
      padding: fd.margin,
      child: _buildFieldBody(
        fd: fd,
        bgColor: bgColor,
        fgColor: fgColor,
        borderSide: borderSide,
        isOpenChanged: isOpenChanged,
        trailing: trailing,
        content: content,
      ),
    );
  }

  Widget? _buildFieldTrailing(BuildContext context, Color fgColor) {
    final fd = widget.fieldStyle;
    final morphTheme = MorphTheme.of(context);

    if (_isLoading) {
      return fd.loadingWidget ??
          const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          );
    }
    if (fd.showClearIcon &&
        widget.enabled &&
        _controller.selectedItems.isNotEmpty) {
      return _buildClearTrailing(fgColor, morphTheme, fd);
    }
    if (fd.suffixIcon != null) {
      return _buildSuffixTrailing(fd);
    }
    if (fd.showArrow) {
      return AnimatedBuilder(
        animation: _arrowCtrl,
        builder: (context, child) {
          return Transform.rotate(
            angle: _arrowCtrl.value,
            child: Icon(MorphIcons.keyboard_arrow_down, color: fgColor),
          );
        },
      );
    }
    return null;
  }

  Widget _buildClearTrailing(
    Color fgColor,
    MorphThemeData morphTheme,
    MorphDropdownFieldStyle fd,
  ) {
    final iconSize = morphTheme.resolvedIconTheme.size ?? 18;
    final ringRadius = BorderRadius.circular(iconSize);
    return MorphTooltip(
      message: 'Clear selection',
      child: MorphTappable(
        semanticLabel: 'Clear all selections',
        onTap: () {
          MorphFocusInteraction.instance.notePointerInteraction();
          _controller.clearAll();
          _formFieldKey.currentState?.didChange(_controller.selectedItems);
        },
        builder: (BuildContext context, MorphInteractionState state) {
          return MorphFocusRing(
            focused: state.focused,
            radius: ringRadius,
            child:
                fd.clearIcon ??
                Icon(MorphIcons.close, color: fgColor, size: iconSize),
          );
        },
      ),
    );
  }

  Widget _buildSuffixTrailing(MorphDropdownFieldStyle fd) {
    if (fd.animateSuffixIcon) {
      return AnimatedRotation(
        turns: _controller.isOpen ? 0.5 : 0,
        duration: MorphMotion.durationOf(context, MorphMotion.short4),
        child: fd.suffixIcon,
      );
    }
    return fd.suffixIcon!;
  }

  Widget _buildFieldContent(
    BuildContext context,
    Color fgColor,
    MorphDropdownMenuTheme menuTheme,
    MorphTypeScale type,
    MorphColorScheme scheme,
  ) {
    final fd = widget.fieldStyle;
    final selected = _controller.selectedItems;

    // 1. mostrar seleccion unica como texto y sin etiquetas
    if (widget.singleSelect && selected.isNotEmpty) {
      if (widget.selectedItemBuilder != null) {
        return widget.selectedItemBuilder!(selected.first);
      }
      return Text(
        selected.first.label,
        style:
            fd.selectedTextStyle ??
            type.bodyLarge.copyWith(color: scheme.onSurface),
        overflow: TextOverflow.ellipsis,
      );
    }
    // 2. mantener las etiquetas para seleccion multiple
    if (!widget.singleSelect && selected.isNotEmpty) {
      if (widget.showChipAnimation) {
        return _buildChips(context, selected, fgColor);
      }
      if (widget.selectedItemBuilder != null) {
        return _buildCustomSelectedContent(context, selected, fgColor);
      }
      return _buildChips(context, selected, fgColor);
    }
    // 3. aplicar onSurfaceVariant solo al placeholder
    return Text(
      fd.hintText ?? 'Select',
      style:
          fd.hintStyle ??
          type.bodyLarge.copyWith(color: scheme.onSurfaceVariant),
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildCustomSelectedContent(
    BuildContext context,
    List<MorphDropdownItem<T>> selected,
    Color fgColor,
  ) {
    if (widget.showChipAnimation) {
      return _buildChips(context, selected, fgColor);
    }

    final children = selected
        .map((o) => widget.selectedItemBuilder!(o))
        .toList();
    if (widget.chipStyle.wrap) {
      return Wrap(
        spacing: widget.chipStyle.spacing,
        runSpacing: widget.chipStyle.runSpacing,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: children,
      );
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (int i = 0; i < children.length; i++) ...[
            children[i],
            if (i < children.length - 1)
              SizedBox(width: widget.chipStyle.spacing),
          ],
        ],
      ),
    );
  }

  Widget _buildFieldBody({
    required MorphDropdownFieldStyle fd,
    required Color bgColor,
    required Color fgColor,
    required BorderSide borderSide,
    required bool isOpenChanged,
    required Widget? trailing,
    required Widget content,
  }) {
    final contentRow = Row(
      children: [
        if (fd.prefixIcon != null) ...[
          fd.prefixIcon!,
          const SizedBox(width: 8),
        ],
        Expanded(child: content),
        if (trailing != null) ...[const SizedBox(width: 8), trailing],
      ],
    );

    final duration = isOpenChanged
        ? const Duration(milliseconds: 20)
        : const Duration(milliseconds: 40);

    return TweenAnimationBuilder<BorderRadius?>(
      duration: MorphMotion.durationOf(context, duration),
      curve: MorphMotion.enter,
      tween: BorderRadiusTween(
        begin: _buildEffectiveFieldRadius(),
        end: _buildEffectiveFieldRadius(),
      ),
      builder: (context, animatedRadius, child) {
        final radius = animatedRadius ?? _buildEffectiveFieldRadius();
        // Ring follows the field's animated radius.
        return MorphFocusRing(
          focused: _focusRingNotifier.value,
          radius: radius,
          child: _buildFieldMaterial(
            fd: fd,
            bgColor: bgColor,
            fgColor: fgColor,
            borderSide: borderSide,
            radius: radius,
            child: child!,
          ),
        );
      },
      child: contentRow,
    );
  }

  KeyEventResult _handleFieldKeyEvent(FocusNode node, KeyEvent event) {
    if (!widget.enabled || event is! KeyDownEvent) {
      return KeyEventResult.ignored;
    }
    if (event.logicalKey == LogicalKeyboardKey.escape) {
      return _handleFieldEscapeKey();
    }
    if (_isFieldActivateKey(event.logicalKey)) {
      return _handleFieldActivateKey();
    }
    return KeyEventResult.ignored;
  }

  KeyEventResult _handleFieldEscapeKey() {
    if (_controller.isOpen) {
      _close();
    } else if (_focusNode.hasPrimaryFocus) {
      _focusNode.unfocus();
    }
    return KeyEventResult.handled;
  }

  KeyEventResult _handleFieldActivateKey() {
    // Only the field shell toggles. Chips / clear own ActivateIntent when
    // they have primary focus — do not steal Enter/Space from them.
    if (!_focusNode.hasPrimaryFocus) {
      return KeyEventResult.ignored;
    }
    _toggle();
    return KeyEventResult.handled;
  }

  WidgetStateProperty<Color?> _fieldOverlayColor(Color fgColor) {
    return WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.pressed)) {
        return fgColor.withValues(alpha: 0.10);
      }
      if (states.contains(WidgetState.hovered)) {
        return fgColor.withValues(alpha: 0.05);
      }
      return Colors.transparent;
    });
  }

  void _onFieldHover(bool hover) => setState(() => _isHoveredField = hover);

  void _onFieldTapDown(TapDownDetails _) {
    MorphFocusInteraction.instance.notePointerInteraction();
    setState(() => _isPressedField = true);
  }

  void _onFieldTapUp(TapUpDetails _) {
    _focusNode.requestFocus();
    setState(() => _isPressedField = false);
  }

  void _onFieldTapCancel() => setState(() => _isPressedField = false);

  Widget _buildFieldInkWell({
    required MorphDropdownFieldStyle fd,
    required Color fgColor,
    required Widget child,
  }) {
    return InkWell(
      enableFeedback: false,
      // Field Focus above owns keyboard focus; InkWell is pointer-only.
      canRequestFocus: false,
      excludeFromSemantics: true,
      splashFactory: fd.splashFactory ?? widget.splashFactory,
      splashColor: fd.splashColor,
      highlightColor: fd.highlightColor,
      overlayColor: _fieldOverlayColor(fgColor),
      mouseCursor: widget.enabled
          ? (fd.mouseCursor ?? SystemMouseCursors.click)
          : SystemMouseCursors.forbidden,
      onTap: widget.enabled ? () => _toggle(fromPointer: true) : null,
      onHover: _onFieldHover,
      onTapDown: _onFieldTapDown,
      onTapUp: _onFieldTapUp,
      onTapCancel: _onFieldTapCancel,
      child: Padding(padding: fd.padding, child: child),
    );
  }

  Widget _buildFieldMaterial({
    required MorphDropdownFieldStyle fd,
    required Color bgColor,
    required Color fgColor,
    required BorderSide borderSide,
    required BorderRadius radius,
    required Widget child,
  }) {
    return Focus(
      focusNode: _focusNode,
      canRequestFocus: widget.enabled,
      parentNode: _portalController.isShowing ? _focusTrapScope : null,
      onKeyEvent: _handleFieldKeyEvent,
      child: Material(
        animationDuration: MorphMotion.durationOf(context, MorphMotion.short4),
        color: bgColor,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: radius, side: borderSide),
        child: _buildFieldInkWell(fd: fd, fgColor: fgColor, child: child),
      ),
    );
  }
}

bool _isFieldActivateKey(LogicalKeyboardKey key) {
  return key == LogicalKeyboardKey.enter ||
      key == LogicalKeyboardKey.numpadEnter ||
      key == LogicalKeyboardKey.space;
}
