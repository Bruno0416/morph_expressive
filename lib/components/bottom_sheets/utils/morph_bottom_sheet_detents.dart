import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import '../enums/morph_bottom_sheet_enums.dart';

/// Preset heights (in dp) a sheet can rest at, lowest first.
@immutable
class MorphBottomSheetDetents {
  /// MorphBottomSheetDetents.
  const MorphBottomSheetDetents(this.heights);

  /// Works out the preset heights for a sheet.
  ///
  /// [contentHeight] is the laid-out sheet height. Without [fullScreen] the
  /// sheet opens at most [initialFraction] of [screenHeight] and expands to
  /// its content, up to [screenHeight] minus [topMargin].
  factory MorphBottomSheetDetents.resolve({
    required double contentHeight,
    required double screenHeight,
    required double topMargin,
    required double initialFraction,
    required bool fullScreen,
    double? previewHeight,
  }) {
    final double maxHeight = math.max(0, screenHeight - topMargin);
    final double cap = screenHeight * initialFraction;
    final double expanded = fullScreen
        ? maxHeight
        : math.min(contentHeight, maxHeight);
    final heights = <MorphBottomSheetValue, double>{};
    final preview = previewHeight;
    if (preview != null && preview > 0 && preview < math.min(cap, expanded)) {
      heights[MorphBottomSheetValue.preview] = preview;
    }
    if (expanded > cap + 0.5) {
      heights[MorphBottomSheetValue.collapsed] = cap;
    }
    heights[MorphBottomSheetValue.expanded] = expanded;
    if (fullScreen) {
      heights[MorphBottomSheetValue.fullScreen] = screenHeight;
    }
    return MorphBottomSheetDetents(heights);
  }

  /// Visible height per value, lowest first. Never holds `hidden`.
  final Map<MorphBottomSheetValue, double> heights;

  /// Available values, lowest first.
  List<MorphBottomSheetValue> get values => heights.keys.toList();

  /// Tallest preset height.
  double get max => heights.values.last;

  /// Lowest preset height.
  double get min => heights.values.first;

  /// Visible height for [value]; 0 when hidden or missing.
  double heightOf(MorphBottomSheetValue value) => heights[value] ?? 0;

  /// [wanted] when available, else the closest available value above it.
  MorphBottomSheetValue resolve(MorphBottomSheetValue wanted) {
    if (wanted == MorphBottomSheetValue.hidden || heights.containsKey(wanted)) {
      return wanted;
    }
    for (final MorphBottomSheetValue value in values) {
      if (value.index > wanted.index) {
        return value;
      }
    }
    return values.last;
  }

  /// Value whose height is closest to [extent].
  MorphBottomSheetValue nearest(double extent) {
    MorphBottomSheetValue best = values.first;
    for (final MorphBottomSheetValue value in values) {
      if ((heights[value]! - extent).abs() < (heights[best]! - extent).abs()) {
        best = value;
      }
    }
    return best;
  }

  /// First value taller than [extent], or null.
  MorphBottomSheetValue? above(double extent) {
    for (final MorphBottomSheetValue value in values) {
      if (heights[value]! > extent + 0.5) {
        return value;
      }
    }
    return null;
  }

  /// First value lower than [extent], or null.
  MorphBottomSheetValue? below(double extent) {
    for (final MorphBottomSheetValue value in values.reversed) {
      if (heights[value]! < extent - 0.5) {
        return value;
      }
    }
    return null;
  }

  @override
  bool operator ==(Object other) =>
      other is MorphBottomSheetDetents && mapEquals(other.heights, heights);

  @override
  int get hashCode => Object.hashAllUnordered(heights.entries.map(_hash));

  static int _hash(MapEntry<MorphBottomSheetValue, double> e) =>
      Object.hash(e.key, e.value);
}
