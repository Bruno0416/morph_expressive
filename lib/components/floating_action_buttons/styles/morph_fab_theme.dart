import 'package:flutter/widgets.dart';

import '../../../foundations/foundations.dart';
import '../../extended_fabs/enums/morph_extended_fab.dart';
import '../enums/morph_fab.dart';

/// Resolved size and color metrics for a floating action button.
@immutable
class MorphFabMetrics {
  /// MorphFabMetrics.
  const MorphFabMetrics({
    required this.container,
    required this.iconSize,
    required this.radius,
    required this.background,
    required this.foreground,
  });

  /// container.
  final double container;

  /// iconSize.
  final double iconSize;

  /// radius.
  final double radius;

  /// background.
  final Color background;

  /// foreground.
  final Color foreground;
}

/// Resolved metrics for an extended floating action button size.
@immutable
class MorphExtendedFabMetrics {
  /// Creates resolved extended FAB metrics.
  const MorphExtendedFabMetrics({
    required this.height,
    required this.cornerRadius,
    required this.leadingSpace,
    required this.trailingSpace,
    required this.iconLabelGap,
    required this.iconSize,
    required this.collapsedHorizontalPadding,
    required this.labelRole,
  });

  /// Container height (dp).
  final double height;

  /// Corner radius (dp).
  final double cornerRadius;

  /// Start padding when extended (dp).
  final double leadingSpace;

  /// End padding when extended (dp).
  final double trailingSpace;

  /// Gap between icon and label (dp).
  final double iconLabelGap;

  /// Icon size (dp).
  final double iconSize;

  /// Horizontal padding when collapsed to icon-only (dp).
  final double collapsedHorizontalPadding;

  /// Type role for the label.
  final MorphTypeRole labelRole;

  /// Label [TextStyle] for [type] and [foreground].
  TextStyle labelStyle(MorphTypeScale type, Color foreground) {
    final TextStyle base = switch (labelRole) {
      MorphTypeRole.titleMedium => type.titleMedium,
      MorphTypeRole.titleLarge => type.titleLarge,
      MorphTypeRole.headlineSmall => type.headlineSmall,
      _ => type.titleMedium,
    };
    return base.copyWith(color: foreground);
  }
}

/// Theme values for the extended FAB variant.
@immutable
class MorphExtendedFabTheme {
  /// MorphExtendedFabTheme.
  const MorphExtendedFabTheme({
    this.pressedScale = 0.95,
    this.minWidth = 80,
    this.appearStartScale = 0.6,
    this.focusRingWidth = 3,
    this.focusRingGap = 2,
    this.focusRingColor,
    this.disabledBackgroundAlpha = 0.1,
    this.disabledForegroundAlpha = 0.38,
    this.smallHeight = 56,
    this.smallRadius = 16,
    this.smallIconSize = 24,
    this.smallLeading = 16,
    this.smallTrailing = 16,
    this.smallIconLabelGap = 8,
    this.smallCollapsedPadding = 16,
    this.mediumHeight = 80,
    this.mediumRadius = 20,
    this.mediumIconSize = 28,
    this.mediumLeading = 26,
    this.mediumTrailing = 26,
    this.mediumIconLabelGap = 12,
    this.mediumCollapsedPadding = 26,
    this.largeHeight = 96,
    this.largeRadius = 28,
    this.largeIconSize = 36,
    this.largeLeading = 28,
    this.largeTrailing = 28,
    this.largeIconLabelGap = 16,
    this.largeCollapsedPadding = 28,
  });

  /// Package defaults.
  static const MorphExtendedFabTheme defaults = MorphExtendedFabTheme();

  /// Press scale while held.
  final double pressedScale;

  /// Minimum extended width (dp). Spec: 80.
  final double minWidth;

  /// Initial scale for appear morph.
  final double appearStartScale;

  /// Focus ring stroke width (dp).
  final double focusRingWidth;

  /// Gap between surface and focus ring (dp).
  final double focusRingGap;

  /// Focus ring color; defaults to secondary.
  final Color? focusRingColor;

  /// Disabled container alpha over on-surface.
  final double disabledBackgroundAlpha;

