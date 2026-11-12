part of '../morph_buttons.dart';

extension _MorphButtonSelectionShape on _MorphButtonState {
  ({
    BorderRadius defaultShape,
    BorderRadius pressedShape,
    BorderRadius hoveredShape,
    bool freezeLeft,
    bool freezeRight,
  })
  _resolveSelectionShapes(MorphButtonMeasurements measurements) {
    final explicit = _decoration?.borderRadius;
    final fullyRound = BorderRadius.circular(measurements.height / 2);
    final square = BorderRadius.circular(
      _buttonTheme.squareRadius(widget.size),
    );
    final double? unselectedRadius = _decoration?.unselectedRadius;
    final double? selectedRadius = _decoration?.selectedRadius;
    final unselected = unselectedRadius != null
        ? BorderRadius.circular(unselectedRadius)
        : explicit != null
        ? BorderRadius.circular(explicit)
        : widget.shape == MorphButtonShape.round
        ? fullyRound
        : square;
    final selected = selectedRadius != null
        ? BorderRadius.circular(selectedRadius)
        : explicit != null
        ? BorderRadius.circular(explicit)
        : widget.shape == MorphButtonShape.round
        ? square
        : fullyRound;
    final pressed = BorderRadius.circular(
      _decoration?.pressedRadius ??
          explicit ??
          _buttonTheme.pressedRadius(widget.size),
    );
    // Spec (buttons + button groups): hover keeps resting shape; press morphs.
    final restingShape = _isSelected ? selected : unselected;
    final hovered = _decoration?.hoveredRadius != null
        ? BorderRadius.circular(_decoration!.hoveredRadius!)
        : restingShape;

    if (!widget.isGroupConnected) {
      return (
        defaultShape: restingShape,
        pressedShape: pressed,
        hoveredShape: hovered,
        freezeLeft: false,
        freezeRight: false,
      );
    }

    return _connectedSelectionShapes(
      measurements: measurements,
      explicit: explicit,
    );
  }

  ({
    BorderRadius defaultShape,
    BorderRadius pressedShape,
    BorderRadius hoveredShape,
    bool freezeLeft,
    bool freezeRight,
  })
  _connectedSelectionShapes({
    required MorphButtonMeasurements measurements,
    required double? explicit,
  }) {
    final groupTheme = MorphTheme.of(context).buttonGroupTheme;
    final outerRadius =
        explicit ??
        (widget.shape == MorphButtonShape.round
            ? measurements.height / 2
            : groupTheme.connectedOuterSquareRadiusFor(widget.size));
    final innerRadius =
        explicit ??
        _decoration?.connectedInnerRadius ??
        groupTheme.connectedInnerRadiusFor(widget.size);
    final pressedInnerRadius =
        _decoration?.pressedRadius ??
        explicit ??
        groupTheme.connectedPressedInnerRadiusFor(widget.size);
    final selectedInnerRadius =
        _decoration?.selectedRadius ??
        explicit ??
        groupTheme.connectedSelectedInnerRadiusFor(measurements.height);
    // isFirstInGroup / isLastInGroup are the physical left / right edges (the
    // group strategies already swap them for RTL), so radii are not directional.
    final resting = BorderRadius.horizontal(
      left: Radius.circular(widget.isFirstInGroup ? outerRadius : innerRadius),
      right: Radius.circular(widget.isLastInGroup ? outerRadius : innerRadius),
    );
    final connectedSelected = BorderRadius.circular(selectedInnerRadius);
    final connectedPressed = BorderRadius.horizontal(
      left: Radius.circular(
        widget.isFirstInGroup ? outerRadius : pressedInnerRadius,
      ),
      right: Radius.circular(
        widget.isLastInGroup ? outerRadius : pressedInnerRadius,
      ),
    );
    final connectedResting = _isSelected ? connectedSelected : resting;
    final connectedHovered = _decoration?.hoveredRadius != null
        ? BorderRadius.horizontal(
            left: Radius.circular(
              widget.isFirstInGroup ? outerRadius : _decoration!.hoveredRadius!,
            ),
            right: Radius.circular(
              widget.isLastInGroup ? outerRadius : _decoration!.hoveredRadius!,
            ),
          )
        : connectedResting;
    return (
      defaultShape: connectedResting,
      pressedShape: connectedPressed,
      hoveredShape: connectedHovered,
      freezeLeft: false,
      freezeRight: false,
    );
  }
}
