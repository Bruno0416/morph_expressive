import 'package:flutter/foundation.dart';

import '../enums/morph_bottom_sheet_enums.dart';
import '../res/morph_bottom_sheet_strings.dart';

/// Accessibility strings for a bottom sheet.
///
/// Only the drag handle is labelled; it reads as a button.
@immutable
class MorphBottomSheetLabels {
  /// MorphBottomSheetLabels.
  const MorphBottomSheetLabels({
    this.dragHandle = MorphBottomSheetStrings.dragHandle,
    this.expand = MorphBottomSheetStrings.expand,
    this.collapse = MorphBottomSheetStrings.collapse,
    this.dismiss = MorphBottomSheetStrings.dismiss,
    this.close = MorphBottomSheetStrings.close,
    this.scrim = MorphBottomSheetStrings.dismiss,
    this.preview = MorphBottomSheetStrings.preview,
    this.collapsed = MorphBottomSheetStrings.collapsed,
    this.expanded = MorphBottomSheetStrings.expanded,
    this.fullScreen = MorphBottomSheetStrings.fullScreen,
  });

  /// Drag handle label.
  final String dragHandle;

  /// Custom action that moves to a taller height.
  final String expand;

  /// Custom action that moves to a lower height; also the collapse tooltip.
  final String collapse;

  /// Custom action that closes the sheet.
  final String dismiss;

  /// Close button tooltip in the full-screen header.
  final String close;

  /// Scrim label (modal only).
  final String scrim;

  /// Value read for [MorphBottomSheetValue.preview].
  final String preview;

  /// Value read for [MorphBottomSheetValue.collapsed].
  final String collapsed;

  /// Value read for [MorphBottomSheetValue.expanded].
  final String expanded;

  /// Value read for [MorphBottomSheetValue.fullScreen].
  final String fullScreen;

  /// Spoken value for [value].
  String valueOf(MorphBottomSheetValue value) {
    return switch (value) {
      MorphBottomSheetValue.hidden => '',
      MorphBottomSheetValue.preview => preview,
      MorphBottomSheetValue.collapsed => collapsed,
      MorphBottomSheetValue.expanded => expanded,
      MorphBottomSheetValue.fullScreen => fullScreen,
    };
  }
}
