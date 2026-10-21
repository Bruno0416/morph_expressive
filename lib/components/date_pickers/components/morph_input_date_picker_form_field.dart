import 'package:material_ui/material_ui.dart'
    show
        BuildContext,
        FocusNode,
        FormField,
        FormFieldState,
        MaterialLocalizations,
        State,
        StatefulWidget,
        TextEditingController,
        TextEditingValue,
        TextInputType,
        TextSelection,
        ValueChanged,
        Widget,
        WidgetsBinding;

import '../../text_fields/morph_text_fields.dart';
import '../models/morph_date_picker_models.dart';
import '../utils/morph_date_picker_utils.dart';

/// Text field for entering a single date in a picker dialog.
class MorphInputDatePickerFormField extends StatefulWidget {
  /// MorphInputDatePickerFormField.
  const MorphInputDatePickerFormField({
    required this.firstDate,
    required this.lastDate,
    this.initialDate,
    this.onDateSubmitted,
    this.onDateSaved,
    this.selectableDayPredicate,
    this.errorFormatText,
    this.errorInvalidText,
    this.fieldHintText,
    this.fieldLabelText,
    this.keyboardType,
    this.autofocus = false,
    this.acceptEmptyDate = false,
    this.reserveFloatingLabelSpace = false,
    this.focusNode,
    super.key,
  });

  /// initialDate.

  final DateTime? initialDate;

  /// firstDate.
  final DateTime firstDate;

  /// lastDate.
  final DateTime lastDate;

  /// onDateSubmitted.
  final ValueChanged<DateTime>? onDateSubmitted;

  /// onDateSaved.
  final ValueChanged<DateTime>? onDateSaved;

  /// selectableDayPredicate.
  final MorphSelectableDayPredicate? selectableDayPredicate;

  /// errorFormatText.
  final String? errorFormatText;

  /// errorInvalidText.
  final String? errorInvalidText;

  /// fieldHintText.
  final String? fieldHintText;

  /// fieldLabelText.
  final String? fieldLabelText;

  /// keyboardType.
  final TextInputType? keyboardType;

  /// autofocus.
  final bool autofocus;

  /// acceptEmptyDate.
  final bool acceptEmptyDate;

  /// Keep the filled field surface aligned with neighboring date fields.
  final bool reserveFloatingLabelSpace;

  /// focusNode.
  final FocusNode? focusNode;

  @override
  State<MorphInputDatePickerFormField> createState() =>
      _MorphInputDatePickerFormFieldState();
}

class _MorphInputDatePickerFormFieldState
    extends State<MorphInputDatePickerFormField> {
  final TextEditingController _controller = TextEditingController();
  DateTime? _selectedDate;
  bool _autoSelected = false;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate == null
        ? null
        : MorphDatePickerUtils.dateOnly(widget.initialDate!);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateValueForSelectedDate();
  }

  @override
  void didUpdateWidget(covariant MorphInputDatePickerFormField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialDate != oldWidget.initialDate) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        setState(() {
          _selectedDate = widget.initialDate == null
              ? null
              : MorphDatePickerUtils.dateOnly(widget.initialDate!);
          _updateValueForSelectedDate();
        });
      });
    }
  }

  void _updateValueForSelectedDate() {
    if (_selectedDate != null) {
      final String text = MaterialLocalizations.of(context)
          .formatCompactDate(_selectedDate!);
      var value = TextEditingValue(text: text);
      if (widget.autofocus && !_autoSelected) {
        value = value.copyWith(
          selection: TextSelection(baseOffset: 0, extentOffset: text.length),
        );
        _autoSelected = true;
      }
      _controller.value = value;
    } else {
      _controller.value = TextEditingValue.empty;
    }
  }

  DateTime? _parseDate(String? text) {
    return MaterialLocalizations.of(context).parseCompactDate(text);
  }

  bool _isValidAcceptableDate(DateTime? date) {
    if (date == null) {
      return false;
    }
    final DateTime normalized = MorphDatePickerUtils.dateOnly(date);
    return MorphDatePickerUtils.isSelectable(
      normalized,
      MorphDatePickerUtils.dateOnly(widget.firstDate),
      MorphDatePickerUtils.dateOnly(widget.lastDate),
      predicate: widget.selectableDayPredicate,
    );
  }

  String? _validate(String? text) {
    if ((text == null || text.isEmpty) && widget.acceptEmptyDate) {
      return null;
    }
    final DateTime? parsed = _parseDate(text);
    if (parsed == null) {
      return widget.errorFormatText ??
          MaterialLocalizations.of(context).invalidDateFormatLabel;
    }
    if (!_isValidAcceptableDate(parsed)) {
      return widget.errorInvalidText ??
          MaterialLocalizations.of(context).invalidDateRangeLabel;
    }
    return null;
  }

  void _handleSaved(String? value) {
    final DateTime? parsed = _parseDate(value);
    if (parsed != null && _isValidAcceptableDate(parsed)) {
      widget.onDateSaved?.call(MorphDatePickerUtils.dateOnly(parsed));
    }
  }

  void _handleSubmitted(String value) {
    final DateTime? parsed = _parseDate(value);
    if (parsed != null && _isValidAcceptableDate(parsed)) {
      widget.onDateSubmitted?.call(MorphDatePickerUtils.dateOnly(parsed));
    }
  }

  @override
  Widget build(BuildContext context) {
    final MaterialLocalizations localizations = MaterialLocalizations.of(
      context,
    );
    return FormField<String>(
      initialValue: _controller.text,
      validator: _validate,
      onSaved: _handleSaved,
      builder: (FormFieldState<String> field) {
        return MorphTextField(
          controller: _controller,
          focusNode: widget.focusNode,
          autofocus: widget.autofocus,
          reserveFloatingLabelSpace: widget.reserveFloatingLabelSpace,
          label: widget.fieldLabelText ?? localizations.dateInputLabel,
          keyboardType: widget.keyboardType ?? TextInputType.datetime,
          errorText: field.errorText,
          onSubmitted: (String value) {
            field.didChange(value);
            if (field.validate()) {
              _handleSubmitted(value);
            }
          },
          onChanged: field.didChange,
        );
      },
    );
  }
}
