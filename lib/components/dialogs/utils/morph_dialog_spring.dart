import 'package:flutter/physics.dart';
import 'package:motor/motor.dart';

import '../../../foundations/foundations.dart';

const Tolerance _settleTolerance = Tolerance(velocity: 0.01);
const Duration _maxSettle = Duration(seconds: 2);

/// Motor motion for [spring].
SpringMotion morphDialogSpringMotion(MorphSpring spring) =>
    MorphMotion.springMotion(spring);

/// Time a 0→1 [spring] needs to settle (capped at 2s).
Duration morphDialogSpringSettle(MorphSpring spring) {
  final sim = SpringSimulation(
    spring.toDescription(),
    0,
    1,
    0,
    tolerance: _settleTolerance,
  );
  var ms = 0;
  while (ms < _maxSettle.inMilliseconds && !sim.isDone(ms / 1000)) {
    ms += 4;
  }
  return Duration(milliseconds: ms);
}

/// Snaps a settled spring [value] to exactly 0 or 1.
double morphDialogSnap(double value) {
  if ((value - 1).abs() < 0.001) {
    return 1;
  }
  return value.abs() < 0.001 ? 0 : value;
}
