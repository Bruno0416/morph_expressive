import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/rendering.dart' show ScrollDirection;
import 'package:flutter/widgets.dart';
import 'package:material_ui/material_ui.dart'
    show Material, MaterialType, Icon, Scaffold;
import 'package:motor/motor.dart';

import '../../foundations/foundations.dart';
import '../../foundations/interaction/morph_motion_controller.dart';
import '../app_bars/morph_app_bars.dart' show MorphAppBar;
import '../icon_buttons/morph_icon_buttons.dart';
import '../lists/utils/morph_measure_size.dart';
import '../refresh_indicator/morph_refresh_indicator.dart';
import 'morph_navigation_bar.dart';
import 'components/morph_navigation_scroll_activity.dart';

/// Native body/bar composition with scroll visibility and optional refresh.
///
/// The body builder receives a controller and the bottom clearance to apply
/// to its *scroll content*. This keeps content visible behind a glass bar
/// without letting the last row disappear beneath it. Scroll notifications
/// also work with descendant scrollables that cannot use that controller.
/// Docked bars reserve their own height and stay visible.
///
/// Supports the default, `.morph()`, and `.expressive()` navigation bars.
/// The optional [MorphNavigationBar.glass] controls the surface only; it does
/// not affect scroll handling or pull-to-refresh. Nested vertical scrollables
/// are selected automatically per drag, including tabbed NestedScrollViews.
/// Without [onRefresh], no
/// [MorphRefreshIndicator] is inserted in the widget tree.
class MorphNavigationBarHost extends StatefulWidget {
  const MorphNavigationBarHost({
    required this.bar,
    required this.body,
    this.scrollController,
    this.onRefresh,
    this.refreshController,
    this.refreshIndicatorEdgeOffset,
    this.hideOnScroll = true,
    this.scrollThreshold = 12,
    this.showOnScrollEnd = false,
    this.showBackToTop = true,
    this.backToTopIcon,
    this.backToTopLabel,
    this.floatingMargin = const EdgeInsets.fromLTRB(12, 0, 12, 12),
    this.maxBarWidth = 600,
    this.visibilitySpring = MorphMotion.expressiveSpatialDefault,
    this.onVisibilityChanged,
    super.key,
  }) : assert(
         refreshIndicatorEdgeOffset == null || refreshIndicatorEdgeOffset >= 0,
       ),
       assert(scrollThreshold >= 0),
       assert(maxBarWidth > 0);

  final MorphNavigationBar bar;
  final Widget Function(
    BuildContext context,
    ScrollController controller,
    EdgeInsets contentPadding,
  )
  body;
  final ScrollController? scrollController;
  final Future<void> Function()? onRefresh;
  final MorphRefreshIndicatorController? refreshController;

  /// Distance from the body's top edge to the refresh spinner's scroll edge.
  ///
  /// By default this is zero, unless the nearest [Scaffold] extends its body
  /// behind a glass [MorphAppBar]. For that composition it automatically
  /// includes the AppBar's preferred height and Scaffold's top inset, keeping
  /// the loading indicator below the title while the list scrolls behind it.
  /// Set an explicit nonnegative value to override the automatic placement.
  final double? refreshIndicatorEdgeOffset;
  final bool hideOnScroll;
  final double scrollThreshold;
  final bool showOnScrollEnd;
  final bool showBackToTop;
  final Widget? backToTopIcon;

  /// Localized tooltip/semantics for the optional return-to-start action.
  final String? backToTopLabel;
  final EdgeInsets floatingMargin;
  final double maxBarWidth;
  final MorphSpring visibilitySpring;
  final ValueChanged<bool>? onVisibilityChanged;

  @override
  State<MorphNavigationBarHost> createState() => _MorphNavigationBarHostState();
}

