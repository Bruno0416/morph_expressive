import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:material_ui/material_ui.dart'
    show Curve, Gradient, Size, immutable;

import '../../../foundations/foundations.dart';
import '../enums/morph_icon_button_enums.dart';

/// Theme values for `MorphIconButton`.
@immutable
class MorphIconButtonTheme extends MorphThemeExtension<MorphIconButtonTheme> {
  /// MorphIconButtonTheme.
  const MorphIconButtonTheme({
    this.outlineWidth,
    this.morphDuration = const Duration(milliseconds: 120),
    this.morphCurve = MorphMotion.enter,
    this.filledBackgroundGradient,
    this.tonalBackgroundGradient,
    this.morphSpring = MorphMotion.spatialFast,
  });

  /// defaults.

  static const MorphIconButtonTheme defaults = MorphIconButtonTheme();

  /// Disabled container opacity (spec 0.1).
  static const double disabledContainerAlpha = 0.1;

  /// Disabled icon opacity (spec 0.38).
  static const double disabledForegroundAlpha = 0.38;

  /// Optional flat outline width override for all sizes.
  ///
  /// When null, [outlineWidthFor] uses per-size tokens (1 / 1 / 1 / 2 / 3).
  final double? outlineWidth;

  /// morphDuration.
  final Duration morphDuration;

  /// morphCurve.
  final Curve morphCurve;

  /// Optional gradient for filled icon buttons.
  final Gradient? filledBackgroundGradient;

  /// Optional gradient for tonal icon buttons.
  final Gradient? tonalBackgroundGradient;

  /// Shape morph spring (stiffness 1400 / damping 0.9).
  final MorphSpring morphSpring;

  static const Map<MorphIconButtonSize, double> _icon = {
    MorphIconButtonSize.xs: 20,
    MorphIconButtonSize.sm: 24,
    MorphIconButtonSize.md: 24,
    MorphIconButtonSize.lg: 32,
    MorphIconButtonSize.xl: 40,
  };

  static const Map<MorphIconButtonSize, Map<MorphIconButtonWidth, Size>>
  _visual = {
    MorphIconButtonSize.xs: {
      MorphIconButtonWidth.defaultWidth: Size(32, 32),
      MorphIconButtonWidth.narrow: Size(28, 32),
      MorphIconButtonWidth.wide: Size(40, 32),
    },
    MorphIconButtonSize.sm: {
      MorphIconButtonWidth.defaultWidth: Size(40, 40),
      MorphIconButtonWidth.narrow: Size(32, 40),
      MorphIconButtonWidth.wide: Size(52, 40),
    },
    MorphIconButtonSize.md: {
      MorphIconButtonWidth.defaultWidth: Size(56, 56),
      MorphIconButtonWidth.narrow: Size(48, 56),
      MorphIconButtonWidth.wide: Size(72, 56),
    },
    MorphIconButtonSize.lg: {
      MorphIconButtonWidth.defaultWidth: Size(96, 96),
      MorphIconButtonWidth.narrow: Size(64, 96),
      MorphIconButtonWidth.wide: Size(128, 96),
    },
    MorphIconButtonSize.xl: {
      MorphIconButtonWidth.defaultWidth: Size(136, 136),
      MorphIconButtonWidth.narrow: Size(104, 136),
      MorphIconButtonWidth.wide: Size(184, 136),
    },
  };

  static const Map<MorphIconButtonSize, Map<MorphIconButtonWidth, Size>>
  _target = {
    MorphIconButtonSize.xs: {
      MorphIconButtonWidth.defaultWidth: Size(48, 48),
      MorphIconButtonWidth.narrow: Size(48, 48),
      MorphIconButtonWidth.wide: Size(48, 48),
    },
    MorphIconButtonSize.sm: {
      MorphIconButtonWidth.defaultWidth: Size(48, 48),
      MorphIconButtonWidth.narrow: Size(48, 48),
      MorphIconButtonWidth.wide: Size(52, 48),
    },
    MorphIconButtonSize.md: {
      MorphIconButtonWidth.defaultWidth: Size(56, 56),
      MorphIconButtonWidth.narrow: Size(48, 56),
      MorphIconButtonWidth.wide: Size(72, 56),
    },
    MorphIconButtonSize.lg: {
      MorphIconButtonWidth.defaultWidth: Size(96, 96),
      MorphIconButtonWidth.narrow: Size(64, 96),
      MorphIconButtonWidth.wide: Size(128, 96),
    },
    MorphIconButtonSize.xl: {
      MorphIconButtonWidth.defaultWidth: Size(136, 136),
      MorphIconButtonWidth.narrow: Size(104, 136),
      MorphIconButtonWidth.wide: Size(184, 136),
    },
  };

  static const Map<MorphIconButtonSize, double> _radiusRestRound = {
    MorphIconButtonSize.xs: 16,
    MorphIconButtonSize.sm: 20,
    MorphIconButtonSize.md: 28,
    MorphIconButtonSize.lg: 48,
    MorphIconButtonSize.xl: 68,
  };

  static const Map<MorphIconButtonSize, double> _radiusRestSquare = {
    MorphIconButtonSize.xs: 12,
    MorphIconButtonSize.sm: 12,
    MorphIconButtonSize.md: 16,
    MorphIconButtonSize.lg: 28,
    MorphIconButtonSize.xl: 28,
  };

