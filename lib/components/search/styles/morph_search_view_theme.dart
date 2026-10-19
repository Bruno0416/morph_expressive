import 'package:flutter/widgets.dart';
import 'package:morph_expressive/components/search/morph_search.dart'
    show MorphSearchAnchor;
import 'package:morph_expressive/components/search/morph_search_anchor.dart'
    show MorphSearchAnchor;
import 'package:morph_expressive/morph_components.dart' show MorphSearchAnchor;

import '../../../foundations/foundations.dart';
import '../enums/morph_search_enums.dart';

/// Theme values for [MorphSearchAnchor] search views.
///
/// Defaults follow the M3 Expressive "Search - View" token set. [style]
/// picks the contained (expressive) or divided (baseline) values.
@immutable
class MorphSearchViewTheme extends MorphThemeExtension<MorphSearchViewTheme> {
  /// MorphSearchViewTheme.
  const MorphSearchViewTheme({
    this.elevation = MorphElevation.level3,
    this.cornerRadius = 28,
    this.headerHeight = 72,
    this.minWidth = 360,
    this.minHeight = 240,
    this.barHorizontalPadding = 8,
    this.shrinkWrap = false,
    this.style = MorphSearchViewStyle.contained,
    this.maxWidth = 720,
    this.maxHeightFactor = 2 / 3,
    this.compactBreakpoint = 600,
    this.containedElevation = MorphElevation.level0,
    this.containedLeadingMargin = 12,
    this.containedTrailingMargin = 12,
    this.containedBarHeight = 56,
    this.dockedBarResultsGap = 2,
    this.dockedResultsRadius = 28,
    this.dockedResultsInset = 4,
    this.dockedResultsBottomPadding = 4,
    this.dividedDockedHeaderHeight = 56,
    this.dividedDockedListPadding = 16,
    this.fullScreenRadius = 0,
    this.scrimOpacity = 0.32,
    this.containerTransformSpring = MorphMotion.expressiveSpatialDefault,
    this.fadeSpring = MorphMotion.effectsDefault,
    this.predictiveBackSpring = MorphMotion.expressiveSpatialDefault,
    this.predictiveBackMinScale = 0.9,
    this.predictiveBackEdgeMargin = 8,
    this.predictiveBackMaxOffsetY = 24,
    this.containedFullScreenBarVerticalPadding = 8,
    this.containedFullScreenResultsInset = 12,
    this.dividedResultsInset = 16,
  });

  /// defaults.

  static const MorphSearchViewTheme defaults = MorphSearchViewTheme();

  /// Divided docked container elevation (level 3).
  final double elevation;

  /// Docked container radius in the divided style (28).
  final double cornerRadius;

  /// Divided full-screen header height (72).
  final double headerHeight;

  /// Docked min width (360).
  final double minWidth;

  /// Docked min height (240).
  final double minHeight;

  /// Legacy: no longer applied. The header bar uses the search bar spacing.
  final double barHorizontalPadding;

  /// Whether the docked view hugs its results.
  final bool shrinkWrap;

  /// Default style when the anchor does not set one (contained).
  final MorphSearchViewStyle style;

  /// Docked max width (720).
  final double maxWidth;

  /// Docked max height as a fraction of the screen height (2/3).
  final double maxHeightFactor;

  /// Window width below which the view is full-screen (600).
  final double compactBreakpoint;

  /// Contained view elevation (level 0).
  final double containedElevation;

  /// Contained bar leading margin when focused (12).
  final double containedLeadingMargin;

  /// Contained bar trailing margin when focused (12).
  final double containedTrailingMargin;

  /// Contained bar container height (56).
  final double containedBarHeight;

  /// Contained docked gap between the bar and results (2).
  final double dockedBarResultsGap;

  /// Contained docked results container radius (28).
  final double dockedResultsRadius;

  /// Contained docked results side inset (4).
  final double dockedResultsInset;

  /// Contained docked results bottom padding (4).
  final double dockedResultsBottomPadding;

  /// Divided docked header height (56).
  final double dividedDockedHeaderHeight;

  /// Divided docked list top / bottom padding (16).
  final double dividedDockedListPadding;

  /// Full-screen container radius (0).
  final double fullScreenRadius;

  /// Docked scrim opacity on [MorphColorScheme.scrim] (0.32).
  final double scrimOpacity;

  /// Spring for the bar → view container transform.
  final MorphSpring containerTransformSpring;

  /// Spring for results / divider fades.
  final MorphSpring fadeSpring;

  /// Spring that settles the view after a predictive back gesture.
  final MorphSpring predictiveBackSpring;

  /// Smallest scale while a predictive back gesture runs (0.9).
  final double predictiveBackMinScale;

  /// Gap kept from the screen edge while detaching (8).
  final double predictiveBackEdgeMargin;

  /// Max vertical follow of the back gesture (24).
  final double predictiveBackMaxOffsetY;

  /// Contained full-screen space above and below the bar (8), giving a 72
  /// header like the divided style.
  final double containedFullScreenBarVerticalPadding;