  /// Disabled foreground alpha over on-surface.
  final double disabledForegroundAlpha;

  /// smallHeight.
  final double smallHeight;

  /// smallRadius.
  final double smallRadius;

  /// smallIconSize.
  final double smallIconSize;

  /// smallLeading.
  final double smallLeading;

  /// smallTrailing.
  final double smallTrailing;

  /// smallIconLabelGap.
  final double smallIconLabelGap;

  /// smallCollapsedPadding.
  final double smallCollapsedPadding;

  /// mediumHeight.
  final double mediumHeight;

  /// mediumRadius.
  final double mediumRadius;

  /// mediumIconSize.
  final double mediumIconSize;

  /// mediumLeading.
  final double mediumLeading;

  /// mediumTrailing.
  final double mediumTrailing;

  /// mediumIconLabelGap.
  final double mediumIconLabelGap;

  /// mediumCollapsedPadding.
  final double mediumCollapsedPadding;

  /// largeHeight.
  final double largeHeight;

  /// largeRadius.
  final double largeRadius;

  /// largeIconSize.
  final double largeIconSize;

  /// largeLeading.
  final double largeLeading;

  /// largeTrailing.
  final double largeTrailing;

  /// largeIconLabelGap.
  final double largeIconLabelGap;

  /// largeCollapsedPadding.
  final double largeCollapsedPadding;

  /// Elevation for hover vs rest.
  double elevation({required bool hovered}) =>
      hovered ? MorphElevation.level4 : MorphElevation.level3;

  /// Resolved focus ring color.
  Color resolveFocusRingColor(MorphColorScheme scheme) =>
      focusRingColor ?? scheme.secondary;

  /// Resolves size tokens for [size].
  MorphExtendedFabMetrics resolve(MorphExtendedFabSize size) {
    switch (size) {
      case MorphExtendedFabSize.small:
        return MorphExtendedFabMetrics(
          height: smallHeight,
          cornerRadius: smallRadius,
          leadingSpace: smallLeading,
          trailingSpace: smallTrailing,
          iconLabelGap: smallIconLabelGap,
          iconSize: smallIconSize,
          collapsedHorizontalPadding: smallCollapsedPadding,
          labelRole: MorphTypeRole.titleMedium,
        );
      case MorphExtendedFabSize.medium:
        return MorphExtendedFabMetrics(
          height: mediumHeight,
          cornerRadius: mediumRadius,
          leadingSpace: mediumLeading,
          trailingSpace: mediumTrailing,
          iconLabelGap: mediumIconLabelGap,
          iconSize: mediumIconSize,
          collapsedHorizontalPadding: mediumCollapsedPadding,
          labelRole: MorphTypeRole.titleLarge,
        );
      case MorphExtendedFabSize.large:
        return MorphExtendedFabMetrics(
          height: largeHeight,
          cornerRadius: largeRadius,
          leadingSpace: largeLeading,
          trailingSpace: largeTrailing,
          iconLabelGap: largeIconLabelGap,
          iconSize: largeIconSize,
          collapsedHorizontalPadding: largeCollapsedPadding,
          labelRole: MorphTypeRole.headlineSmall,
        );
    }
  }

