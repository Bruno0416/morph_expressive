import 'package:flutter/widgets.dart';

import '../../../foundations/foundations.dart';
import '../../floating_action_buttons/enums/morph_fab.dart';
import '../../floating_action_buttons/styles/morph_fab_theme.dart';
import '../enums/morph_fab_menu_color_set.dart';

/// Theme values for `MorphFabMenu`.
@immutable
class MorphFabMenuTheme extends MorphThemeExtension<MorphFabMenuTheme> {
  /// Creates FAB menu theme tokens.
  const MorphFabMenuTheme({
    this.menuOffset = 8,
    this.scrimOpacity = 0.0,
    this.itemGap = 4,
    this.itemHeight = 56,
    this.itemLeading = 24,
    this.itemTrailing = 24,
    this.iconSize = 24,
    this.iconLabelGap = 8,
    this.closeIconSize = 20,
    this.itemElevation = 0,
    this.closeElevation = MorphElevation.level3,
    this.closeHoverElevation = MorphElevation.level4,
    this.openFabContainer = 56,
    this.closedFabContainer,
    this.focusRingWidth = 3,
    this.focusRingGap = 2,
    this.focusRingColor,
    this.itemBorderWidth = 1,
    this.itemOutlineColor,
    this.itemOutlineGradient,
    this.itemBackgroundGradient,
    this.itemForegroundGradient,
    this.expandSpring = const MorphSpring(stiffness: 380, damping: 0.55),
    this.fabShapeSpring = const MorphSpring(stiffness: 380, damping: 0.7),
    this.expandStagger = const Duration(milliseconds: 30),
  });

  /// Package defaults.
  static const MorphFabMenuTheme defaults = MorphFabMenuTheme();

  /// Vertical gap between the close FAB and the nearest menu item. Spec: 8.
  final double menuOffset;

  /// Scrim opacity over [MorphColorScheme.scrim].
  final double scrimOpacity;

  /// Spacing between adjacent menu items. Spec: 4.
  final double itemGap;

  /// Menu item height. Spec: 56.
  final double itemHeight;

  /// Start padding inside an item. Spec: 24.
  final double itemLeading;

  /// End padding inside an item. Spec: 24.
  final double itemTrailing;

  /// Item icon size. Spec: 24.
  final double iconSize;

  /// Gap between item icon and label. Spec: 8.
  final double iconLabelGap;

  /// Close FAB icon size when open. Spec: 20.
  final double closeIconSize;

  /// Item surface elevation. Defaults to 0.
  final double itemElevation;

  /// Close FAB resting elevation. Spec unclear; defaults to level 3.
  final double closeElevation;

  /// Close FAB hover elevation. Spec unclear; defaults to level 4.
  final double closeHoverElevation;

  /// Close FAB size when open. Spec: 56.
  final double openFabContainer;

  /// Optional override for closed FAB size; null uses [MorphFabSize] metrics.
  final double? closedFabContainer;

  /// Focus ring stroke width. Spec unclear; defaults to 3.
  final double focusRingWidth;

  /// Gap between surface and focus ring. Spec unclear; defaults to 2.
  final double focusRingGap;

  /// Focus ring color; defaults to secondary.
  final Color? focusRingColor;

  /// Item outline thickness when an outline is set.
  final double itemBorderWidth;

  /// Solid outline for item pills.
  final Color? itemOutlineColor;

  /// Gradient outline for item pills. Wins over [itemOutlineColor].
  final Gradient? itemOutlineGradient;

  /// Gradient fill for item pills, replacing resolved container color.
  final Gradient? itemBackgroundGradient;

  /// Gradient tint for item icons and labels.
  final Gradient? itemForegroundGradient;

  /// Menu item expand / collapse spring.
  final MorphSpring expandSpring;

  /// FAB container shape morph spring.
  final MorphSpring fabShapeSpring;

  /// Stagger between cascading item reveals.
  final Duration expandStagger;

  /// Scrim color for the dismiss barrier.
  Color scrimColor(MorphColorScheme scheme) =>
      scheme.scrim.withValues(alpha: scrimOpacity);

  /// Resolved focus ring color.
  Color resolveFocusRingColor(MorphColorScheme scheme) =>
      focusRingColor ?? scheme.secondary;

