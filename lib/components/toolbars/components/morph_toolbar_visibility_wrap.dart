// ignore_for_file: invalid_use_of_protected_member
// helpers del estado original; se revisaran durante la migracion de motion

part of '../morph_toolbars.dart';

extension _MorphToolbarVisibilityWrap on _MorphToolbarState {
  Widget _wrapVisibility(Widget bar) {
    // Collapse-on-scroll reuses the FAB / expand-trigger spring instead —
    // offset never moves in that mode, so this slide wrapper has nothing to
    // do and is skipped outright.
    if (_collapseOnScrollActive) {
      return bar;
    }
    final MorphToolbarVisibilityController? controller = _visibility;
    if (controller == null && widget.scrollBehavior == null) {
      return bar;
    }
    final MorphToolbarVisibilityController resolved =
        controller ?? widget.scrollBehavior!.controller;
    final bool vertical =
        _exitDirection == MorphToolbarExitDirection.top ||
        _exitDirection == MorphToolbarExitDirection.bottom;

    final Widget measured = _buildMeasuredToolbar(bar, resolved, vertical);
    final Widget sliding = _buildSlidingToolbar(measured, resolved);

    if (_floating || !vertical) {
      return sliding;
    }

    return _buildDockedShrinkWrapper(sliding, resolved);
  }

  Widget _buildMeasuredToolbar(
    Widget bar,
    MorphToolbarVisibilityController resolved,
    bool vertical,
  ) {
    return MorphToolbarMeasureSize(
      onChange: (Size size) => _handleMeasuredSize(size, resolved, vertical),
      child: bar,
    );
  }

  void _handleMeasuredSize(
    Size size,
    MorphToolbarVisibilityController resolved,
    bool vertical,
  ) {
    final double rawExtent = vertical ? size.height : size.width;
    if (!_floating && vertical && mounted) {
      setState(() => _dockedExtent = rawExtent);
    }
    if (widget.exitExtent != null || resolved.exitExtent != null) {
      final double extent = widget.exitExtent ?? resolved.exitExtent ?? 0;
      resolved.offsetLimit = -extent.abs();
      return;
    }
    resolved.offsetLimit = -(rawExtent + MorphToolbarTokens.screenOffset);
  }

  Widget _buildSlidingToolbar(
    Widget measured,
    MorphToolbarVisibilityController resolved,
  ) {
    return ClipRect(
      child: ListenableBuilder(
        listenable: resolved,
        builder: (BuildContext context, Widget? child) {
          final Offset offset = _exitOffset(context, resolved.offset);
          final bool hidden = resolved.isHidden;
          return Transform.translate(
            offset: offset,
            child: ExcludeFocus(excluding: hidden, child: child!),
          );
        },
        child: measured,
      ),
    );
  }

  /// Docked bars sit in a fixed-size layout slot (typically
  /// Scaffold.bottomNavigationBar). Shrink the reported layout extent in
  /// sync with the scroll offset so that slot collapses along with the
  /// bar, instead of leaving an empty "ghost" the size of the bar once it
  /// has slid out of view.
  Widget _buildDockedShrinkWrapper(
    Widget sliding,
    MorphToolbarVisibilityController resolved,
  ) {
    final Alignment alignment = _exitDirection == MorphToolbarExitDirection.top
        ? Alignment.topCenter
        : Alignment.bottomCenter;
    return ListenableBuilder(
      listenable: resolved,
      builder: (BuildContext context, Widget? child) {
        final double? natural = _dockedExtent;
        if (natural == null) {
          return child!;
        }
        final double shrunk = (natural - resolved.offset.abs()).clamp(
          0.0,
          natural,
        );
        return SizedBox(
          height: shrunk,
          child: ClipRect(
            child: OverflowBox(
              alignment: alignment,
              minHeight: natural,
              maxHeight: natural,
              child: SizedBox(height: natural, child: child),
            ),
          ),
        );
      },
      child: sliding,
    );
  }
}
