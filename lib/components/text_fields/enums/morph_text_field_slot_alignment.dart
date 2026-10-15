/// Vertical position of `MorphTextField` icons or prefix/suffix text when the
/// field is taller than one line (multi-line or text area).
enum MorphTextFieldSlotAlignment {
  /// Stays where it sits in a single-line field, level with the first line.
  firstLine,

  /// Vertically centered in the field.
  center,

  /// Level with the last line, at the bottom of the field.
  bottom,
}
