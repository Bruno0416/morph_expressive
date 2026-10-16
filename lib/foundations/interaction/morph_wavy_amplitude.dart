/// Smooth, normalized wavy-track amplitude near the ends of determinate
/// sliders and progress indicators.
///
/// The wave fades in over 10–15% and fades out over 90–98%. Both ramps
/// use smoothstep, so the amplitude and its first derivative are continuous
/// at the boundaries. Callers can still override this default curve.
double morphWavyAmplitudeForProgress(double progress) {
  if (progress <= 0.10 || progress >= 0.98) {
    return 0.0;
  }
  if (progress < 0.15) {
    return _smoothstep((progress - 0.10) / 0.05);
  }
  if (progress <= 0.90) {
    return 1.0;
  }
  return 1.0 - _smoothstep((progress - 0.90) / 0.08);
}

double _smoothstep(double t) => t * t * (3.0 - 2.0 * t);
