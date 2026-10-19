// ignore_for_file: invalid_use_of_protected_member
// helpers del estado original; se revisaran durante la migracion de motion

part of '../morph_dropdown_menus.dart';

/// Open / close / selection helpers for [_MorphDropdownMenuState].
extension _MorphDropdownMenuActions<T> on _MorphDropdownMenuState<T> {
  void _open() {
    if (!widget.enabled || _isLoading) {
      return;
    }
    if (_controller.isOpen && _portalController.isShowing && !_closingPanel) {
      return;
    }

    // Reopening during the exit animation reverses it without removing
    // the existing overlay.
    _closingPanel = false;
    if (!_controller.isOpen) {
      _controller.setOpen(open: true);
    }

    _resolveOpeningDirection();
    _expandCtrl.motion = _resolvedOpenMotion.toMotion();
    _arrowCtrl.motion = _resolvedOpenMotion.toMotion();
    _expandCtrl.animateTo(1);
    _arrowCtrl.animateTo(math.pi);
    _portalController.show();
    _holdOverlayHistory();
    setState(() {});
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_controller.isOpen) {
        return;
      }
      if (MorphFocusInteraction.instance.ringsAllowed) {
        _focusTrapScope.requestFocus();
      }
    });
  }

  void _resolveOpeningDirection() {
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.attached) {
      return;
    }

    final renderBoxSize = renderBox.size;
    final renderBoxOffset = renderBox.localToGlobal(Offset.zero);
    final screenHeight = MediaQuery.of(context).size.height;
    final spaceBelow = screenHeight - renderBoxOffset.dy - renderBoxSize.height;
    final spaceAbove = renderBoxOffset.dy;

    switch (widget.dropdownStyle.expandDirection) {
      case MorphDropdownExpandDirection.down:
        _openingShowOnTop = false;
      case MorphDropdownExpandDirection.up:
        _openingShowOnTop = true;
      case MorphDropdownExpandDirection.auto:
        _openingShowOnTop =
            spaceBelow < widget.dropdownStyle.maxHeight &&
            spaceAbove > spaceBelow;
    }
  }

  void _holdOverlayHistory() {
    _overlayHistory ??= MorphOverlayHistory.register(context, onBack: _close);
  }

  void _releaseOverlayHistory() {
    final MorphOverlayHistory? history = _overlayHistory;
    _overlayHistory = null;
    history?.release();
  }

  void _close() {
    _releaseOverlayHistory();
    if (_closingPanel ||
        (!_controller.isOpen && !_portalController.isShowing)) {
      return;
    }

    // Set this before notifying the controller to prevent a synchronous
    // callback from starting a second, conflicting close animation.
    _closingPanel = true;
    if (_controller.isOpen) {
      _controller.setOpen(open: false);
    }
    _expandCtrl.motion = _resolvedCloseMotion.toMotion();
    _arrowCtrl.motion = _resolvedCloseMotion.toMotion();
    _expandCtrl.animateTo(0);
    _arrowCtrl.animateTo(0);
    _searchTextController.clear();
    _searchDebounce?.cancel();
    if (mounted) {
      _focusNode.requestFocus();
    }
  }

  void _toggle({bool fromPointer = false}) {
    if (!widget.enabled || _isLoading) {
      return;
    }
    _applyHaptic();
    if (_controller.isOpen) {
      _close();
    } else {
      if (fromPointer) {
        MorphFocusInteraction.instance.notePointerInteraction();
        _focusNode.requestFocus();
      }
      _open();
    }
  }

  void _applyHaptic() {
    MorphHaptics.triggerFor(context, widget.haptic);
  }

  void _onItemTap(MorphDropdownItem<T> item) {
    if (item.disabled) {
      return;
    }
    _applyHaptic();

    if (widget.singleSelect) {
      _selectSingleItem(item);
      return;
    }
    if (!_canSelectMultiItem(item)) {
      return;
    }
    if (_tryAnimateChipDeselect(item)) {
      return;
    }

    _controller.toggleWhere((e) => e == item);
    _formFieldKey.currentState?.didChange(_controller.selectedItems);
  }

  void _selectSingleItem(MorphDropdownItem<T> item) {
    _controller.toggleOnly(item);
    WidgetsBinding.instance.addPostFrameCallback((_) => _close());
  }

  bool _canSelectMultiItem(MorphDropdownItem<T> item) {
    if (item.selected) {
      return true;
    }
    final int? limit = widget.limit;
    if (limit != null) {
      return _controller.selectedItems.length < limit;
    }
    if (widget.maxSelections <= 0) {
      return true;
    }
    return _controller.selectedItems.length < widget.maxSelections;
  }

  bool _tryAnimateChipDeselect(MorphDropdownItem<T> item) {
    if (!item.selected || !widget.showChipAnimation) {
      return false;
    }

    final optionKey = item.value as Object;
    final chipKey = _chipKeys[optionKey];
    if (chipKey?.currentState == null) {
      return false;
    }

    final selected = _controller.selectedItems;
    final maxCount = widget.chipStyle.maxDisplayCount;
    final displayOptions = maxCount != null && selected.length > maxCount
        ? selected.take(maxCount).toList()
        : selected;
    final idx = displayOptions.indexWhere((e) => e.value == item.value);
    if (idx < 0) {
      return false;
    }

    _handleChipRemove(item, optionKey, chipKey!, displayOptions, idx);
    return true;
  }
}
