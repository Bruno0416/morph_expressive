import 'package:flutter/widgets.dart';

import '../../../foundations/foundations.dart';

/// Theme values for `MorphCheckbox`.
@immutable
class MorphCheckboxTheme extends MorphThemeExtension<MorphCheckboxTheme> {
  /// MorphCheckboxTheme.
  const MorphCheckboxTheme({
    this.boxSize = 18,
    this.hitSize = 40,
    this.targetSize = 48,
    this.markSize = 16,
    this.indeterminateWidth = 10,
    this.indeterminateHeight = 2,
    this.borderWidth = 2,
    this.selectedOutlineWidth = 0,
    this.borderRadius = const BorderRadius.all(Radius.circular(2)),
    this.disabledOpacity = 0.38,
    this.labelGap = 8,
    this.hoverStateLayerOpacity = 0.08,
    this.focusStateLayerOpacity = 0.1,
    this.pressedStateLayerOpacity = 0.1,
    this.focusIndicatorThickness = 3,
    this.focusIndicatorOffset = 2,
    this.focusIndicatorColor,
    this.checkIconPadding = EdgeInsets.zero,
    this.pulseSpring = MorphMotion.expressiveSpatialDefault,
  });

  /// defaults.

  static const MorphCheckboxTheme defaults = MorphCheckboxTheme();

  /// Container width and height.
  final double boxSize;

  /// Circular state-layer size.
  final double hitSize;

  /// Touch target. The state layer stays centered inside this slot.
  final double targetSize;

  /// Check icon size.
  final double markSize;

  /// indeterminateWidth.
  final double indeterminateWidth;

  /// indeterminateHeight.
  final double indeterminateHeight;

  /// Unselected outline width.
  final double borderWidth;

  /// Selected outline width, including the error selected state.
  final double selectedOutlineWidth;

  /// Container corner radius.
  final BorderRadius borderRadius;

  /// disabledOpacity.
  final double disabledOpacity;

  /// Gap between the control and an optional label beside the checkbox.
  final double labelGap;

  /// Hover state-layer opacity.
  final double hoverStateLayerOpacity;

  /// Focus state-layer opacity.
  final double focusStateLayerOpacity;

  /// Pressed state-layer opacity.
  final double pressedStateLayerOpacity;

  /// Keyboard focus-ring stroke width.
  final double focusIndicatorThickness;

  /// Gap between the state layer and the focus ring.
  final double focusIndicatorOffset;

  /// Focus-ring color. Null resolves to [MorphColorScheme.secondary].
  final Color? focusIndicatorColor;

  /// Optical offset for the built-in check icon (paint translation, not layout).
  ///
  /// Default is [EdgeInsets.zero]. `left`/`top` nudge the glyph right/down;
  /// `right`/`bottom` nudge left/up.
  final EdgeInsetsGeometry checkIconPadding;

  /// Scale pulse spring when the value changes.
  final MorphSpring pulseSpring;

  static const Color _transparent = Color(0x00000000);

  /// Focus-ring color for [scheme].
  Color resolveFocusIndicatorColor(MorphColorScheme scheme) =>
      focusIndicatorColor ?? scheme.secondary;

  /// Opacity for the active hover, focus, or pressed state layer.
  double stateLayerOpacity(MorphInteractionState state) {
    if (state.pressed) {
      return pressedStateLayerOpacity;
    }
    if (state.focused) {
      return focusStateLayerOpacity;
    }
    if (state.hovered) {
      return hoverStateLayerOpacity;
    }
    return 0;
  }

  /// stateLayerColor.
  ///
  /// Pressed unselected uses primary; pressed selected uses onSurface.
  /// Hover and focus use primary when selected and onSurface when not.
  /// Error uses error for every interaction.
  Color stateLayerColor(
    MorphColorScheme scheme, {
    required bool active,
    required bool error,
    bool pressed = false,
  }) {
    if (error) {
      return scheme.error;
    }
    if (pressed) {
      return active ? scheme.onSurface : scheme.primary;
    }
    return active ? scheme.primary : scheme.onSurface;
  }

  /// fillColor.

  Color fillColor(
    MorphColorScheme scheme, {
    required bool enabled,
    required bool active,
    required bool error,
  }) {
    if (!enabled) {
      return active
          ? MorphColorUtils.withOpacity(scheme.onSurface, disabledOpacity)
          : _transparent;
    }
    if (!active) {
      return _transparent;
    }
    return error ? scheme.error : scheme.primary;
  }

  /// borderColor.

  Color borderColor(
    MorphColorScheme scheme, {
    required bool enabled,
    required bool active,
    required bool error,
    bool hovered = false,
    bool focused = false,
    bool pressed = false,
  }) {
    if (!enabled) {
      return MorphColorUtils.withOpacity(scheme.onSurface, disabledOpacity);
    }
    if (active) {
      return error ? scheme.error : scheme.primary;
    }
    if (error) {
      return scheme.error;
    }
    if (hovered || focused || pressed) {
      return scheme.onSurface;
    }
    return scheme.onSurfaceVariant;
  }

  /// Outline width for the current value. Selected states use
  /// [selectedOutlineWidth].
  double outlineWidth({required bool active}) =>
      active ? selectedOutlineWidth : borderWidth;

