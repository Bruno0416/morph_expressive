/// Placement of an explicit validation error icon in a `MorphTextField`.
///
/// Prefix is the start side (before the input); suffix is the end side
/// (after the input). Both follow the ambient text direction.
enum MorphTextFieldErrorIconPosition {
  /// Before the editable content (start side in the current text direction).
  prefix,

  /// After the editable content (end side in the current text direction).
  suffix,
}
