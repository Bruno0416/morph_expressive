// Derived from Material 3 Expressive by Paa Developments (MIT), modified
// in 2026 for Morph Expressive (naming, layout, styling and/or motion).
// Follows Material 3 Compose design/reference patterns; direct inclusion
// of Android Open Source Project Apache-2.0 code is not established here.
// See NOTICE for original copyright and third-party attribution.

import 'package:flutter/widgets.dart';

import '../enums/morph_slider_enums.dart';
import '../styles/morph_slider_theme.dart';
import 'morph_slider_track.dart';

/// Centered active-track variant — active fill grows from the midpoint.
class MorphSliderCenteredTrack extends StatelessWidget {
  /// MorphSliderCenteredTrack.
  const MorphSliderCenteredTrack({
    required this.fraction,
    required this.tickFractions,
    required this.colors,
    required this.theme,
    required this.axis,
    required this.textDirection,
    required this.handleThickness,
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
    return MorphSliderTrack(
      fraction: fraction,
      tickFractions: tickFractions,
      colors: colors,
      theme: theme,
      axis: axis,
      textDirection: textDirection,
      handleThickness: handleThickness,
      trackKind: MorphSliderTrackKind.centered,
      trackHeight: trackHeight,
      cornerRadius: cornerRadius,
      stopIndicatorSize: stopIndicatorSize,
      tickSize: tickSize,
      edgeInset: edgeInset,
      drawDots: drawDots,
      isWavy: isWavy,
      waveAmplitude: waveAmplitude,
      wavelength: wavelength,
      phase: phase,
      amplitudeFactor: amplitudeFactor,
    );
  }
}
