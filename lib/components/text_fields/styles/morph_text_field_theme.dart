import 'package:flutter/widgets.dart';

import '../../../foundations/foundations.dart';
import '../enums/morph_text_field_slot_alignment.dart';
import '../enums/morph_text_field_variant.dart';
import '../models/morph_text_field_colors.dart';
import '../models/morph_text_field_states.dart';
import 'morph_text_field_color_theme.dart';

/// Theme values for `MorphTextField`.
///
/// Morph defaults use rounded surfaces and a shape transition on focus.
@immutable
class MorphTextFieldTheme extends MorphThemeExtension<MorphTextFieldTheme> {
  /// MorphTextFieldTheme.
  const MorphTextFieldTheme({
    this.containerHeight = 56,
    this.verticalPadding = 8,
    this.horizontalPadding = 16,
    this.iconEdgePadding = 12,
    this.iconSize = 24,
    this.iconTextGap = 16,
    this.notchPadding = 4,
    this.supportingTopPadding = 4,
    this.supportingHorizontalPadding = 16,
    this.supportingCounterGap = 16,
    this.density = 0,
    this.densityStep = 4,
    this.constraints,
    this.filledShape = const BorderRadius.all(Radius.circular(18)),
    this.outlinedShape = const BorderRadius.all(Radius.circular(18)),
    this.focusedFilledShape = const BorderRadius.all(Radius.circular(24)),
    this.focusedOutlinedShape = const BorderRadius.all(Radius.circular(24)),
    this.shapeSpring = MorphMotion.spatialFast,
    this.activeIndicatorWidth = 0,
    this.focusActiveIndicatorWidth = 0,
    this.outlineWidth = 2,
    this.focusOutlineWidth = 2,
    this.focusRingWidth = 3,
    this.focusRingGap = 2,
    this.selectionOpacity = 0.4,
    this.labelSpring = MorphMotion.spatialFast,
    this.effectsSpring = MorphMotion.effectsFast,
    this.inputTextStyle,
    this.labelTextStyle,
    this.floatingLabelTextStyle,
    this.supportingTextStyle,
    this.colors = const MorphTextFieldColorTheme(),
    this.iconAlignment = MorphTextFieldSlotAlignment.center,
    this.affixAlignment = MorphTextFieldSlotAlignment.firstLine,
  });

  /// defaults.
  static const MorphTextFieldTheme defaults = MorphTextFieldTheme();

  /// Container height (and target size) at density 0.
  final double containerHeight;

  /// Filled top/bottom padding around the floating label and input.
  final double verticalPadding;

  /// Start/end padding on a side without an icon.
  final double horizontalPadding;

  /// Edge to leading/trailing icon padding.
  final double iconEdgePadding;

  /// Leading/trailing icon (and image) size.
  final double iconSize;

  /// Icon to label/input padding.
  final double iconTextGap;

  /// Outlined notch padding on each side of the floating label.
  final double notchPadding;

  /// Container to supporting text / counter padding.
  final double supportingTopPadding;

  /// Supporting text / counter start and end inset.
  final double supportingHorizontalPadding;

  /// Supporting text to counter gap.
  final double supportingCounterGap;

  /// Default density, from 0 (spec) down to -3. Not dense by default.
  final int density;

  /// Height removed per density step.
  final double densityStep;

  /// Optional width bounds for medium and expanded layouts.
  final BoxConstraints? constraints;

  /// Filled container shape at rest (Morph: rounded on all corners).
  final BorderRadius filledShape;

  /// Outlined container shape at rest.
  final BorderRadius outlinedShape;

  /// Focused filled shape, interpolated from [filledShape].
  final BorderRadius focusedFilledShape;

  /// Focused outlined shape, interpolated from [outlinedShape].
  final BorderRadius focusedOutlinedShape;

  /// Spatial spring for the field's corner morph on focus.
  final MorphSpring shapeSpring;

  /// Filled active indicator height (0 by default: no underline).
  final double activeIndicatorWidth;

  /// Filled focused active indicator height (0 by default).
  final double focusActiveIndicatorWidth;

  /// Outlined outline width.
  final double outlineWidth;

  /// Outlined focused outline width.
  final double focusOutlineWidth;

  /// Keyboard focus ring thickness.
  final double focusRingWidth;

  /// Gap between the container and the keyboard focus ring.
  final double focusRingGap;

  /// Text selection highlight opacity (primary).
  final double selectionOpacity;

  /// Spatial spring for the label moving between rest and float.
  final MorphSpring labelSpring;

  /// Effects spring for colors, stroke width and the outline notch.
  final MorphSpring effectsSpring;

  /// Input text style. Default: body large.
  final TextStyle? inputTextStyle;

  /// Label style in an empty field. Default: body large.
  final TextStyle? labelTextStyle;

  /// Label style in a populated or focused field. Default: body small.
  final TextStyle? floatingLabelTextStyle;

