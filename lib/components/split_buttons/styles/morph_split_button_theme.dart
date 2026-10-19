import 'package:flutter/widgets.dart';
import 'package:material_ui/material_ui.dart';

import '../../../foundations/foundations.dart';
import '../../buttons/enums/morph_button_enums.dart';
import '../../buttons/styles/morph_button_motion.dart';

/// Theme values for `MorphSplitButton`.
@immutable
class MorphSplitButtonTheme extends MorphThemeExtension<MorphSplitButtonTheme> {
  /// MorphSplitButtonTheme.
  const MorphSplitButtonTheme({
    this.minTapTarget = 48,
    this.innerGap = 2,
    this.elevatedInnerGap = 2,
    this.chevronOpenTurns = 0.5,
    this.trailingInnerSelectedCornerPercent = 50,
    this.popupElevation = 3,
    this.popupBorderRadius = 28,
    this.popupPadding = const EdgeInsets.all(10),
    this.popupOffset = const Offset(0, 4),
    this.popupMinWidth = 120,
    this.popupMaxWidth = 280,
    this.popupMaxHeight = 400,
    this.popupScrimAlpha = 0.26,
    this.popupMotion = MorphButtonMotion.standardPopup,
  });

  /// defaults.

  static const MorphSplitButtonTheme defaults = MorphSplitButtonTheme();

  /// minTapTarget.

  final double minTapTarget;

  /// innerGap.
  final double innerGap;

  /// elevatedInnerGap — same as [innerGap] (spec: always 2dp).
  final double elevatedInnerGap;

  /// chevronOpenTurns.
  final double chevronOpenTurns;

  /// trailingInnerSelectedCornerPercent.
  final double trailingInnerSelectedCornerPercent;

  /// popupElevation.
  final double popupElevation;

  /// popupBorderRadius.
  final double popupBorderRadius;

  /// popupPadding.
  final EdgeInsetsGeometry popupPadding;

  /// popupOffset.
  final Offset popupOffset;

  /// popupMinWidth.
  final double popupMinWidth;

  /// popupMaxWidth.
  final double popupMaxWidth;

  /// popupMaxHeight.
  final double popupMaxHeight;

  /// popupScrimAlpha.
  final double popupScrimAlpha;

  /// popupMotion.
  final MorphButtonMotion popupMotion;

  static final Map<MorphButtonSize, double> _splitHeight = {
    MorphButtonSize.xs: 32,
    MorphButtonSize.sm: 40,
    MorphButtonSize.md: 56,
    MorphButtonSize.lg: 96,
    MorphButtonSize.xl: 136,
  };

  static final Map<MorphButtonSize, double> _splitTrailingWidth = {
    MorphButtonSize.xs: 22,
    MorphButtonSize.sm: 22,
    MorphButtonSize.md: 26,
    MorphButtonSize.lg: 38,
    MorphButtonSize.xl: 50,
  };

  static final Map<MorphButtonSize, double> _splitInnerCornerRadius = {
    MorphButtonSize.xs: 4,
    MorphButtonSize.sm: 4,
    MorphButtonSize.md: 4,
    MorphButtonSize.lg: 8,
    MorphButtonSize.xl: 12,
  };

  static final Map<MorphButtonSize, double> _splitHoveredInnerCornerRadius = {
    MorphButtonSize.xs: 8,
    MorphButtonSize.sm: 12,
    MorphButtonSize.md: 12,
    MorphButtonSize.lg: 20,
    MorphButtonSize.xl: 20,
  };

  static final Map<MorphButtonSize, double> _splitInnerPadding = {
    MorphButtonSize.xs: 4,
    MorphButtonSize.sm: 4,
    MorphButtonSize.md: 4,
    MorphButtonSize.lg: 8,
    MorphButtonSize.xl: 12,
  };

  static final Map<MorphButtonSize, double> _splitMenuIconOffset = {
    MorphButtonSize.xs: -1,
    MorphButtonSize.sm: -1,
    MorphButtonSize.md: -2,
    MorphButtonSize.lg: -3,
    MorphButtonSize.xl: -6,
  };

  static final Map<MorphButtonSize, double> _splitIcon = {
    MorphButtonSize.xs: 20,
    MorphButtonSize.sm: 20,
    MorphButtonSize.md: 24,
    MorphButtonSize.lg: 32,
    MorphButtonSize.xl: 40,
  };

