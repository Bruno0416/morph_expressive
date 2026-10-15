part of '../morph_button_group.dart';

extension _MorphButtonGroupActionRadii on _MorphButtonGroupState {
  ({
    double? selected,
    double? unselected,
    double? pressed,
    double? hovered,
    double? connectedInner,
  })
  _actionRadii(
    MorphButtonDecoration? actionDecoration,
    MorphButtonDecoration? groupDecoration,
    MorphButtonGroupTheme groupTheme,
    double segmentHeight,
    bool connected,
  ) {
    return (
      selected:
          actionDecoration?.selectedRadius ??
          groupDecoration?.selectedRadius ??
          (connected
              ? groupTheme.connectedSelectedInnerRadiusFor(segmentHeight)
              : null),
      unselected:
          actionDecoration?.unselectedRadius ??
          groupDecoration?.unselectedRadius ??
          (connected ? groupTheme.connectedInnerRadiusFor(widget.size) : null),
      pressed:
          actionDecoration?.pressedRadius ??
          groupDecoration?.pressedRadius ??
          (connected
              ? groupTheme.connectedPressedInnerRadiusFor(widget.size)
              : null),
      hovered:
          actionDecoration?.hoveredRadius ?? groupDecoration?.hoveredRadius,
      connectedInner:
          actionDecoration?.connectedInnerRadius ??
          groupDecoration?.connectedInnerRadius ??
          (connected ? groupTheme.connectedInnerRadiusFor(widget.size) : null),
    );
  }
}
