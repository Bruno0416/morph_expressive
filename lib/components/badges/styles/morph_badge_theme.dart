import 'package:flutter/widgets.dart';

import '../../../foundations/foundations.dart';

/// Theme values for `MorphBadge`.
@immutable
class MorphBadgeTheme extends MorphThemeExtension<MorphBadgeTheme> {
  /// MorphBadgeTheme.
  const MorphBadgeTheme({
    this.dotSize = 6,
    this.dotCornerRadius = 3,
    this.smallOffset = const Offset(6, 6),
    this.largeOffset = const Offset(13, 15),
    this.labelHorizontalPadding = 5,
    this.labelVerticalPadding = 1,
    this.labelMinSize = 18,
    this.labelCornerRadius = 9,
    this.labelFontSize = 11,
    this.labelFontWeight = FontWeight.w600,
    this.labelLineHeight = 16,
    this.labelLetterSpacing = 0.5,
    this.density,
  });

  /// defaults.

  static const MorphBadgeTheme defaults = MorphBadgeTheme();

  /// Small (dot) badge diameter. Spec: 6dp.
  final double dotSize;

  /// Small badge corner radius. Spec: 3dp (fully rounded circle).
  final double dotCornerRadius;

  /// Distance from icon top-trailing corner to badge bottom-leading (W×H).
  /// Spec: 6×6dp for small badges.
  final Offset smallOffset;

  /// Distance from icon top-trailing corner to badge bottom-leading (W×H).
  /// Standard geometry: 13×15dp, which keeps the badge center where the
  /// 16dp spec badge (12×14dp) had it.
  final Offset largeOffset;

  /// Horizontal padding inside the large badge at standard density (5dp).
  final double labelHorizontalPadding;

  /// Vertical padding inside the large badge at standard density (1dp).
  final double labelVerticalPadding;

  /// Minimum width and height for the large badge at standard density (18dp).
  final double labelMinSize;

  /// Large badge corner radius at standard density: half of [labelMinSize], so
  /// single characters stay circular and longer labels become pills.
  final double labelCornerRadius;

  /// Large badge label font size. Spec: 11pt.
  final double labelFontSize;

  /// Large badge label weight. Semi-bold (600) for legibility at 11pt.
  final FontWeight labelFontWeight;

  /// Large badge label line height. Spec: 16pt.
  final double labelLineHeight;

  /// Large badge label tracking. Spec: 0.5pt.
  final double labelLetterSpacing;

  /// Density override for this badge theme.
  ///
  /// When null, badges follow the global `MorphThemeData.density`. Density
  /// only moves the large badge's padding, minimum size, radius and placement;
  /// the font size, weight and the small dot never change.
  final MorphDensity? density;

  /// This theme with the layout metrics of [density] applied.
  ///
  /// [MorphDensity.standard] returns the theme unchanged, so the approved
  /// geometry is preserved; compact tightens the large badge down to the
  /// legacy 16dp footprint and comfortable adds a little air.
  MorphBadgeTheme resolveDensity(MorphDensity global) {
    final MorphDensity effective = density ?? global;
    if (effective == MorphDensity.standard) {
      return this;
    }
    final bool compact = effective == MorphDensity.compact;
    final double h = compact ? -1 : 1;
    final double v = compact ? -1 : 0.5;
    final double size = compact ? -2 : 1;
    final double radius = compact ? -1 : 0.5;
    final double place = compact ? -1 : 0.5;
    double adjust(double value, double delta) =>
        MorphDensityMetrics.adjust(value, delta);
    return copyWith(
      largeOffset: Offset(
        adjust(largeOffset.dx, place),
        adjust(largeOffset.dy, place),
      ),
      labelHorizontalPadding: adjust(labelHorizontalPadding, h),
      labelVerticalPadding: adjust(labelVerticalPadding, v),
      labelMinSize: adjust(labelMinSize, size),
      labelCornerRadius: adjust(labelCornerRadius, radius),
    );
  }

