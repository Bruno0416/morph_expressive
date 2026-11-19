import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'morph_color_scheme.dart';

/// Shared chromatic roles for Morph components.
///
/// A variant selects *which* color role a component uses; it never selects
/// the visual type (filled, tonal, outlined…), which is chosen with a named
/// constructor, nor the finish, which is chosen with [MorphSurface].
///
/// ```dart
/// MorphButton.outlined(
///   variant: .danger,
///   surface: .frosted,
///   onPressed: onDelete,
///   child: const Text('Delete'),
/// );
/// ```
///
/// Components that accept a nullable `variant` keep their canonical Material 3
/// pairing for each visual type when it is null (for example, a tonal button
/// uses the secondary container). Pass a variant to opt into a role.
///
/// Every role resolves from the active [MorphColorScheme] through
/// [MorphVariantPalette.of], so seed, brightness and scoped theme changes
/// propagate without hardcoded colors.
enum MorphVariant {
  /// Primary roles: the main brand action.
  primary,

  /// Secondary roles: supporting actions with lower emphasis.
  secondary,

  /// Tertiary roles: contrasting accents that balance primary and secondary.
  tertiary,

  /// Neutral surface roles: lowest-emphasis, color-neutral actions.
  muted,

  /// Error roles: destructive or irreversible actions.
  danger,
}

/// Visual finish of an in-flow component, independent of its type and role.
///
/// [solid] paints opaque theme-dependent surfaces. [frosted] paints the
/// existing Morph frosted-glass treatment (`MorphGlassSurface`): a clipped
/// backdrop blur, a tint derived from the resolved semantic color and an
/// optional hairline. The frosted configuration comes from the widget's
/// `glass` parameter when present, then from
/// `MorphThemeData.floatingSurfaceGlass`, then from the default
/// `MorphSurfaceGlass()`.
///
/// Floating surfaces (menus, dialogs, sheets, tooltips, toolbars, app bars)
/// keep their historical `glass` parameter, which already distinguishes
/// inherited, explicit and disabled frosted configurations.
enum MorphSurface {
  /// Opaque surface (default).
  solid,

  /// Frosted, translucent surface with backdrop blur.
  frosted;

  /// Whether this finish paints the frosted-glass treatment.
  bool get isFrosted => this == MorphSurface.frosted;
}

/// Resolved colors for one [MorphVariant] in one [MorphColorScheme].
///
/// Components map their visual type onto these slots:
///
/// | Type | Container | Content | Border |
/// | --- | --- | --- | --- |
/// | filled | [color] | [onColor] | none |
/// | tonal | [container] | [onContainer] | none |
/// | elevated | neutral surface | [accent] | none |
/// | outlined | transparent | [accent] | [outline] |
/// | text | transparent | [accent] | none |
///
/// The same semantic role therefore keeps one chromatic interpretation across
/// families without forcing identical backgrounds on different types.
@immutable
class MorphVariantPalette with Diagnosticable {
  /// Creates a palette from explicit colors.
  const MorphVariantPalette({
    required this.color,
    required this.onColor,
    required this.container,
    required this.onContainer,
    required this.accent,
    required this.outline,
  });

  /// Resolves [variant] against [scheme].
  ///
  /// - primary/secondary/tertiary use their own role, on-role, container and
  ///   on-container colors; [accent] is the role color and [outline] is the
  ///   scheme outline.
  /// - muted uses neutral surface roles: [color] is `surfaceContainerHighest`
  ///   with `onSurface`, [container] is `surfaceContainerHigh` with
  ///   `onSurfaceVariant`, and [accent] is `onSurfaceVariant`.
  /// - danger uses the error roles and an error-tinted [outline].
  factory MorphVariantPalette.of(
    MorphColorScheme scheme,
    MorphVariant variant,
  ) {
    return switch (variant) {
      MorphVariant.primary => MorphVariantPalette(
        color: scheme.primary,
        onColor: scheme.onPrimary,
        container: scheme.primaryContainer,
        onContainer: scheme.onPrimaryContainer,
        accent: scheme.primary,
        outline: scheme.outline,
      ),
      MorphVariant.secondary => MorphVariantPalette(
        color: scheme.secondary,
        onColor: scheme.onSecondary,
        container: scheme.secondaryContainer,
        onContainer: scheme.onSecondaryContainer,
        accent: scheme.secondary,
        outline: scheme.outline,
      ),
      MorphVariant.tertiary => MorphVariantPalette(
        color: scheme.tertiary,
        onColor: scheme.onTertiary,
        container: scheme.tertiaryContainer,
        onContainer: scheme.onTertiaryContainer,
        accent: scheme.tertiary,
        outline: scheme.outline,
      ),
      MorphVariant.muted => MorphVariantPalette(
        color: scheme.surfaceContainerHighest,
        onColor: scheme.onSurface,
        container: scheme.surfaceContainerHigh,
        onContainer: scheme.onSurfaceVariant,
        accent: scheme.onSurfaceVariant,
        outline: scheme.outlineVariant,
      ),
      MorphVariant.danger => MorphVariantPalette(
        color: scheme.error,
        onColor: scheme.onError,
        container: scheme.errorContainer,
        onContainer: scheme.onErrorContainer,
        accent: scheme.error,
        outline: scheme.error,
      ),
    };
  }

  /// High-emphasis fill (filled types).
  final Color color;

  /// Content painted on [color].
  final Color onColor;

  /// Medium-emphasis fill (tonal types).
  final Color container;

  /// Content painted on [container].
  final Color onContainer;

  /// Content color on neutral or transparent surfaces (outlined, text,
  /// elevated types).
  final Color accent;

  /// Border color for outlined types.
  final Color outline;

  @override
  bool operator ==(Object other) =>
      other is MorphVariantPalette &&
      other.color == color &&
      other.onColor == onColor &&
      other.container == container &&
      other.onContainer == onContainer &&
      other.accent == accent &&
      other.outline == outline;

  @override
  int get hashCode =>
      Object.hash(color, onColor, container, onContainer, accent, outline);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(ColorProperty('color', color))
      ..add(ColorProperty('onColor', onColor))
      ..add(ColorProperty('container', container))
      ..add(ColorProperty('onContainer', onContainer))
      ..add(ColorProperty('accent', accent))
      ..add(ColorProperty('outline', outline));
  }
}

/// Convenience resolution of a [MorphVariant] against a scheme.
extension MorphVariantResolution on MorphVariant {
  /// Shorthand for [MorphVariantPalette.of].
  MorphVariantPalette resolve(MorphColorScheme scheme) =>
      MorphVariantPalette.of(scheme, this);
}
