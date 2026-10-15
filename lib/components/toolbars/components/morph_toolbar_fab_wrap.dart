part of '../morph_toolbars.dart';

extension _MorphToolbarFabWrap on _MorphToolbarState {
  Widget _withFab(Widget toolbar, MorphToolbarColorStyle style) {
    final Widget expandIcon =
        widget.fabExpandIcon ?? widget.fabIcon ?? const Icon(MorphIcons.add);
    final Widget collapseIcon =
        widget.fabCollapseIcon ?? const Icon(MorphIcons.close);
    final bool fabExpands = widget.fabExpandsToolbar;
    final fabIcon = fabExpands && _expanded ? collapseIcon : expandIcon;
    final VoidCallback? fabOnPressed = widget.floatingActionButton == null
        ? (fabExpands ? _onFabPressed : widget.onFabPressed)
        : widget.onFabPressed;
    final MorphToolbarTheme toolbarTheme = MorphTheme.of(context).toolbarTheme;
    final double fabProgress = fabExpands ? _expandCtrl.value : 1;
    final MorphFabTheme fabTheme = MorphTheme.of(context).fabTheme;
    final Widget fab = MorphToolbarFabSlot(
      fab: widget.floatingActionButton,
      icon: fabIcon,
      onPressed: fabOnPressed,
      color: style == MorphToolbarColorStyle.vibrant
          ? MorphFabColor.tertiary
          : MorphFabColor.secondary,
      containerSize: fabExpands ? _fabSize : MorphToolbarTokens.fabBaseline,
      iconSize:
          toolbarTheme.fabCollapsedIcon +
          (toolbarTheme.fabExpandedIcon - toolbarTheme.fabCollapsedIcon) *
              fabProgress,
      cornerRadius:
          fabTheme.mediumRadius +
          (fabTheme.regularRadius - fabTheme.mediumRadius) * fabProgress,
    );

    final horizontal = widget.axis == Axis.horizontal;
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return AnimatedBuilder(
      animation: _expandCtrl,
      builder: (BuildContext context, Widget? child) {
        if (horizontal) {
          final MorphToolbarFabPosition pos =
              widget.fabPosition == MorphToolbarFabPosition.start ||
                  widget.fabPosition == MorphToolbarFabPosition.end
              ? widget.fabPosition
              : MorphToolbarFabPosition.end;
          return MorphToolbarHorizontalFabLayout(
            progress: _fabLayoutProgress,
            fabPosition: pos,
            isRtl: isRtl,
            toolbar: toolbar,
            fab: fab,
          );
        }
        final MorphToolbarFabPosition pos =
            widget.fabPosition == MorphToolbarFabPosition.top ||
                widget.fabPosition == MorphToolbarFabPosition.bottom
            ? widget.fabPosition
            : MorphToolbarFabPosition.bottom;
        return MorphToolbarVerticalFabLayout(
          progress: _fabLayoutProgress,
          fabPosition: pos,
          toolbar: toolbar,
          fab: fab,
        );
      },
    );
  }
}
