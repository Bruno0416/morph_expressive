/// Spec density levels 0, −1, −2, −3.
///
/// Density shrinks container height (−4dp per level).
enum MorphSegmentedButtonDensity {
  /// Level 0 — full token container height (40dp).
  regular,

  /// Level −1 (36dp).
  comfortable,

  /// Level −2 (32dp).
  compact,

  /// Level −3 (28dp).
  dense,
}

/// Helpers for [MorphSegmentedButtonDensity].
extension MorphSegmentedButtonDensityX on MorphSegmentedButtonDensity {
  /// Spec density level (0, −1, −2, −3).
  int get level => switch (this) {
    MorphSegmentedButtonDensity.regular => 0,
    MorphSegmentedButtonDensity.comfortable => -1,
    MorphSegmentedButtonDensity.compact => -2,
    MorphSegmentedButtonDensity.dense => -3,
  };

  /// Height delta in dp (−4.0 per density level).
  double get heightAdjustment => level * 4.0;
}
