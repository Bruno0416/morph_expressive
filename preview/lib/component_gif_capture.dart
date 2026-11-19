import 'dart:async';

import 'package:flutter/foundation.dart' show ValueNotifier, debugPrint;
import 'package:flutter/gestures.dart';
import 'package:material_ui/material_ui.dart'
    show
        Align,
        AnimatedBuilder,
        AnimationController,
        BorderRadius,
        BoxDecoration,
        BoxFit,
        Builder,
        Canvas,
        Center,
        Container,
        CustomPaint,
        CustomPainter,
        Curves,
        EdgeInsets,
        Element,
        Expanded,
        GlobalKey,
        Offset,
        Padding,
        RenderBox,
        Alignment,
        ValueChanged,
        MainAxisAlignment,
        MainAxisSize,
        BuildContext,
        Color,
        Column,
        CrossAxisAlignment,
        FocusManager,
        FittedBox,
        FocusNode,
        Icon,
        IgnorePointer,
        MaterialApp,
        Navigator,
        Paint,
        PaintingStyle,
        Path,
        Positioned,
        Row,
        Scaffold,
        SingleTickerProviderStateMixin,
        Size,
        SizedBox,
        Spacer,
        Stack,
        State,
        TextBaseline,
        StatefulWidget,
        StatelessWidget,
        Text,
        TextEditingController,
        TextEditingValue,
        TextSelection,
        TextStyle,
        ValueKey,
        ValueListenableBuilder,
        VoidCallback,
        Widget,
        WidgetsBinding,
        Wrap;
import 'package:morph_expressive/components/chips/morph_chip_organic_surface.dart'
    show MorphChipOrganicSurface;
import 'package:morph_expressive/morph_expressive.dart';
import 'package:morph_expressive_preview/gif_scenes/frosted_scene.dart';

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
      builder: (context, child) => MorphTheme(
        data: theme,
        // Only the context-menu scene draws a pointer, on purpose: the menu
        // opens at the pointer, so the viewer needs to see where it is. The
        // pointer sits above the navigator so it stays over the menu.
        child: scene == 'context_menu'
            ? Stack(
                children: [
                  Positioned.fill(child: child ?? const SizedBox.shrink()),
                  const _CaptureCursor(),
                ],
              )
            : (child ?? const SizedBox.shrink()),
      ),
      home: Scaffold(
        backgroundColor: theme.colorScheme.surface,
        body: _CaptureScene(scene: scene),
      ),
    );
  }
}

/// Pointer position drawn by the `context_menu` scene (null = hidden).
final ValueNotifier<Offset?> _captureCursor = ValueNotifier<Offset?>(null);

/// A small arrow drawn above the app, used only by the `context_menu` scene.
class _CaptureCursor extends StatelessWidget {
  const _CaptureCursor();

  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: ValueListenableBuilder<Offset?>(
      valueListenable: _captureCursor,
      builder: (context, at, _) => at == null
          ? const SizedBox.shrink()
          : Stack(
              children: [
                Positioned(
                  left: at.dx,
                  top: at.dy,
                  child: const CustomPaint(
                    size: Size(16, 22),
                    painter: _CursorPainter(),
                  ),
                ),
              ],
            ),
    ),
  );
}

class _CursorPainter extends CustomPainter {
  const _CursorPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final arrow = Path()
      ..moveTo(0, 0)
      ..lineTo(0, 17)
      ..lineTo(4.2, 13.2)
      ..lineTo(7, 19.5)
      ..lineTo(9.8, 18.3)
      ..lineTo(7.1, 12)
      ..lineTo(12.5, 12)
      ..close();
    canvas
      ..drawPath(arrow, Paint()..color = const Color(0xFFFFFFFF))
      ..drawPath(
        arrow,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.3
          ..color = const Color(0xFF14141A),
      );
  }

  @override
  bool shouldRepaint(_CursorPainter oldDelegate) => false;
}

class _CaptureScene extends StatefulWidget {
  const _CaptureScene({required this.scene});

  final String scene;

  @override
  State<_CaptureScene> createState() => _CaptureSceneState();
}