  static final Map<MorphButtonSize, double> _splitOuterRadiusRound = {
    MorphButtonSize.xs: 16,
    MorphButtonSize.sm: 20,
    MorphButtonSize.md: 28,
    MorphButtonSize.lg: 48,
    MorphButtonSize.xl: 68,
  };

  static final Map<MorphButtonSize, double> _splitOuterRadiusSquare = {
    MorphButtonSize.xs: 8,
    MorphButtonSize.sm: 10,
    MorphButtonSize.md: 14,
    MorphButtonSize.lg: 24,
    MorphButtonSize.xl: 34,
  };

  /// Pressed inner corner = hovered (spec size tables).
  static final Map<MorphButtonSize, double> _splitPressedRadius = {
    MorphButtonSize.xs: 8,
    MorphButtonSize.sm: 12,
    MorphButtonSize.md: 12,
    MorphButtonSize.lg: 20,
    MorphButtonSize.xl: 20,
  };

  static final Map<MorphButtonSize, double> _splitLeadingIconBlockWidth = {
    MorphButtonSize.xs: 20,
    MorphButtonSize.sm: 20,
    MorphButtonSize.md: 24,
    MorphButtonSize.lg: 32,
    MorphButtonSize.xl: 40,
  };

  static final Map<MorphButtonSize, double> _splitLeftOuterPadding = {
    MorphButtonSize.xs: 12,
    MorphButtonSize.sm: 16,
    MorphButtonSize.md: 24,
    MorphButtonSize.lg: 48,
    MorphButtonSize.xl: 64,
  };

  static final Map<MorphButtonSize, double> _splitGapIconToLabel = {
    MorphButtonSize.xs: 4,
    MorphButtonSize.sm: 8,
    MorphButtonSize.md: 8,
    MorphButtonSize.lg: 12,
    MorphButtonSize.xl: 16,
  };

  static final Map<MorphButtonSize, double> _splitLabelRightPadding = {
    MorphButtonSize.xs: 10,
    MorphButtonSize.sm: 12,
    MorphButtonSize.md: 24,
    MorphButtonSize.lg: 48,
    MorphButtonSize.xl: 64,
  };

  /// Optical trailing leading pad (closed, optically centered).
  static final Map<MorphButtonSize, double> _splitTrailingOpticalLeading = {
    MorphButtonSize.xs: 12,
    MorphButtonSize.sm: 12,
    MorphButtonSize.md: 13,
    MorphButtonSize.lg: 26,
    MorphButtonSize.xl: 37,
  };

  /// Optical trailing trailing pad (closed, optically centered).
  static final Map<MorphButtonSize, double> _splitTrailingOpticalTrailing = {
    MorphButtonSize.xs: 14,
    MorphButtonSize.sm: 14,
    MorphButtonSize.md: 17,
    MorphButtonSize.lg: 32,
    MorphButtonSize.xl: 49,
  };

  /// Centered trailing pads when menu open (and geometricCenter when closed).
  static final Map<MorphButtonSize, double> _splitTrailingLeftInnerPadding = {
    MorphButtonSize.xs: 13,
    MorphButtonSize.sm: 13,
    MorphButtonSize.md: 15,
    MorphButtonSize.lg: 29,
    MorphButtonSize.xl: 43,
  };

  static final Map<MorphButtonSize, double> _splitRightOuterPadding = {
    MorphButtonSize.xs: 13,
    MorphButtonSize.sm: 13,
    MorphButtonSize.md: 15,
    MorphButtonSize.lg: 29,
    MorphButtonSize.xl: 43,
  };

  static final Map<MorphButtonSize, double> _splitSidePaddingSelected = {
    MorphButtonSize.xs: 13,
    MorphButtonSize.sm: 13,
    MorphButtonSize.md: 15,
    MorphButtonSize.lg: 29,
    MorphButtonSize.xl: 43,
  };

  /// splitHeight.

  double splitHeight(MorphButtonSize size) => _splitHeight[size] ?? 56;

  /// splitTrailingWidth.

  double splitTrailingWidth(MorphButtonSize size) {
    for (final variant in _splitTrailingWidth.keys) {
      if (variant.name == size.name) {
        return _splitTrailingWidth[variant]!;
      }
    }
    return 26;
  }

