import 'package:flutter/widgets.dart';

/// Content region of a side sheet.
///
/// It has its own primary scroll controller, so it scrolls vertically and
/// independently of the page, and it never scrolls horizontally.
class MorphSideSheetBody extends StatefulWidget {
  /// MorphSideSheetBody.
  const MorphSideSheetBody({
    required this.child,
    this.scrollable = false,
    super.key,
  });

  /// Sheet content.
  final Widget child;

  /// Wraps [child] in a vertical scroll view.
  final bool scrollable;

  @override
  State<MorphSideSheetBody> createState() => _MorphSideSheetBodyState();
}

class _MorphSideSheetBodyState extends State<MorphSideSheetBody> {
  final ScrollController _scroll = ScrollController();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: PrimaryScrollController(
        controller: _scroll,
        automaticallyInheritForPlatforms: TargetPlatform.values.toSet(),
        child: widget.scrollable
            ? SingleChildScrollView(primary: true, child: widget.child)
            : widget.child,
      ),
    );
  }
}
