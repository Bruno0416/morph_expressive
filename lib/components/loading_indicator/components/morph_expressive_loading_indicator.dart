// Contains portions adapted from the Android Open Source Project Material 3
// Compose reference (Copyright (c) 2024 The Android Open Source Project;
// Apache-2.0). Modified in 2026 for Morph Expressive (Dart/Flutter integration,
// names, layout, styling, motion and/or source refactoring).
// See NOTICE for the original attribution and Apache-2.0 license terms.

import 'dart:math' as math;

import 'package:flutter/scheduler.dart' show Ticker;
import 'package:flutter/widgets.dart' show TickerMode;

import 'package:flutter/physics.dart';
import 'package:flutter/semantics.dart';
import 'package:material_new_shapes/material_new_shapes.dart'
    as legacy_shapes
    show RoundedPolygon;
import 'package:material_ui/material_ui.dart'
    show
        AnimatedBuilder,
        AnimationController,
        AspectRatio,
        BoxConstraints,
        BuildContext,
        Center,
        Color,
        ConstrainedBox,
        Listenable,
        ProgressIndicator,
        RepaintBoundary,
        Semantics,
        TweenAnimationBuilder,
        Tween,
        Size,
        SizedBox,
        State,
        TickerProviderStateMixin,
        Transform,
        Widget;
import 'package:morph_expressive/foundations/foundations.dart';

import '../styles/morph_loading_indicator_theme.dart';

/// A Material Design loading indicator.
///
/// This version of the loading indicator morphs between its [polygons] shapes.
/// ![Loading indicator image](https://developer.android.com/images/reference/androidx/compose/material3/loading-indicator.png)
class MorphExpressiveLoadingIndicator extends ProgressIndicator {
  /// A list of [shapes.RoundedPolygon]s for the sequence of shapes this loading indicator
  /// will morph between. The loading indicator expects at least two items in that list.
  final List<legacy_shapes.RoundedPolygon>? polygons;
  final List<MorphShape>? shapes;
  final MorphShapeRenderer renderer;

  /// Indicator colors cycled and interpolated during morphing.
  final List<Color>? indicatorColors;

  /// Size of the morphing indicator.
  final double? indicatorSize;

  /// Defines minimum and maximum sizes for an [MorphExpressiveLoadingIndicator].
  /// If null, then the [ProgressIndicatorThemeData.constraints] will be used. Otherwise, defaults to a minimum width and height of 48 pixels.
  final BoxConstraints? constraints;

  /// When non-null (dp), the active size is scaled down uniformly so the
  /// farthest point of the whole sequence (any rotation, largest pulse) stays
  /// within this radius from the center. Used by the contained variant.
  final double? radialBudget;

  /// Full 360° continuous spin period. Defaults to theme.
  final Duration? globalRotationDuration;

  /// Delay between polygon morph cycles. Defaults to theme.
  final Duration? morphInterval;

  /// Extra rotation (degrees) across each morph. Defaults to theme (45).
  final double? morphRotationDegrees;

  /// Spring for morph progress. Defaults to theme.
  final MorphSpring? morphSpring;

  /// Initial morph spring velocity. Defaults to theme.
  final double? morphSpringVelocity;

  /// Scale at the start of each morph-in pulse (`→ 1`; default expands above 1).
  final double? pulseStartScale;

  /// Spring for pulse settle. Defaults to theme.
  final MorphSpring? pulseSpring;

  /// Initial pulse spring velocity. Defaults to theme.
  final double? pulseSpringVelocity;

  /// When non-null, auto spin and morph pulse are disabled; this value (in
  /// turns, where `1.0` is 360°) drives rotation instead.
  final double? rotationTurns;

  /// MorphExpressiveLoadingIndicator.