  /// Maps a FAB color style to a menu color set.
  static MorphFabMenuColorSet colorSetFor(MorphFabColor color) {
    switch (color) {
      case MorphFabColor.secondary:
      case MorphFabColor.secondaryFilled:
        return MorphFabMenuColorSet.secondary;
      case MorphFabColor.tertiary:
      case MorphFabColor.tertiaryFilled:
        return MorphFabMenuColorSet.tertiary;
      case MorphFabColor.primary:
      case MorphFabColor.primaryFilled:
      case MorphFabColor.surface:
        return MorphFabMenuColorSet.primary;
    }
  }

  /// Filled [MorphFabColor] for the open close button of [set].
  static MorphFabColor closeFabColor(MorphFabMenuColorSet set) {
    switch (set) {
      case MorphFabMenuColorSet.primary:
        return MorphFabColor.primaryFilled;
      case MorphFabMenuColorSet.secondary:
        return MorphFabColor.secondaryFilled;
      case MorphFabMenuColorSet.tertiary:
        return MorphFabColor.tertiaryFilled;
    }
  }

  /// Closed container size for [size], using theme override when set.
  double resolveClosedContainer({
    required MorphFabSize size,
    required MorphFabTheme fabTheme,
  }) {
    final override = closedFabContainer;
    if (override != null) {
      return override;
    }
    switch (size) {
      case MorphFabSize.small:
        return fabTheme.smallContainer;
      case MorphFabSize.regular:
        return fabTheme.regularContainer;
      case MorphFabSize.medium:
        return fabTheme.mediumContainer;
      case MorphFabSize.large:
        return fabTheme.largeContainer;
    }
  }

  /// Item container color for [set].
  Color itemContainerColor(MorphColorScheme scheme, MorphFabMenuColorSet set) {
    switch (set) {
      case MorphFabMenuColorSet.primary:
        return scheme.primaryContainer;
      case MorphFabMenuColorSet.secondary:
        return scheme.secondaryContainer;
      case MorphFabMenuColorSet.tertiary:
        return scheme.tertiaryContainer;
    }
  }

  /// Item icon/label color for [set].
  Color itemForegroundColor(MorphColorScheme scheme, MorphFabMenuColorSet set) {
    switch (set) {
      case MorphFabMenuColorSet.primary:
        return scheme.onPrimaryContainer;
      case MorphFabMenuColorSet.secondary:
        return scheme.onSecondaryContainer;
      case MorphFabMenuColorSet.tertiary:
        return scheme.onTertiaryContainer;
    }
  }

  /// Close container color for [set] (filled role).
  Color closeContainerColor(MorphColorScheme scheme, MorphFabMenuColorSet set) {
    switch (set) {
      case MorphFabMenuColorSet.primary:
        return scheme.primary;
      case MorphFabMenuColorSet.secondary:
        return scheme.secondary;
      case MorphFabMenuColorSet.tertiary:
        return scheme.tertiary;
    }
  }

  /// Close icon color for [set] (on-filled role).
  Color closeForegroundColor(
    MorphColorScheme scheme,
    MorphFabMenuColorSet set,
  ) {
    switch (set) {
      case MorphFabMenuColorSet.primary:
        return scheme.onPrimary;
      case MorphFabMenuColorSet.secondary:
        return scheme.onSecondary;
      case MorphFabMenuColorSet.tertiary:
        return scheme.onTertiary;
    }
  }

  /// Item label [TextStyle] (titleMedium).
  TextStyle itemLabelStyle(
    MorphTypeScale type,
    MorphColorScheme scheme,
    MorphFabMenuColorSet set,
  ) => type.titleMedium.copyWith(color: itemForegroundColor(scheme, set));

