import 'dart:async' show Timer;
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;

import 'dart:math' as math;

import 'package:flutter/scheduler.dart' show timeDilation;

import 'package:material_ui/material_ui.dart'
    show
        BuildContext,
        Canvas,
        Color,
        BoxConstraints,
        Column,
        ConstrainedBox,
        AlignmentDirectional,
        Align,
        Alignment,
        ValueKey,
        ColoredBox,
        CrossAxisAlignment,
        CustomPaint,
        CustomPainter,
        Directionality,
        EdgeInsets,
        Icon,
        MediaQuery,
        Offset,
        Padding,
        Paint,
        PaintingStyle,
        Positioned,
        Size,
        SizedBox,
        Stack,
        State,
        StatefulWidget,
        StatelessWidget,
        Text,
        TextDirection,
        TextScaler,
        TickerMode,
        Transform,
        Widget,
        Wrap,
        WrapCrossAlignment;
import 'package:morph_expressive/morph_expressive.dart';

Widget _toggle(String label, bool value, void Function(bool) update) =>
    MorphButton.tonal(
      onPressed: () => update(!value),
      child: Text('${value ? '✓ ' : ''}$label'),
    );

Widget _slider(
  String label,
  double value,
  double min,
  double max,
  void Function(double) update, {
  int digits = 0,
}) => Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Text('$label · ${value.toStringAsFixed(digits)}'),
    MorphSlider(
      value: value,
      min: min,
      max: max,
      semanticLabel: label,
      onChanged: update,
    ),
  ],
);

class _Section extends StatelessWidget {
  const _Section(this.title, this.children);
  final String title;
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 32),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: MorphTheme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        ...children,
      ],
    ),
  );
}

/// Draws the control polygon, anchors and bounds of a contour, in the same
/// coordinates as the shape view. Inspection only, never used by components.
class ShapeInspectionPainter extends CustomPainter {
  ShapeInspectionPainter(this.contour, {this.rotation = 0});
  final MorphContour contour;
  final double rotation;
  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.rotate(rotation);
    canvas.translate(-size.width / 2, -size.height / 2);
    final line = Paint()
      ..color = const Color(0xffde5900)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    final box = Paint()
      ..color = const Color(0xff1a73e8)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    Offset p(Offset v) => Offset(v.dx * size.width, v.dy * size.height);
    for (final c in contour.curves) {
      canvas.drawLine(p(c.start), p(c.control1), line);
      canvas.drawLine(p(c.end), p(c.control2), line);
      canvas.drawCircle(p(c.start), 2, line);
    }
    canvas.drawCircle(p(contour.curves.first.start), 5, line);
    final b = contour.bounds;
    canvas.drawRect(
      p(b.topLeft) & Size(b.width * size.width, b.height * size.height),
      box,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(ShapeInspectionPainter old) =>
      old.contour != contour || old.rotation != rotation;
}

// ───────────────────────── Edge quality ─────────────────────────

enum _EdgeBackground { light, dark, transparent }

class EdgeQualityLab extends StatefulWidget {
  const EdgeQualityLab({super.key});
  @override
  State<EdgeQualityLab> createState() => _EdgeQualityLabState();
}

class _EdgeQualityLabState extends State<EdgeQualityLab> {
  MorphEdgeAntialias _mode = MorphEdgeAntialias.auto;
  _EdgeBackground _bg = _EdgeBackground.dark;
  bool _fraction = true, _inspect = false;
  double _progress = .5, _rotation = 0;
  MorphShapeRenderStatus? _shaderStatus;
  late final _pair = const MorphGeometryEngine().prepare(
    MorphShapeCatalog.fromKind(MorphShapeKind.clover4Leaf).contour,
    MorphShapeCatalog.fromKind(MorphShapeKind.gem).contour,
  );
  final _ellipse = MorphShape.ellipse(width: 1, height: .64);

  Color get _color => MorphTheme.of(context).colorScheme.primary;

