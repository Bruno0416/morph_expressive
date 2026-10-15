import 'package:morph_expressive/components/dropdown_menus/utils/morph_dropdown_spring_motion.dart'
    show MorphDropdownSpringMotion;
import 'package:motor/motor.dart';

import '../../../foundations/foundations.dart';

/// Converts [MorphSpring] to a motor [SpringMotion] for expandable animations.
///
/// Matches [MorphDropdownSpringMotion] so expand/collapse feels the same as the
/// dropdown menu panel.
extension MorphExpandableSpringMotion on MorphSpring {
  /// toMotion.
  SpringMotion toMotion() =>
      MorphMotion.springMotion(this);
}
