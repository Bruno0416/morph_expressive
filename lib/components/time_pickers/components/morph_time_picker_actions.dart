import 'package:flutter/widgets.dart';

import '../../../foundations/foundations.dart';
import '../../buttons/morph_buttons.dart';

/// Cancel and confirm actions for time picker dialogs.
class MorphTimePickerActions extends StatelessWidget {
  /// MorphTimePickerActions.
  const MorphTimePickerActions({
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

  /// Optional dial/input toggle at the far start (bottom-left).
  final Widget? entryModeButton;

  @override
  Widget build(BuildContext context) {
    final dialogTheme = MorphTheme.of(context).dialogTheme;

    return Padding(
      padding: EdgeInsetsDirectional.only(top: dialogTheme.actionGap),
      child: Row(
        children: <Widget>[
          ?entryModeButton,
          Expanded(
            child: Align(
              alignment: AlignmentDirectional.centerEnd,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  MorphButton(
                    style: MorphButtonStyle.text,
                    onPressed: onCancel,
                    child: Text(cancelText),
                  ),
                  SizedBox(width: dialogTheme.actionGap),
                  MorphButton(onPressed: onConfirm, child: Text(confirmText)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
