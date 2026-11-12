import 'dart:ui' show SemanticsRole;

import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import '../../foundations/interaction/morph_motion.dart';
import 'controllers/morph_tabs_controller.dart';

/// Horizontal body for `MorphTabs`.
///
/// A sideways swipe moves the pages with the finger and reports the page that
/// becomes dominant through [onTabSelected] (once per change of the dominant
/// page, never per frame). Vertical scrolling inside a child is left to that
/// child.
///
/// Share a [MorphTabsController] with the bar to link them: while the pages
/// move (drag, fling, animated change) this view publishes its fractional page
/// position and the bar's indicator follows it, so both show the same
/// progress. This view is then the single driver of that motion; the bar does
/// not run a competing animation.
///
/// A change of [selectedIndex] animates the pages over [duration] with
/// [curve]. A distant destination travels directly: callbacks and tab colours
/// are never produced for the pages in between. With reduced motion the pages
/// jump. If the parent keeps a selection different from the page the user
/// settled on, the pages return to the selected one.
class MorphTabsView extends StatefulWidget {
  /// Creates a swipeable tab body.
  const MorphTabsView({
    required this.selectedIndex,
    required this.onTabSelected,
    required this.children,
    this.controller,
    this.duration = MorphMotion.medium2,
    this.curve = MorphMotion.enter,
    super.key,
  }) : assert(children.length > 0, 'A tab view needs a child.');

  /// Page that should be showing.
  final int selectedIndex;

  /// Called when the dominant page changes because of a swipe.
  final ValueChanged<int> onTabSelected;

  /// One child per tab, in tab order.
  final List<Widget> children;

  /// Controller shared with the `MorphTabs` bar.
  final MorphTabsController? controller;

  /// Duration of an animated change of [selectedIndex].
  final Duration duration;

  /// Curve of an animated change of [selectedIndex].
  final Curve curve;

  @override
  State<MorphTabsView> createState() => _MorphTabsViewState();
}

class _MorphTabsViewState extends State<MorphTabsView> {
  late final PageController _page;
  MorphTabsController? _controller;

  /// Programmatic travel in progress.
  int? _travelFrom;
  int? _travelTo;
  int _generation = 0;

  /// A finger (or its fling) is moving the pages.
  bool _user = false;
  bool _suppress = false;

  @override
  void initState() {
    super.initState();
    _page = PageController(initialPage: _index);
    _page.addListener(_onScroll);
    _controller = widget.controller;
  }

  @override
  void didUpdateWidget(covariant MorphTabsView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.setPageDriving(false);
      oldWidget.controller?.reportPosition(null);
      _controller = widget.controller;
    }
    if (oldWidget.selectedIndex == widget.selectedIndex) {
      return;
    }
    if (_user) {
      // The finger owns the pages; the parent already follows them.
      return;
    }
    final int current = _currentPage;
    if (current == _index && _travelTo == null) {
      return;
    }
    if (_travelTo == _index) {
      return;
    }
    _goTo(_index);
  }

  @override
  void dispose() {
    _generation++;
    _controller?.setPageDriving(false);
    final MorphTabsController? controller = _controller;
    if (controller != null) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        controller.reportPosition(null);
      });
    }
    _page.removeListener(_onScroll);
    _page.dispose();
    super.dispose();
  }

  int get _index {
    if (widget.children.isEmpty) {
      return 0;
    }
    return widget.selectedIndex.clamp(0, widget.children.length - 1);
  }

  int get _currentPage {
    return _page.hasClients ? (_page.page?.round() ?? _index) : _index;
  }

  void _goTo(int target) {
    final int from = _currentPage;
    final int generation = ++_generation;
    if (MorphMotion.reduceMotionOf(context) ||
        widget.duration == Duration.zero) {
      _travelFrom = null;
      _travelTo = null;
      _suppress = true;
      _page.jumpToPage(target);
      _suppress = false;
      _controller?.setPageDriving(false);
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (mounted && generation == _generation) {
          _controller?.reportPosition(null);
        }
      });
      return;
    }
    _travelFrom = from;
    _travelTo = target;
    _controller?.setPageDriving(true);
    _page
        .animateToPage(target, duration: widget.duration, curve: widget.curve)
        .whenComplete(() {
          if (!mounted || generation != _generation) {
            return;
          }
          _travelFrom = null;
          _travelTo = null;
          _controller?.setPageDriving(false);
          _controller?.reportPosition(null);
        });
  }

  void _onScroll() {
    if (_suppress || !_page.hasClients) {
      return;
    }
    final double? page = _page.page;
    final MorphTabsController? controller = _controller;
    if (page == null || controller == null) {
      return;
    }
    final int? from = _travelFrom;
    final int? to = _travelTo;
    controller.reportPosition(
      from != null && to != null && !_user
          ? MorphTabsPosition(page, from: from, to: to)
          : MorphTabsPosition(page),
    );
  }

  bool _onNotification(ScrollNotification notification) {
    if (notification.depth != 0 ||
        notification.metrics.axis != Axis.horizontal) {
      return false;
    }
    if (notification is ScrollUpdateNotification &&
        notification.dragDetails != null &&
        !_user) {
      _beginUser();
    } else if (notification is ScrollStartNotification &&
        notification.dragDetails != null &&
        !_user) {
      _beginUser();
    } else if (notification is ScrollEndNotification) {
      _endScroll();
    }
    return false;
  }

  void _beginUser() {
    // A finger interrupts any travel: the pages are the truth from here on.
    _user = true;
    _travelFrom = null;
    _travelTo = null;
    _generation++;
    _controller?.setPageDriving(true);
  }

  void _endScroll() {
    if (_travelTo != null && !_user) {
      return;
    }
    _user = false;
    _controller?.setPageDriving(false);
    _controller?.reportPosition(null);
    // A controlled parent may keep a selection other than the settled page.
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _user || _travelTo != null) {
        return;
      }
      if (_currentPage != _index) {
        _goTo(_index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final MorphTabsController? controller = widget.controller;
    return NotificationListener<ScrollNotification>(
      onNotification: _onNotification,
      child: PageView(
        controller: _page,
        onPageChanged: (int index) {
          // Pages crossed while travelling to a distant tab are not selections.
          if (_travelTo != null && !_user) {
            return;
          }
          if (index != widget.selectedIndex) {
            widget.onTabSelected(index);
          }
        },
        children: <Widget>[
          for (var i = 0; i < widget.children.length; i++)
            Semantics(
              role: SemanticsRole.tabPanel,
              identifier: controller?.panelIdentifier(i),
              child: widget.children[i],
            ),
        ],
      ),
    );
  }
}
