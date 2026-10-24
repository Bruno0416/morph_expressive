import 'package:flutter/widgets.dart';

import '../../foundations/interaction/morph_motion.dart';

/// Horizontal body for `MorphTabs`.
///
/// A sideways swipe settles on the next child and reports it through
/// [onTabSelected]. Vertical scrolling inside a child is left to that child.
class MorphTabsView extends StatefulWidget {
  /// Creates a swipeable tab body.
  const MorphTabsView({
    required this.selectedIndex,
    required this.onTabSelected,
    required this.children,
    super.key,
  }) : assert(children.length > 0, 'A tab view needs a child.');

  /// Page that should be showing.
  final int selectedIndex;

  /// Called when a swipe settles on a page.
  final ValueChanged<int> onTabSelected;

  /// One child per tab, in tab order.
  final List<Widget> children;

  @override
  State<MorphTabsView> createState() => _MorphTabsViewState();
}

class _MorphTabsViewState extends State<MorphTabsView> {
  late final PageController _page;

  @override
  void initState() {
    super.initState();
    _page = PageController(initialPage: _index);
  }

  @override
  void didUpdateWidget(covariant MorphTabsView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedIndex == widget.selectedIndex) {
      return;
    }
    final int current = _page.hasClients
        ? (_page.page?.round() ?? _index)
        : _index;
    if (current == _index) {
      return;
    }
    if (MorphMotion.reduceMotionOf(context)) {
      _page.jumpToPage(_index);
      return;
    }
    _page.animateToPage(
      _index,
      duration: MorphMotion.medium2,
      curve: MorphMotion.enter,
    );
  }

  @override
  void dispose() {
    _page.dispose();
    super.dispose();
  }

  int get _index {
    if (widget.children.isEmpty) {
      return 0;
    }
    return widget.selectedIndex.clamp(0, widget.children.length - 1);
  }

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: _page,
      children: widget.children,
      onPageChanged: (int index) {
        if (index != widget.selectedIndex) {
          widget.onTabSelected(index);
        }
      },
    );
  }
}
