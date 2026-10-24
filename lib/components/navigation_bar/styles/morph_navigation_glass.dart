import 'package:flutter/widgets.dart';

/// Opt-in frosted surface for a navigation bar. Null keeps the opaque surface.
@immutable
class MorphNavigationGlass {
  const MorphNavigationGlass({
    this.blurX = 8,
    this.blurY = 8,
    this.tint,
    this.tintOpacity = 0.72,
    this.gradient,
    this.borderColor,
    this.borderWidth = 1,
    this.blendMode = BlendMode.srcOver,
    this.opaqueInHighContrast = true,
    this.blurDuringScroll = false,
    this.blurRevealProgress = 0.35,
    this.webBackdropBlur = true,
  }) : assert(blurX >= 0),
       assert(blurY >= 0),
       assert(blurRevealProgress >= 0 && blurRevealProgress <= 1),
       assert(tintOpacity >= 0 && tintOpacity <= 1),
       assert(borderWidth >= 0);

  /// Gaussian blur strength on each axis, in logical pixels.
  /// Defaults to 8 for a cheaper frosted treatment. Use 0 to disable blur
  /// while retaining the tint, gradient and border. Larger values are costly
  /// over moving or animated content.
  final double blurX;
  final double blurY;

  /// Uses the bar's background color when omitted.
  final Color? tint;
  final double tintOpacity;

  /// Optional highlight painted over the tint.
  final Gradient? gradient;
  final Color? borderColor;
  final double borderWidth;
  final BlendMode blendMode;

  /// Falls back to an opaque surface for the system high-contrast preference.
  final bool opaqueInHighContrast;

  /// Keep live backdrop blur while the host's body scrolls. By default only
  /// tint/gradient/border are painted during scrolling, and blur returns when
  /// scrolling stops. This avoids resampling the moving backdrop every frame.
  /// Standalone bars without a host always retain their blur.
  final bool blurDuringScroll;

  /// On native platforms, resume blur at this fraction of the floating bar's
  /// upward reveal (0 = immediately, 1 = fully shown), even if its scroll is
  /// still active. This only affects bars managed by MorphNavigationBarHost;
  /// web waits for scrolling and motion to stop to protect frame rate.
  final double blurRevealProgress;

  /// Whether to use the real (more expensive) backdrop blur on Flutter Web.
  /// Defaults to true for backwards compatibility. Set false to render the
  /// tint, gradient and border without a BackdropFilter on web; native targets
  /// continue to use real blur. Useful for previews with animated backgrounds.
  final bool webBackdropBlur;
}
