import 'package:flutter/widgets.dart';

import '../../../foundations/foundations.dart';
import '../enums/morph_bottom_sheet_enums.dart';
import 'morph_bottom_sheet_colors.dart';
import 'morph_bottom_sheet_drag_handle_style.dart';

export 'morph_bottom_sheet_colors.dart';
export 'morph_bottom_sheet_drag_handle_style.dart';

/// Theme values for `MorphBottomSheet`.
///
/// Defaults follow the M3 bottom sheet spec. Both variants share them; only
/// the modal sheet has a scrim.
@immutable
class MorphBottomSheetTheme extends MorphThemeExtension<MorphBottomSheetTheme> {
  /// MorphBottomSheetTheme.
  const MorphBottomSheetTheme({
    this.maxWidth = 640,
    this.topCornerRadius = 28,
    this.handleWidth = 32,
    this.handleHeight = 4,
    this.handleCornerRadius = 2,
    this.handleVerticalPadding = 22,
    this.handleOpacity = 0.4,
    this.scrimOpacity = 0.32,
    this.dismissVelocity = 700,
    this.wideBreakpoint = 640,
    this.compactTopMargin = 72,
    this.wideTopMargin = 56,
    this.wideSideMargin = 56,
    this.bottomCornerRadius = 0,
    this.modalElevation = MorphElevation.level1,
    this.standardElevation = MorphElevation.level1,
    this.initialHeightFraction = 0.5,
    this.dismissThresholdFraction = 0.5,
    this.handleCyclesToClose = false,
    this.fullScreenHeaderHeight = 64,
    this.enterSpring = MorphMotion.spatialDefault,
    this.settleSpring = MorphMotion.spatialDefault,
    this.layoutSpring = MorphMotion.spatialDefault,
    this.scrimSpring = MorphMotion.effectsDefault,
    this.predictiveBackShrinkX = 48,
    this.predictiveBackShrinkY = 24,
    this.adaptiveSideSheetBreakpoint = 840,
    this.colors = const MorphBottomSheetColors(),
    this.dragHandle = const MorphBottomSheetDragHandleStyle(),
  });

  /// defaults.
  static const MorphBottomSheetTheme defaults = MorphBottomSheetTheme();

  /// Max sheet width (640).
  final double maxWidth;

  /// Top corner radius, extra large top rounding (28).
  final double topCornerRadius;

  /// Drag handle width (32).
  final double handleWidth;

  /// Drag handle height (4).
  final double handleHeight;

  /// Drag handle corner radius (2, fully rounded).
  final double handleCornerRadius;

  /// Space above and below the drag handle (22).
  final double handleVerticalPadding;

  /// Drag handle opacity (0.4).
  final double handleOpacity;

  /// Scrim opacity (0.32).
  final double scrimOpacity;

  /// Fling speed in dp/s that moves one preset height (700).
  final double dismissVelocity;

  /// Window widths above this use the wide margins (640).
  final double wideBreakpoint;

  /// Top margin at or below [wideBreakpoint] (72).
  final double compactTopMargin;

  /// Top margin above [wideBreakpoint] (56).
  final double wideTopMargin;

  /// Start / end margin above [wideBreakpoint] (56).
  final double wideSideMargin;

  /// Bottom corner radius, no rounding (0).
  final double bottomCornerRadius;

  /// Modal container elevation (level 1).
  final double modalElevation;

  /// Standard container elevation (level 1).
  final double standardElevation;

  /// Cap on the initial height as a share of the screen (0.5).
  final double initialHeightFraction;

  /// Releasing below this share of the lowest height dismisses (0.5).
  final double dismissThresholdFraction;

  /// Whether selecting the handle at the tallest height closes the sheet.
  final bool handleCyclesToClose;

  /// Full-screen header height (64).
  final double fullScreenHeaderHeight;

  /// Spring for opening and closing.
  final MorphSpring enterSpring;

  /// Spring for snapping between heights.
  final MorphSpring settleSpring;

  /// Spring for width and margin changes across [wideBreakpoint].
  final MorphSpring layoutSpring;

  /// Spring for the scrim fade.
  final MorphSpring scrimSpring;

  /// Width lost at full predictive-back progress (48).
  final double predictiveBackShrinkX;

  /// Height lost at full predictive-back progress (24).
  final double predictiveBackShrinkY;

  /// `showAdaptive` uses a side sheet at and above this width (840).
  final double adaptiveSideSheetBreakpoint;

  /// Color overrides.
  final MorphBottomSheetColors colors;

  /// Drag handle interaction tokens.
  final MorphBottomSheetDragHandleStyle dragHandle;

  /// Container color.
  Color containerColor(MorphColorScheme scheme) =>
      colors.containerColor ?? scheme.surfaceContainerLow;

  /// Drag handle color with [handleOpacity].
  Color handleColor(MorphColorScheme scheme) => MorphColorUtils.withOpacity(
    colors.handleColor ?? scheme.onSurfaceVariant,
    handleOpacity,
  );

  /// Handle state layer color.
  Color handleStateColor(MorphColorScheme scheme) =>
      colors.handleColor ?? scheme.onSurfaceVariant;

  /// Drag handle focus ring color.
  Color focusRingColor(MorphColorScheme scheme) =>
      colors.focusRingColor ?? scheme.secondary;

  /// Scrim color with [scrimOpacity].
  Color scrimColor(MorphColorScheme scheme) =>
      (colors.scrimColor ?? scheme.scrim).withValues(alpha: scrimOpacity);

  /// Container elevation for [variant].
  double elevationFor(MorphBottomSheetVariant variant) =>
      variant == MorphBottomSheetVariant.modal
      ? modalElevation
      : standardElevation;

