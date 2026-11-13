import 'dart:async' show Timer;

import 'package:material_ui/material_ui.dart'
    show
        BuildContext,
        Center,
        Color,
        Colors,
        Column,
        Key,
        MaterialApp,
        Size,
        Row,
        Scaffold,
        SizedBox,
        State,
        StatefulWidget,
        Text,
        ValueKey,
        Widget;
import 'package:morph_expressive/morph_expressive.dart';

/// Diagnostic harness (`--dart-define=MORPH_EDGE_STRESS=true`): a live
/// [MorphShapeView] that receives a scripted sequence of parameter changes next
/// to a freshly mounted one with the same configuration. Differences between
/// both columns reveal state that survives a change.
class EdgeStressApp extends StatefulWidget {
  const EdgeStressApp({super.key});
  @override
  State<EdgeStressApp> createState() => _EdgeStressAppState();
}

class _Step {
  const _Step(
    this.renderer,
    this.shape, {
    this.target,
    this.progress = 0,
    this.size = 96,
    this.rotation = 0,
    this.color = const Color(0xffb69df8),
    this.captured = false,
    this.edge = MorphEdgeAntialias.auto,
  });
  final MorphShapeRenderer renderer;
  final MorphShape shape;
  final MorphShape? target;
  final double progress, size, rotation;
  final Color color;
  final bool captured;
  final MorphEdgeAntialias edge;
}

class _EdgeStressAppState extends State<EdgeStressApp> {
  late final List<_Step> _steps;
  int _i = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    final e = MorphShape.ellipse(width: 1, height: .64);
    final e2 = MorphShape.ellipse(width: .64, height: 1);
    final clover = MorphShapeCatalog.fromKind(MorphShapeKind.clover4Leaf);
    final gem = MorphShapeCatalog.fromKind(MorphShapeKind.gem);
    _steps = [
      _Step(MorphShapeRenderer.canvas, e),
      _Step(MorphShapeRenderer.shader, e),
      _Step(MorphShapeRenderer.shader, clover),
      _Step(MorphShapeRenderer.auto, e, target: e2, progress: .4),
      _Step(
        MorphShapeRenderer.auto,
        clover,
        target: gem,
        progress: .5,
        rotation: .7,
      ),
      _Step(MorphShapeRenderer.shader, e, size: 122, rotation: 1.1),
      _Step(
        MorphShapeRenderer.canvas,
        e,
        size: 48,
        edge: MorphEdgeAntialias.native,
      ),
      _Step(MorphShapeRenderer.shader, e, captured: true),
      _Step(MorphShapeRenderer.shader, e, color: Colors.redAccent),
      _Step(MorphShapeRenderer.canvas, gem, rotation: .3),
      _Step(MorphShapeRenderer.shader, e),
      _Step(MorphShapeRenderer.canvas, e),
    ];
    _timer = Timer.periodic(const Duration(milliseconds: 2500), (_) {
      if (mounted) setState(() => _i = (_i + 1) % _steps.length);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Widget _view(_Step s, Key key) => MorphShapeView(
    key: key,
    shape: s.shape,
    targetShape: s.target,
    progress: s.progress,
    contour: s.captured ? s.shape.contour : null,
    size: Size(s.size, s.size),
    rotationRadians: s.rotation,
    color: s.color,
    renderer: s.renderer,
    edgeAntialias: s.edge,
  );

  Widget _button(_Step s, Key key) => MorphShapeButton(
    key: key,
    size: s.size.clamp(48, 100),
    shape: s.shape,
    pressedShape: s.target,
    selected: _i.isOdd,
    selectedShape: s.target,
    rotationOnPress: s.rotation,
    edgeAntialias: s.edge,
    backgroundColor: s.color,
    enabled: _i % 5 != 4,
    onPressed: () {},
    child: const Text('x'),
  );

  Widget _loader(_Step s, Key key) => MorphLoadingIndicator(
    key: key,
    variant: MorphLoadingIndicatorVariant.contained,
    size: 96,
    renderer: s.renderer,
    rotationTurns: s.rotation,
    shapes: s.target == null ? null : [s.shape, s.target!],
    color: s.color,
  );

  @override
  Widget build(BuildContext context) {
    final s = _steps[_i];
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            children: [
              Text('step $_i · ${s.renderer.name} · ${s.shape.name}'),
              const SizedBox(height: 16),
              Row(
                children: [
                  const SizedBox(width: 40),
                  SizedBox(
                    width: 160,
                    height: 160,
                    child: Center(child: _view(s, const ValueKey('live'))),
                  ),
                  const SizedBox(width: 40),
                  SizedBox(
                    width: 160,
                    height: 160,
                    child: Center(child: _view(s, ValueKey('fresh$_i'))),
                  ),
                ],
              ),
              Row(
                children: [
                  const SizedBox(width: 40),
                  SizedBox(
                    width: 160,
                    height: 160,
                    child: Center(child: _button(s, const ValueKey('blive'))),
                  ),
                  const SizedBox(width: 40),
                  SizedBox(
                    width: 160,
                    height: 160,
                    child: Center(child: _button(s, ValueKey('bfresh$_i'))),
                  ),
                ],
              ),
              Row(
                children: [
                  const SizedBox(width: 40),
                  SizedBox(
                    width: 160,
                    height: 120,
                    child: Center(child: _loader(s, const ValueKey('llive'))),
                  ),
                  const SizedBox(width: 40),
                  SizedBox(
                    width: 160,
                    height: 120,
                    child: Center(child: _loader(s, ValueKey('lfresh$_i'))),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
