// ignore_for_file: invalid_use_of_protected_member
// helpers del estado original; se revisaran durante la migracion de motion

part of '../morph_split_buttons.dart';

/// Menu open/show helpers for [_MorphSplitButtonState].
extension _MorphSplitButtonMenu<T> on _MorphSplitButtonState<T> {
  Future<void> _openMenu(BuildContext context) async {
    if (!widget.enabled) {
      return;
    }
    if (widget.menuBuilder != null) {
      await _showNativeMenu(context);
      return;
    }
    if (widget.morphMenuBuilder != null) {
      await _showM3eCustomMenu(context);
      return;
    }

    final items = widget.items!;
    final menuStyle =
        widget.decoration?.menuStyle ?? MorphSplitButtonMenuStyle.popup;

    switch (menuStyle) {
      case MorphSplitButtonMenuStyle.popup:
        await _showSpringPopup(context, items);
      case MorphSplitButtonMenuStyle.bottomSheet:
        await _showBottomSheet(context, items);
      case MorphSplitButtonMenuStyle.native:
        await _showNativeMenu(context, items: items);
    }
  }

  Future<void> _showM3eCustomMenu(BuildContext context) async {
    final menuStyle =
        widget.decoration?.menuStyle ?? MorphSplitButtonMenuStyle.popup;
    if (menuStyle == MorphSplitButtonMenuStyle.bottomSheet) {
      assert(() {
        debugPrint(
          'MorphSplitButton.morphMenuBuilder does not support '
          'MorphSplitButtonMenuStyle.bottomSheet; falling back to popup.',
        );
        return true;
      }(), 'morphMenuBuilder does not support bottomSheet menu style');
    }
    final useNativeTheme = menuStyle == MorphSplitButtonMenuStyle.native;
    await _showM3eMenuNodes(
      context,
      widget.morphMenuBuilder!(context),
      applyPopupTheme: !useNativeTheme,
    );
  }

  Future<void> _showSpringPopup(
    BuildContext context,
    List<MorphSplitButtonItem<T>> items,
  ) async {
    final iconSize = _splitTheme.splitIcon(widget.size);
    final nodes = <MorphMenuNode>[
      for (final item in items) _splitItemToMenuNode(item, iconSize: iconSize),
    ];
    await _showM3eMenuNodes(context, nodes, applyPopupTheme: true);
  }

  Future<void> _showM3eMenuNodes(
    BuildContext context,
    List<MorphMenuNode> nodes, {
    required bool applyPopupTheme,
  }) async {
    setState(() => _menuOpen = true);

    final tCtx = _trailingKey.currentContext;
    if (tCtx == null) {
      _closeMenu();
      return;
    }
    final Rect? anchor = morphOverlayRectFor(tCtx);
    final tb = tCtx.findRenderObject() as RenderBox?;
    if (anchor == null || tb == null || !tb.hasSize) {
      _closeMenu();
      return;
    }

    final popupDec =
        widget.decoration?.popupDecoration ??
        MorphSplitButtonPopupDecoration(
          backgroundColor: _splitTheme.popupBackgroundColor(_scheme),
          elevation: _splitTheme.popupElevation,
          borderRadius: BorderRadius.circular(_splitTheme.popupBorderRadius),
          offset: _splitTheme.popupOffset,
          minWidth: _splitTheme.popupMinWidth,
          maxWidth: _splitTheme.popupMaxWidth,
          maxHeight: _splitTheme.popupMaxHeight,
          padding: _splitTheme.popupPadding,
          motion: _splitTheme.popupMotion,
        );

    // Al igual que el dropdown, el radio del elemento respeta la distancia
    // al borde del popup, evitando esquinas internas demasiado cuadradas.
    final popupPadding = popupDec.padding ?? _splitTheme.popupPadding;
    final popupRadius = popupDec.borderRadius?.topLeft.x ??
        _splitTheme.popupBorderRadius;
    final itemRadius = popupDec.selectedBorderRadius?.topLeft.x ??
        MorphDropdownGeometry.innerRadius(
          outerRadius: popupRadius,
          padding: popupPadding,
          direction: Directionality.of(context),
        );
    final inset = popupPadding.resolve(Directionality.of(context));

    final MorphMenuTheme? menuTheme = applyPopupTheme
        ? MorphTheme.of(context).menuTheme.copyWith(
            containerRadius: popupRadius,
            containerBottomRadius: popupRadius,
            itemRadius: itemRadius,
            stateLayerInset: inset.left,
            verticalPadding: inset.top,
            entryHorizontalPadding: 16,
            entryHeight: 52,
            minWidth: popupDec.minWidth,
            maxWidth: popupDec.maxWidth,
            maxHeight: popupDec.maxHeight,
            elevation: popupDec.elevation ?? _splitTheme.popupElevation,
            backgroundColor: popupDec.backgroundColor,
            anchorOffset: popupDec.offset.dy != 0
                ? popupDec.offset.dy
                : MorphTheme.of(context).menuTheme.anchorOffset,
          )
        : null;

    final double preferredWidth = applyPopupTheme
        ? (tb.size.width + 176.0).clamp(popupDec.minWidth, popupDec.maxWidth)
        : tb.size.width;

    final res = await showMorphMenu<T>(
      context: context,
      anchor: anchor,
      children: nodes,
      colorStyle: applyPopupTheme
          ? MorphMenuColorStyle.primary
          : MorphMenuColorStyle.standard,
      selectedValue: widget.selectedValue,
      preferredWidth: preferredWidth,
      callerFocusNode: _trailingFocusNode,
      themeOverride: menuTheme,
    );

    if (!mounted) {
      return;
    }
    _closeMenu();
    if (res != null && widget.onSelected != null) {
      widget.onSelected!(res);
    }
  }

