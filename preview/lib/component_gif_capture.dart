import 'dart:async';

import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter/gestures.dart';
import 'package:material_ui/material_ui.dart'
    show
        Align,
        BorderRadius,
        BoxDecoration,
        Center,
        Container,
        EdgeInsets,
        Expanded,
        GlobalKey,
        Offset,
        Padding,
        RenderBox,
        Alignment,
        ValueChanged,
        MainAxisAlignment,
        BuildContext,
        Color,
        Column,
        CrossAxisAlignment,
        FocusManager,
        FocusNode,
        Icon,
        MaterialApp,
        Navigator,
        Positioned,
        Row,
        Scaffold,
        SizedBox,
        Stack,
        State,
        TextBaseline,
        StatefulWidget,
        StatelessWidget,
        Text,
        TextEditingController,
        TextStyle,
        ValueKey,
        VoidCallback,
        Widget,
        WidgetsBinding,
        Wrap;
import 'package:morph_expressive/components/chips/morph_chip_organic_surface.dart'
    show MorphChipOrganicSurface;
import 'package:morph_expressive/morph_expressive.dart';

/// Escenas aisladas para generar los GIFs del README con Playwright.
///
/// Ejemplo: /?capture=dropdown&theme=teal&delayMs=950
/// Cada escena ejecuta las transiciones desde Flutter, sin clicks ni cursor.
class MorphGifCaptureApp extends StatelessWidget {
  const MorphGifCaptureApp({required this.scene, super.key});

  final String scene;

  static const Map<String, Color> _captureSeeds = {
    'purple': Color(0xFF6750A4),
    'teal': Color(0xFF006B5E),
    'blue': Color(0xFF3867D6),
  };

  @override
  Widget build(BuildContext context) {
    final themeName = Uri.base.queryParameters['theme'] ?? 'purple';
    final seed = _captureSeeds[themeName] ?? const Color(0xFF6750A4);
    final theme = MorphThemeData.dark(seedColor: seed);
    return MaterialApp(
      title: 'Morph Expressive — $scene',
      debugShowCheckedModeBanner: false,
      theme: theme.toThemeData(),
      builder: (context, child) =>
          MorphTheme(data: theme, child: child ?? const SizedBox.shrink()),
      home: Scaffold(
        backgroundColor: theme.colorScheme.surface,
        body: _CaptureScene(scene: scene),
      ),
    );
  }
}

class _CaptureScene extends StatefulWidget {
  const _CaptureScene({required this.scene});

  final String scene;

  @override
  State<_CaptureScene> createState() => _CaptureSceneState();
}

class _CaptureSceneState extends State<_CaptureScene> {
  final List<Timer> _timers = [];
  final MorphDropdownController<String> _dropdown =
      MorphDropdownController<String>();
  final TextEditingController _search = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _filled = TextEditingController();
  final MorphDismissibleListController _listController =
      MorphDismissibleListController();
  final FocusNode _searchFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _filledFocus = FocusNode();

  String _segment = 'Movies';
  String _chipToggle = 'Daily';
  Set<String> _chipMulti = <String>{};
  bool _filterSelected = false;
  bool _inputSelected = false;
  double _sliderValue = 0.28;
  double _progressValue = 0.32;
  int _expressiveNavigationIndex = 0;
  int _morphNavigationIndex = 0;
  int _pageIndex = 0;
  int _railIndex = 0;
  int _drawerIndex = 0;

  // Async button, skeleton, tabs and FAB menu scenes.
  MorphOperationState _operation = MorphOperationState.idle;
  bool _skeletonLoading = true;
  int _tabsUnderline = 0;
  int _tabsPill = 0;
  final MorphTabsController _underlineController = MorphTabsController();
  final MorphTabsController _pillController = MorphTabsController();
  final MorphFabMenuController _fab = MorphFabMenuController();
  final GlobalKey _preserveKey = GlobalKey();
  final GlobalKey _compactKey = GlobalKey();
  final GlobalKey _groupKey = GlobalKey();
  final GlobalKey _underlineViewKey = GlobalKey();
  final GlobalKey _pillViewKey = GlobalKey();
  final List<GlobalKey> _styleKeys = List.generate(5, (_) => GlobalKey());
  final List<GlobalKey> _shapeKeys = List.generate(4, (_) => GlobalKey());
  final List<bool> _shapeSelected = List<bool>.filled(4, false);
  final GlobalKey _connectedKey = GlobalKey();
  final List<GlobalKey> _fabKeys = List.generate(6, (_) => GlobalKey());
  int _connectedSelected = 0;
  int _reactiveSelected = 1;
  int _pointerId = 900;

  // Real pointer events, so press feedback and gestures drive the real widgets
  // (no cursor is rendered and nothing is simulated inside the components).
  Offset? _centerOf(GlobalKey key, {double fx = .5, double fy = .5}) {
    final box = key.currentContext?.findRenderObject();
    if (box is! RenderBox || !box.hasSize) return null;
    final size = box.size;
    return box.localToGlobal(Offset(size.width * fx, size.height * fy));
  }

  Duration get _stamp =>
      Duration(milliseconds: DateTime.now().millisecondsSinceEpoch);

  void _after(int ms, VoidCallback action) {
    _timers.add(
      Timer(Duration(milliseconds: ms), () {
        if (mounted) action();
      }),
    );
  }

  void _tapKey(GlobalKey key, {int holdMs = 150, double fx = .5}) {
    final at = _centerOf(key, fx: fx);
    if (at == null) return;
    final id = _pointerId++;
    final binding = GestureBinding.instance;
    binding.handlePointerEvent(
      PointerDownEvent(
        pointer: id,
        position: at,
        kind: PointerDeviceKind.touch,
        timeStamp: _stamp,
      ),
    );
    Timer(Duration(milliseconds: holdMs), () {
      binding.handlePointerEvent(
        PointerUpEvent(
          pointer: id,
          position: at,
          kind: PointerDeviceKind.touch,
          timeStamp: _stamp,
        ),
      );
    });
  }

