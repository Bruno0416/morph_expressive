import 'package:flutter/widgets.dart';

import '../../../foundations/foundations.dart';
import '../../buttons/morph_buttons.dart';
import '../res/morph_date_picker_constants.dart';

/// Cancel and confirm actions for date picker dialogs.
class MorphDatePickerActions extends StatelessWidget {
  /// MorphDatePickerActions.
  const MorphDatePickerActions({
    required this.onCancel,
    required this.onConfirm,
    required this.cancelText,
    required this.confirmText,
    this.entryModeButton,
    super.key,
  });

  /// onCancel.
  final VoidCallback onCancel;

  /// onConfirm.
  final VoidCallback onConfirm;

  /// cancelText.
  final String cancelText;

  /// confirmText.
  final String confirmText;

  /// Kept for API compatibility; entry mode lives in the date picker header.
  final Widget? entryModeButton;

  @override
  Widget build(BuildContext context) {
    final dialogTheme = MorphTheme.of(context).dialogTheme;

    // Outer content padding is applied by the dialog; keep action bar compact.
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minHeight: MorphDatePickerConstants.actionsMinHeight,
      ),
      child: Align(
        alignment: AlignmentDirectional.centerEnd,
        child: OverflowBar(
          spacing: dialogTheme.actionGap,
          children: <Widget>[
            MorphButton(
              style: MorphButtonStyle.text,
              onPressed: onCancel,
              child: Text(cancelText),
            ),
            MorphButton(onPressed: onConfirm, child: Text(confirmText)),
          ],
        ),
      ),
    );
  }
}