  /// Maps a split-button item to a menu node using [MorphMenuTheme] colors
  /// (not the split button's on-container color).
  MorphMenuNode _splitItemToMenuNode(
    MorphSplitButtonItem<T> item, {
    required double iconSize,
  }) {
    final selected =
        widget.selectedValue != null && widget.selectedValue == item.value;
    final theme = MorphTheme.of(context);
    final menuTheme = theme.menuTheme;
    final scheme = theme.colorScheme;
    final foreground = menuTheme.entryForegroundColor(
      scheme,
      enabled: item.enabled,
      selected: selected,
      style: MorphMenuColorStyle.primary,
    );
    final labelStyle = menuTheme.entryLabelStyle(
      theme.typeScale,
      scheme,
      enabled: item.enabled,
      selected: selected,
      style: MorphMenuColorStyle.primary,
    );

    if (item.child is IconData) {
      return MorphMenuSelectable(
        label: item.child.toString(),
        value: item.value as Object,
        enabled: item.enabled,
        selected: selected,
        leading: Icon(item.child as IconData, size: iconSize),
      );
    }

    if (item.child is Widget) {
      return MorphMenuWidget(
        value: item.value,
        enabled: item.enabled,
        selected: selected,
        child: IconTheme.merge(
          data: IconThemeData(color: foreground, size: iconSize),
          child: DefaultTextStyle.merge(
            style: labelStyle,
            child: item.child as Widget,
          ),
        ),
      );
    }

    return MorphMenuSelectable(
      label: item.child.toString(),
      value: item.value as Object,
      enabled: item.enabled,
      selected: selected,
    );
  }

  Future<void> _showBottomSheet(
    BuildContext context,
    List<MorphSplitButtonItem<T>> items,
  ) async {
    setState(() => _menuOpen = true);

    final (_, onCont, _, _) = _resolveColorsAndShapes(
      context,
      segmentEnabled: widget.enabled,
    );

    final bottomSheetDec =
        widget.decoration?.bottomSheetDecoration ??
        const MorphSplitButtonBottomSheetDecoration();

    final isMultiSelect =
        bottomSheetDec.selectionMode == MorphSplitButtonSelectionMode.multiple;

    if (isMultiSelect) {
      await _showMultiSelectBottomSheet(context, items, bottomSheetDec, onCont);
    } else {
      await _showSingleSelectBottomSheet(
        context,
        items,
        bottomSheetDec,
        onCont,
      );
    }
  }

  Future<void> _showMultiSelectBottomSheet(
    BuildContext context,
    List<MorphSplitButtonItem<T>> items,
    MorphSplitButtonBottomSheetDecoration bottomSheetDec,
    Color onCont,
  ) async {
    final result = await showSplitButtonBottomSheet<T>(
      context: context,
      items: items,
      decoration: bottomSheetDec,
      foregroundColor: widget.decorationMenuForegroundColor ?? onCont,
      iconSize: _splitTheme.splitIcon(widget.size),
      callerFocusNode: _trailingFocusNode,
      selectedValues: _selectedValues?.cast<T>(),
    );

    if (!mounted) {
      return;
    }
    if (result is List) {
      final Set<T> selectedSet = result.cast<T>().toSet();
      _selectedValues = selectedSet;
      widget.onMultiSelected?.call(selectedSet);
    }
    _closeMenu();
  }

