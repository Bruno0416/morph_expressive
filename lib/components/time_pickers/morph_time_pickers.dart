import 'package:material_ui/material_ui.dart';

import '../../foundations/foundations.dart';
import 'enums/morph_time_picker_enums.dart';
import 'morph_time_picker_dialog.dart';
import 'models/morph_time.dart';
import 'res/morph_time_picker_constants.dart';
import 'utils/morph_time_picker_utils.dart';

export 'components/morph_day_period_control.dart';
export 'components/morph_dial_time_picker.dart';
export 'components/morph_hour_minute_text_field.dart';
export 'components/morph_input_time_picker_form_field.dart';
export 'components/morph_time_picker_actions.dart';
export 'components/morph_time_picker_dialog_content.dart';
export 'components/morph_time_picker_header.dart';
export 'enums/morph_time_picker_enums.dart';
export 'morph_time_picker_dialog.dart';
export 'models/morph_time.dart';
export 'res/morph_time_picker_constants.dart';
export 'styles/morph_time_picker_theme.dart';
export 'utils/morph_time_picker_utils.dart';

/// Entry points for presenting Morph time picker dialogs.
abstract final class MorphTimePicker {
  const MorphTimePicker._();

  /// Shows a dialog to pick a single time.
  static Future<MorphTime?> show(
    BuildContext context, {
    required MorphTime initialTime,
    MorphTimePickerEntryMode initialEntryMode = MorphTimePickerEntryMode.dial,
    String? helpText,
    String? cancelText,
    String? confirmText,
    String? errorInvalidText,
    String? hourLabelText,
    String? minuteLabelText,
    Orientation? orientation,
    bool? alwaysUse24HourFormat,
    bool emptyInitialInput = false,
    bool barrierDismissible = true,
    String? restorationId,
    ValueChanged<MorphTimePickerEntryMode>? onTimePickerModeChange,
    EdgeInsets insetPadding = MorphTimePickerConstants.defaultInsetPadding,
    bool? resizeToAvoidBottomInset,
  }) {
    final MorphTime normalized = MorphTimePickerUtils.clampTime(initialTime);

    final MorphThemeData theme =
        MorphThemeScope.resolveOf(context) ?? MorphTheme.of(context);
    final dialogTheme = theme.dialogTheme;

    return showGeneralDialog<MorphTime>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: dialogTheme.scrimColor(theme.colorScheme),
      transitionDuration: MorphMotion.medium2,
      pageBuilder: (BuildContext context, _, _) {
        return MorphScrimSystemUi.wrap(
          MorphComponentTheme(
            builder: (BuildContext context) => MorphTimePickerDialog(
              initialTime: normalized,
              initialEntryMode: initialEntryMode,
              helpText: helpText,
              cancelText: cancelText,
              confirmText: confirmText,
              errorInvalidText: errorInvalidText,
              hourLabelText: hourLabelText,
              minuteLabelText: minuteLabelText,
              orientation: orientation,
              alwaysUse24HourFormat: alwaysUse24HourFormat,
              emptyInitialInput: emptyInitialInput,
              restorationId: restorationId,
              onTimePickerModeChange: onTimePickerModeChange,
              insetPadding: insetPadding,
              resizeToAvoidBottomInset: resizeToAvoidBottomInset,
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondary, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: MorphMotion.emphasizedDecelerate,
        );
        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween<double>(
              begin: dialogTheme.entranceScale,
              end: 1,
            ).animate(curved),
            child: child,
          ),
        );
      },
    );
  }
}