  Widget _stage(Widget child, double size) {
    final dx = _fraction ? .37 : 0.0;
    final inner = Padding(
      padding: const EdgeInsets.all(6),
      child: Transform.translate(
        offset: Offset(dx, dx * .6),
        child: SizedBox(width: size, height: size, child: child),
      ),
    );
    return switch (_bg) {
      _EdgeBackground.light => ColoredBox(
        color: const Color(0xfff6f2fa),
        child: inner,
      ),
      _EdgeBackground.dark => ColoredBox(
        color: const Color(0xff141218),
        child: inner,
      ),
      _EdgeBackground.transparent => CustomPaint(
        painter: _Checker(),
        child: inner,
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final rot = _rotation * math.pi / 180;
    final contour = _pair.at(_progress);
    return _Section('B2 · Edge quality (Canvas vs Shader)', [
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final m in MorphEdgeAntialias.values)
            _toggle(m.name, _mode == m, (_) => setState(() => _mode = m)),
          for (final b in _EdgeBackground.values)
            _toggle('bg ${b.name}', _bg == b, (_) => setState(() => _bg = b)),
          _toggle(
            'Fractional position',
            _fraction,
            (v) => setState(() => _fraction = v),
          ),
          _toggle(
            'Inspect path/bounds',
            _inspect,
            (v) => setState(() => _inspect = v),
          ),
        ],
      ),
      const SizedBox(height: 8),
      Text(
        'Canvas edge mode: ${_mode.name} (auto = 8-sample coverage; native = plain drawPath) · '
        'Shader sample: ${_shaderStatus?.effective.name ?? 'loading'}'
        '${_shaderStatus?.reason == null ? '' : ' (${_shaderStatus!.reason})'}',
      ),
      _slider(
        'Progress',
        _progress,
        0,
        1,
        (v) => setState(() => _progress = v),
        digits: 2,
      ),
      _slider(
        'Rotation degrees',
        _rotation,
        -720,
        720,
        (v) => setState(() => _rotation = v),
      ),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final d in const [0.0, 359.999, 360.0, 360.001, 720.0, -360.0])
            MorphButton.tonal(
              onPressed: () => setState(() => _rotation = d),
              child: Text('$d°'),
            ),
        ],
      ),
      const SizedBox(height: 8),
      const Text('Ellipse: Canvas (left) vs Shader (right), same size/center.'),
      Wrap(
        spacing: 16,
        runSpacing: 16,
        children: [
          for (final s in const [24.0, 48.0, 96.0, 122.0]) ...[
            _stage(
              MorphShapeView(
                shape: _ellipse,
                size: Size(s, s),
                color: _color,
                rotationRadians: rot,
                edgeAntialias: _mode,
              ),
              s,
            ),
            _stage(
              MorphShapeView(
                shape: _ellipse,
                size: Size(s, s),
                color: _color,
                rotationRadians: rot,
                renderer: MorphShapeRenderer.shader,
                onRendererChanged: s == 122
                    ? (st) => setState(() => _shaderStatus = st)
                    : null,
              ),
              s,
            ),
          ],
        ],
      ),
      const SizedBox(height: 16),
      const Text('clover4Leaf → gem at the slider progress (Canvas path).'),
      Wrap(
        spacing: 16,
        runSpacing: 16,
        children: [
          for (final s in const [48.0, 96.0, 122.0, 160.0])
            _stage(
              CustomPaint(
                foregroundPainter: _inspect
                    ? ShapeInspectionPainter(contour, rotation: rot)
                    : null,
                child: MorphShapeView(
                  shape: MorphShapeCatalog.fromKind(MorphShapeKind.clover4Leaf),
                  contour: contour,
                  size: Size(s, s),
                  color: _color,
                  rotationRadians: rot,
                  edgeAntialias: _mode,
                ),
              ),
              s,
            ),
        ],
      ),
    ]);
  }
}

