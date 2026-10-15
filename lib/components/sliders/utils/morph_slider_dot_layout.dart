import 'package:flutter/widgets.dart';

import '../enums/morph_slider_enums.dart';
import '../styles/morph_slider_theme.dart';
import '../utils/morph_slider_math.dart';
import 'morph_slider_dot_geometry.dart';

/// One stop/tick marker along the slider track.
@immutable
class MorphSliderDotPlacement {
  /// MorphSliderDotPlacement.
  const MorphSliderDotPlacement({
    required this.primary,
    required this.color,
    required this.size,
    required this.active,
  });

  /// Position along the primary track axis (x for horizontal, y for vertical).
  final double primary;

  /// color.
  final Color color;

  /// size.
  final double size;

  /// active.
  final bool active;
}

/// Shared stop/tick placement for canvas paint and custom `dotBuilder` overlays.
abstract final class MorphSliderDotLayout {
  const MorphSliderDotLayout._();

  /// resolve.
  static List<MorphSliderDotPlacement> resolve({
    required Size size,
    required MorphSliderPaintMode mode,
    required MorphSliderTrackKind trackKind,
    required double activeStartFraction,
    required double activeEndFraction,
    required List<double> tickFractions,
    required MorphSliderColors colors,
    required double trackHeight,
    required double handleGap,
    required double handleThickness,
    required double stopIndicatorSize,
    required double tickSize,
    required double edgeInset,
    required Axis axis,
    required TextDirection textDirection,
  }) {
    final MorphSliderDotGeometry? geometry = MorphSliderDotGeometry.resolve(
      size: size,
      mode: mode,
      trackKind: trackKind,
      activeStartFraction: activeStartFraction,
      activeEndFraction: activeEndFraction,
      trackHeight: trackHeight,
      handleGap: handleGap,
      handleThickness: handleThickness,
      axis: axis,
    );
    if (geometry == null) {
      return const <MorphSliderDotPlacement>[];
    }

    final out = <MorphSliderDotPlacement>[];
    _appendEndStops(
      out,
      geometry: geometry,
      colors: colors,
      stopIndicatorSize: stopIndicatorSize,
      edgeInset: edgeInset,
    );
    _appendTicks(
      out,
      geometry: geometry,
      tickFractions: tickFractions,
      colors: colors,
      tickSize: tickSize,
      stopIndicatorSize: stopIndicatorSize,
      edgeInset: edgeInset,
    );
    return out;
  }

  static void _appendEndStops(
    List<MorphSliderDotPlacement> out, {
    required MorphSliderDotGeometry geometry,
    required MorphSliderColors colors,
    required double stopIndicatorSize,
    required double edgeInset,
  }) {
    // [edgeInset] is clear space between the track edge and the marker's outer
    // edge; centers are therefore inset by spacing + half the marker size.
    final double stopRadius = stopIndicatorSize / 2;
    final double stopStart = geometry.sliderStart + edgeInset + stopRadius;
    final double stopEnd = geometry.sliderEnd - edgeInset - stopRadius;
    if (stopEnd <= stopStart) {
      return;
    }
    if (!_onActiveOrGap(stopStart, geometry)) {
      out.add(
        MorphSliderDotPlacement(
          primary: stopStart,
          color: colors.stopIndicator,
          size: stopIndicatorSize,
          active: false,
        ),
      );
    }
    if (!_onActiveOrGap(stopEnd, geometry)) {
      out.add(
        MorphSliderDotPlacement(
          primary: stopEnd,
          color: colors.stopIndicator,
          size: stopIndicatorSize,
          active: false,
        ),
      );
    }
  }

  static void _appendTicks(
    List<MorphSliderDotPlacement> out, {
    required MorphSliderDotGeometry geometry,
    required List<double> tickFractions,
    required MorphSliderColors colors,
    required double tickSize,
    required double stopIndicatorSize,
    required double edgeInset,
  }) {
    if (tickFractions.isEmpty) {
      return;
    }

    // Discrete ticks share the same padded span as the end stops.
    final double stopRadius = stopIndicatorSize / 2;
    final double tickStart = geometry.sliderStart + edgeInset + stopRadius;
    final double tickEnd = geometry.sliderEnd - edgeInset - stopRadius;
    final double tickCenterGapStart = geometry.centered
        ? geometry.centerAxis - geometry.endGap
        : 0;
    final double tickCenterGapEnd = geometry.centered
        ? geometry.centerAxis + geometry.endGap
        : 0;
    final double tickStartGapLo = geometry.valueStart - geometry.startGap;
    final double tickStartGapHi = geometry.valueStart + geometry.startGap;
    final double tickEndGapLo = geometry.valueEnd - geometry.endGap;
    final double tickEndGapHi = geometry.valueEnd + geometry.endGap;

    for (var i = 0; i < tickFractions.length; i++) {
      // Ends are owned by stop indicators.
      if (i == 0 || i == tickFractions.length - 1) {
        continue;
      }
      final double centerTick = MorphSliderMath.lerp(
        tickStart,
        tickEnd,
        tickFractions[i],
      );
      if (_skipTick(
        centerTick,
        geometry: geometry,
        tickCenterGapStart: tickCenterGapStart,
        tickCenterGapEnd: tickCenterGapEnd,
        tickStartGapLo: tickStartGapLo,
        tickStartGapHi: tickStartGapHi,
        tickEndGapLo: tickEndGapLo,
        tickEndGapHi: tickEndGapHi,
      )) {
        continue;
      }
      final bool inActive =
          centerTick >= geometry.activeStart &&
          centerTick <= geometry.activeEnd;
      out.add(
        MorphSliderDotPlacement(
          primary: centerTick,
          color: inActive ? colors.activeTick : colors.inactiveTick,
          size: tickSize,
          active: inActive,
        ),
      );
    }
  }

  static bool _skipTick(
    double centerTick, {
    required MorphSliderDotGeometry geometry,
    required double tickCenterGapStart,
    required double tickCenterGapEnd,
    required double tickStartGapLo,
    required double tickStartGapHi,
    required double tickEndGapLo,
    required double tickEndGapHi,
  }) {
    if (geometry.centered &&
        centerTick >= tickCenterGapStart &&
        centerTick <= tickCenterGapEnd) {
      return true;
    }
    if (geometry.range &&
        centerTick >= tickStartGapLo &&
        centerTick <= tickStartGapHi) {
      return true;
    }
    return centerTick >= tickEndGapLo && centerTick <= tickEndGapHi;
  }

  static bool _onActiveOrGap(double primary, MorphSliderDotGeometry geometry) {
    if (primary >= geometry.activeStart && primary <= geometry.activeEnd) {
      return true;
    }
    if (geometry.range &&
        primary >= geometry.valueStart - geometry.startGap &&
        primary <= geometry.valueStart + geometry.startGap) {
      return true;
    }
    if (primary >= geometry.valueEnd - geometry.endGap &&
        primary <= geometry.valueEnd + geometry.endGap) {
      return true;
    }
    if (geometry.centered &&
        geometry.startGap > 0 &&
        primary >= geometry.valueEnd - geometry.startGap &&
        primary <= geometry.valueEnd + geometry.startGap) {
      return true;
    }
    return false;
  }
}