  Future<void> _showSingleSelectBottomSheet(
    BuildContext context,
    List<MorphSplitButtonItem<T>> items,
    MorphSplitButtonBottomSheetDecoration bottomSheetDec,
    Color onCont,
  ) async {
    final res = await showSplitButtonBottomSheet<T>(
      context: context,
      items: items,
      decoration: bottomSheetDec,
      foregroundColor: widget.decorationMenuForegroundColor ?? onCont,
      iconSize: _splitTheme.splitIcon(widget.size),
      callerFocusNode: _trailingFocusNode,
    );

    if (!mounted) {
      return;
    }
    _closeMenu();
    if (res != null && widget.onSelected != null) {
      widget.onSelected!(res as T);
    }
  }

  Future<void> _showNativeMenu(
    BuildContext context, {
    List<MorphSplitButtonItem<T>>? items,
  }) async {
    setState(() => _menuOpen = true);

    final trailingBox = _trailingRenderBox();
    final tSize = trailingBox?.size ?? Size.zero;
    final double minMenuWidth = tSize.width > 0
        ? tSize.width
        : _splitTheme.splitTrailingWidth(widget.size);

    if (items == null) {
      await _showCustomNativeMenu(context, minMenuWidth);
      return;
    }

    if (trailingBox == null) {
      _closeMenu();
      return;
    }

    await _showItemsNativeMenu(context, items, trailingBox, minMenuWidth);
  }

  RenderBox? _trailingRenderBox() {
    final tCtx = _trailingKey.currentContext;
    if (tCtx == null) {
      return null;
    }
    return tCtx.findRenderObject() as RenderBox?;
  }

  Future<void> _showCustomNativeMenu(
    BuildContext context,
    double minMenuWidth,
  ) async {
    final res = await showMenu<T>(
      context: context,
      position: _menuPosition(context),
      constraints: BoxConstraints(minWidth: minMenuWidth),
      items: widget.menuBuilder!(context),
    );
    if (!mounted) {
      return;
    }
    _closeMenu();
    if (res != null && widget.onSelected != null) {
      widget.onSelected!(res);
    }
  }

  Future<void> _showItemsNativeMenu(
    BuildContext context,
    List<MorphSplitButtonItem<T>> items,
    RenderBox tb,
    double minMenuWidth,
  ) async {
    final iconSize = _splitTheme.splitIcon(widget.size);
    final nodes = <MorphMenuNode>[
      for (final item in items) _splitItemToMenuNode(item, iconSize: iconSize),
    ];

    final BuildContext? tCtx = _trailingKey.currentContext;
    final Rect anchor =
        (tCtx != null ? morphOverlayRectFor(tCtx) : null) ??
        (tb.localToGlobal(Offset.zero) & tb.size);
    final res = await showMorphMenu<T>(
      context: context,
      anchor: anchor,
      children: nodes,
      selectedValue: widget.selectedValue,
      preferredWidth: minMenuWidth,
      callerFocusNode: _trailingFocusNode,
    );

    if (!mounted) {
      return;
    }
    _closeMenu();
    if (res != null && widget.onSelected != null) {
      widget.onSelected!(res);
    }
  }

  RelativeRect _menuPosition(BuildContext context) {
    final overlay =
        Overlay.of(context).context.findRenderObject()! as RenderBox;

    final BuildContext tCtx = _trailingKey.currentContext ?? context;
    final targetBox = tCtx.findRenderObject()! as RenderBox;

    final Offset targetTopLeft = targetBox.localToGlobal(
      Offset.zero,
      ancestor: overlay,
    );
    final targetRect = Rect.fromLTWH(
      targetTopLeft.dx,
      targetTopLeft.dy,
      targetBox.size.width,
      targetBox.size.height,
    );

    const kMenuVerticalOffset = 4;
    final double top = targetRect.bottom + kMenuVerticalOffset;
    final left = targetRect.left;
    final right = overlay.size.width - targetRect.right;

    return RelativeRect.fromLTRB(left, top, right, overlay.size.height - top);
  }
}