  const MorphExpressiveLoadingIndicator({
    super.key,
    super.color,
    this.polygons,
    this.shapes,
    this.renderer = MorphShapeRenderer.canvas,
    this.indicatorColors,
    this.indicatorSize,
    this.radialBudget,
    this.constraints,
    this.globalRotationDuration,
    this.morphInterval,
    this.morphRotationDegrees,
    this.morphSpring,
    this.morphSpringVelocity,
    this.pulseStartScale,
    this.pulseSpring,
    this.pulseSpringVelocity,
    this.rotationTurns,
    super.semanticsLabel,
    super.semanticsValue,
  }) : assert(
         shapes == null || polygons == null,
         'shapes and polygons are exclusive',
       ),
       assert(
         !(polygons != null) || polygons.length > 1,
         'polygons must contain more than one shape when provided',
       );

  @override
  State<MorphExpressiveLoadingIndicator> createState() =>
      _MorphExpressiveLoadingIndicatorState();
}

class _MorphExpressiveLoadingIndicatorState
    extends State<MorphExpressiveLoadingIndicator>
    with TickerProviderStateMixin {
  static final List<legacy_shapes.RoundedPolygon> _defaultPolygons = [
    MorphMaterialNewShapes.softBurst,
    MorphMaterialNewShapes.cookie9Sided,
    MorphMaterialNewShapes.pentagon,
    MorphMaterialNewShapes.pill,
    MorphMaterialNewShapes.sunny,
    MorphMaterialNewShapes.cookie4Sided,
    MorphMaterialNewShapes.oval,
  ];

  late List<MorphShape> _shapeSequence;
  late MorphPreparedGeometry _activeMorph;
  MorphContour get _visibleContour => _activeMorph.at(_morphController.value);

  static const double _fullRotation = 360;

  late final AnimationController _morphController;
  late final AnimationController _globalRotationController;
  late final AnimationController _pulseController;
  int _currentMorphIndex = 0;
  double _morphRotationTargetAngle = 0;

  late final Ticker _cycleClock;
  Duration _lastCycle = Duration.zero;

  late BoxConstraints _constraints;
  late List<Color> _indicatorColors;
  late MorphLoadingIndicatorTheme _loadingTheme;

  Duration get _globalRotationDuration =>
      widget.globalRotationDuration ?? _loadingTheme.globalRotationDuration;

  Duration get _morphInterval =>
      widget.morphInterval ?? _loadingTheme.morphInterval;

  double get _morphRotationDegrees =>
      widget.morphRotationDegrees ?? _loadingTheme.morphRotationDegrees;

  MorphSpring get _morphSpring =>
      widget.morphSpring ?? _loadingTheme.morphSpring;

  double get _morphSpringVelocity =>
      widget.morphSpringVelocity ?? _loadingTheme.morphSpringVelocity;

  double get _pulseStartScale =>
      widget.pulseStartScale ?? _loadingTheme.pulseStartScale;

  MorphSpring get _pulseSpring =>
      widget.pulseSpring ?? _loadingTheme.pulseSpring;

  double get _pulseSpringVelocity =>
      widget.pulseSpringVelocity ?? _loadingTheme.pulseSpringVelocity;

  double get _activeSize =>
      widget.indicatorSize ?? _loadingTheme.activeIndicatorSize;

  static final Expando<double> _radius = Expando('loader shape radius');

  /// Largest pulse scale (≥ 1) from simulating the pulse spring.
  double get _pulseMax {
    final sim = SpringSimulation(
      _pulseSpring.toDescription(),
      _pulseStartScale,
      1,
      _pulseSpringVelocity,
    );
    var m = math.max(1.0, _pulseStartScale);
    for (var t = 0.0; t < 4; t += .004) {
      m = math.max(m, sim.x(t));
    }
    return m;
  }

  /// Stable per-sequence scale; never derived from the instantaneous bounds.
  Object? _envelopeKey;
  double _envelopeValue = 1;
  double get _envelopeScale {
    final budget = widget.radialBudget;
    if (budget == null) return 1;
    final key = Object.hash(
      identityHashCode(_shapeSequence),
      budget,
      _activeSize,
      _pulseStartScale,
      _pulseSpring,
      _pulseSpringVelocity,
    );
    if (key == _envelopeKey) return _envelopeValue;
    _envelopeKey = key;
    return _envelopeValue = _computeEnvelope(budget);
  }

  double _computeEnvelope(double budget) {
    var r = 0.0;
    for (final s in _shapeSequence) {
      r = math.max(r, _radius[s] ??= s.contour.maxRadius());
    }
    final needed = r * _activeSize * _pulseMax;
    return needed <= budget ? 1 : budget / needed;
  }

  bool get _manualRotation => widget.rotationTurns != null;

  void _rejectEmptyIndicatorColors() {
    assert(() {
      if (widget.indicatorColors != null && widget.indicatorColors!.isEmpty) {
        throw AssertionError('indicatorColors cannot be empty');
      }
      return true;
    }(), 'indicatorColors cannot be empty');
    if (widget.indicatorColors != null && widget.indicatorColors!.isEmpty) {
      throw ArgumentError.value(
        widget.indicatorColors,
        'indicatorColors',
        'must not be empty',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    _rejectEmptyIndicatorColors();
    final morphTheme = MorphTheme.of(context);
    _loadingTheme = morphTheme.loadingIndicatorTheme;
    _indicatorColors =
        widget.indicatorColors ??
        <Color>[
          widget.color ?? _loadingTheme.activeColor(morphTheme.colorScheme),
        ];
    _constraints =
        widget.constraints ??
        BoxConstraints.tightFor(
          width: _loadingTheme.containerWidth,
          height: _loadingTheme.containerHeight,
        );

    // Fit polygons into the active shape size only — outer container stays fixed.

    return Semantics.fromProperties(
      properties: SemanticsProperties(
        label: widget.semanticsLabel,
        // Spec: progressbar. Flutter requires value/min/max for this role;
        // indeterminate uses 0% with optional descriptive hint.
        role: SemanticsRole.progressBar,
        minValue: '0',
        maxValue: '100',
        value: _progressBarValue(widget.semanticsValue),
        hint: _progressBarHint(widget.semanticsValue),
      ),
      child: RepaintBoundary(
        child: ConstrainedBox(
          constraints: _constraints,
          child: AspectRatio(
            aspectRatio: 1,
            child: Center(
              child: AnimatedBuilder(
                animation: Listenable.merge([
                  _morphController,
                  _globalRotationController,
                  _pulseController,
                ]),
                builder: (context, child) {
                  final morphProgress = _morphController.value.clamp(0.0, 1.0);
                  final double globalRotationDegrees = _manualRotation
                      ? (widget.rotationTurns! * _fullRotation)
                      : (_globalRotationController.value * _fullRotation);

                  final double totalRotationDegrees = _manualRotation
                      ? globalRotationDegrees
                      : morphProgress * _morphRotationDegrees +
                            _morphRotationTargetAngle +
                            globalRotationDegrees;

                  final totalRotationRadians =
                      totalRotationDegrees * (math.pi / 180.0);

                  final Color indicatorColor = _resolveIndicatorColor(
                    morphProgress,
                  );
                  final double pulseScale = _manualRotation
                      ? 1.0
                      : _pulseController.value;

                  return Transform.rotate(
                    angle: totalRotationRadians,
                    child: Transform.scale(
                      scale: pulseScale,
                      child: TweenAnimationBuilder<double>(
                        tween: Tween<double>(end: _envelopeScale),
                        duration: _reduced
                            ? Duration.zero
                            : const Duration(milliseconds: 240),
                        builder: (context, k, _) => SizedBox(
                          width: _activeSize * k,
                          height: _activeSize * k,
                          child: MorphShapeView(
                            shape: _shapeSequence[_currentMorphIndex],
                            contour: _visibleContour,
                            color: indicatorColor,
                            renderer: widget.renderer,
                            size: Size.square(_activeSize * k),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _cycleClock.dispose();
    _morphController.dispose();
    _globalRotationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _readSequence();
    _activeMorph = const MorphGeometryEngine().prepare(
      _shapeSequence.first.contour,
      _shapeSequence.first.contour,
    );

    _morphController = AnimationController.unbounded(vsync: this);
    _pulseController = AnimationController.unbounded(vsync: this, value: 1);

    // continuous linear rotation — duration applied once theme is available
    _globalRotationController = AnimationController(vsync: this);
    _cycleClock = createTicker((elapsed) {
      if (elapsed - _lastCycle >= _morphInterval) {
        _lastCycle = elapsed;
        _startMorphCycle();
      }
    });

    // Theme is read in didChangeDependencies before first morph tick.
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadingTheme = MorphTheme.of(context).loadingIndicatorTheme;
    _reduced = MorphMotion.reduceMotionOf(context);
    if (_reduced || !TickerMode.valuesOf(context).enabled) {
      _enterManualRotation();
      _animationsStarted = false;
    } else {
      _ensureAnimationsStarted();
    }
  }

  @override
  void didUpdateWidget(MorphExpressiveLoadingIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.shapes != widget.shapes ||
        oldWidget.polygons != widget.polygons) {
      final current = _visibleContour;
      _readSequence();
      _currentMorphIndex = 0;
      _activeMorph = const MorphGeometryEngine().prepare(
        current,
        _shapeSequence.first.contour,
      );
      _morphController.value = 0;
      if (!_reduced &&
          !_manualRotation &&
          TickerMode.valuesOf(context).enabled) {
        _animateMorph();
      }
    }
    final wasManual = oldWidget.rotationTurns != null;
    final isManual = widget.rotationTurns != null;
    if (_reduced) return;
    if (wasManual != isManual) {
      if (isManual) {
        _enterManualRotation();
      } else {
        _exitManualRotation(seedTurns: oldWidget.rotationTurns);
      }
    } else if (!isManual &&
        (oldWidget.globalRotationDuration != widget.globalRotationDuration ||
            oldWidget.morphInterval != widget.morphInterval)) {
      _restartPeriodicAnimations();
    }
  }

  bool _animationsStarted = false;
  bool _reduced = false;

  void _ensureAnimationsStarted() {
    if (_animationsStarted) {
      if (!_manualRotation) {
        _syncGlobalRotationDuration();
      }
      return;
    }
    _animationsStarted = true;
    _morphRotationTargetAngle = _morphRotationDegrees;
    if (_manualRotation) {
      _pulseController.value = 1;
      return;
    }
    _syncGlobalRotationDuration();
    _startAnimations();
  }

  void _enterManualRotation() {
    _cycleClock.stop();
    _globalRotationController.stop();
    _morphController.stop();
    _pulseController
      ..stop()
      ..value = 1;
  }

  void _exitManualRotation({double? seedTurns}) {
    if (seedTurns != null) {
      _globalRotationController.value = seedTurns % 1.0;
      _morphRotationTargetAngle = 0;
    }
    _syncGlobalRotationDuration();
    if (!_globalRotationController.isAnimating) {
      _globalRotationController.repeat();
    }
    _restartClock();
    _startMorphCycle();
  }

  void _syncGlobalRotationDuration() {
    final Duration duration = _globalRotationDuration;
    if (_globalRotationController.duration != duration) {
      final double value = _globalRotationController.value;
      _globalRotationController.duration = duration;
      if (_globalRotationController.isAnimating) {
        _globalRotationController
          ..value = value
          ..repeat();
      }
    }
  }

  void _restartPeriodicAnimations() {
    if (_manualRotation || _reduced) {
      return;
    }
    _syncGlobalRotationDuration();
    if (!_globalRotationController.isAnimating) {
      _globalRotationController.repeat();
    }
    _restartClock();
  }

  void _readSequence() {
    if (widget.shapes != null && widget.polygons != null) {
      throw ArgumentError('shapes and polygons are mutually exclusive');
    }
    final sequence =
        widget.shapes ??
        (widget.polygons ?? _defaultPolygons)
            .map((p) => MorphShape.fromPolygon(p))
            .toList();
    if (sequence.length < 2) {
      throw ArgumentError('At least two shapes are required');
    }
    // Normalize only when definitions change, never per frame.
    _shapeSequence = List.unmodifiable(
      sequence.map(
        (s) => MorphShape(
          name: s.name,
          contour: s.contour.normalized(),
          provenance: s.provenance,
        ),
      ),
    );
  }

  void _restartClock() {
    _cycleClock.stop();
    _lastCycle = Duration.zero;
    _cycleClock.start();
  }

  void _startAnimations() {
    if (_manualRotation || _reduced) {
      return;
    }
    // infinite global rotation
    _globalRotationController.repeat();

    // periodic morph cycle
    _restartClock();

    _startMorphCycle();
  }

  Color _resolveIndicatorColor(double progress) {
    if (_indicatorColors.length == 1) {
      return _indicatorColors.first;
    }

    final int colorIndex = _currentMorphIndex % _indicatorColors.length;
    final Color startColor = _indicatorColors[colorIndex];
    final Color endColor =
        _indicatorColors[(colorIndex + 1) % _indicatorColors.length];
    return Color.lerp(startColor, endColor, progress) ?? startColor;
  }

  /// Numeric / percent [semanticsValue], else indeterminate `0%`.
  static String _progressBarValue(String? semanticsValue) {
    if (semanticsValue == null || semanticsValue.isEmpty) {
      return '0%';
    }
    if (double.tryParse(semanticsValue) != null) {
      return semanticsValue;
    }
    if (semanticsValue.endsWith('%') &&
        double.tryParse(
              semanticsValue.substring(0, semanticsValue.length - 1),
            ) !=
            null) {
      return semanticsValue;
    }
    return '0%';
  }

  /// Non-numeric [semanticsValue] is exposed as a hint (progressBar value
  /// must stay numeric for Flutter debug role checks).
  static String? _progressBarHint(String? semanticsValue) {
    if (semanticsValue == null || semanticsValue.isEmpty) {
      return null;
    }
    if (_progressBarValue(semanticsValue) == semanticsValue) {
      return null;
    }
    return semanticsValue;
  }

  void _startMorphCycle() {
    if (!mounted ||
        _manualRotation ||
        _reduced ||
        !TickerMode.valuesOf(context).enabled) {
      return;
    }

    // move to next morph in sequence
    final current = _visibleContour;
    _currentMorphIndex = (_currentMorphIndex + 1) % _shapeSequence.length;
    _activeMorph = const MorphGeometryEngine().prepare(
      current,
      _shapeSequence[_currentMorphIndex].contour,
    );

    // Capture the visible transition rotation before resetting its progress.
    _morphRotationTargetAngle =
        (_morphRotationTargetAngle +
            _morphController.value.clamp(0.0, 1.0) * _morphRotationDegrees) %
        _fullRotation;

    _animateMorph();
  }

  void _animateMorph() {
    // Reset and start morph animation (slower spring + lower velocity by default)
    _morphController
      ..value = 0.0
      ..animateWith(
        SpringSimulation(
          _morphSpring.toDescription(),
          0,
          1,
          _morphSpringVelocity,
          snapToEnd: true,
        ),
      );

    // Outward pulse (scale > 1) then smooth settle down to 1.
    _pulseController
      ..value = _pulseStartScale
      ..animateWith(
        SpringSimulation(
          _pulseSpring.toDescription(),
          _pulseStartScale,
          1,
          _pulseSpringVelocity,
        ),
      );
  }
}
