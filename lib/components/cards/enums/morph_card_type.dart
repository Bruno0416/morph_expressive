/// The three card types defined by Material 3.
///
/// The chromatic role of a card is chosen independently with `MorphVariant`.
///
/// See https://m3.material.io/components/cards/specs.
enum MorphCardType {
  /// Elevated surface with shadow.
  elevated,

  /// Filled tonal surface.
  filled,

  /// Outlined surface with a border.
  outlined,
}

/// Previous name of [MorphCardType].
///
/// `variant` now selects a chromatic role (`MorphVariant`); the visual type is
/// the `type` parameter of `MorphCard`.
@Deprecated('Use MorphCardType')
typedef MorphCardVariant = MorphCardType;
