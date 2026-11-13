/// Visual presentation of the selection indicator of `MorphTabs`.
///
/// Independent of `MorphTabsVariant`: the variant describes the hierarchy of
/// the tab (icon above or beside the label), the style describes how the
/// selection is drawn.
enum MorphTabsIndicatorStyle {
  /// A thin line along the bottom edge. This is the compatibility default.
  underline,

  /// A persistent filled surface (pill or rounded rectangle) that travels
  /// behind the tab content.
  surface,
}

/// How the indicator moves between tabs.
///
/// Only the indicator moves. Tabs, labels, icons and the bar height stay still.
enum MorphTabsIndicatorMotion {
  /// The indicator rectangle interpolates between origin and destination.
  /// No stretching and no oscillation. Default.
  slide,

  /// Like [slide], but the leading edge advances slightly before the trailing
  /// edge and the shape recovers on arrival. Both edges are monotonic and end
  /// exactly on the destination (no rebound, no overshoot).
  elastic,
}

/// What the indicator width follows.
///
/// Independent of the tab distribution (`MorphTabsAlignment`, `scrollable`).
enum MorphTabsIndicatorFit {
  /// The measured icon/label/badge content, plus the configured padding
  /// (surface) or minus the configured inset (underline).
  content,

  /// The whole tab slot minus the configured tab inset.
  tab,
}
