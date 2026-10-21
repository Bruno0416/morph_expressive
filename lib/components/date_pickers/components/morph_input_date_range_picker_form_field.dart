import 'package:material_ui/material_ui.dart'
    show
        BuildContext,
        CrossAxisAlignment,
        Expanded,
        MaterialLocalizations,
        Row,
        SizedBox,
        StatelessWidget,
        ValueChanged,
        Widget;

import '../models/morph_date_picker_models.dart';
import 'morph_input_date_picker_form_field.dart';

/// Text fields for entering a date range in a picker dialog.
class MorphInputDateRangePickerFormField extends StatelessWidget {
  /// MorphInputDateRangePickerFormField.
  const MorphInputDateRangePickerFormField({
    required this.firstDate,
    required this.lastDate,
    this.initialStartDate,
    this.initialEndDate,
    this.onStartDateSaved,
    this.onEndDateSaved,
    this.selectableDayPredicate,
    this.errorFormatText,
    this.errorInvalidText,
    this.fieldStartHintText,
    this.fieldEndHintText,
    this.fieldStartLabelText,
    this.fieldEndLabelText,
    super.key,
  });

  /// firstDate.

  final DateTime firstDate;

  /// lastDate.
  final DateTime lastDate;

  /// initialStartDate.
  final DateTime? initialStartDate;

  /// initialEndDate.
  final DateTime? initialEndDate;

  /// onStartDateSaved.
  final ValueChanged<DateTime>? onStartDateSaved;

  /// onEndDateSaved.
  final ValueChanged<DateTime>? onEndDateSaved;

  /// selectableDayPredicate.
  final MorphSelectableDayForRangePredicate? selectableDayPredicate;

  /// errorFormatText.
  final String? errorFormatText;

  /// errorInvalidText.
  final String? errorInvalidText;

  /// fieldStartHintText.
  final String? fieldStartHintText;

  /// fieldEndHintText.
  final String? fieldEndHintText;

  /// fieldStartLabelText.
  final String? fieldStartLabelText;

  /// fieldEndLabelText.
  final String? fieldEndLabelText;

  @override
  Widget build(BuildContext context) {
    final MaterialLocalizations localizations = MaterialLocalizations.of(
      context,
    );
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: MorphInputDatePickerFormField(
            firstDate: firstDate,
            lastDate: lastDate,
            initialDate: initialStartDate,
            onDateSaved: onStartDateSaved,
            selectableDayPredicate: selectableDayPredicate,
            errorFormatText: errorFormatText,
            errorInvalidText: errorInvalidText,
            fieldHintText: fieldStartHintText,
            fieldLabelText:
                fieldStartLabelText ?? localizations.dateRangeStartLabel,
            autofocus: true,
            reserveFloatingLabelSpace: true,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: MorphInputDatePickerFormField(
            firstDate: firstDate,
            lastDate: lastDate,
            initialDate: initialEndDate,
            onDateSaved: onEndDateSaved,
            selectableDayPredicate: selectableDayPredicate,
            errorFormatText: errorFormatText,
            errorInvalidText: errorInvalidText,
            fieldHintText: fieldEndHintText,
            fieldLabelText:
                fieldEndLabelText ?? localizations.dateRangeEndLabel,
            reserveFloatingLabelSpace: true,
          ),
        ),
      ],
    );
  }
}