  /// Supporting text and counter style. Default: body small.
  final TextStyle? supportingTextStyle;

  /// Color tokens.
  final MorphTextFieldColorTheme colors;

  /// Leading/trailing icon position in multi-line fields. Default: centered,
  /// per the spec's "icon alignment: vertically centered".
  final MorphTextFieldSlotAlignment iconAlignment;

  /// Prefix/suffix text position in multi-line fields. Default: first line.
  final MorphTextFieldSlotAlignment affixAlignment;

  /// [density] clamped to the supported range.
  static int clampDensity(int density) => density.clamp(-3, 0);

  /// Height change per side for [density] (zero or negative).
  double densityOffset(int density) => clampDensity(density) * densityStep / 2;

  /// Container height for [density].
  double heightFor(int density) => containerHeight + densityOffset(density) * 2;

  /// Filled top/bottom padding for [density].
  double verticalPaddingFor(int density) =>
      verticalPadding + densityOffset(density);

  /// Width of an icon slot (edge padding on both sides of the icon).
  double get iconSlotWidth => iconSize + iconEdgePadding * 2;

  /// Text side padding next to an icon slot.
  double get iconSlotTextPadding => iconTextGap - iconEdgePadding;

  /// Container shape for [variant].
  BorderRadius shapeFor(MorphTextFieldVariant variant) =>
      variant == MorphTextFieldVariant.outlined ? outlinedShape : filledShape;

  /// Morphs only the corners; does not affect field dimensions or label notch.
  BorderRadius shapeAt(MorphTextFieldVariant variant, double focusProgress) {
    final resting = shapeFor(variant);
    final focused = variant == MorphTextFieldVariant.outlined
        ? focusedOutlinedShape
        : focusedFilledShape;
    return BorderRadius.lerp(resting, focused, focusProgress.clamp(0.0, 1.0).toDouble())!;
  }

  /// Resolved input style.
  TextStyle resolveInputStyle(MorphTypeScale type) =>
      inputTextStyle ?? type.bodyLarge;

  /// Resolved resting label style.
  TextStyle resolveLabelStyle(MorphTypeScale type) =>
      labelTextStyle ?? type.bodyLarge;

  /// Resolved floating label style.
  TextStyle resolveFloatingLabelStyle(MorphTypeScale type) =>
      floatingLabelTextStyle ?? type.bodySmall;

  /// Resolved supporting text style.
  TextStyle resolveSupportingStyle(MorphTypeScale type) =>
      supportingTextStyle ?? type.bodySmall;

  /// Line height of [style] in logical pixels.
  static double lineHeightOf(TextStyle style) =>
      (style.fontSize ?? 14) * (style.height ?? 1);

  /// Stroke width for [variant] in [states].
  double strokeWidthFor(
    MorphTextFieldVariant variant,
    MorphTextFieldStates states,
  ) {
    final bool focused = states.isFocused;
    if (variant == MorphTextFieldVariant.outlined) {
      return focused ? focusOutlineWidth : outlineWidth;
    }
    return focused ? focusActiveIndicatorWidth : activeIndicatorWidth;
  }

  /// Resolves the palette for [variant] in [states].
  MorphTextFieldColors resolveColors(
    MorphColorScheme scheme, {
    required MorphTextFieldVariant variant,
    required MorphTextFieldStates states,
  }) {
    return colors.resolve(
      scheme,
      outlined: variant == MorphTextFieldVariant.outlined,
      states: states,
      strokeWidth: strokeWidthFor(variant, states),
    );
  }

