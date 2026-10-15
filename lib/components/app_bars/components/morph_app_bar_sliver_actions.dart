part of '../morph_app_bars.dart';

/// Builds the [MorphAppBarHideMode.actions]-only variant of the sliver app bar,
/// where the action row stays pinned while the rest of the bar slides away.
extension _MorphSliverAppBarActions on _MorphSliverAppBarState {
  Widget _actionSliver(
    MorphThemeData theme,
    MorphAppBarTheme appBarTheme,
    MorphColorScheme scheme,
    MorphAppBarMetrics metrics,
    _MorphBarMotion motion,
    double top,
  ) {
    final double push = motion.band;
    final double paintContent = math.max(push, _collapsed);
    final double share = _follow ? 1.0 : motion.shown.clamp(0.0, 1.0);
    // Actions mode hides on scroll, so the bar keeps its resting look.
    final Color bg = _morphBarColor(
      bar: bar,
      theme: appBarTheme,
      scheme: scheme,
      under: false,
    );
    final double elevation = metrics.elevation;
    final Widget? leading = _actionSliverLeading(appBarTheme, scheme);
    final Widget body = _actionSliverBody(
      theme,
      appBarTheme,
      scheme,
      metrics,
      motion,
      leading,
      bg,
    );
    return _MorphActionSliver(
      maxExtent: top + _expanded * share,
      minExtent: top + _collapsed,
      child: _MorphScrolledUnder(
        scrolledUnder: false,
        child: SizedBox(
          height: top + paintContent,
          child: Padding(
            padding: EdgeInsets.only(top: top),
            child: Stack(
              children: <Widget>[
                _actionSliverSurface(
                  bg: bg,
                  elevation: elevation,
                  appBarTheme: appBarTheme,
                  scheme: scheme,
                  push: push,
                  motion: motion,
                  body: body,
                ),
                _actionSliverRow(
                  appBarTheme: appBarTheme,
                  metrics: metrics,
                  scheme: scheme,
                  motion: motion,
                  leading: leading,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget? _actionSliverLeading(
    MorphAppBarTheme appBarTheme,
    MorphColorScheme scheme,
  ) {
    return bar.leading ??
        (bar.automaticallyImplyLeading
            ? _maybeBackButton(
                context,
                bar.foregroundColor ?? appBarTheme.leadingColor(scheme),
              )
            : null);
  }

  Widget _actionSliverBody(
    MorphThemeData theme,
    MorphAppBarTheme appBarTheme,
    MorphColorScheme scheme,
    MorphAppBarMetrics metrics,
    _MorphBarMotion motion,
    Widget? leading,
    Color containerColor,
  ) {
    return _MorphBarBody(
      expand: motion.titleExpand,
      topPadding: appBarTheme.flexibleTopPadding,
      actionRow: appBarTheme.actionRowHeight,
      bottomPadding: metrics.flexibleBottomPadding,
      titleInset: metrics.titleInset,
      contentPadding: metrics.contentPadding,
      centerTitle: bar.centerTitle,
      search: bar.title is _MorphAppBarSearchTitle,
      leading: leading,
      actions: bar.actions,
      title: _sliverTitle(theme, appBarTheme, scheme, motion.titleExpand),
      leadingColor: bar.foregroundColor ?? appBarTheme.leadingColor(scheme),
      trailingColor: appBarTheme.trailingColor(scheme),
      iconSize: metrics.iconSize,
      separateActions: true,
      containerColor: containerColor,
      shadowColor: scheme.shadow,
      shape: appBarTheme.shape(bar.shapeFamily),
    );
  }

  Widget _actionSliverSurface({
    required Color bg,
    required double elevation,
    required MorphAppBarTheme appBarTheme,
    required MorphColorScheme scheme,
    required double push,
    required _MorphBarMotion motion,
    required Widget body,
  }) {
    return Material(
      color: bg,
      elevation: elevation,
      shadowColor: scheme.shadow,
      surfaceTintColor: const Color(0x00000000),
      shape: appBarTheme.shape(bar.shapeFamily),
      child: _morphClipSliding(
        push: push,
        visual: math.max(motion.painted, push),
        child: body,
      ),
    );
  }

  Widget _actionSliverRow({
    required MorphAppBarTheme appBarTheme,
    required MorphAppBarMetrics metrics,
    required MorphColorScheme scheme,
    required _MorphBarMotion motion,
    required Widget? leading,
  }) {
    return Positioned(
      top: appBarTheme.flexibleTopPadding,
      left: 0,
      right: 0,
      height: appBarTheme.actionRowHeight,
      child: _MorphActionRow(
        contentPadding: metrics.contentPadding,
        actionRow: appBarTheme.actionRowHeight,
        hide: motion.titleHide,
        tonal: appBarTheme.actionsTonalColor(scheme),
        leadingColor: bar.foregroundColor ?? appBarTheme.leadingColor(scheme),
        trailingColor: appBarTheme.trailingColor(scheme),
        iconSize: metrics.iconSize,
        leading: leading,
        actions: bar.actions,
      ),
    );
  }
}