  /// Height of the top strip that holds the handle.
  double get dragRegionHeight {
    final double handle = handleHeight + handleVerticalPadding * 2;
    final double region = dragHandle.dragRegionHeight;
    return handle > region ? handle : region;
  }

  @override
  MorphBottomSheetTheme copyWith({
    double? maxWidth,
    double? topCornerRadius,
    double? handleWidth,
    double? handleHeight,
    double? handleCornerRadius,
    double? handleVerticalPadding,
    double? handleOpacity,
    double? scrimOpacity,
    double? dismissVelocity,
    double? wideBreakpoint,
    double? compactTopMargin,
    double? wideTopMargin,
    double? wideSideMargin,
    double? bottomCornerRadius,
    double? modalElevation,
    double? standardElevation,
    double? initialHeightFraction,
    double? dismissThresholdFraction,
    bool? handleCyclesToClose,
    double? fullScreenHeaderHeight,
    MorphSpring? enterSpring,
    MorphSpring? settleSpring,
    MorphSpring? layoutSpring,
    MorphSpring? scrimSpring,
    double? predictiveBackShrinkX,
    double? predictiveBackShrinkY,
    double? adaptiveSideSheetBreakpoint,
    MorphBottomSheetColors? colors,
    MorphBottomSheetDragHandleStyle? dragHandle,
  }) {
    return MorphBottomSheetTheme(
      maxWidth: maxWidth ?? this.maxWidth,
      topCornerRadius: topCornerRadius ?? this.topCornerRadius,
      handleWidth: handleWidth ?? this.handleWidth,
      handleHeight: handleHeight ?? this.handleHeight,
      handleCornerRadius: handleCornerRadius ?? this.handleCornerRadius,
      handleVerticalPadding:
          handleVerticalPadding ?? this.handleVerticalPadding,
      handleOpacity: handleOpacity ?? this.handleOpacity,
      scrimOpacity: scrimOpacity ?? this.scrimOpacity,
      dismissVelocity: dismissVelocity ?? this.dismissVelocity,
      wideBreakpoint: wideBreakpoint ?? this.wideBreakpoint,
      compactTopMargin: compactTopMargin ?? this.compactTopMargin,
      wideTopMargin: wideTopMargin ?? this.wideTopMargin,
      wideSideMargin: wideSideMargin ?? this.wideSideMargin,
      bottomCornerRadius: bottomCornerRadius ?? this.bottomCornerRadius,
      modalElevation: modalElevation ?? this.modalElevation,
      standardElevation: standardElevation ?? this.standardElevation,
      initialHeightFraction:
          initialHeightFraction ?? this.initialHeightFraction,
      dismissThresholdFraction:
          dismissThresholdFraction ?? this.dismissThresholdFraction,
      handleCyclesToClose: handleCyclesToClose ?? this.handleCyclesToClose,
      fullScreenHeaderHeight:
          fullScreenHeaderHeight ?? this.fullScreenHeaderHeight,
      enterSpring: enterSpring ?? this.enterSpring,
      settleSpring: settleSpring ?? this.settleSpring,
      layoutSpring: layoutSpring ?? this.layoutSpring,
      scrimSpring: scrimSpring ?? this.scrimSpring,
      predictiveBackShrinkX:
          predictiveBackShrinkX ?? this.predictiveBackShrinkX,
      predictiveBackShrinkY:
          predictiveBackShrinkY ?? this.predictiveBackShrinkY,
      adaptiveSideSheetBreakpoint:
          adaptiveSideSheetBreakpoint ?? this.adaptiveSideSheetBreakpoint,
      colors: colors ?? this.colors,
      dragHandle: dragHandle ?? this.dragHandle,
    );
  }

  @override
  MorphBottomSheetTheme lerp(MorphBottomSheetTheme? other, double t) {
    if (other is! MorphBottomSheetTheme) {
      return this;
    }
    final MorphBottomSheetTheme end = t < 0.5 ? this : other;
    return end.copyWith(
      maxWidth: _lerp(maxWidth, other.maxWidth, t),
      topCornerRadius: _lerp(topCornerRadius, other.topCornerRadius, t),
      handleWidth: _lerp(handleWidth, other.handleWidth, t),
      handleHeight: _lerp(handleHeight, other.handleHeight, t),
      handleCornerRadius: _lerp(
        handleCornerRadius,
        other.handleCornerRadius,
        t,
      ),
      handleVerticalPadding: _lerp(
        handleVerticalPadding,
        other.handleVerticalPadding,
        t,
      ),
      handleOpacity: _lerp(handleOpacity, other.handleOpacity, t),
      scrimOpacity: _lerp(scrimOpacity, other.scrimOpacity, t),
      dismissVelocity: _lerp(dismissVelocity, other.dismissVelocity, t),
      compactTopMargin: _lerp(compactTopMargin, other.compactTopMargin, t),
      wideTopMargin: _lerp(wideTopMargin, other.wideTopMargin, t),
      wideSideMargin: _lerp(wideSideMargin, other.wideSideMargin, t),
      bottomCornerRadius: _lerp(
        bottomCornerRadius,
        other.bottomCornerRadius,
        t,
      ),
      modalElevation: _lerp(modalElevation, other.modalElevation, t),
      standardElevation: _lerp(standardElevation, other.standardElevation, t),
      fullScreenHeaderHeight: _lerp(
        fullScreenHeaderHeight,
        other.fullScreenHeaderHeight,
        t,
      ),
      colors: colors.lerp(other.colors, t),
      dragHandle: dragHandle.lerp(other.dragHandle, t),
    );
  }

  static double _lerp(double a, double b, double t) => a + (b - a) * t;
}
