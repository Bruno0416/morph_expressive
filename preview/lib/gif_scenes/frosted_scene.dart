import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:material_ui/material_ui.dart'
    show
        AnimatedBuilder,
        AnimationController,
        Alignment,
        BuildContext,
        Canvas,
        Color,
        Column,
        CrossAxisAlignment,
        CustomPaint,
        CustomPainter,
        Element,
        GlobalKey,
        LinearGradient,
        Offset,
        Paint,
        PaintingStyle,
        Positioned,
        RRect,
        Radius,
        Rect,
        RenderBox,
        RepaintBoundary,
        Size,
        SingleTickerProviderStateMixin,
        SizedBox,
        Stack,
        State,
        StatefulWidget,
        Text,
        TextStyle,
        ValueKey,
        VoidCallback,
        Widget,
        WidgetsBinding;
import 'package:morph_expressive/morph_expressive.dart';

/// Showcase of the frosted (backdrop blur) finish, for the README GIF.
///
/// Three real components take part, each through its public glass API:
///
/// * [MorphCard] with an explicit `glass: MorphSurfaceGlass(...)`,
/// * [MorphDropdownMenu] with `glass:` (the opened panel),
/// * [MorphNavigationBar] with `glass: MorphNavigationGlass(...)`.
///
/// Soft geometric shapes drift slowly behind them. The clip lasts exactly one
/// period of that motion, so it loops without a seam, and every interaction is
/// a scripted pointer event on the real widgets (nothing is simulated inside
/// the components). The scene ends on the state it starts from.
class FrostedGifScene extends StatefulWidget {
  const FrostedGifScene({required this.delayMs, super.key});

  /// Time between the scene start marker and the first scripted event.
  final int delayMs;

  /// Period of the background motion, in milliseconds (the clip length).
  static const int periodMs = 7000;

  /// Glass of the card.
  static const MorphSurfaceGlass cardGlass = MorphSurfaceGlass(
    blurX: 16,
    blurY: 16,
    tint: Color(0xFF120E1C),
    tintOpacity: 0.34,
    borderColor: Color(0x44FFFFFF),
    borderWidth: 1,
  );

  /// Glass of the opened dropdown panel.
  static const MorphSurfaceGlass panelGlass = MorphSurfaceGlass(
    blurX: 16,
    blurY: 16,
    tint: Color(0xFF120E1C),
    tintOpacity: 0.36,
    borderColor: Color(0x44FFFFFF),
    borderWidth: 1,
  );

  /// Glass of the navigation bar.
  static const MorphNavigationGlass navigationGlass = MorphNavigationGlass(
    blurX: 16,
    blurY: 16,
    tint: Color(0xFF120E1C),
    tintOpacity: 0.34,
    borderColor: Color(0x44FFFFFF),
  );

  @override
  State<FrostedGifScene> createState() => _FrostedGifSceneState();
}

