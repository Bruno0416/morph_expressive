part of '../morph_app_bars.dart';

/// Pinned sliver. One title block moves inside the bar as it collapses.
class _MorphSliverAppBar extends StatefulWidget {
  const _MorphSliverAppBar({required this.bar});

  final MorphAppBar bar;

  @override
  State<_MorphSliverAppBar> createState() => _MorphSliverAppBarState();
}

class _MorphSliverAppBarState extends State<_MorphSliverAppBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _visibility;
  ScrollPosition? _position;
  MorphAppBarController? _bound;
  bool _follow = true;
  double _offset = 0;
  double _lastPixels = 0;
  double _collapsed = 0;
  double _expanded = 0;

  MorphAppBar get bar => widget.bar;

  @override
  void initState() {
    super.initState();
    _visibility = AnimationController(
      vsync: this,
      value: 1,
      duration: _kAppBarTravel,
    )..addListener(_onVisibility);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _visibility.duration = MorphMotion.durationOf(context, _kAppBarTravel);
    if (MorphMotion.reduceMotionOf(context) && _visibility.isAnimating) {
      final target = _visibility.status == AnimationStatus.reverse ? 0.0 : 1.0;
      _visibility.stop(canceled: false);
      _visibility.value = target;
    }
    _bindScrollable();
    _bindController();
  }

  @override
  void didUpdateWidget(_MorphSliverAppBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.bar.controller != bar.controller) {
      _bindController();
    }
  }

  @override
  void dispose() {
    _position?.removeListener(_onScroll);
    if (_bound == bar.controller) {
      bar.controller?.detach();
    }
    _visibility
      ..removeListener(_onVisibility)
      ..dispose();
    super.dispose();
  }

  void _onVisibility() {
    if (mounted) {
      setState(() {});
    }
    _publish();
  }

  void _bindScrollable() {
    final ScrollPosition? next = Scrollable.maybeOf(context)?.position;
    if (next == _position) {
      return;
    }
    _position?.removeListener(_onScroll);
    _position = next;
    _lastPixels = next?.pixels ?? 0;
    _offset = _lastPixels;
    _position?.addListener(_onScroll);
  }

  void _bindController() {
    final MorphAppBarController? next = bar.controller;
    if (_bound == next) {
      _publish();
      return;
    }
    _bound?.detach();
    _bound = next;
    next?.attach(
      collapsed: _collapsedNow,
      visible: _visibleNow,
      expand: _expand,
      collapse: _collapse,
      show: _show,
      hide: _hide,
      followScroll: _resumeScroll,
    );
  }

  bool get _visibleNow {
    final MorphAppBarHideMode mode = bar._effectiveHideMode;
    if (mode == MorphAppBarHideMode.actions) {
      return true;
    }
    if (_follow) {
      return mode == MorphAppBarHideMode.none || _offset < _expanded - 0.5;
    }
    return _visibility.value > 0.01;
  }

  bool get _collapsedNow {
    if (_expanded <= _collapsed + 0.5) {
      return true;
    }
    return _offset >= _expanded - _collapsed - 0.5;
  }

  void _publish() {
    _bound?.update(collapsed: _collapsedNow, visible: _visibleNow);
  }

  void _onScroll() {
    final ScrollPosition? position = _position;
    if (position == null || !position.hasPixels) {
      return;
    }
    final double pixels = position.pixels;
    final double delta = pixels - _lastPixels;
    final underChanged = (_lastPixels > 0) != (pixels > 0);
    _lastPixels = pixels;
    _offset = pixels;
    _publish();
    _maybeRebuildAfterScroll(underChanged: underChanged, delta: delta);
  }

  void _maybeRebuildAfterScroll({
    required bool underChanged,
    required double delta,
  }) {
    // The persistent header already rebuilds from its shrink offset every
    // frame; rebuilding the whole sliver as well would build it twice. Only
    // the actions band is sized from [_offset] here, so only it follows every
    // scrolled pixel.
    final follows = bar._effectiveHideMode == MorphAppBarHideMode.actions;
    if (mounted && (underChanged || (follows && delta != 0))) {
      setState(() {});
    }
  }

  Future<void> _expand() {
    final ScrollPosition? position = _position;
    if (position == null || !position.hasPixels) {
      return Future<void>.value();
    }
    if (MorphMotion.reduceMotionOf(context)) {
      position.jumpTo(0);
      return Future<void>.value();
    }
    return position.animateTo(
      0,
      duration: _kAppBarTravel,
      curve: MorphMotion.enter,
    );
  }

  Future<void> _collapse() {
    final ScrollPosition? position = _position;
    if (position == null || !position.hasPixels) {
      return Future<void>.value();
    }
    final double target = (_expanded - _collapsed).clamp(
      0.0,
      position.maxScrollExtent,
    );
    if (MorphMotion.reduceMotionOf(context)) {
      position.jumpTo(target);
      return Future<void>.value();
    }
    return position.animateTo(
      target,
      duration: _kAppBarTravel,
      curve: MorphMotion.enter,
    );
  }

  Future<void> _show() {
    _follow = false;
    return _visibility.forward();
  }

  Future<void> _hide() {
    _follow = false;
    return _visibility.reverse();
  }

  /// Scroll hiding is pure geometry (the bar scrolls with the content), so
  /// [_visibility] only needs to settle back to fully shown.
  Future<void> _resumeScroll() {
    _follow = true;
    return _visibility.forward();
  }

  @override
  Widget build(BuildContext context) {
    final theme = MorphTheme.of(context);
    final appBarTheme = theme.appBarTheme;
    final scheme = theme.colorScheme;
    final metrics = appBarTheme.metrics(bar.density);
    final hasSubtitle = bar.subtitle != null || bar.subtitleText != null;
    _collapsed = metrics.collapsedHeight;
    _expanded = metrics.expandedHeight(bar.variant, hasSubtitle: hasSubtitle);
    final motion = _MorphBarMotion(
      offset: _offset,
      collapsed: _collapsed,
      expanded: _expanded,
      shown: _visibility.value,
      mode: bar._effectiveHideMode,
      manual: !_follow,
      glued: true,
    );
    final double top = MediaQuery.paddingOf(context).top;
    // Following scroll, the whole bar is ordinary scroll extent: the header
    // shrinks by exactly the scrolled distance, so the content below it (and
    // the bar's edge) move together at the scroll rate.
    final bool sweep = _follow && motion.entire;
    final double minContent = motion.entire
        ? (sweep ? 0.0 : _collapsed * motion.shown)
        : _collapsed;
    final double maxContent = motion.entire
        ? math.max(_expanded * motion.shown, minContent)
        : _expanded;
    if (_bound != null &&
        (_collapsedNow != _bound!.isCollapsed ||
            _visibleNow != _bound!.isVisible)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _publish();
        }
      });
    }

    final Widget sliver = motion.actions
        ? _actionSliver(theme, appBarTheme, scheme, metrics, motion, top)
        : SliverPersistentHeader(
            pinned: bar.pinned,
            floating: bar.floating,
            delegate: _MorphAppBarDelegate(
              minExtent: top + minContent,
              maxExtent: top + math.max(maxContent, minContent),
              snap: bar.snap && bar.floating,
              vsync: this,
              builder:
                  (
                    BuildContext context,
                    double shrinkOffset, {
                    required bool overlaps,
                  }) {
                    final double current = math.max(
                      top + minContent,
                      top + math.max(maxContent, minContent) - shrinkOffset,
                    );
                    final double range = sweep
                        ? math.max(0, _expanded - _collapsed)
                        : math.max(0, maxContent - minContent);
                    final double expand = range <= 0.5
                        ? 0
                        : (1 - (shrinkOffset / range).clamp(0.0, 1.0));
                    final double titleExpand = motion.actions
                        ? expand * motion.shown
                        : expand;
                    // A bar that hides on scroll keeps its resting look.
                    final bool under =
                        bar._effectiveHideMode == MorphAppBarHideMode.none &&
                        (shrinkOffset > 0 || overlaps || _offset > 0);
                    final Color bg = _morphBarColor(
                      bar: bar,
                      theme: appBarTheme,
                      scheme: scheme,
                      under: under,
                    );
                    final double elevation = under
                        ? metrics.scrolledElevation
                        : metrics.elevation;
                    final double contentSlot = math.max(0, current - top);
                    final double painted = sweep
                        ? math.max(_collapsed, contentSlot)
                        : motion.entire && motion.shown > 0.001
                        ? contentSlot / motion.shown
                        : contentSlot;
                    final Widget body = _headerBody(
                      context,
                      theme,
                      appBarTheme,
                      scheme,
                      metrics,
                      motion,
                      titleExpand,
                      bg,
                    );
                    final Widget inner = ClipRect(
                      child: motion.entire
                          ? OverflowBox(
                              alignment: Alignment.bottomCenter,
                              minHeight: painted,
                              maxHeight: painted,
                              child: SizedBox(height: painted, child: body),
                            )
                          : body,
                    );
                    final Widget padded = SizedBox(
                      height: current,
                      child: Padding(
                        padding: EdgeInsets.only(top: top),
                        child: inner,
                      ),
                    );
                    return _MorphScrolledUnder(
                      scrolledUnder: under,
                      child: Material(
                        animationDuration: MorphMotion.durationOf(
                          context,
                          MorphMotion.short4,
                        ),
                        color: bg,
                        elevation: elevation,
                        shadowColor: scheme.shadow,
                        surfaceTintColor: const Color(0x00000000),
                        shape: appBarTheme.shape(bar.shapeFamily),
                        child: padded,
                      ),
                    );
                  },
            ),
          );
    if (bar.semanticLabel == null) {
      return sliver;
    }
    return MorphSliverSemantic(label: bar.semanticLabel!, child: sliver);
  }

  /// Title block and action row for the persistent header. [context] is
  /// the header builder's own context.
  Widget _headerBody(
    BuildContext context,
    MorphThemeData theme,
    MorphAppBarTheme appBarTheme,
    MorphColorScheme scheme,
    MorphAppBarMetrics metrics,
    _MorphBarMotion motion,
    double titleExpand,
    Color bg,
  ) {
    return _MorphBarBody(
      expand: titleExpand,
      topPadding: appBarTheme.flexibleTopPadding,
      actionRow: appBarTheme.actionRowHeight,
      bottomPadding: metrics.flexibleBottomPadding,
      titleInset: metrics.titleInset,
      contentPadding: metrics.contentPadding,
      centerTitle: bar.centerTitle,
      search: bar.title is _MorphAppBarSearchTitle,
      leading:
          bar.leading ??
          (bar.automaticallyImplyLeading
              ? _maybeBackButton(
                  context,
                  bar.foregroundColor ?? appBarTheme.leadingColor(scheme),
                )
              : null),
      actions: bar.actions,
      title: _sliverTitle(theme, appBarTheme, scheme, titleExpand),
      leadingColor: bar.foregroundColor ?? appBarTheme.leadingColor(scheme),
      trailingColor: appBarTheme.trailingColor(scheme),
      iconSize: metrics.iconSize,
      separateActions: motion.actions,
      containerColor: bg,
      shadowColor: scheme.shadow,
      shape: appBarTheme.shape(bar.shapeFamily),
    );
  }

  Widget? _sliverTitle(
    MorphThemeData theme,
    MorphAppBarTheme appBarTheme,
    MorphColorScheme scheme,
    double expand,
  ) {
    if (bar.title is _MorphAppBarSearchTitle) {
      return bar.title;
    }
    final Color titleColor =
        bar.foregroundColor ?? appBarTheme.titleColor(scheme);
    final TextStyle collapsedStyle = appBarTheme
        .titleStyle(theme.typeScale, variant: bar.variant)
        .copyWith(color: titleColor);
    final TextStyle expandedStyle = appBarTheme
        .titleStyle(theme.typeScale, collapsed: false, variant: bar.variant)
        .copyWith(color: titleColor);
    final bool wrap = expand > 0.5;
    final Widget? title = _collapsingHeadline(
      title: bar.title,
      titleText: bar.titleText,
      collapsedStyle: collapsedStyle,
      expandedStyle: expandedStyle,
      expand: expand,
      centerTitle: bar.centerTitle,
      wrap: wrap,
    );
    final Widget? subtitle = _supporting(
      subtitle: bar.subtitle,
      subtitleText: bar.subtitleText,
      style: appBarTheme
          .subtitleStyle(theme.typeScale, bar.variant)
          .copyWith(color: appBarTheme.subtitleColor(scheme)),
      centerTitle: bar.centerTitle,
      wrap: wrap,
    );
    if (title == null && subtitle == null) {
      return null;
    }
    return _MorphTitleBlock(
      title: title,
      subtitle: subtitle,
      centerTitle: bar.centerTitle,
    );
  }
}

class _MorphAppBarDelegate extends SliverPersistentHeaderDelegate {
  _MorphAppBarDelegate({
    required this.minExtent,
    required this.maxExtent,
    required this.snap,
    required this.vsync,
    required this.builder,
  });

  @override
  final double minExtent;

  @override
  final double maxExtent;

  final bool snap;

  @override
  final TickerProvider vsync;

  final Widget Function(
    BuildContext context,
    double shrinkOffset, {
    required bool overlaps,
  })
  builder;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return builder(context, shrinkOffset, overlaps: overlapsContent);
  }

  @override
  bool shouldRebuild(_MorphAppBarDelegate oldDelegate) => true;

  @override
  FloatingHeaderSnapConfiguration? get snapConfiguration {
    if (!snap) {
      return null;
    }
    return FloatingHeaderSnapConfiguration(
      curve: MorphMotion.enter,
      duration: _kAppBarTravel,
    );
  }
}
