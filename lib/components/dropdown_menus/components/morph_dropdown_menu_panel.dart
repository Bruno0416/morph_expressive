part of '../morph_dropdown_menus.dart';

/// Overlay, panel, and search builders for [_MorphDropdownMenuState].
extension _MorphDropdownMenuPanel<T> on _MorphDropdownMenuState<T> {
  Widget _buildOverlay(FormFieldState<List<MorphDropdownItem<T>>?> formState) {
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.attached) {
      return const SizedBox.shrink();
    }

    final showOnTop = _resolveShowOnTop(renderBox);
    final marginOffset = widget.dropdownStyle.marginTop == 0
        ? Offset.zero
        : Offset(
            0,
            showOnTop
                ? -widget.dropdownStyle.marginTop
                : widget.dropdownStyle.marginTop,
          );

    return Stack(
      children: [
        Positioned.fill(
          child: Listener(
            behavior: HitTestBehavior.opaque,
            onPointerDown: _handleOutsideTap,
          ),
        ),
        CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          targetAnchor: showOnTop ? Alignment.topLeft : Alignment.bottomLeft,
          followerAnchor: showOnTop ? Alignment.bottomLeft : Alignment.topLeft,
          offset: marginOffset,
          child: SizedBox(
            width: renderBox.size.width,
            child: CallbackShortcuts(
              bindings: <ShortcutActivator, VoidCallback>{
                const SingleActivator(LogicalKeyboardKey.escape): _close,
              },
              child: FocusScope(
                node: _focusTrapScope,
                child: FocusTraversalGroup(
                  policy: ReadingOrderTraversalPolicy(),
                  child: RepaintBoundary(child: _buildDropdownPanel(showOnTop)),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  bool _resolveShowOnTop(RenderBox renderBox) {
    if (_openingShowOnTop != null) {
      return _openingShowOnTop!;
    }

    final renderBoxOffset = renderBox.localToGlobal(Offset.zero);
    final screenHeight = MediaQuery.of(context).size.height;
    final spaceBelow =
        screenHeight - renderBoxOffset.dy - renderBox.size.height;
    final spaceAbove = renderBoxOffset.dy;

    switch (widget.dropdownStyle.expandDirection) {
      case MorphDropdownExpandDirection.down:
        return false;
      case MorphDropdownExpandDirection.up:
        return true;
      case MorphDropdownExpandDirection.auto:
        return spaceBelow < widget.dropdownStyle.maxHeight &&
            spaceAbove > spaceBelow;
    }
  }

  bool _toggleFromInside(RenderBox renderBox, PointerDownEvent event) {
    final Offset localPosition = renderBox.globalToLocal(event.position);
    if (!renderBox.paintBounds.contains(localPosition)) {
      return false;
    }
    // The barrier is opaque, so the field does not receive this tap.
    if (_controller.isOpen) {
      _close();
    } else if (_portalController.isShowing) {
      _open();
    }
    return true;
  }

  void _handleOutsideTap(PointerDownEvent event) {
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox != null && renderBox.attached) {
      if (_toggleFromInside(renderBox, event)) {
        return;
      }
    }

    _close();
  }

  Widget _buildDropdownPanel(bool showOnTop) {
    final morphTheme = MorphTheme.of(context);
    final menuTheme = morphTheme.dropdownMenuTheme;
    final scheme = morphTheme.colorScheme;
    final type = morphTheme.typeScale;
    final dd = widget.dropdownStyle;

    return AnimatedBuilder(
      animation: _expandCtrl,
      builder: (context, child) => _wrapExpandAnimation(showOnTop, child),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: dd.maxHeight),
        child: Material(
          animationDuration: MorphMotion.durationOf(
            context,
            MorphMotion.short4,
          ),
          elevation: dd.elevation,
          color: dd.backgroundColor ?? menuTheme.panelBackgroundColor(scheme),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              widget.dropdownStyle.containerRadius ?? widget.containerRadius,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (dd.header != null) dd.header!,
              if (widget.searchEnabled) _buildSearch(context),
              _buildPanelBody(dd, scheme, type),
              if (dd.footer != null) dd.footer!,
            ],
          ),
        ),
      ),
    );
  }

  /// Expansión real del contenido, desde el borde unido al campo.
  /// No escala las letras ni refluye el layout de la página (OverlayPortal).
  Widget _wrapExpandAnimation(bool showOnTop, Widget? child) {
    final progress = _expandCtrl.value.clamp(0.0, 1.0).toDouble();
    if (progress <= 0.001) return const SizedBox.shrink();

    final reveal = MorphMotion.standard.transform(progress);
    // Entrada y salida con efectos acotados: la superficie sí se despliega
    // físicamente, a diferencia de la escala previa de 0.94 a 1.0.
    // Use the same bounded curve in both directions: the panel stays visible
    // during the first part of its collapse instead of vanishing instantly.
    final opacity = MorphMotion.enter.transform(progress).clamp(0.0, 1.0);
    return Opacity(
      opacity: opacity,
      child: ClipRect(
        child: Align(
          alignment: showOnTop ? Alignment.bottomCenter : Alignment.topCenter,
          heightFactor: reveal.clamp(0.0, 1.0),
          child: child,
        ),
      ),
    );
  }

  Widget _buildPanelBody(
    MorphDropdownPanelStyle dd,
    MorphColorScheme scheme,
    MorphTypeScale type,
  ) {
    final filtered = _controller.items;

    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_errorMessage != null) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          _errorMessage!,
          style: type.bodyMedium.copyWith(color: scheme.error),
        ),
      );
    }
    if (filtered.isEmpty) {
      return widget.emptyBuilder?.call(context) ??
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              dd.noItemsFoundText,
              style: type.bodyMedium.copyWith(color: scheme.onSurfaceVariant),
            ),
          );
    }

    return Flexible(
      child: ListView.separated(
        padding: dd.contentPadding,
        shrinkWrap: true,
        itemCount: filtered.length,
        separatorBuilder: (_, _) =>
            widget.itemSeparator ??
            SizedBox(height: widget.itemStyle.itemGap ?? 5.0),
        itemBuilder: (context, index) =>
            _buildPanelItem(filtered[index], index, filtered.length),
      ),
    );
  }

  Widget _buildPanelItem(MorphDropdownItem<T> item, int index, int total) {
    if (widget.itemBuilder != null) {
      return widget.itemBuilder!(
        item,
        selected: item.selected,
        onTap: () => _onItemTap(item),
      );
    }

    // 1. calcular el radio de la lista a partir del panel
    final panelRadius =
        widget.dropdownStyle.containerRadius ?? widget.containerRadius;
    final innerRadius = MorphDropdownGeometry.innerRadius(
      outerRadius: panelRadius,
      padding: widget.dropdownStyle.contentPadding,
      direction: Directionality.of(context),
    );

    return MorphDropdownMenuItemWidget<T>(
      key: ValueKey(item.value),
      item: item,
      index: index,
      total: total,
      style: widget.itemStyle.copyWith(
        outerRadius: widget.itemStyle.outerRadius ?? innerRadius,
      ),
      onTap: () => _onItemTap(item),
    );
  }

  Widget _buildSearch(BuildContext context) {
    final sd = widget.searchStyle;
    final morphTheme = MorphTheme.of(context);
    final scheme = morphTheme.colorScheme;
    final type = morphTheme.typeScale;
    final containerRadius =
        widget.dropdownStyle.containerRadius ?? widget.containerRadius;
    // 1. ajustar el contorno al padding real del panel
    final radius = MorphDropdownGeometry.innerRadius(
      outerRadius: containerRadius,
      padding: widget.dropdownStyle.contentPadding,
      direction: Directionality.of(context),
    );
    final searchRadius = sd.borderRadius ?? BorderRadius.circular(radius);
    final panelPadding = widget.dropdownStyle.contentPadding.resolve(
      Directionality.of(context),
    );
    final customMargin = sd.margin.resolve(Directionality.of(context));
    final searchMargin = sd.alignWithPanelPadding
        ? EdgeInsets.fromLTRB(
            panelPadding.left,
            customMargin.top,
            panelPadding.right,
            customMargin.bottom,
          )
        : customMargin;

    return Padding(
      padding: searchMargin,
      child: TextField(
        controller: _searchTextController,
        autofocus: sd.autofocus,
        onTapOutside: (PointerDownEvent event) {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        style:
            sd.textStyle ??
            type.bodyLarge.copyWith(
              color: scheme.onSurface,
              fontSize: ((type.bodyLarge.fontSize ?? 16) + 1.5).clamp(
                17.0,
                23.0,
              ),
            ),
        cursorColor: scheme.primary,
        mouseCursor: sd.mouseCursor,
        decoration: _buildSearchDecoration(
          sd,
          scheme,
          morphTheme,
          searchRadius,
        ),
        onChanged: _handleSearchChanged,
      ),
    );
  }

  InputDecoration _buildSearchDecoration(
    MorphDropdownSearchStyle sd,
    MorphColorScheme scheme,
    MorphThemeData morphTheme,
    BorderRadius searchRadius,
  ) {
    final Color fillColor = sd.fillColor ?? scheme.surfaceContainerHigh;
    return InputDecoration(
      hintText: sd.hintText,
      hintStyle:
          sd.hintStyle ??
          morphTheme.typeScale.bodyLarge.copyWith(
            color: scheme.onSurfaceVariant,
            fontSize: ((morphTheme.typeScale.bodyLarge.fontSize ?? 16) + 1.5)
                .clamp(17.0, 23.0),
          ),
      isDense: true,
      constraints: BoxConstraints(minHeight: sd.minHeight),
      prefixIconConstraints: BoxConstraints(
        minWidth: 48,
        minHeight: sd.minHeight,
      ),
      filled: sd.filled || sd.fillColor != null,
      fillColor: fillColor,
      prefixIcon:
          sd.searchIcon ??
          Icon(
            MorphIcons.search,
            color: scheme.onSurface.withValues(alpha: 0.5),
            size: (morphTheme.resolvedIconTheme.size ?? 20).clamp(22.0, 26.0),
          ),
      suffixIcon: sd.showClearIcon && _searchTextController.text.isNotEmpty
          ? IconButton(
              icon:
                  sd.clearIcon ??
                  Icon(
                    MorphIcons.close,
                    size: morphTheme.resolvedIconTheme.size,
                  ),
              onPressed: () {
                _searchTextController.clear();
                _searchDebounce?.cancel();
                _controller.setSearchQuery('');
              },
            )
          : null,
      contentPadding: sd.contentPadding,
      border: OutlineInputBorder(
        borderRadius: searchRadius,
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: searchRadius,
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: searchRadius,
        borderSide: BorderSide(color: scheme.primary, width: 1.5),
      ),
    );
  }

  void _handleSearchChanged(String value) {
    final debounceMs = widget.searchStyle.searchDebounceMs;
    if (debounceMs <= 0) {
      _controller.setSearchQuery(value);
      return;
    }

    _searchDebounce?.cancel();
    _searchDebounce = Timer(Duration(milliseconds: debounceMs), () {
      _controller.setSearchQuery(value);
    });
  }
}
