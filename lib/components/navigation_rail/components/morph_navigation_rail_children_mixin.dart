part of '../morph_navigation_rail.dart';

mixin _MorphNavigationRailChildrenMixin on State<MorphNavigationRail> {
  bool get _suppressInk;
  bool get _showExpandedItems;
  List<FocusNode> get _destinationNodes;

  Widget _buildMenuButton(BuildContext context);
  Widget? _buildFab(BuildContext context, {required bool showLabels});

  Widget? _buildTrailing(BuildContext context) {
    final Widget? trailing = widget.trailing;
    if (trailing == null) {
      return null;
    }
    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 16),
      child: Align(
        alignment: _showExpandedItems
            ? AlignmentDirectional.centerStart
            : Alignment.center,
        child: trailing,
      ),
    );
  }

  List<Widget> _headerChildren(BuildContext context) {
    final theme = MorphTheme.of(context).navigationRailTheme;
    final children = <Widget>[SizedBox(height: theme.topSpace)];
    if (widget.leading != null) {
      children.add(
        Padding(
          padding: const EdgeInsetsDirectional.only(bottom: 8),
          child: widget.leading,
        ),
      );
    }
    children.add(_buildMenuButton(context));
    final Widget? fab = _buildFab(context, showLabels: _showExpandedItems);
    if (fab != null) {
      children.add(fab);
    }
    return children;
  }

  List<Widget> _destinationChildren(BuildContext context) {
    final MorphNavigationRailTheme theme = MorphTheme.of(context)
        .navigationRailTheme;
    final List<Widget> children = _showExpandedItems
        ? _buildExpandedDestinations(context, theme)
        : _buildCollapsedDestinations(theme);
    if (_showExpandedItems) {
      children.add(SizedBox(height: theme.expandedTrailingSpace));
    }
    if (widget.trailing != null && !widget.trailingAtBottom) {
      final Widget? trailing = _buildTrailing(context);
      if (trailing != null) {
        children.add(trailing);
      }
    }
    return children;
  }

  List<Widget> _buildExpandedDestinations(
    BuildContext context,
    MorphNavigationRailTheme theme,
  ) {
    final children = <Widget>[];
    var index = 0;
    for (final MorphNavigationRailSection section in widget.sections) {
      if (section.header != null) {
        children.add(_sectionHeader(context, theme, section.header!));
      }
      for (final MorphNavigationRailDestination dest in section.destinations) {
        final itemIndex = index;
        children.add(
          _paddedDestination(
            gap: theme.expandedItemGap,
            child: MorphRailItem(
              motion: widget.motion,
              destination: dest,
              selected: itemIndex == widget.selectedIndex,
              onTap: () => widget.onDestinationSelected(itemIndex),
              expanded: true,
              labelBehavior: widget.labelBehavior,
              suppressInk: _suppressInk,
              focusNode: _destinationNodes[itemIndex],
            ),
          ),
        );
        index++;
      }
    }
    return children;
  }

  List<Widget> _buildCollapsedDestinations(MorphNavigationRailTheme theme) {
    final List<MorphNavigationRailDestination> all = widget.sections
        .expand((MorphNavigationRailSection s) => s.destinations)
        .toList();
    return <Widget>[
      for (var i = 0; i < all.length; i++)
        _paddedDestination(
          gap: theme.itemVerticalGap,
          child: MorphRailItem(
            motion: widget.motion,
            destination: all[i],
            selected: i == widget.selectedIndex,
            onTap: () => widget.onDestinationSelected(i),
            expanded: false,
            labelBehavior: widget.labelBehavior,
            suppressInk: _suppressInk,
            focusNode: _destinationNodes[i],
          ),
        ),
    ];
  }

  Widget _sectionHeader(
    BuildContext context,
    MorphNavigationRailTheme theme,
    Widget header,
  ) {
    final MorphThemeData morph = MorphTheme.of(context);
    return Padding(
      padding: EdgeInsetsDirectional.only(
        start: theme.indicatorLeading,
        end: theme.indicatorTrailing,
        top: theme.sectionHeaderSpacingTop,
        bottom: theme.sectionHeaderSpacingBottom,
      ),
      child: DefaultTextStyle(
        style: morph.typeScale.titleSmall.copyWith(
          color: morph.colorScheme.onSurfaceVariant,
        ),
        child: header,
      ),
    );
  }

  Widget _paddedDestination({required double gap, required Widget child}) {
    return Padding(
      padding: EdgeInsets.only(bottom: gap),
      child: child,
    );
  }
}