class _FrostedGifSceneState extends State<FrostedGifScene>
    with SingleTickerProviderStateMixin {
  final List<Timer> _timers = <Timer>[];
  final MorphDropdownController<String> _dropdown =
      MorphDropdownController<String>();
  final GlobalKey _fieldKey = GlobalKey();
  final GlobalKey _navKey = GlobalKey();
  late final AnimationController _clock = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: FrostedGifScene.periodMs),
  );
  int _destination = 0;
  int _pointer = 700;

  static const List<String> _destinations = <String>[
    'Home',
    'Explore',
    'Settings',
  ];

  @override
  void initState() {
    super.initState();
    _clock.repeat();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _script();
    });
  }

  void _at(int offsetMs, VoidCallback action) {
    _timers.add(
      Timer(Duration(milliseconds: widget.delayMs + offsetMs), () {
        if (mounted) action();
      }),
    );
  }

  void _after(int ms, VoidCallback action) {
    _timers.add(
      Timer(Duration(milliseconds: ms), () {
        if (mounted) action();
      }),
    );
  }

  Duration get _stamp =>
      Duration(milliseconds: DateTime.now().millisecondsSinceEpoch);

  void _tapAt(Offset at, {int holdMs = 160}) {
    final int id = _pointer++;
    final GestureBinding binding = GestureBinding.instance;
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

  Offset? _centerOf(GlobalKey key, {double fx = .5}) {
    final Object? box = key.currentContext?.findRenderObject();
    if (box is! RenderBox || !box.hasSize) return null;
    return box.localToGlobal(Offset(box.size.width * fx, box.size.height / 2));
  }

  /// The lowest on-screen [Text] equal to [text]: when the closed field shows
  /// the same label as a menu item, the item is the one further down.
  Offset? _lowestText(String text) {
    Offset? found;
    void visit(Element element) {
      final Object widget = element.widget;
      if (widget is Text && widget.data == text) {
        final Object? box = element.renderObject;
        if (box is RenderBox && box.hasSize && box.attached) {
          final Offset at = box.localToGlobal(box.size.center(Offset.zero));
          if (found == null || at.dy > found!.dy) found = at;
        }
      }
      element.visitChildren(visit);
    }

    WidgetsBinding.instance.rootElement?.visitChildren(visit);
    return found;
  }

  void _tapText(String text) {
    final Offset? at = _lowestText(text);
    if (at != null) _tapAt(at);
  }

  void _tapDestination(int index) {
    final Offset? at = _centerOf(_navKey, fx: (index + .5) / 3);
    if (at != null) _tapAt(at, holdMs: 200);
  }

  void _script() {
    // The clip starts and ends on the same state (Aurora, Home), so the
    // loop joins: the dropdown is opened twice, the navigation walks round.
    _at(400, () {
      final Offset? at = _centerOf(_fieldKey);
      if (at != null) _tapAt(at, holdMs: 140);
    });
    _at(1650, () => _tapText('Sunset'));
    _at(2350, () => _tapDestination(1));
    _at(2950, () => _tapDestination(2));
    _at(3550, () {
      final Offset? at = _centerOf(_fieldKey);
      if (at != null) _tapAt(at, holdMs: 140);
    });
    _at(4750, () => _tapText('Aurora'));
    _at(5650, () => _tapDestination(0));
  }

  @override
  void dispose() {
    for (final Timer timer in _timers) {
      timer.cancel();
    }
    _dropdown.dispose();
    _clock.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final MorphThemeData morph = MorphTheme.of(context);
    final scheme = morph.colorScheme;
    final TextStyle title = morph.textTheme.titleLarge ?? const TextStyle();
    final TextStyle caption = (morph.textTheme.bodySmall ?? const TextStyle())
        .copyWith(color: scheme.onSurfaceVariant);
    final TextStyle label = (morph.textTheme.labelMedium ?? const TextStyle())
        .copyWith(color: scheme.onSurfaceVariant, letterSpacing: 0.3);
    return Stack(
      children: <Widget>[
        Positioned.fill(
          child: RepaintBoundary(
            child: AnimatedBuilder(
              animation: _clock,
              builder: (BuildContext context, Widget? child) =>
                  CustomPaint(painter: _BackdropPainter(_clock.value)),
            ),
          ),
        ),
        Positioned(
          top: 16,
          left: 28,
          child: Text('Frosted surfaces', style: title),
        ),
        Positioned(
          top: 21,
          left: 214,
          child: Text('Blur over moving shapes', style: caption),
        ),
        Positioned(
          top: 66,
          left: 28,
          width: 344,
          child: MorphCard(
            key: const ValueKey<String>('gif_frosted_card'),
            glass: FrostedGifScene.cardGlass,
            headline: 'Card',
            subhead: _destinations[_destination],
            supportingText: 'Shapes keep drifting behind this surface.',
          ),
        ),
        Positioned(
          top: 248,
          left: 28,
          width: 344,
          child: SizedBox(
            key: _navKey,
            child: MorphNavigationBar.expressive(
              key: const ValueKey<String>('gif_frosted_navigation'),
              floating: true,
              glass: FrostedGifScene.navigationGlass,
              safeArea: false,
              autoLayout: false,
              selectedIndex: _destination,
              onDestinationSelected: (int index) =>
                  setState(() => _destination = index),
              destinations: const <MorphNavigationBarDestination>[
                MorphNavigationBarDestination(
                  icon: MorphIcons.home,
                  label: 'Home',
                ),
                MorphNavigationBarDestination(
                  icon: MorphIcons.search,
                  label: 'Explore',
                ),
                MorphNavigationBarDestination(
                  icon: MorphIcons.tune,
                  label: 'Settings',
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: 50,
          left: 396,
          width: 216,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Dropdown', style: label),
              const SizedBox(height: 8),
              SizedBox(
                key: _fieldKey,
                child: MorphDropdownMenu<String>(
                  key: const ValueKey<String>('gif_frosted_dropdown'),
                  controller: _dropdown,
                  singleSelect: true,
                  glass: FrostedGifScene.panelGlass,
                  // Translucent rows keep the blurred backdrop visible.
                  itemStyle: const MorphDropdownItemStyle(
                    backgroundColor: Color(0x14FFFFFF),
                    selectedBackgroundColor: Color(0x2EFFFFFF),
                  ),
                  fieldStyle: const MorphDropdownFieldStyle(
                    hintText: 'Choose a theme',
                  ),
                  items: const <MorphDropdownItem<String>>[
                    MorphDropdownItem<String>(
                      label: 'Aurora',
                      value: 'aurora',
                      selected: true,
                    ),
                    MorphDropdownItem<String>(label: 'Sunset', value: 'sunset'),
                    MorphDropdownItem<String>(label: 'Forest', value: 'forest'),
                  ],
                ),
              ),
            ],
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
}

/// Slow, seamless backdrop: crisp coloured shapes on a dark ground.
///
/// Every motion is periodic in the clock value `t` (0..1) with a whole number
/// of cycles, so the picture at `t = 1` equals the picture at `t = 0`.
class _BackdropPainter extends CustomPainter {
  const _BackdropPainter(this.t);

  final double t;

  static const Color _ground = Color(0xFF0D0A16);

  @override
  void paint(Canvas canvas, Size size) {
    final double scale = size.width / 640;
    canvas.drawRect(Offset.zero & size, Paint()..color = _ground);
    const double tau = math.pi * 2;

    Offset move(Offset base, Offset amp, double phase) => Offset(
      (base.dx + amp.dx * math.sin(tau * (t + phase))) * scale,
      (base.dy + amp.dy * math.cos(tau * (t + phase))) * scale,
    );

    void disc(Offset center, double radius, Color color) =>
        canvas.drawCircle(center, radius * scale, Paint()..color = color);

    void tile(
      Offset center,
      double side,
      double radius,
      double turns,
      Color color,
    ) {
      canvas
        ..save()
        ..translate(center.dx, center.dy)
        ..rotate(tau * turns);
      final double half = side * scale / 2;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTRB(-half, -half, half, half),
          Radius.circular(radius * scale),
        ),
        Paint()..color = color,
      );
      canvas.restore();
    }

    void bar(
      Offset center,
      double length,
      double thickness,
      double turns,
      Color color,
    ) {
      canvas
        ..save()
        ..translate(center.dx, center.dy)
        ..rotate(tau * turns);
      final double halfLength = length * scale / 2;
      final double halfThickness = thickness * scale / 2;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTRB(-halfLength, -halfThickness, halfLength, halfThickness),
          Radius.circular(halfThickness),
        ),
        Paint()..color = color,
      );
      canvas.restore();
    }

    // Behind the card.
    disc(
      move(const Offset(150, 168), const Offset(110, 30), 0),
      78,
      const Color(0xFF7352FF),
    );
    tile(
      move(const Offset(300, 190), const Offset(70, 40), .35),
      110,
      26,
      .25 * t,
      const Color(0xFFE0457B),
    );
    // Behind the dropdown field and its open panel.
    disc(
      move(const Offset(505, 166), const Offset(50, 30), .6),
      58,
      const Color(0xFF14B8A6),
    );
    canvas.drawCircle(
      move(const Offset(535, 222), const Offset(55, 24), .15),
      62 * scale,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 18 * scale
        ..color = const Color(0xFFF08A24),
    );
    // Behind the navigation bar.
    bar(
      move(const Offset(190, 282), const Offset(120, 14), .8),
      250,
      34,
      0,
      const Color(0xFF3B82F6),
    );
    bar(
      move(const Offset(330, 330), const Offset(110, 10), .3),
      150,
      26,
      -.5 * t,
      const Color(0xFFE0457B),
    );
    disc(
      move(const Offset(70, 300), const Offset(40, 18), .5),
      26,
      const Color(0xFFA3E635),
    );

    // Keeps the title legible: a dark fade from the top edge.
    final Rect top = Rect.fromLTWH(0, 0, size.width, 62 * scale);
    canvas.drawRect(
      top,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[Color(0xF00D0A16), Color(0x000D0A16)],
        ).createShader(top),
    );
  }

  @override
  bool shouldRepaint(_BackdropPainter oldDelegate) => oldDelegate.t != t;
}
