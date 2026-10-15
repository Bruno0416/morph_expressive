import 'package:flutter/widgets.dart';

import '../../../foundations/foundations.dart';

/// Theme values for `MorphTooltip`.
@immutable
class MorphTooltipTheme extends MorphThemeExtension<MorphTooltipTheme> {
  /// MorphTooltipTheme.
  const MorphTooltipTheme({
    this.anchorOffset = 4,
    this.plainShape = const StadiumBorder(),
    this.richShape = const StadiumBorder(),
    this.plainMaxWidth = 200,
    this.plainMinHeight = 24,
    this.plainPadding = const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    this.richMaxWidth = 320,
    this.richPadding = const EdgeInsets.fromLTRB(16, 12, 16, 8),
    this.richTitleGap = 4,
    this.richActionsGap = 12,
    this.richElevation = MorphElevation.level2,
    this.plainDismissDelay = Duration.zero,
    this.richDismissDelay = const Duration(milliseconds: 1500),
    this.placementStep = 8,
  });

  /// defaults.
  static const MorphTooltipTheme defaults = MorphTooltipTheme();

  /// Forma predeterminada de los tooltips simples.
  final ShapeBorder plainShape;

  /// Forma predeterminada de los tooltips enriquecidos.
  final ShapeBorder richShape;

  /// Gap between the target and the tooltip. Spec: 4dp (visual boundary).
  final double anchorOffset;

  /// Max width for plain tooltips.
  final double plainMaxWidth;

  /// Min height for plain tooltips. Spec: 24dp.
  final double plainMinHeight;

  /// Plain padding. Spec-aligned: horizontal 8, vertical 4 (with [plainMinHeight]).
  final EdgeInsets plainPadding;

  /// Max width for rich tooltips.
  final double richMaxWidth;

  /// Rich padding. Spec: top 12, bottom 8, left/right 16.
  final EdgeInsets richPadding;

  /// Gap between subhead and supporting text. Spec: 4dp.
  final double richTitleGap;

  /// Gap between supporting text and actions. Spec-aligned: 12dp.
  final double richActionsGap;

  /// Rich container elevation. Spec inference: Level 2.
  final double richElevation;

  /// Delay after leaving the target before hiding a plain tooltip.
  /// Default: instant ([Duration.zero]).
  final Duration plainDismissDelay;

  /// Delay after leaving the target before hiding a transient rich tooltip.
  /// Default: 1.5s so actions remain reachable.
  final Duration richDismissDelay;

  /// Step size when shifting to stay on-screen. Spec: 8dp.
  final double placementStep;

  /// Plain corner radius. Spec: Extra small (4dp).
  BorderRadius get plainBorderRadius => BorderRadius.circular(999);

  /// Rich corner radius. Spec: Medium (12dp).
  BorderRadius get richBorderRadius => MorphShapes.radiusMedium;

  /// Plain container. Spec: Inverse surface.
  Color plainContainerColor(MorphColorScheme scheme) => scheme.surfaceContainerHigh;

  /// Plain supporting text. Spec: Inverse on surface / bodySmall metrics.
  TextStyle plainMessageStyle(MorphTypeScale type, MorphColorScheme scheme) =>
      type.bodySmall.copyWith(color: scheme.onSurface);

  /// Rich container. Spec: Surface container.
  Color richContainerColor(MorphColorScheme scheme) => scheme.surfaceContainer;

  /// Rich subhead. Spec: On surface variant / titleSmall metrics.
  TextStyle richTitleStyle(MorphTypeScale type, MorphColorScheme scheme) =>
      type.titleSmall.copyWith(color: scheme.onSurfaceVariant);

  /// Rich supporting text. Spec: On surface variant / bodyMedium metrics.
  TextStyle richBodyStyle(MorphTypeScale type, MorphColorScheme scheme) =>
      type.bodyMedium.copyWith(color: scheme.onSurfaceVariant);

  @override
  MorphTooltipTheme copyWith({
    ShapeBorder? plainShape,
    ShapeBorder? richShape,
    double? anchorOffset,
    double? plainMaxWidth,
    double? plainMinHeight,
    EdgeInsets? plainPadding,
    double? richMaxWidth,
    EdgeInsets? richPadding,
    double? richTitleGap,
    double? richActionsGap,
    double? richElevation,
    Duration? plainDismissDelay,
    Duration? richDismissDelay,
    double? placementStep,
  }) {
    return MorphTooltipTheme(
      plainShape: plainShape ?? this.plainShape,
      richShape: richShape ?? this.richShape,
      anchorOffset: anchorOffset ?? this.anchorOffset,
      plainMaxWidth: plainMaxWidth ?? this.plainMaxWidth,
      plainMinHeight: plainMinHeight ?? this.plainMinHeight,
      plainPadding: plainPadding ?? this.plainPadding,
      richMaxWidth: richMaxWidth ?? this.richMaxWidth,
      richPadding: richPadding ?? this.richPadding,
      richTitleGap: richTitleGap ?? this.richTitleGap,
      richActionsGap: richActionsGap ?? this.richActionsGap,
      richElevation: richElevation ?? this.richElevation,
      plainDismissDelay: plainDismissDelay ?? this.plainDismissDelay,
      richDismissDelay: richDismissDelay ?? this.richDismissDelay,
      placementStep: placementStep ?? this.placementStep,
    );
  }

  @override
  MorphTooltipTheme lerp(MorphTooltipTheme? other, double t) {
    if (other is! MorphTooltipTheme) {
      return this;
    }
    return MorphTooltipTheme(
      plainShape: t < 0.5 ? plainShape : other.plainShape,
      richShape: t < 0.5 ? richShape : other.richShape,
      anchorOffset: _lerpDouble(anchorOffset, other.anchorOffset, t)!,
      plainMaxWidth: _lerpDouble(plainMaxWidth, other.plainMaxWidth, t)!,
      plainMinHeight: _lerpDouble(plainMinHeight, other.plainMinHeight, t)!,
      plainPadding: EdgeInsets.lerp(plainPadding, other.plainPadding, t)!,
      richMaxWidth: _lerpDouble(richMaxWidth, other.richMaxWidth, t)!,
      richPadding: EdgeInsets.lerp(richPadding, other.richPadding, t)!,
      richTitleGap: _lerpDouble(richTitleGap, other.richTitleGap, t)!,
      richActionsGap: _lerpDouble(richActionsGap, other.richActionsGap, t)!,
      richElevation: _lerpDouble(richElevation, other.richElevation, t)!,
      plainDismissDelay: t < 0.5 ? plainDismissDelay : other.plainDismissDelay,
      richDismissDelay: t < 0.5 ? richDismissDelay : other.richDismissDelay,
      placementStep: _lerpDouble(placementStep, other.placementStep, t)!,
    );
  }

  double? _lerpDouble(double a, double b, double t) => a + (b - a) * t;
}
