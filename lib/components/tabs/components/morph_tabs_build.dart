part of '../morph_tabs.dart';

/// Bar chrome, fixed/scrollable layout, and per-tab widget construction for
/// [MorphTabs].
extension _MorphTabsBuild on _MorphTabsState {
  Widget _build(BuildContext context) {
    final theme = MorphTheme.of(context);
    final tabTheme = widget.tabTheme ?? theme.tabTheme;
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
    _spec = tabTheme.resolveIndicator(
      scheme,
      widget.variant,
      style: widget.indicatorStyle,
      motion: widget.indicatorMotion,
      fit: widget.indicatorFit,
      renderer: widget.indicatorRenderer,
      duration: widget.indicatorDuration,
    );
    final double labelLine = MediaQuery.textScalerOf(context).scale(20);
    // A stacked badge mark is centred near the icon corner and scales with the
    // text: keep it inside the bar at large text scales.
    final bool stackedBadge =
        stacked &&
        widget.tabs.any((MorphTab t) => t.hasBadge && !_inlineBadge(t));
    final double clearance = stackedBadge
        ? math.max(0, 16 * (labelLine / 20) - 14)
        : 0;
    _stackedLift = clearance > 4 ? clearance - 4 : 0;
    final double barHeight = tabTheme.barHeight(
      widget.variant,
      stacked: stacked,
      labelLineHeight: labelLine,
      badgeClearance: clearance,
      verticalChrome: _spec.isSurface
          ? 2 * _spec.verticalPadding + 2 * _spec.surfaceInset
          : 8,
    );
    _barHeight = barHeight;
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
              return _barStack(
                context,
                constraints,
                tabTheme,
                style,
                scheme,
                theme,
              );
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
    BuildContext context,
    BoxConstraints constraints,
    MorphTabTheme tabTheme,
    TextStyle style,
    MorphColorScheme scheme,
    MorphThemeData theme,
  ) {
    final scroll = _useScroll(constraints.maxWidth, tabTheme, style);
    final MorphTabIndicatorSpec spec = _spec;
    _observe(
      Object.hash(
        constraints.maxWidth,
        MediaQuery.textScalerOf(context).scale(14),
        Directionality.of(context),
        widget.variant,
        widget.alignment,
        scroll,
        spec.style,
        spec.fit,
        spec.tabInset,
        spec.padding,
        spec.contentInset,
        spec.minLength,
        spec.surfaceInset,
        spec.verticalPadding,
        spec.thickness,
      ),
      Object.hash(_tabsSignature(), tabTheme, theme.typeScale.titleSmall),
    );
    // The tab list role sits on the row itself, not on the scroll viewport:
    // its semantic children must all be tabs.
    final Widget tabs = Semantics(
      role: SemanticsRole.tabBar,
      container: true,
      child: scroll ? _scrollable(tabTheme) : _fixed(tabTheme, style),
    );
    final Widget track = Stack(
      key: _trackKey,
      clipBehavior: Clip.none,
      children: <Widget>[
        _groupBackground(),
        _indicatorLayer(surface: true),
        tabs,
        _indicatorLayer(surface: false),
      ],
    );
    return Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        _divider(tabTheme, scheme),
        if (scroll)
          Positioned.fill(child: _scrollView(tabTheme, track))
        else
          Positioned.fill(child: track),
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

  Widget _fixed(MorphTabTheme theme, TextStyle style) {
    if (widget.alignment == MorphTabsAlignment.fill) {
      return Row(
        children: <Widget>[
          for (var i = 0; i < widget.tabs.length; i++)
            Expanded(child: _tab(theme, i, scrollable: false)),
        ],
      );
    }
    if (widget.alignment == MorphTabsAlignment.content) {
      return Row(
        children: <Widget>[
          for (var i = 0; i < widget.tabs.length; i++)
            _tab(theme, i, scrollable: true),
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
    return Row(
      children: <Widget>[
        for (var i = 0; i < widget.tabs.length; i++)
          _tab(theme, i, scrollable: true),
      ],
    );
  }

  /// The scroll viewport. The track (tabs and indicator) is its child, so the
  /// indicator shares the coordinate space of the tabs and the scroll offset is
  /// applied once, by the scrollable itself.
  Widget _scrollView(MorphTabTheme theme, Widget track) {
    // Clipped to the viewport horizontally only: the antialiased edge of a
    // rounded underline at the bottom of the bar is never cut.
    return NotificationListener<ScrollNotification>(
      onNotification: _onScrollNotification,
      child: ClipRect(
        clipper: const _ViewportClipper(),
        child: SingleChildScrollView(
          controller: _scroll,
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          padding: EdgeInsetsDirectional.only(
            start: theme.scrollableLeadingOffset,
            end: theme.scrollableLeadingOffset,
          ),
          child: track,
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
      // One node: the tab role, its selected state, the activation action of
      // the tappable and the relation to the page it controls.
      child: MergeSemantics(
        child: Semantics(
          role: SemanticsRole.tab,
          selected: selected,
          controlsNodes: _panelNodes(index),
          child: body,
        ),
      ),
    );
  }

  Set<String>? _panelNodes(int index) {
    final MorphTabsController? controller = widget.controller;
    if (controller == null) {
      return null;
    }
    return <String>{controller.panelIdentifier(index)};
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
      style: _spec.style,
    );
    final Widget label = KeyedSubtree(
      key: _contentKeys[index],
      child: AnimatedBuilder(
        animation: _pulse,
        builder: (BuildContext context, Widget? _) =>
            _content(theme, tab, _weightOf(index), interacting),
      ),
    );
    if (_spec.isSurface) {
      return _surfaceTabBody(
        theme: theme,
        scheme: scheme,
        label: label,
        layer: layer,
        opacity: opacity,
        focused: state.focused,
        shrink: scrollable,
      );
    }
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
            padding: EdgeInsets.symmetric(horizontal: _slotPadding(theme)),
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

  /// Body of a tab for the surface presentation.
  ///
  /// The hover / pressed layer and the focus ring use the geometry of the
  /// surface itself (same inset, same inner radius): a capsule for a pill, the
  /// inner radius for a rounded rectangle. The whole slot stays the hit target.
  Widget _surfaceTabBody({
    required MorphTabTheme theme,
    required MorphColorScheme scheme,
    required Widget label,
    required Color layer,
    required double opacity,
    required bool focused,
    required bool shrink,
  }) {
    final MorphTabIndicatorSpec spec = _spec;
    final double radius = spec.innerRadius(_barHeight);
    // A hugging layout, or a content fit, sizes the tab by its content.
    final bool hug = shrink || spec.fit == MorphTabsIndicatorFit.content;
    final double gap = math.min(2, spec.surfaceInset);
    Widget surface = DecoratedBox(
      key: const ValueKey<String>('morph-tabs-interaction'),
      decoration: BoxDecoration(
        color: opacity > 0 ? layer.withValues(alpha: opacity) : null,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: hug ? spec.padding : 0),
        child: Center(widthFactor: hug ? 1 : null, child: label),
      ),
    );
    if (focused) {
      surface = Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          surface,
          Positioned(
            left: -gap,
            top: -gap,
            right: -gap,
            bottom: -gap,
            child: IgnorePointer(
              child: DecoratedBox(
                key: const ValueKey<String>('morph-tabs-focus'),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(radius + gap),
                  border: Border.all(
                    color: theme.focusColor(scheme),
                    width: theme.focusThickness,
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }
    return SizedBox(
      height: double.infinity,
      child: Padding(
        padding: EdgeInsets.all(spec.surfaceInset),
        child: hug ? Align(widthFactor: 1, child: surface) : surface,
      ),
    );
  }
}

/// Clips to the bar width with a small vertical margin for edge coverage.
class _ViewportClipper extends CustomClipper<Rect> {
  const _ViewportClipper();

  @override
  Rect getClip(Size size) => Rect.fromLTRB(0, -4, size.width, size.height + 4);

  @override
  bool shouldReclip(_ViewportClipper oldClipper) => false;
}
