part of 'morph_navigation_rail_theme.dart';

/// Color and text-style resolution helpers for [MorphNavigationRailTheme],
/// split out to keep the theme class under the component length
/// guidelines. Public (not underscore-prefixed) because these methods are
/// called from other component files outside this library, and a
/// library-private extension is invisible across file/library boundaries.
extension MorphNavigationRailThemeColors on MorphNavigationRailTheme {
  /// Active icon color.
  Color activeIconColor(MorphColorScheme scheme) =>
      activeIconAndLabel ?? scheme.onSecondaryContainer;

  /// Active label color.
  Color activeLabelColorResolved(MorphColorScheme scheme) =>
      activeLabelColor ?? scheme.onSurface;

  /// Kept for callers that still ask for one active color.
  Color activeIconAndLabelColor(MorphColorScheme scheme) =>
      activeIconColor(scheme);

  /// inactiveIconAndLabelColor.
  Color inactiveIconAndLabelColor(MorphColorScheme scheme) =>
      inactiveIconAndLabel ?? scheme.onSurfaceVariant;

  /// activeIndicatorColorResolved.
  Color activeIndicatorColorResolved(MorphColorScheme scheme) =>
      activeIndicatorColor ?? scheme.secondaryContainer;

  /// containerColorResolved.
  Color containerColorResolved(MorphColorScheme scheme) =>
      containerColor ?? scheme.surface;

  /// Modal container color.
  Color modalContainerColorResolved(MorphColorScheme scheme) =>
      modalContainerColor ?? scheme.surfaceContainer;

  /// Scrolled container color.
  Color scrolledContainerColorResolved(MorphColorScheme scheme) =>
      scrolledContainerColor ?? scheme.surfaceContainer;

  /// State layer color.
  Color stateLayerColorResolved(MorphColorScheme scheme) =>
      stateLayerColor ?? scheme.onSecondaryContainer;

  /// Focus ring color.
  Color focusRingColorResolved(MorphColorScheme scheme) =>
      focusRingColor ?? scheme.secondary;

  /// Menu icon color.
  Color menuColorResolved(MorphColorScheme scheme) =>
      menuColor ?? scheme.onSurfaceVariant;

  /// Badge fill.
  Color badgeBackgroundResolved(MorphColorScheme scheme) =>
      badgeBackground ?? scheme.error;

  /// Badge label.
  Color badgeLabelResolved(MorphColorScheme scheme) =>
      badgeLargeLabel ?? scheme.onError;

  /// Divider color.
  Color dividerColorResolved(MorphColorScheme scheme) =>
      dividerColor ?? scheme.outlineVariant;

  /// Label style for [selected].
  TextStyle labelStyle(MorphColorScheme scheme, {required bool selected}) {
    return TextStyle(
      fontSize: labelFontSize,
      height: labelLineHeight / labelFontSize,
      letterSpacing: labelLetterSpacing,
      fontWeight: selected ? activeLabelWeight : inactiveLabelWeight,
      color: selected
          ? activeLabelColorResolved(scheme)
          : inactiveIconAndLabelColor(scheme),
    );
  }
}
