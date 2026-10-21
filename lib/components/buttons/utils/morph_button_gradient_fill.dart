import 'package:material_ui/material_ui.dart'
    show
        BorderRadius,
        BoxDecoration,
        BuildContext,
        ButtonLayerBuilder,
        ClipRRect,
        DecoratedBox,
        Gradient,
        Opacity,
        SizedBox,
        Widget,
        WidgetState,
        WidgetStateProperty;

import '../res/morph_button_constants.dart';

/// Paints [gradient] behind [child], clipped to [clipRadius].
Widget morphGradientFillLayer({
  required BorderRadius clipRadius,
  required Gradient gradient,
  required Widget? child,
  bool disabled = false,
}) {
  Widget layer = ClipRRect(
    borderRadius: clipRadius,
    child: DecoratedBox(
      decoration: BoxDecoration(gradient: gradient),
      child: child,
    ),
  );
  if (disabled) {
    layer = Opacity(
      opacity: MorphButtonConstants.kDisabledBackgroundAlpha,
      child: layer,
    );
  }
  return layer;
}

/// Builds a [ButtonLayerBuilder] that paints [gradient] behind the child.
///
/// When [explicitBuilder] is set, it wins. The result is always clipped to
/// [clipRadius] unless [explicitBuilder] is used (caller clips that path).
ButtonLayerBuilder? morphGradientBackgroundBuilder({
  required BorderRadius clipRadius,
  WidgetStateProperty<Gradient?>? gradient,
  ButtonLayerBuilder? explicitBuilder,
}) {
  if (explicitBuilder != null) {
    return (BuildContext context, Set<WidgetState> states, Widget? child) {
      return ClipRRect(
        borderRadius: clipRadius,
        child: explicitBuilder(context, states, child),
      );
    };
  }
  if (gradient == null) {
    return null;
  }
  return (BuildContext context, Set<WidgetState> states, Widget? child) {
    final Gradient? resolved = gradient.resolve(states);
    if (resolved == null) {
      return child ?? const SizedBox.shrink();
    }
    return morphGradientFillLayer(
      clipRadius: clipRadius,
      gradient: resolved,
      child: child,
      disabled: states.contains(WidgetState.disabled),
    );
  };
}
