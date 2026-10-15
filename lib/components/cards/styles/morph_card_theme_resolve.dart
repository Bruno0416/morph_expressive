part of 'morph_card_theme.dart';

/// Color, elevation, and type-style resolution for [MorphCardTheme].
///
/// None of these override an inherited member, so they live in this
/// extension instead of the main class body. Public (not `_`-prefixed)
/// because these were public instance methods on [MorphCardTheme] before this
/// split, and stay reachable the same way for existing callers.
extension MorphCardThemeResolve on MorphCardTheme {
  /// Resolved outer radius.
  BorderRadius get borderRadius => BorderRadius.circular(radius);

  /// Collection gap clamped to [maxGap].
  double resolveGap([double? override]) {
    final double value = override ?? gap;
    if (value > maxGap) {
      return maxGap;
    }
    return value;
  }

  /// Enabled container color for [variant].
  Color backgroundColor(MorphColorScheme scheme, MorphCardVariant variant) {
    final Color? shared = containerColor;
    if (shared != null) {
      return shared;
    }
    switch (variant) {
      case MorphCardVariant.elevated:
        return elevatedContainerColor ?? scheme.surfaceContainerLow;
      case MorphCardVariant.filled:
        return filledContainerColor ?? scheme.surfaceContainerHighest;
      case MorphCardVariant.outlined:
        return outlinedContainerColor ?? scheme.surface;
    }
  }

  /// Container color, including the disabled roles.
  Color containerColorFor(
    MorphColorScheme scheme,
    MorphCardVariant variant, {
    required bool enabled,
  }) {
    if (enabled) {
      return backgroundColor(scheme, variant);
    }
    switch (variant) {
      case MorphCardVariant.elevated:
        return disabledElevatedColor ?? scheme.surface;
      case MorphCardVariant.filled:
        return disabledFilledColor ?? scheme.onSurface;
      case MorphCardVariant.outlined:
        return backgroundColor(scheme, variant);
    }
  }

  /// Enabled outline color.
  Color outlineColor(MorphColorScheme scheme) =>
      outlineColorOverride ?? scheme.outlineVariant;

  /// Outline color for the current enabled and focus state.
  Color outlineColorFor(
    MorphColorScheme scheme, {
    required bool enabled,
    required bool focused,
  }) {
    if (!enabled) {
      return disabledOutlineColor ??
          scheme.outline.withValues(alpha: disabledOutlineOpacity);
    }
    if (focused) {
      return focusedOutlineColor ?? scheme.onSurface;
    }
    return outlineColor(scheme);
  }

  /// Icon color.
  Color resolveIconColor(MorphColorScheme scheme) => iconColor ?? scheme.primary;

  /// Shadow color.
  Color resolveShadowColor(MorphColorScheme scheme) =>
      shadowColor ?? scheme.shadow;

  /// Surface tint role. Not painted on the container.
  Color resolveSurfaceTint(MorphColorScheme scheme) =>
      surfaceTint ?? scheme.primary;

  /// Focus ring color.
  Color resolveFocusColor(MorphColorScheme scheme) =>
      focusColor ?? scheme.secondary;

  /// State-layer color.
  Color resolveStateLayerColor(MorphColorScheme scheme) =>
      stateLayerColor ?? scheme.onSurface;

  /// Scrim behind text on media.
  Color resolveScrimColor(MorphColorScheme scheme) =>
      (scrimColor ?? scheme.scrim).withValues(alpha: scrimOpacity);

  /// Container-transform scrim.
  Color resolveTransformScrim(MorphColorScheme scheme) =>
      (transformScrimColor ?? scheme.scrim).withValues(alpha: scrimOpacity);

  /// Open container-transform fill.
  Color resolveTransformOpenColor(MorphColorScheme scheme) =>
      transformOpenColor ?? scheme.surface;

  /// Plate behind text on media.
  Color resolveOverlayPlate(MorphColorScheme scheme) =>
      overlayPlateColor ?? scheme.surfaceContainerHigh;

  /// Elevation for [variant] and the active interaction.
  ///
  /// Disabled wins, then dragged, pressed, focused, hovered, then resting.
  double elevation(
    MorphCardVariant variant, {
    required bool hovered,
    bool focused = false,
    bool pressed = false,
    bool dragged = false,
    bool enabled = true,
  }) {
    if (!enabled) {
      return MorphElevation.level0;
    }
    if (dragged) {
      return _draggedElevation(variant);
    }
    if (pressed) {
      return _pressedElevation(variant);
    }
    if (focused) {
      return _focusedElevation(variant);
    }
    if (hovered) {
      return _hoverElevation(variant);
    }
    return _restingElevation(variant);
  }

  double _restingElevation(MorphCardVariant variant) {
    switch (variant) {
      case MorphCardVariant.elevated:
        return elevatedElevation;
      case MorphCardVariant.filled:
        return filledElevation;
      case MorphCardVariant.outlined:
        return outlinedElevation;
    }
  }

  double _hoverElevation(MorphCardVariant variant) {
    switch (variant) {
      case MorphCardVariant.elevated:
        return elevatedHoverElevation;
      case MorphCardVariant.filled:
        return filledHoverElevation;
      case MorphCardVariant.outlined:
        return outlinedHoverElevation;
    }
  }

  double _focusedElevation(MorphCardVariant variant) {
    switch (variant) {
      case MorphCardVariant.elevated:
        return elevatedFocusElevation;
      case MorphCardVariant.filled:
        return filledFocusElevation;
      case MorphCardVariant.outlined:
        return outlinedFocusElevation;
    }
  }

  double _pressedElevation(MorphCardVariant variant) {
    switch (variant) {
      case MorphCardVariant.elevated:
        return elevatedPressedElevation;
      case MorphCardVariant.filled:
        return filledPressedElevation;
      case MorphCardVariant.outlined:
        return outlinedPressedElevation;
    }
  }

  double _draggedElevation(MorphCardVariant variant) {
    switch (variant) {
      case MorphCardVariant.elevated:
        return elevatedDraggedElevation;
      case MorphCardVariant.filled:
        return filledDraggedElevation;
      case MorphCardVariant.outlined:
        return outlinedDraggedElevation;
    }
  }

  /// Headline style.
  TextStyle headlineStyle(MorphThemeData theme) {
    return theme.typeScale.titleMedium.copyWith(
      color: headlineColor ?? theme.colorScheme.onSurface,
    );
  }

  /// Subhead style.
  TextStyle subheadStyle(MorphThemeData theme) {
    return theme.typeScale.titleSmall.copyWith(
      color: subheadColor ?? theme.colorScheme.onSurfaceVariant,
    );
  }

  /// Supporting text style.
  TextStyle supportingStyle(MorphThemeData theme) {
    return theme.typeScale.bodyMedium.copyWith(
      color: supportingColor ?? theme.colorScheme.onSurfaceVariant,
    );
  }
}
