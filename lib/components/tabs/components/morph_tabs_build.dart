part of '../morph_tabs.dart';

/// Bar chrome, fixed/scrollable layout, and per-tab widget construction for
/// [MorphTabs].
extension _MorphTabsBuild on _MorphTabsState {
  Widget _build(BuildContext context) {
    final theme = MorphTheme.of(context);
    final tabTheme = theme.tabTheme;
    final scheme = theme.colorScheme;
    final bar = _bar(theme, tabTheme, scheme);
    if (!widget._sliver) {
      return bar;
    }
    if (widget.floating) {
      return SliverFloatingHeader(child: bar);
    }
    return PinnedHeaderSliver(child: bar);
  }

  Widget _bar(
    MorphThemeData theme,
    MorphTabTheme tabTheme,
    MorphColorScheme scheme,
  ) {
    final bool stacked = _stacked(tabTheme);
    final double barHeight = tabTheme.barHeight(
      widget.variant,
      stacked: stacked,
    );
    final style = tabTheme.labelStyle(
      theme.typeScale,
      scheme,
      selected: true,
      variant: widget.variant,
    );
    return CallbackShortcuts(
      bindings: _shortcutBindings(),
      child: Material(
        animationDuration: MorphMotion.durationOf(context, MorphMotion.short4),
        key: _barKey,
        color: tabTheme.backgroundColor(scheme),
        elevation: tabTheme.elevation,
        shadowColor: tabTheme.shadowColor(scheme),
        surfaceTintColor: const Color(0x00000000),
        child: SizedBox(
          height: barHeight,
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              return _barStack(constraints, tabTheme, style, scheme);
            },
          ),
        ),
      ),
    );
  }

  Map<ShortcutActivator, VoidCallback> _shortcutBindings() {
    return <ShortcutActivator, VoidCallback>{
      const SingleActivator(LogicalKeyboardKey.arrowRight): () {
        _move(_step(1));
      },
      const SingleActivator(LogicalKeyboardKey.arrowLeft): () {
        _move(_step(-1));
      },
    };
  }

  Widget _barStack(
    BoxConstraints constraints,
    MorphTabTheme tabTheme,
    TextStyle style,
    MorphColorScheme scheme,
  ) {
    final scroll = _useScroll(constraints.maxWidth, tabTheme, style);
    final primary = widget.variant == MorphTabsVariant.primary;
    return Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        if (scroll) _scrollable(tabTheme) else _fixed(tabTheme, style),
        _divider(tabTheme, scheme),
        _indicatorOverlay(tabTheme, scheme, primary),
      ],
    );
  }

  Widget _divider(MorphTabTheme tabTheme, MorphColorScheme scheme) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      height: tabTheme.dividerHeight,
      child: ColoredBox(color: tabTheme.dividerColor(scheme)),
    );
  }

  Widget _indicatorOverlay(
    MorphTabTheme tabTheme,
    MorphColorScheme scheme,
    bool primary,
  ) {
    return AnimatedBuilder(
      animation: Listenable.merge(<Listenable>[
        _indicatorLeft,
        _indicatorWidth,
        _scroll,
      ]),
      builder: (BuildContext context, Widget? _) {
        final double dx =
            _indicatorLeft.value - (_scroll.hasClients ? _scroll.offset : 0);
        return Positioned(
          left: dx,
          width: math.max(0, _indicatorWidth.value),
          bottom: 0,
          height: tabTheme.indicatorExtent(widget.variant),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: tabTheme.indicatorColor(scheme),
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(
                  primary ? tabTheme.indicatorCornerRadius : 0,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _fixed(MorphTabTheme theme, TextStyle style) {
    if (widget.alignment == MorphTabsAlignment.fill) {
      return Row(
        children: <Widget>[
          for (var i = 0; i < widget.tabs.length; i++)
            Expanded(child: _tab(theme, i, scrollable: false)),
        ],
      );
    }
    final double widest = widget.tabs
        .map((MorphTab tab) => _contentWidth(tab, style, theme))
        .reduce(math.max);
    return Row(
      mainAxisAlignment: widget.alignment == MorphTabsAlignment.center
          ? MainAxisAlignment.center
          : MainAxisAlignment.start,
      children: <Widget>[
        for (var i = 0; i < widget.tabs.length; i++)
          SizedBox(width: widest, child: _tab(theme, i, scrollable: false)),
      ],
    );
  }

  Widget _scrollable(MorphTabTheme theme) {
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification notification) {
        _measure();
        return false;
      },
      child: SingleChildScrollView(
        controller: _scroll,
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        padding: EdgeInsetsDirectional.only(
          start: theme.scrollableLeadingOffset,
          end: theme.scrollableLeadingOffset,
        ),
        child: Row(
          children: <Widget>[
            for (var i = 0; i < widget.tabs.length; i++)
              _tab(theme, i, scrollable: true),
          ],
        ),
      ),
    );
  }

  Widget _tab(MorphTabTheme theme, int index, {required bool scrollable}) {
    final MorphTab tab = widget.tabs[index];
    final selected = index == _index;
    final Widget body = MorphTappable(
      focusNode: _nodes[index],
      focusOverlay: false,
      semanticButton: false,
      semanticLabel: tab.semanticLabel ?? tab.label,
      onTap: () => widget.onTabSelected(index),
      builder: (BuildContext context, MorphInteractionState state) {
        return _tabContent(
          context: context,
          state: state,
          theme: theme,
          tab: tab,
          index: index,
          selected: selected,
          scrollable: scrollable,
        );
      },
    );
    return KeyedSubtree(
      key: _slotKeys[index],
      child: Semantics(selected: selected, child: body),
    );
  }

  Widget _tabContent({
    required BuildContext context,
    required MorphInteractionState state,
    required MorphTabTheme theme,
    required MorphTab tab,
    required int index,
    required bool selected,
    required bool scrollable,
  }) {
    final scheme = MorphTheme.of(context).colorScheme;
    final bool interacting = state.hovered || state.focused || state.pressed;
    final double opacity = theme.stateOpacity(
      hovered: state.hovered,
      focused: state.focused,
      pressed: state.pressed,
    );
    final Color layer = theme.stateLayerColor(
      scheme,
      variant: widget.variant,
      selected: selected,
    );
    final Widget label = KeyedSubtree(
      key: _contentKeys[index],
      child: _content(theme, tab, selected, interacting),
    );
    final Widget? ring = state.focused ? _focusRing(theme, scheme) : null;
    if (scrollable) {
      return _scrollableTabBody(theme, label, layer, opacity, ring);
    }
    return _fixedTabBody(theme, label, layer, opacity, ring);
  }

  Widget _focusRing(MorphTabTheme theme, MorphColorScheme scheme) {
    return Padding(
      padding: EdgeInsets.all(theme.focusInset),
      child: IgnorePointer(
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(theme.interactionCornerRadius),
            border: Border.all(
              color: theme.focusColor(scheme),
              width: theme.focusThickness,
            ),
          ),
        ),
      ),
    );
  }

  Widget _scrollableTabBody(
    MorphTabTheme theme,
    Widget label,
    Color layer,
    double opacity,
    Widget? ring,
  ) {
    return SizedBox(
      height: double.infinity,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: theme.scrollableTabPadding,
            ),
            child: label,
          ),
          Positioned.fill(
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                if (opacity > 0)
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: layer.withValues(alpha: opacity),
                      borderRadius: BorderRadius.circular(
                        theme.interactionCornerRadius,
                      ),
                    ),
                  ),
                ?ring,
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _fixedTabBody(
    MorphTabTheme theme,
    Widget label,
    Color layer,
    double opacity,
    Widget? ring,
  ) {
    return SizedBox.expand(
      child: Stack(
        clipBehavior: Clip.none,
        fit: StackFit.expand,
        children: <Widget>[
          if (opacity > 0)
            DecoratedBox(
              decoration: BoxDecoration(
                color: layer.withValues(alpha: opacity),
                borderRadius: BorderRadius.circular(
                  theme.interactionCornerRadius,
                ),
              ),
            ),
          ?ring,
          Center(child: label),
        ],
      ),
    );
  }
}
