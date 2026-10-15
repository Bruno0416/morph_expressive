import 'package:flutter/widgets.dart';
import 'package:morph_expressive/morph_components.dart'
    show MorphRangeSlider, MorphSlider;

import '../../../foundations/foundations.dart';
import '../enums/morph_slider_enums.dart';
import '../res/morph_slider_tokens.dart';

/// Resolved colors for an [MorphSlider] / [MorphRangeSlider] paint pass.
@immutable
class MorphSliderColors {
  /// MorphSliderColors.
  const MorphSliderColors({
    required this.thumb,
    required this.activeTrack,
    required this.inactiveTrack,
    required this.activeTick,
    required this.inactiveTick,
    required this.stopIndicator,
    required this.valueIndicator,
    required this.valueIndicatorLabel,
  });

  /// thumb.

  final Color thumb;

  /// activeTrack.
  final Color activeTrack;

  /// inactiveTrack.
  final Color inactiveTrack;

  /// activeTick.
  final Color activeTick;

  /// inactiveTick.
  final Color inactiveTick;

  /// stopIndicator.
  final Color stopIndicator;

  /// valueIndicator.
  final Color valueIndicator;

  /// valueIndicatorLabel.
  final Color valueIndicatorLabel;
}

/// Theme values for [MorphSlider] and [MorphRangeSlider].
@immutable
class MorphSliderTheme extends MorphThemeExtension<MorphSliderTheme> {
  /// MorphSliderTheme.
  const MorphSliderTheme({
    this.height = MorphSliderTokens.handleHeight,
    this.trackHeight = 4,
    this.handleGap = MorphSliderTokens.thumbTrackGapSize,
    this.handleWidth = MorphSliderTokens.handleWidth,
    this.handleHeight = MorphSliderTokens.handleHeight,
    this.pressedHandleWidth = MorphSliderTokens.pressedHandleWidth,
    this.focusHandleWidth = MorphSliderTokens.focusHandleWidth,
    this.hoverHandleWidth = MorphSliderTokens.hoverHandleWidth,
    this.trackInsideCornerSize = MorphSliderTokens.trackInsideCornerSize,
    this.trackCornerRadius = MorphSliderTokens.trackCornerRadius,
    this.stopIndicatorSize = MorphSliderTokens.stopIndicatorSize,
    this.tickSize = MorphSliderTokens.tickSize,
    this.stopIndicatorTrailingSpace =
        MorphSliderTokens.stopIndicatorTrailingSpace,
    this.iconEdgeInset = MorphSliderTokens.iconEdgeInset,
    this.iconSize = MorphSliderTokens.iconSize,
    this.valueIndicatorBottomSpace =
        MorphSliderTokens.valueIndicatorActiveBottomSpace,
    this.valueIndicatorWidth = MorphSliderTokens.valueIndicatorWidth,
    this.valueIndicatorHeight = MorphSliderTokens.valueIndicatorHeight,
    this.valueIndicatorRadius = MorphSliderTokens.valueIndicatorRadius,
    this.valueIndicatorFontSize = MorphSliderTokens.valueIndicatorFontSize,
    this.valueIndicatorLineHeight = MorphSliderTokens.valueIndicatorLineHeight,
    this.valueIndicatorLetterSpacing =
        MorphSliderTokens.valueIndicatorLetterSpacing,
    this.valueIndicatorFontWeight = FontWeight.w400,
    this.stateLayerSize = MorphSliderTokens.stateLayerSize,
    this.hoverStateOpacity = MorphSliderTokens.hoverStateOpacity,
    this.focusStateOpacity = MorphSliderTokens.focusStateOpacity,
    this.pressedStateOpacity = MorphSliderTokens.pressedStateOpacity,
    this.tickOpacity = MorphSliderTokens.tickOpacity,
    this.overlapOutlineWidth = MorphSliderTokens.overlapOutlineWidth,
    this.disabledActiveOpacity = MorphSliderTokens.disabledActiveTrackOpacity,
    this.disabledInactiveOpacity = MorphSliderTokens.disabledInactiveTrackOpacity,
    this.waveAmplitude = MorphSliderTokens.waveAmplitude,
    this.wavelength = MorphSliderTokens.wavelength,
    this.dockSpring = MorphMotion.expressiveSpatialFast,
  });

  /// defaults.

  static const MorphSliderTheme defaults = MorphSliderTheme();

