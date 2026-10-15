import 'package:flutter/animation.dart';
import '../../../foundations/foundations.dart';

/// Shared constants for the Morph search bar and search view.
abstract final class MorphSearchConstants {
  /// openViewMilliseconds.
  static const int openViewMilliseconds = 600;

  /// openViewDuration.
  static const Duration openViewDuration = Duration(
    milliseconds: openViewMilliseconds,
  );

  /// anchorFadeDuration.
  static const Duration anchorFadeDuration = MorphMotion.short3;

  /// viewFadeOnInterval.

  static const Curve viewFadeOnInterval = Interval(0, 1 / 2);

  /// viewIconsFadeOnInterval.
  static const Curve viewIconsFadeOnInterval = Interval(1 / 6, 2 / 6);

  /// viewDividerFadeOnInterval.
  static const Curve viewDividerFadeOnInterval = Interval(0, 1 / 6);

  /// viewListFadeOnInterval.
  static const Curve viewListFadeOnInterval = Interval(
    133 / openViewMilliseconds,
    233 / openViewMilliseconds,
  );

  /// disabledOpacity.

  static const double disabledOpacity = 0.38;

  /// fullScreenBarHeight.
  static const double fullScreenBarHeight = 72;

  /// dismissBarrierLabel.

  static const String dismissBarrierLabel = 'Dismiss';

  /// clearButtonTooltip.
  static const String clearButtonTooltip = 'Clear';

  /// backButtonTooltip.
  static const String backButtonTooltip = 'Back';
}

/// Default screen reader text when suggestions or results change.
String morphSearchResultsAnnouncement(int count) =>
    count == 1 ? '1 result available' : '$count results available';
