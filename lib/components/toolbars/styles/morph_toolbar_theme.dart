import 'package:flutter/widgets.dart';
import 'package:morph_expressive/components/toolbars/morph_toolbars.dart'
    show MorphToolbar;
import 'package:morph_expressive/morph_components.dart'
    show MorphToolbar;

import '../../../foundations/foundations.dart';
import '../../icon_buttons/enums/morph_icon_button_enums.dart';
import '../enums/morph_toolbar_enums.dart';
import '../res/morph_toolbar_tokens.dart';

/// Resolved colors for a toolbar (+ optional FAB).
@immutable
class MorphToolbarColors {
  /// MorphToolbarColors.
  const MorphToolbarColors({
    required this.container,
    required this.content,
    required this.fabContainer,
    required this.fabContent,
    this.selectedContainer,
    this.selectedContent,
    this.emphasisContainer,
    this.emphasisContent,
    this.disabledContent,
  });

  /// container.

  final Color container;

  /// Unselected icon and label.
  final Color content;

  /// fabContainer.
  final Color fabContainer;

  /// fabContent.
  final Color fabContent;

  /// Selected toggle container. Tonal, not filled.
  final Color? selectedContainer;

  /// Selected toggle icon and label.
  final Color? selectedContent;

  /// Single filled emphasis action (primary).
  final Color? emphasisContainer;

  /// Icon and label on the filled emphasis action.
  final Color? emphasisContent;

  /// Disabled icon and label (on-surface at 0.38).
  final Color? disabledContent;
}

/// Resolved layout metrics for floating / docked toolbars.
@immutable
class MorphToolbarMetrics {
  /// MorphToolbarMetrics.
  const MorphToolbarMetrics({
    required this.crossAxisSize,
    required this.contentPadding,
    required this.gap,
    required this.iconSize,
    required this.elevation,
    required this.elevationWithFab,
  });

  /// crossAxisSize.

  final double crossAxisSize;

  /// contentPadding.
  final EdgeInsetsGeometry contentPadding;

  /// gap.
  final double gap;

  /// iconSize.
  final double iconSize;

  /// elevation.
  final double elevation;

  /// elevationWithFab.
  final double elevationWithFab;
}

/// Theme values for [MorphToolbar].
@immutable
class MorphToolbarTheme extends MorphThemeExtension<MorphToolbarTheme> {
  /// MorphToolbarTheme.
  const MorphToolbarTheme({
    this.containerSize = MorphToolbarTokens.containerSize,
    this.floatingPadding = MorphToolbarTokens.floatingContentPadding,
    this.dockedHorizontalPadding = MorphToolbarTokens.dockedHorizontalPadding,
    this.actionGap = MorphToolbarTokens.containerBetweenSpace,
    this.dockedPreferredGap = MorphToolbarTokens.dockedPreferredGap,
    this.dockedMinGap = MorphToolbarTokens.containerBetweenSpace,
    this.centeredGap = MorphToolbarTokens.centeredGap,
    this.iconSize = 24,
    this.elevation = MorphToolbarTokens.elevationNone,
    this.floatingElevation = MorphToolbarTokens.floatingElevation,
    this.elevationWithFab = MorphToolbarTokens.floatingElevation,
    this.toolbarToFabGap = MorphToolbarTokens.toolbarToFabGap,
    this.screenOffset = MorphToolbarTokens.screenOffset,
    this.verticalScreenOffset = MorphToolbarTokens.verticalScreenOffset,
    this.compactBreakpoint = MorphToolbarTokens.compactBreakpoint,
    this.fabExpandedIcon = MorphToolbarTokens.fabExpandedIcon,
    this.fabCollapsedIcon = MorphToolbarTokens.fabCollapsedIcon,
    this.dockedRadius = MorphToolbarTokens.dockedRadius,
    // Legacy fields retained for copyWith / lerp compatibility.
    this.heightSmall = 40,
    this.heightMedium = 48,
    this.heightLarge = 56,
    this.compactHeightReduction = 4,
    this.elevationSurface = 0,
    this.elevationProminent = 2,
    this.expandSpring = MorphMotion.expressiveSpatialFast,
    this.labelSpring = const MorphSpring(stiffness: 800, damping: 0.4),
  });

