import 'dart:math' as math;
import 'dart:async' show Timer;
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:material_ui/material_ui.dart'
    show
        AnimationController,
        AnimationStatus,
        AppBar,
        BoxConstraints,
        BuildContext,
        Canvas,
        Center,
        Color,
        Colors,
        Column,
        ConstrainedBox,
        CrossAxisAlignment,
        CustomPaint,
        CustomPainter,
        DropdownButton,
        DropdownMenuItem,
        EdgeInsets,
        Icon,
        IconButton,
        ListView,
        Offset,
        Padding,
        Paint,
        PaintingStyle,
        Scaffold,
        SingleChildScrollView,
        SingleTickerProviderStateMixin,
        Size,
        SizedBox,
        State,
        StatefulWidget,
        Text,
        TextOverflow,
        ValueChanged,
        VoidCallback,
        Widget,
        Wrap,
        GlobalKey,
        KeyedSubtree,
        Scrollable,
        WidgetsBinding;
import 'package:morph_expressive/morph_expressive.dart';

import 'shape_lab_sections.dart';

/// Deterministic 2D geometry and input workbench. No simulated performance data.
class ShapeMorphLab extends StatefulWidget {
  const ShapeMorphLab({super.key, this.onToggleTheme, this.onSeedChanged});
  final VoidCallback? onToggleTheme;
  final ValueChanged<Color>? onSeedChanged;
  @override
  State<ShapeMorphLab> createState() => _ShapeMorphLabState();
}

