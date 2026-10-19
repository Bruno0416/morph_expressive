import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../theme/morph_theme.dart';

/// Haptic preference for an interactive Morph control.
///
/// [inherit] takes the nearest [MorphTheme] default, [none] opts out locally,
/// and a concrete impact overrides the default while the theme is enabled.
enum MorphHapticFeedback {
  /// Use the nearest MorphThemeData.hapticFeedback.
  inherit(-1),

  /// Suppress haptics for this interaction.
  none(0),

  /// Light impact.
  light(1),

  /// Medium impact.
  medium(2),

  /// Heavy impact.
  heavy(3);

  final int value;
  const MorphHapticFeedback(this.value);
}

/// Feedback centralization for Morph components.
///
/// Components should use the context-aware methods. The legacy context-free
/// methods remain available for callers who intentionally manage feedback
/// outside a MorphTheme, but cannot obey an inherited opt-out.
abstract final class MorphHaptics {
  const MorphHaptics._();

  /// Resolves a component override against the nearest theme.
  static MorphHapticFeedback resolve(
    BuildContext context, [
    MorphHapticFeedback level = MorphHapticFeedback.inherit,
  ]) {
    final theme = MorphTheme.of(context);
    if (!theme.hapticsEnabled) return MorphHapticFeedback.none;
    final effective = level == MorphHapticFeedback.inherit
        ? theme.hapticFeedback
        : level;
    return effective == MorphHapticFeedback.inherit
        ? MorphHapticFeedback.light
        : effective;
  }

  /// Emits a theme-aware impact, or nothing when disabled.
  static void triggerFor(
    BuildContext context, [
    MorphHapticFeedback level = MorphHapticFeedback.inherit,
  ]) {
    trigger(resolve(context, level));
  }

  /// Emits a selection tick only when the nearest MorphTheme allows haptics.
  static void selectionFor(BuildContext context) {
    if (resolve(context) != MorphHapticFeedback.none) selection();
  }

  /// Emits an explicit impact without inherited theme resolution.
  /// Prefer [triggerFor] inside the Morph widget tree.
  static void trigger(MorphHapticFeedback level) {
    switch (level) {
      case MorphHapticFeedback.light:
        HapticFeedback.lightImpact();
      case MorphHapticFeedback.medium:
        HapticFeedback.mediumImpact();
      case MorphHapticFeedback.heavy:
        HapticFeedback.heavyImpact();
      case MorphHapticFeedback.none:
      case MorphHapticFeedback.inherit:
        break;
    }
  }

  /// Raw selection tick. Prefer [selectionFor] from Morph components.
  static void selection() {
    HapticFeedback.selectionClick();
  }
}
