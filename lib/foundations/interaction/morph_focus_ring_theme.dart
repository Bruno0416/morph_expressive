import 'package:flutter/widgets.dart';

import '../color/morph_color_scheme.dart';
import '../theme/morph_theme_extension.dart';

/// Shared tokens for the Material 3 Expressive keyboard focus ring.
@immutable
class MorphFocusRingTheme extends MorphThemeExtension<MorphFocusRingTheme> {
  /// Creates focus ring theme tokens.
  const MorphFocusRingTheme({this.color, this.width = 2, this.gap = 2});

  /// Package defaults.
  static const MorphFocusRingTheme defaults = MorphFocusRingTheme();

  /// Optional override; when null, resolves to [MorphColorScheme.primary].
  final Color? color;

  /// Stroke width of the focus ring outline (dp).
  final double width;

  /// Gap between the component edge and the focus ring outline (dp).
  final double gap;

  /// Total outset past the component edge (`gap + width`).
  double get outset => gap + width;

  /// Resolved ring color for [scheme].
  Color resolveColor(MorphColorScheme scheme) => color ?? scheme.primary;

  @override
  MorphFocusRingTheme copyWith({
    Color? color,
    bool clearColor = false,
    double? width,
    double? gap,
  }) {
    return MorphFocusRingTheme(
      color: clearColor ? null : (color ?? this.color),
      width: width ?? this.width,
      gap: gap ?? this.gap,
    );
  }

  @override
  MorphFocusRingTheme lerp(MorphFocusRingTheme? other, double t) {
    if (other is! MorphFocusRingTheme) {
      return this;
    }
    return MorphFocusRingTheme(
      color: Color.lerp(color, other.color, t) ?? color ?? other.color,
      width: _lerpDouble(width, other.width, t),
      gap: _lerpDouble(gap, other.gap, t),
    );
  }

  static double _lerpDouble(double a, double b, double t) => a + (b - a) * t;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is MorphFocusRingTheme &&
        other.color == color &&
        other.width == width &&
        other.gap == gap;
  }

  @override
  int get hashCode => Object.hash(color, width, gap);
}
