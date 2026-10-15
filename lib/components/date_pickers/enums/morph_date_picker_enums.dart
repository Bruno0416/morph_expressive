import 'package:morph_expressive/components/date_pickers/morph_date_pickers.dart'
    show MorphCalendarDatePicker, MorphDatePickerDialog, MorphDateRangePickerDialog;
import 'package:morph_expressive/morph_components.dart'
    show MorphCalendarDatePicker, MorphDatePickerDialog, MorphDateRangePickerDialog;

/// Entry mode for [MorphDatePickerDialog] and [MorphDateRangePickerDialog].
enum MorphDatePickerEntryMode {
  /// Calendar only, with an icon button to switch to input mode.
  calendar,

  /// Text input only, with an icon button to switch to calendar mode.
  input,

  /// Calendar only with no way to switch to input mode.
  calendarOnly,

  /// Text input only with no way to switch to calendar mode.
  inputOnly,
}

/// Calendar sub-view for [MorphCalendarDatePicker].
enum MorphDatePickerMode {
  /// Day grid for the displayed month.
  day,

  /// Scrollable year grid.
  year,
}
