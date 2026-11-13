import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/scheduler.dart' show Ticker;
import 'package:flutter/widgets.dart';
import 'package:material_ui/material_ui.dart'
    show InkWell, Material, MaterialType;

import '../../foundations/foundations.dart';
import 'components/morph_base_button_state.dart';
import 'enums/morph_button_enums.dart';
import 'styles/morph_button_motion.dart';
import '../tooltips/morph_tooltips.dart';

/// Direction of [MorphShapeButton.rotationEnabled] spin.
enum MorphShapeRotationDirection { clockwise, counterClockwise }

/// Controlled shape button: a surface that can spin around its own center,
/// compresses slightly on press and may *optionally* morph.
///
/// Defaults keep the previous behavior (no spin, [pressedScale] 0.96 is the
/// only new visible press feedback; no shape change unless [pressedShape] or
/// [selectedShape] is given).
///
/// * [rotationEnabled] spins the **surface** continuously, one turn per
///   [rotationDuration] in [rotationDirection]. Changing speed/direction keeps
///   the visible phase; disabling pauses at the current angle. Reduced motion
///   and `TickerMode` stop the ticker.
/// * [pressedScale] uniformly compresses the surface about its fixed center
///   (default 0.96, valid 0.5–1.2) with the press/release profile (90/160 ms).
/// * [pressedShape] / [selectedShape] are opt-in morph targets; `null` keeps
///   the current shape. Press takes precedence over selection.
/// * [rotationOnPress] (radians) is a *separate*, legacy one-shot offset added
///   while pressed. It is never the continuous speed.
///
/// The child (icon/text) is never rotated, scaled or clipped by the surface.
/// Layout size is always [size]; while spinning the surface is scaled by a
/// stable envelope (max radius of every configured shape) so it never leaves
/// the box. Hit testing uses the full [size] square (≥ 48 dp), not the contour.
class MorphShapeButton extends StatefulWidget {
  const MorphShapeButton({
    super.key,
    required this.shape,
    this.pressedShape,
    this.selectedShape,
    this.selected = false,
    this.rotationOnPress = 0,
    this.rotationEnabled = false,
    this.rotationDuration = const Duration(seconds: 8),
    this.rotationDirection = MorphShapeRotationDirection.clockwise,
    this.pressedScale = .96,
    this.edgeAntialias = MorphEdgeAntialias.auto,
    this.onPressed,
    this.onLongPress,
    this.enabled = true,
    this.child,
    this.size = 64,
    this.tooltip,
    this.semanticLabel,
    this.focusNode,
    this.statesController,
    this.pressDuration,
    this.releaseDuration,
    this.backgroundColor,
    this.foregroundColor,
  });
  final MorphShape shape;
  final MorphShape? pressedShape, selectedShape;
  final bool selected, enabled, rotationEnabled;
  final double rotationOnPress, size, pressedScale;
  final Duration rotationDuration;
  final MorphShapeRotationDirection rotationDirection;
  final MorphEdgeAntialias edgeAntialias;
  final VoidCallback? onPressed, onLongPress;
  final Widget? child;
  final String? tooltip, semanticLabel;
  final FocusNode? focusNode;
  final WidgetStatesController? statesController;
  final Duration? pressDuration, releaseDuration;
  final Color? backgroundColor, foregroundColor;
  @override
  State<MorphShapeButton> createState() => _MorphShapeButtonState();
}

