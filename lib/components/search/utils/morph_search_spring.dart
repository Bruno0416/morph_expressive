import 'package:flutter/animation.dart';
import 'package:flutter/physics.dart';

import '../../../foundations/foundations.dart';

const Tolerance _settleTolerance = Tolerance(velocity: 0.01);
const Duration _maxSettle = Duration(seconds: 2);

/// Spring simulation from [from] to [to] used by search motion.
SpringSimulation morphSearchSpringSimulation(
  MorphSpring spring, {
  double from = 0,
  double to = 1,
  double velocity = 0,
}) {
  return SpringSimulation(
    spring.toDescription(),
    from,
    to,
    velocity,
    tolerance: _settleTolerance,
    snapToEnd: true,
  );
}

/// Time a 0→1 [spring] needs to settle (capped at 2s).
Duration morphSearchSpringSettle(MorphSpring spring) {
  final SpringSimulation sim = morphSearchSpringSimulation(spring);
  var ms = 0;
  while (ms < _maxSettle.inMilliseconds && !sim.isDone(ms / 1000)) {
    ms += 4;
  }
  return Duration(milliseconds: ms);
}

/// [spring] sampled as a [Curve] over its settle time.
Curve morphSearchSpringCurve(MorphSpring spring) => _MorphSearchSpringCurve(spring);

class _MorphSearchSpringCurve extends Curve {
  _MorphSearchSpringCurve(MorphSpring spring)
    : _sim = morphSearchSpringSimulation(spring),
      _seconds = morphSearchSpringSettle(spring).inMicroseconds / 1e6;

  final SpringSimulation _sim;
  final double _seconds;

  @override
  double transformInternal(double t) => _sim.x(t * _seconds);
}