class _Checker extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final a = Paint()..color = const Color(0xffcccccc);
    final b = Paint()..color = const Color(0xff888888);
    const t = 8.0;
    for (var y = 0.0; y < size.height; y += t) {
      for (var x = 0.0; x < size.width; x += t) {
        canvas.drawRect(
          Offset(x, y) & const Size(t, t),
          ((x ~/ t + y ~/ t) % 2 == 0) ? a : b,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_Checker old) => false;
}

// ───────────────────────── Connected groups ─────────────────────────

class ConnectedGroupLab extends StatefulWidget {
  const ConnectedGroupLab({super.key});
  @override
  State<ConnectedGroupLab> createState() => _ConnectedGroupLabState();
}

class _ConnectedGroupLabState extends State<ConnectedGroupLab> {
  int? _week = 1, _numbers = 0, _long = 1;
  double _width = 520;
  bool _doubleText = false, _rtl = false, _autoWidth = true;
  double _itemWidth = 110;
  double? _gap;
  int? _extreme = 0;
  Timer? _rapid;
  int _rapidTick = 0;

  @override
  void dispose() {
    _rapid?.cancel();
    super.dispose();
  }

  void _startRapid() {
    _rapid?.cancel();
    _rapidTick = 0;
    _rapid = Timer.periodic(const Duration(milliseconds: 110), (t) {
      if (!mounted || ++_rapidTick > 12) {
        t.cancel();
        return;
      }
      setState(() => _week = _rapidTick % 3);
    });
  }

  Widget _group({
    required List<MorphButtonGroupAction> actions,
    required int? selected,
    required void Function(int?) onChanged,
  }) => Align(
    alignment: AlignmentDirectional.centerStart,
    child: ConstrainedBox(
      constraints: BoxConstraints(maxWidth: _width),
      child: MorphButtonGroup(
        type: MorphButtonGroupType.connected,
        overflow: MorphButtonGroupOverflow.none,
        neighborSquish: true,
        selectionRequired: true,
        selectedIndex: selected,
        itemWidth: _autoWidth ? null : _itemWidth,
        spacing: _gap,
        onSelectedIndexChanged: onChanged,
        actions: actions,
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final theme = MorphTheme.of(context).buttonGroupTheme;
    final media = MediaQuery.of(context);
    return _Section('F · Connected groups', [
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final (i, l) in ['Left', 'Center', 'Right'].indexed)
            MorphButton.tonal(
              onPressed: () => setState(() => _week = i),
              child: Text('Select $l'),
            ),
          MorphButton.tonal(
            onPressed: _startRapid,
            child: const Text('Rapid changes'),
          ),
          _toggle(
            'Text 2×',
            _doubleText,
            (v) => setState(() => _doubleText = v),
          ),
          _toggle('RTL', _rtl, (v) => setState(() => _rtl = v)),
          for (final g in const [null, 0.0, 4.0, 8.0])
            _toggle(
              g == null ? 'Gap: theme (4)' : 'Gap ${g.toStringAsFixed(0)} dp',
              _gap == g,
              (_) => setState(() => _gap = g),
            ),
          _toggle(
            'Automatic item width',
            _autoWidth,
            (v) => setState(() => _autoWidth = v),
          ),
        ],
      ),
      if (!_autoWidth)
        _slider(
          'Item width dp',
          _itemWidth,
          40,
          240,
          (v) => setState(() => _itemWidth = v),
        ),
      _slider(
        'Max group width dp',
        _width,
        160,
        640,
        (v) => setState(() => _width = v),
      ),
      const SizedBox(height: 8),
      MediaQuery(
        data: media.copyWith(
          textScaler: _doubleText
              ? const TextScaler.linear(2)
              : media.textScaler,
        ),
        child: Directionality(
          textDirection: _rtl ? TextDirection.rtl : TextDirection.ltr,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _group(
                actions: const [
                  MorphButtonGroupAction(label: Text('Day')),
                  MorphButtonGroupAction(label: Text('Week')),
                  MorphButtonGroupAction(label: Text('Month')),
                ],
                selected: _week,
                onChanged: (i) => setState(() => _week = i),
              ),
              const SizedBox(height: 16),
              _group(
                actions: const [
                  MorphButtonGroupAction(label: Text('One')),
                  MorphButtonGroupAction(label: Text('Two')),
                  MorphButtonGroupAction(label: Text('Three')),
                ],
                selected: _numbers,
                onChanged: (i) => setState(() => _numbers = i),
              ),
              const SizedBox(height: 16),
              _group(
                actions: [
                  MorphButtonGroupAction(
                    icon: Icon(FluentIcons.line.heart),
                    label: const Text('Favorites'),
                  ),
                  MorphButtonGroupAction(
                    icon: Icon(FluentIcons.line.play),
                    label: const Text('Recently played'),
                  ),
                  MorphButtonGroupAction(
                    icon: Icon(FluentIcons.line.pause),
                    label: const Text('Paused'),
                  ),
                ],
                selected: _long,
                onChanged: (i) => setState(() => _long = i),
              ),
              const SizedBox(height: 16),
              _group(
                actions: const [
                  MorphButtonGroupAction(label: Text('Short')),
                  MorphButtonGroupAction(
                    label: Text(
                      'An extraordinarily long label that cannot possibly fit',
                    ),
                  ),
                  MorphButtonGroupAction(label: Text('Tiny')),
                ],
                selected: _extreme,
                onChanged: (i) => setState(() => _extreme = i),
              ),
              const SizedBox(height: 16),
              for (final g in const [0.0, 4.0, 8.0]) ...[
                Text('Gap ${g.toStringAsFixed(0)} dp (spacing parameter)'),
                MorphButtonGroup(
                  type: MorphButtonGroupType.connected,
                  overflow: MorphButtonGroupOverflow.none,
                  spacing: g,
                  selectedIndex: 1,
                  selectionRequired: true,
                  onSelectedIndexChanged: (_) {},
                  actions: const [
                    MorphButtonGroupAction(label: Text('Day')),
                    MorphButtonGroupAction(label: Text('Week')),
                    MorphButtonGroupAction(label: Text('Month')),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ],
          ),
        ),
      ),
      const SizedBox(height: 12),
      Text(
        'Expected shape (read from the real group theme, 40 dp height): '
        'selected = pill (radius ${theme.connectedSelectedInnerRadiusFor(40).toStringAsFixed(0)}) at any position · '
        'unselected outer end = full radius · inner faces = '
        '${theme.connectedInnerRadiusFor(MorphButtonSize.sm).toStringAsFixed(0)} '
        '(pressed ${theme.connectedPressedInnerRadiusFor(MorphButtonSize.sm).toStringAsFixed(0)}).',
      ),
    ]);
  }
}

// ───────────────────────── Loader inset ─────────────────────────

class LoaderInsetLab extends StatefulWidget {
  const LoaderInsetLab({super.key});
  @override
  State<LoaderInsetLab> createState() => _LoaderInsetLabState();
}

class _LoaderInsetLabState extends State<LoaderInsetLab> {
  double _inset = 5, _interval = 650;
  bool _paused = false, _guide = true, _custom = false, _manual = false;
  double _turns = 0;

  @override
  Widget build(BuildContext context) {
    final scheme = MorphTheme.of(context).colorScheme;
    final shapes = _custom
        ? [
            MorphShapeCatalog.fromKind(MorphShapeKind.sunny),
            MorphShapeCatalog.fromKind(MorphShapeKind.softBurst),
            MorphShapeCatalog.fromKind(MorphShapeKind.gem),
            MorphShapeCatalog.fromKind(MorphShapeKind.pentagon),
          ]
        : null;
    Widget loader(MorphLoadingIndicatorVariant v, double size) => SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          MorphLoadingIndicator(
            variant: v,
            size: size,
            containedInset: _inset,
            morphInterval: Duration(milliseconds: _interval.round()),
            rotationTurns: _manual ? _turns : null,
            shapes: shapes,
            renderer: MorphShapeRenderer.auto,
          ),
          if (_guide && v == MorphLoadingIndicatorVariant.contained)
            Positioned.fill(
              child: CustomPaint(
                painter: _GuidePainter(size / 2 - _inset, scheme.error),
              ),
            ),
        ],
      ),
    );
    return _Section('D2 · Loader inset (contained vs plain)', [
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _toggle(
            'Pause (TickerMode)',
            _paused,
            (v) => setState(() => _paused = v),
          ),
          _toggle('Inset guide', _guide, (v) => setState(() => _guide = v)),
          _toggle(
            'Wide sequence (live)',
            _custom,
            (v) => setState(() => _custom = v),
          ),
          _toggle(
            'Manual rotation',
            _manual,
            (v) => setState(() => _manual = v),
          ),
        ],
      ),
      _slider(
        'Inset dp',
        _inset,
        0,
        12,
        (v) => setState(() => _inset = v),
        digits: 1,
      ),
      _slider(
        'Interval ms',
        _interval,
        300,
        1600,
        (v) => setState(() => _interval = v),
      ),
      if (_manual)
        _slider(
          'Turns',
          _turns,
          0,
          1,
          (v) => setState(() => _turns = v),
          digits: 2,
        ),
      const SizedBox(height: 8),
      TickerMode(
        enabled: !_paused,
        child: Wrap(
          spacing: 24,
          runSpacing: 24,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            for (final s in const [48.0, 96.0, 144.0]) ...[
              loader(MorphLoadingIndicatorVariant.defaultStyle, s),
              loader(MorphLoadingIndicatorVariant.contained, s),
            ],
          ],
        ),
      ),
    ]);
  }
}