  /// Geometry preset for [size]. Motion and color fields stay at defaults.
  factory MorphSliderTheme.forSize(MorphSliderSize size) {
    return MorphSliderTheme(
      height: size.handleHeight,
      trackHeight: size.trackHeight,
      handleHeight: size.handleHeight,
      trackCornerRadius: size.cornerRadius,
      iconEdgeInset: size.iconPadding,
      iconSize: size.iconSize,
    );
  }

  /// Uses [size] geometry when it is not [MorphSliderSize.xs].
  ///
  /// XS keeps this theme so an app-wide slider theme still applies.
  MorphSliderTheme applyingSize(MorphSliderSize size) {
    if (size == MorphSliderSize.xs) {
      return this;
    }
    final preset = MorphSliderTheme.forSize(size);
    return copyWith(
      height: preset.height,
      trackHeight: preset.trackHeight,
      handleHeight: preset.handleHeight,
      trackCornerRadius: preset.trackCornerRadius,
      iconEdgeInset: preset.iconEdgeInset,
      iconSize: preset.iconSize,
    );
  }

  /// Cross-axis extent of the interactive slider layout.
  final double height;

  /// trackHeight.

  final double trackHeight;

  /// handleGap.
  final double handleGap;

  /// handleWidth.
  final double handleWidth;

  /// handleHeight.
  final double handleHeight;

  /// pressedHandleWidth.
  final double pressedHandleWidth;

  /// Short-axis handle width while keyboard focus is showing.
  final double focusHandleWidth;

  /// Short-axis handle width while hovered.
  final double hoverHandleWidth;

  /// trackInsideCornerSize.
  final double trackInsideCornerSize;

  /// Outer corner radius for active and inactive track ends.
  ///
  /// Fixed default; not derived from [trackHeight].
  final double trackCornerRadius;

  /// stopIndicatorSize.
  final double stopIndicatorSize;

  /// tickSize.
  final double tickSize;

  /// Clear space between each track end and the outer edge of end markers.
  final double stopIndicatorTrailingSpace;

  /// Clear space between the track edge and the relocating [MorphSlider.icon].
  final double iconEdgeInset;

  /// Extent of the inset icon.
  final double iconSize;

  /// valueIndicatorBottomSpace.
  final double valueIndicatorBottomSpace;

  /// valueIndicatorWidth.
  final double valueIndicatorWidth;

  /// valueIndicatorHeight.
  final double valueIndicatorHeight;

  /// valueIndicatorRadius.
  final double valueIndicatorRadius;

  /// valueIndicatorFontSize.
  final double valueIndicatorFontSize;

  /// valueIndicatorLineHeight.
  final double valueIndicatorLineHeight;

  /// valueIndicatorLetterSpacing.
  final double valueIndicatorLetterSpacing;

  /// valueIndicatorFontWeight.
  final FontWeight valueIndicatorFontWeight;

  /// Diameter of the hover, focus, and press state layer.
  final double stateLayerSize;

  /// hoverStateOpacity.
  final double hoverStateOpacity;

  /// focusStateOpacity.
  final double focusStateOpacity;

  /// pressedStateOpacity.
  final double pressedStateOpacity;

  /// Opacity of discrete tick marks.
  final double tickOpacity;

  /// Outline width when range handles overlap.
  final double overlapOutlineWidth;

  /// disabledActiveOpacity.
  final double disabledActiveOpacity;

  /// disabledInactiveOpacity.
  final double disabledInactiveOpacity;

  /// Peak offset of the wavy active track from the centerline.
  final double waveAmplitude;

  /// Length of one full sine cycle on a wavy active track.
  final double wavelength;

  /// Dock / undock spring for the handle.
  final MorphSpring dockSpring;

  /// Compose wavy determinate amplitude: full mid-progress, zero near ends.
  double amplitudeForProgress(double progress) {
    if (progress <= 0.1 || progress >= 0.95) {
      return 0;
    }
    return 1;
  }

  /// Resolves Compose-accurate slider colors for the current [scheme].
  MorphSliderColors colors(MorphColorScheme scheme, {required bool enabled}) {
    Color active(Color c) => enabled
        ? c
        : MorphColorUtils.withOpacity(scheme.onSurface, disabledActiveOpacity);
    Color inactive(Color c) => enabled
        ? c
        : MorphColorUtils.withOpacity(scheme.onSurface, disabledInactiveOpacity);

    final Color activeTrack = active(scheme.primary);
    final Color inactiveTrack = inactive(scheme.secondaryContainer);
    final Color activeTick = enabled
        ? MorphColorUtils.withOpacity(scheme.onPrimary, tickOpacity)
        : MorphColorUtils.withOpacity(scheme.onInverseSurface, tickOpacity);
    final Color inactiveTick = enabled
        ? MorphColorUtils.withOpacity(scheme.onSecondaryContainer, tickOpacity)
        : MorphColorUtils.withOpacity(scheme.onSurface, tickOpacity);
    return MorphSliderColors(
      thumb: active(scheme.primary),
      activeTrack: activeTrack,
      inactiveTrack: inactiveTrack,
      activeTick: activeTick,
      inactiveTick: inactiveTick,
      stopIndicator: enabled ? scheme.onSecondaryContainer : scheme.onSurface,
      valueIndicator: scheme.inverseSurface,
      valueIndicatorLabel: scheme.onInverseSurface,
    );
  }

