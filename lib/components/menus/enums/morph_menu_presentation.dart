/// Visual and interaction presentation of a menu popup.
enum MorphMenuPresentation {
  /// The expressive Morph menu geometry (48 px rows, anchored popups).
  ///
  /// This is the default everywhere and never changes with density.
  standard,

  /// Compact desktop context-menu geometry.
  ///
  /// Rows are 28 / 32 / 40 px high (compact / standard / comfortable density),
  /// the popup is sized to its content between 180 and 320 px, opens with its
  /// top-left corner at the pointer, shows shortcut hints in a right-aligned
  /// column, reserves a stable leading slot and a fixed submenu chevron slot,
  /// and follows desktop pointer and keyboard conventions.
  desktop,
}