class _MorphShapeButtonState extends State<MorphShapeButton>
    with TickerProviderStateMixin, MorphBaseButtonState<MorphShapeButton> {
  late final AnimationController _controller;
  late final Ticker _spin;
  final ValueNotifier<double> _phase = ValueNotifier(0); // turns
  Duration _lastTick = Duration.zero;
  late MorphPreparedGeometry _morph;
  double _rotationStart = 0, _rotationEnd = 0;
  double _scaleStart = 1, _scaleEnd = 1;
  double _envelopeStart = 1, _envelopeEnd = 1;
  bool _ready = false;
  static final Map<MorphShape, double> _radii = {};

  bool get _reduced => MorphMotion.reduceMotionOf(context);
  bool get _enabled =>
      widget.enabled &&
      (widget.onPressed != null || widget.onLongPress != null);
  bool get _pressed =>
      _enabled && (isPointerDownNotifier.value || isPressedNotifier.value);
  MorphShape get _rest =>
      widget.selected ? widget.selectedShape ?? widget.shape : widget.shape;
  MorphShape get _target => _pressed ? widget.pressedShape ?? _rest : _rest;
  double get _progress => Curves.easeOutCubic.transform(_controller.value);
  MorphContour get _visible => _morph.at(_progress);
  double get _pressAngle =>
      lerpDouble(_rotationStart, _rotationEnd, _progress)!;
  double get _scale =>
      lerpDouble(_scaleStart, _scaleEnd, _progress)! *
      lerpDouble(_envelopeStart, _envelopeEnd, _progress)!;
  double get _angle =>
      _pressAngle + (_reduced ? 0 : _phase.value * 2 * math.pi);

  /// Stable per-configuration envelope: the farthest contour point of every
  /// shape that can be shown, so a spinning surface never leaves the box.
  double _envelopeTarget() {
    if (!(widget.rotationEnabled || widget.rotationOnPress != 0)) return 1;
    var r = 0.0;
    for (final s in {widget.shape, widget.pressedShape, widget.selectedShape}) {
      if (s != null) r = math.max(r, _radii[s] ??= s.contour.maxRadius());
    }
    return r <= .5 ? 1 : .5 / r;
  }

  @override
  MorphButtonSize get buttonSize => MorphButtonSize.md;
  @override
  WidgetStatesController? get externalStatesController =>
      widget.statesController;
  @override
  FocusNode? get externalFocusNode => widget.focusNode;
  @override
  MorphButtonMotion? get effectiveMotion => null;

  @override
  void initState() {
    super.initState();
    initBaseButtonState();
    _controller = AnimationController(vsync: this, value: 1);
    _spin = createTicker(_onTick);
    _morph = const MorphGeometryEngine().prepare(_rest.contour, _rest.contour);
    _envelopeStart = _envelopeEnd = _envelopeTarget();
    _scaleStart = _scaleEnd = 1;
    isPointerDownNotifier.addListener(_retarget);
    isPressedNotifier.addListener(_retarget);
    _ready = true;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_reduced) _controller.value = 1;
    _syncSpin();
  }

  void _onTick(Duration elapsed) {
    final dt = math.min(.1, (elapsed - _lastTick).inMicroseconds / 1e6);
    _lastTick = elapsed;
    if (dt <= 0) return;
    final turns = dt / (widget.rotationDuration.inMicroseconds / 1e6);
    final sign =
        widget.rotationDirection == MorphShapeRotationDirection.clockwise
        ? 1
        : -1;
    _phase.value = (_phase.value + sign * turns) % 1.0;
  }

  void _syncSpin() {
    final want = widget.rotationEnabled && !_reduced;
    if (want && !_spin.isActive) {
      _lastTick = Duration.zero;
      _spin.start();
    } else if (!want && _spin.isActive) {
      _spin.stop();
    }
  }

  @override
  void didUpdateWidget(MorphShapeButton old) {
    super.didUpdateWidget(old);
    if (!_enabled) cancelPointerPress();
    handleStatesControllerUpdate(old.statesController, widget.statesController);
    handleFocusNodeUpdate(old.focusNode, widget.focusNode);
    _syncSpin();
    if (old.shape != widget.shape ||
        old.pressedShape != widget.pressedShape ||
        old.selectedShape != widget.selectedShape ||
        old.selected != widget.selected ||
        old.enabled != widget.enabled ||
        old.rotationOnPress != widget.rotationOnPress ||
        old.rotationEnabled != widget.rotationEnabled ||
        old.pressedScale != widget.pressedScale ||
        old.pressDuration != widget.pressDuration ||
        old.releaseDuration != widget.releaseDuration) {
      _retarget();
    }
  }

  void _retarget() {
    if (!_ready) return;
    final current = _visible;
    final angle = _pressAngle;
    // Visible scale excludes the envelope so it can retarget independently.
    final scale = lerpDouble(_scaleStart, _scaleEnd, _progress)!;
    final envelope = lerpDouble(_envelopeStart, _envelopeEnd, _progress)!;
    _morph = const MorphGeometryEngine().prepare(current, _target.contour);
    _rotationStart = angle;
    _rotationEnd = _pressed ? widget.rotationOnPress : 0;
    _scaleStart = scale;
    _scaleEnd = _pressed ? widget.pressedScale : 1;
    _envelopeStart = envelope;
    _envelopeEnd = _envelopeTarget();
    final theme = MorphTheme.of(context).buttonTheme;
    final duration = _pressed
        ? widget.pressDuration ?? theme.pressDuration
        : widget.releaseDuration ?? theme.releaseDuration;
    if (duration.isNegative) {
      throw ArgumentError('Shape button durations must be non-negative');
    }
    if (_reduced || duration == Duration.zero) {
      _controller.value = 1;
      setState(() {});
    } else {
      _controller.duration = duration;
      _controller.forward(from: 0);
    }
  }

  VoidCallback? _action(VoidCallback? callback) => !_enabled || callback == null
      ? null
      : () {
          MorphHaptics.triggerFor(context);
          callback();
        };

  Path _livePath(Size size) {
    final path = morphContourPath(_visible, size);
    final c = size.center(Offset.zero);
    final m = Matrix4.identity()
      ..translateByDouble(c.dx, c.dy, 0, 1)
      ..rotateZ(_angle)
      ..scaleByDouble(_scale, _scale, 1, 1)
      ..translateByDouble(-c.dx, -c.dy, 0, 1);
    return path.transform(m.storage);
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.size.isFinite ||
        widget.size < 48 ||
        !widget.rotationOnPress.isFinite ||
        !widget.pressedScale.isFinite ||
        widget.pressedScale <= .5 ||
        widget.pressedScale > 1.2 ||
        widget.rotationDuration <= Duration.zero) {
      throw ArgumentError(
        'Shape button requires size >= 48, finite rotation, pressedScale in '
        '(0.5, 1.2] and a positive rotationDuration',
      );
    }
    final scheme = MorphTheme.of(context).colorScheme;
    final bg = _enabled
        ? widget.backgroundColor ?? scheme.primary
        : scheme.onSurface.withValues(alpha: .12);
    final fg = _enabled
        ? widget.foregroundColor ?? scheme.onPrimary
        : scheme.onSurface.withValues(alpha: .38);
    final repaint = Listenable.merge([_controller, _phase, isFocusedNotifier]);
    final dpr = MediaQuery.maybeDevicePixelRatioOf(context) ?? 1;
    final border = _LiveBorder(_livePath);
    Widget result = wrapWithPointerPressTracking(
      enabled: _enabled,
      child: SizedBox.square(
        dimension: widget.size,
        child: CustomPaint(
          painter: _SurfacePainter(
            repaint: repaint,
            path: _livePath,
            color: bg,
            focusColor: scheme.onSurface,
            focused: () => isFocused,
            mode: widget.edgeAntialias,
            dpr: dpr,
          ),
          child: ClipPath(
            clipper: _LiveClipper(_livePath, repaint),
            child: Material(
              type: MaterialType.transparency,
              child: InkWell(
                statesController: statesController,
                focusNode: effectiveFocusNode,
                customBorder: border,
                onTap: _action(widget.onPressed),
                onLongPress: _action(widget.onLongPress),
                child: Center(
                  child: IconTheme.merge(
                    data: IconThemeData(color: fg),
                    child: DefaultTextStyle.merge(
                      style: TextStyle(color: fg),
                      child: widget.child ?? const SizedBox.shrink(),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    result = Semantics(
      button: true,
      selected: widget.selected,
      enabled: _enabled,
      label: widget.semanticLabel,
      child: result,
    );
    if (widget.tooltip != null) {
      result = MorphTooltip(message: widget.tooltip!, child: result);
    }
    return result;
  }

  @override
  void dispose() {
    _ready = false;
    isPointerDownNotifier.removeListener(_retarget);
    isPressedNotifier.removeListener(_retarget);
    _spin.dispose();
    _phase.dispose();
    _controller.dispose();
    disposeBaseButtonState();
    super.dispose();
  }
}

class _SurfacePainter extends CustomPainter {
  _SurfacePainter({
    required Listenable repaint,
    required this.path,
    required this.color,
    required this.focusColor,
    required this.focused,
    required this.mode,
    required this.dpr,
  }) : super(repaint: repaint);
  final Path Function(Size) path;
  final Color color, focusColor;
  final bool Function() focused;
  final MorphEdgeAntialias mode;
  final double dpr;
  @override
  void paint(Canvas canvas, Size size) {
    final p = path(size);
    MorphEdgeCoverage.draw(
      canvas,
      p,
      Paint()..color = color,
      mode: mode,
      pixelRatio: dpr,
    );
    if (focused()) {
      MorphEdgeCoverage.draw(
        canvas,
        p,
        Paint()
          ..color = focusColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
        mode: mode,
        pixelRatio: dpr,
      );
    }
  }

  @override
  bool shouldRepaint(_SurfacePainter old) =>
      old.color != color ||
      old.focusColor != focusColor ||
      old.mode != mode ||
      old.dpr != dpr;
}

class _LiveClipper extends CustomClipper<Path> {
  _LiveClipper(this.path, Listenable reclip) : super(reclip: reclip);
  final Path Function(Size) path;
  @override
  Path getClip(Size size) => path(size);
  @override
  bool shouldReclip(_LiveClipper old) => true;
}

class _LiveBorder extends ShapeBorder {
  const _LiveBorder(this.path);
  final Path Function(Size) path;
  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;
  @override
  ShapeBorder scale(double t) => this;
  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) =>
      path(rect.size).shift(rect.topLeft);
  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) =>
      getOuterPath(rect);
  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {}
}