class _MorphNavigationBarHostState extends State<MorphNavigationBarHost>
    with SingleTickerProviderStateMixin {
  late final SingleMotionController _visibility;
  ScrollController? _ownedScroll;
  final FocusNode _barFocus = FocusNode(canRequestFocus: false);
  final ValueNotifier<bool> _scrollActivity = ValueNotifier(false);
  bool _bodyScrolling = false;
  ScrollController get _scroll =>
      widget.scrollController ?? (_ownedScroll ??= ScrollController());
  bool _visible = true;
  bool _refreshing = false;
  double _travel = 0;
  double _barHeight = 80;
  ScrollDirection _direction = ScrollDirection.idle;

  // Visibility must observe nested vertical scrollables too. Keep a single
  // source per motion so outer/inner updates do not double-count travel.
  BuildContext? _visibilityScrollSource;
  int _visibilityScrollDepth = -1;
  bool _visibilityScrollMoved = false;

  // The scrollable whose vertical drag currently drives pull-to-refresh.
  // Notification.depth is not a stable identity in nested scroll trees.
  BuildContext? _refreshScrollSource;
  int _refreshScrollDepth = -1;
  bool _refreshDragMoved = false;

  @override
  void initState() {
    super.initState();
    _visibility = MorphMotionController(
      motion: MorphMotion.springMotion(widget.visibilitySpring),
      vsync: this,
      initialValue: 1,
    )..addListener(_updateGlassActivity);
  }

  @override
  void didUpdateWidget(covariant MorphNavigationBarHost oldWidget) {
    super.didUpdateWidget(oldWidget);
    _visibility.motion = MorphMotion.springMotion(widget.visibilitySpring);
    if (!widget.hideOnScroll ||
        !widget.bar.floating ||
        oldWidget.scrollController != widget.scrollController) {
      _setVisible(true);
      _travel = 0;
      _direction = ScrollDirection.idle;
      _clearVisibilityScrollSource();
      if (oldWidget.scrollController != widget.scrollController) {
        _bodyScrolling = false;
        _updateGlassActivity();
      }
    }
    if (widget.onRefresh == null ||
        oldWidget.scrollController != widget.scrollController) {
      _clearRefreshScrollSource();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.accessibleNavigationOf(context)) _setVisible(true);
  }

  // Only the busy/idle transitions rebuild the glass. Never notify per pixel
  // or per spring tick, which would repeatedly recreate the backdrop layer.
  void _updateGlassActivity() {
    final glass = widget.bar.glass;
    // Only the host's own content scroll and bar motion control its blur.
    // An enclosing gallery may scroll without changing this bar's appearance.
    // On native, restore blur early during an upward reveal even while the
    // host's content is still scrolling. Web waits for local activity to end.
    final restoreOnReveal =
        !kIsWeb &&
        glass != null &&
        _visible &&
        _direction == ScrollDirection.forward &&
        _visibility.value >= glass.blurRevealProgress;
    final busy =
        !restoreOnReveal && (_bodyScrolling || _visibility.isAnimating);
    if (_scrollActivity.value != busy) _scrollActivity.value = busy;
  }

  @override
  void dispose() {
    _visibility.removeListener(_updateGlassActivity);
    _visibility.dispose();
    _ownedScroll?.dispose();
    _barFocus.dispose();
    _scrollActivity.dispose();
    super.dispose();
  }

  void _setVisible(bool value) {
    if (_visible == value) return;
    if (!value &&
        (_refreshing ||
            _barFocus.hasFocus ||
            MediaQuery.accessibleNavigationOf(context))) {
      return;
    }
    setState(() => _visible = value);
    _visibility.animateTo(value ? 1 : 0);
    _updateGlassActivity();
    widget.onVisibilityChanged?.call(value);
  }

  void _clearVisibilityScrollSource() {
    _visibilityScrollSource = null;
    _visibilityScrollDepth = -1;
    _visibilityScrollMoved = false;
  }

  // NestedScrollView and PageView can route vertical updates through a deeper
  // viewport, especially during diagonal drags. Follow a single vertical
  // origin, preferring a deeper one only once it actually moves; this avoids
  // accumulating the same physical gesture from both parent and child.
  bool _acceptVisibilityScroll(ScrollNotification notification) {
    if (notification.metrics.axis != Axis.vertical) return false;
    final origin = notification.context;
    if (origin == null) return notification.depth == 0;

    final moving =
        notification is ScrollUpdateNotification &&
        (notification.scrollDelta ?? 0) != 0 &&
        !notification.metrics.outOfRange;
    final source = _visibilityScrollSource;
    if (source == null) {
      if (notification is ScrollEndNotification) return false;
      _visibilityScrollSource = origin;
      _visibilityScrollDepth = notification.depth;
    } else if (!identical(source, origin)) {
      // A moving child may take over after the outer header collapses.
      // A fresh drag can also select a sibling tab at the same depth.
      final newPeerDrag =
          notification is ScrollStartNotification &&
          notification.dragDetails != null &&
          notification.depth == _visibilityScrollDepth;
      final preferChild =
          (moving &&
              (notification.depth > _visibilityScrollDepth ||
                  !_visibilityScrollMoved)) ||
          newPeerDrag;
      if (!preferChild) return false;
      _visibilityScrollSource = origin;
      _visibilityScrollDepth = notification.depth;
      _visibilityScrollMoved = false;
      _travel = 0;
      _direction = ScrollDirection.idle;
    }
    if (moving) _visibilityScrollMoved = true;
    return true;
  }

  bool _onScroll(ScrollNotification notification) {
    if (!_acceptVisibilityScroll(notification)) return false;
    if (notification is ScrollStartNotification) {
      _bodyScrolling = true;
      _updateGlassActivity();
    } else if (notification is ScrollEndNotification) {
      _bodyScrolling = false;
      _updateGlassActivity();
      _clearVisibilityScrollSource();
    }
    if (notification.metrics.pixels <= notification.metrics.minScrollExtent) {
      _travel = 0;
      if (_outerAtRefreshEdge()) _setVisible(true);
      return false;
    }
    if (!widget.bar.floating || !widget.hideOnScroll || _refreshing) {
      return false;
    }
    if (notification is ScrollStartNotification) {
      _travel = 0;
      _direction = ScrollDirection.idle;
    } else if (notification is ScrollUpdateNotification) {
      // Scroll deltas already include the axis direction of reverse lists.
      final raw = notification.scrollDelta ?? 0;
      final reverse = notification.metrics.axisDirection == AxisDirection.up;
      final delta = reverse ? -raw : raw;
      final direction = delta > 0
          ? ScrollDirection.reverse
          : ScrollDirection.forward;
      if (delta == 0 || notification.metrics.outOfRange) return false;
      if (direction != _direction) {
        _direction = direction;
        _travel = 0;
      }
      _travel += delta.abs();
      if (_travel >= widget.scrollThreshold) {
        _setVisible(direction == ScrollDirection.forward);
      }
    } else if (notification is ScrollEndNotification &&
        widget.showOnScrollEnd) {
      _setVisible(true);
    }
    return false;
  }

  void _clearRefreshScrollSource() {
    _refreshScrollSource = null;
    _refreshScrollDepth = -1;
    _refreshDragMoved = false;
  }

  static bool _atLeadingEdge(ScrollMetrics metrics) =>
      switch (metrics.axisDirection) {
        AxisDirection.down => metrics.extentBefore == 0,
        AxisDirection.up => metrics.extentAfter == 0,
        AxisDirection.left || AxisDirection.right => false,
      };

  // NestedScrollView's outer controller may still be collapsing or expanding
  // its header while an inner tab reports extentBefore == 0. Requiring the
  // outer position to reach its leading edge prevents premature refreshes.
  bool _outerAtRefreshEdge() {
    if (!_scroll.hasClients) return true;
    return _scroll.positions.every(_atLeadingEdge);
  }

  /// Keeps one vertical notification source for the lifetime of a pull.
  ///
  /// The first eligible child drag wins. If an outer scroll starts first,
  /// a deeper child may take over until drag updates actually begin. This
  /// avoids processing a parent's ScrollEnd as the child's release, or
  /// mixing the horizontal PageView with the active inner CustomScrollView.
  bool _onRefreshScrollNotification(ScrollNotification notification) {
    if (notification.metrics.axis != Axis.vertical) return false;
    final origin = notification.context;
    if (origin == null) return defaultScrollNotificationPredicate(notification);

    final startsDrag =
        (notification is ScrollStartNotification &&
            notification.dragDetails != null) ||
        (notification is OverscrollNotification &&
            notification.dragDetails != null);
    final source = _refreshScrollSource;
    if (source != null && !identical(source, origin)) {
      final canPreferChild =
          !_refreshDragMoved &&
          startsDrag &&
          notification.depth > _refreshScrollDepth &&
          _atLeadingEdge(notification.metrics) &&
          _outerAtRefreshEdge();
      if (!canPreferChild) return false;
    } else if (source == null) {
      if (!startsDrag ||
          !_atLeadingEdge(notification.metrics) ||
          !_outerAtRefreshEdge()) {
        return false;
      }
    }

    if (!identical(source, origin)) {
      _refreshScrollSource = origin;
      _refreshScrollDepth = notification.depth;
      _refreshDragMoved = false;
    }
    if ((notification is ScrollUpdateNotification &&
            notification.dragDetails != null) ||
        (notification is OverscrollNotification &&
            notification.dragDetails != null)) {
      _refreshDragMoved = true;
    }
    if (notification is ScrollEndNotification) {
      _clearRefreshScrollSource();
    }
    return true;
  }

  Future<void> _refresh() async {
    if (_refreshing) return;
    _setVisible(true);
    _refreshing = true;
    try {
      await widget.onRefresh?.call();
    } finally {
      _refreshing = false;
      if (mounted) _setVisible(true);
    }
  }

  Future<void> _backToTop() async {
    _setVisible(true);
    if (!_scroll.hasClients || _scroll.positions.length != 1) return;
    final target = _scroll.position.minScrollExtent;
    if (MorphMotion.reduceMotionOf(context)) {
      _scroll.jumpTo(target);
    } else {
      await _scroll.animateTo(
        target,
        duration: MorphMotion.long2,
        curve: MorphMotion.standard,
      );
    }
  }

  double _resolvedRefreshEdgeOffset(BuildContext context) {
    final override = widget.refreshIndicatorEdgeOffset;
    if (override != null) return override;

    final scaffoldState = Scaffold.maybeOf(context);
    if (scaffoldState == null) return 0;
    final scaffold = scaffoldState.widget;
    if (!scaffold.extendBodyBehindAppBar) return 0;

    final appBar = scaffold.appBar;
    if (appBar is! MorphAppBar || appBar.glass == null) return 0;

    // Scaffold adds top padding when primary, independent of the AppBar's
    // own safeArea setting. Read its MediaQuery rather than the body's, which
    // Scaffold may have stripped for edge-to-edge layouts.
    final topInset = scaffold.primary
        ? MediaQuery.paddingOf(scaffoldState.context).top
        : 0.0;
    return appBar.preferredSize.height + topInset;
  }

  @override
  Widget build(BuildContext context) {
    final floating = widget.bar.floating;
    final inset = MediaQuery.paddingOf(context).bottom;
    final keyboard = MediaQuery.viewInsetsOf(context).bottom > 0;
    final margin = widget.floatingMargin;
    final padding = EdgeInsets.only(
      bottom: floating ? _barHeight + margin.bottom + inset + 12 : 0,
    );
    Widget body = widget.body(context, _scroll, padding);
    if (widget.onRefresh != null) {
      body = MorphRefreshIndicator(
        controller: widget.refreshController,
        notificationPredicate: _onRefreshScrollNotification,
        edgeOffset: _resolvedRefreshEdgeOffset(context),
        onRefresh: _refresh,
        onStatusChange: (status) {
          if (status != null) _setVisible(true);
        },
        child: body,
      );
    }
    body = NotificationListener<ScrollNotification>(
      onNotification: _onScroll,
      child: body,
    );
    final bar = Focus(
      focusNode: _barFocus,
      onFocusChange: (focused) {
        if (focused) _setVisible(true);
      },
      child: MorphNavigationScrollActivity(
        activity: _scrollActivity,
        child: widget.bar,
      ),
    );
    if (!floating) {
      return Column(
        children: [
          Expanded(child: body),
          bar,
        ],
      );
    }
    return Stack(
      fit: StackFit.expand,
      children: [
        RepaintBoundary(child: body),
        if (!keyboard)
          Positioned(
            left: margin.left,
            right: margin.right,
            bottom: margin.bottom + inset,
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: widget.maxBarWidth),
                child: AnimatedBuilder(
                  animation: _visibility,
                  builder: (context, child) {
                    final t = _visibility.value.clamp(0.0, 1.0);
                    final hidden = !_visible && t < 0.001;
                    return IgnorePointer(
                      ignoring: !_visible,
                      child: ExcludeFocus(
                        excluding: !_visible,
                        child: ExcludeSemantics(
                          excluding: !_visible,
                          child: Offstage(
                            offstage: hidden,
                            child: TickerMode(
                              enabled: !hidden,
                              child: Transform.translate(
                                offset: Offset(
                                  0,
                                  (1 - t) *
                                      (_barHeight + margin.bottom + inset),
                                ),
                                child: child,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  child: MorphMeasureSize(
                    onChange: (size) {
                      if (mounted && (size.height - _barHeight).abs() > 0.5) {
                        setState(() => _barHeight = size.height);
                      }
                    },
                    child: bar,
                  ),
                ),
              ),
            ),
          ),
        if (!keyboard && !_visible && widget.showBackToTop)
          Positioned(
            left: margin.left,
            right: margin.right,
            bottom: margin.bottom + inset,
            child: Center(
              child: Material(
                type: MaterialType.transparency,
                child: MorphIconButton(
                  tooltip: widget.backToTopLabel ?? 'Scroll to top',
                  semanticLabel: widget.backToTopLabel ?? 'Scroll to top',
                  onPressed: _backToTop,
                  icon:
                      widget.backToTopIcon ??
                      const Icon(MorphIcons.arrow_drop_up),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
