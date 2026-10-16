import 'package:flutter/widgets.dart';

import '../../../foundations/foundations.dart';
import '../../../foundations/interaction/morph_wavy_amplitude.dart';
import '../enums/morph_progress_enums.dart';

/// Measured layout values for a flat linear progress indicator.
@immutable
class MorphLinearProgressLayout {
  /// MorphLinearProgressLayout.
  const MorphLinearProgressLayout({
    required this.trackHeight,
    required this.gap,
    required this.dotDiameter,
    required this.dotOffset,
    required this.trailingMargin,
  });

  /// trackHeight.

  final double trackHeight;

  /// gap.
  final double gap;

  /// dotDiameter.
  final double dotDiameter;

  /// dotOffset.
  final double dotOffset;

  /// Host edge inset after the track/stop. Spec: ≥4dp.
  final double trailingMargin;
}

/// Theme values for linear progress indicators.
@immutable
class MorphLinearProgressTheme
    extends MorphThemeExtension<MorphLinearProgressTheme> {
  /// MorphLinearProgressTheme.
  const MorphLinearProgressTheme({
    this.strokeWidth = 4,
    this.trackStrokeWidth = 4,
    this.gapSize = 4,
    this.stopSize = 4,
    this.waveAmplitude = 3,
    this.determinateWavelength = 40,
    this.indeterminateWavelength = 20,
    this.wavyContainerHeight = 10,
  });

  /// defaults.

  static const MorphLinearProgressTheme defaults = MorphLinearProgressTheme();

  /// strokeWidth.

  final double strokeWidth;

  /// trackStrokeWidth.
  final double trackStrokeWidth;

  /// Track–active gap. Spec: 4dp.
  final double gapSize;

  /// Stop diameter. Spec: 4dp.
  final double stopSize;

  /// waveAmplitude.
  final double waveAmplitude;

  /// determinateWavelength.
  final double determinateWavelength;

  /// indeterminateWavelength.
  final double indeterminateWavelength;

  /// wavyContainerHeight.
  final double wavyContainerHeight;

  /// resolveFlat.

  MorphLinearProgressLayout resolveFlat(MorphProgressIndicatorSize size) =>
      switch (size) {
        MorphProgressIndicatorSize.s => const MorphLinearProgressLayout(
          trackHeight: 4,
          gap: 4,
          dotDiameter: 4,
          dotOffset: 4,
          trailingMargin: 4,
        ),
        MorphProgressIndicatorSize.m => const MorphLinearProgressLayout(
          trackHeight: 8,
          gap: 4,
          dotDiameter: 4,
          dotOffset: 2,
          trailingMargin: 4,
        ),
      };

  /// Track color. Spec: Secondary container.
  Color trackColor(MorphColorScheme scheme) => scheme.secondaryContainer;

  /// Active / stop color. Spec: Primary.
  Color activeColor(MorphColorScheme scheme) => scheme.primary;

  /// Determinate wave amplitude: smooth transitions at 10–15% and 90–98%.
  double amplitudeForProgress(double progress) =>
      morphWavyAmplitudeForProgress(progress);

  @override
  MorphLinearProgressTheme copyWith({
    double? strokeWidth,
    double? trackStrokeWidth,
    double? gapSize,
    double? stopSize,
    double? waveAmplitude,
    double? determinateWavelength,
    double? indeterminateWavelength,
    double? wavyContainerHeight,
  }) {
    return MorphLinearProgressTheme(
      strokeWidth: strokeWidth ?? this.strokeWidth,
      trackStrokeWidth: trackStrokeWidth ?? this.trackStrokeWidth,
      gapSize: gapSize ?? this.gapSize,
      stopSize: stopSize ?? this.stopSize,
      waveAmplitude: waveAmplitude ?? this.waveAmplitude,
      determinateWavelength:
          determinateWavelength ?? this.determinateWavelength,
      indeterminateWavelength:
          indeterminateWavelength ?? this.indeterminateWavelength,
      wavyContainerHeight: wavyContainerHeight ?? this.wavyContainerHeight,
    );
  }

  @override
  MorphLinearProgressTheme lerp(MorphLinearProgressTheme? other, double t) {
    if (other is! MorphLinearProgressTheme) {
      return this;
    }
    return MorphLinearProgressTheme(
      strokeWidth: _lerp(strokeWidth, other.strokeWidth, t),
      trackStrokeWidth: _lerp(trackStrokeWidth, other.trackStrokeWidth, t),
      gapSize: _lerp(gapSize, other.gapSize, t),
      stopSize: _lerp(stopSize, other.stopSize, t),
      waveAmplitude: _lerp(waveAmplitude, other.waveAmplitude, t),
      determinateWavelength: _lerp(
        determinateWavelength,
        other.determinateWavelength,
        t,
      ),
      indeterminateWavelength: _lerp(
        indeterminateWavelength,
        other.indeterminateWavelength,
        t,
      ),
      wavyContainerHeight: _lerp(
        wavyContainerHeight,
        other.wavyContainerHeight,
        t,
      ),
    );
  }

  static double _lerp(double a, double b, double t) => a + (b - a) * t;
}

