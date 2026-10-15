import 'package:motor/motor.dart';

import '../../../foundations/foundations.dart';

/// Converts [MorphSpring] to a motor [SpringMotion] for toolbar animations.
extension MorphToolbarSpringMotion on MorphSpring {
  /// Matches morph_core floating toolbar: expressive spatial base + token values.
  SpringMotion toMotion() => MorphMotion.springMotion(this);
}
