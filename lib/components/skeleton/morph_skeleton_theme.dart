import 'package:flutter/widgets.dart';

import '../../foundations/theme/morph_theme_extension.dart';

/// Group defaults. Widget values override these, then color-scheme defaults.
@immutable
class MorphSkeletonTheme extends MorphThemeExtension<MorphSkeletonTheme> {
  const MorphSkeletonTheme({
    this.duration = const Duration(milliseconds: 1600),
    this.transitionDuration = const Duration(milliseconds: 180),
    this.intensity = .35,
    this.angle = 0,
    this.baseColor,
    this.highlightColor,
  });
  static const defaults = MorphSkeletonTheme();
  final Duration duration, transitionDuration;
  final double intensity;

  /// Shimmer band tilt in degrees; see [MorphSkeletonGroup.angle].
  final double angle;
  final Color? baseColor, highlightColor;
  @override
  MorphSkeletonTheme copyWith({
    Duration? duration,
    Duration? transitionDuration,
    double? intensity,
    double? angle,
    Color? baseColor,
    Color? highlightColor,
  }) => MorphSkeletonTheme(
    duration: duration ?? this.duration,
    transitionDuration: transitionDuration ?? this.transitionDuration,
    intensity: intensity ?? this.intensity,
    angle: angle ?? this.angle,
    baseColor: baseColor ?? this.baseColor,
    highlightColor: highlightColor ?? this.highlightColor,
  );
  @override
  MorphSkeletonTheme lerp(MorphSkeletonTheme? other, double t) => other == null
      ? this
      : MorphSkeletonTheme(
          duration: Duration(
            microseconds:
                (duration.inMicroseconds +
                        (other.duration.inMicroseconds -
                                duration.inMicroseconds) *
                            t)
                    .round(),
          ),
          transitionDuration: Duration(
            microseconds:
                (transitionDuration.inMicroseconds +
                        (other.transitionDuration.inMicroseconds -
                                transitionDuration.inMicroseconds) *
                            t)
                    .round(),
          ),
          intensity: intensity + (other.intensity - intensity) * t,
          angle: angle + (other.angle - angle) * t,
          baseColor: Color.lerp(baseColor, other.baseColor, t),
          highlightColor: Color.lerp(highlightColor, other.highlightColor, t),
        );
  @override
  bool operator ==(Object other) =>
      other is MorphSkeletonTheme &&
      duration == other.duration &&
      transitionDuration == other.transitionDuration &&
      intensity == other.intensity &&
      angle == other.angle &&
      baseColor == other.baseColor &&
      highlightColor == other.highlightColor;
  @override
  int get hashCode => Object.hash(
    duration,
    transitionDuration,
    intensity,
    angle,
    baseColor,
    highlightColor,
  );
}