  /// Drags from the centre of [key] through the horizontal [waypoints]
  /// (cumulative dx), one 16 ms step at a time, then releases.
  void _dragKey(GlobalKey key, List<double> waypoints, {int startMs = 0}) {
    final origin = _centerOf(key);
    if (origin == null) return;
    final id = _pointerId++;
    final binding = GestureBinding.instance;
    var elapsed = startMs;
    var x = 0.0;
    var previous = origin;
    _after(elapsed, () {
      binding.handlePointerEvent(
        PointerDownEvent(
          pointer: id,
          position: origin,
          kind: PointerDeviceKind.touch,
          timeStamp: _stamp,
        ),
      );
    });
    for (final target in waypoints) {
      final steps = ((target - x).abs() / 7).ceil().clamp(1, 80);
      final from = x;
      for (var i = 1; i <= steps; i++) {
        elapsed += 16;
        final next = Offset(
          origin.dx + from + (target - from) * i / steps,
          origin.dy,
        );
        final delta = next - previous;
        previous = next;
        _after(elapsed, () {
          binding.handlePointerEvent(
            PointerMoveEvent(
              pointer: id,
              position: next,
              delta: delta,
              kind: PointerDeviceKind.touch,
              timeStamp: _stamp,
            ),
          );
        });
      }
      x = target;
      elapsed += 130;
    }
    final end = previous;
    _after(elapsed, () {
      binding.handlePointerEvent(
        PointerUpEvent(
          pointer: id,
          position: end,
          kind: PointerDeviceKind.touch,
          timeStamp: _stamp,
        ),
      );
    });
  }

  int get _delayMs {
    final raw = int.tryParse(Uri.base.queryParameters['delayMs'] ?? '800');
    return (raw ?? 800).clamp(250, 10000);
  }

  void _at(int offsetMs, VoidCallback action) {
    _timers.add(
      Timer(Duration(milliseconds: _delayMs + offsetMs), () {
        if (mounted) action();
      }),
    );
  }

  // Enter text a character at a time so the focus/label transition is visible
  // in the exported GIF rather than jumping to the final value in one frame.
  void _typeForCapture(
    TextEditingController controller,
    String text, {
    required int startMs,
    int letterDelayMs = 46,
  }) {
    for (var i = 1; i <= text.length; i++) {
      final value = text.substring(0, i);
      _at(startMs + (i - 1) * letterDelayMs, () => controller.text = value);
    }
  }

  // Keep the multi selector externally controlled, exactly like the gallery.
  void _addMultiChip(String value) => setState(() {
    _chipMulti = <String>{..._chipMulti, value};
  });

  void _removeMultiChip(String value) => setState(() {
    _chipMulti = <String>{..._chipMulti}..remove(value);
  });

  void _scheduleDoubleSequence(
    List<double> values, {
    required void Function(double value) apply,
    int startMs = 0,
    int stepMs = 180,
  }) {
    for (var i = 0; i < values.length; i++) {
      _at(startMs + (i * stepMs), () => setState(() => apply(values[i])));
    }
  }

