import 'package:flutter/widgets.dart';

import 'morph_focus_interaction.dart';
import 'morph_ink_splash_theme.dart' show MorphInkSplashTheme;

/// Material 3 state layer opacity tokens.
///
/// State layers are translucent overlays of a role color painted on top of a
/// component to communicate hover, focus, pressed and dragged states.
abstract final class MorphStateOpacity {
  const MorphStateOpacity._();

  /// Hover state-layer opacity (8%).
  static const double hover = 0.08;

  /// Focus state-layer opacity (10%).
  static const double focus = 0.1;

  /// Pressed state-layer opacity (10%).
  static const double pressed = 0.1;

  /// Dragged state-layer opacity (16%).
  static const double dragged = 0.16;

  /// Opacity applied to content (icon/label) of a disabled component.
  static const double disabledContent = 0.38;

  /// Opacity applied to the container of a disabled component.
  static const double disabledContainer = 0.12;
}

/// The mutually reinforcing interaction states of a component.
///
/// Only the highest priority active state contributes a state layer at a time,
/// matching the Material specification (pressed over focus over hover).
@immutable
class MorphInteractionState {
  /// Creates an interaction state snapshot.
  const MorphInteractionState({
    this.hovered = false,
    this.focused = false,
    this.pressed = false,
    this.dragged = false,
  });

  /// Whether the pointer is hovering the component.
  final bool hovered;

  /// Whether the component is keyboard-focused.
  final bool focused;

  /// Whether the component is pressed.
  final bool pressed;

  /// Whether the component is being dragged.
  final bool dragged;

  /// Focus fill when rings are not the keyboard chrome.
  bool get showFocusFill =>
      focused && !MorphFocusInteraction.instance.ringsAllowed;

  /// Resolves the effective state layer opacity for the active state.
  double get opacity {
    if (dragged) {
      return MorphStateOpacity.dragged;
    }
    if (pressed) {
      return MorphStateOpacity.pressed;
    }
    if (showFocusFill) {
      return MorphStateOpacity.focus;
    }
    if (hovered) {
      return MorphStateOpacity.hover;
    }
    return 0;
  }

  /// Returns a copy with the given fields replaced.
  MorphInteractionState copyWith({
    bool? hovered,
    bool? focused,
    bool? pressed,
    bool? dragged,
  }) {
    return MorphInteractionState(
      hovered: hovered ?? this.hovered,
      focused: focused ?? this.focused,
      pressed: pressed ?? this.pressed,
      dragged: dragged ?? this.dragged,
    );
  }

  @override
  /// Equality based on public fields.
  bool operator ==(Object other) {
    return other is MorphInteractionState &&
        other.hovered == hovered &&
        other.focused == focused &&
        other.pressed == pressed &&
        other.dragged == dragged;
  }

  @override
  /// Hash code for this interaction state.
  int get hashCode => Object.hash(hovered, focused, pressed, dragged);
}

/// Resolves Material state-layer overlay colors using [MorphStateOpacity] tokens.
abstract final class MorphStateLayer {
  const MorphStateLayer._();

  /// Resolves an overlay color for the highest-priority active [states].
  ///
  /// When keyboard focus rings are active, [WidgetState.focused] does not
  /// contribute a fill overlay (ring-only chrome).
  static Color? resolveOverlayColor(Color color, Set<WidgetState> states) {
    if (states.contains(WidgetState.pressed)) {
      return color.withValues(alpha: MorphStateOpacity.pressed);
    }
    if (states.contains(WidgetState.hovered)) {
      return color.withValues(alpha: MorphStateOpacity.hover);
    }
    if (states.contains(WidgetState.focused) &&
        !MorphFocusInteraction.instance.ringsAllowed) {
      return color.withValues(alpha: MorphStateOpacity.focus);
    }
    return null;
  }

  /// Pressed ripple color. Use with splash on ink widgets or
  /// [MorphInkSplashTheme] for Material buttons.
  static Color splashColor(Color color) =>
      color.withValues(alpha: MorphStateOpacity.pressed);

  /// Hover/focus overlays only. Pressed feedback is splash-only.
  static WidgetStateProperty<Color?> overlayColorHoverFocus(Color color) {
    return WidgetStateProperty.resolveWith((Set<WidgetState> states) {
      if (states.contains(WidgetState.pressed)) {
        return null;
      }
      return resolveOverlayColor(color, states);
    });
  }

  /// Alias for [overlayColorHoverFocus].
  static WidgetStateProperty<Color?> overlayColor(Color color) {
    return overlayColorHoverFocus(color);
  }
}