class _GuidePainter extends CustomPainter {
  _GuidePainter(this.radius, this.color);
  final double radius;
  final Color color;
  @override
  void paint(Canvas canvas, Size size) => canvas.drawCircle(
    size.center(Offset.zero),
    radius,
    Paint()
      ..color = color.withValues(alpha: .6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = .75,
  );
  @override
  bool shouldRepaint(_GuidePainter old) =>
      old.radius != radius || old.color != color;
}

// ───────────────────────── Shape buttons ─────────────────────────

class ShapeButtonLab extends StatefulWidget {
  const ShapeButtonLab({super.key});
  @override
  State<ShapeButtonLab> createState() => _ShapeButtonLabState();
}

class _ShapeButtonLabState extends State<ShapeButtonLab> {
  bool _rotate = true, _ccw = false, _morph = false, _selected = false;
  bool _disabled = false, _inspect = false, _alternate = false;
  double _period = 8, _scale = .96, _pairProgress = .5;
  int _taps = 0;
  Timer? _scheduled;
  late final _pair = const MorphGeometryEngine().prepare(
    MorphShapeCatalog.cookie7Sided.contour,
    MorphShapeCatalog.softBurst.contour,
  );

  @override
  void dispose() {
    _scheduled?.cancel();
    super.dispose();
  }

