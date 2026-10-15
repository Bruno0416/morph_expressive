import 'package:flutter/widgets.dart';

/// Text selection gestures for `MorphTextField`.
///
/// Tap places the caret, double tap selects a word, and long press or drag
/// selects text. [onTap] runs on every user tap.
class MorphTextFieldSelectionBuilder extends TextSelectionGestureDetectorBuilder {
  /// Creates the gesture builder.
  MorphTextFieldSelectionBuilder({required super.delegate, this.onTap});

  /// Called after a user tap.
  final VoidCallback? onTap;

  @override
  void onUserTap() => onTap?.call();
}
