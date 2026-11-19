import 'package:material_ui/material_ui.dart'
    show
        Brightness,
        BuildContext,
        Color,
        Directionality,
        Material,
        MaterialApp,
        MaterialType,
        MediaQuery,
        SizedBox,
        State,
        StatefulWidget,
        StatelessWidget,
        TextDirection,
        Theme,
        ThemeMode,
        ValueListenableBuilder,
        ValueNotifier,
        Widget,
        WidgetsBinding;
import 'package:morph_expressive/morph_expressive.dart';
import 'package:widgetbook/widgetbook.dart';

import '../themes/seed_presets.dart';

/// Brightness choices of the Morph scope.
enum MorphPreviewMode { light, dark, system }

/// Value selected through [MorphScopeAddon].
class MorphScopeSetting {
  const MorphScopeSetting({
    required this.mode,
    required this.seed,
    required this.seedName,
    required this.rtl,
    required this.reduceMotion,
    required this.highContrast,
    this.density = MorphDensity.standard,
  });

  final MorphPreviewMode mode;
  final Color seed;
  final String seedName;
  final bool rtl;
  final bool reduceMotion;
  final bool highContrast;

  /// Global layout density applied to the real [MorphThemeData].
  final MorphDensity density;

  @override
  bool operator ==(Object other) =>
      other is MorphScopeSetting &&
      other.mode == mode &&
      other.seed == seed &&
      other.rtl == rtl &&
      other.reduceMotion == reduceMotion &&
      other.highContrast == highContrast &&
      other.density == density;

  @override
  int get hashCode =>
      Object.hash(mode, seed, rtl, reduceMotion, highContrast, density);
}

/// The setting currently selected in the panel.
///
/// Morph dialogs push on the root navigator, which in the workbench belongs to
/// Widgetbook and sits above every use case. [MorphRootScope] listens to this
/// notifier and installs the same Morph theme there, so overlays opened through
/// the root navigator follow the selected seed and brightness as they do in an
/// application whose MorphMaterialApp wraps its Navigator.
final ValueNotifier<MorphScopeSetting?> activeMorphScope =
    ValueNotifier<MorphScopeSetting?>(null);

/// Wraps every use case in the real Morph scope.
///
/// A nested [MaterialApp] provides the Material [ThemeData] and a Navigator and
/// Overlay (dialogs, menus, sheets, tooltips and snackbars work as in an app),
/// and its builder installs [MorphTheme], [MorphMotionScope], text direction
/// and the high-contrast media flag. The brightness, seed colour (preset or
/// custom hex), text direction, reduced motion and high contrast are
/// selectable from the Widgetbook panel.
class MorphScopeAddon extends WidgetbookAddon<MorphScopeSetting> {
  MorphScopeAddon() : super(name: 'Morph');

  static const _densityLabels = {
    MorphDensity.compact: 'Compact',
    MorphDensity.standard: 'Standard',
    MorphDensity.comfortable: 'Comfortable',
  };

  static const _modeLabels = {
    MorphPreviewMode.light: 'Light',
    MorphPreviewMode.dark: 'Dark',
    MorphPreviewMode.system: 'System',
  };

  @override
  List<Field> get fields => [
    ObjectDropdownField<MorphPreviewMode>(
      name: 'mode',
      values: MorphPreviewMode.values,
      initialValue: MorphPreviewMode.light,
      labelBuilder: (mode) => _modeLabels[mode]!,
    ),
    ObjectDropdownField<String>(
      name: 'seed',
      values: morphSeedPresets.keys.toList(),
      initialValue: morphDefaultSeedName,
    ),
    ObjectDropdownField<MorphDensity>(
      name: 'density',
      values: MorphDensity.values,
      initialValue: MorphDensity.standard,
      labelBuilder: (density) => _densityLabels[density]!,
    ),
    StringField(name: 'custom hex'),
    BooleanField(name: 'rtl', initialValue: false),
    BooleanField(name: 'reduced motion', initialValue: false),
    BooleanField(name: 'high contrast', initialValue: false),
  ];

