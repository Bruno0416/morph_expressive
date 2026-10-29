import 'package:flutter/foundation.dart';

/// Progressive surface tint and background blur for `MorphAppBar.frosted`.
///
/// Both effects start at zero at the *bottom* edge and grow towards the top.
/// The tint follows a continuous gradient while the blur uses clipped bands
/// to keep the number of backdrop filters bounded on native devices.
@immutable
class MorphAppBarGlass {
  const MorphAppBarGlass({
    this.topOpacity = 0.90,
    this.maxBlurSigma = 16,
    this.blurBands = 7,
    this.tintCurvePower = 0.38,
    this.blurCurvePower = 1.8,
    this.blurClearExtent = 4,
  }) : assert(topOpacity >= 0 && topOpacity <= 1),
       assert(maxBlurSigma >= 0),
       assert(blurBands >= 2 && blurBands <= 8),
       assert(tintCurvePower > 0),
       assert(blurCurvePower > 0),
       assert(blurClearExtent >= 0);

  /// Surface tint opacity at the top; always zero at the bottom.
  final double topOpacity;

  /// Maximum upper-edge Gaussian blur sigma; zero disables backdrop filters.
  final double maxBlurSigma;

  /// Number of blur levels including the completely clear bottom region.
  ///
  /// Seven levels use six backdrop filters, whose strips become progressively
  /// narrower near the bottom. Lower this to reduce GPU work on slow devices.
  final int blurBands;

  /// Shapes the exponential upper half of the surface tint gradient.
  ///
  /// The lower half always increases linearly from zero; the upper half
  /// accelerates exponentially to [topOpacity]. Lower values show the tint
  /// sooner, while higher values concentrate it nearer the top. The two
  /// halves meet with matching slopes. Must be positive.
  final double tintCurvePower;

  /// Controls how gradually blur grows from the sharp lower edge.
  ///
  /// Values above 1 soften the first blurred bands near the bottom; 1 is
  /// linear. Lower values increase blur sooner. Must be positive.
  final double blurCurvePower;

  /// Unfiltered logical pixels at the bottom of the AppBar (default: 4).
  ///
  /// Blur starts above this edge with narrow, low-sigma strips. The surface
  /// tint still reaches exactly zero opacity at the bottommost pixel.
  /// Increase this only if the blur edge is visible on your device.
  final double blurClearExtent;
}
