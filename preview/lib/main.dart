import 'package:gap/gap.dart';
import 'package:material_ui/material_ui.dart';
import 'package:morph_expressive/morph_expressive.dart';

import 'component_gallery.dart';
import 'component_gif_capture.dart';
import 'mobile_haptics_lab.dart';

void main() {
  final capture = Uri.base.queryParameters['capture'];
  if (capture != null) {
    runApp(MorphGifCaptureApp(scene: capture));
  } else {
    runApp(const MorphPreviewApp());
  }
}

/// Aplicacion de preview web para evaluar los widgets Morph.
class MorphPreviewApp extends StatefulWidget {
  const MorphPreviewApp({super.key, this.mobileLab = false});

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

  @override
  Widget build(BuildContext context) {
    final fontTheme = _useSerif
        ? ThemeData().textTheme.apply(fontFamily: 'serif')
        : null;
    final light = MorphThemeData.light(seedColor: _seed, textTheme: fontTheme)
        .copyWith(
          hapticsEnabled: _hapticsEnabled,
          hapticFeedback: _hapticFeedback,
        );
    final dark = MorphThemeData.dark(seedColor: _seed, textTheme: fontTheme)
        .copyWith(
          hapticsEnabled: _hapticsEnabled,
          hapticFeedback: _hapticFeedback,
        );
    final current = _darkMode ? dark : light;
    final scheme = current.colorScheme;

    return MaterialApp(
      title: 'Morph Expressive — Component Studio',
      debugShowCheckedModeBanner: false,
      theme: light.toThemeData(),
      darkTheme: dark.toThemeData(),
      themeMode: _darkMode ? ThemeMode.dark : ThemeMode.light,
      builder: (context, child) =>
          MorphTheme(data: current, child: child ?? const SizedBox.shrink()),
      home: widget.mobileLab
          ? MorphMobileHapticsLab(
              hapticsEnabled: _hapticsEnabled,
              hapticFeedback: _hapticFeedback,
              onHapticsEnabledChanged: (value) =>
                  setState(() => _hapticsEnabled = value),
              onHapticFeedbackChanged: (value) => setState(() {
                _hapticFeedback = value;
                _hapticsEnabled = true;
              }),
              darkMode: _darkMode,
              onToggleTheme: () => setState(() => _darkMode = !_darkMode),
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
                  PopupMenuButton<MorphHapticFeedback>(
                    tooltip: 'Haptic settings',
                    icon: Icon(FluentIcons.line.settings, size: 22),
                    initialValue: _hapticsEnabled
                        ? _hapticFeedback
                        : MorphHapticFeedback.none,
                    onSelected: (value) => setState(() {
                      if (value == MorphHapticFeedback.none) {
                        _hapticsEnabled = false;
                      } else {
                        _hapticsEnabled = true;
                        _hapticFeedback = value;
                      }
                    }),
                    itemBuilder: (context) => [
                      const PopupMenuItem<MorphHapticFeedback>(
                        enabled: false,
                        child: Text('Haptics · try on a physical device'),
                      ),
                      const PopupMenuItem(
                        value: MorphHapticFeedback.none,
                        child: Text('Off'),
                      ),
                      const PopupMenuItem(
                        value: MorphHapticFeedback.light,
                        child: Text('Light'),
                      ),
                      const PopupMenuItem(
                        value: MorphHapticFeedback.medium,
                        child: Text('Medium'),
                      ),
                      const PopupMenuItem(
                        value: MorphHapticFeedback.heavy,
                        child: Text('Heavy'),
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
                  IconButton(
                    tooltip: 'Switch theme',
                    onPressed: () => setState(() => _darkMode = !_darkMode),
                    icon: Icon(
                      _darkMode
                          ? FluentIcons.line.weather_sunny
                          : FluentIcons.line.weather_moon,
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
