import 'package:material_ui/material_ui.dart'
    show Color, Colors, WidgetState, immutable;

import '../../../foundations/foundations.dart';
import '../enums/morph_button_enums.dart';
import '../models/morph_button_measurements.dart';
import '../res/morph_button_constants.dart';

/// Theme values for `MorphButton`.
@immutable
class MorphButtonTheme extends MorphThemeExtension<MorphButtonTheme> {
  /// MorphButtonTheme.
  const MorphButtonTheme({
    this.focusRingWidth = 2,
    this.focusRingGap = MorphButtonConstants.kFocusRingGap,
    this.minWidthFloor = 48,
    this.dividerHeight = 24,
    this.connectedInnerRadius = 11,
    this.connectedPressedInnerRadius = 6,
    this.labelSlideDistance = 10,
    this.shapeSpring = MorphMotion.buttonMorph,
    this.pressDuration = const Duration(milliseconds: 90),
    this.releaseDuration = const Duration(milliseconds: 160),
  });

  /// Temporal corner morph profile; independent of Material animationDuration.
  final Duration pressDuration;
  final Duration releaseDuration;

  /// defaults.

  static const MorphButtonTheme defaults = MorphButtonTheme();

  /// focusRingWidth.

  final double focusRingWidth;

  /// focusRingGap.
  final double focusRingGap;

  /// minWidthFloor.
  final double minWidthFloor;

  /// dividerHeight.
  final double dividerHeight;

  /// connectedInnerRadius.
  final double connectedInnerRadius;

  /// connectedPressedInnerRadius.
  final double connectedPressedInnerRadius;

  /// Horizontal distance used by selection label transitions.
  final double labelSlideDistance;

  /// Legacy spatial spring, retained for consumers and spring-based effects.
  /// Button corner transitions use [pressDuration] / [releaseDuration].
  final MorphSpring shapeSpring;

  static final Map<MorphButtonSize, double> _squareRadiusTable = {
    MorphButtonSize.xs: 12,
    MorphButtonSize.sm: 12,
    MorphButtonSize.md: 16,
    MorphButtonSize.lg: 28,
    MorphButtonSize.xl: 28,
  };

  static final Map<MorphButtonSize, double> _pressedRadiusTable = {
    MorphButtonSize.xs: 10,
    MorphButtonSize.sm: 10,
    MorphButtonSize.md: 15,
    MorphButtonSize.lg: 20,
    MorphButtonSize.xl: 20,
  };

  /// Legacy intermediate hover radii (used by toggle; buttons keep resting).
  static final Map<MorphButtonSize, double> _hoveredRadiusTable = {
    MorphButtonSize.xs: 10,
    MorphButtonSize.sm: 10,
    MorphButtonSize.md: 14,
    MorphButtonSize.lg: 22,
    MorphButtonSize.xl: 22,
  };

  static final Map<MorphButtonSize, double> _equalizedMinWidthTable = {
    MorphButtonSize.xs: 40,
    MorphButtonSize.sm: 56,
    MorphButtonSize.md: 72,
    MorphButtonSize.lg: 96,
    MorphButtonSize.xl: 120,
  };

  static final Map<MorphButtonSize, MorphButtonMeasurements>
  _measurementsTable = {
    MorphButtonSize.xs: const MorphButtonMeasurements(
      height: 32,
      hPadding: 12,
      iconSize: 20,
      iconGap: 4,
    ),
    MorphButtonSize.sm: const MorphButtonMeasurements(
      height: 40,
      hPadding: 16,
      iconSize: 20,
      iconGap: 8,
    ),
    MorphButtonSize.md: const MorphButtonMeasurements(
      height: 56,
      hPadding: 24,
      iconSize: 24,
      iconGap: 8,
    ),
    MorphButtonSize.lg: const MorphButtonMeasurements(
      height: 96,
      hPadding: 48,
      iconSize: 32,
      iconGap: 12,
      outlineWidth: 2,
    ),
    MorphButtonSize.xl: const MorphButtonMeasurements(
      height: 136,
      hPadding: 64,
      iconSize: 40,
      iconGap: 16,
      outlineWidth: 2,
    ),
  };

  /// container.

  Color container(MorphColorScheme scheme, MorphButtonStyle style) {
    switch (style) {
      case MorphButtonStyle.filled:
        return scheme.primary;
      case MorphButtonStyle.tonal:
        return scheme.secondaryContainer;
      case MorphButtonStyle.elevated:
        return scheme.surfaceContainerLow;
      case MorphButtonStyle.outlined:
      case MorphButtonStyle.text:
        return Colors.transparent;
    }
  }

  /// foreground.

  Color foreground(MorphColorScheme scheme, MorphButtonStyle style) {
    switch (style) {
      case MorphButtonStyle.filled:
        return scheme.onPrimary;
      case MorphButtonStyle.tonal:
        return scheme.onSecondaryContainer;
      case MorphButtonStyle.elevated:
      case MorphButtonStyle.text:
        return scheme.primary;
      case MorphButtonStyle.outlined:
        return scheme.onSurfaceVariant;
    }
  }

  /// outline.

  Color outline(MorphColorScheme scheme) => scheme.outline;

  /// focusRingColor.
  ///
  /// Prefer [MorphThemeData.focusRingTheme] for a package-wide override.
  Color focusRingColor(MorphColorScheme scheme) => scheme.primary;

