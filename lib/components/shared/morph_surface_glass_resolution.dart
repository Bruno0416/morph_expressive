import 'package:flutter/widgets.dart';

import '../../foundations/foundations.dart';

/// Resolves the frosted configuration for an in-flow component.
///
/// Returns null when the component keeps its opaque paint.
///
/// - An explicit [glass] wins (a disabled one yields null).
/// - Otherwise [MorphSurface.solid] yields null.
/// - [MorphSurface.frosted] uses the enabled
///   [MorphThemeData.floatingSurfaceGlass] and falls back to the default
///   [MorphSurfaceGlass], because asking for a frosted surface on the widget
///   is an explicit request that must not depend on app-level configuration.
MorphSurfaceGlass? morphResolveSurfaceGlass(
  BuildContext context,
  MorphSurface surface, {
  MorphSurfaceGlass? glass,
}) {
  if (glass != null) {
    return glass.enabled ? glass : null;
  }
  if (!surface.isFrosted) {
    return null;
  }
  final MorphSurfaceGlass? themed = MorphTheme.of(context).floatingSurfaceGlass;
  return themed != null && themed.enabled ? themed : const MorphSurfaceGlass();
}

/// Returns [color], or [fallback] when [color] is fully transparent.
///
/// Frosted surfaces derive their tint from a semantic color; transparent
/// component types (outlined, text) borrow a neutral surface so the glass is
/// visible.
Color morphGlassBaseColor(Color color, Color fallback) =>
    color.a == 0 ? fallback : color;

/// Raises [glass]'s tint opacity until [content] stays legible on the tint.
///
/// A frosted tint is composited over an unknown, blurred backdrop. The worst
/// cases are a white and a black backdrop, so the tint opacity is raised (in
/// 0.02 steps, never lowered) until [content] reaches [minContrast] against
/// [base] blended over both. Content that already contrasts strongly with its
/// surface (for example `onSurface` on a neutral tint) keeps the configured
/// translucency; colored content on colored fills gets a denser tint.
MorphSurfaceGlass morphLegibleGlass(
  MorphSurfaceGlass glass, {
  required Color base,
  required Color content,
  double minContrast = 4.5,
}) {
  if (!glass.enabled || glass.tint != null) {
    return glass;
  }
  const Color white = Color(0xFFFFFFFF);
  const Color black = Color(0xFF000000);
  final Color solidContent = content.withValues(alpha: 1);
  bool legible(double opacity) {
    final double alpha = base.a * opacity;
    for (final Color backdrop in const <Color>[white, black]) {
      final Color tint = Color.alphaBlend(
        base.withValues(alpha: alpha),
        backdrop,
      );
      if (_contrast(tint, solidContent) < minContrast) {
        return false;
      }
    }
    return true;
  }

  double opacity = glass.tintOpacity;
  while (opacity < 1 && !legible(opacity)) {
    opacity = (opacity + 0.02).clamp(0, 1).toDouble();
  }
  return opacity == glass.tintOpacity
      ? glass
      : glass.copyWith(tintOpacity: opacity);
}

double _contrast(Color a, Color b) {
  final double la = a.computeLuminance();
  final double lb = b.computeLuminance();
  final double hi = la > lb ? la : lb;
  final double lo = la > lb ? lb : la;
  return (hi + 0.05) / (lo + 0.05);
}