class _CaptureSceneState extends State<_CaptureScene>
    with SingleTickerProviderStateMixin {
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

  String _segment = 'Day';
  Set<String> _transport = <String>{};
  int _sizeIndex = 1;
  Set<String> _chipMulti = <String>{};
  Set<String> _topics = <String>{};
  static const List<String> _everyone = ['Ana', 'Ben', 'Chloe'];
  final List<String> _people = [..._everyone];
  final Map<String, GlobalKey> _chipKeys = {
    for (final name in _everyone) name: GlobalKey(),
  };
  bool _emailTouched = false;
  double _volume = .35;
  double _brightness = .6;
  MorphSliderRange _range = const MorphSliderRange(.25, .75);
  final List<GlobalKey> _sliderKeys = List.generate(3, (_) => GlobalKey());
  final List<GlobalKey> _navKeys = List.generate(2, (_) => GlobalKey());
  final List<GlobalKey> _dropdownKeys = List.generate(2, (_) => GlobalKey());
  final MorphDropdownController<String> _dropdownMulti =
      MorphDropdownController<String>();
  // Loading scene: one 3.5 s period of progress (two per 7 s clip).
  late final AnimationController _loadingClock = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3500),
  );
  int _expressiveNavigationIndex = 0;
  int _morphNavigationIndex = 0;
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
  final GlobalKey _underlineViewKey = GlobalKey();
  final GlobalKey _pillViewKey = GlobalKey();
  final List<GlobalKey> _styleKeys = List.generate(5, (_) => GlobalKey());
  final List<GlobalKey> _shapeKeys = List.generate(4, (_) => GlobalKey());
  final List<bool> _shapeSelected = List<bool>.filled(4, false);
  final List<GlobalKey> _fabKeys = List.generate(6, (_) => GlobalKey());
  int _pointerId = 900;

  // Density scene: the only thing that changes is the theme's density.
  MorphDensity _density = MorphDensity.standard;

  // Context-menu scene: a scripted mouse (real pointer events of kind
  // `mouse`) and a deliberately drawn pointer arrow.
  final List<GlobalKey> _fileKeys = List.generate(3, (_) => GlobalKey());
  final List<GlobalKey> _variantKeys = List.generate(25, (_) => GlobalKey());
  String _menuStatus = 'Right-click a file';
  Offset _mouse = const Offset(430, 262);
  bool _mouseAdded = false;
  static const int _mouseDevice = 41;

  void _mouseMove(Offset to) {
    final binding = GestureBinding.instance;
    if (!_mouseAdded) {
      _mouseAdded = true;
      binding.handlePointerEvent(
        PointerAddedEvent(
          device: _mouseDevice,
          kind: PointerDeviceKind.mouse,
          position: _mouse,
          timeStamp: _stamp,
        ),
      );
    }
    binding.handlePointerEvent(
      PointerHoverEvent(
        device: _mouseDevice,
        kind: PointerDeviceKind.mouse,
        position: to,
        delta: to - _mouse,
        timeStamp: _stamp,
      ),
    );
    _mouse = to;
    _captureCursor.value = to;
  }

  /// Eases the scripted mouse from where it is to [target] (resolved when the
  /// glide starts, so it can point at widgets that were just built).
  void _glide(Offset? Function() target, {required int atMs, int ms = 600}) {
    _at(atMs, () {
      final to = target();
      if (to == null) return;
      final from = _mouse;
      final steps = (ms / 16).ceil();
      for (var i = 1; i <= steps; i++) {
        _after(i * 16, () {
          final t = Curves.easeInOutCubic.transform(i / steps);
          _mouseMove(Offset.lerp(from, to, t)!);
        });
      }
    });
  }

  void _mouseClick({bool secondary = false, int holdMs = 110}) {
    final id = _pointerId++;
    final binding = GestureBinding.instance;
    final at = _mouse;
    binding.handlePointerEvent(
      PointerDownEvent(
        pointer: id,
        device: _mouseDevice,
        kind: PointerDeviceKind.mouse,
        position: at,
        buttons: secondary ? kSecondaryButton : kPrimaryButton,
        timeStamp: _stamp,
      ),
    );
    _after(holdMs, () {
      binding.handlePointerEvent(
        PointerUpEvent(
          pointer: id,
          device: _mouseDevice,
          kind: PointerDeviceKind.mouse,
          position: at,
          timeStamp: _stamp,
        ),
      );
    });
  }

  /// Centre of the first on-screen [Text] whose data equals [text].
  Offset? _textCenter(String text) {
    Offset? found;
    void visit(Element element) {
      if (found != null) return;
      final widget = element.widget;
      if (widget is Text && widget.data == text) {
        final box = element.renderObject;
        if (box is RenderBox && box.hasSize && box.attached) {
          found = box.localToGlobal(box.size.center(Offset.zero));
          return;
        }
      }
      element.visitChildren(visit);
    }

    WidgetsBinding.instance.rootElement?.visitChildren(visit);
    return found;
  }

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
          _scriptButtons();
        case 'dropdown':
          _scriptDropdown();
        case 'segmented':
          _scriptSegmented();
        case 'textfields':
          _scriptTextfields();
        case 'chips':
          _scriptChips();
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
          _scriptSliders();
        case 'navigation':
          _scriptNavigation();
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
          _loadingClock.repeat();
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
        case 'variants':
          // One row at a time: the four styles of a variant are pressed in
          // sequence (real touches, so the real press feedback shows).
          for (var row = 0; row < 5; row++) {
            for (var col = 0; col < 4; col++) {
              _at(
                300 + row * 1000 + col * 170,
                () => _tapKey(_variantKeys[row * 5 + col], holdMs: 320),
              );
            }
          }
        case 'density':
          // Standard -> Compact -> Standard -> Comfortable -> Standard: the
          // clip starts and ends on the default, so the loop joins.
          for (final (ms, density) in [
            (1200, MorphDensity.compact),
            (2700, MorphDensity.standard),
            (4100, MorphDensity.comfortable),
            (5500, MorphDensity.standard),
          ]) {
            _at(ms, () => setState(() => _density = density));
          }
        case 'context_menu':
          // Real secondary click on the second file: the desktop menu opens at
          // the pointer, hover moves the highlight, "Move to" opens its
          // submenu, a left click on "Documents" chooses and closes.
          _mouseMove(_mouse);
          _glide(
            () => _centerOf(_fileKeys[1], fx: .38, fy: .5),
            atMs: 400,
            ms: 800,
          );
          _at(1450, () => _mouseClick(secondary: true));
          _glide(() => _textCenter('Copy'), atMs: 2200, ms: 520);
          _glide(() => _textCenter('Move to'), atMs: 2950, ms: 420);
          _glide(() => _textCenter('Documents'), atMs: 3800, ms: 560);
          _at(4600, _mouseClick);
          _glide(() => const Offset(430, 262), atMs: 5100, ms: 800);
          _at(6500, () => setState(() => _menuStatus = 'Right-click a file'));
      }
    });
  }

  // -----------------------------------------------------------------------
  // Showcases redesigned for 1.0.0: buttons, dropdown, segmented, textfields,
  // chips, sliders, loading and navigation. Every label is English and every
  // interaction is a scripted pointer event (or a controller call) on the real
  // widgets; the clips start and end on the same resting state.
  // -----------------------------------------------------------------------

  void _tapAt(Offset at, {int holdMs = 200}) {
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
    _after(holdMs, () {
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

  /// Touch tap on the centre of the first on-screen [Text] equal to [text].
  void _tapText(String text, {int holdMs = 220, double dx = 0}) {
    final at = _textCenter(text);
    if (at != null) _tapAt(at + Offset(dx, 0), holdMs: holdMs);
  }

  /// Presses [key] at horizontal fraction [from], drags through [legs]
  /// (duration in ms, target fraction) with eased motion and releases where the
  /// last leg ends. A 120 ms pause separates the legs.
  void _dragSmooth(GlobalKey key, double from, List<(int, double)> legs) {
    final box = key.currentContext?.findRenderObject();
    if (box is! RenderBox || !box.hasSize) return;
    Offset at(double fraction) => box.localToGlobal(
      Offset(box.size.width * fraction, box.size.height / 2),
    );
    final id = _pointerId++;
    final binding = GestureBinding.instance;
    var previous = at(from);
    binding.handlePointerEvent(
      PointerDownEvent(
        pointer: id,
        position: previous,
        kind: PointerDeviceKind.touch,
        timeStamp: _stamp,
      ),
    );
    var elapsed = 0;
    var start = from;
    for (final (index, (ms, target)) in legs.indexed) {
      final steps = (ms / 16).ceil();
      for (var i = 1; i <= steps; i++) {
        elapsed += 16;
        final next = at(
          start + (target - start) * Curves.easeInOutCubic.transform(i / steps),
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
      start = target;
      if (index < legs.length - 1) elapsed += 120;
    }
    final end = previous;
    _after(elapsed + 16, () {
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

  /// Types [text] one character at a time into [controller] with the caret at
  /// the end (the field keeps the focus it was given).
  void _typeInto(
    TextEditingController controller,
    String text, {
    required int startMs,
    int letterMs = 55,
    String prefix = '',
  }) {
    for (var i = 1; i <= text.length; i++) {
      final value = prefix + text.substring(0, i);
      _at(startMs + (i - 1) * letterMs, () {
        controller.value = TextEditingValue(
          text: value,
          selection: TextSelection.collapsed(offset: value.length),
        );
        setState(() {});
      });
    }
  }

  Widget _valueText(String text) {
    final theme = MorphTheme.of(context);
    return Text(
      text,
      style: (theme.textTheme.labelLarge ?? const TextStyle()).copyWith(
        color: theme.colorScheme.primary,
      ),
    );
  }

  Widget _labelWithValue(String label, String value) =>
      Row(children: [_captureLabel(label), const Spacer(), _valueText(value)]);

  // ------------------------------- buttons -------------------------------

  void _scriptButtons() {
    // Five styles, one press at a time, held long enough to read the response.
    for (var i = 0; i < 5; i++) {
      _at(350 + i * 600, () => _tapKey(_styleKeys[i], holdMs: 330));
    }
    // Every shape button is pressed twice: the first press selects (and
    // morphs), the second returns it to the resting shape.
    for (final (i, ms) in [
      (0, 3500),
      (1, 3900),
      (2, 4300),
      (3, 4700),
      (0, 5200),
      (1, 5600),
      (2, 6000),
      (3, 6400),
    ]) {
      _at(ms, () => _tapKey(_shapeKeys[i], holdMs: 280));
    }
  }

  Widget _buttonsScene() {
    final shapes = [
      (
        'Rotating',
        MorphShapeCatalog.fromKind(MorphShapeKind.sunny),
        null as MorphShape?,
        true,
        MorphIcons.favorite_border,
      ),
      (
        'Press',
        MorphShapeCatalog.fromKind(MorphShapeKind.softBurst),
        null,
        false,
        MorphIcons.star_outline,
      ),
      (
        'Morph on select',
        MorphShapeCatalog.fromKind(MorphShapeKind.clover4Leaf),
        MorphShapeCatalog.fromKind(MorphShapeKind.flower),
        false,
        MorphIcons.check,
      ),
      (
        'Rotate + morph',
        MorphShapeCatalog.fromKind(MorphShapeKind.cookie12Sided),
        MorphShapeCatalog.fromKind(MorphShapeKind.softBoom),
        true,
        MorphIcons.add,
      ),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _captureLabel('Button styles · press response'),
        const SizedBox(height: 10),
        Wrap(
          spacing: 14,
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
        const SizedBox(height: 30),
        _captureLabel('Shape buttons · rotate, press and morph'),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final (i, (caption, shape, selectedShape, rotate, icon))
                in shapes.indexed)
              SizedBox(
                width: 136,
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
                      rotationDuration: const Duration(milliseconds: 3500),
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
          ],
        ),
      ],
    );
  }

  // ------------------------------- dropdown ------------------------------

  void _scriptDropdown() {
    _mouse = const Offset(612, 342);
    _mouseMove(_mouse);
    // Single select: open, hover, choose, closes by itself.
    _at(350, () => _tapKey(_dropdownKeys[0], holdMs: 140));
    _glide(() => _textCenter('Kotlin'), atMs: 1050, ms: 380);
    _glide(() => _textCenter('Swift'), atMs: 1650, ms: 380);
    _at(2250, () => _tapText('Swift', holdMs: 140));
    // Multiple select: open, pick two, close.
    _at(3150, () => _tapKey(_dropdownKeys[1], holdMs: 140));
    _at(3850, () => _tapText('Android', holdMs: 140));
    _at(4350, () => _tapText('Web', holdMs: 140));
    _at(5100, _dropdownMulti.closeDropdown);
    // Back to the resting state so the clip loops.
    _at(6250, () {
      _dropdown.clearAll();
      _dropdownMulti.clearAll();
    });
  }

  Widget _dropdownScene() {
    Widget column(String caption, Widget field) => SizedBox(
      width: 284,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [_captureLabel(caption), const SizedBox(height: 8), field],
      ),
    );
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        column(
          'Single select',
          MorphDropdownMenu<String>(
            key: _dropdownKeys[0],
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
        column(
          'Multiple select',
          MorphDropdownMenu<String>(
            key: _dropdownKeys[1],
            controller: _dropdownMulti,
            fieldStyle: const MorphDropdownFieldStyle(
              hintText: 'Choose platforms',
            ),
            items: const [
              MorphDropdownItem(label: 'Android', value: 'android'),
              MorphDropdownItem(label: 'iOS', value: 'ios'),
              MorphDropdownItem(label: 'Web', value: 'web'),
            ],
          ),
        ),
      ],
    );
  }

  // ------------------------------- segmented -----------------------------

  void _scriptSegmented() {
    // Toggle: the pill glides and stretches between options.
    _at(400, () => _tapText('Week', holdMs: 200));
    _at(1150, () => _tapText('Month', holdMs: 200));
    _at(1900, () => _tapText('Day', holdMs: 200));
    // Segmented button: multi select with the selected check.
    _at(2700, () => _tapText('Walk', holdMs: 200));
    _at(3250, () => _tapText('Train', holdMs: 200));
    _at(3800, () => _tapText('Walk', holdMs: 200));
    _at(4350, () => _tapText('Train', holdMs: 200));
    // Connected group: neighbours squish while one segment is selected.
    _at(5000, () => _tapText('Large', holdMs: 240));
    _at(5650, () => _tapText('Small', holdMs: 240));
    _at(6300, () => _tapText('Medium', holdMs: 240));
  }

  Widget _segmentedScene() {
    const sizes = ['Small', 'Medium', 'Large'];
    return SizedBox(
      width: 584,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _labelWithValue('Segmented toggle', 'Calendar: $_segment'),
          const SizedBox(height: 8),
          MorphSegmentedToggle<String>(
            options: const [
              MorphSegmentedToggleOption(value: 'Day', label: 'Day'),
              MorphSegmentedToggleOption(value: 'Week', label: 'Week'),
              MorphSegmentedToggleOption(value: 'Month', label: 'Month'),
            ],
            selected: _segment,
            onChanged: (value) => setState(() => _segment = value),
          ),
          const SizedBox(height: 24),
          _labelWithValue(
            'Segmented button',
            _transport.isEmpty
                ? 'Nothing selected'
                : 'Selected: ${(_transport.toList()..sort()).join(' + ')}',
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: SizedBox(
              width: 584,
              child: MorphSegmentedButton<String>(
                multiSelect: true,
                selected: _transport,
                onSelectionChanged: (next) => setState(() => _transport = next),
                segments: const [
                  MorphSegment(value: 'Walk', label: 'Walk'),
                  MorphSegment(value: 'Bike', label: 'Bike'),
                  MorphSegment(value: 'Bus', label: 'Bus'),
                  MorphSegment(value: 'Train', label: 'Train'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          _labelWithValue(
            'Connected button group',
            'Size: ${sizes[_sizeIndex]}',
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: MorphButtonGroup(
              type: MorphButtonGroupType.connected,
              overflow: MorphButtonGroupOverflow.none,
              neighborSquish: true,
              selectedIndex: _sizeIndex,
              selectionRequired: true,
              onSelectedIndexChanged: (next) =>
                  setState(() => _sizeIndex = next ?? _sizeIndex),
              actions: [
                for (final size in sizes)
                  MorphButtonGroupAction(label: Text(size)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------- textfields ----------------------------

  bool get _emailValid =>
      RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]{2,}$').hasMatch(_filled.text);

  void _scriptTextfields() {
    // Filled field: focus, type an incomplete address, leave (error), return
    // and complete it (the error clears).
    _at(300, _filledFocus.requestFocus);
    _typeInto(_filled, 'hello@morph', startMs: 600, letterMs: 55);
    _at(1700, () {
      _filledFocus.unfocus();
      setState(() => _emailTouched = true);
    });
    _at(2400, _filledFocus.requestFocus);
    _at(2480, () {
      _filled.selection = TextSelection.collapsed(offset: _filled.text.length);
    });
    _typeInto(
      _filled,
      '.dev',
      startMs: 2750,
      letterMs: 110,
      prefix: 'hello@morph',
    );
    _at(3500, _filledFocus.unfocus);
    // Outlined field with a character counter.
    _at(3700, _emailFocus.requestFocus);
    _typeInto(_email, 'morph_dev', startMs: 4000, letterMs: 65);
    _at(4800, _emailFocus.unfocus);
    // Search field with its clear button.
    _at(5000, _searchFocus.requestFocus);
    _typeInto(_search, 'Morph', startMs: 5250, letterMs: 80);
    // Everything returns to the empty resting state.
    _at(6450, () {
      _search.clear();
      _searchFocus.unfocus();
      _filled.clear();
      _email.clear();
      setState(() => _emailTouched = false);
    });
  }

  /// Column header with one fixed line height, so both columns start their
  /// fields at the same y even when a font is wider than expected.
  Widget _columnHeader(String text) => SizedBox(
    height: 16,
    child: FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: _captureLabel(text),
    ),
  );

  /// Extra top space the outlined field needs so its container starts where
  /// the filled one does (see [_textfieldsScene]).
  double get _outlinedTopAlignment {
    final theme = MorphTheme.of(context);
    final fieldTheme = theme.textFieldTheme;
    final filledLabel = theme.typeScale.bodyMedium.copyWith(
      fontSize: (theme.typeScale.bodyMedium.fontSize ?? 14) + 1,
    );
    final filledInset =
        MorphTextFieldTheme.lineHeightOf(filledLabel) +
        fieldTheme.supportingTopPadding;
    final outlinedInset =
        MorphTextFieldTheme.lineHeightOf(
          fieldTheme.resolveFloatingLabelStyle(theme.typeScale),
        ) /
        2;
    return filledInset - outlinedInset;
  }

  Widget _textfieldsScene() {
    final showError = _emailTouched && !_emailValid;
    return SizedBox(
      width: 584,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _columnHeader('Filled · floating label and error'),
                    const SizedBox(height: 8),
                    MorphTextField(
                      key: const ValueKey('gif_textfield_filled'),
                      controller: _filled,
                      focusNode: _filledFocus,
                      label: 'Email address',
                      placeholder: 'name@example.com',
                      leading: Icon(FluentIcons.line.mail),
                      variant: MorphTextFieldVariant.filled,
                      supportingText: 'We only use it for receipts',
                      errorText: showError
                          ? 'Enter a valid email address'
                          : null,
                      showErrorIcon: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _columnHeader('Outlined · counter'),
                    const SizedBox(height: 8),
                    // The filled field reserves its floating-label region above
                    // the container, the outlined one only half a label line
                    // (the label floats on its border). Reserve the difference
                    // so both containers share the same top edge.
                    SizedBox(height: _outlinedTopAlignment),
                    MorphTextField(
                      key: const ValueKey('gif_textfield_outlined'),
                      controller: _email,
                      focusNode: _emailFocus,
                      label: 'Username',
                      placeholder: 'your_name',
                      leading: Icon(FluentIcons.line.person),
                      variant: MorphTextFieldVariant.outlined,
                      supportingText: 'Letters, numbers and _',
                      maxLength: 16,
                      showCounter: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _captureLabel('Search · clear button'),
          const SizedBox(height: 8),
          MorphTextField(
            key: const ValueKey('gif_textfield_search'),
            controller: _search,
            focusNode: _searchFocus,
            placeholder: 'Search components',
            leading: const Icon(MorphIcons.search),
            showClearButton: true,
          ),
        ],
      ),
    );
  }

  // ------------------------------- chips ---------------------------------

  void _scriptChips() {
    // Filter chips: select three, then deselect them.
    for (final (ms, topic) in [
      (400, 'Movies'),
      (850, 'Music'),
      (1300, 'Games'),
      (1900, 'Music'),
      (2350, 'Movies'),
      (2800, 'Games'),
    ]) {
      _at(ms, () => _tapText(topic, holdMs: 170));
    }
    // Input chips: remove two people, then add them back with the assist chip.
    _at(3500, () => _tapKey(_chipKeys['Ben']!, fx: .86, holdMs: 170));
    _at(3950, () => _tapKey(_chipKeys['Chloe']!, fx: .86, holdMs: 170));
    _at(4500, () => _tapText('Add person', holdMs: 170));
    _at(4950, () => _tapText('Add person', holdMs: 170));
    // Expressive group: multiple selection with the shared morphing pill.
    for (final (ms, day) in [
      (5500, 'Mon'),
      (5900, 'Wed'),
      (6300, 'Mon'),
      (6700, 'Wed'),
    ]) {
      _at(ms, () => _tapText(day, holdMs: 170));
    }
  }

  Widget _chipsScene() {
    const topics = ['Movies', 'Music', 'Books', 'Games', 'Travel'];
    return SizedBox(
      width: 584,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _captureLabel('Filter chips · select and deselect'),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final topic in topics)
                MorphChip.filter(
                  label: topic,
                  selected: _topics.contains(topic),
                  onPressed: () => setState(() {
                    _topics = _topics.contains(topic)
                        ? ({..._topics}..remove(topic))
                        : {..._topics, topic};
                  }),
                ),
            ],
          ),
          const SizedBox(height: 22),
          _captureLabel('Input chips · remove, and an assist chip to add'),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final person in _people)
                MorphChip.input(
                  key: _chipKeys[person],
                  label: person,
                  onDeleted: () => setState(() => _people.remove(person)),
                ),
              MorphChip.assist(
                label: 'Add person',
                leading: const Icon(MorphIcons.add),
                onPressed: () => setState(() {
                  final next = _everyone.firstWhere(
                    (name) => !_people.contains(name),
                    orElse: () => '',
                  );
                  if (next.isEmpty) return;
                  _people
                    ..add(next)
                    ..sort(
                      (a, b) => _everyone.indexOf(a) - _everyone.indexOf(b),
                    );
                }),
              ),
            ],
          ),
          const SizedBox(height: 22),
          _captureLabel('Chip group · multiple selection'),
          const SizedBox(height: 10),
          MorphChipToggle<String>(
            key: const ValueKey('gif_chips_multi'),
            multiSelection: true,
            options: const [
              MorphChipToggleOption(value: 'Mon', label: 'Mon'),
              MorphChipToggleOption(value: 'Tue', label: 'Tue'),
              MorphChipToggleOption(value: 'Wed', label: 'Wed'),
              MorphChipToggleOption(value: 'Thu', label: 'Thu'),
              MorphChipToggleOption(value: 'Fri', label: 'Fri'),
            ],
            selectedValues: _chipMulti,
            onSelectionChanged: (values) => setState(() => _chipMulti = values),
          ),
        ],
      ),
    );
  }

  // ------------------------------- sliders -------------------------------

  void _scriptSliders() {
    // Each slider is dragged for real, then returned to where it started.
    _at(
      300,
      () => _dragSmooth(_sliderKeys[0], .35, [
        (650, .85),
        (750, .12),
        (650, .35),
      ]),
    );
    _at(
      2500,
      () => _dragSmooth(_sliderKeys[1], .6, [(650, .2), (750, .95), (650, .6)]),
    );
    _at(
      4700,
      () => _dragSmooth(_sliderKeys[2], .75, [
        (650, .95),
        (750, .55),
        (650, .75),
      ]),
    );
  }

  Widget _sliderRow(String name, Widget slider, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 22),
    child: Row(
      children: [
        SizedBox(width: 96, child: _captureLabel(name)),
        Expanded(child: slider),
        SizedBox(
          width: 76,
          child: Align(
            alignment: Alignment.centerRight,
            child: _valueText(value),
          ),
        ),
      ],
    ),
  );

  Widget _slidersScene() => SizedBox(
    width: 584,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Room for the value bubble that rises above a dragged thumb.
        const SizedBox(height: 26),
        _sliderRow(
          'Volume',
          MorphSlider(
            key: _sliderKeys[0],
            value: _volume,
            label: '${(_volume * 100).round()}%',
            onChanged: (value) => setState(() => _volume = value),
          ),
          '${(_volume * 100).round()}%',
        ),
        _sliderRow(
          'Brightness',
          MorphSlider.wavy(
            key: _sliderKeys[1],
            value: _brightness,
            label: '${(_brightness * 100).round()}%',
            onChanged: (value) => setState(() => _brightness = value),
          ),
          '${(_brightness * 100).round()}%',
        ),
        _sliderRow(
          'Price range',
          MorphRangeSlider.wavy(
            key: _sliderKeys[2],
            values: _range,
            labels: MorphSliderRangeLabels(
              '${(_range.start * 100).round()}',
              '${(_range.end * 100).round()}',
            ),
            onChanged: (range) => setState(() => _range = range),
          ),
          '\$${(_range.start * 100).round()}–${(_range.end * 100).round()}',
        ),
      ],
    ),
  );

  // ------------------------------- loading -------------------------------

  /// Progress shared by every determinate indicator: eased 0 -> 100 %, held for
  /// a moment, then restarted. Two periods fit the 7 s clip.
  double _loadingProgress() {
    final u = _loadingClock.value;
    return u < .8 ? Curves.easeInOutCubic.transform(u / .8) : 1.0;
  }

  Widget _loadingScene() {
    Widget cell(String caption, Widget child) => SizedBox(
      width: 146,
      child: Column(
        children: [
          SizedBox(width: 72, height: 72, child: Center(child: child)),
          const SizedBox(height: 8),
          _captureLabel(caption),
        ],
      ),
    );
    // One full morph sequence (7 shapes x 1 s) and a whole number of turns
    // fit the 7 s clip, so the loop joins seamlessly.
    const rotation = Duration(milliseconds: 1750);
    const morphTurn = 360 / 7;
    return AnimatedBuilder(
      animation: _loadingClock,
      builder: (context, _) {
        final value = _loadingProgress();
        return SizedBox(
          width: 584,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  cell(
                    'Loading indicator',
                    const MorphLoadingIndicator(
                      size: 64,
                      globalRotationDuration: rotation,
                      morphRotationDegrees: morphTurn,
                    ),
                  ),
                  cell(
                    'Contained',
                    const MorphLoadingIndicator(
                      variant: MorphLoadingIndicatorVariant.contained,
                      size: 64,
                      globalRotationDuration: rotation,
                      morphRotationDegrees: morphTurn,
                    ),
                  ),
                  cell(
                    'Circular',
                    MorphProgressIndicator.circular(
                      value: value,
                      size: 56,
                      strokeWidth: 6,
                      trackStrokeWidth: 6,
                    ),
                  ),
                  cell(
                    'Circular wavy',
                    MorphProgressIndicator.circularWavy(
                      value: value,
                      size: 60,
                      strokeWidth: 5,
                      trackStrokeWidth: 5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              _labelWithValue('Linear', '${(value * 100).round()}%'),
              const SizedBox(height: 8),
              MorphProgressIndicator.linear(
                value: value,
                linearSize: MorphProgressIndicatorSize.m,
              ),
              const SizedBox(height: 26),
              _labelWithValue('Linear wavy', '${(value * 100).round()}%'),
              const SizedBox(height: 8),
              MorphProgressIndicator.linearWavy(
                value: value,
                linearSize: MorphProgressIndicatorSize.m,
              ),
            ],
          ),
        );
      },
    );
  }

  // ------------------------------- navigation ----------------------------

  void _scriptNavigation() {
    const taps = <(int, bool, int)>[
      (400, true, 1),
      (1150, false, 1),
      (1900, true, 2),
      (2650, false, 2),
      (3400, true, 1),
      (4150, false, 1),
      (4900, true, 0),
      (5650, false, 0),
    ];
    for (final (ms, expressive, index) in taps) {
      _at(ms, () {
        if (expressive) {
          _tapKey(_navKeys[0], fx: (index + .5) / 3, holdMs: 200);
        } else {
          _tapKey(_navKeys[1], fx: (index + .5) / 3, holdMs: 200);
        }
      });
    }
  }

  Widget _navigationScene() {
    const names = ['Home', 'Search', 'Saved'];
    const destinations = [
      MorphNavigationBarDestination(icon: MorphIcons.home, label: 'Home'),
      MorphNavigationBarDestination(icon: MorphIcons.search, label: 'Search'),
      MorphNavigationBarDestination(
        icon: MorphIcons.favorite_border,
        label: 'Saved',
      ),
    ];
    return SizedBox(
      width: 584,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 584,
            child: _labelWithValue(
              'Expressive bar · shared elastic selection',
              names[_expressiveNavigationIndex],
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            key: _navKeys[0],
            width: 584,
            child: MorphNavigationBar.expressive(
              key: const ValueKey('gif_navigation_expressive_bar'),
              safeArea: false,
              autoLayout: false,
              selectedIndex: _expressiveNavigationIndex,
              onDestinationSelected: (index) =>
                  setState(() => _expressiveNavigationIndex = index),
              destinations: destinations,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: 584,
            child: _labelWithValue(
              'Morph bar · sliding top indicator',
              names[_morphNavigationIndex],
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            key: _navKeys[1],
            width: 584,
            child: MorphNavigationBar.morph(
              key: const ValueKey('gif_navigation_morph_bar'),
              safeArea: false,
              iconSize: 32,
              unselectedIconScale: 0.9,
              selectedIndex: _morphNavigationIndex,
              onDestinationSelected: (index) =>
                  setState(() => _morphNavigationIndex = index),
              destinations: destinations,
            ),
          ),
          const SizedBox(height: 22),
          _captureLabel('Page indicators · follow the bars above'),
          const SizedBox(height: 5),
          Row(
            children: [
              MorphPageIndicator(
                key: const ValueKey('gif_page_expand'),
                count: 3,
                selectedIndex: _expressiveNavigationIndex,
                activeWidth: 34,
                inactiveWidth: 12,
                height: 14,
                inactiveHeight: 12,
                spacing: 4,
              ),
              const SizedBox(width: 34),
              MorphPageIndicator(
                key: const ValueKey('gif_page_slide'),
                count: 3,
                selectedIndex: _morphNavigationIndex,
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
    );
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
    _dropdownMulti.dispose();
    _loadingClock.dispose();
    _underlineController.dispose();
    _pillController.dispose();
    _fab.dispose();
    _captureCursor.value = null;
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
    if (widget.scene == 'frosted') {
      // Full-bleed backdrop: the scene lays out its own title and watermark.
      return FrostedGifScene(
        key: const ValueKey('morph_gif_frosted'),
        delayMs: _delayMs,
      );
    }
    final morph = MorphTheme.of(context);
    final scheme = morph.colorScheme;
    final (title, subtitle) = switch (widget.scene) {
      'buttons' => ('Buttons', 'Five styles · shape buttons'),
      'dropdown' => ('Dropdown', 'Open, hover, select, close'),
      'segmented' => (
        'Segmented',
        'Toggle · segmented button · connected group',
      ),
      'textfields' => ('Text fields', 'Typing, focus, floating label, error'),
      'chips' => ('Chips', 'Filter · input · assist · group'),
      'sliders' => ('Sliders', 'Drag to change the value'),
      'loading' => ('Loading', 'Loading indicator and progress'),
      'navigation' => ('Navigation', 'Tap to change destination'),
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
      'variants' => (
        'Variants',
        'primary · secondary · tertiary · muted · danger',
      ),
      'density' => ('Density', 'One theme switch · nothing else changes'),
      'context_menu' => ('Context menu', 'Desktop secondary click and submenu'),
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
        if (widget.scene == 'density')
          Positioned(
            top: 18,
            right: 28,
            child: Text(
              'density: .${_density.name}',
              style: (morph.textTheme.titleSmall ?? const TextStyle()).copyWith(
                color: scheme.primary,
              ),
            ),
          ),
        if (widget.scene == 'loading')
          Positioned(
            top: 18,
            right: 28,
            child: AnimatedBuilder(
              animation: _loadingClock,
              builder: (context, _) => Text(
                'Progress ${(_loadingProgress() * 100).round()}%',
                style: (morph.textTheme.titleSmall ?? const TextStyle())
                    .copyWith(color: scheme.primary),
              ),
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

  Widget _variantsScene() {
    const variants = [
      (MorphVariant.primary, 'primary'),
      (MorphVariant.secondary, 'secondary'),
      (MorphVariant.tertiary, 'tertiary'),
      (MorphVariant.muted, 'muted'),
      (MorphVariant.danger, 'danger'),
    ];
    return SizedBox(
      width: 584,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final (row, (variant, name)) in variants.indexed)
            Padding(
              padding: const EdgeInsets.only(bottom: 2),
              // Scales down only when a wider fallback font would overflow.
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(width: 96, child: _captureLabel('.$name')),
                    MorphButton.filled(
                      key: _variantKeys[row * 5],
                      variant: variant,
                      label: const Text('Filled'),
                      onPressed: () {},
                    ),
                    const SizedBox(width: 24),
                    MorphButton.tonal(
                      key: _variantKeys[row * 5 + 1],
                      variant: variant,
                      label: const Text('Tonal'),
                      onPressed: () {},
                    ),
                    const SizedBox(width: 24),
                    MorphButton.outlined(
                      key: _variantKeys[row * 5 + 2],
                      variant: variant,
                      label: const Text('Outlined'),
                      onPressed: () {},
                    ),
                    const SizedBox(width: 24),
                    MorphButton.text(
                      key: _variantKeys[row * 5 + 3],
                      variant: variant,
                      child: const Text('Text'),
                      onPressed: () {},
                    ),
                    const SizedBox(width: 24),
                    MorphIconButton.tonal(
                      key: _variantKeys[row * 5 + 4],
                      variant: variant,
                      icon: Icon(FluentIcons.line.heart),
                      semanticLabel: 'Favorite',
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// The same small set of real widgets under one theme whose only change is
  /// `density`; texts, colours, variants and sizes stay as they are.
  Widget _densityScene() {
    final base = MorphTheme.of(context);
    return MorphTheme(
      data: base.copyWith(density: _density),
      child: Builder(
        builder: (context) => Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 292,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _captureLabel('Buttons'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      MorphButton.filled(
                        label: const Text('Save'),
                        onPressed: () {},
                      ),
                      MorphButton.tonal(
                        label: const Text('Share'),
                        onPressed: () {},
                      ),
                      MorphButton.outlined(
                        label: const Text('Cancel'),
                        onPressed: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _captureLabel('Chips'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final (label, selected) in const [
                        ('Daily', true),
                        ('Weekly', false),
                        ('Monthly', false),
                      ])
                        MorphChip(
                          label: label,
                          type: MorphChipType.filter,
                          selected: selected,
                          onPressed: () {},
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _captureLabel('Text field'),
                  const SizedBox(height: 8),
                  MorphTextField(
                    label: 'Email',
                    placeholder: 'name@example.com',
                    variant: MorphTextFieldVariant.outlined,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _captureLabel('List rows'),
                  const SizedBox(height: 8),
                  for (final (title, subtitle) in const [
                    ('Quarterly report', 'Updated today'),
                    ('Design tokens', 'Updated yesterday'),
                    ('Release notes', 'Updated last week'),
                  ])
                    MorphListItem(
                      headline: title,
                      supportingText: subtitle,
                      leading: const Icon(MorphIcons.star),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<MorphMenuNode> _fileMenu() => <MorphMenuNode>[
    MorphMenuEntry(
      label: 'Open',
      leading: Icon(FluentIcons.line.folder_open),
      trailingText: 'Enter',
      value: 'open',
    ),
    MorphMenuEntry(
      label: 'Rename',
      leading: Icon(FluentIcons.line.edit),
      trailingText: 'F2',
      value: 'rename',
    ),
    MorphMenuEntry(
      label: 'Copy',
      leading: Icon(FluentIcons.line.copy),
      trailingText: 'Ctrl+C',
      value: 'copy',
    ),
    MorphMenuSubmenu(
      label: 'Move to',
      leading: Icon(FluentIcons.line.folder_arrow_right),
      children: const <MorphMenuNode>[
        MorphMenuEntry(label: 'Documents', value: 'Documents'),
        MorphMenuEntry(label: 'Projects', value: 'Projects'),
        MorphMenuEntry(label: 'Archive', value: 'Archive'),
      ],
    ),
    const MorphMenuDivider(),
    MorphMenuEntry(
      label: 'Delete',
      leading: Icon(FluentIcons.line.delete),
      isDestructive: true,
      value: 'delete',
    ),
  ];

  Widget _contextMenuScene() {
    const files = [
      ('Quarterly report.pdf', 'PDF · 2.4 MB'),
      ('Meeting notes.md', 'Markdown · 12 KB'),
      ('Design tokens.json', 'JSON · 38 KB'),
    ];
    return SizedBox(
      width: 584,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final (i, (name, detail)) in files.indexed)
            MorphContextMenuRegion<String>(
              onSelected: (value) => setState(
                () => _menuStatus = switch (value) {
                  'Documents' ||
                  'Projects' ||
                  'Archive' => 'Moved $name to $value',
                  _ => '$value: $name',
                },
              ),
              children: _fileMenu(),
              child: MorphListItem(
                key: _fileKeys[i],
                headline: name,
                supportingText: detail,
                leading: Icon(FluentIcons.line.document),
              ),
            ),
          const SizedBox(height: 12),
          Text(
            _menuStatus,
            style:
                (MorphTheme.of(context).textTheme.labelLarge ??
                        const TextStyle())
                    .copyWith(
                      color: _menuStatus.startsWith('Moved')
                          ? MorphTheme.of(context).colorScheme.primary
                          : MorphTheme.of(context).colorScheme.onSurfaceVariant,
                    ),
          ),
        ],
      ),
    );
  }

  Widget _content() => switch (widget.scene) {
    'buttons' => _buttonsScene(),
    'dropdown' => _dropdownScene(),
    'segmented' => _segmentedScene(),
    'textfields' => _textfieldsScene(),
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
    'chips' => _chipsScene(),
    'sliders' => _slidersScene(),
    'navigation' => _navigationScene(),
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
    'loading' => _loadingScene(),
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
    'variants' => _variantsScene(),
    'density' => _densityScene(),
    'context_menu' => _contextMenuScene(),
    _ => const SizedBox.shrink(),
  };
}
