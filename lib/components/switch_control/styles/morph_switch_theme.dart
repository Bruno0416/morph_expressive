import 'package:flutter/widgets.dart';

import '../../../foundations/foundations.dart';

/// Theme values for `MorphSwitch`.
@immutable
class MorphSwitchTheme extends MorphThemeExtension<MorphSwitchTheme> {
  /// MorphSwitchTheme.
  const MorphSwitchTheme({
    this.trackWidth = 52,
    this.trackHeight = 32,
    this.trackPadding = 4,
    this.thumbSizePressed = 28,
    this.thumbSizeSelected = 24,
    this.thumbSizeUnselected = 16,
    this.thumbSizeWithIcon = 24,
    this.stateLayerSize = 40,
    this.targetSize = 48,
    this.iconSize = 16,
    this.borderWidth = 2,
    this.disabledTrackOpacity = 0.12,
    this.disabledThumbOpacity = 0.38,
    this.disabledSelectedHandleOpacity = 1,
    this.disabledOutlineOpacity = 0.12,
    this.hoverStateLayerOpacity = 0.08,
    this.focusStateLayerOpacity = 0.1,
    this.pressedStateLayerOpacity = 0.1,
    this.focusIndicatorThickness = 3,
    this.focusIndicatorOffset = 2,
    this.focusIndicatorColor,
    this.positionSpring = const MorphSpring(stiffness: 380, damping: 0.55),
    this.sizeSpring = const MorphSpring(stiffness: 380, damping: 0.7),
  });

  /// defaults.

  static const MorphSwitchTheme defaults = MorphSwitchTheme();

  /// trackWidth.

  final double trackWidth;

  /// trackHeight.
  final double trackHeight;

  /// Inset that keeps the 24dp handle inside the track.
  ///
  /// The 28dp pressed handle then stops 2dp short of the track edge.
  final double trackPadding;

  /// thumbSizePressed.
  final double thumbSizePressed;

  /// thumbSizeSelected.
  final double thumbSizeSelected;

  /// thumbSizeUnselected.
  final double thumbSizeUnselected;

  /// Handle size when the current state shows an icon.
  final double thumbSizeWithIcon;

  /// Diameter of the handle-centered hover/focus/press state layer.
  final double stateLayerSize;

  /// Minimum control slot. The track stays centered inside it.
  final double targetSize;

  /// iconSize.
  final double iconSize;

  /// borderWidth.
  final double borderWidth;

  /// disabledTrackOpacity.
  final double disabledTrackOpacity;

  /// Opacity for the disabled unselected handle and disabled icons.
  final double disabledThumbOpacity;

  /// Opacity for the disabled selected handle.
  final double disabledSelectedHandleOpacity;

  /// disabledOutlineOpacity.
  final double disabledOutlineOpacity;

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

  /// Thumb position spring (overshoot toward resting side).
  final MorphSpring positionSpring;

  /// Thumb size spring (follows the slide, more damped).
  final MorphSpring sizeSpring;

  /// thumbSize.

  double thumbSize({
    required bool pressed,
    required bool grown,
    bool hasIcon = false,
  }) {
    if (pressed) {
      return thumbSizePressed;
    }
    if (hasIcon) {
      return thumbSizeWithIcon;
    }
    return grown ? thumbSizeSelected : thumbSizeUnselected;
  }

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

  /// trackColor.

  Color trackColor(
    MorphColorScheme scheme, {
    required bool enabled,
    required bool value,
  }) {
    if (!enabled) {
      return MorphColorUtils.withOpacity(
        value ? scheme.onSurface : scheme.surfaceContainerHighest,
        disabledTrackOpacity,
      );
    }
    return value ? scheme.primary : scheme.surfaceContainerHighest;
  }

  /// thumbColor.
  ///
  /// Hover, focus, and press use primary container when selected and
  /// on surface variant when not.
  Color thumbColor(
    MorphColorScheme scheme, {
    required bool enabled,
    required bool value,
    bool hovered = false,
    bool focused = false,
    bool pressed = false,
  }) {
    if (!enabled) {
      if (value) {
        return MorphColorUtils.withOpacity(
          scheme.surface,
          disabledSelectedHandleOpacity,
        );
      }
      return MorphColorUtils.withOpacity(
        scheme.onSurface,
        disabledThumbOpacity,
      );
    }
    if (hovered || focused || pressed) {
      return value ? scheme.primaryContainer : scheme.onSurfaceVariant;
    }
    return value ? scheme.onPrimary : scheme.outline;
  }

  /// outlineColor.

  Color outlineColor(MorphColorScheme scheme, {required bool enabled}) {
    if (!enabled) {
      return MorphColorUtils.withOpacity(
        scheme.onSurface,
        disabledOutlineOpacity,
      );
    }
    return scheme.outline;
  }

  /// iconColor.
  ///
  /// Selected icons use primary. Disabled icons use on surface or
  /// surface container highest at [disabledThumbOpacity].
  Color iconColor(
    MorphColorScheme scheme, {
    required bool value,
    bool enabled = true,
  }) {
    if (!enabled) {
      return MorphColorUtils.withOpacity(
        value ? scheme.onSurface : scheme.surfaceContainerHighest,
        disabledThumbOpacity,
      );
    }
    return value ? scheme.primary : scheme.surfaceContainerHighest;
  }

  /// stateLayerColor.

  Color stateLayerColor(MorphColorScheme scheme, {required bool value}) =>
      value ? scheme.primary : scheme.onSurface;