  /// Contained full-screen results side inset (12), aligned with the bar.
  final double containedFullScreenResultsInset;

  /// Divided results side inset (16), aligned with the header's 16 space.
  final double dividedResultsInset;

  /// Docked container color: surface container high.

  Color backgroundColor(MorphColorScheme scheme) => scheme.surfaceContainerHigh;

  /// Divided full-screen container color: surface container high.

  Color fullScreenBackgroundColor(MorphColorScheme scheme) =>
      scheme.surfaceContainerHigh;

  /// Contained full-screen background: surface container low.

  Color containedBackgroundColor(MorphColorScheme scheme) =>
      scheme.surfaceContainerLow;

  /// Contained bar and docked results color: surface container high.

  Color containedContainerColor(MorphColorScheme scheme) =>
      scheme.surfaceContainerHigh;

  /// Container surface tint layer color: primary.

  Color surfaceTintColor(MorphColorScheme scheme) => scheme.primary;

  /// Docked scrim color.

  Color scrimColor(MorphColorScheme scheme) =>
      scheme.scrim.withValues(alpha: scrimOpacity);

  /// Legacy full-screen header padding. No longer applied.

  EdgeInsetsGeometry fullScreenHeaderPadding() =>
      const EdgeInsets.symmetric(horizontal: 16, vertical: 8);

  /// Divider color: outline.

  Color dividerColor(MorphColorScheme scheme) => scheme.outline;

  /// Header input text: body large, on surface.

  TextStyle headerTextStyle(MorphTypeScale type, MorphColorScheme scheme) =>
      type.bodyLarge.copyWith(color: scheme.onSurface);

  /// Header supporting text: body large, on surface variant.

  TextStyle headerHintStyle(MorphTypeScale type, MorphColorScheme scheme) =>
      type.bodyLarge.copyWith(color: scheme.onSurfaceVariant);

  /// Rounded docked container shape.