  /// markColor.
  ///
  /// Disabled marks use surface so they read on the faded onSurface fill.
  Color markColor(
    MorphColorScheme scheme, {
    required bool error,
    bool enabled = true,
  }) {
    if (!enabled) {
      return scheme.surface;
    }
    return error ? scheme.onError : scheme.onPrimary;
  }

  @override
  MorphCheckboxTheme copyWith({
    double? boxSize,
    double? hitSize,
    double? targetSize,
    double? markSize,
    double? indeterminateWidth,
    double? indeterminateHeight,
    double? borderWidth,
    double? selectedOutlineWidth,
    BorderRadius? borderRadius,
    double? disabledOpacity,
    double? labelGap,
    double? hoverStateLayerOpacity,
    double? focusStateLayerOpacity,
    double? pressedStateLayerOpacity,
    double? focusIndicatorThickness,
    double? focusIndicatorOffset,
    Color? focusIndicatorColor,
    bool clearFocusIndicatorColor = false,
    EdgeInsetsGeometry? checkIconPadding,
    MorphSpring? pulseSpring,
  }) {
    return MorphCheckboxTheme(
      boxSize: boxSize ?? this.boxSize,
      hitSize: hitSize ?? this.hitSize,
      targetSize: targetSize ?? this.targetSize,
      markSize: markSize ?? this.markSize,
      indeterminateWidth: indeterminateWidth ?? this.indeterminateWidth,
      indeterminateHeight: indeterminateHeight ?? this.indeterminateHeight,
      borderWidth: borderWidth ?? this.borderWidth,
      selectedOutlineWidth: selectedOutlineWidth ?? this.selectedOutlineWidth,
      borderRadius: borderRadius ?? this.borderRadius,
      disabledOpacity: disabledOpacity ?? this.disabledOpacity,
      labelGap: labelGap ?? this.labelGap,
      hoverStateLayerOpacity:
          hoverStateLayerOpacity ?? this.hoverStateLayerOpacity,
      focusStateLayerOpacity:
          focusStateLayerOpacity ?? this.focusStateLayerOpacity,
      pressedStateLayerOpacity:
          pressedStateLayerOpacity ?? this.pressedStateLayerOpacity,
      focusIndicatorThickness:
          focusIndicatorThickness ?? this.focusIndicatorThickness,
      focusIndicatorOffset: focusIndicatorOffset ?? this.focusIndicatorOffset,
      focusIndicatorColor: clearFocusIndicatorColor
          ? null
          : (focusIndicatorColor ?? this.focusIndicatorColor),
      checkIconPadding: checkIconPadding ?? this.checkIconPadding,
      pulseSpring: pulseSpring ?? this.pulseSpring,
    );
  }

  @override
  MorphCheckboxTheme lerp(MorphCheckboxTheme? other, double t) {
    if (other is! MorphCheckboxTheme) {
      return this;
    }
    return MorphCheckboxTheme(
      boxSize: _lerpDouble(boxSize, other.boxSize, t)!,
      hitSize: _lerpDouble(hitSize, other.hitSize, t)!,
      targetSize: _lerpDouble(targetSize, other.targetSize, t)!,
      markSize: _lerpDouble(markSize, other.markSize, t)!,
      indeterminateWidth: _lerpDouble(
        indeterminateWidth,
        other.indeterminateWidth,
        t,
      )!,
      indeterminateHeight: _lerpDouble(
        indeterminateHeight,
        other.indeterminateHeight,
        t,
      )!,
      borderWidth: _lerpDouble(borderWidth, other.borderWidth, t)!,
      selectedOutlineWidth: _lerpDouble(
        selectedOutlineWidth,
        other.selectedOutlineWidth,
        t,
      )!,
      borderRadius: BorderRadius.lerp(borderRadius, other.borderRadius, t)!,
      disabledOpacity: _lerpDouble(disabledOpacity, other.disabledOpacity, t)!,
      labelGap: _lerpDouble(labelGap, other.labelGap, t)!,
      hoverStateLayerOpacity: _lerpDouble(
        hoverStateLayerOpacity,
        other.hoverStateLayerOpacity,
        t,
      )!,
      focusStateLayerOpacity: _lerpDouble(
        focusStateLayerOpacity,
        other.focusStateLayerOpacity,
        t,
      )!,
      pressedStateLayerOpacity: _lerpDouble(
        pressedStateLayerOpacity,
        other.pressedStateLayerOpacity,
        t,
      )!,
      focusIndicatorThickness: _lerpDouble(
        focusIndicatorThickness,
        other.focusIndicatorThickness,
        t,
      )!,
      focusIndicatorOffset: _lerpDouble(
        focusIndicatorOffset,
        other.focusIndicatorOffset,
        t,
      )!,
      focusIndicatorColor: Color.lerp(
        focusIndicatorColor,
        other.focusIndicatorColor,
        t,
      ),
      checkIconPadding: EdgeInsetsGeometry.lerp(
        checkIconPadding,
        other.checkIconPadding,
        t,
      )!,
      pulseSpring: t < 0.5 ? pulseSpring : other.pulseSpring,
    );
  }

  double? _lerpDouble(double a, double b, double t) => a + (b - a) * t;
}
