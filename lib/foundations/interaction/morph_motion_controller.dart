import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:motor/motor.dart';

import 'morph_motion_scope.dart';

/// Motor controller used internally by Morph's decorative transitions.
///
/// Keeps the configured spring in normal mode. Reduced motion completes at the
/// requested target, including an in-flight transition, preserving completion
/// callbacks and status listeners used by overlays and reorder operations.
class MorphMotionController extends SingleMotionController
    with WidgetsBindingObserver {
  MorphMotionController({
    required super.motion,
    required super.vsync,
    super.initialValue = 0,
    super.behavior = AnimationBehavior.normal,
  }) : _owner = vsync is State ? vsync as State : null {
    WidgetsBinding.instance.addObserver(this);
  }

  final State? _owner;
  ValueNotifier<bool>? _policy;
  double? _targetValue;
  int _generation = 0;
  bool _disposed = false;

  bool get _reduced {
    final owner = _owner;
    if (owner != null && owner.mounted) {
      final context = owner.context;
      final next = context
          .getInheritedWidgetOfExactType<MorphMotionPolicy>()
          ?.notifier;
      if (!identical(next, _policy)) {
        _policy?.removeListener(_onPreferenceChanged);
        _policy = next;
        next?.addListener(_onPreferenceChanged);
      }
      return MorphMotionScope.reducedOf(context, listen: false);
    }
    final features =
        WidgetsBinding.instance.platformDispatcher.accessibilityFeatures;
    return features.disableAnimations || features.reduceMotion;
  }

  void _onPreferenceChanged() {
    if (_reduced && isAnimating && _targetValue != null) {
      // Motor's value setter completes the existing ticker, rather than
      // cancelling the Future awaited by a closing overlay.
      super.value = _targetValue!;
    }
  }

  @override
  void didChangeAccessibilityFeatures() => _onPreferenceChanged();

  @override
  TickerFuture animateTo(double target, {double? from, double? withVelocity}) {
    final generation = ++_generation;
    _targetValue = target;
    final reduced = _reduced;
    final done = super.animateTo(
      target,
      from: reduced ? target : from,
      withVelocity: reduced ? 0 : withVelocity,
    );
    if (reduced) {
      // A caller may assign this controller with a cascade whose listeners
      // reference that very field. Complete after that assignment, while the
      // visible value is already at the target and before the next frame.
      scheduleMicrotask(() {
        if (!_disposed && generation == _generation) super.value = target;
      });
    }
    return done;
  }

  @override
  set value(double next) {
    _generation++;
    _targetValue = null;
    super.value = next;
  }

  @override
  void dispose() {
    _disposed = true;
    WidgetsBinding.instance.removeObserver(this);
    _policy?.removeListener(_onPreferenceChanged);
    super.dispose();
  }
}
