import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:material_ui/material_ui.dart'
    show Brightness, Color, ColorScheme;

/// Builds a subtree from device light and dark dynamic [ColorScheme]s.
typedef MorphDynamicColorBuilder = Widget Function(
  ColorScheme? lightDynamic,
  ColorScheme? darkDynamic,
);

/// Fetches device dynamic colors and refreshes them when the app resumes.
///
/// Prefers Android's core palette: extracts its primary color and builds light
/// and dark [ColorScheme]s via [ColorScheme.fromSeed]. Falls back to
/// [DynamicColorPlugin.getAccentColor] on platforms that expose an accent
/// color (desktop) or when the core palette is unavailable.
///
/// Re-fetches on [AppLifecycleState.resumed] so OS color changes apply without
/// restarting the app.
class MorphDynamicColorHost extends StatefulWidget {
  /// Creates a host that supplies dynamic color schemes to [builder].
  const MorphDynamicColorHost({required this.builder, super.key});

  /// Builds the subtree from the latest light/dark dynamic schemes.
  final MorphDynamicColorBuilder builder;

  @override
  /// Creates the mutable state for this widget.
  State<MorphDynamicColorHost> createState() => _MorphDynamicColorHostState();
}

class _MorphDynamicColorHostState extends State<MorphDynamicColorHost>
    with WidgetsBindingObserver {
  ColorScheme? _light;
  ColorScheme? _dark;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _fetchDynamicColors();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _fetchDynamicColors();
    }
  }

  void _applySeed(Color seed) {
    setState(() {
      _light = ColorScheme.fromSeed(seedColor: seed);
      _dark = ColorScheme.fromSeed(
        seedColor: seed,
        brightness: Brightness.dark,
      );
    });
  }

  void _debugLog(String message) {
    if (kDebugMode) {
      debugPrint(message);
    }
  }

  /// Returns true when fetching should stop (applied or unmounted).
  Future<bool> _tryApplyCorePalette() async {
    try {
      final corePalette = await DynamicColorPlugin.getCorePalette();
      if (!mounted) {
        return true;
      }
      if (corePalette == null) {
        return false;
      }
      final Color seed = corePalette.toColorScheme().primary;
      _debugLog('dynamic_color: Core palette primary seed detected.');
      _applySeed(seed);
      return true;
    } on PlatformException {
      _debugLog('dynamic_color: Failed to obtain core palette.');
      return false;
    }
  }

  /// Returns true when fetching should stop (applied or unmounted).
  Future<bool> _tryApplyAccentColor() async {
    try {
      final Color? accentColor = await DynamicColorPlugin.getAccentColor();
      if (!mounted) {
        return true;
      }
      if (accentColor == null) {
        return false;
      }
      _debugLog('dynamic_color: Accent color detected.');
      _applySeed(accentColor);
      return true;
    } on PlatformException {
      _debugLog('dynamic_color: Failed to obtain accent color.');
      return false;
    }
  }

  Future<void> _fetchDynamicColors() async {
    if (await _tryApplyCorePalette()) {
      return;
    }
    if (await _tryApplyAccentColor()) {
      return;
    }
    _debugLog('dynamic_color: Dynamic color not detected on this device.');
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(_light, _dark);
  }
}