  MorphShapeRotationDirection get _dir => _ccw
      ? MorphShapeRotationDirection.counterClockwise
      : MorphShapeRotationDirection.clockwise;

  Widget _labeled(String label, Widget child) => Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      child,
      const SizedBox(height: 8),
      SizedBox(width: 120, child: Text(label)),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final rest = _alternate
        ? MorphShapeCatalog.oval
        : MorphShapeCatalog.cookie7Sided;
    final period = Duration(milliseconds: (_period * 1000).round());
    final heart = Icon(FluentIcons.line.heart);
    return _Section('E · Shape buttons', [
      Text(
        'Taps: $_taps · down never activates · tap keeps the same shape unless morph opt-in is on.',
      ),
      const SizedBox(height: 16),
      Wrap(
        spacing: 32,
        runSpacing: 24,
        children: [
          _labeled(
            'Main: spin + press scale, same shape',
            MorphShapeButton(
              size: 96,
              shape: rest,
              rotationEnabled: _rotate,
              rotationDuration: period,
              rotationDirection: _dir,
              pressedScale: _scale,
              selected: _selected,
              selectedShape: _morph ? MorphShapeCatalog.pentagon : null,
              enabled: !_disabled,
              tooltip: 'Favorite',
              semanticLabel: 'Favorite',
              onPressed: () => setState(() {
                _taps++;
                _selected = !_selected;
              }),
              child: heart,
            ),
          ),
          _labeled(
            'Comparison: no rotation, press only',
            MorphShapeButton(
              size: 96,
              shape: rest,
              pressedScale: _scale,
              enabled: !_disabled,
              tooltip: 'Static',
              onPressed: () => setState(() => _taps++),
              child: heart,
            ),
          ),
          _labeled(
            'Opt-in: spin + pressedShape',
            MorphShapeButton(
              size: 96,
              shape: rest,
              pressedShape: MorphShapeCatalog.softBurst,
              rotationEnabled: _rotate,
              rotationDuration: period,
              rotationDirection: _dir,
              pressedScale: _scale,
              enabled: !_disabled,
              tooltip: 'Morph on press',
              onPressed: () => setState(() => _taps++),
              child: heart,
            ),
          ),
          _labeled(
            'Small 48 · spin',
            MorphShapeButton(
              size: 48,
              shape: MorphShapeCatalog.fromKind(MorphShapeKind.gem),
              rotationEnabled: _rotate,
              rotationDuration: period,
              rotationDirection: _dir,
              pressedScale: _scale,
              enabled: !_disabled,
              tooltip: 'Gem (spins inside its box)',
              onPressed: () => setState(() => _taps++),
              child: Icon(FluentIcons.line.play),
            ),
          ),
        ],
      ),
      const SizedBox(height: 16),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _toggle('Rotation', _rotate, (v) => setState(() => _rotate = v)),
          _toggle('Counter-clockwise', _ccw, (v) => setState(() => _ccw = v)),
          _toggle(
            'Selected shape morph (main)',
            _morph,
            (v) => setState(() => _morph = v),
          ),
          _toggle('Selected', _selected, (v) => setState(() => _selected = v)),
          _toggle('Disable', _disabled, (v) => setState(() => _disabled = v)),
          MorphButton.tonal(
            onPressed: () {
              _scheduled?.cancel();
              _scheduled = Timer(const Duration(milliseconds: 900), () {
                if (mounted) setState(() => _alternate = !_alternate);
              });
            },
            child: const Text('Change shape in 900 ms'),
          ),
          MorphButton.tonal(
            onPressed: () {
              _scheduled?.cancel();
              _scheduled = Timer(const Duration(milliseconds: 900), () {
                if (mounted) setState(() => _disabled = true);
              });
            },
            child: const Text('Disable in 900 ms'),
          ),
        ],
      ),
      _slider(
        'Rotation period s',
        _period,
        2,
        20,
        (v) => setState(() => _period = v),
        digits: 1,
      ),
      _slider(
        'Press scale',
        _scale,
        .8,
        1,
        (v) => setState(() => _scale = v),
        digits: 2,
      ),
      const SizedBox(height: 16),
      const Text(
        'Former diagonal-cut pair: cookie7Sided → softBurst (frozen).',
      ),
      _slider(
        'Pair progress',
        _pairProgress,
        0,
        1,
        (v) => setState(() => _pairProgress = v),
        digits: 2,
      ),
      Wrap(
        spacing: 16,
        runSpacing: 16,
        children: [
          _toggle(
            'Inspect path/control points',
            _inspect,
            (v) => setState(() => _inspect = v),
          ),
          for (final t in [_pairProgress, .25, .5, .75])
            CustomPaint(
              foregroundPainter: _inspect
                  ? ShapeInspectionPainter(_pair.at(t))
                  : null,
              child: MorphShapeView(
                shape: MorphShapeCatalog.cookie7Sided,
                contour: _pair.at(t),
                size: const Size(112, 112),
                color: MorphTheme.of(context).colorScheme.primary,
              ),
            ),
        ],
      ),
    ]);
  }
}