  /// defaults.

  static const MorphToolbarTheme defaults = MorphToolbarTheme();

  /// containerSize.

  final double containerSize;

  /// floatingPadding.
  final double floatingPadding;

  /// dockedHorizontalPadding.
  final double dockedHorizontalPadding;

  /// Gap between floating actions.
  final double actionGap;

  /// Preferred docked gap. Clamped down to [dockedMinGap] when the bar is tight.
  final double dockedPreferredGap;

  /// Smallest docked gap before actions overflow.
  final double dockedMinGap;

  /// Gap when [MorphToolbarContentAlignment.centered] is active.
  final double centeredGap;

  /// iconSize.
  final double iconSize;

  /// Docked elevation.
  final double elevation;

  /// Floating elevation (level 3). Does not change when a FAB is attached.
  final double floatingElevation;

  /// Kept for theme compatibility. Resolved metrics use [floatingElevation].
  final double elevationWithFab;

  /// toolbarToFabGap.
  final double toolbarToFabGap;

  /// Horizontal floating screen margin.
  final double screenOffset;

  /// Vertical floating screen margin.
  final double verticalScreenOffset;

  /// Window width below which docked actions stay evenly spaced.
  final double compactBreakpoint;

  /// Expanded FAB icon size.
  final double fabExpandedIcon;

  /// Collapsed FAB icon size.
  final double fabCollapsedIcon;

  /// Docked corner radius. Default 0.
  final double dockedRadius;

  /// heightSmall.

  final double heightSmall;

  /// heightMedium.
  final double heightMedium;

  /// heightLarge.
  final double heightLarge;

  /// compactHeightReduction.
  final double compactHeightReduction;

  /// elevationSurface.
  final double elevationSurface;

  /// elevationProminent.
  final double elevationProminent;

  /// Floating toolbar morph / visibility expand spring.
  final MorphSpring expandSpring;

  /// Labeled action expand / collapse spring.
  final MorphSpring labelSpring;

  /// metricsFor.

  MorphToolbarMetrics metricsFor(MorphToolbarPlacement placement) {
    final EdgeInsetsGeometry padding = placement == MorphToolbarPlacement.floating
        ? EdgeInsets.all(floatingPadding)
        : EdgeInsets.fromLTRB(
            dockedHorizontalPadding,
            floatingPadding,
            dockedHorizontalPadding,
            floatingPadding,
          );
    final double barElevation = placement == MorphToolbarPlacement.floating
        ? floatingElevation
        : elevation;
    return MorphToolbarMetrics(
      crossAxisSize: containerSize,
      contentPadding: padding,
      gap: placement == MorphToolbarPlacement.floating ? actionGap : dockedMinGap,
      iconSize: iconSize,
      elevation: barElevation,
      elevationWithFab: barElevation,
    );
  }

  /// Legacy metrics API used by older call sites.
  MorphToolbarMetrics metrics(MorphToolbarDensity density, MorphSpacing spacing) {
    return metricsFor(MorphToolbarPlacement.floating).copyWithGap(spacing.sm);
  }

  /// colors.

  MorphToolbarColors colors(MorphColorScheme scheme, MorphToolbarColorStyle style) {
    switch (style) {
      case MorphToolbarColorStyle.standard:
        return MorphToolbarColors(
          container: scheme.surfaceContainer,
          content: scheme.onSurfaceVariant,
          fabContainer: scheme.secondaryContainer,
          fabContent: scheme.onSecondaryContainer,
          selectedContainer: scheme.secondaryContainer,
          selectedContent: scheme.onSecondaryContainer,
          emphasisContainer: scheme.primary,
          emphasisContent: scheme.onPrimary,
          disabledContent: scheme.onSurface.withValues(
            alpha: MorphToolbarTokens.disabledContentAlpha,
          ),
        );
      case MorphToolbarColorStyle.vibrant:
        return MorphToolbarColors(
          container: scheme.primaryContainer,
          content: scheme.onPrimaryContainer,
          fabContainer: scheme.tertiaryContainer,
          fabContent: scheme.onTertiaryContainer,
          selectedContainer: scheme.surfaceContainer,
          selectedContent: scheme.onSurface,
          emphasisContainer: scheme.primary,
          emphasisContent: scheme.onPrimary,
          disabledContent: scheme.onSurface.withValues(
            alpha: MorphToolbarTokens.disabledContentAlpha,
          ),
        );
    }
  }

