/// How buttons in the group are visually connected.
enum MorphButtonGroupType {
  /// Independent buttons with size-token between-space (18 / 12 / 8 / 8 / 8).
  standard,

  /// Joined segments with a 2dp gap; inner corners morph on press/selection.
  connected,
}

/// Spec density levels 0, −1, −2, −3.
///
/// Density shrinks container height (−4dp per level). Between-space is unchanged.
enum MorphButtonGroupDensity {
  /// Level 0 — full token container height.
  regular,

  /// Level −1.
  comfortable,

  /// Level −2.
  compact,

  /// Level −3.
  dense,
}

/// Helpers for [MorphButtonGroupDensity].
extension MorphButtonGroupDensityX on MorphButtonGroupDensity {
  /// Spec density level (0, −1, −2, −3).
  int get level => switch (this) {
    MorphButtonGroupDensity.regular => 0,
    MorphButtonGroupDensity.comfortable => -1,
    MorphButtonGroupDensity.compact => -2,
    MorphButtonGroupDensity.dense => -3,
  };

  /// Height delta in dp (−4.0 per density level).
  double get heightAdjustment => level * 4.0;
}

/// How the group handles actions that do not fit the available main-axis space.
enum MorphButtonGroupOverflow {
  /// Clip / overflow without a special strategy (content may exceed bounds).
  none,

  /// Scroll along the main axis when constraints are bounded.
  scroll,

  /// Collapse trailing actions into an overflow menu trigger.
  menu,

  /// Shift a visible paging window with back/forward overflow triggers.
  experimentalPaging,
}

/// Presentation style for [MorphButtonGroupOverflow.menu].
enum MorphButtonGroupOverflowMenuStyle {
  /// Overflow actions in a popup menu.
  popup,

  /// Overflow actions in a modal bottom sheet.
  bottomSheet,
}