// ───────────────────────── Component edges ─────────────────────────

class ComponentEdgesLab extends StatefulWidget {
  const ComponentEdgesLab({super.key});
  @override
  State<ComponentEdgesLab> createState() => _ComponentEdgesLabState();
}

class _ComponentEdgesLabState extends State<ComponentEdgesLab> {
  double _slider = .45;
  @override
  Widget build(BuildContext context) {
    return _Section(
      'B3 · Component edges (sliders, progress, buttons, swipe)',
      [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final m in MorphSmoothEdgesMode.values)
              _toggle(
                'smooth edges: ${m.name}',
                MorphSmoothEdges.defaultMode == m,
                (_) => setState(() => MorphSmoothEdges.defaultMode = m),
              ),
          ],
        ),
        const Text(
          'Offscreen anti-aliasing for Material/third-party painters '
          '(auto = Linux desktop only). Compare disabled vs auto.',
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 24,
          runSpacing: 16,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SizedBox(
              width: 300,
              child: MorphSlider(
                value: _slider,
                onChanged: (v) => setState(() => _slider = v),
              ),
            ),
            SizedBox(
              width: 300,
              child: MorphSlider.wavy(
                value: _slider,
                onChanged: (v) => setState(() => _slider = v),
              ),
            ),
            const MorphProgressIndicator.circular(value: .62, size: 48),
            const MorphProgressIndicator.circularWavy(value: .55, size: 48),
            const SizedBox(
              width: 300,
              child: MorphProgressIndicator.linear(value: .62),
            ),
            const SizedBox(
              width: 300,
              child: MorphProgressIndicator.linearWavy(value: .55),
            ),
            MorphButton(
              onPressed: () {},
              child: const Text('Press for splash'),
            ),
            MorphButton.tonal(onPressed: () {}, child: const Text('Tonal')),
          ],
        ),
      ],
    );
  }
}

