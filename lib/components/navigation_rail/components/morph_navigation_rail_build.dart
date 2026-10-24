part of '../morph_navigation_rail.dart';

/// Rail-body widget-building helpers for `_MorphNavigationRailState`, split
/// out to keep the state class under the component length guidelines.
extension _MorphNavigationRailBuild on _MorphNavigationRailState {
  Widget _buildRailCore(BuildContext context, {required bool modal}) {
    final MorphThemeData morph = MorphTheme.of(context);
    final MorphNavigationRailTheme theme = morph.navigationRailTheme;
    final MorphColorScheme scheme = morph.colorScheme;
    final bool raised = widget.scrollUnder && _scrolledUnder && !modal;
    final Color color =
        widget.background ??
        (modal
            ? theme.modalContainerColorResolved(scheme)
            : raised
            ? theme.scrolledContainerColorResolved(scheme)
            : theme.containerColorResolved(scheme));
    final double elevation = raised ? theme.scrolledElevation : theme.elevation;
    final double corner = modal
        ? theme.modalContainerRadius
        : theme.containerRadius;
    final double raw = modal ? _expandedTarget(context) : _width.value;
    final double width = raw < 0 ? 0 : raw;
    final bool revealExpanded = !modal && _immersive && _showExpandedItems;
    final double contentWidth = revealExpanded
        ? _expandedTarget(context)
        : width;
    final BorderRadius? radius = corner > 0
        ? BorderRadius.circular(corner)
        : null;
    Widget rail = DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        borderRadius: radius,
        boxShadow: MorphElevation.shadows(
          elevation,
          shadowColor: scheme.shadow,
        ),
      ),
      child: Material(
        animationDuration: MorphMotion.durationOf(context, MorphMotion.short4),
        type: MaterialType.transparency,
        child: _body(context),
      ),
    );
    if (widget.showDivider) {
      rail = Stack(
        children: <Widget>[
          rail,
          PositionedDirectional(
            top: 0,
            bottom: 0,
            end: 0,
            width: theme.dividerThickness,
            child: ColoredBox(color: theme.dividerColorResolved(scheme)),
          ),
        ],
      );
    }
    if (radius != null) {
      rail = ClipRRect(borderRadius: radius, child: rail);
    }
    rail = SizedBox(width: contentWidth, child: rail);
    if (revealExpanded && contentWidth > width) {
      rail = ClipRect(
        child: OverflowBox(
          alignment: AlignmentDirectional.centerStart,
          minWidth: contentWidth,
          maxWidth: contentWidth,
          child: rail,
        ),
      );
    }
    return _shortcuts(SizedBox(width: width, child: rail));
  }

  double _destinationListTop(MorphNavigationRailTheme theme) {
    final bool controls =
        widget.leading != null || widget.fab != null || _canToggle;
    if (!controls) {
      return 0;
    }
    return theme.destinationTopPadding;
  }

  Widget _body(BuildContext context) {
    final MorphNavigationRailTheme theme = MorphTheme.of(context)
        .navigationRailTheme;
    final double listTop = _destinationListTop(theme);
    final listPadding = EdgeInsets.only(top: listTop);
    final List<Widget> header = _headerChildren(context);
    final rows = _destinationChildren(context);
    final List<Widget> destinations =
        widget.motion == MorphNavigationMotion.morph
        ? [
            MorphSlidingIndicator(
              axis: Axis.vertical,
              selectionDelay: widget.selectionDelay,
              leadSpring: theme.indicatorLeadSpring,
              trailSpring: theme.indicatorTrailSpring,
              child: Column(mainAxisSize: MainAxisSize.min, children: rows),
            ),
          ]
        : rows;
    final Widget? trailing = widget.trailing != null && widget.trailingAtBottom
        ? _buildTrailing(context)
        : null;
    final Widget group = widget.alignment == MorphNavigationRailAlignment.center
        ? Expanded(
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final double minHeight = constraints.maxHeight - listTop;
                return SingleChildScrollView(
                  padding: listPadding,
                  physics: widget.scrollable
                      ? const ClampingScrollPhysics()
                      : const NeverScrollableScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: minHeight < 0 ? 0 : minHeight,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: destinations,
                    ),
                  ),
                );
              },
            ),
          )
        : Expanded(
            child: widget.scrollable
                ? ListView(padding: listPadding, children: destinations)
                : SingleChildScrollView(
                    padding: listPadding,
                    physics: const NeverScrollableScrollPhysics(),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: destinations,
                    ),
                  ),
          );
    final int destinationsCount = widget.sections.fold<int>(0, (
      int count,
      MorphNavigationRailSection section,
    ) {
      return count + section.destinations.length;
    });
    return Semantics(
      role: destinationsCount > 0 ? SemanticsRole.menu : null,
      explicitChildNodes: true,
      child: Column(children: <Widget>[...header, group, ?trailing]),
    );
  }

  Widget _shortcuts(Widget child) {
    return CallbackShortcuts(
      bindings: <ShortcutActivator, VoidCallback>{
        const SingleActivator(LogicalKeyboardKey.arrowDown): () => _move(1),
        const SingleActivator(LogicalKeyboardKey.arrowUp): () => _move(-1),
        const SingleActivator(LogicalKeyboardKey.arrowRight): () =>
            _move(_arrowDelta(LogicalKeyboardKey.arrowRight)),
        const SingleActivator(LogicalKeyboardKey.arrowLeft): () =>
            _move(_arrowDelta(LogicalKeyboardKey.arrowLeft)),
      },
      child: child,
    );
  }
}
