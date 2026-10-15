import 'package:material_ui/material_ui.dart';

import '../../foundations/foundations.dart';
import '../dialogs/styles/morph_dialog_theme.dart';
import 'enums/morph_date_picker_enums.dart';
import 'morph_date_picker_dialog.dart';
import 'morph_date_range_picker_dialog.dart';
import 'models/morph_date_picker_models.dart';
import 'res/morph_date_picker_constants.dart';
import 'utils/morph_date_picker_utils.dart';

export 'components/morph_calendar_date_range_picker.dart';
export 'components/morph_date_picker_actions.dart';
export 'components/morph_date_picker_header.dart';
export 'components/morph_day_picker.dart';
export 'components/morph_input_date_picker_form_field.dart';
export 'components/morph_input_date_range_picker_form_field.dart';
export 'components/morph_month_picker.dart';
export 'components/morph_year_picker.dart';
export 'enums/morph_date_picker_enums.dart';
export 'morph_calendar_date_picker.dart';
export 'morph_date_picker_dialog.dart';
export 'morph_date_range_picker_dialog.dart';
export 'models/morph_calendar_labels.dart';
export 'models/morph_date_picker_models.dart';
export 'res/morph_date_picker_constants.dart';
export 'styles/morph_date_picker_theme.dart';
export 'utils/morph_date_picker_utils.dart';

/// Entry points for presenting Morph date picker dialogs.
abstract final class MorphDatePicker {
  const MorphDatePicker._();

  /// Shows a dialog to pick a single date.
  static Future<DateTime?> show(
    BuildContext context, {
    DateTime? initialDate,
    required DateTime firstDate,
    required DateTime lastDate,
    DateTime? currentDate,
    MorphDatePickerEntryMode initialEntryMode = MorphDatePickerEntryMode.calendar,
    MorphSelectableDayPredicate? selectableDayPredicate,
    String? helpText,
    String? cancelText,
    String? confirmText,
    MorphDatePickerMode initialCalendarMode = MorphDatePickerMode.day,
    String? errorFormatText,
    String? errorInvalidText,
    String? fieldHintText,
    String? fieldLabelText,
    TextInputType? keyboardType,
    bool barrierDismissible = true,
    String? restorationId,
    ValueChanged<MorphDatePickerEntryMode>? onDatePickerModeChange,
    EdgeInsets insetPadding = MorphDatePickerConstants.defaultInsetPadding,
    bool? resizeToAvoidBottomInset,
  }) {
    final DateTime? resolvedInitialDate = initialDate == null
        ? null
        : MorphDatePickerUtils.dateOnly(initialDate);
    final DateTime resolvedFirstDate = MorphDatePickerUtils.dateOnly(firstDate);
    final DateTime resolvedLastDate = MorphDatePickerUtils.dateOnly(lastDate);

    final MorphThemeData theme =
        MorphThemeScope.resolveOf(context) ?? MorphTheme.of(context);
    final MorphDialogTheme dialogTheme = theme.dialogTheme;

    return showGeneralDialog<DateTime>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: dialogTheme.scrimColor(theme.colorScheme),
      transitionDuration: MorphMotion.medium2,
      pageBuilder: (BuildContext context, _, _) {
        return MorphScrimSystemUi.wrap(
          MorphComponentTheme(
            builder: (BuildContext context) => MorphDatePickerDialog(
              initialDate: resolvedInitialDate,
              firstDate: resolvedFirstDate,
              lastDate: resolvedLastDate,
              currentDate: currentDate,
              initialEntryMode: initialEntryMode,
              initialCalendarMode: initialCalendarMode,
              selectableDayPredicate: selectableDayPredicate,
              helpText: helpText,
              cancelText: cancelText,
              confirmText: confirmText,
              errorFormatText: errorFormatText,
              errorInvalidText: errorInvalidText,
              fieldHintText: fieldHintText,
              fieldLabelText: fieldLabelText,
              keyboardType: keyboardType,
              restorationId: restorationId,
              onDatePickerModeChange: onDatePickerModeChange,
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

  /// Shows a dialog to pick a date range.
  static Future<MorphDateRange?> showRange(
    BuildContext context, {
    DateTime? initialStartDate,
    DateTime? initialEndDate,
    required DateTime firstDate,
    required DateTime lastDate,
    DateTime? currentDate,
    MorphDatePickerEntryMode initialEntryMode = MorphDatePickerEntryMode.calendar,
    MorphSelectableDayForRangePredicate? selectableDayPredicate,
    String? helpText,
    String? cancelText,
    String? confirmText,
    String? errorFormatText,
    String? errorInvalidText,
    String? fieldStartHintText,
    String? fieldEndHintText,
    String? fieldStartLabelText,
    String? fieldEndLabelText,
    bool barrierDismissible = true,
    String? restorationId,
    ValueChanged<MorphDatePickerEntryMode>? onDatePickerModeChange,
    EdgeInsets insetPadding = MorphDatePickerConstants.defaultInsetPadding,
    bool? resizeToAvoidBottomInset,
  }) {
    final DateTime? resolvedInitialStartDate = initialStartDate == null
        ? null
        : MorphDatePickerUtils.dateOnly(initialStartDate);
    final DateTime? resolvedInitialEndDate = initialEndDate == null
        ? null
        : MorphDatePickerUtils.dateOnly(initialEndDate);
    final DateTime resolvedFirstDate = MorphDatePickerUtils.dateOnly(firstDate);
    final DateTime resolvedLastDate = MorphDatePickerUtils.dateOnly(lastDate);

    final MorphThemeData theme =
        MorphThemeScope.resolveOf(context) ?? MorphTheme.of(context);
    final MorphDialogTheme dialogTheme = theme.dialogTheme;

    return showGeneralDialog<MorphDateRange>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: dialogTheme.scrimColor(theme.colorScheme),
      transitionDuration: MorphMotion.medium2,
      pageBuilder: (BuildContext context, _, _) {
        return MorphScrimSystemUi.wrap(
          MorphComponentTheme(
            builder: (BuildContext context) => MorphDateRangePickerDialog(
              initialStartDate: resolvedInitialStartDate,
              initialEndDate: resolvedInitialEndDate,
              firstDate: resolvedFirstDate,
              lastDate: resolvedLastDate,
              currentDate: currentDate,
              initialEntryMode: initialEntryMode,
              selectableDayPredicate: selectableDayPredicate,
              helpText: helpText,
              cancelText: cancelText,
              confirmText: confirmText,
              errorFormatText: errorFormatText,
              errorInvalidText: errorInvalidText,
              fieldStartHintText: fieldStartHintText,
              fieldEndHintText: fieldEndHintText,
              fieldStartLabelText: fieldStartLabelText,
              fieldEndLabelText: fieldEndLabelText,
              restorationId: restorationId,
              onDatePickerModeChange: onDatePickerModeChange,
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
