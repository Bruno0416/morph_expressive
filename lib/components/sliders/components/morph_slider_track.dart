// Derived from Material 3 Expressive by Paa Developments (MIT), modified
// in 2026 for Morph Expressive (naming, layout, styling and/or motion).
// Follows Material 3 Compose design/reference patterns; direct inclusion
// of Android Open Source Project Apache-2.0 code is not established here.
// See NOTICE for original copyright and third-party attribution.

import 'package:flutter/widgets.dart';
import 'package:morph_expressive/components/sliders/morph_sliders.dart'
    show MorphSlider;
import 'package:morph_expressive/morph_components.dart' show MorphSlider;

import '../enums/morph_slider_enums.dart';
import '../styles/morph_slider_theme.dart';
import 'morph_slider_track_painter.dart';

/// Default expressive track for a single-value [MorphSlider].
class MorphSliderTrack extends StatelessWidget {
  /// MorphSliderTrack.
  const MorphSliderTrack({
    required this.fraction,
    required this.tickFractions,
    required this.colors,
    required this.theme,
    required this.axis,
    required this.textDirection,
    required this.handleThickness,
    this.trackKind = MorphSliderTrackKind.standard,
    this.trackHeight,
    this.cornerRadius,
    this.stopIndicatorSize,
    this.tickSize,
    this.edgeInset,
    this.drawDots = true,
    this.isWavy = false,
    this.waveAmplitude = 0,
    this.wavelength = 40,
    this.phase = 0,
    this.amplitudeFactor = 1,
    super.key,
  });

  /// fraction.

  final double fraction;

  /// tickFractions.
  final List<double> tickFractions;

  /// colors.
  final MorphSliderColors colors;

  /// theme.
  final MorphSliderTheme theme;

  /// axis.
  final Axis axis;

  /// textDirection.
  final TextDirection textDirection;

  /// handleThickness.
  final double handleThickness;

  /// trackKind.
  final MorphSliderTrackKind trackKind;

  /// trackHeight.
  final double? trackHeight;

  /// Outer corner radius. Defaults to [MorphSliderTheme.trackCornerRadius].
  final double? cornerRadius;

  /// stopIndicatorSize.
  final double? stopIndicatorSize;

  /// tickSize.
  final double? tickSize;

  /// edgeInset.
  final double? edgeInset;

  /// drawDots.
  final bool drawDots;

  /// isWavy.
  final bool isWavy;

  /// waveAmplitude.
  final double waveAmplitude;

  /// wavelength.
  final double wavelength;

  /// phase.
  final double phase;

  /// amplitudeFactor.
  final double amplitudeFactor;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: MorphSliderTrackPainter(
        mode: MorphSliderPaintMode.single,
        trackKind: trackKind,
        activeStartFraction: 0,
        activeEndFraction: fraction,
        tickFractions: tickFractions,
        colors: colors,
        trackHeight: trackHeight ?? theme.trackHeight,
        handleGap: theme.handleGap,
        handleThickness: handleThickness,
        insideCornerSize: theme.trackInsideCornerSize,
        cornerRadius: cornerRadius ?? theme.trackCornerRadius,
        stopIndicatorSize: stopIndicatorSize ?? theme.stopIndicatorSize,
        tickSize: tickSize ?? theme.tickSize,
        edgeInset: edgeInset ?? theme.stopIndicatorTrailingSpace,
        axis: axis,
        textDirection: textDirection,
        drawDots: drawDots,
        isWavy: isWavy,
        waveAmplitude: waveAmplitude,
        wavelength: wavelength,
        phase: phase,
        amplitudeFactor: amplitudeFactor,
      ),
      child: const SizedBox.expand(),
    );
  }
}