  @override
  MorphFabMenuTheme copyWith({
    double? menuOffset,
    double? scrimOpacity,
    double? itemGap,
    double? itemHeight,
    double? itemLeading,
    double? itemTrailing,
    double? iconSize,
    double? iconLabelGap,
    double? closeIconSize,
    double? itemElevation,
    double? closeElevation,
    double? closeHoverElevation,
    double? openFabContainer,
    double? closedFabContainer,
    bool clearClosedFabContainer = false,
    double? focusRingWidth,
    double? focusRingGap,
    Color? focusRingColor,
    bool clearFocusRingColor = false,
    double? itemBorderWidth,
    Color? itemOutlineColor,
    Gradient? itemOutlineGradient,
    Gradient? itemBackgroundGradient,
    Gradient? itemForegroundGradient,
    MorphSpring? expandSpring,
    MorphSpring? fabShapeSpring,
    Duration? expandStagger,
  }) {
    return MorphFabMenuTheme(
      menuOffset: menuOffset ?? this.menuOffset,
      scrimOpacity: scrimOpacity ?? this.scrimOpacity,
      itemGap: itemGap ?? this.itemGap,
      itemHeight: itemHeight ?? this.itemHeight,
      itemLeading: itemLeading ?? this.itemLeading,
      itemTrailing: itemTrailing ?? this.itemTrailing,
      iconSize: iconSize ?? this.iconSize,
      iconLabelGap: iconLabelGap ?? this.iconLabelGap,
      closeIconSize: closeIconSize ?? this.closeIconSize,
      itemElevation: itemElevation ?? this.itemElevation,
      closeElevation: closeElevation ?? this.closeElevation,
      closeHoverElevation: closeHoverElevation ?? this.closeHoverElevation,
      openFabContainer: openFabContainer ?? this.openFabContainer,
      closedFabContainer: clearClosedFabContainer
          ? null
          : (closedFabContainer ?? this.closedFabContainer),
      focusRingWidth: focusRingWidth ?? this.focusRingWidth,
      focusRingGap: focusRingGap ?? this.focusRingGap,
      focusRingColor: clearFocusRingColor
          ? null
          : (focusRingColor ?? this.focusRingColor),
      itemBorderWidth: itemBorderWidth ?? this.itemBorderWidth,
      itemOutlineColor: itemOutlineColor ?? this.itemOutlineColor,
      itemOutlineGradient: itemOutlineGradient ?? this.itemOutlineGradient,
      itemBackgroundGradient:
          itemBackgroundGradient ?? this.itemBackgroundGradient,
      itemForegroundGradient:
          itemForegroundGradient ?? this.itemForegroundGradient,
      expandSpring: expandSpring ?? this.expandSpring,
      fabShapeSpring: fabShapeSpring ?? this.fabShapeSpring,
      expandStagger: expandStagger ?? this.expandStagger,
    );
  }

  @override
  MorphFabMenuTheme lerp(MorphFabMenuTheme? other, double t) {
    if (other is! MorphFabMenuTheme) {
      return this;
    }
    return MorphFabMenuTheme(
      menuOffset: _lerpDouble(menuOffset, other.menuOffset, t)!,
      scrimOpacity: _lerpDouble(scrimOpacity, other.scrimOpacity, t)!,
      itemGap: _lerpDouble(itemGap, other.itemGap, t)!,
      itemHeight: _lerpDouble(itemHeight, other.itemHeight, t)!,
      itemLeading: _lerpDouble(itemLeading, other.itemLeading, t)!,
      itemTrailing: _lerpDouble(itemTrailing, other.itemTrailing, t)!,
      iconSize: _lerpDouble(iconSize, other.iconSize, t)!,
      iconLabelGap: _lerpDouble(iconLabelGap, other.iconLabelGap, t)!,
      closeIconSize: _lerpDouble(closeIconSize, other.closeIconSize, t)!,
      itemElevation: _lerpDouble(itemElevation, other.itemElevation, t)!,
      closeElevation: _lerpDouble(closeElevation, other.closeElevation, t)!,
      closeHoverElevation: _lerpDouble(
        closeHoverElevation,
        other.closeHoverElevation,
        t,
      )!,
      openFabContainer: _lerpDouble(
        openFabContainer,
        other.openFabContainer,
        t,
      )!,
      closedFabContainer: t < 0.5
          ? closedFabContainer
          : other.closedFabContainer,
      focusRingWidth: _lerpDouble(focusRingWidth, other.focusRingWidth, t)!,
      focusRingGap: _lerpDouble(focusRingGap, other.focusRingGap, t)!,
      focusRingColor:
          Color.lerp(focusRingColor, other.focusRingColor, t) ??
          focusRingColor ??
          other.focusRingColor,
      itemBorderWidth: _lerpDouble(itemBorderWidth, other.itemBorderWidth, t)!,
      itemOutlineColor: Color.lerp(itemOutlineColor, other.itemOutlineColor, t),
      itemOutlineGradient: t < 0.5
          ? itemOutlineGradient
          : other.itemOutlineGradient,
      itemBackgroundGradient: t < 0.5
          ? itemBackgroundGradient
          : other.itemBackgroundGradient,
      itemForegroundGradient: t < 0.5
          ? itemForegroundGradient
          : other.itemForegroundGradient,
      expandSpring: t < 0.5 ? expandSpring : other.expandSpring,
      fabShapeSpring: t < 0.5 ? fabShapeSpring : other.fabShapeSpring,
      expandStagger: t < 0.5 ? expandStagger : other.expandStagger,
    );
  }

  double? _lerpDouble(double a, double b, double t) => a + (b - a) * t;
}
