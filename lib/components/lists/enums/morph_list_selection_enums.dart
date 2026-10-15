/// Selection cardinality for list selection.
enum MorphListSelectionMode {
  /// At most one index may be selected.
  single,

  /// Any number of indices may be selected.
  multiple,
}

/// Gesture that toggles list selection.
enum MorphListSelectionTrigger {
  /// Tap the leading selection flip target.
  icon,

  /// Double-tap the list row (single taps stay immediate).
  doubleTap,
}