  /// Maps legacy [MorphToolbarVariant] onto [MorphToolbarColorStyle].
  MorphToolbarColorStyle colorStyleFromVariant(MorphToolbarVariant variant) {
    return switch (variant) {
      MorphToolbarVariant.primary => MorphToolbarColorStyle.vibrant,
      MorphToolbarVariant.surface ||
      MorphToolbarVariant.tonal => MorphToolbarColorStyle.standard,
    };
  }

  /// containerColor.

  Color containerColor(MorphColorScheme scheme, MorphToolbarVariant variant) {
    return colors(scheme, colorStyleFromVariant(variant)).container;
  }

  /// foregroundColor.

  Color foregroundColor(MorphColorScheme scheme, MorphToolbarVariant variant) {
    return colors(scheme, colorStyleFromVariant(variant)).content;
  }

  /// floatingShape.

  ShapeBorder floatingShape() {
    return const StadiumBorder();
  }

  /// dockedShape.

  ShapeBorder dockedShape() {
    if (dockedRadius <= 0) {
      return const RoundedRectangleBorder();
    }
    return RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(dockedRadius),
    );
  }

  /// shape.

  ShapeBorder shape(MorphToolbarShapeFamily family) {
    return family == MorphToolbarShapeFamily.round
        ? floatingShape()
        : dockedShape();
  }

  /// titleStyle.

  TextStyle titleStyle(MorphTypeScale typeScale) => typeScale.titleSmall;

  /// subtitleStyle.

  TextStyle subtitleStyle(MorphTypeScale typeScale) => typeScale.bodySmall;

  /// scopedTheme.

  /// Unselected toolbar icons read [MorphColorScheme.onSurfaceVariant].
  ///
  /// Disabled content stays on [MorphColorScheme.onSurface] so the icon button
  /// can fade it to [MorphToolbarTokens.disabledContentAlpha].
  MorphThemeData scopedTheme(MorphThemeData base, Color foreground) {
    return base.copyWith(
      colorScheme: base.colorScheme.copyWith(onSurfaceVariant: foreground),
    );
  }

  /// iconButtonSize.

  MorphIconButtonSize iconButtonSize(MorphToolbarSize size) {
    switch (size) {
      case MorphToolbarSize.small:
        return MorphIconButtonSize.xs;
      case MorphToolbarSize.medium:
      case MorphToolbarSize.large:
        return MorphIconButtonSize.sm;
    }
  }

  @override
  MorphToolbarTheme copyWith({
    double? containerSize,
    double? floatingPadding,
    double? dockedHorizontalPadding,
    double? actionGap,
    double? dockedPreferredGap,
    double? dockedMinGap,
    double? centeredGap,
    double? iconSize,
    double? elevation,
    double? floatingElevation,
    double? elevationWithFab,
    double? toolbarToFabGap,
    double? screenOffset,
    double? verticalScreenOffset,
    double? compactBreakpoint,
    double? fabExpandedIcon,
    double? fabCollapsedIcon,
    double? dockedRadius,
    double? heightSmall,
    double? heightMedium,
    double? heightLarge,
    double? compactHeightReduction,
    double? elevationSurface,
    double? elevationProminent,
    MorphSpring? expandSpring,
    MorphSpring? labelSpring,
  }) {
    return MorphToolbarTheme(
      containerSize: containerSize ?? this.containerSize,
      floatingPadding: floatingPadding ?? this.floatingPadding,
      dockedHorizontalPadding:
          dockedHorizontalPadding ?? this.dockedHorizontalPadding,
      actionGap: actionGap ?? this.actionGap,
      dockedPreferredGap: dockedPreferredGap ?? this.dockedPreferredGap,
      dockedMinGap: dockedMinGap ?? this.dockedMinGap,
      centeredGap: centeredGap ?? this.centeredGap,
      iconSize: iconSize ?? this.iconSize,
      elevation: elevation ?? this.elevation,
      floatingElevation: floatingElevation ?? this.floatingElevation,
      elevationWithFab: elevationWithFab ?? this.elevationWithFab,
      toolbarToFabGap: toolbarToFabGap ?? this.toolbarToFabGap,
      screenOffset: screenOffset ?? this.screenOffset,
      verticalScreenOffset: verticalScreenOffset ?? this.verticalScreenOffset,
      compactBreakpoint: compactBreakpoint ?? this.compactBreakpoint,
      fabExpandedIcon: fabExpandedIcon ?? this.fabExpandedIcon,
      fabCollapsedIcon: fabCollapsedIcon ?? this.fabCollapsedIcon,
      dockedRadius: dockedRadius ?? this.dockedRadius,
      heightSmall: heightSmall ?? this.heightSmall,
      heightMedium: heightMedium ?? this.heightMedium,
      heightLarge: heightLarge ?? this.heightLarge,
      compactHeightReduction:
          compactHeightReduction ?? this.compactHeightReduction,
      elevationSurface: elevationSurface ?? this.elevationSurface,
      elevationProminent: elevationProminent ?? this.elevationProminent,
      expandSpring: expandSpring ?? this.expandSpring,
      labelSpring: labelSpring ?? this.labelSpring,
    );
  }

  @override
  MorphToolbarTheme lerp(MorphToolbarTheme? other, double t) {
    if (other is! MorphToolbarTheme) {
      return this;
    }
    return MorphToolbarTheme(
      containerSize: _lerp(containerSize, other.containerSize, t),
      floatingPadding: _lerp(floatingPadding, other.floatingPadding, t),
      dockedHorizontalPadding: _lerp(
        dockedHorizontalPadding,
        other.dockedHorizontalPadding,
        t,
      ),
      actionGap: _lerp(actionGap, other.actionGap, t),
      dockedPreferredGap: _lerp(
        dockedPreferredGap,
        other.dockedPreferredGap,
        t,
      ),
      dockedMinGap: _lerp(dockedMinGap, other.dockedMinGap, t),
      centeredGap: _lerp(centeredGap, other.centeredGap, t),
      iconSize: _lerp(iconSize, other.iconSize, t),
      elevation: _lerp(elevation, other.elevation, t),
      floatingElevation: _lerp(floatingElevation, other.floatingElevation, t),
      elevationWithFab: _lerp(elevationWithFab, other.elevationWithFab, t),
      toolbarToFabGap: _lerp(toolbarToFabGap, other.toolbarToFabGap, t),
      screenOffset: _lerp(screenOffset, other.screenOffset, t),
      verticalScreenOffset: _lerp(
        verticalScreenOffset,
        other.verticalScreenOffset,
        t,
      ),
      compactBreakpoint: _lerp(compactBreakpoint, other.compactBreakpoint, t),
      fabExpandedIcon: _lerp(fabExpandedIcon, other.fabExpandedIcon, t),
      fabCollapsedIcon: _lerp(fabCollapsedIcon, other.fabCollapsedIcon, t),
      dockedRadius: _lerp(dockedRadius, other.dockedRadius, t),
      heightSmall: _lerp(heightSmall, other.heightSmall, t),
      heightMedium: _lerp(heightMedium, other.heightMedium, t),
      heightLarge: _lerp(heightLarge, other.heightLarge, t),
      compactHeightReduction: _lerp(
        compactHeightReduction,
        other.compactHeightReduction,
        t,
      ),
      elevationSurface: _lerp(elevationSurface, other.elevationSurface, t),
      elevationProminent: _lerp(
        elevationProminent,
        other.elevationProminent,
        t,
      ),
      expandSpring: t < 0.5 ? expandSpring : other.expandSpring,
      labelSpring: t < 0.5 ? labelSpring : other.labelSpring,
    );
  }

  double _lerp(double a, double b, double t) => a + (b - a) * t;
}

extension on MorphToolbarMetrics {
  MorphToolbarMetrics copyWithGap(double gap) {
    return MorphToolbarMetrics(
      crossAxisSize: crossAxisSize,
      contentPadding: contentPadding,
      gap: gap,
      iconSize: iconSize,
      elevation: elevation,
      elevationWithFab: elevationWithFab,
    );
  }
}
