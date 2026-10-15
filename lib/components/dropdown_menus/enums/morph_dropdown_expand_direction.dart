/// Controls the direction in which the dropdown overlay expands.
///
/// * [MorphDropdownExpandDirection.auto]: Automatically determines the direction based on
///   available space. Falls back to showing above if there's not enough space below.
/// * [MorphDropdownExpandDirection.down]: Forces the dropdown to expand downward.
/// * [MorphDropdownExpandDirection.up]: Forces the dropdown to expand upward.
enum MorphDropdownExpandDirection {
  /// Automatically determine the best direction based on available space.
  auto,

  /// Force the dropdown to expand downward.
  down,

  /// Force the dropdown to expand upward.
  up,
}