  /// copyWith.
  MorphExtendedFabTheme copyWith({
    double? pressedScale,
    double? minWidth,
    double? appearStartScale,
    double? focusRingWidth,
    double? focusRingGap,
    Color? focusRingColor,
    bool clearFocusRingColor = false,
    double? disabledBackgroundAlpha,
    double? disabledForegroundAlpha,
    double? smallHeight,
    double? smallRadius,
    double? smallIconSize,
    double? smallLeading,
    double? smallTrailing,
    double? smallIconLabelGap,
    double? smallCollapsedPadding,
    double? mediumHeight,
    double? mediumRadius,
    double? mediumIconSize,
    double? mediumLeading,
    double? mediumTrailing,
    double? mediumIconLabelGap,
    double? mediumCollapsedPadding,
    double? largeHeight,
    double? largeRadius,
    double? largeIconSize,
    double? largeLeading,
    double? largeTrailing,
    double? largeIconLabelGap,
    double? largeCollapsedPadding,
  }) {
    return MorphExtendedFabTheme(
      pressedScale: pressedScale ?? this.pressedScale,
      minWidth: minWidth ?? this.minWidth,
      appearStartScale: appearStartScale ?? this.appearStartScale,
      focusRingWidth: focusRingWidth ?? this.focusRingWidth,
      focusRingGap: focusRingGap ?? this.focusRingGap,
      focusRingColor: clearFocusRingColor
          ? null
          : (focusRingColor ?? this.focusRingColor),
      disabledBackgroundAlpha:
          disabledBackgroundAlpha ?? this.disabledBackgroundAlpha,
      disabledForegroundAlpha:
          disabledForegroundAlpha ?? this.disabledForegroundAlpha,
      smallHeight: smallHeight ?? this.smallHeight,
      smallRadius: smallRadius ?? this.smallRadius,
      smallIconSize: smallIconSize ?? this.smallIconSize,
      smallLeading: smallLeading ?? this.smallLeading,
      smallTrailing: smallTrailing ?? this.smallTrailing,
      smallIconLabelGap: smallIconLabelGap ?? this.smallIconLabelGap,
      smallCollapsedPadding:
          smallCollapsedPadding ?? this.smallCollapsedPadding,
      mediumHeight: mediumHeight ?? this.mediumHeight,
      mediumRadius: mediumRadius ?? this.mediumRadius,
      mediumIconSize: mediumIconSize ?? this.mediumIconSize,
      mediumLeading: mediumLeading ?? this.mediumLeading,
      mediumTrailing: mediumTrailing ?? this.mediumTrailing,
      mediumIconLabelGap: mediumIconLabelGap ?? this.mediumIconLabelGap,
      mediumCollapsedPadding:
          mediumCollapsedPadding ?? this.mediumCollapsedPadding,
      largeHeight: largeHeight ?? this.largeHeight,
      largeRadius: largeRadius ?? this.largeRadius,
      largeIconSize: largeIconSize ?? this.largeIconSize,
      largeLeading: largeLeading ?? this.largeLeading,
      largeTrailing: largeTrailing ?? this.largeTrailing,
      largeIconLabelGap: largeIconLabelGap ?? this.largeIconLabelGap,
      largeCollapsedPadding:
          largeCollapsedPadding ?? this.largeCollapsedPadding,
    );
  }
}

/// Theme values for `MorphFab` and `MorphExtendedFab`.
@immutable
class MorphFabTheme extends MorphThemeExtension<MorphFabTheme> {
  /// MorphFabTheme.
  const MorphFabTheme({
    this.pressedScale = 0.95,
    this.smallContainer = 40,
    this.smallIconSize = 24,
    this.smallRadius = 12,
    this.regularContainer = 56,
    this.regularIconSize = 24,
    this.regularRadius = 16,
    this.mediumContainer = 80,
    this.mediumIconSize = 28,
    this.mediumRadius = 20,
    this.largeContainer = 96,
    this.largeIconSize = 36,
    this.largeRadius = 28,
    this.focusRingWidth = 3,
    this.focusRingGap = 2,
    this.focusRingColor,
    this.disabledBackgroundAlpha = 0.1,
    this.disabledForegroundAlpha = 0.38,
    this.appearStartScale = 0.6,
    this.extended = MorphExtendedFabTheme.defaults,
    this.gradient,
  });

  /// defaults.
  static const MorphFabTheme defaults = MorphFabTheme();

  /// pressedScale.
  final double pressedScale;

  /// smallContainer.
  final double smallContainer;

  /// smallIconSize.
  final double smallIconSize;

  /// smallRadius.
  final double smallRadius;

  /// regularContainer.
  final double regularContainer;

  /// regularIconSize.
  final double regularIconSize;

  /// regularRadius.
  final double regularRadius;

  /// mediumContainer.
  final double mediumContainer;

  /// mediumIconSize.
  final double mediumIconSize;

  /// mediumRadius.
  final double mediumRadius;

  /// largeContainer.
  final double largeContainer;

  /// largeIconSize.
  final double largeIconSize;

  /// largeRadius.
  final double largeRadius;

