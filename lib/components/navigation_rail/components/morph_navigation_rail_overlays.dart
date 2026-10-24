part of '../morph_navigation_rail.dart';

/// Modal and collapsed-peek overlay management for
/// `_MorphNavigationRailState`, split out to keep the state class under the
/// component length guidelines.
extension _MorphNavigationRailOverlays on _MorphNavigationRailState {
  void _syncOverlay() {
    if (!mounted) {
      return;
    }
    if (_isModal && _isExpanded) {
      _modalShown = true;
    }
    if (_overlayVisible) {
      if (_modalEntry == null) {
        _insertOverlay();
      } else {
        _modalEntry!.markNeedsBuild();
      }
    } else {
      _removeOverlay();
    }
    if (_needsCollapsedPeek) {
      if (_collapsedPeekEntry == null) {
        _insertCollapsedPeekOverlay();
      } else {
        _collapsedPeekEntry!.markNeedsBuild();
      }
    } else {
      _removeCollapsedPeekOverlay();
    }
  }

  void _insertOverlay() {
    final OverlayState overlay = Overlay.of(context, rootOverlay: true);
    _modalEntry = OverlayEntry(
      builder: (BuildContext overlayContext) => InheritedTheme.captureAll(
        context,
        Builder(builder: (context) => _buildModalOverlay(context)),
      ),
    );
    overlay.insert(_modalEntry!);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _modalShown) {
        _modalFocus.requestFocus();
      }
    });
  }

  void _removeOverlay() {
    _modalEntry?.remove();
    _modalEntry = null;
  }

  void _insertCollapsedPeekOverlay() {
    final OverlayState overlay = Overlay.of(context, rootOverlay: true);
    _collapsedPeekEntry = OverlayEntry(
      builder: (BuildContext overlayContext) => InheritedTheme.captureAll(
        context,
        Builder(builder: (context) => _buildCollapsedPeekOverlay(context)),
      ),
    );
    overlay.insert(_collapsedPeekEntry!);
  }

  void _removeCollapsedPeekOverlay() {
    _collapsedPeekEntry?.remove();
    _collapsedPeekEntry = null;
  }

  void _dismissModal() {
    if (!_isExpanded) {
      return;
    }
    widget.onDismissModal?.call();
    _setExpanded(false);
  }

  Widget _buildModalOverlay(BuildContext context) {
    final theme = MorphTheme.of(context).navigationRailTheme;
    final double span = _expandedTarget(context);
    final double reveal = span <= 0 ? 0 : (_width.value / span).clamp(0, 1);
    final rtl = Directionality.of(context) == TextDirection.rtl;
    return MorphScrimSystemUi.wrap(
      CallbackShortcuts(
        bindings: <ShortcutActivator, VoidCallback>{
          const SingleActivator(LogicalKeyboardKey.escape): () =>
              _dismissModal(),
        },
        child: Focus(
          focusNode: _modalFocus,
          autofocus: true,
          skipTraversal: true,
          onKeyEvent: (FocusNode node, KeyEvent event) {
            if (event is KeyDownEvent &&
                event.logicalKey == LogicalKeyboardKey.escape) {
              _dismissModal();
              return KeyEventResult.handled;
            }
            return KeyEventResult.ignored;
          },
          child: Stack(
            children: <Widget>[
              Positioned.fill(
                child: GestureDetector(
                  onTap: () => _dismissModal(),
                  child: ColoredBox(
                    color: MorphTheme.of(context).colorScheme.scrim
                        .withValues(alpha: theme.modalScrimOpacity * reveal),
                  ),
                ),
              ),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: FractionalTranslation(
                  translation: Offset(rtl ? 1 - reveal : reveal - 1, 0),
                  child: Material(
                    animationDuration: MorphMotion.durationOf(
                      context,
                      MorphMotion.short4,
                    ),
                    type: MaterialType.transparency,
                    child: _buildRailCore(context, modal: true),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCollapsedPeekOverlay(BuildContext context) {
    final MorphNavigationRailTheme theme = MorphTheme.of(context)
        .navigationRailTheme;
    final Widget button = MorphIconButton(
      variant: MorphIconButtonVariant.standard,
      icon: const Icon(MorphIcons.menu),
      tooltip: widget.expandTooltip,
      onPressed: _canToggle ? () => _setExpanded(true) : null,
      suppressInk: _suppressInk,
      focusNode: _menuFocus,
    );
    return CompositedTransformFollower(
      link: _anchor,
      showWhenUnlinked: false,
      offset: Offset(8, theme.topSpace),
      child: Material(
        animationDuration: MorphMotion.durationOf(context, MorphMotion.short4),
        type: MaterialType.transparency,
        child: button,
      ),
    );
  }
}
