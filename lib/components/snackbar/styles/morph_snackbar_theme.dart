import 'package:flutter/widgets.dart';

import '../../../foundations/foundations.dart';

/// Theme values for `MorphSnackbar`.
@immutable
class MorphSnackbarTheme extends MorphThemeExtension<MorphSnackbarTheme> {
  /// MorphSnackbarTheme.
  const MorphSnackbarTheme({
    this.singleLineMinHeight = 48,
    this.twoLineMinHeight = 68,
    this.maxWidth = 600,
    this.startPadding = 16,
    this.endPadding = 16,
    this.endPaddingWithTrailing = 8,
    this.verticalPadding = 8,
    this.elevation = MorphElevation.level3,
    this.defaultDuration = const Duration(seconds: 4),
    this.overlayHorizontalInset = 16,
    this.overlayBottomInset = 16,
    this.overlayAlignment = Alignment.bottomCenter,
    this.actionPadding = const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    this.actionGap = 8,
    this.closeIconSize = 24,
    this.closePadding = 12,
    this.hoverStateOpacity = MorphStateOpacity.hover,
    this.focusStateOpacity = MorphStateOpacity.focus,
    this.pressedStateOpacity = MorphStateOpacity.pressed,
    this.longActionLabelThreshold = 12,
  });

  /// Spec-aligned defaults.
  static const MorphSnackbarTheme defaults = MorphSnackbarTheme();

  /// Min height for single-line snackbars. Spec: 48dp.
  final double singleLineMinHeight;

  /// Min height for two-line snackbars. Spec: 68dp.
  final double twoLineMinHeight;

  /// Max width on medium / expanded layouts.
  final double maxWidth;

  /// Start padding (text to container edge). Spec: 16dp.
  final double startPadding;

  /// End padding when there is no action or close. Spec-aligned: 16dp.
  final double endPadding;

  /// End padding when action and/or close is present. Spec: 8dp.
  final double endPaddingWithTrailing;

  /// Vertical content padding inside the container.
  final double verticalPadding;

  /// Container elevation. Spec inference: Level 3 (6dp).
  final double elevation;

  /// Auto-dismiss duration for snackbars without action/close. Spec: 4–10s.
  final Duration defaultDuration;

  /// Distance from leading / trailing screen edges.
  final double overlayHorizontalInset;

  /// Distance from the bottom edge (plus safe area).
  final double overlayBottomInset;

  /// Horizontal placement within the overlay slot (start / center).
  final AlignmentGeometry overlayAlignment;

  /// Padding around the action label.
  final EdgeInsets actionPadding;

  /// Gap between supporting text and the action.
  final double actionGap;

  /// Close icon size. Spec: 24dp.
  final double closeIconSize;

  /// Padding around the close icon. Spec: 12dp.
  final double closePadding;

  /// Action/close hover state-layer opacity. Spec: 0.08.
  final double hoverStateOpacity;

  /// Action/close focus state-layer opacity. Spec: 0.1.
  final double focusStateOpacity;

  /// Action/close pressed state-layer opacity. Spec: 0.1.
  final double pressedStateOpacity;

  /// Action labels longer than this prefer a dedicated trailing row.
  final int longActionLabelThreshold;

  /// Rounded snackbar container that follows the active Morph theme.
  BorderRadius get borderRadius => MorphShapes.radiusLarge;

  /// Theme-adaptive surface, including dark mode and seed colors.
  Color containerColor(MorphColorScheme scheme) => scheme.surfaceContainerHigh;

  /// Supporting text uses the surface foreground for legible contrast.
  TextStyle messageStyle(MorphTypeScale type, MorphColorScheme scheme) =>
      type.bodyMedium.copyWith(color: scheme.onSurface);

  /// Action label uses the primary role, consistent with Morph buttons.
  TextStyle actionStyle(MorphTypeScale type, MorphColorScheme scheme) =>
      type.labelLarge.copyWith(color: scheme.primary);

  /// Close icon is secondary on the same adaptive surface.
  Color closeIconColor(MorphColorScheme scheme) => scheme.onSurfaceVariant;

  /// Resolves state-layer opacity for [state].
  double stateOpacityFor(MorphInteractionState state) {
    if (state.pressed) {
      return pressedStateOpacity;
    }
    if (state.showFocusFill) {
      return focusStateOpacity;
    }
    if (state.hovered) {
      return hoverStateOpacity;
    }
    return 0;
  }