  /// splitInnerCornerRadius.

  double splitInnerCornerRadius(MorphButtonSize size) =>
      _splitInnerCornerRadius[size] ?? 4;

  /// splitHoveredInnerCornerRadius.

  double splitHoveredInnerCornerRadius(MorphButtonSize size) =>
      _splitHoveredInnerCornerRadius[size] ?? 12;

  /// splitInnerPadding.

  double splitInnerPadding(MorphButtonSize size) =>
      _splitInnerPadding[size] ?? 4;

  /// splitMenuIconOffset.

  double splitMenuIconOffset(MorphButtonSize size) =>
      _splitMenuIconOffset[size] ?? -2;

  /// splitIcon.

  double splitIcon(MorphButtonSize size) => _splitIcon[size] ?? 20;

  /// splitOuterRadiusRound.

  double splitOuterRadiusRound(MorphButtonSize size) =>
      _splitOuterRadiusRound[size] ?? 28;

  /// splitOuterRadiusSquare.

  double splitOuterRadiusSquare(MorphButtonSize size) =>
      _splitOuterRadiusSquare[size] ?? 14;

  /// splitPressedRadius.

  double splitPressedRadius(MorphButtonSize size) =>
      _splitPressedRadius[size] ?? 12;

  /// splitLeadingIconBlockWidth.

  double splitLeadingIconBlockWidth(MorphButtonSize size) {
    for (final variant in _splitLeadingIconBlockWidth.keys) {
      if (variant.name == size.name) {
        return _splitLeadingIconBlockWidth[variant]!;
      }
    }
    return 24;
  }

  /// splitLeftOuterPadding.

  double splitLeftOuterPadding(MorphButtonSize size) =>
      _splitLeftOuterPadding[size] ?? 24;

  /// splitGapIconToLabel.

  double splitGapIconToLabel(MorphButtonSize size) {
    for (final variant in _splitGapIconToLabel.keys) {
      if (variant.name == size.name) {
        return _splitGapIconToLabel[variant]!;
      }
    }
    return 8;
  }

  /// splitLabelRightPadding.

  double splitLabelRightPadding(MorphButtonSize size) =>
      _splitLabelRightPadding[size] ?? 24;

  /// splitTrailingLeftInnerPadding — centered (open / geometric).

  double splitTrailingLeftInnerPadding(MorphButtonSize size) =>
      _splitTrailingLeftInnerPadding[size] ?? 13;

  /// Optical trailing leading pad (closed + opticalCenter).

  double splitTrailingOpticalLeading(MorphButtonSize size) =>
      _splitTrailingOpticalLeading[size] ?? 12;

  /// Optical trailing trailing pad (closed + opticalCenter).

  double splitTrailingOpticalTrailing(MorphButtonSize size) =>
      _splitTrailingOpticalTrailing[size] ?? 14;

  /// splitRightOuterPadding — centered (open / geometric).

  double splitRightOuterPadding(MorphButtonSize size) =>
      _splitRightOuterPadding[size] ?? 13;

  /// splitSidePaddingSelected.

  double splitSidePaddingSelected(MorphButtonSize size) {
    for (final variant in _splitSidePaddingSelected.keys) {
      if (variant.name == size.name) {
        return _splitSidePaddingSelected[variant]!;
      }
    }
    return 15;
  }

  /// splitLeadingButtonLeadingSpace.

  double splitLeadingButtonLeadingSpace(MorphButtonSize size) =>
      splitLeftOuterPadding(size);

  /// splitLeadingButtonTrailingSpace.

  double splitLeadingButtonTrailingSpace(MorphButtonSize size) =>
      splitLabelRightPadding(size);

  /// splitTrailingIconSize.

  double splitTrailingIconSize(MorphButtonSize size) =>
      _splitTrailingWidth[size] ?? 26;

  /// splitTrailingButtonLeadingSpace.

  double splitTrailingButtonLeadingSpace(MorphButtonSize size) =>
      splitTrailingLeftInnerPadding(size);

  /// splitTrailingButtonTrailingSpace.

  double splitTrailingButtonTrailingSpace(MorphButtonSize size) =>
      splitRightOuterPadding(size);

  /// popupBackgroundColor.

  Color popupBackgroundColor(MorphColorScheme scheme) =>
      scheme.surfaceContainer;

