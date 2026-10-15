import 'package:flutter/widgets.dart';

import '../../../foundations/interaction/morph_motion.dart';
import 'morph_selection_flip.dart';

/// Flips horizontally between [child] and [selectedChild] when [selected].
///
/// Thin wrapper over [MorphSelectionFlip] for leading-slot usage.
class MorphSelectionLeading extends StatelessWidget {
  /// Creates a selection leading flip.
  const MorphSelectionLeading({
    required this.selected,
    required this.selectedChild,
    required this.child,
    this.duration = MorphMotion.selectionFlip,
    this.onTap,
    super.key,
  });

  /// Whether the selected face is shown.
  final bool selected;

  /// Unselected leading widget.
  final Widget child;

  /// Selected leading widget.
  final Widget selectedChild;

  /// Flip duration.
  final Duration duration;

  /// Optional tap handler (leading only; does not compete with row body).
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return MorphSelectionFlip(
      selected: selected,
      selectedChild: selectedChild,
      duration: duration,
      onTap: onTap,
      child: child,
    );
  }
}
