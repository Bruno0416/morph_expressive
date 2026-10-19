import 'package:motor/motor.dart';

import '../../../foundations/foundations.dart';

/// Converts [MorphSpring] to a motor [SpringMotion] for dropdown animations.
extension MorphDropdownSpringMotion on MorphSpring {
  /// toMotion.
  SpringMotion toMotion() => MorphMotion.springMotion(this);
}
