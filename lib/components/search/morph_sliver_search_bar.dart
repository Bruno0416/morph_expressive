import 'package:flutter/rendering.dart' show FloatingHeaderSnapConfiguration;
import 'package:flutter/widgets.dart';

import '../../foundations/foundations.dart';
import 'enums/morph_search_enums.dart';
import 'morph_search_bar.dart';
import 'utils/morph_search_spring.dart';

/// Places a search bar at the top of a [CustomScrollView].
///
/// With [MorphSearchBarScrollBehavior.scrollAway] the bar scrolls away with
/// content and springs back as soon as the user scrolls toward the top.
/// With [MorphSearchBarScrollBehavior.fixed] it stays at the top.
class MorphSliverSearchBar extends StatefulWidget {
  /// MorphSliverSearchBar.
  const MorphSliverSearchBar({
    required this.child,
    this.scrollBehavior = MorphSearchBarScrollBehavior.scrollAway,
    this.padding = EdgeInsets.zero,
    this.spring = MorphMotion.expressiveSpatialDefault,
    this.height,
    super.key,
  });

  /// Usually an [MorphSearchBar] or an anchor built with one.
  final Widget child;

  /// Scroll away and reappear, or stay fixed.
  final MorphSearchBarScrollBehavior scrollBehavior;

  /// Space around [child] inside the header.
  final EdgeInsetsGeometry padding;

  /// Spring for the reappear snap.
  final MorphSpring spring;

  /// Header extent without [padding]. Defaults to the search bar height (56).
  final double? height;

  @override
  State<MorphSliverSearchBar> createState() => _MorphSliverSearchBarState();
}

class _MorphSliverSearchBarState extends State<MorphSliverSearchBar>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    final double extent =
        (widget.height ?? MorphTheme.of(context).searchBarTheme.minHeight) +
        widget.padding.vertical;
    final floating =
        widget.scrollBehavior == MorphSearchBarScrollBehavior.scrollAway;
    return SliverPersistentHeader(
      pinned: !floating,
      floating: floating,
      delegate: _MorphSliverSearchBarDelegate(
        extent: extent,
        vsync: floating ? this : null,
        snap: floating
            ? FloatingHeaderSnapConfiguration(
                curve: morphSearchSpringCurve(widget.spring),
                duration: morphSearchSpringSettle(widget.spring),
              )
            : null,
        child: Padding(padding: widget.padding, child: widget.child),
      ),
    );
  }
}

class _MorphSliverSearchBarDelegate extends SliverPersistentHeaderDelegate {
  _MorphSliverSearchBarDelegate({
    required this.extent,
    required this.vsync,
    required this.snap,
    required this.child,
  });

  final double extent;
  final Widget child;
  final FloatingHeaderSnapConfiguration? snap;

  @override
  final TickerProvider? vsync;

  @override
  double get minExtent => extent;

  @override
  double get maxExtent => extent;

  @override
  FloatingHeaderSnapConfiguration? get snapConfiguration => snap;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return ClipRect(child: Align(child: child));
  }

  @override
  bool shouldRebuild(_MorphSliverSearchBarDelegate oldDelegate) {
    return extent != oldDelegate.extent ||
        child != oldDelegate.child ||
        vsync != oldDelegate.vsync ||
        snap?.duration != oldDelegate.snap?.duration;
  }
}
