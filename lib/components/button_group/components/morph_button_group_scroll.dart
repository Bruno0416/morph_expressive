part of '../morph_button_group.dart';

/// Scroll-overflow helpers for [_MorphButtonGroupState].
extension _MorphButtonGroupScroll on _MorphButtonGroupState {
  Widget _linearScrollable(BuildContext context, double spacing) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isBounded = widget.direction == Axis.horizontal
            ? constraints.hasBoundedWidth
            : constraints.hasBoundedHeight;
        final maxMain = widget.direction == Axis.horizontal
            ? constraints.maxWidth
            : constraints.maxHeight;
        final core = _buildAnimatedLinearLayout(context, spacing, maxMain);
        if (!isBounded) {
          return core;
        }
        if (widget._connected) {
          return core;
        }
        final contentFits = _scrollContentFits(maxMain, spacing);
        return SingleChildScrollView(
          key: PageStorageKey<Object>(_scrollOverflowController),
          controller: _scrollOverflowController,
          scrollDirection: widget.direction,
          primary: false,
          physics: contentFits ? const NeverScrollableScrollPhysics() : null,
          clipBehavior: contentFits ? Clip.none : Clip.hardEdge,
          child: core,
        );
      },
    );
  }

  bool _scrollContentFits(double maxMain, double spacing) {
    if (!maxMain.isFinite || !_allOverflowExtentsMeasured()) {
      return false;
    }
    return _scrollContentMainExtent(spacing) <= maxMain;
  }

  double _scrollContentMainExtent(double spacing) {
    final separator = _separatorMainExtent(spacing);
    var total = 0.0;
    for (var i = 0; i < widget.actions.length; i++) {
      if (i > 0) {
        total += separator;
      }
      total += _itemMainExtentForScrollFit(context, i);
    }
    return total;
  }

  double _itemMainExtentForScrollFit(BuildContext context, int index) {
    if (widget.direction == Axis.vertical) {
      return _itemMainExtentForOverflow(context, index);
    }
    if (index < 0 || index >= widget.actions.length) {
      return MorphButtonGroupOverflowController.roundConsumed(
        _iconOnlyNaturalSizeCache,
      );
    }
    final action = widget.actions[index];
    if (action.width != null) {
      return MorphButtonGroupOverflowController.roundConsumed(action.width!);
    }
    if (action.minWidth != null) {
      // Floor; measured content may still raise the extent below.
      final measured = index < _measuredUnselectedWidths.length
          ? math.max(
              _measuredUnselectedWidths[index] ?? 0,
              _measuredSelectedWidths[index] ?? 0,
            )
          : 0.0;
      return MorphButtonGroupOverflowController.roundConsumed(
        math.max(action.minWidth!, measured),
      );
    }
    if (index >= _measuredUnselectedWidths.length) {
      return MorphButtonGroupOverflowController.roundConsumed(
        _iconOnlyNaturalSizeCache,
      );
    }
    final unselectedWidth =
        _measuredUnselectedWidths[index] ?? _iconOnlyNaturalSizeCache;
    final selectedWidth = _measuredSelectedWidths[index] ?? unselectedWidth;
    return MorphButtonGroupOverflowController.roundConsumed(
      math.max(unselectedWidth, selectedWidth),
    );
  }
}