  /// elevation.
  ///
  /// Matches Material 3 elevated / filled / tonal button elevation tokens
  /// (`material_ui` defaults): elevated stays at level 1 while pressed.
  double elevation(MorphButtonStyle style, Set<WidgetState> states) {
    final hovered = states.contains(WidgetState.hovered);
    final pressed = states.contains(WidgetState.pressed);
    final disabled = states.contains(WidgetState.disabled);
    if (disabled) {
      return 0;
    }
    switch (style) {
      case MorphButtonStyle.elevated:
        return _elevatedElevation(pressed: pressed, hovered: hovered);
      case MorphButtonStyle.filled:
      case MorphButtonStyle.tonal:
        if (pressed) {
          return 0;
        }
        if (hovered) {
          return 1;
        }
        return 0;
      case MorphButtonStyle.outlined:
      case MorphButtonStyle.text:
        return 0;
    }
  }

  double _elevatedElevation({required bool pressed, required bool hovered}) {
    if (pressed) {
      return 1;
    }
    if (hovered) {
      return 3;
    }
    return 1;
  }

  /// squareRadius.

  double squareRadius(MorphButtonSize size) =>
      _lookupByName(_squareRadiusTable, size) ?? 12;

  /// pressedRadius.

  double pressedRadius(MorphButtonSize size) =>
      _lookupByName(_pressedRadiusTable, size) ?? 12;

  /// Intermediate hover corner radius (legacy table).
  ///
  /// `MorphButton` does not morph on hover by default; set
  /// `MorphButtonDecoration.hoveredRadius` to opt in. Toggle still reads this.
  double hoveredRadius(MorphButtonSize size) =>
      _lookupByName(_hoveredRadiusTable, size) ?? 16;

  /// equalizedMinWidth.

  double equalizedMinWidth(MorphButtonSize size) =>
      _lookupByName(_equalizedMinWidthTable, size) ?? 72;

  static double? _lookupByName(
    Map<MorphButtonSize, double> table,
    MorphButtonSize size,
  ) {
    for (final entry in table.entries) {
      if (entry.key.name == size.name) {
        return entry.value;
      }
    }
    return null;
  }

  /// measurements.

  MorphButtonMeasurements measurements(
    MorphButtonSize size, {
    MorphButtonSize? override,
  }) {
    final base = _tokenMeasurements(size);
    if (override == null) {
      // Apply field overrides from [size] (custom name or copyWith height/density).
      return base.applyCustomSize(size);
    }
    final overrideBase = _tokenMeasurements(override);
    return overrideBase.applyCustomSize(override);
  }

  MorphButtonMeasurements _tokenMeasurements(MorphButtonSize size) {
    for (final variant in _measurementsTable.keys) {
      if (variant.name == size.name) {
        return _measurementsTable[variant]!;
      }
    }
    return _measurementsTable[MorphButtonSize.md]!;
  }

  @override
  MorphButtonTheme copyWith({
    double? focusRingWidth,
    double? focusRingGap,
    double? minWidthFloor,
    double? dividerHeight,
    double? connectedInnerRadius,
    double? connectedPressedInnerRadius,
    double? labelSlideDistance,
    MorphSpring? shapeSpring,
    Duration? pressDuration,
    Duration? releaseDuration,
  }) {
    return MorphButtonTheme(
      focusRingWidth: focusRingWidth ?? this.focusRingWidth,
      focusRingGap: focusRingGap ?? this.focusRingGap,
      minWidthFloor: minWidthFloor ?? this.minWidthFloor,
      dividerHeight: dividerHeight ?? this.dividerHeight,
      connectedInnerRadius: connectedInnerRadius ?? this.connectedInnerRadius,
      connectedPressedInnerRadius:
          connectedPressedInnerRadius ?? this.connectedPressedInnerRadius,
      labelSlideDistance: labelSlideDistance ?? this.labelSlideDistance,
      shapeSpring: shapeSpring ?? this.shapeSpring,
      pressDuration: pressDuration ?? this.pressDuration,
      releaseDuration: releaseDuration ?? this.releaseDuration,
    );
  }

  @override
  MorphButtonTheme lerp(MorphButtonTheme? other, double t) {
    if (other is! MorphButtonTheme) {
      return this;
    }
    return MorphButtonTheme(
      focusRingWidth: _lerpDouble(focusRingWidth, other.focusRingWidth, t)!,
      focusRingGap: _lerpDouble(focusRingGap, other.focusRingGap, t)!,
      minWidthFloor: _lerpDouble(minWidthFloor, other.minWidthFloor, t)!,
      dividerHeight: _lerpDouble(dividerHeight, other.dividerHeight, t)!,
      connectedInnerRadius: _lerpDouble(
        connectedInnerRadius,
        other.connectedInnerRadius,
        t,
      )!,
      connectedPressedInnerRadius: _lerpDouble(
        connectedPressedInnerRadius,
        other.connectedPressedInnerRadius,
        t,
      )!,
      labelSlideDistance: _lerpDouble(
        labelSlideDistance,
        other.labelSlideDistance,
        t,
      )!,
      shapeSpring: t < 0.5 ? shapeSpring : other.shapeSpring,
      pressDuration: Duration(
        microseconds: _lerpDouble(
          pressDuration.inMicroseconds.toDouble(),
          other.pressDuration.inMicroseconds.toDouble(),
          t.clamp(0.0, 1.0),
        )!.round(),
      ),
      releaseDuration: Duration(
        microseconds: _lerpDouble(
          releaseDuration.inMicroseconds.toDouble(),
          other.releaseDuration.inMicroseconds.toDouble(),
          t.clamp(0.0, 1.0),
        )!.round(),
      ),
    );
  }

  double? _lerpDouble(double a, double b, double t) => a + (b - a) * t;
}
