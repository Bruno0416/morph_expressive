import 'package:material_ui/material_ui.dart';

/// Tints [child] with [gradient] via [BlendMode.srcIn], clipped to [clipRadius].
Widget morphGradientForegroundLayer({
  required BorderRadius clipRadius,
  required Gradient gradient,
  required Widget child,
}) {
  return ClipRRect(
    borderRadius: clipRadius,
    child: ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (Rect bounds) => gradient.createShader(bounds),
      child: child,
    ),
  );
}

/// Builds a [ButtonLayerBuilder] that applies [gradient] to foreground content.
///
/// When [explicitBuilder] is set, it wins (still clipped to [clipRadius]).
ButtonLayerBuilder? morphGradientForegroundBuilder({
  required BorderRadius clipRadius,
  WidgetStateProperty<Gradient?>? gradient,
  ButtonLayerBuilder? explicitBuilder,
}) {
  if (explicitBuilder != null) {
    return (BuildContext context, Set<WidgetState> states, Widget? child) {
      return ClipRRect(
        borderRadius: clipRadius,
        child: explicitBuilder(
          context,
          states,
          child ?? const SizedBox.shrink(),
        ),
      );
    };
  }
  if (gradient == null) {
    return null;
  }
  return (BuildContext context, Set<WidgetState> states, Widget? child) {
    final Gradient? resolved = gradient.resolve(states);
    final Widget content = child ?? const SizedBox.shrink();
    if (resolved == null) {
      return content;
    }
    return morphGradientForegroundLayer(
      clipRadius: clipRadius,
      gradient: resolved,
      child: content,
    );
  };
}

/// Opaque white so BlendMode.srcIn shows the gradient as the content color.
const Color morphGradientForegroundSourceColor = Color(0xFFFFFFFF);
