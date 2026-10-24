import 'dart:async';

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:motor/motor.dart';

import '../../../foundations/foundations.dart';
import '../../../foundations/interaction/morph_motion_controller.dart';

/// Internal shared indicator. Targets report their actual laid-out bounds so
/// sections, RTL, text scale and content-width pills need no index arithmetic.
class MorphSlidingIndicator extends StatefulWidget {
  const MorphSlidingIndicator({
    required this.child,
    this.axis = Axis.horizontal,
    this.selectionDelay,
    this.foreground = false,
    this.leadSpring = MorphMotion.navigationSelection,
    this.trailSpring = const MorphSpring(stiffness: 280, damping: 0.8),
    super.key,
  });

  final Widget child;
  final bool foreground;
  final Axis axis;

  /// Delay before the trailing edge follows the leading edge. Defaults to
  /// 60ms on a horizontal track and 20ms on a vertical track. Set zero to
  /// disable the stretch pause entirely.
  final Duration? selectionDelay;
  final MorphSpring leadSpring;
  final MorphSpring trailSpring;

  @override
  State<MorphSlidingIndicator> createState() => _MorphSlidingIndicatorState();
}

class _MorphSlidingIndicatorState extends State<MorphSlidingIndicator>
    with TickerProviderStateMixin {
  late final List<SingleMotionController> _edges = List.generate(
    4,
    (_) => MorphMotionController(
      motion: MorphMotion.springMotion(widget.leadSpring),
      vsync: this,
    ),
  );

  @override
  void dispose() {
    for (final edge in _edges) {
      edge.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _IndicatorSurface(
    edges: _edges,
    foreground: widget.foreground,
    axis: widget.axis,
    selectionDelay:
        widget.selectionDelay ??
        (widget.axis == Axis.vertical
            ? const Duration(milliseconds: 20)
            : const Duration(milliseconds: 60)),
    leadSpring: widget.leadSpring,
    trailSpring: widget.trailSpring,
    reduced: MorphMotion.reduceMotionOf(context),
    textDirection: Directionality.of(context),
    child: widget.child,
  );
}

class _IndicatorSurface extends SingleChildRenderObjectWidget {
  const _IndicatorSurface({
    required this.edges,
    required this.foreground,
    required this.axis,
    required this.selectionDelay,
    required this.leadSpring,
    required this.trailSpring,
    required this.reduced,
    required this.textDirection,
    required super.child,
  });
  final bool foreground;
  final List<SingleMotionController> edges;
  final Axis axis;
  final Duration selectionDelay;
  final MorphSpring leadSpring;
  final MorphSpring trailSpring;
  final bool reduced;
  final TextDirection textDirection;

  @override
  RenderMorphSlidingIndicator createRenderObject(BuildContext context) =>
      RenderMorphSlidingIndicator(
        edges,
        foreground,
        axis,
        selectionDelay,
        leadSpring,
        trailSpring,
        reduced,
        textDirection,
      );

  @override
  void updateRenderObject(
    BuildContext context,
    RenderMorphSlidingIndicator renderObject,
  ) {
    renderObject
      ..foreground = foreground
      ..axis = axis
      ..selectionDelay = selectionDelay
      ..leadSpring = leadSpring
      ..trailSpring = trailSpring
      ..reduced = reduced
      ..textDirection = textDirection
      ..markNeedsLayout();
  }
}

/// Render surface exposed only to package tests, not from the public barrel.
class RenderMorphSlidingIndicator extends RenderProxyBox {
  RenderMorphSlidingIndicator(
    this.edges,
    this.foreground,
    this.axis,
    this.selectionDelay,
    this.leadSpring,
    this.trailSpring,
    this.reduced,
    this.textDirection,
  );

  final List<SingleMotionController> edges;
  bool foreground;
  Axis axis;
  Duration selectionDelay;
  MorphSpring leadSpring;
  MorphSpring trailSpring;
  bool reduced;
  TextDirection textDirection;
  Rect? _target;
  Decoration? _decoration;
  BoxPainter? _painter;
  bool _hasTarget = false;
  bool _updatingTarget = false;
  bool _targetDirty = true;
  Timer? _trailTimer;
  int? _delayedEdge;
  _RenderIndicatorTarget? _selectedMarker;

  void _onTick() {
    // Initial seeding/retargeting is already being painted. Only later ticker
    // notifications must invalidate the next frame.
    if (!_updatingTarget) markNeedsPaint();
  }

  Rect? get indicatorRect => !_hasTarget
      ? null
      : Rect.fromLTRB(
          edges[0].value,
          edges[1].value,
          edges[2].value,
          edges[3].value,
        );

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    for (final edge in edges) {
      edge.addListener(_onTick);
    }
  }

  @override
  void detach() {
    _trailTimer?.cancel();
    _trailTimer = null;
    _delayedEdge = null;
    _target = null;
    _selectedMarker = null;
    _targetDirty = true;
    for (final edge in edges) {
      edge.removeListener(_onTick);
    }
    super.detach();
  }

  @override
  void dispose() {
    _trailTimer?.cancel();
    _painter?.dispose();
    super.dispose();
  }

  @override
  void performLayout() {
    super.performLayout();
    _targetDirty = true;
    markNeedsPaint();
  }

  void markTargetNeedsUpdate() {
    _targetDirty = true;
    markNeedsPaint();
  }

  void _updateTarget() {
    // Fixed-size slots can contain independently laid-out descendants. Measure
    // after the complete layout pass so a nested relayout boundary cannot leave
    // a reduced-motion selection at the previous dot's dimensions for one frame.
    _RenderIndicatorTarget? selected;
    void visit(RenderObject object) {
      if (object is RenderMorphSlidingIndicator) {
        return;
      }
      if (object is _RenderIndicatorTarget && object.selected) {
        selected = object;
        return;
      }
      object.visitChildren(visit);
    }

    child?.visitChildren(visit);
    if (child is _RenderIndicatorTarget) {
      visit(child!);
    }
    final marker = selected;
    _hasTarget = marker != null;
    if (marker == null) {
      _trailTimer?.cancel();
      _trailTimer = null;
      _delayedEdge = null;
      _selectedMarker = null;
      _target = null;
      return;
    }
    final rect = MatrixUtils.transformRect(
      marker.getTransformTo(this),
      Offset.zero & marker.laidOutSize,
    );
    if (_decoration != marker.decoration) {
      _painter?.dispose();
      _decoration = marker.decoration;
      _painter = marker.decoration.createBoxPainter(_onTick);
    }
    if (_target != rect ||
        (reduced &&
            (indicatorRect != rect || edges.any((edge) => edge.isAnimating)))) {
      final previous = _target;
      final selectionChanged = !identical(marker, _selectedMarker);
      final reference = indicatorRect ?? previous;
      final forward =
          reference == null ||
          (axis == Axis.horizontal
              ? rect.center.dx >= reference.center.dx
              : rect.center.dy >= reference.center.dy);
      final values = [rect.left, rect.top, rect.right, rect.bottom];
      if (selectionChanged || reduced || previous == null) {
        _trailTimer?.cancel();
        _trailTimer = null;
        _delayedEdge = null;
      }
      if (selectionChanged && previous != null && !reduced) {
        _delayedEdge = axis == Axis.horizontal
            ? (forward ? 0 : 2)
            : (forward ? 1 : 3);
        // Stop an old trailing spring on rapid reversal. The new leading edge
        // moves immediately; the opposite edge starts after the shared delay.
        final trailing = edges[_delayedEdge!];
        trailing.value = trailing.value;
        void followTrailingEdge() {
          final edge = _delayedEdge;
          _trailTimer = null;
          _delayedEdge = null;
          final target = _target;
          if (!attached || edge == null || target == null || reduced) {
            return;
          }
          final latest = [target.left, target.top, target.right, target.bottom];
          edges[edge].animateTo(latest[edge]);
        }

        if (selectionDelay == Duration.zero) {
          followTrailingEdge();
        } else {
          _trailTimer = Timer(selectionDelay, followTrailingEdge);
        }
      }
      for (var i = 0; i < edges.length; i++) {
        final leading = axis == Axis.horizontal
            ? (forward ? i == 2 : i == 0)
            : (forward ? i == 3 : i == 1);
        edges[i].motion = MorphMotion.springMotion(
          leading ? leadSpring : trailSpring,
        );
        if (previous == null || reduced) {
          edges[i].value = values[i];
        } else if (i != _delayedEdge) {
          edges[i].animateTo(values[i]);
        }
      }
      _target = rect;
      _selectedMarker = marker;
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    _updatingTarget = true;
    try {
      if (_targetDirty) {
        _targetDirty = false;
        _updateTarget();
      }
    } finally {
      _updatingTarget = false;
    }
    if (foreground) super.paint(context, offset);
    final rect = indicatorRect;
    if (rect != null && rect.width > 0 && rect.height > 0) {
      _painter?.paint(
        context.canvas,
        offset + rect.topLeft,
        ImageConfiguration(size: rect.size, textDirection: textDirection),
      );
    }
    if (!foreground) super.paint(context, offset);
  }
}

/// Empty destination-sized marker; its decoration is painted by the host.
class MorphIndicatorTarget extends LeafRenderObjectWidget {
  const MorphIndicatorTarget({
    required this.selected,
    required this.decoration,
    super.key,
  });
  final bool selected;
  final Decoration decoration;
  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderIndicatorTarget(selected, decoration);
  @override
  void updateRenderObject(BuildContext context, RenderObject renderObject) {
    final target = renderObject as _RenderIndicatorTarget;
    target
      ..selected = selected
      ..decoration = decoration;
    RenderObject? ancestor = target.parent;
    while (ancestor != null && ancestor is! RenderMorphSlidingIndicator) {
      ancestor = ancestor.parent;
    }
    (ancestor as RenderMorphSlidingIndicator?)?.markTargetNeedsUpdate();
  }
}

class _RenderIndicatorTarget extends RenderBox {
  _RenderIndicatorTarget(this.selected, this.decoration);
  bool selected;
  Decoration decoration;
  Size laidOutSize = Size.zero;
  @override
  void performLayout() {
    laidOutSize = constraints.biggest;
    size = laidOutSize;
    RenderObject? ancestor = parent;
    while (ancestor != null && ancestor is! RenderMorphSlidingIndicator) {
      ancestor = ancestor.parent;
    }
    (ancestor as RenderMorphSlidingIndicator?)?.markTargetNeedsUpdate();
  }
}