// ───────────────────────── FAB menu ─────────────────────────

class FabMenuLab extends StatefulWidget {
  const FabMenuLab({super.key});
  @override
  State<FabMenuLab> createState() => _FabMenuLabState();
}

class _FabMenuLabState extends State<FabMenuLab> {
  final _controller = MorphFabMenuController();
  MorphShapeRenderer _renderer = MorphShapeRenderer.auto;
  MorphShapeRenderStatus? _status;
  bool _slow = false;
  int _toggles = 0;
  Timer? _auto;

  @override
  void initState() {
    super.initState();
    // Diagnostic: MORPH_FAB_AUTO=1 opens at 1 s and closes at 9 s in x8 slow
    // motion so intermediate frames can be inspected on a real backend.
    if (!kIsWeb && Platform.environment['MORPH_FAB_AUTO'] != null) {
      timeDilation = 8;
      _auto = Timer(const Duration(seconds: 1), () {
        _controller.open();
        _auto = Timer(const Duration(seconds: 9), _controller.close);
      });
    }
  }

  @override
  void dispose() {
    _auto?.cancel();
    timeDilation = 1;
    _controller.dispose();
    super.dispose();
  }

  Future<void> _reverseMidway() async {
    _controller.open();
    await Future<void>.delayed(const Duration(milliseconds: 140));
    if (mounted) _controller.close();
  }

  Future<void> _rapid() async {
    for (var i = 0; i < 8 && mounted; i++) {
      _controller.toggle();
      setState(() => _toggles++);
      await Future<void>.delayed(Duration(milliseconds: 60 + (i % 3) * 40));
    }
  }