  @override
  MorphScopeSetting valueFromQueryGroup(Map<String, String> group) {
    final seedName = valueOf<String>('seed', group) ?? morphDefaultSeedName;
    final custom = valueOf<String>('custom hex', group) ?? '';
    return MorphScopeSetting(
      mode: valueOf<MorphPreviewMode>('mode', group) ?? MorphPreviewMode.light,
      seed: resolveSeed(seedName, custom),
      seedName: seedName,
      rtl: valueOf<bool>('rtl', group) ?? false,
      reduceMotion: valueOf<bool>('reduced motion', group) ?? false,
      highContrast: valueOf<bool>('high contrast', group) ?? false,
      density: valueOf<MorphDensity>('density', group) ?? MorphDensity.standard,
    );
  }

  @override
  Widget buildUseCase(
    BuildContext context,
    Widget child,
    MorphScopeSetting setting,
  ) => MorphScope(setting: setting, child: child);
}

/// Real Morph + Material scope for one use case.
class MorphScope extends StatefulWidget {
  const MorphScope({super.key, required this.setting, required this.child});

  final MorphScopeSetting setting;
  final Widget child;

  @override
  State<MorphScope> createState() => _MorphScopeState();
}

class _MorphScopeState extends State<MorphScope> {
  @override
  void initState() {
    super.initState();
    _publish();
  }

  @override
  void didUpdateWidget(MorphScope oldWidget) {
    super.didUpdateWidget(oldWidget);
    _publish();
  }

  void _publish() {
    final setting = widget.setting;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (activeMorphScope.value != setting) activeMorphScope.value = setting;
    });
  }

  @override
  Widget build(BuildContext context) {
    final setting = widget.setting;
    final child = widget.child;
    final light = buildMorphTheme(
      setting.seed,
      Brightness.light,
      reduceMotion: setting.reduceMotion,
      density: setting.density,
    );
    final dark = buildMorphTheme(
      setting.seed,
      Brightness.dark,
      reduceMotion: setting.reduceMotion,
      density: setting.density,
    );
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Morph Expressive',
      // Switching brightness or seed in the panel is instant.
      themeAnimationDuration: Duration.zero,
      theme: light.toThemeData(),
      darkTheme: dark.toThemeData(),
      themeMode: switch (setting.mode) {
        MorphPreviewMode.light => ThemeMode.light,
        MorphPreviewMode.dark => ThemeMode.dark,
        MorphPreviewMode.system => ThemeMode.system,
      },
      builder: (context, app) {
        final brightness = Theme.of(context).brightness;
        final data = brightness == Brightness.dark ? dark : light;
        final media = MediaQuery.of(context);
        return Directionality(
          textDirection: setting.rtl ? TextDirection.rtl : TextDirection.ltr,
          child: MediaQuery(
            data: media.copyWith(highContrast: setting.highContrast),
            child: MorphMotionScope(
              reduceMotion: setting.reduceMotion,
              child: MorphTheme(
                data: data,
                child: app ?? const SizedBox.shrink(),
              ),
            ),
          ),
        );
      },
      home: Material(type: MaterialType.transparency, child: child),
    );
  }
}

/// Installs the active Morph theme above the workbench's root navigator.
class MorphRootScope extends StatelessWidget {
  const MorphRootScope({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<MorphScopeSetting?>(
      valueListenable: activeMorphScope,
      child: child,
      builder: (context, setting, child) {
        if (setting == null) return child!;
        final brightness = switch (setting.mode) {
          MorphPreviewMode.light => Brightness.light,
          MorphPreviewMode.dark => Brightness.dark,
          MorphPreviewMode.system => MediaQuery.platformBrightnessOf(context),
        };
        return MorphMotionScope(
          reduceMotion: setting.reduceMotion,
          child: MorphTheme(
            data: buildMorphTheme(
              setting.seed,
              brightness,
              reduceMotion: setting.reduceMotion,
              density: setting.density,
            ),
            child: child!,
          ),
        );
      },
    );
  }
}