  /// Hover, focus, or press disc behind the handle. Null when idle.
  Color? stateLayerColor(
    MorphColorScheme scheme, {
    required bool hovered,
    required bool focused,
    required bool pressed,
  }) {
    if (pressed) {
      return MorphColorUtils.withOpacity(scheme.primary, pressedStateOpacity);
    }
    if (focused) {
      return MorphColorUtils.withOpacity(scheme.primary, focusStateOpacity);
    }
    if (hovered) {
      return MorphColorUtils.withOpacity(scheme.primary, hoverStateOpacity);
    }
    return null;
  }

  /// Legacy helper retained for call sites that only need one role color.
  Color color(
    MorphColorScheme scheme, {
    required Color enabledColor,
    required bool enabled,
  }) {
    if (!enabled) {
      return MorphColorUtils.withOpacity(scheme.onSurface, disabledActiveOpacity);
    }
    return enabledColor;
  }

  @override
  MorphSliderTheme copyWith({
    double? height,
    double? trackHeight,
    double? handleGap,
    double? handleWidth,
    double? handleHeight,
    double? pressedHandleWidth,
    double? focusHandleWidth,
    double? hoverHandleWidth,
    double? trackInsideCornerSize,
    double? trackCornerRadius,
    double? stopIndicatorSize,
    double? tickSize,
    double? stopIndicatorTrailingSpace,
    double? iconEdgeInset,
    double? iconSize,
    double? valueIndicatorBottomSpace,
    double? valueIndicatorWidth,
    double? valueIndicatorHeight,
    double? valueIndicatorRadius,
    double? valueIndicatorFontSize,
    double? valueIndicatorLineHeight,
    double? valueIndicatorLetterSpacing,
    FontWeight? valueIndicatorFontWeight,
    double? stateLayerSize,
    double? hoverStateOpacity,
    double? focusStateOpacity,
    double? pressedStateOpacity,
    double? tickOpacity,
    double? overlapOutlineWidth,
    double? disabledActiveOpacity,
    double? disabledInactiveOpacity,
    double? waveAmplitude,
    double? wavelength,
    MorphSpring? dockSpring,
  }) {
    return MorphSliderTheme(
      height: height ?? this.height,
      trackHeight: trackHeight ?? this.trackHeight,
      handleGap: handleGap ?? this.handleGap,
      handleWidth: handleWidth ?? this.handleWidth,
      handleHeight: handleHeight ?? this.handleHeight,
      pressedHandleWidth: pressedHandleWidth ?? this.pressedHandleWidth,
      focusHandleWidth: focusHandleWidth ?? this.focusHandleWidth,
      hoverHandleWidth: hoverHandleWidth ?? this.hoverHandleWidth,
      trackInsideCornerSize:
          trackInsideCornerSize ?? this.trackInsideCornerSize,
      trackCornerRadius: trackCornerRadius ?? this.trackCornerRadius,
      stopIndicatorSize: stopIndicatorSize ?? this.stopIndicatorSize,
      tickSize: tickSize ?? this.tickSize,
      stopIndicatorTrailingSpace:
          stopIndicatorTrailingSpace ?? this.stopIndicatorTrailingSpace,
      iconEdgeInset: iconEdgeInset ?? this.iconEdgeInset,
      iconSize: iconSize ?? this.iconSize,
      valueIndicatorBottomSpace:
          valueIndicatorBottomSpace ?? this.valueIndicatorBottomSpace,
      valueIndicatorWidth: valueIndicatorWidth ?? this.valueIndicatorWidth,
      valueIndicatorHeight: valueIndicatorHeight ?? this.valueIndicatorHeight,
      valueIndicatorRadius: valueIndicatorRadius ?? this.valueIndicatorRadius,
      valueIndicatorFontSize:
          valueIndicatorFontSize ?? this.valueIndicatorFontSize,
      valueIndicatorLineHeight:
          valueIndicatorLineHeight ?? this.valueIndicatorLineHeight,
      valueIndicatorLetterSpacing:
          valueIndicatorLetterSpacing ?? this.valueIndicatorLetterSpacing,
      valueIndicatorFontWeight:
          valueIndicatorFontWeight ?? this.valueIndicatorFontWeight,
      stateLayerSize: stateLayerSize ?? this.stateLayerSize,
      hoverStateOpacity: hoverStateOpacity ?? this.hoverStateOpacity,
      focusStateOpacity: focusStateOpacity ?? this.focusStateOpacity,
      pressedStateOpacity: pressedStateOpacity ?? this.pressedStateOpacity,
      tickOpacity: tickOpacity ?? this.tickOpacity,
      overlapOutlineWidth: overlapOutlineWidth ?? this.overlapOutlineWidth,
      disabledActiveOpacity:
          disabledActiveOpacity ?? this.disabledActiveOpacity,
      disabledInactiveOpacity:
          disabledInactiveOpacity ?? this.disabledInactiveOpacity,
      waveAmplitude: waveAmplitude ?? this.waveAmplitude,
      wavelength: wavelength ?? this.wavelength,
      dockSpring: dockSpring ?? this.dockSpring,
    );
  }

