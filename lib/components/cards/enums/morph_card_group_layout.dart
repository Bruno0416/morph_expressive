/// How a card collection arranges its children.
enum MorphCardGroupLayout {
  /// Equal columns that wrap.
  grid,

  /// Columns filled in turn so row heights can differ.
  staggered,

  /// One vertical sequence.
  list,

  /// A horizontal row that scrolls.
  carousel,
}
