import 'package:flutter/widgets.dart';

import '../../../foundations/foundations.dart';
import 'morph_side_sheet_spring.dart';

/// Springs [controller] to [target], or jumps there when animations are off.
void morphSideSheetAnimate(
  BuildContext context,
  AnimationController controller,
  MorphSpring spring,
  double target,
) {
  final bool reduce = MorphMotion.reduceMotionOf(context);
  if (reduce) {
    controller.value = target;
    return;
  }
  controller.animateWith(
    morphSideSheetSpring(
      spring,
      from: controller.value,
      to: target,
      velocity: controller.velocity,
    ),
  );
}