  /// Focus ring stroke width (dp). Spec: 3.
  final double focusRingWidth;

  /// Gap between FAB edge and focus ring (dp). Spec: 2.
  final double focusRingGap;

  /// Focus ring color; defaults to [MorphColorScheme.secondary].
  final Color? focusRingColor;

  /// Disabled container alpha over on-surface.
  final double disabledBackgroundAlpha;

  /// Disabled icon alpha over on-surface.
  final double disabledForegroundAlpha;

  /// Initial scale for appear morph.
  final double appearStartScale;

  /// extended.
  final MorphExtendedFabTheme extended;

  /// Optional theme-level FAB gradient fill.
  final Gradient? gradient;

  /// resolve.
  MorphFabMetrics resolve({
    required MorphFabSize size,
    required MorphFabColor color,
    required MorphColorScheme scheme,
    bool enabled = true,
  }) {
    final dims = _dimensions(size);
    final palette = _palette(color, scheme, enabled: enabled);
    return MorphFabMetrics(
      container: dims.container,
      iconSize: dims.iconSize,
      radius: dims.radius,
      background: palette.background,
      foreground: palette.foreground,
    );
  }

  /// Resolved focus ring color for [scheme].
  Color resolveFocusRingColor(MorphColorScheme scheme) =>
      focusRingColor ?? scheme.secondary;

  _FabDimensions _dimensions(MorphFabSize size) {
    switch (size) {
      case MorphFabSize.small:
        return _FabDimensions(
          container: smallContainer,
          iconSize: smallIconSize,
          radius: smallRadius,
        );
      case MorphFabSize.regular:
        return _FabDimensions(
          container: regularContainer,
          iconSize: regularIconSize,
          radius: regularRadius,
        );
      case MorphFabSize.medium:
        return _FabDimensions(
          container: mediumContainer,
          iconSize: mediumIconSize,
          radius: mediumRadius,
        );
      case MorphFabSize.large:
        return _FabDimensions(
          container: largeContainer,
          iconSize: largeIconSize,
          radius: largeRadius,
        );
    }
  }

  _FabPalette _palette(
    MorphFabColor color,
    MorphColorScheme scheme, {
    required bool enabled,
  }) {
    if (!enabled) {
      return _FabPalette(
        scheme.onSurface.withValues(alpha: disabledBackgroundAlpha),
        scheme.onSurface.withValues(alpha: disabledForegroundAlpha),
      );
    }
    switch (color) {
      case MorphFabColor.primary:
        return _FabPalette(scheme.primaryContainer, scheme.onPrimaryContainer);
      case MorphFabColor.secondary:
        return _FabPalette(
          scheme.secondaryContainer,
          scheme.onSecondaryContainer,
        );
      case MorphFabColor.tertiary:
        return _FabPalette(
          scheme.tertiaryContainer,
          scheme.onTertiaryContainer,
        );
      case MorphFabColor.primaryFilled:
        return _FabPalette(scheme.primary, scheme.onPrimary);
      case MorphFabColor.secondaryFilled:
        return _FabPalette(scheme.secondary, scheme.onSecondary);
      case MorphFabColor.tertiaryFilled:
        return _FabPalette(scheme.tertiary, scheme.onTertiary);
      case MorphFabColor.surface:
        return _FabPalette(scheme.surfaceContainerHigh, scheme.primary);
    }
  }

