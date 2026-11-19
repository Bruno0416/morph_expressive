import 'package:material_ui/material_ui.dart'
    show
        BuildContext,
        Color,
        EdgeInsets,
        MaterialApp,
        Padding,
        ScrollConfiguration,
        SizedBox,
        State,
        StatefulWidget,
        StatelessWidget,
        Text,
        ThemeMode,
        Widget,
        runApp;
import 'package:morph_expressive/morph_expressive.dart';
import 'package:widgetbook/widgetbook.dart' show Widgetbook;
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import 'main.directories.g.dart';
import 'widgetbook/addons/morph_scope_addon.dart' show MorphRootScope;
import 'widgetbook/app/morph_widgetbook_config.dart';
import 'component_gif_capture.dart';
import 'mobile_frosted_surfaces_lab.dart';
import 'frosted_blur_benchmark_lab.dart';
import 'aa_probe.dart';
import 'edge_stress.dart';
import 'native_check.dart';
import 'shape_morph_lab.dart';
import 'operation_loading_lab.dart';
import 'tabs_lab.dart';

void main() {
  if (const bool.fromEnvironment('MORPH_FROSTED_BENCHMARK')) {
    runApp(const MorphFrostedBlurBenchmarkLab());
    return;
  }
  const nativeCheck = String.fromEnvironment('MORPH_NATIVE_CHECK');
  if (nativeCheck.isNotEmpty) {
    runApp(const NativeCheckApp(mode: nativeCheck));
    return;
  }
  if (const bool.fromEnvironment('MORPH_AA_PROBE')) {
    runApp(const AaProbeApp());
    return;
  }
  if (const bool.fromEnvironment('MORPH_EDGE_STRESS')) {
    runApp(const EdgeStressApp());
    return;
  }
  final capture = Uri.base.queryParameters['capture'];
  if (Uri.base.queryParameters['lab'] == 'operations' ||
      const String.fromEnvironment('MORPH_LAB') == 'operations') {
    runApp(const MorphPreviewApp(operationLab: true));
    return;
  }
  if (Uri.base.queryParameters['lab'] == 'tabs' ||
      const String.fromEnvironment('MORPH_LAB') == 'tabs') {
    runApp(const MorphPreviewApp(tabsLab: true));
    return;
  }
  if (capture != null) {
    runApp(MorphGifCaptureApp(scene: capture));
    return;
  }
  final lab = Uri.base.queryParameters['lab'];
  const envLab = String.fromEnvironment('MORPH_LAB');
  if (lab == 'shapes' || envLab == 'shapes') {
    runApp(const MorphPreviewApp(shapeLab: true));
    return;
  }
  runApp(const MorphWidgetbookApp());
}

/// Widgetbook catalog of every Morph Expressive component family.
///
/// Use cases live in `lib/widgetbook/use_cases/<category>/` and are collected
/// by `build_runner` into `main.directories.g.dart`.
@widgetbook.App()
class MorphWidgetbookApp extends StatelessWidget {
  const MorphWidgetbookApp({super.key, this.initialRoute = '/'});

  /// Deep link into the catalog, e.g. `/?path=actions/buttons`.
  final String initialRoute;

  @override
  Widget build(BuildContext context) {
    return MorphRootScope(
      child: Widgetbook(
        directories: directories,
        initialRoute: initialRoute,
        addons: morphWidgetbookAddons(),
        appBuilder: morphWidgetbookAppBuilder,
        header: const Padding(
          padding: EdgeInsets.all(12),
          child: Text('Morph Expressive'),
        ),
      ),
    );
  }
}

/// Standalone host for the lab screens (shapes, tabs, operations, mobile glass).
///
/// The component catalog itself is [MorphWidgetbookApp]; this app only hosts
/// the labs that are launched directly with `?lab=...` or `MORPH_LAB=...`.
class MorphPreviewApp extends StatefulWidget {
  const MorphPreviewApp({
    super.key,
    this.mobileLab = false,
    this.shapeLab = false,
    this.operationLab = false,
    this.tabsLab = false,
  });
  final bool shapeLab;
  final bool tabsLab;
  final bool operationLab;

  /// Opens the touch-first glass preview.
  final bool mobileLab;

  @override
  State<MorphPreviewApp> createState() => _MorphPreviewAppState();
}

class _MorphPreviewAppState extends State<MorphPreviewApp> {
  bool _darkMode = true;
  Color _seed = const Color(0xFF6750A4);
  bool _hapticsEnabled = true;
  MorphHapticFeedback _hapticFeedback = MorphHapticFeedback.light;
  bool _glassEnabled = true;
  double _glassBlur = 12;
  double _glassTint = 0.65;

  @override
  Widget build(BuildContext context) {
    final floatingGlass = widget.mobileLab
        ? MorphSurfaceGlass(
            enabled: _glassEnabled,
            blurX: _glassBlur,
            blurY: _glassBlur,
            tintOpacity: _glassTint,
          )
        : null;
    final light = MorphThemeData.light(seedColor: _seed).copyWith(
      hapticsEnabled: _hapticsEnabled,
      hapticFeedback: _hapticFeedback,
      floatingSurfaceGlass: floatingGlass,
    );
    final dark = MorphThemeData.dark(seedColor: _seed).copyWith(
      hapticsEnabled: _hapticsEnabled,
      hapticFeedback: _hapticFeedback,
      floatingSurfaceGlass: floatingGlass,
    );
    final current = _darkMode ? dark : light;

    return MaterialApp(
      title: 'Morph Expressive — Component Studio',
      debugShowCheckedModeBanner: false,
      theme: light.toThemeData(),
      darkTheme: dark.toThemeData(),
      themeMode: _darkMode ? ThemeMode.dark : ThemeMode.light,
      builder: (context, child) => MorphTheme(
        data: current,
        child: widget.mobileLab
            ? ScrollConfiguration(
                behavior: const MorphScrollBehavior(),
                child: child ?? const SizedBox.shrink(),
              )
            : child ?? const SizedBox.shrink(),
      ),
      home: widget.tabsLab
          ? TabsLab(onToggleTheme: () => setState(() => _darkMode = !_darkMode))
          : widget.operationLab
          ? OperationLoadingLab(
              onToggleTheme: () => setState(() => _darkMode = !_darkMode),
            )
          : widget.shapeLab
          ? ShapeMorphLab(
              onToggleTheme: () => setState(() => _darkMode = !_darkMode),
              onSeedChanged: (color) => setState(() => _seed = color),
            )
          : widget.mobileLab
          ? MorphFrostedSurfacesLab(
              darkMode: _darkMode,
              onToggleTheme: () => setState(() => _darkMode = !_darkMode),
              glassEnabled: _glassEnabled,
              onGlassEnabledChanged: (value) =>
                  setState(() => _glassEnabled = value),
              blur: _glassBlur,
              onBlurChanged: (value) => setState(() => _glassBlur = value),
              tintOpacity: _glassTint,
              onTintOpacityChanged: (value) =>
                  setState(() => _glassTint = value),
              hapticsEnabled: _hapticsEnabled,
              hapticFeedback: _hapticFeedback,
              onHapticsEnabledChanged: (value) =>
                  setState(() => _hapticsEnabled = value),
              onHapticFeedbackChanged: (value) => setState(() {
                _hapticFeedback = value;
                _hapticsEnabled = true;
              }),
            )
          : ShapeMorphLab(
              onToggleTheme: () => setState(() => _darkMode = !_darkMode),
              onSeedChanged: (color) => setState(() => _seed = color),
            ),
    );
  }
}
