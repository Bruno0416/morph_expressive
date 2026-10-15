import 'package:motor/motor.dart';

import '../../../foundations/foundations.dart';

/// Converts [MorphSpring] to a motor [SpringMotion] for menu animations.
///
/// Identical to the dropdown menu conversion so expand/collapse feel matches.
extension MorphMenuSpringMotion on MorphSpring {
  /// toMotion.
  SpringMotion toMotion() =>
      MorphMotion.springMotion(this);
}
