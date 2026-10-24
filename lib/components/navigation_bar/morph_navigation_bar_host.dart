import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/rendering.dart' show ScrollDirection;
import 'package:flutter/widgets.dart';
import 'package:material_ui/material_ui.dart' show Material, MaterialType, Icon;
import 'package:motor/motor.dart';

import '../../foundations/foundations.dart';
import '../../foundations/interaction/morph_motion_controller.dart';
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
class MorphNavigationBarHost extends StatefulWidget {
  const MorphNavigationBarHost({
    required this.bar,
    required this.body,
    this.scrollController,
    this.onRefresh,
    this.refreshController,
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
  }) : assert(scrollThreshold >= 0),
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
      if (oldWidget.scrollController != widget.scrollController) {
        _bodyScrolling = false;
        _updateGlassActivity();
      }
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

  bool _onScroll(ScrollNotification notification) {
    if (notification.depth != 0 || notification.metrics.axis != Axis.vertical) {
      return false;
    }
    if (notification is ScrollStartNotification) {
      _bodyScrolling = true;
      _updateGlassActivity();
    } else if (notification is ScrollEndNotification) {
      _bodyScrolling = false;
      _updateGlassActivity();
    }
    if (notification.metrics.pixels <= notification.metrics.minScrollExtent) {
      _travel = 0;
      _setVisible(true);
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
