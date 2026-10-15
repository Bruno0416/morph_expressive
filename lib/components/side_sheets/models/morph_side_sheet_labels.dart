import 'package:flutter/foundation.dart';

import '../res/morph_side_sheet_strings.dart';

/// Accessibility strings for a side sheet.
///
/// The sheet itself reads as a dialog named by its headline.
@immutable
class MorphSideSheetLabels {
  /// MorphSideSheetLabels.
  const MorphSideSheetLabels({
    this.close = MorphSideSheetStrings.close,
    this.back = MorphSideSheetStrings.back,
    this.scrim = MorphSideSheetStrings.dismiss,
  });

  /// Close icon button tooltip and label.
  final String close;

  /// Back icon button tooltip and label.
  final String back;

  /// Scrim label (modal only).
  final String scrim;
}