  @override
  MorphSliderTheme lerp(MorphSliderTheme? other, double t) {
    if (other is! MorphSliderTheme) {
      return this;
    }
    final _MorphSliderGeometryLerp geometry = _lerpGeometry(other, t);
    final _MorphSliderIndicatorLerp indicator = _lerpValueIndicator(other, t);
    final _MorphSliderStateLerp state = _lerpState(other, t);
    return MorphSliderTheme(
      height: geometry.height,
      trackHeight: geometry.trackHeight,
      handleGap: geometry.handleGap,
      handleWidth: geometry.handleWidth,
      handleHeight: geometry.handleHeight,
      pressedHandleWidth: geometry.pressedHandleWidth,
      focusHandleWidth: geometry.focusHandleWidth,
      hoverHandleWidth: geometry.hoverHandleWidth,
      trackInsideCornerSize: geometry.trackInsideCornerSize,
      trackCornerRadius: geometry.trackCornerRadius,
      stopIndicatorSize: geometry.stopIndicatorSize,
      tickSize: geometry.tickSize,
      stopIndicatorTrailingSpace: geometry.stopIndicatorTrailingSpace,
      iconEdgeInset: geometry.iconEdgeInset,
      iconSize: geometry.iconSize,
      valueIndicatorBottomSpace: indicator.bottomSpace,
      valueIndicatorWidth: indicator.width,
      valueIndicatorHeight: indicator.height,
      valueIndicatorRadius: indicator.radius,
      valueIndicatorFontSize: indicator.fontSize,
      valueIndicatorLineHeight: indicator.lineHeight,
      valueIndicatorLetterSpacing: indicator.letterSpacing,
      valueIndicatorFontWeight: indicator.fontWeight,
      stateLayerSize: state.stateLayerSize,
      hoverStateOpacity: state.hoverStateOpacity,
      focusStateOpacity: state.focusStateOpacity,
      pressedStateOpacity: state.pressedStateOpacity,
      tickOpacity: state.tickOpacity,
      overlapOutlineWidth: state.overlapOutlineWidth,
      disabledActiveOpacity: state.disabledActiveOpacity,
      disabledInactiveOpacity: state.disabledInactiveOpacity,
      waveAmplitude: state.waveAmplitude,
      wavelength: state.wavelength,
      dockSpring: state.dockSpring,
    );
  }

  /// Sizing / geometry fields lerped for [lerp].
  _MorphSliderGeometryLerp _lerpGeometry(MorphSliderTheme other, double t) {
    return (
      height: _lerp(height, other.height, t),
      trackHeight: _lerp(trackHeight, other.trackHeight, t),
      handleGap: _lerp(handleGap, other.handleGap, t),
      handleWidth: _lerp(handleWidth, other.handleWidth, t),
      handleHeight: _lerp(handleHeight, other.handleHeight, t),
      pressedHandleWidth: _lerp(
        pressedHandleWidth,
        other.pressedHandleWidth,
        t,
      ),
      focusHandleWidth: _lerp(focusHandleWidth, other.focusHandleWidth, t),
      hoverHandleWidth: _lerp(hoverHandleWidth, other.hoverHandleWidth, t),
      trackInsideCornerSize: _lerp(
        trackInsideCornerSize,
        other.trackInsideCornerSize,
        t,
      ),
      trackCornerRadius: _lerp(trackCornerRadius, other.trackCornerRadius, t),
      stopIndicatorSize: _lerp(stopIndicatorSize, other.stopIndicatorSize, t),
      tickSize: _lerp(tickSize, other.tickSize, t),
      stopIndicatorTrailingSpace: _lerp(
        stopIndicatorTrailingSpace,
        other.stopIndicatorTrailingSpace,
        t,
      ),
      iconEdgeInset: _lerp(iconEdgeInset, other.iconEdgeInset, t),
      iconSize: _lerp(iconSize, other.iconSize, t),
    );
  }

