import 'package:material_ui/material_ui.dart';

import '../../buttons/styles/morph_button_motion.dart';
import '../enums/morph_split_button_selection_mode.dart';
import 'morph_split_button_checkbox_style.dart';

/// Styling options for split-button bottom-sheet menus.
@immutable
class MorphSplitButtonBottomSheetDecoration {
  /// MorphSplitButtonBottomSheetDecoration.
  const MorphSplitButtonBottomSheetDecoration({
    this.title,
    this.titlePadding,
    this.showDragHandle = true,
    this.backgroundColor,
    this.elevation,
    this.shape,
    this.motion = MorphButtonMotion.expressiveSpatialDefault,
    this.selectionMode = MorphSplitButtonSelectionMode.single,
    this.checkboxStyle,
  });

  /// title.

  final Widget? title;

  /// titlePadding.
  final EdgeInsetsGeometry? titlePadding;

  /// showDragHandle.
  final bool showDragHandle;

  /// backgroundColor.
  final Color? backgroundColor;

  /// elevation.
  final double? elevation;

  /// shape.
  final ShapeBorder? shape;

  /// motion.
  final MorphButtonMotion motion;

  /// selectionMode.
  final MorphSplitButtonSelectionMode selectionMode;

  /// checkboxStyle.
  final MorphSplitButtonCheckboxStyle? checkboxStyle;

  /// copyWith.

  MorphSplitButtonBottomSheetDecoration copyWith({
    Widget? title,
    EdgeInsetsGeometry? titlePadding,
    bool? showDragHandle,
    Color? backgroundColor,
    double? elevation,
    ShapeBorder? shape,
    MorphButtonMotion? motion,
    MorphSplitButtonSelectionMode? selectionMode,
    MorphSplitButtonCheckboxStyle? checkboxStyle,
  }) {
    return MorphSplitButtonBottomSheetDecoration(
      title: title ?? this.title,
      titlePadding: titlePadding ?? this.titlePadding,
      showDragHandle: showDragHandle ?? this.showDragHandle,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      elevation: elevation ?? this.elevation,
      shape: shape ?? this.shape,
      motion: motion ?? this.motion,
      selectionMode: selectionMode ?? this.selectionMode,
      checkboxStyle: checkboxStyle ?? this.checkboxStyle,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MorphSplitButtonBottomSheetDecoration &&
          title == other.title &&
          titlePadding == other.titlePadding &&
          showDragHandle == other.showDragHandle &&
          backgroundColor == other.backgroundColor &&
          elevation == other.elevation &&
          shape == other.shape &&
          motion == other.motion &&
          selectionMode == other.selectionMode &&
          checkboxStyle == other.checkboxStyle;

  @override
  int get hashCode => Object.hash(
    title,
    titlePadding,
    showDragHandle,
    backgroundColor,
    elevation,
    shape,
    motion,
    selectionMode,
    checkboxStyle,
  );
}