  @override
  MorphFabTheme copyWith({
    double? pressedScale,
    double? smallContainer,
    double? smallIconSize,
    double? smallRadius,
    double? regularContainer,
    double? regularIconSize,
    double? regularRadius,
    double? mediumContainer,
    double? mediumIconSize,
    double? mediumRadius,
    double? largeContainer,
    double? largeIconSize,
    double? largeRadius,
    double? focusRingWidth,
    double? focusRingGap,
    Color? focusRingColor,
    bool clearFocusRingColor = false,
    double? disabledBackgroundAlpha,
    double? disabledForegroundAlpha,
    double? appearStartScale,
    MorphExtendedFabTheme? extended,
    Gradient? gradient,
  }) {
    return MorphFabTheme(
      pressedScale: pressedScale ?? this.pressedScale,
      smallContainer: smallContainer ?? this.smallContainer,
      smallIconSize: smallIconSize ?? this.smallIconSize,
      smallRadius: smallRadius ?? this.smallRadius,
      regularContainer: regularContainer ?? this.regularContainer,
      regularIconSize: regularIconSize ?? this.regularIconSize,
      regularRadius: regularRadius ?? this.regularRadius,
      mediumContainer: mediumContainer ?? this.mediumContainer,
      mediumIconSize: mediumIconSize ?? this.mediumIconSize,
      mediumRadius: mediumRadius ?? this.mediumRadius,
      largeContainer: largeContainer ?? this.largeContainer,
      largeIconSize: largeIconSize ?? this.largeIconSize,
      largeRadius: largeRadius ?? this.largeRadius,
      focusRingWidth: focusRingWidth ?? this.focusRingWidth,
      focusRingGap: focusRingGap ?? this.focusRingGap,
      focusRingColor: clearFocusRingColor
          ? null
          : (focusRingColor ?? this.focusRingColor),
      disabledBackgroundAlpha:
          disabledBackgroundAlpha ?? this.disabledBackgroundAlpha,
      disabledForegroundAlpha:
          disabledForegroundAlpha ?? this.disabledForegroundAlpha,
      appearStartScale: appearStartScale ?? this.appearStartScale,
      extended: extended ?? this.extended,
      gradient: gradient ?? this.gradient,
    );
  }

  @override
  MorphFabTheme lerp(MorphFabTheme? other, double t) {
    if (other is! MorphFabTheme) {
      return this;
    }
    return MorphFabTheme(
      pressedScale: _lerpDouble(pressedScale, other.pressedScale, t)!,
      smallContainer: _lerpDouble(smallContainer, other.smallContainer, t)!,
      smallIconSize: _lerpDouble(smallIconSize, other.smallIconSize, t)!,
      smallRadius: _lerpDouble(smallRadius, other.smallRadius, t)!,
      regularContainer: _lerpDouble(
        regularContainer,
        other.regularContainer,
        t,
      )!,
      regularIconSize: _lerpDouble(regularIconSize, other.regularIconSize, t)!,
      regularRadius: _lerpDouble(regularRadius, other.regularRadius, t)!,
      mediumContainer: _lerpDouble(mediumContainer, other.mediumContainer, t)!,
      mediumIconSize: _lerpDouble(mediumIconSize, other.mediumIconSize, t)!,
      mediumRadius: _lerpDouble(mediumRadius, other.mediumRadius, t)!,
      largeContainer: _lerpDouble(largeContainer, other.largeContainer, t)!,
      largeIconSize: _lerpDouble(largeIconSize, other.largeIconSize, t)!,
      largeRadius: _lerpDouble(largeRadius, other.largeRadius, t)!,
      focusRingWidth: _lerpDouble(focusRingWidth, other.focusRingWidth, t)!,
      focusRingGap: _lerpDouble(focusRingGap, other.focusRingGap, t)!,
      focusRingColor:
          Color.lerp(focusRingColor, other.focusRingColor, t) ??
          focusRingColor ??
          other.focusRingColor,
      disabledBackgroundAlpha: _lerpDouble(
        disabledBackgroundAlpha,
        other.disabledBackgroundAlpha,
        t,
      )!,
      disabledForegroundAlpha: _lerpDouble(
        disabledForegroundAlpha,
        other.disabledForegroundAlpha,
        t,
      )!,
      appearStartScale: _lerpDouble(
        appearStartScale,
        other.appearStartScale,
        t,
      )!,
      extended: extended,
      gradient: t < 0.5 ? gradient : other.gradient,
    );
  }

  double? _lerpDouble(double a, double b, double t) => a + (b - a) * t;
}

@immutable
class _FabDimensions {
  const _FabDimensions({
    required this.container,
    required this.iconSize,
    required this.radius,
  });

  final double container;
  final double iconSize;
  final double radius;
}

@immutable
class _FabPalette {
  const _FabPalette(this.background, this.foreground);

  final Color background;
  final Color foreground;
}
