import 'package:flutter/widgets.dart';
import 'package:material_ui/material_ui.dart' show Brightness, ColorScheme;

import '../color/morph_color_scheme.dart';
import 'morph_dynamic_color_host.dart';
import 'morph_resolved_theme.dart';
import 'morph_theme_controller.dart';
import 'morph_theme_data.dart';

/// Hosts adaptive theme listeners and resolves [MorphThemeData] for components.
class MorphThemeScope extends StatefulWidget {
  /// Creates an adaptive theme scope for [child].
  const MorphThemeScope({
    required this.baseData,
    required this.controller,
    required this.child,
    this.initialTheme,
    this.autoTheming,
    this.dynamicColoring,
    super.key,
  });

  /// Light-oriented template used to derive light/dark resolved themes.
  final MorphThemeData baseData;

  /// Manual brightness / invert controller for this scope.
  final MorphThemeController controller;

  /// The subtree under this adaptive scope.
  final Widget child;

  /// Initial brightness when not following the system.
  final Brightness? initialTheme;

  /// When true, follows platform brightness (with optional invert).
  final bool? autoTheming;

  /// When true, applies device dynamic color to the active scheme.
  final bool? dynamicColoring;

  /// Returns the nearest scope, if any.
  static MorphThemeScopeState? maybeOf(BuildContext context) {
    final _InheritedMorphThemeScope? inherited = context
        .getInheritedWidgetOfExactType<_InheritedMorphThemeScope>();
    return inherited?.scopeState;
  }

  /// Resolves theme from the nearest scope, or null when none is present.
  static MorphThemeData? resolveOf(BuildContext context) {
    return maybeOf(context)?.resolve(context);
  }

  /// Returns the nearest adaptive [MorphThemeController], if any.
  static MorphThemeController? controllerOf(BuildContext context) {
    return maybeOf(context)?.controller;
  }

  /// Resolves theme for a component, registering an inherited dependency.
  static MorphThemeData? resolveForComponent(BuildContext context) {
    final _InheritedMorphThemeScope? inherited = context
        .dependOnInheritedWidgetOfExactType<_InheritedMorphThemeScope>();
    return inherited?.resolve(context);
  }

  @override
  /// Creates the mutable state for this widget.
  State<MorphThemeScope> createState() => MorphThemeScopeState();
}

/// State for [MorphThemeScope] that resolves brightness and dynamic color.
class MorphThemeScopeState extends State<MorphThemeScope> {
  late MorphThemeData _cachedDarkTemplate;

  /// Light-oriented template from the widget.
  MorphThemeData get baseData => widget.baseData;

  /// Adaptive theme controller for this scope.
  MorphThemeController get controller => widget.controller;

  /// Initial brightness from the widget.
  Brightness? get initialTheme => widget.initialTheme;

  /// Whether platform brightness is followed.
  bool get autoTheming => widget.autoTheming ?? false;

  /// Whether device dynamic color is applied.
  bool get dynamicColoring => widget.dynamicColoring ?? false;

  /// Light template (same as [baseData]).
  MorphThemeData get lightTemplate => widget.baseData;

  /// Cached dark template derived from [baseData].
  MorphThemeData get darkTemplate => _cachedDarkTemplate;

  @override
  /// Caches the dark template derived from [baseData].
  void initState() {
    super.initState();
    _cachedDarkTemplate = widget.baseData.deriveDarkTemplate();
  }

  @override
  /// Refreshes the dark template when [baseData] changes.
  void didUpdateWidget(MorphThemeScope oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.baseData != widget.baseData) {
      _cachedDarkTemplate = widget.baseData.deriveDarkTemplate();
    }
  }

  /// Resolves effective brightness for the current adaptive rules.
  Brightness resolveBrightness(BuildContext context) {
    return widget.controller.resolveBrightness(
      MediaQuery.platformBrightnessOf(context),
      autoTheming: autoTheming,
      initialTheme: initialTheme,
    );
  }

  /// Resolves [MorphThemeData] for the current brightness and optional dynamics.
  MorphThemeData resolve(
    BuildContext context, {
    ColorScheme? lightDynamic,
    ColorScheme? darkDynamic,
  }) {
    final Brightness brightness = resolveBrightness(context);
    final MorphThemeData template = brightness == Brightness.dark
        ? darkTemplate
        : lightTemplate;

    if (!dynamicColoring) {
      return template;
    }

    final dynamicScheme = brightness == Brightness.dark
        ? darkDynamic
        : lightDynamic;
    if (dynamicScheme == null) {
      return template;
    }

    final ColorScheme harmonizedDynamic = dynamicScheme.harmonized();
    final MorphColorScheme morphScheme = MorphColorScheme.fromColorScheme(
      harmonizedDynamic,
    ).harmonized();

    return template.withColorScheme(morphScheme);
  }

  Widget _buildInheritedScope(
    BuildContext context, {
    ColorScheme? lightDynamic,
    ColorScheme? darkDynamic,
  }) {
    final Brightness? manualBrightness = widget.controller.brightnessOverride;
    final Brightness? platformBrightness = autoTheming
        ? MediaQuery.platformBrightnessOf(context)
        : null;
    final MorphThemeData resolved = resolve(
      context,
      lightDynamic: lightDynamic,
      darkDynamic: darkDynamic,
    );

    return _InheritedMorphThemeScope(
      scopeState: this,
      manualBrightness: manualBrightness,
      platformBrightness: platformBrightness,
      invertPlatformBrightness: widget.controller.invertPlatformBrightness,
      lightDynamic: lightDynamic,
      darkDynamic: darkDynamic,
      child: MorphResolvedTheme(data: resolved, child: widget.child),
    );
  }

  @override
  /// Builds the adaptive inherited scope, optionally with dynamic color.
  Widget build(BuildContext context) {
    if (dynamicColoring) {
      return MorphDynamicColorHost(
        builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
          return ListenableBuilder(
            listenable: widget.controller,
            builder: (BuildContext context, Widget? _) {
              return _buildInheritedScope(
                context,
                lightDynamic: lightDynamic,
                darkDynamic: darkDynamic,
              );
            },
          );
        },
      );
    }

    return ListenableBuilder(
      listenable: widget.controller,
      builder: (BuildContext context, Widget? _) {
        return _buildInheritedScope(context);
      },
    );
  }
}

class _InheritedMorphThemeScope extends InheritedWidget {
  const _InheritedMorphThemeScope({
    required this.scopeState,
    required this.manualBrightness,
    required this.platformBrightness,
    required this.invertPlatformBrightness,
    required this.lightDynamic,
    required this.darkDynamic,
    required super.child,
  });

  final MorphThemeScopeState scopeState;
  final Brightness? manualBrightness;
  final Brightness? platformBrightness;
  final bool invertPlatformBrightness;
  final ColorScheme? lightDynamic;
  final ColorScheme? darkDynamic;

  MorphThemeData resolve(BuildContext context) {
    return scopeState.resolve(
      context,
      lightDynamic: lightDynamic,
      darkDynamic: darkDynamic,
    );
  }

  @override
  bool updateShouldNotify(_InheritedMorphThemeScope oldWidget) {
    return scopeState != oldWidget.scopeState ||
        manualBrightness != oldWidget.manualBrightness ||
        platformBrightness != oldWidget.platformBrightness ||
        invertPlatformBrightness != oldWidget.invertPlatformBrightness ||
        lightDynamic != oldWidget.lightDynamic ||
        darkDynamic != oldWidget.darkDynamic;
  }
}