  /// The labelBorderRadius.
  BorderRadius get labelBorderRadius =>
      BorderRadius.circular(labelCornerRadius);

  /// Dot shape border radius.
  BorderRadius get dotBorderRadius => BorderRadius.circular(dotCornerRadius);

  /// Container color. Spec: Error.
  Color containerColor(MorphColorScheme scheme) => scheme.error;

  /// Label color. Spec: On error.
  Color labelColor(MorphColorScheme scheme) => scheme.onError;

  /// Label text style based on type-scale labelSmall with spec metrics.
  TextStyle labelStyle(MorphTypeScale type, MorphColorScheme scheme) =>
      type.labelSmall.copyWith(
        fontSize: labelFontSize,
        fontWeight: labelFontWeight,
        height: labelLineHeight / labelFontSize,
        letterSpacing: labelLetterSpacing,
        color: labelColor(scheme),
      );

  @override
  MorphBadgeTheme copyWith({
    double? dotSize,
    double? dotCornerRadius,
    Offset? smallOffset,
    Offset? largeOffset,
    double? labelHorizontalPadding,
    double? labelVerticalPadding,
    double? labelMinSize,
    double? labelCornerRadius,
    double? labelFontSize,
    FontWeight? labelFontWeight,
    double? labelLineHeight,
    double? labelLetterSpacing,
    MorphDensity? density,
  }) {
    return MorphBadgeTheme(
      dotSize: dotSize ?? this.dotSize,
      dotCornerRadius: dotCornerRadius ?? this.dotCornerRadius,
      smallOffset: smallOffset ?? this.smallOffset,
      largeOffset: largeOffset ?? this.largeOffset,
      labelHorizontalPadding:
          labelHorizontalPadding ?? this.labelHorizontalPadding,
      labelVerticalPadding: labelVerticalPadding ?? this.labelVerticalPadding,
      labelMinSize: labelMinSize ?? this.labelMinSize,
      labelCornerRadius: labelCornerRadius ?? this.labelCornerRadius,
      labelFontSize: labelFontSize ?? this.labelFontSize,
      labelFontWeight: labelFontWeight ?? this.labelFontWeight,
      labelLineHeight: labelLineHeight ?? this.labelLineHeight,
      labelLetterSpacing: labelLetterSpacing ?? this.labelLetterSpacing,
      density: density ?? this.density,
    );
  }

  @override
  MorphBadgeTheme lerp(MorphBadgeTheme? other, double t) {
    if (other is! MorphBadgeTheme) {
      return this;
    }
    return MorphBadgeTheme(
      dotSize: _lerpDouble(dotSize, other.dotSize, t)!,
      dotCornerRadius: _lerpDouble(dotCornerRadius, other.dotCornerRadius, t)!,
      smallOffset: Offset.lerp(smallOffset, other.smallOffset, t)!,
      largeOffset: Offset.lerp(largeOffset, other.largeOffset, t)!,
      labelHorizontalPadding: _lerpDouble(
        labelHorizontalPadding,
        other.labelHorizontalPadding,
        t,
      )!,
      labelVerticalPadding: _lerpDouble(
        labelVerticalPadding,
        other.labelVerticalPadding,
        t,
      )!,
      labelMinSize: _lerpDouble(labelMinSize, other.labelMinSize, t)!,
      labelCornerRadius: _lerpDouble(
        labelCornerRadius,
        other.labelCornerRadius,
        t,
      )!,
      labelFontSize: _lerpDouble(labelFontSize, other.labelFontSize, t)!,
      labelFontWeight: t < 0.5 ? labelFontWeight : other.labelFontWeight,
      labelLineHeight: _lerpDouble(labelLineHeight, other.labelLineHeight, t)!,
      labelLetterSpacing: _lerpDouble(
        labelLetterSpacing,
        other.labelLetterSpacing,
        t,
      )!,
      density: t < 0.5 ? density : other.density,
    );
  }

  double? _lerpDouble(double a, double b, double t) => a + (b - a) * t;
}