  void _scheduleLoop({
    required int cycleMs,
    required int cycles,
    required List<({int atMs, VoidCallback action})> events,
  }) {
    for (var cycle = 0; cycle < cycles; cycle++) {
      final baseMs = cycle * cycleMs;
      for (final event in events) {
        _at(baseMs + event.atMs, event.action);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      // The capture tool starts recording relative to this marker, after the
      // fonts and shader programs had `delayMs` to load.
      debugPrint('MORPH_GIF_SCENE_START');
      switch (widget.scene) {
        case 'buttons':
          // Staggered: one control at a time. Two full turns of the rotating
          // shape (3.6 s each) fit the clip, so the loop joins seamlessly.
          for (var i = 0; i < 5; i++) {
            _at(300 + i * 560, () => _tapKey(_styleKeys[i], holdMs: 230));
          }
          // Every shape is pressed twice so selection (and the morph) returns
          // to the first state before the loop restarts.
          for (final (i, ms) in [
            (0, 3000),
            (1, 3400),
            (2, 3800),
            (3, 4200),
            (0, 4900),
            (1, 5300),
            (2, 5700),
            (3, 6100),
          ]) {
            _at(ms, () => _tapKey(_shapeKeys[i], holdMs: 230));
          }
        case 'dropdown':
          _scheduleLoop(
            cycleMs: 2200,
            cycles: 2,
            events: [
              (atMs: 0, action: _dropdown.openDropdown),
              (atMs: 680, action: _dropdown.closeDropdown),
              (atMs: 1140, action: _dropdown.openDropdown),
              (atMs: 1820, action: _dropdown.closeDropdown),
            ],
          );
        case 'segmented':
          // One row at a time so each behaviour can be followed.
          _at(300, () => setState(() => _segment = 'TV Shows'));
          _at(1500, () => setState(() => _segment = 'Movies'));
          _at(2300, () => _tapKey(_connectedKey, fx: .83, holdMs: 240));
          _at(3100, () => _tapKey(_connectedKey, fx: .5, holdMs: 240));
          _at(3900, () => _tapKey(_connectedKey, fx: .17, holdMs: 240));
          _at(4700, () => _tapKey(_groupKey, fx: .83, holdMs: 260));
          _at(5500, () => _tapKey(_groupKey, fx: .17, holdMs: 260));
          _at(6300, () => _tapKey(_groupKey, fx: .5, holdMs: 260));
        case 'textfields':
          // Show the existing search and outlined fields, then the new filled
          // label transition: focus -> type -> blur (label stays outside) -> clear.
          // This scene needs a longer recording than the other components.
          _typeForCapture(_filled, 'hello@morph.dev', startMs: 3320);
          _typeForCapture(
            _filled,
            'morph@flutter.dev',
            startMs: 6450,
            letterDelayMs: 40,
          );
          for (final event in <({int atMs, VoidCallback action})>[
            (atMs: 0, action: _searchFocus.requestFocus),
            (atMs: 300, action: () => _search.text = 'Morph Expressive'),
            (atMs: 1050, action: _search.clear),
            (atMs: 1250, action: _emailFocus.requestFocus),
            (atMs: 1570, action: () => _email.text = 'hello@morph.dev'),
            (atMs: 2250, action: _emailFocus.unfocus),
            (atMs: 2670, action: _filledFocus.requestFocus),
            (atMs: 4430, action: _filledFocus.unfocus),
            (atMs: 5580, action: _filled.clear),
            (atMs: 5970, action: _filledFocus.requestFocus),
            (atMs: 7420, action: _filledFocus.unfocus),
          ]) {
            _at(event.atMs, event.action);
          }
        case 'chips':
          // Material 3 Expressive chips + moving single + independent multi.
          // Multi: 0->1 bloom, 1->2->3 borrowed-pill morph, 3->2->1
          // fusion, 1->0 bloom, then replay both behaviors for visibility.
          for (final event in <({int atMs, VoidCallback action})>[
            (
              atMs: 0,
              action: () => setState(() {
                _filterSelected = true;
                _chipToggle = 'Weekly';
              }),
            ),
            (atMs: 620, action: () => _addMultiChip('Daily')),
            (atMs: 1150, action: () => setState(() => _chipToggle = 'Monthly')),
            (atMs: 1460, action: () => _addMultiChip('Weekly')),
            (atMs: 2020, action: () => setState(() => _inputSelected = true)),
            (atMs: 2280, action: () => _addMultiChip('Monthly')),
            (atMs: 2860, action: () => setState(() => _chipToggle = 'Daily')),
            (atMs: 3150, action: () => _removeMultiChip('Weekly')),
            (atMs: 3820, action: () => _removeMultiChip('Monthly')),
            (atMs: 4480, action: () => _removeMultiChip('Daily')),
            (atMs: 5150, action: () => _addMultiChip('Monthly')),
            (atMs: 5810, action: () => _addMultiChip('Daily')),
            (atMs: 6250, action: () => setState(() => _chipToggle = 'Weekly')),
            (atMs: 6450, action: () => _removeMultiChip('Monthly')),
            (atMs: 6980, action: () => _removeMultiChip('Daily')),
            (atMs: 7490, action: () => _addMultiChip('Daily')),
            (
              atMs: 7850,
              action: () => setState(() {
                _filterSelected = false;
                _inputSelected = false;
                _chipToggle = 'Daily';
              }),
            ),
          ]) {
            _at(event.atMs, event.action);
          }
        case 'dialogs':
          // Capture MorphDialog's own animated route transition and scrim.
          for (final event in <({int atMs, VoidCallback action})>[
            (atMs: 250, action: _showCaptureDialog),
            (atMs: 1900, action: () => Navigator.of(context).maybePop()),
            (atMs: 3100, action: _showCaptureDialog),
            (atMs: 4750, action: () => Navigator.of(context).maybePop()),
          ]) {
            _at(event.atMs, event.action);
          }
        case 'lists':
          _scheduleLoop(
            cycleMs: 2800,
            cycles: 2,
            events: [
              (
                atMs: 360,
                action: () => _listController.reveal(1, leading: false),
              ),
              (atMs: 1540, action: _listController.close),
              (
                atMs: 1940,
                action: () => _listController.reveal(2, leading: true),
              ),
              (atMs: 2440, action: _listController.close),
            ],
          );
        case 'sliders':
          // Slow down near the upper threshold to make the 90–98% smoothstep
          // flattening clearly visible on both wavy slider variants.
          _scheduleDoubleSequence(
            const [
              0.52,
              0.72,
              0.86,
              0.90,
              0.91,
              0.92,
              0.93,
              0.94,
              0.95,
              0.96,
              0.97,
              0.98,
              1.00,
              0.98,
              0.97,
              0.96,
              0.95,
              0.94,
              0.93,
              0.92,
              0.91,
              0.90,
              0.85,
              0.65,
              0.50,
              0.72,
              0.88,
              0.90,
              0.92,
              0.94,
              0.96,
              0.98,
            ],
            apply: (value) => _sliderValue = value,
            stepMs: 178,
          );
        case 'navigation':
          _scheduleLoop(
            cycleMs: 3300,
            cycles: 2,
            events: [
              (
                atMs: 0,
                action: () => setState(() => _expressiveNavigationIndex = 1),
              ),
              (
                atMs: 350,
                action: () => setState(() => _morphNavigationIndex = 2),
              ),
              (atMs: 740, action: () => setState(() => _pageIndex = 1)),
              (
                atMs: 1100,
                action: () => setState(() => _expressiveNavigationIndex = 2),
              ),
              (
                atMs: 1450,
                action: () => setState(() => _morphNavigationIndex = 1),
              ),
              (atMs: 1830, action: () => setState(() => _pageIndex = 3)),
              (
                atMs: 2250,
                action: () => setState(() => _expressiveNavigationIndex = 0),
              ),
              (
                atMs: 2640,
                action: () => setState(() => _morphNavigationIndex = 0),
              ),
              (atMs: 2960, action: () => setState(() => _pageIndex = 0)),
            ],
          );
        case 'navigation_rail_drawer':
          // Diagnostic outside the image: which renderer the organic stretch
          // really uses here (the capture tool reads this line).
          MorphChipOrganicSurface.createSharedShader().then((shader) {
            debugPrint(
              'MORPH_GIF_RENDERER organic_stretch='
              '${shader == null ? 'canvas' : 'shader'}',
            );
            shader?.dispose();
          });
          _scheduleLoop(
            cycleMs: 3600,
            cycles: 2,
            events: [
              (atMs: 200, action: () => setState(() => _railIndex = 1)),
              (atMs: 900, action: () => setState(() => _drawerIndex = 2)),
              (atMs: 1700, action: () => setState(() => _railIndex = 2)),
              (atMs: 2300, action: () => setState(() => _drawerIndex = 1)),
              (atMs: 2900, action: () => setState(() => _railIndex = 0)),
              (atMs: 3200, action: () => setState(() => _drawerIndex = 0)),
            ],
          );
        case 'loading':
          // All variants stay visible; determinate indicators advance together
          // and return to their first value so the loop joins.
          _scheduleDoubleSequence(
            const [
              0.12,
              0.2,
              0.28,
              0.36,
              0.44,
              0.52,
              0.6,
              0.68,
              0.76,
              0.84,
              0.9,
              0.94,
              0.97,
              1.0,
              1.0,
              1.0,
              0.6,
              0.35,
              0.2,
              0.12,
            ],
            apply: (value) => _progressValue = value,
            stepMs: 330,
          );
        case 'async_button':
          _after(_delayMs + 300, () => _tapKey(_preserveKey, holdMs: 160));
          _after(_delayMs + 300, () => _tapKey(_compactKey, holdMs: 160));
          for (final (ms, state) in [
            (900, MorphOperationState.loading),
            (3000, MorphOperationState.success),
            (5000, MorphOperationState.idle),
            (5600, MorphOperationState.loading),
            (7400, MorphOperationState.error),
            (9200, MorphOperationState.idle),
          ]) {
            _at(ms, () => setState(() => _operation = state));
          }
        case 'skeleton':
          _at(4300, () => setState(() => _skeletonLoading = false));
          _at(6700, () => setState(() => _skeletonLoading = true));
        case 'tabs':
          _at(
            700,
            () => setState(() {
              _tabsUnderline = 1;
              _tabsPill = 1;
            }),
          );
          // Partial swipe that is reversed: the pages (and the indicator)
          // follow the finger back to the same tab.
          _at(2300, () => _dragKey(_underlineViewKey, [-190, -70]));
          // A swipe that completes on the next tab.
          _at(4000, () => _dragKey(_pillViewKey, [-150, -420]));
          _at(
            5900,
            () => setState(() {
              _tabsUnderline = 0;
              _tabsPill = 0;
            }),
          );
        case 'fab_menu':
          for (var i = 0; i < 6; i++) {
            _at(300 + i * 420, () => _tapKey(_fabKeys[i], holdMs: 220));
          }
          _at(3300, _fab.open);
          _at(5700, _fab.close);
          // Focus returns to the trigger after closing; release it so the
          // loop joins on the resting state.
          _at(6500, () => FocusManager.instance.primaryFocus?.unfocus());
      }
    });
  }