  @override
  MorphTextFieldTheme copyWith({
    double? containerHeight,
    double? verticalPadding,
    double? horizontalPadding,
    double? iconEdgePadding,
    double? iconSize,
    double? iconTextGap,
    double? notchPadding,
    double? supportingTopPadding,
    double? supportingHorizontalPadding,
    double? supportingCounterGap,
    int? density,
    double? densityStep,
    BoxConstraints? constraints,
    BorderRadius? filledShape,
    BorderRadius? outlinedShape,
    BorderRadius? focusedFilledShape,
    BorderRadius? focusedOutlinedShape,
    MorphSpring? shapeSpring,
    double? activeIndicatorWidth,
    double? focusActiveIndicatorWidth,
    double? outlineWidth,
    double? focusOutlineWidth,
    double? focusRingWidth,
    double? focusRingGap,
    double? selectionOpacity,
    MorphSpring? labelSpring,
    MorphSpring? effectsSpring,
    TextStyle? inputTextStyle,
    TextStyle? labelTextStyle,
    TextStyle? floatingLabelTextStyle,
    TextStyle? supportingTextStyle,
    MorphTextFieldColorTheme? colors,
    MorphTextFieldSlotAlignment? iconAlignment,
    MorphTextFieldSlotAlignment? affixAlignment,
  }) {
    return MorphTextFieldTheme(
      containerHeight: containerHeight ?? this.containerHeight,
      verticalPadding: verticalPadding ?? this.verticalPadding,
      horizontalPadding: horizontalPadding ?? this.horizontalPadding,
      iconEdgePadding: iconEdgePadding ?? this.iconEdgePadding,
      iconSize: iconSize ?? this.iconSize,
      iconTextGap: iconTextGap ?? this.iconTextGap,
      notchPadding: notchPadding ?? this.notchPadding,
      supportingTopPadding: supportingTopPadding ?? this.supportingTopPadding,
      supportingHorizontalPadding:
          supportingHorizontalPadding ?? this.supportingHorizontalPadding,
      supportingCounterGap: supportingCounterGap ?? this.supportingCounterGap,
      density: density ?? this.density,
      densityStep: densityStep ?? this.densityStep,
      constraints: constraints ?? this.constraints,
      filledShape: filledShape ?? this.filledShape,
      outlinedShape: outlinedShape ?? this.outlinedShape,
      focusedFilledShape: focusedFilledShape ?? this.focusedFilledShape,
      focusedOutlinedShape: focusedOutlinedShape ?? this.focusedOutlinedShape,
      shapeSpring: shapeSpring ?? this.shapeSpring,
      activeIndicatorWidth: activeIndicatorWidth ?? this.activeIndicatorWidth,
      focusActiveIndicatorWidth:
          focusActiveIndicatorWidth ?? this.focusActiveIndicatorWidth,
      outlineWidth: outlineWidth ?? this.outlineWidth,
      focusOutlineWidth: focusOutlineWidth ?? this.focusOutlineWidth,
      focusRingWidth: focusRingWidth ?? this.focusRingWidth,
      focusRingGap: focusRingGap ?? this.focusRingGap,
      selectionOpacity: selectionOpacity ?? this.selectionOpacity,
      labelSpring: labelSpring ?? this.labelSpring,
      effectsSpring: effectsSpring ?? this.effectsSpring,
      inputTextStyle: inputTextStyle ?? this.inputTextStyle,
      labelTextStyle: labelTextStyle ?? this.labelTextStyle,
      floatingLabelTextStyle:
          floatingLabelTextStyle ?? this.floatingLabelTextStyle,
      supportingTextStyle: supportingTextStyle ?? this.supportingTextStyle,
      colors: colors ?? this.colors,
      iconAlignment: iconAlignment ?? this.iconAlignment,
      affixAlignment: affixAlignment ?? this.affixAlignment,
    );
  }

  @override
  MorphTextFieldTheme lerp(MorphTextFieldTheme? other, double t) {
    if (other is! MorphTextFieldTheme) {
      return this;
    }
    final MorphTextFieldTheme b = t < 0.5 ? this : other;
    double l(double Function(MorphTextFieldTheme x) f) =>
        f(this) + (f(other) - f(this)) * t;
    return b.copyWith(
      containerHeight: l((MorphTextFieldTheme x) => x.containerHeight),
      verticalPadding: l((MorphTextFieldTheme x) => x.verticalPadding),
      horizontalPadding: l((MorphTextFieldTheme x) => x.horizontalPadding),
      iconEdgePadding: l((MorphTextFieldTheme x) => x.iconEdgePadding),
      iconSize: l((MorphTextFieldTheme x) => x.iconSize),
      iconTextGap: l((MorphTextFieldTheme x) => x.iconTextGap),
      notchPadding: l((MorphTextFieldTheme x) => x.notchPadding),
      supportingTopPadding: l((MorphTextFieldTheme x) => x.supportingTopPadding),
      supportingHorizontalPadding: l(
        (MorphTextFieldTheme x) => x.supportingHorizontalPadding,
      ),
      supportingCounterGap: l((MorphTextFieldTheme x) => x.supportingCounterGap),
      densityStep: l((MorphTextFieldTheme x) => x.densityStep),
      filledShape: BorderRadius.lerp(filledShape, other.filledShape, t),
      outlinedShape: BorderRadius.lerp(outlinedShape, other.outlinedShape, t),
      focusedFilledShape: BorderRadius.lerp(
        focusedFilledShape, other.focusedFilledShape, t),
      focusedOutlinedShape: BorderRadius.lerp(
        focusedOutlinedShape, other.focusedOutlinedShape, t),
      activeIndicatorWidth: l((MorphTextFieldTheme x) => x.activeIndicatorWidth),
      focusActiveIndicatorWidth: l(
        (MorphTextFieldTheme x) => x.focusActiveIndicatorWidth,
      ),
      outlineWidth: l((MorphTextFieldTheme x) => x.outlineWidth),
      focusOutlineWidth: l((MorphTextFieldTheme x) => x.focusOutlineWidth),
      focusRingWidth: l((MorphTextFieldTheme x) => x.focusRingWidth),
      focusRingGap: l((MorphTextFieldTheme x) => x.focusRingGap),
      selectionOpacity: l((MorphTextFieldTheme x) => x.selectionOpacity),
      colors: colors.lerp(other.colors, t),
    );
  }
}
