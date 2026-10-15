import 'package:flutter/widgets.dart';

/// Color overrides for a side sheet.
///
/// Null values resolve to the spec roles.
@immutable
class MorphSideSheetColors {
  /// MorphSideSheetColors.
  const MorphSideSheetColors({
    this.standardContainerColor,
    this.modalContainerColor,
    this.surfaceTintColor,
    this.headlineColor,
    this.iconColor,
    this.dividerColor,
    this.scrimColor,
  });

  /// Standard container. Null uses `surface`.
  final Color? standardContainerColor;

  /// Modal container. Null uses `surfaceContainerLow`.
  final Color? modalContainerColor;

  /// Surface tint layer blended at the elevation, e.g. `primary`. Null
  /// paints no tint.
  final Color? surfaceTintColor;

  /// Headline text. Null uses `onSurfaceVariant`.
  final Color? headlineColor;

  /// Back and close icons at rest. Null uses `onSurfaceVariant`.
  final Color? iconColor;

  /// Divider. Null uses `outlineVariant`.
  final Color? dividerColor;

  /// Scrim, before its opacity. Null uses `scrim`.
  final Color? scrimColor;

  /// Returns a copy with the given fields replaced.
  MorphSideSheetColors copyWith({
    Color? standardContainerColor,
    Color? modalContainerColor,
    Color? surfaceTintColor,
    Color? headlineColor,
    Color? iconColor,
    Color? dividerColor,
    Color? scrimColor,
  }) {
    return MorphSideSheetColors(
      standardContainerColor:
          standardContainerColor ?? this.standardContainerColor,
      modalContainerColor: modalContainerColor ?? this.modalContainerColor,
      surfaceTintColor: surfaceTintColor ?? this.surfaceTintColor,
      headlineColor: headlineColor ?? this.headlineColor,
      iconColor: iconColor ?? this.iconColor,
      dividerColor: dividerColor ?? this.dividerColor,
      scrimColor: scrimColor ?? this.scrimColor,
    );
  }

  /// Interpolates between this and [other].
  MorphSideSheetColors lerp(MorphSideSheetColors other, double t) {
    return MorphSideSheetColors(
      standardContainerColor: Color.lerp(
        standardContainerColor,
        other.standardContainerColor,
        t,
      ),
      modalContainerColor: Color.lerp(
        modalContainerColor,
        other.modalContainerColor,
        t,
      ),
      surfaceTintColor: Color.lerp(surfaceTintColor, other.surfaceTintColor, t),
      headlineColor: Color.lerp(headlineColor, other.headlineColor, t),
      iconColor: Color.lerp(iconColor, other.iconColor, t),
      dividerColor: Color.lerp(dividerColor, other.dividerColor, t),
      scrimColor: Color.lerp(scrimColor, other.scrimColor, t),
    );
  }
}