  ShapeBorder dockedShape(double radius) =>
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius));

  /// Full-screen container shape.

  ShapeBorder fullScreenShape() => RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(fullScreenRadius),
  );

  /// Docked size constraints.

  BoxConstraints constraints({double? maxWidth, double? maxHeight}) {
    return BoxConstraints(
      minWidth: minWidth,
      maxWidth: maxWidth ?? this.maxWidth,
      minHeight: minHeight,
      maxHeight: maxHeight ?? double.infinity,
    );
  }

  /// Legacy header bar padding. No longer applied by default.

  EdgeInsetsGeometry barPadding() =>
      EdgeInsets.symmetric(horizontal: barHorizontalPadding);

  @override
  MorphSearchViewTheme copyWith({
    double? elevation,
    double? cornerRadius,
    double? headerHeight,
    double? minWidth,
    double? minHeight,
    double? barHorizontalPadding,
    bool? shrinkWrap,
    MorphSearchViewStyle? style,
    double? maxWidth,
    double? maxHeightFactor,
    double? compactBreakpoint,
    double? containedElevation,
    double? containedLeadingMargin,
    double? containedTrailingMargin,
    double? containedBarHeight,
    double? dockedBarResultsGap,
    double? dockedResultsRadius,
    double? dockedResultsInset,
    double? dockedResultsBottomPadding,
    double? dividedDockedHeaderHeight,
    double? dividedDockedListPadding,
    double? fullScreenRadius,
    double? scrimOpacity,
    MorphSpring? containerTransformSpring,
    MorphSpring? fadeSpring,
    MorphSpring? predictiveBackSpring,
    double? predictiveBackMinScale,
    double? predictiveBackEdgeMargin,
    double? predictiveBackMaxOffsetY,
    double? containedFullScreenBarVerticalPadding,
    double? containedFullScreenResultsInset,
    double? dividedResultsInset,
  }) {
    return MorphSearchViewTheme(
      elevation: elevation ?? this.elevation,
      cornerRadius: cornerRadius ?? this.cornerRadius,
      headerHeight: headerHeight ?? this.headerHeight,
      minWidth: minWidth ?? this.minWidth,
      minHeight: minHeight ?? this.minHeight,
      barHorizontalPadding: barHorizontalPadding ?? this.barHorizontalPadding,
      shrinkWrap: shrinkWrap ?? this.shrinkWrap,
      style: style ?? this.style,
      maxWidth: maxWidth ?? this.maxWidth,
      maxHeightFactor: maxHeightFactor ?? this.maxHeightFactor,
      compactBreakpoint: compactBreakpoint ?? this.compactBreakpoint,
      containedElevation: containedElevation ?? this.containedElevation,
      containedLeadingMargin:
          containedLeadingMargin ?? this.containedLeadingMargin,
      containedTrailingMargin:
          containedTrailingMargin ?? this.containedTrailingMargin,
      containedBarHeight: containedBarHeight ?? this.containedBarHeight,
      dockedBarResultsGap: dockedBarResultsGap ?? this.dockedBarResultsGap,
      dockedResultsRadius: dockedResultsRadius ?? this.dockedResultsRadius,
      dockedResultsInset: dockedResultsInset ?? this.dockedResultsInset,
      dockedResultsBottomPadding:
          dockedResultsBottomPadding ?? this.dockedResultsBottomPadding,
      dividedDockedHeaderHeight:
          dividedDockedHeaderHeight ?? this.dividedDockedHeaderHeight,
      dividedDockedListPadding:
          dividedDockedListPadding ?? this.dividedDockedListPadding,
      fullScreenRadius: fullScreenRadius ?? this.fullScreenRadius,
      scrimOpacity: scrimOpacity ?? this.scrimOpacity,
      containerTransformSpring:
          containerTransformSpring ?? this.containerTransformSpring,
      fadeSpring: fadeSpring ?? this.fadeSpring,
      predictiveBackSpring: predictiveBackSpring ?? this.predictiveBackSpring,
      predictiveBackMinScale:
          predictiveBackMinScale ?? this.predictiveBackMinScale,
      predictiveBackEdgeMargin:
          predictiveBackEdgeMargin ?? this.predictiveBackEdgeMargin,
      predictiveBackMaxOffsetY:
          predictiveBackMaxOffsetY ?? this.predictiveBackMaxOffsetY,
      containedFullScreenBarVerticalPadding:
          containedFullScreenBarVerticalPadding ??
          this.containedFullScreenBarVerticalPadding,
      containedFullScreenResultsInset:
          containedFullScreenResultsInset ??
          this.containedFullScreenResultsInset,
      dividedResultsInset: dividedResultsInset ?? this.dividedResultsInset,
    );
  }

  @override
  MorphSearchViewTheme lerp(MorphSearchViewTheme? other, double t) {
    if (other is! MorphSearchViewTheme) {
      return this;
    }
    final MorphSearchViewTheme b = t < 0.5 ? this : other;
    double l(double Function(MorphSearchViewTheme x) f) =>
        _lerp(f(this), f(other), t);
    return MorphSearchViewTheme(
      elevation: l((MorphSearchViewTheme x) => x.elevation),
      cornerRadius: l((MorphSearchViewTheme x) => x.cornerRadius),
      headerHeight: l((MorphSearchViewTheme x) => x.headerHeight),
      minWidth: l((MorphSearchViewTheme x) => x.minWidth),
      minHeight: l((MorphSearchViewTheme x) => x.minHeight),
      barHorizontalPadding: l(
        (MorphSearchViewTheme x) => x.barHorizontalPadding,
      ),
      maxWidth: l((MorphSearchViewTheme x) => x.maxWidth),
      maxHeightFactor: l((MorphSearchViewTheme x) => x.maxHeightFactor),
      compactBreakpoint: l((MorphSearchViewTheme x) => x.compactBreakpoint),
      containedElevation: l((MorphSearchViewTheme x) => x.containedElevation),
      containedLeadingMargin: l(
        (MorphSearchViewTheme x) => x.containedLeadingMargin,
      ),
      containedTrailingMargin: l(
        (MorphSearchViewTheme x) => x.containedTrailingMargin,
      ),
      containedBarHeight: l((MorphSearchViewTheme x) => x.containedBarHeight),
      dockedBarResultsGap: l((MorphSearchViewTheme x) => x.dockedBarResultsGap),
      dockedResultsRadius: l((MorphSearchViewTheme x) => x.dockedResultsRadius),
      dockedResultsInset: l((MorphSearchViewTheme x) => x.dockedResultsInset),
      dockedResultsBottomPadding: l(
        (MorphSearchViewTheme x) => x.dockedResultsBottomPadding,
      ),
      dividedDockedHeaderHeight: l(
        (MorphSearchViewTheme x) => x.dividedDockedHeaderHeight,
      ),
      dividedDockedListPadding: l(
        (MorphSearchViewTheme x) => x.dividedDockedListPadding,
      ),
      fullScreenRadius: l((MorphSearchViewTheme x) => x.fullScreenRadius),
      scrimOpacity: l((MorphSearchViewTheme x) => x.scrimOpacity),
      predictiveBackMinScale: l(
        (MorphSearchViewTheme x) => x.predictiveBackMinScale,
      ),
      predictiveBackEdgeMargin: l(
        (MorphSearchViewTheme x) => x.predictiveBackEdgeMargin,
      ),
      predictiveBackMaxOffsetY: l(
        (MorphSearchViewTheme x) => x.predictiveBackMaxOffsetY,
      ),
      containedFullScreenBarVerticalPadding: l(
        (MorphSearchViewTheme x) => x.containedFullScreenBarVerticalPadding,
      ),
      containedFullScreenResultsInset: l(
        (MorphSearchViewTheme x) => x.containedFullScreenResultsInset,
      ),
      dividedResultsInset: l((MorphSearchViewTheme x) => x.dividedResultsInset),
      shrinkWrap: b.shrinkWrap,
      style: b.style,
      containerTransformSpring: b.containerTransformSpring,
      fadeSpring: b.fadeSpring,
      predictiveBackSpring: b.predictiveBackSpring,
    );
  }

  double _lerp(double a, double b, double t) => a + (b - a) * t;
}