/// Theme values for circular progress indicators.
@immutable
class MorphCircularProgressTheme
    extends MorphThemeExtension<MorphCircularProgressTheme> {
  /// MorphCircularProgressTheme.
  const MorphCircularProgressTheme({
    this.defaultSize = 40,
    this.wavySize = 48,
    this.defaultStrokeWidth = 4,
    this.trackStrokeWidth = 4,
    this.gapSize = 4,
    this.waveAmplitude = 1.6,
    this.wavelength = 15,
  });

  /// defaults.

  static const MorphCircularProgressTheme defaults =
      MorphCircularProgressTheme();

  /// defaultSize.

  final double defaultSize;

  /// wavySize.
  final double wavySize;

  /// defaultStrokeWidth.
  final double defaultStrokeWidth;

  /// trackStrokeWidth.
  final double trackStrokeWidth;

  /// Track–active gap. Spec: 4dp.
  final double gapSize;

  /// waveAmplitude.
  final double waveAmplitude;

  /// wavelength.
  final double wavelength;

  /// trackColor.

  Color trackColor(MorphColorScheme scheme) => scheme.secondaryContainer;

  /// activeColor.

  Color activeColor(MorphColorScheme scheme) => scheme.primary;

  /// Determinate wave amplitude: smooth transitions at 10–15% and 90–98%.
  double amplitudeForProgress(double progress) =>
      morphWavyAmplitudeForProgress(progress);

  @override
  MorphCircularProgressTheme copyWith({
    double? defaultSize,
    double? wavySize,
    double? defaultStrokeWidth,
    double? trackStrokeWidth,
    double? gapSize,
    double? waveAmplitude,
    double? wavelength,
  }) {
    return MorphCircularProgressTheme(
      defaultSize: defaultSize ?? this.defaultSize,
      wavySize: wavySize ?? this.wavySize,
      defaultStrokeWidth: defaultStrokeWidth ?? this.defaultStrokeWidth,
      trackStrokeWidth: trackStrokeWidth ?? this.trackStrokeWidth,
      gapSize: gapSize ?? this.gapSize,
      waveAmplitude: waveAmplitude ?? this.waveAmplitude,
      wavelength: wavelength ?? this.wavelength,
    );
  }

  @override
  MorphCircularProgressTheme lerp(MorphCircularProgressTheme? other, double t) {
    if (other is! MorphCircularProgressTheme) {
      return this;
    }
    return MorphCircularProgressTheme(
      defaultSize: _lerp(defaultSize, other.defaultSize, t),
      wavySize: _lerp(wavySize, other.wavySize, t),
      defaultStrokeWidth: _lerp(
        defaultStrokeWidth,
        other.defaultStrokeWidth,
        t,
      ),
      trackStrokeWidth: _lerp(trackStrokeWidth, other.trackStrokeWidth, t),
      gapSize: _lerp(gapSize, other.gapSize, t),
      waveAmplitude: _lerp(waveAmplitude, other.waveAmplitude, t),
      wavelength: _lerp(wavelength, other.wavelength, t),
    );
  }

  static double _lerp(double a, double b, double t) => a + (b - a) * t;
}

/// Theme values for progress indicator widgets.
@immutable
class MorphProgressIndicatorTheme
    extends MorphThemeExtension<MorphProgressIndicatorTheme> {
  /// MorphProgressIndicatorTheme.
  const MorphProgressIndicatorTheme({
    this.linear = MorphLinearProgressTheme.defaults,
    this.circular = MorphCircularProgressTheme.defaults,
  });

  /// defaults.

  static const MorphProgressIndicatorTheme defaults =
      MorphProgressIndicatorTheme();

  /// linear.

  final MorphLinearProgressTheme linear;

  /// circular.
  final MorphCircularProgressTheme circular;

  @override
  MorphProgressIndicatorTheme copyWith({
    MorphLinearProgressTheme? linear,
    MorphCircularProgressTheme? circular,
  }) {
    return MorphProgressIndicatorTheme(
      linear: linear ?? this.linear,
      circular: circular ?? this.circular,
    );
  }

  @override
  MorphProgressIndicatorTheme lerp(
    MorphProgressIndicatorTheme? other,
    double t,
  ) {
    if (other is! MorphProgressIndicatorTheme) {
      return this;
    }
    return MorphProgressIndicatorTheme(
      linear: linear.lerp(other.linear, t),
      circular: circular.lerp(other.circular, t),
    );
  }
}