class _ShapeMorphLabState extends State<ShapeMorphLab>
    with SingleTickerProviderStateMixin {
  late final AnimationController _clock;
  MorphShapeKind _a = MorphShapeKind.cookie7Sided,
      _b = MorphShapeKind.softBurst;
  late MorphPreparedGeometry _morph;
  final _ellipse = MorphShape.ellipse(width: 1, height: .64);
  final _ellipseTarget = MorphShape.ellipse(width: .64, height: 1);
  Timer? _scheduledChange;

  /// Direct section links: `?lab=shapes&section=buttons|edges|groups|loader`
  /// (web) or `--dart-define=MORPH_LAB_SECTION=...` (native).
  final _keys = {
    for (final n in [
      'buttons',
      'edges',
      'groups',
      'loader',
      'components',
      'fab',
      'menus',
    ])
      n: GlobalKey(),
  };
  MorphShapeRenderer _renderer = MorphShapeRenderer.canvas;
  MorphShapeRenderStatus? _status;
  double _progress = 0,
      _duration = 900,
      _rotation = 0,
      _size = 160,
      _aspect = 1;
  double _press = 90, _release = 160, _interval = 650;
  bool _reduced = false, _inspect = false;
  bool _customLoader = false, _manual = false, _rapid = false;
  int _actions = 0, _longPresses = 0, _rapidIndex = 0;
  @override
  void initState() {
    super.initState();
    _morph = const MorphGeometryEngine().prepare(
      _a.geometry.contour,
      _b.geometry.contour,
    );
    final section =
        Uri.base.queryParameters['section'] ??
        const String.fromEnvironment('MORPH_LAB_SECTION', defaultValue: '');
    final section2 = section.isNotEmpty || kIsWeb
        ? section
        : Platform.environment['MORPH_LAB_SECTION'] ?? '';
    if (_keys.containsKey(section2)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final ctx = _keys[section2]?.currentContext;
        if (ctx != null) Scrollable.ensureVisible(ctx);
      });
    }
    _clock =
        AnimationController(
            vsync: this,
            duration: Duration(milliseconds: _duration.round()),
          )
          ..addListener(() {
            setState(() => _progress = _clock.value);
          })
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed && _rapid && !_reduced) {
              _retarget(MorphShapeKind.values[(_rapidIndex++ * 7) % 35]);
            }
          });
  }

  void _retarget(MorphShapeKind next) {
    final visible = _morph.at(_progress);
    _clock.stop();
    _morph = const MorphGeometryEngine().prepare(
      visible,
      next.geometry.contour,
    );
    setState(() {
      _b = next;
      _progress = 0;
    });
    _clock.duration = Duration(milliseconds: _duration.round());
    if (!_reduced) _clock.forward(from: 0);
  }

  void _pair() {
    _clock.stop();
    _morph = const MorphGeometryEngine().prepare(
      _a.geometry.contour,
      _b.geometry.contour,
    );
    setState(() => _progress = 0);
    _clock.value = 0;
  }

  @override
  void dispose() {
    _scheduledChange?.cancel();
    _clock.dispose();
    super.dispose();
  }

  Widget _section(String title, List<Widget> children) => Padding(
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
  Widget _slider(
    String label,
    double value,
    double min,
    double max,
    ValueChanged<double> update,
  ) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('$label · ${value.toStringAsFixed(label == 'Progress' ? 2 : 0)}'),
      MorphSlider(
        value: value,
        min: min,
        max: max,
        semanticLabel: label,
        onChanged: update,
      ),
    ],
  );
  Widget _toggle(String label, bool value, ValueChanged<bool> update) =>
      MorphButton.tonal(
        onPressed: () => update(!value),
        child: Text('${value ? '✓ ' : ''}$label'),
      );
  Widget _selector(
    String label,
    MorphShapeKind value,
    ValueChanged<MorphShapeKind> update,
  ) => SizedBox(
    width: 280,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        DropdownButton<MorphShapeKind>(
          icon: Icon(FluentIcons.line.chevron_down),
          isExpanded: true,
          value: value,
          items: MorphShapeKind.values
              .map(
                (s) => DropdownMenuItem(
                  value: s,
                  child: Text(
                    '${s.name} · ${s.geometry.provenance.name}',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
              .toList(),
          onChanged: (s) {
            if (s != null) update(s);
          },
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    final scheme = MorphTheme.of(context).colorScheme;
    final contour = _morph.at(_progress);
    return MorphMotionScope(
      reduceMotion: _reduced,
      child: Scaffold(
        backgroundColor: scheme.surface,
        appBar: AppBar(
          title: const Text('Shape & Interaction Lab'),
          actions: [
            IconButton(
              tooltip: 'Switch theme',
              onPressed: widget.onToggleTheme,
              icon: Icon(FluentIcons.line.weather_sunny),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _toggle('Reduced motion', _reduced, (v) {
                        _clock.stop();
                        setState(() => _reduced = v);
                      }),
                      MorphButton.text(
                        onPressed: () =>
                            widget.onSeedChanged?.call(Colors.teal),
                        child: const Text('Teal seed'),
                      ),
                      MorphButton.text(
                        onPressed: () =>
                            widget.onSeedChanged?.call(Colors.deepPurple),
                        child: const Text('Purple seed'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  KeyedSubtree(
                    key: _keys['buttons'],
                    child: const ShapeButtonLab(),
                  ),
                  _section('A · Geometry', [
                    Wrap(
                      spacing: 24,
                      runSpacing: 16,
                      children: [
                        _selector('Shape A', _a, (v) {
                          _a = v;
                          _pair();
                        }),
                        _selector('Shape B', _b, (v) {
                          _b = v;
                          _pair();
                        }),
                      ],
                    ),
                    const Text(
                      '9 native fixed cubic definitions · 26 public-API adaptations. '
                      'Rounding/smoothing controls are unavailable for these fixed definitions.',
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: CustomPaint(
                        foregroundPainter: _inspect
                            ? _InspectionPainter(contour)
                            : null,
                        child: MorphShapeView(
                          shape: _a.geometry,
                          contour: contour,
                          size: Size(_size, _size / _aspect),
                          rotationRadians: _rotation * math.pi / 180,
                          color: scheme.primary,
                          renderer: _renderer,
                          onRendererChanged: (s) => setState(() => _status = s),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _slider('Progress', _progress, 0, 1, (v) {
                      _clock.stop();
                      setState(() => _progress = v);
                    }),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        MorphButton(
                          onPressed: () {
                            if (_clock.isAnimating) {
                              _clock.stop();
                              setState(() {});
                            } else if (!_reduced) {
                              _clock.duration = Duration(
                                milliseconds: _duration.round(),
                              );
                              _clock.forward(
                                from: _progress == 1 ? 0 : _progress,
                              );
                            }
                          },
                          child: Text(_clock.isAnimating ? 'Pause' : 'Play'),
                        ),
                        MorphButton.tonal(
                          onPressed: () {
                            _clock.stop();
                            final old = _morph;
                            _morph = const MorphGeometryEngine().prepare(
                              old.end,
                              old.start,
                            );
                            setState(() => _progress = 1 - _progress);
                          },
                          child: const Text('Reverse'),
                        ),
                        MorphButton.tonal(
                          onPressed: () => _retarget(MorphShapeKind.pentagon),
                          child: const Text('Retarget C'),
                        ),
                        _toggle('Rapid targets', _rapid, (v) {
                          setState(() => _rapid = v);
                          if (v) _retarget(MorphShapeKind.sunny);
                        }),
                        _toggle(
                          'Inspect cubics',
                          _inspect,
                          (v) => setState(() => _inspect = v),
                        ),
                      ],
                    ),
                    _slider(
                      'Duration ms',
                      _duration,
                      100,
                      2400,
                      (v) => setState(() => _duration = v),
                    ),
                    _slider(
                      'Rotation degrees',
                      _rotation,
                      0,
                      360,
                      (v) => setState(() => _rotation = v),
                    ),
                    _slider(
                      'Size dp',
                      _size,
                      64,
                      240,
                      (v) => setState(() => _size = v),
                    ),
                    _slider(
                      'Aspect ratio',
                      _aspect,
                      .6,
                      2,
                      (v) => setState(() => _aspect = v),
                    ),
                  ]),
                  _section('B · Canvas / Shader', [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: MorphShapeRenderer.values
                          .map(
                            (r) => MorphButton.tonal(
                              onPressed: () => setState(() => _renderer = r),
                              child: Text(r.name),
                            ),
                          )
                          .toList(),
                    ),
                    Text(
                      'Requested: ${_renderer.name} · Effective: ${_status?.effective.name ?? 'canvas'}',
                    ),
                    Text(_status?.reason ?? 'Canvas reference'),
                    const SizedBox(height: 16),
                    const Text(
                      'Supported procedural ellipse below. Catalog/captured contours use Canvas. '
                      'Both samples share geometry, color, size and rotation.',
                    ),
                    Wrap(
                      spacing: 24,
                      runSpacing: 16,
                      children: [
                        _ellipseSample('Canvas', MorphShapeRenderer.canvas),
                        _ellipseSample(
                          'Shader request',
                          MorphShapeRenderer.shader,
                        ),
                      ],
                    ),
                  ]),
                  _section('C · Existing buttons', [
                    Text(
                      'Activations: $_actions · Long presses: $_longPresses. Down does not activate.',
                    ),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        MorphButton.tonal(
                          onPressed: () => setState(() {
                            _press = 90;
                            _release = 160;
                          }),
                          child: const Text('90 / 160'),
                        ),
                        MorphButton.tonal(
                          onPressed: () => setState(() {
                            _press = 165;
                            _release = 380;
                          }),
                          child: const Text('165 / 380'),
                        ),
                      ],
                    ),
                    _slider(
                      'Press ms',
                      _press,
                      0,
                      400,
                      (v) => setState(() => _press = v),
                    ),
                    _slider(
                      'Release ms',
                      _release,
                      0,
                      600,
                      (v) => setState(() => _release = v),
                    ),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        for (final style in MorphButtonStyle.values)
                          MorphButton(
                            style: style,
                            decoration: MorphButtonDecoration(
                              pressDuration: Duration(
                                milliseconds: _press.round(),
                              ),
                              releaseDuration: Duration(
                                milliseconds: _release.round(),
                              ),
                            ),
                            onPressed: () => setState(() => _actions++),
                            child: Text(style.name),
                          ),
                        MorphButton(
                          onPressed: null,
                          onLongPress: () => setState(() => _longPresses++),
                          child: const Text('Long press only'),
                        ),
                        const MorphButton(
                          onPressed: null,
                          enabled: false,
                          child: Text('Disabled'),
                        ),
                        MorphButton(
                          shape: MorphButtonShape.square,
                          onPressed: () => setState(() => _actions++),
                          icon: Icon(FluentIcons.line.heart),
                          label: const Text('Icon + label'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 144,
                      child: ListView.builder(
                        itemCount: 12,
                        itemBuilder: (context, i) => Padding(
                          padding: const EdgeInsets.all(4),
                          child: MorphButton(
                            onPressed: () => setState(() => _actions++),
                            child: Text('Scroll cancellation $i'),
                          ),
                        ),
                      ),
                    ),
                  ]),
                  _section('D · LoadingIndicator', [
                    Wrap(
                      spacing: 24,
                      runSpacing: 16,
                      children: [
                        for (final variant
                            in MorphLoadingIndicatorVariant.values)
                          MorphLoadingIndicator(
                            variant: variant,
                            size: 80,
                            morphInterval: Duration(
                              milliseconds: _interval.round(),
                            ),
                            rotationTurns: _manual ? _progress : null,
                            renderer: _renderer,
                            shapes: _customLoader
                                ? [
                                    MorphShapeCatalog.circle,
                                    MorphShapeCatalog.cookie7Sided,
                                    MorphShapeCatalog.pentagon,
                                  ]
                                : null,
                            indicatorColors: [
                              scheme.primary,
                              scheme.tertiary,
                              scheme.secondary,
                            ],
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _toggle(
                          'Change sequence live',
                          _customLoader,
                          (v) => setState(() => _customLoader = v),
                        ),
                        _toggle(
                          'Manual rotation (progress turns)',
                          _manual,
                          (v) => setState(() => _manual = v),
                        ),
                      ],
                    ),
                    _slider(
                      'Interval between starts ms',
                      _interval,
                      100,
                      1600,
                      (v) => setState(() => _interval = v),
                    ),
                    const Text(
                      'Morph response: legacy spring. Interval is not morph duration.',
                    ),
                  ]),
                  KeyedSubtree(
                    key: _keys['loader'],
                    child: const LoaderInsetLab(),
                  ),
                  KeyedSubtree(
                    key: _keys['edges'],
                    child: const EdgeQualityLab(),
                  ),
                  KeyedSubtree(
                    key: _keys['components'],
                    child: const ComponentEdgesLab(),
                  ),
                  KeyedSubtree(key: _keys['fab'], child: const FabMenuLab()),
                  KeyedSubtree(
                    key: _keys['menus'],
                    child: const MenuHoverLab(),
                  ),
                  KeyedSubtree(
                    key: _keys['groups'],
                    child: const ConnectedGroupLab(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _ellipseSample(String label, MorphShapeRenderer renderer) => Column(
    children: [
      Text(label),
      const SizedBox(height: 8),
      MorphShapeView(
        shape: _ellipse,
        targetShape: _ellipseTarget,
        progress: _progress,
        size: const Size(120, 120),
        rotationRadians: _rotation * math.pi / 180,
        renderer: renderer,
        onRendererChanged: renderer == MorphShapeRenderer.shader
            ? (s) => setState(() => _ellipseStatus = s)
            : null,
      ),
      if (renderer == MorphShapeRenderer.shader)
        Text(
          '${_ellipseStatus?.effective.name ?? 'loading'} · ${_ellipseStatus?.reason ?? ''}',
        ),
    ],
  );
  MorphShapeRenderStatus? _ellipseStatus;
}

class _InspectionPainter extends CustomPainter {
  _InspectionPainter(this.contour);
  final MorphContour contour;
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xffde5900)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    Offset p(Offset v) => Offset(v.dx * size.width, v.dy * size.height);
    for (final c in contour.curves) {
      canvas.drawLine(p(c.start), p(c.control1), paint);
      canvas.drawLine(p(c.end), p(c.control2), paint);
      canvas.drawCircle(p(c.start), 2, paint);
    }
    canvas.drawCircle(p(contour.curves.first.start), 5, paint);
  }

  @override
  bool shouldRepaint(_InspectionPainter old) => old.contour != contour;
}
