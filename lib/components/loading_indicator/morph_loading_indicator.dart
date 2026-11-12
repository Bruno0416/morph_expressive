import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../../foundations/foundations.dart';
import 'components/morph_expressive_loading_indicator.dart';
import 'enums/morph_loading_indicator_variant.dart';
import 'styles/morph_loading_indicator_theme.dart';

export 'components/morph_expressive_loading_indicator.dart';
export 'enums/morph_loading_indicator_variant.dart';
export 'styles/morph_loading_indicator_theme.dart';

/// Material 3 Expressive loading indicator.
///
/// Port of the reference `LoadingIndicatorMorph`:
///  * [MorphLoadingIndicatorVariant.defaultStyle] draws a floating morphing shape
///    on the surface.
///  * [MorphLoadingIndicatorVariant.contained] draws the shape inside a filled
///    container, using the on-container color for the shape.
///
/// Spec defaults: outer **48dp**, active **38dp**, container [CircleBorder],
/// responsive outer range **24–240dp**. Use [size] to scale both edges while
/// preserving the 38:48 ratio.
///
/// Colors:
///  * [color] — morphing shape (inner) color for both variants.
///  * [containerColor] — filled shell behind a contained indicator.
///  * [indicatorColors] — optional multi-color morph (cannot combine with
///    [color]).
class MorphLoadingIndicator extends StatelessWidget {
  /// MorphLoadingIndicator.
  const MorphLoadingIndicator({
    super.key,
    this.variant = MorphLoadingIndicatorVariant.defaultStyle,
    this.color,
    this.containerColor,
    this.indicatorColors,
    this.size,
    this.indicatorSize,
    this.containedInset,
    this.containerWidth,
    this.containerHeight,
    this.containerShape,
    this.polygons,
    this.shapes,
    this.renderer = MorphShapeRenderer.canvas,
    this.constraints,
    this.padding,
    this.globalRotationDuration,
    this.morphInterval,
    this.morphRotationDegrees,
    this.morphSpring,
    this.morphSpringVelocity,
    this.pulseStartScale,
    this.pulseSpring,
    this.pulseSpringVelocity,
    this.rotationTurns,
    this.semanticLabel,
    this.semanticValue,
  }) : assert(
         shapes == null || polygons == null,
         'shapes and polygons are exclusive',
       ),
       assert(
         color == null || indicatorColors == null,
         'color and indicatorColors cannot both be set',
       ),
       assert(size == null || size > 0, 'size must be greater than zero'),
       assert(
         indicatorSize == null || indicatorSize > 0,
         'indicatorSize must be greater than zero',
       ),
       assert(
         containerWidth == null || containerWidth > 0,
         'containerWidth must be greater than zero',
       ),
       assert(
         containerHeight == null || containerHeight > 0,
         'containerHeight must be greater than zero',
       ),
       assert(
         size == null ||
             (indicatorSize == null &&
                 containerWidth == null &&
                 containerHeight == null &&
                 constraints == null),
         'size cannot be combined with indicatorSize, containerWidth, '
         'containerHeight, or constraints',
       ),
       assert(
         constraints == null ||
             (containerWidth == null && containerHeight == null),
         'constraints cannot be combined with containerWidth or containerHeight',
       );

  /// variant.
  final MorphLoadingIndicatorVariant variant;

  /// Morphing shape (inner) color.
  final Color? color;

  /// Contained shell color behind the shape. Ignored for the default variant
  /// when left null (transparent).
  final Color? containerColor;

  /// Indicator colors, cycled and interpolated during morphing.
  ///
  /// Cannot be combined with [color].
  final List<Color>? indicatorColors;

  /// Outer edge length (dp). Scales container and active sizes with the
  /// 38:48 spec ratio. Spec guidance: 24–240.
  ///
  /// Cannot be combined with [indicatorSize], [containerWidth],
  /// [containerHeight], or [constraints].
  final double? size;

  /// Size of the morphing indicator. Defaults to theme (38).
  final double? indicatorSize;

  /// Contained variant only: minimum clear distance (dp, absolute) between the
  /// morph envelope and the container edge. Overrides the theme token
  /// (default 5 dp). The envelope is the farthest point of every shape in the
  /// sequence, at the largest pulse, rotated about the center; the active size
  /// is scaled down uniformly (never per frame) when it would not fit
  /// `min(width, height) / 2 − inset`. Must be `>= 0` and leave a positive
  /// radius. Ignored by the default variant.
  final double? containedInset;

  /// Width of the container. Defaults to theme (48).
  final double? containerWidth;

  /// Height of the container. Defaults to theme (48).
  final double? containerHeight;

  /// Shape of the container. Defaults to theme ([CircleBorder]).
  final ShapeBorder? containerShape;

  /// polygons.
  final List<RoundedPolygon>? polygons;

  /// Own-engine shapes (at least two), mutually exclusive with [polygons].
  final List<MorphShape>? shapes;
  final MorphShapeRenderer renderer;

  /// constraints.
  final BoxConstraints? constraints;

  /// padding.
  final EdgeInsetsGeometry? padding;

  /// Full 360° continuous spin period.
  final Duration? globalRotationDuration;

  /// Delay between polygon morph cycles.
  final Duration? morphInterval;

