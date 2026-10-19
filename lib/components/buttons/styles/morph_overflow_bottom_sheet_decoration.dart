import 'package:morph_expressive/components/button_group/morph_button_group.dart'
    show MorphButtonGroup;
import 'package:morph_expressive/morph_components.dart' show MorphButtonGroup;
import 'package:material_ui/material_ui.dart';

import 'morph_button_motion.dart';

/// Styling configuration for the overflow bottom sheet in [MorphButtonGroup].
class MorphOverflowBottomSheetDecoration {
  /// title.
  final Widget? title;

  /// backgroundColor.
  final Color? backgroundColor;

  /// elevation.
  final double? elevation;

  /// shape.
  final ShapeBorder? shape;

  /// showDragHandle.
  final bool showDragHandle;

  /// titlePadding.
  final EdgeInsetsGeometry titlePadding;

  /// useCardList.
  final bool useCardList;

  /// outerRadius.
  final double outerRadius;

  /// innerRadius.
  final double innerRadius;

  /// selectedBorderRadius.
  final double? selectedBorderRadius;

  /// selectedBackgroundColor.
  final Color? selectedBackgroundColor;

  /// itemBackgroundColor.
  final Color? itemBackgroundColor;

  /// itemGap.
  final double itemGap;

  /// trailing.
  final Widget? trailing;

  /// itemPadding.
  final EdgeInsetsGeometry itemPadding;

  /// motion.
  final MorphButtonMotion motion;

  /// MorphOverflowBottomSheetDecoration.

  const MorphOverflowBottomSheetDecoration({
    this.title,
    this.backgroundColor,
    this.elevation,
    this.shape,
    this.showDragHandle = true,
    this.titlePadding = const EdgeInsets.fromLTRB(20, 8, 20, 12),
    this.useCardList = true,
    this.outerRadius = 12.0,
    this.innerRadius = 4.0,
    this.selectedBorderRadius,
    this.selectedBackgroundColor,
    this.itemBackgroundColor,
    this.itemGap = 3.0,
    this.trailing,
    this.itemPadding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    this.motion = MorphButtonMotion.standardOverflow,
  });
}