  static const Map<MorphIconButtonSize, double> _radiusPressed = {
    MorphIconButtonSize.xs: 8,
    MorphIconButtonSize.sm: 8,
    MorphIconButtonSize.md: 12,
    MorphIconButtonSize.lg: 16,
    MorphIconButtonSize.xl: 16,
  };

  static const Map<MorphIconButtonSize, double> _outlineWidth = {
    MorphIconButtonSize.xs: 1,
    MorphIconButtonSize.sm: 1,
    MorphIconButtonSize.md: 1,
    MorphIconButtonSize.lg: 2,
    MorphIconButtonSize.xl: 3,
  };

  /// Size step of [size] for density tables (xs = 0 ... xl = 4).
  static int sizeStep(MorphIconButtonSize size) => switch (size) {
    MorphIconButtonSize.xs => 0,
    MorphIconButtonSize.sm => 1,
    MorphIconButtonSize.md => 2,
    MorphIconButtonSize.lg => 3,
    MorphIconButtonSize.xl => 4,
  };

  /// Icon glyph size for [size], adjusted once by [density].
  double iconSize(
    MorphIconButtonSize size, {
    MorphDensity density = MorphDensity.standard,
  }) => MorphDensityMetrics.adjust(
    _icon[size]!,
    density.metrics.iconSize,
    min: 16,
  );

  /// Visual (painted) size for [size] and [width], adjusted once by
  /// [density]. Both axes move by the size-step control height delta so the
  /// button stays square (or keeps its width offset).
  Size visual(
    MorphIconButtonSize size,
    MorphIconButtonWidth width, {
    MorphDensity density = MorphDensity.standard,
  }) {
    final Size base = _visual[size]![width]!;
    if (density == MorphDensity.standard) {
      return base;
    }
    final double delta = density.metrics.controlHeightFor(sizeStep(size));
    return Size(
      MorphDensityMetrics.adjust(base.width, delta, min: 24),
      MorphDensityMetrics.adjust(base.height, delta, min: 24),
    );
  }

  /// Interactive target size for [size] and [width].
  ///
  /// Density shrinks the painted button, never the accessible target: the
  /// target keeps the standard 48dp floor (or the standard target when it is
  /// larger than the visual) and grows with a comfortable visual.
  Size target(
    MorphIconButtonSize size,
    MorphIconButtonWidth width, {
    MorphDensity density = MorphDensity.standard,
  }) {
    final Size base = _target[size]![width]!;
    if (density == MorphDensity.standard) {
      return base;
    }
    final Size standardVisual = _visual[size]![width]!;
    final Size visual = this.visual(size, width, density: density);
    double axis(double target, double standard, double dense) {
      final double floor = target > standard ? target : math.min(target, 48.0);
      return math.max(floor, dense);
    }

    return Size(
      axis(base.width, standardVisual.width, visual.width),
      axis(base.height, standardVisual.height, visual.height),
    );
  }

  /// radiusRestRound.

  double radiusRestRound(MorphIconButtonSize size) => _radiusRestRound[size]!;

  /// radiusRestSquare.

  double radiusRestSquare(MorphIconButtonSize size) => _radiusRestSquare[size]!;

  /// radiusPressed.

  double radiusPressed(MorphIconButtonSize size) => _radiusPressed[size]!;

  /// Hover keeps the resting shape; returns resting round for API compatibility.
  double radiusHovered(MorphIconButtonSize size) => radiusRestRound(size);

  /// Outline stroke width for [size] (or [outlineWidth] when set).
  double outlineWidthFor(MorphIconButtonSize size) =>
      outlineWidth ?? _outlineWidth[size]!;

  @override
  MorphIconButtonTheme copyWith({
    double? outlineWidth,
    bool clearOutlineWidth = false,
    Duration? morphDuration,
    Curve? morphCurve,
    Gradient? filledBackgroundGradient,
    Gradient? tonalBackgroundGradient,
    MorphSpring? morphSpring,
  }) {
    return MorphIconButtonTheme(
      outlineWidth: clearOutlineWidth
          ? null
          : (outlineWidth ?? this.outlineWidth),
      morphDuration: morphDuration ?? this.morphDuration,
      morphCurve: morphCurve ?? this.morphCurve,
      filledBackgroundGradient:
          filledBackgroundGradient ?? this.filledBackgroundGradient,
      tonalBackgroundGradient:
          tonalBackgroundGradient ?? this.tonalBackgroundGradient,
      morphSpring: morphSpring ?? this.morphSpring,
    );
  }

  @override
  MorphIconButtonTheme lerp(MorphIconButtonTheme? other, double t) {
    if (other is! MorphIconButtonTheme) {
      return this;
    }
    return MorphIconButtonTheme(
      outlineWidth: t < 0.5 ? outlineWidth : other.outlineWidth,
      morphDuration: Duration(
        milliseconds: _lerpDouble(
          morphDuration.inMilliseconds.toDouble(),
          other.morphDuration.inMilliseconds.toDouble(),
          t,
        )!.round(),
      ),
      morphCurve: t < 0.5 ? morphCurve : other.morphCurve,
      filledBackgroundGradient: t < 0.5
          ? filledBackgroundGradient
          : other.filledBackgroundGradient,
      tonalBackgroundGradient: t < 0.5
          ? tonalBackgroundGradient
          : other.tonalBackgroundGradient,
      morphSpring: t < 0.5 ? morphSpring : other.morphSpring,
    );
  }

  double? _lerpDouble(double a, double b, double t) => a + (b - a) * t;
}