  /// Extra rotation (degrees) across each morph transition.
  final double? morphRotationDegrees;

  /// Spring for morph progress.
  final MorphSpring? morphSpring;

  /// Initial morph spring velocity.
  final double? morphSpringVelocity;

  /// Scale at the start of each morph-in pulse (default expands above 1, then settles).
  final double? pulseStartScale;

  /// Spring for the morph-in scale pulse settle.
  final MorphSpring? pulseSpring;

  /// Initial pulse spring velocity.
  final double? pulseSpringVelocity;

  /// When non-null, disables auto spin and pulse; rotation is driven by this
  /// value in turns (`1.0` = 360°).
  final double? rotationTurns;

  /// semanticLabel.
  final String? semanticLabel;

  /// semanticValue.
  final String? semanticValue;

  @override
  Widget build(BuildContext context) {
    _rejectEmptyIndicatorColors();
    final theme = MorphTheme.of(context);
    final scheme = theme.colorScheme;
    final loadingTheme = theme.loadingIndicatorTheme;
    final resolved = _resolvedSizes(loadingTheme);
    _rejectOuterSize(resolved.width, resolved.height);
    return _buildIndicator(theme, scheme, loadingTheme, resolved);
  }

  void _rejectEmptyIndicatorColors() {
    assert(() {
      if (indicatorColors != null && indicatorColors!.isEmpty) {
        throw AssertionError('indicatorColors cannot be empty');
      }
      return true;
    }(), 'indicatorColors cannot be empty');
    if (indicatorColors != null && indicatorColors!.isEmpty) {
      throw ArgumentError.value(
        indicatorColors,
        'indicatorColors',
        'must not be empty',
      );
    }
  }

  ({double width, double height, double active}) _resolvedSizes(
    MorphLoadingIndicatorTheme loadingTheme,
  ) {
    final double? scaledOuter = size;
    final double resolvedWidth =
        scaledOuter ?? containerWidth ?? loadingTheme.containerWidth;
    final double resolvedHeight =
        scaledOuter ?? containerHeight ?? loadingTheme.containerHeight;
    final double resolvedActive = scaledOuter != null
        ? MorphLoadingIndicatorTheme.resolveActiveSize(scaledOuter)
        : (indicatorSize ?? loadingTheme.activeIndicatorSize);
    return (
      width: resolvedWidth,
      height: resolvedHeight,
      active: resolvedActive,
    );
  }

  void _rejectOuterSize(double resolvedWidth, double resolvedHeight) {
    assert(() {
      final double outer = math.max(resolvedWidth, resolvedHeight);
      if (outer < MorphLoadingIndicatorTheme.minSize ||
          outer > MorphLoadingIndicatorTheme.maxSize) {
        throw FlutterError(
          'MorphLoadingIndicator outer size $outer is outside the spec range '
          '${MorphLoadingIndicatorTheme.minSize}–${MorphLoadingIndicatorTheme.maxSize}.',
        );
      }
      return true;
    }(), 'outer size must be within 24–240');
  }

  Widget _buildIndicator(
    MorphThemeData theme,
    MorphColorScheme scheme,
    MorphLoadingIndicatorTheme loadingTheme,
    ({double width, double height, double active}) resolved,
  ) {
    final inset = variant == MorphLoadingIndicatorVariant.contained
        ? containedInset ?? loadingTheme.containedInset
        : null;
    if (inset != null) {
      final half = math.min(resolved.width, resolved.height) / 2;
      if (!inset.isFinite || inset < 0 || inset >= half) {
        throw ArgumentError.value(
          inset,
          'containedInset',
          'must be finite, >= 0 and smaller than half of the container ($half)',
        );
      }
    }
    final cons =
        constraints ??
        BoxConstraints.tightFor(width: resolved.width, height: resolved.height);
    final colors =
        indicatorColors ??
        <Color>[color ?? loadingTheme.resolveActiveColor(scheme, variant)];
    final containerBg =
        containerColor ?? loadingTheme.resolveContainerColor(scheme, variant);
    final indicator = MorphExpressiveLoadingIndicator(
      color: colors.first,
      indicatorColors: colors,
      indicatorSize: resolved.active,
      radialBudget: inset == null
          ? null
          : math.min(resolved.width, resolved.height) / 2 - inset,
      polygons: polygons,
      shapes: shapes,
      renderer: renderer,
      semanticsLabel: semanticLabel,
      semanticsValue: semanticValue,
      constraints: cons,
      globalRotationDuration: globalRotationDuration,
      morphInterval: morphInterval,
      morphRotationDegrees: morphRotationDegrees,
      morphSpring: morphSpring,
      morphSpringVelocity: morphSpringVelocity,
      pulseStartScale: pulseStartScale,
      pulseSpring: pulseSpring,
      pulseSpringVelocity: pulseSpringVelocity,
      rotationTurns: rotationTurns,
    );

    return MorphComponentTheme(
      builder: (context) => DecoratedBox(
        decoration: ShapeDecoration(
          color: containerBg,
          shape: containerShape ?? loadingTheme.containerShape,
        ),
        child: Padding(padding: padding ?? EdgeInsets.zero, child: indicator),
      ),
    );
  }
}
