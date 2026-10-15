/// Side sheet variants.
enum MorphSideSheetVariant {
  /// Sits next to the main content; the content stays interactive.
  standard,

  /// Shown over a scrim; must be dismissed to reach the content.
  modal,
}

/// Window edge a side sheet is anchored to.
///
/// Edges follow the text direction, so [end] is the right edge in
/// left-to-right languages and the left edge in right-to-left ones.
enum MorphSideSheetEdge {
  /// Trailing edge (default).
  end,

  /// Leading edge.
  start,
}

/// How `MorphSideSheetLayout` presents its sheet.
enum MorphSideSheetLayoutMode {
  /// Modal below the compact breakpoint, standard at and above it.
  adaptive,

  /// Always standard.
  standard,

  /// Always modal.
  modal,
}
