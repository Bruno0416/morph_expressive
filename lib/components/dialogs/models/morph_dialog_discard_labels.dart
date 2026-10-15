import 'package:flutter/foundation.dart';

import '../res/morph_dialog_strings.dart';

/// Copy for the basic dialog that confirms discarding unsaved changes.
@immutable
class MorphDialogDiscardLabels {
  /// MorphDialogDiscardLabels.
  const MorphDialogDiscardLabels({
    this.title = MorphDialogStrings.discardTitle,
    this.keepLabel = MorphDialogStrings.keepEditing,
    this.discardLabel = MorphDialogStrings.discard,
    this.supportingText,
  });

  /// Headline ("Discard unsaved changes?").
  final String title;

  /// Dismissive action ("Keep editing").
  final String keepLabel;

  /// Confirming action ("Discard").
  final String discardLabel;

  /// Optional supporting text.
  final String? supportingText;
}
