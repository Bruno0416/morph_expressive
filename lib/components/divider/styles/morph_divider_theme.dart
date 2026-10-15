import 'package:flutter/widgets.dart';

import '../../../foundations/foundations.dart';
import '../enums/morph_divider_inset.dart';

/// Theme values for MorphDivider.
@immutable
class MorphDividerTheme extends MorphThemeExtension<MorphDividerTheme> {
  /// Creates divider theme values.
  const MorphDividerTheme({
    this.thickness = 1,
    this.insetStart = 16,
    this.insetEnd = 0,
    this.middleInsetStart = 16,
    this.middleInsetEnd = 16,
    this.textGap = 4,
    this.endMargin = 8,
    this.bottomMargin = 8,
  });

  /// Spec defaults.
  static const MorphDividerTheme defaults = MorphDividerTheme();

  /// Line thickness.
  final double thickness;

  /// Leading inset for [MorphDividerInset.inset].
  final double insetStart;

  /// Trailing inset for [MorphDividerInset.inset].
  final double insetEnd;

  /// Leading inset for [MorphDividerInset.middle].
  final double middleInsetStart;

  /// Trailing inset for [MorphDividerInset.middle].
  final double middleInsetEnd;

  /// Gap between a divider and supporting text. The line does not apply this.
  final double textGap;

  /// Trailing margin used when outer margin is enabled.
  final double endMargin;

  /// Bottom margin used when outer margin is enabled.
  final double bottomMargin;

  /// Line color. Outline variant in both light and dark schemes.
  Color color(MorphColorScheme scheme) => scheme.outlineVariant;

  /// Leading inset for [inset] before a widget override.
  double startFor(MorphDividerInset inset) {
    return switch (inset) {
      MorphDividerInset.full => 0,
      MorphDividerInset.inset => insetStart,
      MorphDividerInset.middle => middleInsetStart,
    };
  }

  /// Trailing inset for [inset] before a widget override.
  double endFor(MorphDividerInset inset) {
    return switch (inset) {
      MorphDividerInset.full => 0,
      MorphDividerInset.inset => insetEnd,
      MorphDividerInset.middle => middleInsetEnd,
    };
  }

  @override
  MorphDividerTheme copyWith({
    double? thickness,
    double? insetStart,
    double? insetEnd,
    double? middleInsetStart,
    double? middleInsetEnd,
    double? textGap,
    double? endMargin,
    double? bottomMargin,
  }) {
    return MorphDividerTheme(
      thickness: thickness ?? this.thickness,
      insetStart: insetStart ?? this.insetStart,
      insetEnd: insetEnd ?? this.insetEnd,
      middleInsetStart: middleInsetStart ?? this.middleInsetStart,
      middleInsetEnd: middleInsetEnd ?? this.middleInsetEnd,
      textGap: textGap ?? this.textGap,
      endMargin: endMargin ?? this.endMargin,
      bottomMargin: bottomMargin ?? this.bottomMargin,
    );
  }

  @override
  MorphDividerTheme lerp(MorphDividerTheme? other, double t) {
    if (other is! MorphDividerTheme) {
      return this;
    }
    return MorphDividerTheme(
      thickness: _lerpDouble(thickness, other.thickness, t),
      insetStart: _lerpDouble(insetStart, other.insetStart, t),
      insetEnd: _lerpDouble(insetEnd, other.insetEnd, t),
      middleInsetStart: _lerpDouble(
        middleInsetStart,
        other.middleInsetStart,
        t,
      ),
      middleInsetEnd: _lerpDouble(middleInsetEnd, other.middleInsetEnd, t),
      textGap: _lerpDouble(textGap, other.textGap, t),
      endMargin: _lerpDouble(endMargin, other.endMargin, t),
      bottomMargin: _lerpDouble(bottomMargin, other.bottomMargin, t),
    );
  }

  double _lerpDouble(double a, double b, double t) => a + (b - a) * t;
}