  @override
  MorphSnackbarTheme copyWith({
    double? singleLineMinHeight,
    double? twoLineMinHeight,
    double? maxWidth,
    double? startPadding,
    double? endPadding,
    double? endPaddingWithTrailing,
    double? verticalPadding,
    double? elevation,
    Duration? defaultDuration,
    double? overlayHorizontalInset,
    double? overlayBottomInset,
    AlignmentGeometry? overlayAlignment,
    EdgeInsets? actionPadding,
    double? actionGap,
    double? closeIconSize,
    double? closePadding,
    double? hoverStateOpacity,
    double? focusStateOpacity,
    double? pressedStateOpacity,
    int? longActionLabelThreshold,
  }) {
    return MorphSnackbarTheme(
      singleLineMinHeight: singleLineMinHeight ?? this.singleLineMinHeight,
      twoLineMinHeight: twoLineMinHeight ?? this.twoLineMinHeight,
      maxWidth: maxWidth ?? this.maxWidth,
      startPadding: startPadding ?? this.startPadding,
      endPadding: endPadding ?? this.endPadding,
      endPaddingWithTrailing:
          endPaddingWithTrailing ?? this.endPaddingWithTrailing,
      verticalPadding: verticalPadding ?? this.verticalPadding,
      elevation: elevation ?? this.elevation,
      defaultDuration: defaultDuration ?? this.defaultDuration,
      overlayHorizontalInset:
          overlayHorizontalInset ?? this.overlayHorizontalInset,
      overlayBottomInset: overlayBottomInset ?? this.overlayBottomInset,
      overlayAlignment: overlayAlignment ?? this.overlayAlignment,
      actionPadding: actionPadding ?? this.actionPadding,
      actionGap: actionGap ?? this.actionGap,
      closeIconSize: closeIconSize ?? this.closeIconSize,
      closePadding: closePadding ?? this.closePadding,
      hoverStateOpacity: hoverStateOpacity ?? this.hoverStateOpacity,
      focusStateOpacity: focusStateOpacity ?? this.focusStateOpacity,
      pressedStateOpacity: pressedStateOpacity ?? this.pressedStateOpacity,
      longActionLabelThreshold:
          longActionLabelThreshold ?? this.longActionLabelThreshold,
    );
  }

  @override
  MorphSnackbarTheme lerp(MorphSnackbarTheme? other, double t) {
    if (other is! MorphSnackbarTheme) {
      return this;
    }
    return MorphSnackbarTheme(
      singleLineMinHeight: _lerpDouble(
        singleLineMinHeight,
        other.singleLineMinHeight,
        t,
      )!,
      twoLineMinHeight: _lerpDouble(
        twoLineMinHeight,
        other.twoLineMinHeight,
        t,
      )!,
      maxWidth: _lerpDouble(maxWidth, other.maxWidth, t)!,
      startPadding: _lerpDouble(startPadding, other.startPadding, t)!,
      endPadding: _lerpDouble(endPadding, other.endPadding, t)!,
      endPaddingWithTrailing: _lerpDouble(
        endPaddingWithTrailing,
        other.endPaddingWithTrailing,
        t,
      )!,
      verticalPadding: _lerpDouble(verticalPadding, other.verticalPadding, t)!,
      elevation: _lerpDouble(elevation, other.elevation, t)!,
      defaultDuration: t < 0.5 ? defaultDuration : other.defaultDuration,
      overlayHorizontalInset: _lerpDouble(
        overlayHorizontalInset,
        other.overlayHorizontalInset,
        t,
      )!,
      overlayBottomInset: _lerpDouble(
        overlayBottomInset,
        other.overlayBottomInset,
        t,
      )!,
      overlayAlignment: t < 0.5 ? overlayAlignment : other.overlayAlignment,
      actionPadding: EdgeInsets.lerp(actionPadding, other.actionPadding, t)!,
      actionGap: _lerpDouble(actionGap, other.actionGap, t)!,
      closeIconSize: _lerpDouble(closeIconSize, other.closeIconSize, t)!,
      closePadding: _lerpDouble(closePadding, other.closePadding, t)!,
      hoverStateOpacity: _lerpDouble(
        hoverStateOpacity,
        other.hoverStateOpacity,
        t,
      )!,
      focusStateOpacity: _lerpDouble(
        focusStateOpacity,
        other.focusStateOpacity,
        t,
      )!,
      pressedStateOpacity: _lerpDouble(
        pressedStateOpacity,
        other.pressedStateOpacity,
        t,
      )!,
      longActionLabelThreshold: t < 0.5
          ? longActionLabelThreshold
          : other.longActionLabelThreshold,
    );
  }

  double? _lerpDouble(double a, double b, double t) => a + (b - a) * t;
}