  void _showCaptureDialog() {
    MorphDialog.show<void>(
      context,
      dialog: MorphDialog(
        title: 'Save your changes?',
        icon: Icon(FluentIcons.line.info),
        content: const Text('Your edits will be saved to the current project.'),
        actions: <Widget>[
          MorphButton(
            style: MorphButtonStyle.text,
            label: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          MorphButton(
            label: const Text('Save'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    for (final timer in _timers) {
      timer.cancel();
    }
    _dropdown.dispose();
    _underlineController.dispose();
    _pillController.dispose();
    _fab.dispose();
    _search.dispose();
    _email.dispose();
    _filled.dispose();
    _searchFocus.dispose();
    _emailFocus.dispose();
    _filledFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final morph = MorphTheme.of(context);
    final scheme = morph.colorScheme;
    final (title, subtitle) = switch (widget.scene) {
      'buttons' => ('Buttons', 'Five styles · ShapeButton'),
      'dropdown' => ('Dropdown', 'Spring expand and collapse'),
      'segmented' => ('Segmented', 'Toggle · connected · reactive'),
      'textfields' => ('Text fields', 'Search, outlined, filled labels'),
      'chips' => ('Chips', 'Single and multi selection'),
      'sliders' => ('Sliders', 'Linear and wavy tracks'),
      'loading' => ('Loading', 'Loaders and progress'),
      'navigation' => ('Navigation', 'Morph bars and page indicators'),
      'navigation_rail_drawer' => (
        'Rail and drawer',
        'Elastic selection and stretch',
      ),
      'lists' => ('Lists', 'Swipe actions'),
      'dialogs' => ('Dialogs', 'Entrance and exit'),
      'async_button' => ('Async button', 'Loading · success · error'),
      'skeleton' => ('Skeleton', 'One tilted shimmer'),
      'tabs' => ('Tabs', 'The indicator follows the pages'),
      'fab_menu' => ('FABs', 'Sizes and the FAB menu'),
      _ => ('Morph Expressive', 'Component capture'),
    };

    return Stack(
      key: ValueKey('morph_gif_${widget.scene}'),
      children: [
        Positioned(
          top: 16,
          left: 28,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(title, style: morph.textTheme.titleLarge),
              const SizedBox(width: 12),
              Text(
                subtitle,
                style: (morph.textTheme.bodySmall ?? const TextStyle())
                    .copyWith(color: scheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
        Positioned(
          top: 60,
          left: 28,
          child: SizedBox(
            width: 584,
            child: Align(alignment: Alignment.topLeft, child: _content()),
          ),
        ),
        Positioned(
          bottom: 19,
          right: 30,
          child: Text(
            'MORPH EXPRESSIVE',
            style: (morph.textTheme.labelSmall ?? const TextStyle()).copyWith(
              color: scheme.onSurfaceVariant,
              letterSpacing: 2,
            ),
          ),
        ),
      ],
    );
  }

  Widget _captureLabel(String label) {
    final theme = MorphTheme.of(context);
    return Text(
      label,
      style: (theme.textTheme.labelMedium ?? const TextStyle()).copyWith(
        color: theme.colorScheme.onSurfaceVariant,
        letterSpacing: 0.3,
      ),
    );
  }

  Widget _loadingCell(String caption, Widget child) => SizedBox(
    width: 112,
    child: Column(
      children: [
        SizedBox(width: 72, height: 72, child: Center(child: child)),
        const SizedBox(height: 8),
        _captureLabel(caption),
      ],
    ),
  );

  Widget _asyncColumn(
    String label,
    MorphOperationPresentation mode,
    GlobalKey key,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _captureLabel(label),
        const SizedBox(height: 12),
        MorphAsyncButton(
          key: key,
          label: 'Save changes',
          state: _operation,
          presentation: mode,
          icon: Icon(FluentIcons.line.heart, size: 20),
          labels: const {
            MorphOperationState.success: 'Saved',
            MorphOperationState.error: 'Retry',
          },
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _skeletonScene() {
    final scheme = MorphTheme.of(context).colorScheme;
    final text = MorphTheme.of(context).textTheme;
    return SizedBox(
      width: 520,
      child: MorphSkeletonGroup(
        loading: _skeletonLoading,
        angle: 18,
        onRendererChanged: (status) =>
            debugPrint('MORPH_GIF_RENDERER skeleton=${status.effective.name}'),
        duration: const Duration(milliseconds: 1500),
        transitionDuration: const Duration(milliseconds: 420),
        semanticLabel: 'Loading profile',
        placeholder: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const MorphSkeleton.avatar(size: 56),
                const SizedBox(width: 16),
                Expanded(child: MorphSkeleton.lines(count: 3)),
              ],
            ),
            const SizedBox(height: 22),
            const MorphSkeleton.image(height: 104),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: scheme.primaryContainer,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  alignment: Alignment.center,
                  child: Text('MA', style: text.titleMedium),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Mara Okafor', style: text.titleSmall),
                        Text('Product designer', style: text.bodySmall),
                        Text('Shared 12 new boards', style: text.labelSmall),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            Container(
              height: 104,
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                'Spring palette review\nLayout stays identical when the content appears.',
                style: text.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tabsScene() {
    const labels = ['Overview', 'Activity', 'Updates'];
    final tabs = [for (final l in labels) MorphTab(label: l)];
    Widget pages(
      GlobalKey key,
      MorphTabsController c,
      int index,
      ValueChanged<int> set,
    ) => SizedBox(
      key: key,
      height: 78,
      child: MorphTabsView(
        controller: c,
        selectedIndex: index,
        onTabSelected: set,
        children: [for (final l in labels) Center(child: Text('$l page'))],
      ),
    );
    return SizedBox(
      width: 520,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _captureLabel('Underline · rounded ends'),
          const SizedBox(height: 6),
          MorphTabs(
            controller: _underlineController,
            tabs: tabs,
            selectedIndex: _tabsUnderline,
            onTabSelected: (i) => setState(() => _tabsUnderline = i),
            alignment: MorphTabsAlignment.content,
            indicatorFit: MorphTabsIndicatorFit.content,
          ),
          pages(
            _underlineViewKey,
            _underlineController,
            _tabsUnderline,
            (i) => setState(() => _tabsUnderline = i),
          ),
          const SizedBox(height: 18),
          _captureLabel('Surface · pill'),
          const SizedBox(height: 6),
          MorphTabs(
            controller: _pillController,
            tabs: tabs,
            selectedIndex: _tabsPill,
            onTabSelected: (i) => setState(() => _tabsPill = i),
            alignment: MorphTabsAlignment.content,
            indicatorStyle: MorphTabsIndicatorStyle.surface,
            onIndicatorRendererChanged: (status) => debugPrint(
              'MORPH_GIF_RENDERER tabs_indicator=${status.effective.name}',
            ),
            indicatorFit: MorphTabsIndicatorFit.content,
          ),
          pages(
            _pillViewKey,
            _pillController,
            _tabsPill,
            (i) => setState(() => _tabsPill = i),
          ),
        ],
      ),
    );
  }

  Widget _content() => switch (widget.scene) {
    'buttons' => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _captureLabel('Styles · press and release'),
        const SizedBox(height: 10),
        Wrap(
          spacing: 18,
          runSpacing: 12,
          children: [
            for (final (i, style, label) in [
              (0, MorphButtonStyle.filled, 'Filled'),
              (1, MorphButtonStyle.tonal, 'Tonal'),
              (2, MorphButtonStyle.elevated, 'Elevated'),
              (3, MorphButtonStyle.outlined, 'Outlined'),
              (4, MorphButtonStyle.text, 'Text'),
            ])
              MorphButton(
                key: _styleKeys[i],
                style: style,
                onPressed: () {},
                label: Text(label),
              ),
          ],
        ),
        const SizedBox(height: 26),
        _captureLabel('ShapeButton · rotation, press and morph'),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final (i, caption, shape, selectedShape, rotate, icon) in [
              (
                0,
                'Rotation',
                MorphShapeCatalog.fromKind(MorphShapeKind.sunny),
                null,
                true,
                MorphIcons.favorite_border,
              ),
              (
                1,
                'Press',
                MorphShapeCatalog.fromKind(MorphShapeKind.softBurst),
                null,
                false,
                MorphIcons.star_outline,
              ),
              (
                2,
                'Morph',
                MorphShapeCatalog.fromKind(MorphShapeKind.clover4Leaf),
                MorphShapeCatalog.fromKind(MorphShapeKind.flower),
                false,
                MorphIcons.check,
              ),
              (
                3,
                'Rotation + morph',
                MorphShapeCatalog.fromKind(MorphShapeKind.cookie12Sided),
                MorphShapeCatalog.fromKind(MorphShapeKind.softBoom),
                true,
                MorphIcons.add,
              ),
            ])
              Padding(
                padding: EdgeInsets.only(left: i == 0 ? 0 : 36),
                child: SizedBox(
                  width: 112,
                  child: Column(
                    children: [
                      MorphShapeButton(
                        key: _shapeKeys[i],
                        size: 100,
                        shape: shape,
                        selectedShape: selectedShape,
                        selected: _shapeSelected[i],
                        pressedScale: .88,
                        rotationEnabled: rotate,
                        rotationDuration: const Duration(milliseconds: 3600),
                        semanticLabel: caption,
                        onPressed: () => setState(
                          () => _shapeSelected[i] = !_shapeSelected[i],
                        ),
                        child: Icon(icon),
                      ),
                      const SizedBox(height: 8),
                      _captureLabel(caption),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ],
    ),
    'dropdown' => SizedBox(
      width: 360,
      child: MorphDropdownMenu<String>(
        controller: _dropdown,
        singleSelect: true,
        fieldStyle: const MorphDropdownFieldStyle(
          hintText: 'Choose a framework',
        ),
        items: const [
          MorphDropdownItem(label: 'Flutter', value: 'flutter'),
          MorphDropdownItem(label: 'Kotlin', value: 'kotlin'),
          MorphDropdownItem(label: 'Swift', value: 'swift'),
        ],
      ),
    ),
    'segmented' => SizedBox(
      width: 584,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _captureLabel('Segmented toggle'),
          const SizedBox(height: 8),
          SizedBox(
            width: 520,
            child: MorphSegmentedToggle<String>(
              options: const [
                MorphSegmentedToggleOption(value: 'Movies', label: 'Movies'),
                MorphSegmentedToggleOption(
                  value: 'TV Shows',
                  label: 'TV Shows',
                ),
              ],
              selected: _segment,
              onChanged: (value) => setState(() => _segment = value),
            ),
          ),
          const SizedBox(height: 24),
          _captureLabel('Connected button group'),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: MorphButtonGroup(
              key: _connectedKey,
              type: MorphButtonGroupType.connected,
              overflow: MorphButtonGroupOverflow.none,
              neighborSquish: true,
              selectedIndex: _connectedSelected,
              selectionRequired: true,
              onSelectedIndexChanged: (next) => setState(
                () => _connectedSelected = next ?? _connectedSelected,
              ),
              actions: const [
                MorphButtonGroupAction(label: Text('Day')),
                MorphButtonGroupAction(label: Text('Week')),
                MorphButtonGroupAction(label: Text('Month')),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _captureLabel('Reactive group'),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: MorphReactiveButtonGroup(
              key: _groupKey,
              fit: MorphReactiveGroupFit.natural,
              selectedIndex: _reactiveSelected,
              onSelectedIndexChanged: (next) =>
                  setState(() => _reactiveSelected = next ?? _reactiveSelected),
              selectionRequired: true,
              pressedExpansion: .08,
              selectedExpansion: .08,
              items: const [
                MorphReactiveGroupItem(label: Text('Hoy')),
                MorphReactiveGroupItem(label: Text('Esta semana')),
                MorphReactiveGroupItem(label: Text('Todo el historial')),
              ],
            ),
          ),
        ],
      ),
    ),
    'textfields' => SizedBox(
      width: 535,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _captureLabel('Search'),
          const SizedBox(height: 8),
          MorphTextField(
            key: const ValueKey('gif_textfield_search'),
            controller: _search,
            focusNode: _searchFocus,
            placeholder: 'Search for a movie',
            leading: const Icon(MorphIcons.search),
            showClearButton: true,
          ),
          const SizedBox(height: 18),
          _captureLabel('Outlined'),
          const SizedBox(height: 8),
          MorphTextField(
            key: const ValueKey('gif_textfield_outlined'),
            controller: _email,
            focusNode: _emailFocus,
            label: 'Email',
            placeholder: 'hello@example.com',
            variant: MorphTextFieldVariant.outlined,
          ),
          const SizedBox(height: 26),
          _captureLabel('Filled · floating label'),
          const SizedBox(height: 8),
          MorphTextField(
            key: const ValueKey('gif_textfield_filled'),
            controller: _filled,
            focusNode: _filledFocus,
            label: 'Email address',
            placeholder: 'name@example.com',
            leading: Icon(FluentIcons.line.mail),
            variant: MorphTextFieldVariant.filled,
          ),
        ],
      ),
    ),
    'dialogs' => SizedBox(
      width: 560,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          const Text('A rounded modal dialog with a spring entrance.'),
          const SizedBox(height: 18),
          MorphButton(
            label: const Text('Open floating dialog'),
            icon: Icon(FluentIcons.line.info),
            onPressed: _showCaptureDialog,
          ),
        ],
      ),
    ),
    'lists' => SizedBox(
      width: 560,
      child: MorphList(
        dismissController: _listController,
        itemCount: 3,
        itemBuilder: (context, index) => MorphListItem(
          headline: index == 0 ? 'Regular item' : 'Swipe item $index',
          supportingText: index == 0
              ? 'Standard MorphList row'
              : 'Reveal Morph action pills',
          leading: const Icon(MorphIcons.star),
          swipe: index == 0
              ? null
              : MorphListItemSwipe(
                  mode: MorphListSwipeMode.reveal,
                  leading: [
                    MorphListSwipeAction(
                      icon: const Icon(MorphIcons.star),
                      tooltip: 'Favorite',
                      onPressed: () {},
                    ),
                  ],
                  trailing: [
                    MorphListSwipeAction(
                      icon: const Icon(MorphIcons.archive),
                      tooltip: 'Archive',
                      onPressed: () {},
                    ),
                    MorphListSwipeAction(
                      icon: const Icon(MorphIcons.delete),
                      tooltip: 'Delete',
                      backgroundColor: MorphTheme.of(context).colorScheme.error,
                      foregroundColor: MorphTheme.of(context)
                          .colorScheme
                          .onError,
                      onPressed: () {},
                    ),
                  ],
                ),
        ),
      ),
    ),
    'chips' => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _captureLabel('Material 3 Expressive · filter, input, assist'),
        const SizedBox(height: 10),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            MorphChip(
              label: 'Filter',
              type: MorphChipType.filter,
              selected: _filterSelected,
              onPressed: () =>
                  setState(() => _filterSelected = !_filterSelected),
            ),
            MorphChip(
              label: 'Input',
              type: MorphChipType.input,
              selected: _inputSelected,
              onPressed: () => setState(() => _inputSelected = !_inputSelected),
            ),
            MorphChip(label: 'Assist', onPressed: () {}),
          ],
        ),
        const SizedBox(height: 20),
        _captureLabel('Morph expressive · single'),
        const SizedBox(height: 10),
        MorphChipToggle<String>(
          key: const ValueKey('gif_chips_single'),
          options: const [
            MorphChipToggleOption(value: 'Daily', label: 'Daily'),
            MorphChipToggleOption(value: 'Weekly', label: 'Weekly'),
            MorphChipToggleOption(value: 'Monthly', label: 'Monthly'),
          ],
          selected: _chipToggle,
          onChanged: (value) => setState(() => _chipToggle = value),
        ),
        const SizedBox(height: 20),
        _captureLabel('Morph expressive · multiple'),
        const SizedBox(height: 10),
        MorphChipToggle<String>(
          key: const ValueKey('gif_chips_multi'),
          multiSelection: true,
          options: const [
            MorphChipToggleOption(value: 'Daily', label: 'Daily'),
            MorphChipToggleOption(value: 'Weekly', label: 'Weekly'),
            MorphChipToggleOption(value: 'Monthly', label: 'Monthly'),
          ],
          selectedValues: _chipMulti,
          onSelectionChanged: (values) => setState(() => _chipMulti = values),
        ),
      ],
    ),
    'sliders' => SizedBox(
      width: 550,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Linear'),
          const SizedBox(height: 6),
          MorphSlider(
            value: _sliderValue,
            onChanged: (value) => setState(() => _sliderValue = value),
          ),
          const SizedBox(height: 26),
          const Text('Wavy'),
          const SizedBox(height: 6),
          MorphSlider.wavy(
            value: _sliderValue,
            onChanged: (value) => setState(() => _sliderValue = value),
          ),
          const SizedBox(height: 18),
          const Text('Wavy range'),
          const SizedBox(height: 6),
          MorphRangeSlider.wavy(
            values: MorphSliderRange(0.0, _sliderValue),
            onChanged: (range) => setState(() => _sliderValue = range.end),
          ),
        ],
      ),
    ),
    'navigation' => SizedBox(
      width: 560,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _captureLabel('Expressive bar · shared elastic selection'),
          const SizedBox(height: 6),
          SizedBox(
            width: 520,
            child: MorphNavigationBar.expressive(
              key: const ValueKey('gif_navigation_expressive_bar'),
              safeArea: false,
              autoLayout: false,
              selectedIndex: _expressiveNavigationIndex,
              onDestinationSelected: (index) =>
                  setState(() => _expressiveNavigationIndex = index),
              destinations: const [
                MorphNavigationBarDestination(
                  icon: MorphIcons.home,
                  label: 'Home',
                ),
                MorphNavigationBarDestination(
                  icon: MorphIcons.search,
                  label: 'Search',
                ),
                MorphNavigationBarDestination(
                  icon: MorphIcons.favorite_border,
                  label: 'Saved',
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _captureLabel('Morph bar · sliding top indicator'),
          const SizedBox(height: 6),
          SizedBox(
            width: 520,
            child: MorphNavigationBar.morph(
              key: const ValueKey('gif_navigation_morph_bar'),
              safeArea: false,
              iconSize: 32,
              unselectedIconScale: 0.9,
              selectedIndex: _morphNavigationIndex,
              onDestinationSelected: (index) =>
                  setState(() => _morphNavigationIndex = index),
              destinations: const [
                MorphNavigationBarDestination(
                  icon: MorphIcons.home,
                  label: 'Home',
                ),
                MorphNavigationBarDestination(
                  icon: MorphIcons.search,
                  label: 'Search',
                ),
                MorphNavigationBarDestination(
                  icon: MorphIcons.favorite_border,
                  label: 'Saved',
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _captureLabel('Page indicator · expand / slide'),
          const SizedBox(height: 5),
          Row(
            children: [
              MorphPageIndicator(
                key: const ValueKey('gif_page_expand'),
                count: 4,
                selectedIndex: _pageIndex,
                activeWidth: 34,
                inactiveWidth: 12,
                height: 14,
                inactiveHeight: 12,
                spacing: 4,
              ),
              const SizedBox(width: 34),
              MorphPageIndicator(
                key: const ValueKey('gif_page_slide'),
                count: 4,
                selectedIndex: _pageIndex,
                effect: MorphPageIndicatorEffect.slide,
                activeWidth: 26,
                inactiveWidth: 12,
                height: 12,
                spacing: 5,
              ),
            ],
          ),
        ],
      ),
    ),
    'navigation_rail_drawer' => SizedBox(
      width: 560,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 232,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _captureLabel('Morph rail'),
                const SizedBox(height: 8),
                SizedBox(
                  width: 226,
                  height: 298,
                  child: MorphNavigationRail.morph(
                    key: const ValueKey('gif_navigation_morph_rail'),
                    expandedWidth: 215,
                    scrollUnder: false,
                    selectedIndex: _railIndex,
                    onDestinationSelected: (index) =>
                        setState(() => _railIndex = index),
                    sections: const [
                      MorphNavigationRailSection(
                        destinations: [
                          MorphNavigationRailDestination(
                            icon: Icon(MorphIcons.home),
                            label: 'Home',
                          ),
                          MorphNavigationRailDestination(
                            icon: Icon(MorphIcons.search),
                            label: 'Search',
                          ),
                          MorphNavigationRailDestination(
                            icon: Icon(MorphIcons.favorite_border),
                            label: 'Saved',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 18),
          SizedBox(
            width: 310,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _captureLabel('Morph drawer'),
                const SizedBox(height: 8),
                SizedBox(
                  width: 304,
                  height: 298,
                  child: MorphNavigationDrawer.morph(
                    key: const ValueKey('gif_navigation_morph_drawer'),
                    headline: 'Navigation',
                    selectedIndex: _drawerIndex,
                    onDestinationSelected: (index) =>
                        setState(() => _drawerIndex = index),
                    destinations: const [
                      MorphNavigationDestination(
                        icon: Icon(MorphIcons.home),
                        label: 'Home',
                      ),
                      MorphNavigationDestination(
                        icon: Icon(MorphIcons.search),
                        label: 'Search',
                      ),
                      MorphNavigationDestination(
                        icon: Icon(MorphIcons.favorite_border),
                        label: 'Saved',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
    'loading' => SizedBox(
      width: 584,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _loadingCell('Loader', const MorphLoadingIndicator(size: 64)),
              _loadingCell(
                'Contained',
                const MorphLoadingIndicator(
                  variant: MorphLoadingIndicatorVariant.contained,
                  size: 64,
                ),
              ),
              _loadingCell(
                'Circular',
                MorphProgressIndicator.circular(
                  value: _progressValue,
                  size: 48,
                ),
              ),
              _loadingCell(
                'Circular wavy',
                MorphProgressIndicator.circularWavy(
                  value: _progressValue,
                  size: 48,
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          _captureLabel('Linear'),
          const SizedBox(height: 8),
          SizedBox(
            width: 520,
            child: MorphProgressIndicator.linear(
              value: _progressValue,
              linearSize: MorphProgressIndicatorSize.s,
            ),
          ),
          const SizedBox(height: 22),
          _captureLabel('Linear wavy'),
          const SizedBox(height: 8),
          SizedBox(
            width: 520,
            child: MorphProgressIndicator.linearWavy(
              value: _progressValue,
              linearSize: MorphProgressIndicatorSize.s,
            ),
          ),
        ],
      ),
    ),
    'async_button' => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _asyncColumn(
              'Preserved width',
              MorphOperationPresentation.preserveWidth,
              _preserveKey,
            ),
            const SizedBox(width: 36),
            _asyncColumn(
              'Compact',
              MorphOperationPresentation.compact,
              _compactKey,
            ),
          ],
        ),
        const SizedBox(height: 26),
        _captureLabel('Fixed states · held for the whole clip'),
        const SizedBox(height: 10),
        Row(
          key: const ValueKey('async_fixed_states'),
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final (label, state) in const [
              ('Idle', MorphOperationState.idle),
              ('Loading', MorphOperationState.loading),
              ('Success', MorphOperationState.success),
              ('Error', MorphOperationState.error),
            ])
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _captureLabel(label),
                      const SizedBox(height: 8),
                      MorphAsyncButton(
                        // Each Expanded cell provides finite width, so labels
                        // can ellipsize instead of overflowing the capture.
                        label: 'Save changes',
                        state: state,
                        presentation: MorphOperationPresentation.preserveWidth,
                        icon: Icon(FluentIcons.line.heart, size: 20),
                        labels: const {
                          MorphOperationState.success: 'Saved',
                          MorphOperationState.error: 'Retry',
                        },
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ],
    ),
    'skeleton' => _skeletonScene(),
    'tabs' => _tabsScene(),
    'fab_menu' => SizedBox(
      width: 584,
      height: 290,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _captureLabel('FAB · small, regular, medium, large'),
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    for (final (i, size) in [
                      (0, MorphFabSize.small),
                      (1, MorphFabSize.regular),
                      (2, MorphFabSize.medium),
                      (3, MorphFabSize.large),
                    ])
                      Padding(
                        padding: const EdgeInsets.only(right: 22),
                        child: MorphFab(
                          key: _fabKeys[i],
                          size: size,
                          icon: const Icon(MorphIcons.add),
                          onPressed: () {},
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 22),
                _captureLabel('Extended FAB'),
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    for (final (i, size) in [
                      (4, MorphExtendedFabSize.small),
                      (5, MorphExtendedFabSize.medium),
                    ])
                      Padding(
                        padding: const EdgeInsets.only(right: 18),
                        child: MorphExtendedFab(
                          key: _fabKeys[i],
                          size: size,
                          icon: const Icon(MorphIcons.add),
                          label: 'Create',
                          onPressed: () {},
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            right: 36,
            bottom: 0,
            child: MorphFabMenu(
              controller: _fab,
              onRendererChanged: (status) => debugPrint(
                'MORPH_GIF_RENDERER fab_menu=${status.effective.name}',
              ),
              items: [
                MorphFabMenuItem(
                  icon: Icon(FluentIcons.line.add),
                  label: 'Create',
                  onPressed: () {},
                ),
                MorphFabMenuItem(
                  icon: Icon(FluentIcons.line.heart),
                  label: 'Save',
                  onPressed: () {},
                ),
                MorphFabMenuItem(
                  icon: Icon(FluentIcons.line.mail),
                  label: 'Share',
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    ),
    _ => const SizedBox.shrink(),
  };
}
