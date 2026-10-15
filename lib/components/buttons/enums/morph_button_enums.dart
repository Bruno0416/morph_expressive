import 'package:flutter/foundation.dart';
import 'package:morph_expressive/morph_components.dart'
    show MorphButton, MorphButtonGroup;

export 'package:morph_expressive/foundations/foundations.dart'
    show MorphHapticFeedback;

/// Visual styles for [MorphButton].
///
/// See also:
/// - [MorphButton] for the standard button widget
enum MorphButtonStyle {
  /// Solid background, high prominence.
  filled,

  /// Transparent background with a visible border.
  outlined,

  /// No background or border, lowest prominence.
  text,

  /// Surface-colored background with a shadow.
  elevated,

  /// Subdued background color, medium prominence.
  tonal,
}

/// Overall corner-radius strategy for buttons.
///
/// Used by [MorphButton] and [MorphButtonGroup] to control the button's
/// corner radius. [round] produces a pill shape, while [square] uses the
/// token-defined radius for the current size.
///
/// See also:
/// - [MorphButton] for the standard button widget
/// - [MorphButtonGroup] for the connected toggle button group
enum MorphButtonShape {
  /// Fully round pill shape (`height / 2`).
  round,

  /// Square corners using the token radius for the current size.
  square,
}

/// Standard size variants that map to Material 3 Expressive tokens.
///
/// Heights: xs=32dp, sm=40dp, md=56dp, lg=96dp, xl=136dp.
///
/// Used by [MorphButton] and [MorphButtonGroup].
///
/// See also:
/// - [MorphButton] for the standard button widget
/// - [MorphButtonGroup] for the connected toggle button group
@immutable
class MorphButtonSize {
  const MorphButtonSize._(
    this.name, {
    this.height,
    this.hPadding,
    this.iconSize,
    this.iconGap,
    this.outlineWidth,
    this.width,
  });

  /// The name of the size variant.
  final String name;

  /// Custom height override.
  final double? height;

  /// Custom horizontal padding override.
  final double? hPadding;

  /// Custom icon size override.
  final double? iconSize;

  /// Custom icon gap override.
  final double? iconGap;

  /// Custom outlined stroke width override.
  final double? outlineWidth;

  /// Custom width override.
  final double? width;

  /// 32 dp height.
  static const MorphButtonSize xs = MorphButtonSize._('xs');

  /// 40 dp height.
  static const MorphButtonSize sm = MorphButtonSize._('sm');

  /// 56 dp height.
  static const MorphButtonSize md = MorphButtonSize._('md');

  /// 96 dp height.
  static const MorphButtonSize lg = MorphButtonSize._('lg');

  /// 136 dp height.
  static const MorphButtonSize xl = MorphButtonSize._('xl');

  /// Creates a custom size variant with the specified overrides.
  factory MorphButtonSize.custom({
    double? height,
    double? hPadding,
    double? iconSize,
    double? iconGap,
    double? outlineWidth,
    double? width,
  }) {
    return MorphButtonSize._(
      'custom',
      height: height,
      hPadding: hPadding,
      iconSize: iconSize,
      iconGap: iconGap,
      outlineWidth: outlineWidth,
      width: width,
    );
  }

  /// Returns this size with selective measurement overrides.
  ///
  /// Keeps [name] so theme token tables (spacing, radii) still resolve.
  MorphButtonSize copyWith({
    double? height,
    double? hPadding,
    double? iconSize,
    double? iconGap,
    double? outlineWidth,
    double? width,
  }) {
    return MorphButtonSize._(
      name,
      height: height ?? this.height,
      hPadding: hPadding ?? this.hPadding,
      iconSize: iconSize ?? this.iconSize,
      iconGap: iconGap ?? this.iconGap,
      outlineWidth: outlineWidth ?? this.outlineWidth,
      width: width ?? this.width,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MorphButtonSize &&
          name == other.name &&
          height == other.height &&
          hPadding == other.hPadding &&
          iconSize == other.iconSize &&
          iconGap == other.iconGap &&
          outlineWidth == other.outlineWidth &&
          width == other.width);

  @override
  int get hashCode => Object.hash(
    name,
    height,
    hPadding,
    iconSize,
    iconGap,
    outlineWidth,
    width,
  );

  @override
  String toString() => 'MorphButtonSize.$name';
}
