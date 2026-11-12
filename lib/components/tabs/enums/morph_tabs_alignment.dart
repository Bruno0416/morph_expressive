/// How fixed tabs share the bar width.
enum MorphTabsAlignment {
  /// Equal sections across the full container.
  fill,

  /// Each tab is as wide as the widest tab, and the group is centered.
  center,

  /// Each tab is as wide as the widest tab, and the group starts at the edge.
  leading,

  /// Each tab is as wide as its own content plus its horizontal padding, and
  /// the group starts at the edge. Falls back to scrolling when it overflows.
  content,
}
