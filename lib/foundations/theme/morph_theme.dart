import 'package:flutter/widgets.dart';
import 'package:material_ui/material_ui.dart' show Theme;

import 'morph_resolved_theme.dart';
import 'morph_theme_controller.dart';
import 'morph_theme_data.dart';
import 'morph_theme_scope.dart';

export '../components/morph_component_theme.dart';
export 'morph_resolved_theme.dart';
export 'morph_theme_controller.dart';
export 'morph_theme_data.dart';
export 'morph_theme_scope.dart';

/// Provides an [MorphThemeData] to the widget subtree.
///
/// At the app entry point, pass [initialTheme], [autoTheming], [dynamicColoring],
/// and an optional [controller] to enable adaptive theming. Nested instances
/// that only pass [data] continue to provide a static local override.
class MorphTheme extends StatefulWidget {
  /// Creates an expressive theme provider for [child].
  const MorphTheme({
    required this.data,
    required this.child,
    this.initialTheme,
    this.autoTheming,
    this.dynamicColoring,
    this.controller,
    super.key,
  });

  /// Theme tokens and component themes for this subtree.
  final MorphThemeData data;

  /// The subtree under this theme.
  final Widget child;

  /// Initial brightness when adaptive theming is enabled.
  final Brightness? initialTheme;

  /// When true, follows platform brightness (with optional invert via
  /// [controller]).
  final bool? autoTheming;

  /// When true, applies device dynamic color to the active scheme.
  final bool? dynamicColoring;

  /// Optional controller for manual brightness overrides.
  final MorphThemeController? controller;

  /// Whether this instance should host an adaptive [MorphThemeScope].
  bool get usesAdaptiveScope =>
      initialTheme != null ||
      (autoTheming ?? false) ||
      (dynamicColoring ?? false) ||
      controller != null;

  /// Returns the nearest expressive theme, or derives one from Material.
  static MorphThemeData of(BuildContext context) {
    final MorphInheritedTheme? inherited = context
        .dependOnInheritedWidgetOfExactType<MorphInheritedTheme>();
    if (inherited != null) {
      return inherited.data;
    }
    MorphThemeScope.resolveForComponent(context);
    final MorphThemeData? scoped = MorphThemeScope.resolveOf(context);
    if (scoped != null) {
      return scoped;
    }
    return MorphThemeData.fromMaterial(Theme.of(context));
  }

  /// Returns the nearest expressive theme, or null if none is found.
  static MorphThemeData? maybeOf(BuildContext context) {
    final MorphInheritedTheme? inherited = context
        .getInheritedWidgetOfExactType<MorphInheritedTheme>();
    if (inherited != null) {
      return inherited.data;
    }
    return MorphThemeScope.resolveOf(context);
  }

  /// Returns the nearest adaptive [MorphThemeController], if any.
  static MorphThemeController? controllerOf(BuildContext context) {
    return MorphThemeScope.controllerOf(context);
  }

  /// Brightness from the nearest [MorphTheme], else platform brightness.
  static Brightness brightnessOf(BuildContext context) {
    return maybeOf(context)?.brightness ??
        MediaQuery.platformBrightnessOf(context);
  }

  /// Platform from the nearest [MorphTheme], else [Theme] or default.
  static TargetPlatform platformOf(BuildContext context) {
    final MorphThemeData? theme = maybeOf(context);
    if (theme?.platform != null) {
      return theme!.platform!;
    }
    return Theme.of(context).platform;
  }

  @override
  /// Creates the mutable state for this widget.
  State<MorphTheme> createState() => _MorphThemeState();
}

class _MorphThemeState extends State<MorphTheme> {
  MorphThemeController? _internalController;

  MorphThemeController get _effectiveController =>
      widget.controller ?? (_internalController ??= MorphThemeController());

  @override
  Widget build(BuildContext context) {
    if (widget.usesAdaptiveScope) {
      return MorphThemeScope(
        baseData: widget.data,
        initialTheme: widget.initialTheme,
        autoTheming: widget.autoTheming,
        dynamicColoring: widget.dynamicColoring,
        controller: _effectiveController,
        child: widget.child,
      );
    }

    return MorphResolvedTheme(data: widget.data, child: widget.child);
  }
}
