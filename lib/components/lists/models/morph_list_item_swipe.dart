import 'package:flutter/widgets.dart';

import '../enums/morph_list_swipe_edge.dart';
import '../enums/morph_list_swipe_mode.dart';
import 'morph_list_swipe_action.dart';

/// Swipe configuration for one list item.
///
/// Null on the item means that row does not swipe. When set, the row can
/// reveal actions, dismiss, or both, using the same gesture rules as before.
@immutable
class MorphListItemSwipe {
  /// Creates a per-item swipe configuration.
  const MorphListItemSwipe({
    this.leading = const <MorphListSwipeAction>[],
    this.trailing = const <MorphListSwipeAction>[],
    this.mode = MorphListSwipeMode.both,
    this.edge = MorphListSwipeEdge.both,
    this.onDismiss,
    this.background,
    this.secondaryBackground,
  });

  /// Start-side actions (revealed by a rightward swipe in LTR).
  final List<MorphListSwipeAction> leading;

  /// End-side actions (revealed by a leftward swipe in LTR).
  final List<MorphListSwipeAction> trailing;

  /// Reveal only, dismiss only, or reveal then dismiss.
  final MorphListSwipeMode mode;

  /// Which manual swipe direction can dismiss.
  final MorphListSwipeEdge edge;

  /// Called when this row is dismissed. Return false to keep the row.
  final Future<bool> Function(DismissDirection direction)? onDismiss;

  /// Background revealed when swiping start-to-end.
  final Widget? background;

  /// Background revealed when swiping end-to-start.
  ///
  /// Falls back to [background] when null.
  final Widget? secondaryBackground;
}
