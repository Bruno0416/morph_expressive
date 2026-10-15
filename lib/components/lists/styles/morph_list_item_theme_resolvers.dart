part of 'morph_list_item_theme.dart';

/// Field surface [_MorphListItemThemeColors] and [_MorphListItemThemeTextStyles]
/// resolve against.
///
/// Splits [MorphListItemTheme]'s color- and text-style-resolution methods into
/// this file (via mixin application, so they stay real instance members —
/// not lexically-scoped extension methods) without inflating the class body.
abstract class _MorphListItemThemeFields {
  const _MorphListItemThemeFields();

  /// See [MorphListItemTheme.containerColor].
  Color? get containerColor;

  /// See [MorphListItemTheme.selectedContainerColor].
  Color? get selectedContainerColor;

  /// See [MorphListItemTheme.labelColor].
  Color? get labelColor;

  /// See [MorphListItemTheme.supportingColor].
  Color? get supportingColor;

  /// See [MorphListItemTheme.iconColorOverride].
  Color? get iconColorOverride;

  /// See [MorphListItemTheme.selectedContentColor].
  Color? get selectedContentColor;

  /// See [MorphListItemTheme.selectedStateIconColor].
  Color? get selectedStateIconColor;

  /// See [MorphListItemTheme.avatarColor].
  Color? get avatarColor;

  /// See [MorphListItemTheme.avatarLabelColor].
  Color? get avatarLabelColor;

  /// See [MorphListItemTheme.dividerColor].
  Color? get dividerColor;

  /// See [MorphListItemTheme.focusIndicatorColor].
  Color? get focusIndicatorColor;

  /// See [MorphListItemTheme.stateLayerColor].
  Color? get stateLayerColor;

  /// See [MorphListItemTheme.hoverOpacity].
  double get hoverOpacity;

  /// See [MorphListItemTheme.focusOpacity].
  double get focusOpacity;

  /// See [MorphListItemTheme.pressedOpacity].
  double get pressedOpacity;

  /// See [MorphListItemTheme.disabledStateOpacity].
  double get disabledStateOpacity;

  /// See [MorphListItemTheme.draggedStateOpacity].
  double get draggedStateOpacity;

  /// See [MorphListItemTheme.disabledContentOpacity].
  double get disabledContentOpacity;
}

/// Color-role resolution for [MorphListItemTheme].
mixin _MorphListItemThemeColors on _MorphListItemThemeFields {
  /// Resting container color.
  Color resolveContainer(MorphColorScheme scheme) =>
      containerColor ?? scheme.surface;

  /// selectedColor.
  Color selectedColor(MorphColorScheme scheme) =>
      selectedContainerColor ?? scheme.secondaryContainer;

  /// Disabled selected container.
  Color disabledSelectedColor(MorphColorScheme scheme) =>
      scheme.onSurface.withValues(alpha: disabledContentOpacity);

  /// iconColor.
  Color iconColor(
    MorphColorScheme scheme, {
    bool selected = false,
    bool stateIcon = false,
    bool trailing = false,
  }) {
    if (selected && stateIcon) {
      return selectedStateIconColor ?? scheme.onSurface;
    }
    if (selected) {
      return selectedContentColor ?? scheme.onSecondaryContainer;
    }
    if (trailing) {
      return iconColorOverride ?? scheme.onSurface;
    }
    return iconColorOverride ?? scheme.onSurfaceVariant;
  }

  /// State-layer role color.
  Color resolveStateLayer(MorphColorScheme scheme) =>
      stateLayerColor ?? scheme.onSurface;

  /// Opacity for the active interaction, including disabled.
  double stateOpacity({
    required bool enabled,
    required bool hovered,
    required bool focused,
    required bool pressed,
    required bool dragged,
  }) {
    if (!enabled) {
      return disabledStateOpacity;
    }
    if (dragged) {
      return draggedStateOpacity;
    }
    if (pressed) {
      return pressedOpacity;
    }
    if (focused) {
      return focusOpacity;
    }
    if (hovered) {
      return hoverOpacity;
    }
    return 0;
  }

  /// Avatar container color.
  Color resolveAvatar(MorphColorScheme scheme) =>
      avatarColor ?? scheme.primaryContainer;

  /// Avatar label color.
  Color resolveAvatarLabel(MorphColorScheme scheme) =>
      avatarLabelColor ?? scheme.onPrimaryContainer;

  /// Divider color.
  Color resolveDivider(MorphColorScheme scheme) => dividerColor ?? scheme.outline;

  /// Focus ring color.
  Color resolveFocusIndicator(MorphColorScheme scheme) =>
      focusIndicatorColor ?? scheme.secondary;
}

/// Text-style resolution for [MorphListItemTheme].
mixin _MorphListItemThemeTextStyles
    on _MorphListItemThemeFields, _MorphListItemThemeColors {
  /// overlineStyle.
  TextStyle overlineStyle(
    MorphTypeScale type,
    MorphColorScheme scheme, {
    bool selected = false,
  }) => type.labelSmall.copyWith(
    color: selected
        ? (selectedContentColor ?? scheme.onSecondaryContainer)
        : (supportingColor ?? scheme.onSurfaceVariant),
  );

  /// headlineStyle.
  TextStyle headlineStyle(
    MorphTypeScale type,
    MorphColorScheme scheme, {
    bool selected = false,
  }) => type.bodyLarge.copyWith(
    color: selected
        ? (selectedContentColor ?? scheme.onSecondaryContainer)
        : (labelColor ?? scheme.onSurface),
  );

  /// supportingStyle.
  TextStyle supportingStyle(
    MorphTypeScale type,
    MorphColorScheme scheme, {
    bool selected = false,
  }) => type.bodyMedium.copyWith(
    color: selected
        ? (selectedContentColor ?? scheme.onSecondaryContainer)
        : (supportingColor ?? scheme.onSurfaceVariant),
  );

  /// Trailing meta text.
  TextStyle trailingStyle(
    MorphTypeScale type,
    MorphColorScheme scheme, {
    bool selected = false,
  }) => type.labelSmall.copyWith(
    color: selected
        ? (selectedContentColor ?? scheme.onSecondaryContainer)
        : (supportingColor ?? scheme.onSurfaceVariant),
  );

  /// Avatar initial.
  TextStyle avatarLabelStyle(MorphTypeScale type, MorphColorScheme scheme) =>
      type.titleMedium.copyWith(color: resolveAvatarLabel(scheme));
}
