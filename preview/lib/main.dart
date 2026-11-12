import 'package:gap/gap.dart';
import 'package:material_ui/material_ui.dart'
    show
        Alignment,
        AppBar,
        BoxFit,
        BuildContext,
        Builder,
        Color,
        FittedBox,
        Flexible,
        Icon,
        IconButton,
        Navigator,
        MainAxisSize,
        MaterialApp,
        MaterialPageRoute,
        Row,
        Scaffold,
        ScrollConfiguration,
        SizedBox,
        State,
        StatefulWidget,
        Text,
        ThemeData,
        ThemeMode,
        Widget,
        runApp;
import 'package:morph_expressive/morph_expressive.dart';

import 'component_gallery.dart';
import 'component_gif_capture.dart';
import 'mobile_frosted_surfaces_lab.dart';
import 'desktop_context_menu_lab.dart';
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
  } else {
    runApp(
      MorphPreviewApp(
        shapeLab:
            Uri.base.queryParameters['lab'] == 'shapes' ||
            const String.fromEnvironment('MORPH_LAB') == 'shapes',
      ),
    );
  }
}

/// Aplicacion de preview web para evaluar los widgets Morph.
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

  /// Opens the touch-first preview without changing the existing web gallery.
  final bool mobileLab;

  @override
  State<MorphPreviewApp> createState() => _MorphPreviewAppState();
}

class _MorphPreviewAppState extends State<MorphPreviewApp> {
  bool _darkMode = true;
  Color _seed = const Color(0xFF6750A4);
  bool _useSerif = false;
  bool _hapticsEnabled = true;
  MorphHapticFeedback _hapticFeedback = MorphHapticFeedback.light;
  bool _glassEnabled = true;
  double _glassBlur = 12;
  double _glassTint = 0.65;

  @override
  Widget build(BuildContext context) {
    final fontTheme = _useSerif
        ? ThemeData().textTheme.apply(fontFamily: 'serif')
        : null;
    final floatingGlass = widget.mobileLab
        ? MorphSurfaceGlass(
            enabled: _glassEnabled,
            blurX: _glassBlur,
            blurY: _glassBlur,
            tintOpacity: _glassTint,
          )
        : null;
    final light = MorphThemeData.light(seedColor: _seed, textTheme: fontTheme)
        .copyWith(
          hapticsEnabled: _hapticsEnabled,
          hapticFeedback: _hapticFeedback,
          floatingSurfaceGlass: floatingGlass,
        );
    final dark = MorphThemeData.dark(seedColor: _seed, textTheme: fontTheme)
        .copyWith(
          hapticsEnabled: _hapticsEnabled,
          hapticFeedback: _hapticFeedback,
          floatingSurfaceGlass: floatingGlass,
        );
    final current = _darkMode ? dark : light;
    final scheme = current.colorScheme;

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
          : Scaffold(
              backgroundColor: scheme.surface,
              appBar: AppBar(
                backgroundColor: scheme.surfaceContainer,
                foregroundColor: scheme.onSurface,
                title: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(FluentIcons.filled.shapes, size: 24),
                    Gap(12),
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text('Morph Expressive'),
                      ),
                    ),
                  ],
                ),
                actions: [
                  Builder(
                    builder: (buttonContext) => IconButton(
                      tooltip: 'Tabs Lab',
                      icon: Icon(FluentIcons.line.tab_desktop),
                      onPressed: () => Navigator.of(buttonContext).push(
                        MaterialPageRoute<void>(
                          builder: (_) => TabsLab(
                            onToggleTheme: () =>
                                setState(() => _darkMode = !_darkMode),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Builder(
                    builder: (buttonContext) => IconButton(
                      tooltip: 'Operation & Skeleton Lab',
                      icon: Icon(FluentIcons.line.arrow_sync),
                      onPressed: () => Navigator.of(buttonContext).push(
                        MaterialPageRoute<void>(
                          builder: (_) => OperationLoadingLab(
                            onToggleTheme: () =>
                                setState(() => _darkMode = !_darkMode),
                          ),
                        ),
                      ),
                    ),
                  ),
                  MorphMenu(
                    anchorBuilder: (buttonContext, open) => IconButton(
                      tooltip: 'Haptic settings',
                      icon: Icon(FluentIcons.line.settings, size: 22),
                      onPressed: open,
                    ),
                    selectedValue: _hapticsEnabled
                        ? _hapticFeedback
                        : MorphHapticFeedback.none,
                    onSelected: (value) {
                      if (value is! MorphHapticFeedback) return;
                      setState(() {
                        if (value == MorphHapticFeedback.none) {
                          _hapticsEnabled = false;
                        } else {
                          _hapticsEnabled = true;
                          _hapticFeedback = value;
                        }
                      });
                    },
                    children: const <MorphMenuNode>[
                      MorphMenuEntry(
                        label: 'Haptics · try on a physical device',
                        enabled: false,
                      ),
                      MorphMenuSelectable(
                        label: 'Off',
                        value: MorphHapticFeedback.none,
                      ),
                      MorphMenuSelectable(
                        label: 'Light',
                        value: MorphHapticFeedback.light,
                      ),
                      MorphMenuSelectable(
                        label: 'Medium',
                        value: MorphHapticFeedback.medium,
                      ),
                      MorphMenuSelectable(
                        label: 'Heavy',
                        value: MorphHapticFeedback.heavy,
                      ),
                    ],
                  ),
                  MorphTooltip(
                    message: 'Toggle typography',
                    child: IconButton(
                      tooltip: 'Toggle typography',
                      onPressed: () => setState(() => _useSerif = !_useSerif),
                      icon: Icon(FluentIcons.line.text_font, size: 22),
                    ),
                  ),
                  Builder(
                    builder: (buttonContext) => IconButton(
                      tooltip: 'Desktop context menu preview',
                      onPressed: () => Navigator.of(buttonContext).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const DesktopContextMenuLab(),
                        ),
                      ),
                      icon: Icon(
                        FluentIcons.line.panel_right_contract,
                        size: 22,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Switch theme',
                    onPressed: () => setState(() => _darkMode = !_darkMode),
                    icon: Icon(
                      _darkMode
                          ? FluentIcons.line.weather_sunny
                          : FluentIcons.line.weather_moon,
                    ),
                  ),
                  Builder(
                    builder: (buttonContext) => IconButton(
                      tooltip: 'Shape & Interaction Lab',
                      icon: Icon(FluentIcons.line.shapes),
                      onPressed: () => Navigator.of(buttonContext).push(
                        MaterialPageRoute<void>(
                          builder: (_) => ShapeMorphLab(
                            onToggleTheme: () =>
                                setState(() => _darkMode = !_darkMode),
                            onSeedChanged: (c) => setState(() => _seed = c),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const Gap(12),
                ],
              ),
              body: MorphComponentGallery(
                seed: _seed,
                onSeedChanged: (color) => setState(() => _seed = color),
              ),
            ),
    );
  }
}
