import 'package:morph_expressive/components/time_pickers/morph_time_picker_dialog.dart'
    show MorphTimePickerDialog;
import 'package:morph_expressive/components/time_pickers/morph_time_pickers.dart'
    show MorphTimePickerDialog;
import 'package:morph_expressive/morph_components.dart'
    show MorphTimePickerDialog;

/// Entry mode for [MorphTimePickerDialog].
enum MorphTimePickerEntryMode {
  /// Dial UI; user can switch to input.
  dial,

  /// Text input UI; user can switch to dial.
  input,

  /// Dial UI only (no mode toggle).
  dialOnly,

  /// Text input UI only (no mode toggle).
  inputOnly,
}

/// Which unit the dial is currently editing.
enum MorphTimePickerMode {
  /// Editing the hour hand / field.
  hour,

  /// Editing the minute hand / field.
  minute,
}
