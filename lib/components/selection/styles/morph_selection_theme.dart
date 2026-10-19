import 'package:flutter/widgets.dart';

import '../../../foundations/foundations.dart';
import '../../cards/enums/morph_card_variant.dart';
import '../../lists/styles/morph_list_theme.dart';

/// Theme values for selection list and selection app bar.
@immutable
class MorphSelectionTheme extends MorphThemeExtension<MorphSelectionTheme> {
  /// Creates a selection theme.
  const MorphSelectionTheme({
    this.outerRadius = MorphListCardListTheme.defaultOuterRadius,
    this.innerRadius = MorphListCardListTheme.defaultInnerRadius,
    this.gap = MorphListCardListTheme.defaultGap,
    this.itemPadding = MorphListCardListTheme.defaultItemPadding,
    this.variant = MorphCardVariant.filled,
    this.border,
    this.leadingFlipDuration = MorphMotion.selectionFlip,
    this.selectAllHeight = 48,
    this.contextualToolbarHeight = 72,
    this.highlightColor,
  });

  /// defaults.
  static const MorphSelectionTheme defaults = MorphSelectionTheme();

  /// Outer card radius (also used for selected equal corners).
  final double outerRadius;

  /// Inner card radius for unselected stacked cards.
  final double innerRadius;

  /// Gap between cards.
  final double gap;

  /// Padding inside each card.
  final EdgeInsetsGeometry itemPadding;

  /// Card variant.
  final MorphCardVariant variant;

  /// Optional outline.
  final BorderSide? border;

  /// Duration for leading horizontal flip.
  final Duration leadingFlipDuration;

  /// Height of the select-all row under the contextual bar.
  final double selectAllHeight;

  /// Height of the contextual selection toolbar (excluding safe area).
  ///
  /// Prefer matching the app bar small height; the selection header applies
  /// app-bar content padding (including vertical) at build time.
  final double contextualToolbarHeight;

  /// Optional selected-item fill. Defaults to the secondary container.
  final Color? highlightColor;

  /// Selected card fill.
  Color selectedColor(MorphColorScheme scheme) =>
      highlightColor ?? scheme.secondaryContainer;

  /// Contextual selection app bar container.
  Color contextualBackground(MorphColorScheme scheme) =>
      scheme.primaryContainer;

  /// Content on the contextual selection app bar.
  Color contextualForeground(MorphColorScheme scheme) =>
      scheme.onPrimaryContainer;

  @override
  MorphSelectionTheme copyWith({
    double? outerRadius,
    double? innerRadius,
    double? gap,
    EdgeInsetsGeometry? itemPadding,
    MorphCardVariant? variant,
    BorderSide? border,
    Duration? leadingFlipDuration,
    double? selectAllHeight,
    double? contextualToolbarHeight,
    Color? highlightColor,
  }) {
    return MorphSelectionTheme(
      outerRadius: outerRadius ?? this.outerRadius,
      innerRadius: innerRadius ?? this.innerRadius,
      gap: gap ?? this.gap,
      itemPadding: itemPadding ?? this.itemPadding,
      variant: variant ?? this.variant,
      border: border ?? this.border,
      leadingFlipDuration: leadingFlipDuration ?? this.leadingFlipDuration,
      selectAllHeight: selectAllHeight ?? this.selectAllHeight,
      contextualToolbarHeight:
          contextualToolbarHeight ?? this.contextualToolbarHeight,
      highlightColor: highlightColor ?? this.highlightColor,
    );
  }

  @override
  MorphSelectionTheme lerp(MorphSelectionTheme? other, double t) {
    if (other is! MorphSelectionTheme) {
      return this;
    }
    return t < 0.5 ? this : other;
  }
}