  /// menuBackgroundColor.

  Color menuBackgroundColor(
    MorphColorScheme scheme, {
    required bool containerIsTransparent,
    required Color containerColor,
  }) {
    if (containerIsTransparent) {
      return scheme.surfaceContainerHigh;
    }
    return containerColor;
  }

  /// menuForegroundColor.

  Color menuForegroundColor(
    MorphColorScheme scheme, {
    required bool containerIsTransparent,
    required Color onContainerColor,
  }) {
    if (containerIsTransparent) {
      return scheme.onSurface;
    }
    return onContainerColor;
  }

  @override
  MorphSplitButtonTheme copyWith({
    double? minTapTarget,
    double? innerGap,
    double? elevatedInnerGap,
    double? chevronOpenTurns,
    double? trailingInnerSelectedCornerPercent,
    double? popupElevation,
    double? popupBorderRadius,
    EdgeInsetsGeometry? popupPadding,
    Offset? popupOffset,
    double? popupMinWidth,
    double? popupMaxWidth,
    double? popupMaxHeight,
    double? popupScrimAlpha,
    MorphButtonMotion? popupMotion,
  }) {
    return MorphSplitButtonTheme(
      minTapTarget: minTapTarget ?? this.minTapTarget,
      innerGap: innerGap ?? this.innerGap,
      elevatedInnerGap: elevatedInnerGap ?? this.elevatedInnerGap,
      chevronOpenTurns: chevronOpenTurns ?? this.chevronOpenTurns,
      trailingInnerSelectedCornerPercent:
          trailingInnerSelectedCornerPercent ??
          this.trailingInnerSelectedCornerPercent,
      popupElevation: popupElevation ?? this.popupElevation,
      popupBorderRadius: popupBorderRadius ?? this.popupBorderRadius,
      popupPadding: popupPadding ?? this.popupPadding,
      popupOffset: popupOffset ?? this.popupOffset,
      popupMinWidth: popupMinWidth ?? this.popupMinWidth,
      popupMaxWidth: popupMaxWidth ?? this.popupMaxWidth,
      popupMaxHeight: popupMaxHeight ?? this.popupMaxHeight,
      popupScrimAlpha: popupScrimAlpha ?? this.popupScrimAlpha,
      popupMotion: popupMotion ?? this.popupMotion,
    );
  }

  @override
  MorphSplitButtonTheme lerp(MorphSplitButtonTheme? other, double t) {
    if (other is! MorphSplitButtonTheme) {
      return this;
    }
    return MorphSplitButtonTheme(
      minTapTarget: _lerpDouble(minTapTarget, other.minTapTarget, t)!,
      innerGap: _lerpDouble(innerGap, other.innerGap, t)!,
      elevatedInnerGap: _lerpDouble(
        elevatedInnerGap,
        other.elevatedInnerGap,
        t,
      )!,
      chevronOpenTurns: _lerpDouble(
        chevronOpenTurns,
        other.chevronOpenTurns,
        t,
      )!,
      trailingInnerSelectedCornerPercent: _lerpDouble(
        trailingInnerSelectedCornerPercent,
        other.trailingInnerSelectedCornerPercent,
        t,
      )!,
      popupElevation: _lerpDouble(popupElevation, other.popupElevation, t)!,
      popupBorderRadius: _lerpDouble(
        popupBorderRadius,
        other.popupBorderRadius,
        t,
      )!,
      popupPadding: EdgeInsets.lerp(
        popupPadding as EdgeInsets?,
        other.popupPadding as EdgeInsets?,
        t,
      )!,
      popupOffset: Offset.lerp(popupOffset, other.popupOffset, t)!,
      popupMinWidth: _lerpDouble(popupMinWidth, other.popupMinWidth, t)!,
      popupMaxWidth: _lerpDouble(popupMaxWidth, other.popupMaxWidth, t)!,
      popupMaxHeight: _lerpDouble(popupMaxHeight, other.popupMaxHeight, t)!,
      popupScrimAlpha: _lerpDouble(popupScrimAlpha, other.popupScrimAlpha, t)!,
      popupMotion: t < 0.5 ? popupMotion : other.popupMotion,
    );
  }

  double? _lerpDouble(double a, double b, double t) => a + (b - a) * t;
}
