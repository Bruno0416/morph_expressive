import 'package:flutter/widgets.dart';

import '../../../foundations/foundations.dart';
import '../../cards/enums/morph_card_variant.dart';

/// Theme values for `MorphCardList`.
@immutable
class MorphListCardListTheme {
  /// defaultOuterRadius.
  static const double defaultOuterRadius = 16;

  /// defaultInnerRadius.
  static const double defaultInnerRadius = 4.5;

  /// defaultGap.
  static const double defaultGap = 5;

  /// defaultItemPadding.
  ///
  /// Zero so list items own the spec padding and rows are not padded twice.
  static const EdgeInsets defaultItemPadding = EdgeInsets.zero;

  /// MorphListCardListTheme.

  const MorphListCardListTheme({
    this.outerRadius = defaultOuterRadius,
    this.innerRadius = defaultInnerRadius,
    this.gap = defaultGap,
    this.itemPadding = defaultItemPadding,
    this.variant = MorphCardVariant.filled,
    this.border,
    this.radiusSpring = MorphMotion.expressiveSpatialDefault,
  });

  /// defaults.

  static const MorphListCardListTheme defaults = MorphListCardListTheme();

  /// outerRadius.

  final double outerRadius;

  /// innerRadius.
  final double innerRadius;

  /// gap.
  final double gap;

  /// itemPadding.
  final EdgeInsetsGeometry itemPadding;

  /// Card variant for each card-list item.
  final MorphCardVariant variant;

  /// Optional card outline; null keeps the variant default.
  final BorderSide? border;

  /// Corner-radius morph spring for card list items.
  final MorphSpring radiusSpring;

  /// Resting fill for [variant]. Outlined stays on surface.
  Color backgroundColor(MorphColorScheme scheme, {MorphCardVariant? variant}) {
    return switch (variant ?? this.variant) {
      MorphCardVariant.filled => scheme.surfaceContainerHighest,
      MorphCardVariant.elevated => scheme.surfaceContainerLow,
      MorphCardVariant.outlined => scheme.surface,
    };
  }

  /// copyWith.

  MorphListCardListTheme copyWith({
    double? outerRadius,
    double? innerRadius,
    double? gap,
    EdgeInsetsGeometry? itemPadding,
    MorphCardVariant? variant,
    BorderSide? border,
    MorphSpring? radiusSpring,
  }) {
    return MorphListCardListTheme(
      outerRadius: outerRadius ?? this.outerRadius,
      innerRadius: innerRadius ?? this.innerRadius,
      gap: gap ?? this.gap,
      itemPadding: itemPadding ?? this.itemPadding,
      variant: variant ?? this.variant,
      border: border ?? this.border,
      radiusSpring: radiusSpring ?? this.radiusSpring,
    );
  }
}
