import 'package:flutter/services.dart';

/// Haptic feedback intensity levels for Morph interactions.
///
/// Use with [MorphHaptics.trigger], component decoration / style haptic fields,
/// or the shared tappable interaction primitive.
///
/// ## Levels
/// - [none] — No haptic feedback (default)
/// - [light] — Light tap feedback for subtle interactions
/// - [medium] — Medium impact for standard presses
/// - [heavy] — Heavy impact for significant actions
enum MorphHapticFeedback {
  /// No haptic feedback.
  none(0),

  /// Light tap feedback.
  light(1),

  /// Medium impact feedback.
  medium(2),

  /// Heavy impact feedback.
  heavy(3);

  /// Ordinal value for the level.
  final int value;

  const MorphHapticFeedback(this.value);
}

/// Shared haptic helpers for Material 3 Expressive components.
///
/// Prefer this API over raw [HapticFeedback] calls so intensity stays consistent
/// and platform no-ops remain centralized.
abstract final class MorphHaptics {
  const MorphHaptics._();

  /// Fires impact feedback for [level]. [MorphHapticFeedback.none] is a no-op.
  static void trigger(MorphHapticFeedback level) {
    switch (level) {
      case MorphHapticFeedback.light:
        HapticFeedback.lightImpact();
      case MorphHapticFeedback.medium:
        HapticFeedback.mediumImpact();
      case MorphHapticFeedback.heavy:
        HapticFeedback.heavyImpact();
      case MorphHapticFeedback.none:
        break;
    }
  }

  /// Fires selection feedback (e.g. discrete slider ticks, picker selection).
  static void selection() {
    HapticFeedback.selectionClick();
  }
}
