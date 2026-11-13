import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// Native Impeller backdrop benchmark. Production frosted widgets are unchanged.
///
/// Launch the preview in profile mode with
/// --dart-define=MORPH_FROSTED_BENCHMARK=true.
/// Compare modes with the same panel count, scroll speed and window size.
class MorphFrostedBlurBenchmarkLab extends StatefulWidget {
  const MorphFrostedBlurBenchmarkLab({super.key});

  @override
  State<MorphFrostedBlurBenchmarkLab> createState() =>
      _MorphFrostedBlurBenchmarkLabState();
}

enum _BlurMode { none, gaussian, bounded, kawase }

class _LiveReadout {
  const _LiveReadout({
    this.fps = 0,
    this.rasterP50 = 0,
    this.rasterP95 = 0,
    this.uiP95 = 0,
    this.sampleCount = 0,
  });

  final double fps;
  final double rasterP50;
  final double rasterP95;
  final double uiP95;
  final int sampleCount;
}

class _MorphFrostedBlurBenchmarkLabState
    extends State<MorphFrostedBlurBenchmarkLab>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final ValueNotifier<_LiveReadout> _readout = ValueNotifier<_LiveReadout>(
    const _LiveReadout(),
  );
  final List<double> _rasterMs = <double>[];
  final List<double> _buildMs = <double>[];
  final List<int> _vsyncUs = <int>[];
  final List<ui.FragmentShader> _shaders = <ui.FragmentShader>[];

  late final Ticker _scrollTicker;
  Timer? _metricsTimer;
  ui.FragmentProgram? _program;
  String? _shaderError;
  DateTime? _lastFrameBatchAt;
  Duration _previousTick = Duration.zero;

  _BlurMode _mode = _BlurMode.gaussian;
  int _panelCount = 4;
  bool _autoScroll = true;
  bool _showPerformanceOverlay = false;
  double _speed = 230;
  double _sigma = 12;
  double _kawaseStep = 2.5;

  @override
  void initState() {
    super.initState();
    _scrollTicker = createTicker(_advanceScroll);
    SchedulerBinding.instance.addTimingsCallback(_onFrames);
    _metricsTimer = Timer.periodic(
      const Duration(milliseconds: 500),
      (_) => _publishMetrics(),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _autoScroll) _scrollTicker.start();
    });
    _loadShader();
  }

  Future<void> _loadShader() async {
    if (kIsWeb || !ui.ImageFilter.isShaderFilterSupported) {
      if (!mounted) return;
      setState(
        () => _shaderError = 'Kawase deshabilitado: requiere Impeller nativo.',
      );
      return;
    }
    try {
      final program = await ui.FragmentProgram.fromAsset(
        'packages/morph_expressive/shaders/frosted_kawase_single_pass.frag',
      );
      if (!mounted) return;
      setState(() {
        _program = program;
        _ensureShaders();
      });
    } catch (error) {
      if (mounted) setState(() => _shaderError = 'Shader: $error');
    }
  }

  void _ensureShaders() {
    if (_program == null) return;
    while (_shaders.length < _panelCount) {
      final shader = _program!.fragmentShader();
      shader.setFloat(2, _kawaseStep);
      _shaders.add(shader);
    }
  }

  void _advanceScroll(Duration elapsed) {
    final delta = (elapsed - _previousTick).inMicroseconds / 1000000.0;
    _previousTick = elapsed;
    if (delta <= 0 || !_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.maxScrollExtent <= 0) return;
    final next = position.pixels + math.min(delta, 0.05) * _speed;
    _scrollController.jumpTo(next >= position.maxScrollExtent ? 0 : next);
  }

  void _toggleAutoScroll(bool value) {
    setState(() {
      _autoScroll = value;
      _previousTick = Duration.zero;
      if (value && !_scrollTicker.isActive) {
        _scrollTicker.start();
      } else if (!value && _scrollTicker.isActive) {
        _scrollTicker.stop();
      }
      _resetSamples();
    });
  }

  void _onFrames(List<ui.FrameTiming> frames) {
    if (frames.isEmpty) return;
    for (final frame in frames) {
      _rasterMs.add(frame.rasterDuration.inMicroseconds / 1000.0);
      _buildMs.add(frame.buildDuration.inMicroseconds / 1000.0);
      _vsyncUs.add(frame.timestampInMicroseconds(ui.FramePhase.vsyncStart));
    }
    if (_rasterMs.length > 600) {
      final trim = _rasterMs.length - 600;
      _rasterMs.removeRange(0, trim);
      _buildMs.removeRange(0, trim);
    }
    final cutoff = _vsyncUs.last - 1000000;
    _vsyncUs.removeWhere((timestamp) => timestamp < cutoff);
    _lastFrameBatchAt = DateTime.now();
  }

  static double _percentile(List<double> values, double fraction) {
    if (values.isEmpty) return 0;
    final sorted = List<double>.of(values)..sort();
    return sorted[((sorted.length - 1) * fraction).round()];
  }

  void _publishMetrics() {
    if (!mounted) return;
    final active =
        _lastFrameBatchAt != null &&
        DateTime.now().difference(_lastFrameBatchAt!) <
            const Duration(milliseconds: 1500);
    // This is rendered-frame throughput based on native vsync timestamps,
    // not the screen's refresh rate, an unbounded frame count or GPU FPS.
    var fps = 0.0;
    if (active && _vsyncUs.length >= 2) {
      final span = _vsyncUs.last - _vsyncUs.first;
      if (span > 0) fps = (_vsyncUs.length - 1) * 1000000.0 / span;
    }
    _readout.value = _LiveReadout(
      fps: fps,
      rasterP50: _percentile(_rasterMs, .50),
      rasterP95: _percentile(_rasterMs, .95),
      uiP95: _percentile(_buildMs, .95),
      sampleCount: _rasterMs.length,
    );
  }

  void _resetSamples() {
    _rasterMs.clear();
    _buildMs.clear();
    _vsyncUs.clear();
    _lastFrameBatchAt = null;
    _readout.value = const _LiveReadout();
  }

  void _setMode(_BlurMode next) {
    if (next == _mode || (next == _BlurMode.kawase && _program == null)) {
      return;
    }
    setState(() {
      _mode = next;
      _resetSamples();
    });
  }

  void _setCount(int? count) {
    if (count == null || count == _panelCount) return;
    setState(() {
      _panelCount = count;
      _ensureShaders();
      _resetSamples();
    });
  }

  void _setStrength(double value) {
    setState(() {
      if (_mode == _BlurMode.kawase) {
        _kawaseStep = value;
        for (final shader in _shaders) {
          shader.setFloat(2, value);
        }
      } else {
        _sigma = value;
      }
      _resetSamples();
    });
  }

  @override
  void dispose() {
    SchedulerBinding.instance.removeTimingsCallback(_onFrames);
    _metricsTimer?.cancel();
    _scrollTicker.dispose();
    _scrollController.dispose();
    _readout.dispose();
    for (final shader in _shaders) {
      shader.dispose();
    }
    super.dispose();
  }

  Widget _glassPanel(int index) {
    Widget surface = ColoredBox(color: const Color(0xA0ECEAF6));
    switch (_mode) {
      case _BlurMode.none:
        break;
      case _BlurMode.gaussian:
        surface = BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: _sigma, sigmaY: _sigma),
          child: surface,
        );
        break;
      case _BlurMode.bounded:
        surface = BackdropFilter(
          filterConfig: ImageFilterConfig.blur(
            sigmaX: _sigma,
            sigmaY: _sigma,
            tileMode: ui.TileMode.clamp,
            bounded: true,
          ),
          child: surface,
        );
        break;
      case _BlurMode.kawase:
        // This mode is only selectable when each panel has a real shader.
        surface = BackdropFilter(
          filter: ui.ImageFilter.shader(_shaders[index]),
          child: surface,
        );
        break;
    }
    return ClipRRect(
      key: ValueKey<String>('frosted-benchmark-panel-$index'),
      borderRadius: BorderRadius.circular(24),
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          surface,
          Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                'Frosted ${index + 1}',
                style: const TextStyle(fontSize: 20, color: Color(0xFF201C30)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _panelGrid(BoxConstraints constraints) {
    const gap = 10.0;
    const preferredWidth = 215.0;
    const preferredHeight = 120.0;
    final maxWidth = math.min(constraints.maxWidth, 1050.0);
    final maxHeight = constraints.maxHeight;
    final columns = math.min(
      _panelCount,
      math.max(1, ((maxWidth + gap) / (preferredWidth + gap)).floor()),
    );
    final rows = (_panelCount + columns - 1) ~/ columns;
    final width = math.min(
      preferredWidth,
      (maxWidth - gap * (columns - 1)) / columns,
    );
    final height = math.max(
      1.0,
      math.min(preferredHeight, (maxHeight - gap * (rows - 1)) / rows),
    );
    return Center(
      child: Wrap(
        spacing: gap,
        runSpacing: gap,
        alignment: WrapAlignment.center,
        runAlignment: WrapAlignment.center,
        children: <Widget>[
          for (var index = 0; index < _panelCount; index++)
            SizedBox(width: width, height: height, child: _glassPanel(index)),
        ],
      ),
    );
  }

  Widget _controls() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1100),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Text('Frosted Impeller Lab · múltiples superficies'),
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  children: <Widget>[
                    for (final mode in _BlurMode.values)
                      ChoiceChip(
                        key: ValueKey<String>('frosted-mode-${mode.name}'),
                        label: Text(switch (mode) {
                          _BlurMode.none => 'Sin blur',
                          _BlurMode.gaussian => 'Gaussian',
                          _BlurMode.bounded => 'Bounded',
                          _BlurMode.kawase => 'Kawase 1x',
                        }),
                        selected: _mode == mode,
                        onSelected: mode == _BlurMode.kawase && _program == null
                            ? null
                            : (_) => _setMode(mode),
                      ),
                    const Text('Superficies:'),
                    DropdownButton<int>(
                      key: const ValueKey('frosted-panel-count'),
                      value: _panelCount,
                      items: <int>[1, 4, 8, 12, 16]
                          .map(
                            (count) => DropdownMenuItem<int>(
                              value: count,
                              child: Text('$count'),
                            ),
                          )
                          .toList(),
                      onChanged: _setCount,
                    ),
                    const Text('Auto-scroll'),
                    Switch(value: _autoScroll, onChanged: _toggleAutoScroll),
                    const Text('Gráficas Flutter'),
                    Switch(
                      value: _showPerformanceOverlay,
                      onChanged: (value) => setState(() {
                        _showPerformanceOverlay = value;
                        _resetSamples();
                      }),
                    ),
                  ],
                ),
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  children: <Widget>[
                    Text(
                      _mode == _BlurMode.kawase
                          ? 'Kawase step ${_kawaseStep.toStringAsFixed(1)}'
                          : 'Sigma ${_sigma.toStringAsFixed(1)}',
                    ),
                    SizedBox(
                      width: 190,
                      child: Slider(
                        value: _mode == _BlurMode.kawase ? _kawaseStep : _sigma,
                        min: .5,
                        max: _mode == _BlurMode.kawase ? 8 : 24,
                        onChanged: _mode == _BlurMode.none
                            ? null
                            : _setStrength,
                      ),
                    ),
                    Text('Scroll ${_speed.round()} px/s'),
                    SizedBox(
                      width: 130,
                      child: Slider(
                        value: _speed,
                        min: 80,
                        max: 500,
                        onChanged: (value) => setState(() {
                          _speed = value;
                          _resetSamples();
                        }),
                      ),
                    ),
                  ],
                ),
                ValueListenableBuilder<_LiveReadout>(
                  valueListenable: _readout,
                  builder: (context, value, _) => Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 16,
                    children: <Widget>[
                      Text(
                        'FPS renderizados (1 s): '
                        '${value.fps.toStringAsFixed(1)}',
                      ),
                      Text(
                        'Raster p50/p95: '
                        '${value.rasterP50.toStringAsFixed(2)} / '
                        '${value.rasterP95.toStringAsFixed(2)} ms',
                      ),
                      Text('UI p95: ${value.uiP95.toStringAsFixed(2)} ms'),
                      Text('${value.sampleCount} muestras'),
                    ],
                  ),
                ),
                if (_shaderError != null)
                  Text(
                    _shaderError!,
                    style: const TextStyle(color: Colors.deepOrange),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      showPerformanceOverlay: _showPerformanceOverlay,
      home: Scaffold(
        body: Stack(
          children: <Widget>[
            ListView.builder(
              key: const ValueKey('frosted-benchmark-backdrop'),
              controller: _scrollController,
              itemCount: 700,
              itemBuilder: (context, index) => Container(
                height: 94,
                margin: const EdgeInsets.all(4),
                alignment: Alignment.center,
                color: Colors.primaries[index % Colors.primaries.length]
                    .withValues(alpha: .34),
                child: Text(
                  'Backdrop en movimiento #$index',
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),
            SafeArea(
              child: Column(
                children: <Widget>[
                  _controls(),
                  Expanded(
                    child: IgnorePointer(
                      child: LayoutBuilder(
                        builder: (context, constraints) =>
                            _panelGrid(constraints),
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(8),
                    child: Text(
                      'macOS/Linux Impeller · usa --profile · misma ventana, '
                      'cantidad de superficies y velocidad por modo',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
