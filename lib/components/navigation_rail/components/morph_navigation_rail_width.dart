part of '../morph_navigation_rail.dart';

/// Width-target and layout-inset calculations for
/// `_MorphNavigationRailState`, split out to keep the state class under the
/// component length guidelines.
extension _MorphNavigationRailWidth on _MorphNavigationRailState {
  double _collapsedInset(MorphNavigationRailTheme theme) {
    final bool narrow =
        (theme.collapsedWidth - theme.narrowCollapsedWidth).abs() < 0.5;
    return narrow
        ? theme.narrowHorizontalPadding
        : theme.collapsedHorizontalPadding;
  }

  /// Leading edge of the destination icon for the current layout.
  double _iconOrigin(MorphNavigationRailTheme theme, {required bool expanded}) {
    if (expanded) {
      return theme.expandedItemInset + theme.indicatorLeading;
    }
    return _collapsedInset(theme) +
        (theme.verticalIndicatorWidth - theme.iconSize) / 2;
  }

  double _expandedTarget(BuildContext context) {
    final MorphNavigationRailTheme theme = MorphTheme.of(context)
        .navigationRailTheme;
    return (widget.expandedWidth ?? theme.expandedMinWidth).clamp(
      theme.expandedMinWidth,
      theme.expandedMaxWidth,
    );
  }

  double _targetWidth(BuildContext context) {
    final MorphNavigationRailTheme theme = MorphTheme.of(context)
        .navigationRailTheme;
    if (_isModal) {
      return _modalShown && _isExpanded ? _expandedTarget(context) : 0;
    }
    if (!_isExpanded && widget.hideWhenCollapsed) {
      return 0;
    }
    return _isExpanded ? _expandedTarget(context) : theme.collapsedWidth;
  }

  void _animateWidth() {
    final MorphNavigationRailTheme theme = MorphTheme.of(context)
        .navigationRailTheme;
    final double target = _targetWidth(context);
    _width.motion = MorphMotion.springMotion(theme.widthSpring);
    if (!_widthSeeded) {
      _width.value = target;
      _widthSeeded = true;
      return;
    }
    if ((_width.value - target).abs() < 0.5) {
      return;
    }
    _width.animateTo(target);
  }
}
