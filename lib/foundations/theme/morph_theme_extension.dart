/// Base type for overridable component themes registered on `MorphThemeData`.
abstract class MorphThemeExtension<T extends MorphThemeExtension<T>> {
  /// Creates a theme extension.
  const MorphThemeExtension();

  /// Returns a copy with non-null fields replaced.
  T copyWith();

  /// Linearly interpolates between this theme and [other].
  T lerp(T? other, double t);
}