  @override
  Widget build(BuildContext context) {
    return _Section('H · FAB menu (one persistent surface)', [
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          MorphButton.tonal(
            onPressed: _controller.open,
            child: const Text('Open'),
          ),
          MorphButton.tonal(
            onPressed: _controller.close,
            child: const Text('Close'),
          ),
          MorphButton.tonal(
            onPressed: _reverseMidway,
            child: const Text('Open → reverse mid-flight'),
          ),
          MorphButton.tonal(
            onPressed: _rapid,
            child: const Text('Rapid toggles ×8'),
          ),
          _toggle('Slow motion ×6', _slow, (v) {
            setState(() => _slow = v);
            timeDilation = v ? 6 : 1;
          }),
          for (final r in MorphShapeRenderer.values)
            _toggle(
              'renderer ${r.name}',
              _renderer == r,
              (_) => setState(() => _renderer = r),
            ),
        ],
      ),
      Text(
        'Requested: ${_renderer.name} · Effective: ${_status?.effective.name ?? 'pending'}'
        '${_status?.reason == null ? '' : ' (${_status!.reason})'} · toggles: $_toggles',
      ),
      const SizedBox(height: 8),
      SizedBox(
        height: 420,
        child: Align(
          alignment: Alignment.bottomRight,
          child: MorphFabMenu(
            controller: _controller,
            renderer: _renderer,
            onRendererChanged: (s) => setState(() => _status = s),
            items: <MorphFabMenuItem>[
              MorphFabMenuItem(
                icon: Icon(FluentIcons.line.heart),
                label: 'Favorite',
              ),
              MorphFabMenuItem(
                icon: Icon(FluentIcons.line.play),
                label: 'Play',
              ),
              MorphFabMenuItem(
                icon: Icon(FluentIcons.line.pause),
                label: 'Pause',
              ),
            ],
          ),
        ),
      ),
    ]);
  }
}

// ───────────────────────── Menu hover ─────────────────────────

class MenuHoverLab extends StatefulWidget {
  const MenuHoverLab({super.key});
  @override
  State<MenuHoverLab> createState() => _MenuHoverLabState();
}

class _MenuHoverLabState extends State<MenuHoverLab> {
  MorphMenuSubmenuOpenMode _mode = MorphMenuSubmenuOpenMode.hover;
  double _delay = 200, _close = 250;
  String _last = 'none';

  @override
  Widget build(BuildContext context) {
    return _Section('I · Menu submenus (hover by default)', [
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final m in MorphMenuSubmenuOpenMode.values)
            _toggle(
              'open on ${m.name}',
              _mode == m,
              (_) => setState(() => _mode = m),
            ),
        ],
      ),
      _slider(
        'Hover delay ms',
        _delay,
        0,
        800,
        (v) => setState(() => _delay = v),
      ),
      _slider(
        'Close grace ms',
        _close,
        0,
        800,
        (v) => setState(() => _close = v),
      ),
      Text('Last selection: $_last (touch always uses tap)'),
      const SizedBox(height: 8),
      MorphMenu(
        key: ValueKey('$_mode$_delay$_close'),
        submenuBehavior: MorphMenuSubmenuBehavior(
          mode: _mode,
          hoverDelay: Duration(milliseconds: _delay.round()),
          closeDelay: Duration(milliseconds: _close.round()),
        ),
        onSelected: (v) => setState(() => _last = '$v'),
        anchorBuilder: (context, open) =>
            MorphButton.tonal(onPressed: open, child: const Text('Open menu')),
        children: const <MorphMenuNode>[
          MorphMenuEntry(label: 'Open', value: 'open'),
          MorphMenuSubmenu(
            label: 'Move to',
            children: <MorphMenuNode>[
              MorphMenuEntry(label: 'Design', value: 'design'),
              MorphMenuEntry(label: 'Product', value: 'product'),
              MorphMenuSubmenu(
                label: 'Archive',
                children: <MorphMenuNode>[
                  MorphMenuEntry(label: '2025', value: 'a2025'),
                  MorphMenuEntry(label: '2026', value: 'a2026'),
                ],
              ),
            ],
          ),
          MorphMenuSubmenu(
            label: 'Share',
            children: <MorphMenuNode>[
              MorphMenuEntry(label: 'Link', value: 'link'),
              MorphMenuEntry(label: 'Email', value: 'email'),
            ],
          ),
          MorphMenuEntry(label: 'Delete', value: 'delete'),
        ],
      ),
    ]);
  }
}