  /// Value-indicator fields lerped for [lerp].
  _MorphSliderIndicatorLerp _lerpValueIndicator(MorphSliderTheme other, double t) {
    return (
      bottomSpace: _lerp(
        valueIndicatorBottomSpace,
        other.valueIndicatorBottomSpace,
        t,
      ),
      width: _lerp(valueIndicatorWidth, other.valueIndicatorWidth, t),
      height: _lerp(valueIndicatorHeight, other.valueIndicatorHeight, t),
      radius: _lerp(valueIndicatorRadius, other.valueIndicatorRadius, t),
      fontSize: _lerp(valueIndicatorFontSize, other.valueIndicatorFontSize, t),
      lineHeight: _lerp(
        valueIndicatorLineHeight,
        other.valueIndicatorLineHeight,
        t,
      ),
      letterSpacing: _lerp(
        valueIndicatorLetterSpacing,
        other.valueIndicatorLetterSpacing,
        t,
      ),
      fontWeight: t < 0.5
          ? valueIndicatorFontWeight
          : other.valueIndicatorFontWeight,
    );
  }

  /// State-layer / opacity / motion fields lerped for [lerp].
  _MorphSliderStateLerp _lerpState(MorphSliderTheme other, double t) {
    return (
      stateLayerSize: _lerp(stateLayerSize, other.stateLayerSize, t),
      hoverStateOpacity: _lerp(hoverStateOpacity, other.hoverStateOpacity, t),
      focusStateOpacity: _lerp(focusStateOpacity, other.focusStateOpacity, t),
      pressedStateOpacity: _lerp(
        pressedStateOpacity,
        other.pressedStateOpacity,
        t,
      ),
      tickOpacity: _lerp(tickOpacity, other.tickOpacity, t),
      overlapOutlineWidth: _lerp(
        overlapOutlineWidth,
        other.overlapOutlineWidth,
        t,
      ),
      disabledActiveOpacity: _lerp(
        disabledActiveOpacity,
        other.disabledActiveOpacity,
        t,
      ),
      disabledInactiveOpacity: _lerp(
        disabledInactiveOpacity,
        other.disabledInactiveOpacity,
        t,
      ),
      waveAmplitude: _lerp(waveAmplitude, other.waveAmplitude, t),
      wavelength: _lerp(wavelength, other.wavelength, t),
      dockSpring: t < 0.5 ? dockSpring : other.dockSpring,
    );
  }

  double _lerp(double a, double b, double t) => a + (b - a) * t;
}

/// Geometry fields grouped for [MorphSliderTheme._lerpGeometry].
typedef _MorphSliderGeometryLerp = ({
  double height,
  double trackHeight,
  double handleGap,
  double handleWidth,
  double handleHeight,
  double pressedHandleWidth,
  double focusHandleWidth,
  double hoverHandleWidth,
  double trackInsideCornerSize,
  double trackCornerRadius,
  double stopIndicatorSize,
  double tickSize,
  double stopIndicatorTrailingSpace,
  double iconEdgeInset,
  double iconSize,
});

/// Value-indicator fields grouped for [MorphSliderTheme._lerpValueIndicator].
typedef _MorphSliderIndicatorLerp = ({
  double bottomSpace,
  double width,
  double height,
  double radius,
  double fontSize,
  double lineHeight,
  double letterSpacing,
  FontWeight fontWeight,
});

/// State-layer / opacity / motion fields grouped for
/// [MorphSliderTheme._lerpState].
typedef _MorphSliderStateLerp = ({
  double stateLayerSize,
  double hoverStateOpacity,
  double focusStateOpacity,
  double pressedStateOpacity,
  double tickOpacity,
  double overlapOutlineWidth,
  double disabledActiveOpacity,
  double disabledInactiveOpacity,
  double waveAmplitude,
  double wavelength,
  MorphSpring dockSpring,
});