  @override
  MorphSwitchTheme copyWith({
    double? trackWidth,
    double? trackHeight,
    double? trackPadding,
    double? thumbSizePressed,
    double? thumbSizeSelected,
    double? thumbSizeUnselected,
    double? thumbSizeWithIcon,
    double? stateLayerSize,
    double? targetSize,
    double? iconSize,
    double? borderWidth,
    double? disabledTrackOpacity,
    double? disabledThumbOpacity,
    double? disabledSelectedHandleOpacity,
    double? disabledOutlineOpacity,
    double? hoverStateLayerOpacity,
    double? focusStateLayerOpacity,
    double? pressedStateLayerOpacity,
    double? focusIndicatorThickness,
    double? focusIndicatorOffset,
    Color? focusIndicatorColor,
    bool clearFocusIndicatorColor = false,
    MorphSpring? positionSpring,
    MorphSpring? sizeSpring,
  }) {
    return MorphSwitchTheme(
      trackWidth: trackWidth ?? this.trackWidth,
      trackHeight: trackHeight ?? this.trackHeight,
      trackPadding: trackPadding ?? this.trackPadding,
      thumbSizePressed: thumbSizePressed ?? this.thumbSizePressed,
      thumbSizeSelected: thumbSizeSelected ?? this.thumbSizeSelected,
      thumbSizeUnselected: thumbSizeUnselected ?? this.thumbSizeUnselected,
      thumbSizeWithIcon: thumbSizeWithIcon ?? this.thumbSizeWithIcon,
      stateLayerSize: stateLayerSize ?? this.stateLayerSize,
      targetSize: targetSize ?? this.targetSize,
      iconSize: iconSize ?? this.iconSize,
      borderWidth: borderWidth ?? this.borderWidth,
      disabledTrackOpacity: disabledTrackOpacity ?? this.disabledTrackOpacity,
      disabledThumbOpacity: disabledThumbOpacity ?? this.disabledThumbOpacity,
      disabledSelectedHandleOpacity:
          disabledSelectedHandleOpacity ?? this.disabledSelectedHandleOpacity,
      disabledOutlineOpacity:
          disabledOutlineOpacity ?? this.disabledOutlineOpacity,
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
      positionSpring: positionSpring ?? this.positionSpring,
      sizeSpring: sizeSpring ?? this.sizeSpring,
    );
  }

  @override
  MorphSwitchTheme lerp(MorphSwitchTheme? other, double t) {
    if (other is! MorphSwitchTheme) {
      return this;
    }
    return _lerpSwitchLayout(other, t);
  }

  MorphSwitchTheme _lerpSwitchLayout(MorphSwitchTheme other, double t) {
    return _lerpSwitchFeedback(other, t).copyWith(
      trackWidth: _lerpDouble(trackWidth, other.trackWidth, t),
      trackHeight: _lerpDouble(trackHeight, other.trackHeight, t),
      trackPadding: _lerpDouble(trackPadding, other.trackPadding, t),
      thumbSizePressed: _lerpDouble(
        thumbSizePressed,
        other.thumbSizePressed,
        t,
      ),
      thumbSizeSelected: _lerpDouble(
        thumbSizeSelected,
        other.thumbSizeSelected,
        t,
      ),
      thumbSizeUnselected: _lerpDouble(
        thumbSizeUnselected,
        other.thumbSizeUnselected,
        t,
      ),
      thumbSizeWithIcon: _lerpDouble(
        thumbSizeWithIcon,
        other.thumbSizeWithIcon,
        t,
      ),
      stateLayerSize: _lerpDouble(stateLayerSize, other.stateLayerSize, t),
      targetSize: _lerpDouble(targetSize, other.targetSize, t),
      iconSize: _lerpDouble(iconSize, other.iconSize, t),
    );
  }

  MorphSwitchTheme _lerpSwitchFeedback(MorphSwitchTheme other, double t) {
    return copyWith(
      borderWidth: _lerpDouble(borderWidth, other.borderWidth, t),
      disabledTrackOpacity: _lerpDouble(
        disabledTrackOpacity,
        other.disabledTrackOpacity,
        t,
      ),
      disabledThumbOpacity: _lerpDouble(
        disabledThumbOpacity,
        other.disabledThumbOpacity,
        t,
      ),
      disabledSelectedHandleOpacity: _lerpDouble(
        disabledSelectedHandleOpacity,
        other.disabledSelectedHandleOpacity,
        t,
      ),
      disabledOutlineOpacity: _lerpDouble(
        disabledOutlineOpacity,
        other.disabledOutlineOpacity,
        t,
      ),
      hoverStateLayerOpacity: _lerpDouble(
        hoverStateLayerOpacity,
        other.hoverStateLayerOpacity,
        t,
      ),
      focusStateLayerOpacity: _lerpDouble(
        focusStateLayerOpacity,
        other.focusStateLayerOpacity,
        t,
      ),
      pressedStateLayerOpacity: _lerpDouble(
        pressedStateLayerOpacity,
        other.pressedStateLayerOpacity,
        t,
      ),
      focusIndicatorThickness: _lerpDouble(
        focusIndicatorThickness,
        other.focusIndicatorThickness,
        t,
      ),
      focusIndicatorOffset: _lerpDouble(
        focusIndicatorOffset,
        other.focusIndicatorOffset,
        t,
      ),
      focusIndicatorColor: Color.lerp(
        focusIndicatorColor,
        other.focusIndicatorColor,
        t,
      ),
      positionSpring: t < 0.5 ? positionSpring : other.positionSpring,
      sizeSpring: t < 0.5 ? sizeSpring : other.sizeSpring,
    );
  }

  double? _lerpDouble(double a, double b, double t) => a + (b - a) * t;
}
