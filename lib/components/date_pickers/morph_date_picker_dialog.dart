import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart'
    show
        AnimatedContainer,
        AutovalidateMode,
        BuildContext,
        Clip,
        Column,
        CrossAxisAlignment,
        EdgeInsets,
        Expanded,
        Form,
        FormState,
        GlobalKey,
        Intent,
        MainAxisSize,
        Material,
        MaterialLocalizations,
        MediaQuery,
        Navigator,
        NextFocusIntent,
        Orientation,
        Padding,
        RestorableDateTimeN,
        RestorableValue,
        RestorationBucket,
        RestorationMixin,
        RoundedRectangleBorder,
        Row,
        ShortcutActivator,
        Shortcuts,
        SingleActivator,
        SingleChildScrollView,
        Size,
        SizedBox,
        State,
        StatefulWidget,
        TextInputType,
        ValueChanged,
        ValueKey,
        Widget;

import '../../foundations/foundations.dart';
import '../dialogs/components/morph_dialog_inset.dart';
import '../divider/morph_divider.dart';
import 'components/morph_date_picker_actions.dart';
import 'components/morph_date_picker_header.dart';
import 'components/morph_date_picker_input_layout.dart';
import 'components/morph_input_date_picker_form_field.dart';
import 'enums/morph_date_picker_enums.dart';
import 'morph_calendar_date_picker.dart';
import 'models/morph_date_picker_models.dart';
import 'res/morph_date_picker_constants.dart';
import 'utils/morph_date_picker_utils.dart';

/// Dialog for picking a single date.
class MorphDatePickerDialog extends StatefulWidget {
  /// MorphDatePickerDialog.
  const MorphDatePickerDialog({
    required this.firstDate,
    required this.lastDate,
    this.initialDate,
    this.currentDate,
    this.initialEntryMode = MorphDatePickerEntryMode.calendar,
    this.initialCalendarMode = MorphDatePickerMode.day,
    this.selectableDayPredicate,
    this.helpText,
    this.cancelText,
    this.confirmText,
    this.errorFormatText,
    this.errorInvalidText,
    this.fieldHintText,
    this.fieldLabelText,
    this.keyboardType,
    this.restorationId,
    this.onDatePickerModeChange,
    this.insetPadding = MorphDatePickerConstants.defaultInsetPadding,
    this.resizeToAvoidBottomInset,
    super.key,
  });

  /// initialDate.

  final DateTime? initialDate;

  /// firstDate.
  final DateTime firstDate;

  /// lastDate.
  final DateTime lastDate;

  /// currentDate.
  final DateTime? currentDate;

  /// initialEntryMode.
  final MorphDatePickerEntryMode initialEntryMode;

  /// initialCalendarMode.
  final MorphDatePickerMode initialCalendarMode;

  /// selectableDayPredicate.
  final MorphSelectableDayPredicate? selectableDayPredicate;

  /// helpText.
  final String? helpText;

  /// cancelText.
  final String? cancelText;

  /// confirmText.
  final String? confirmText;

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

  /// restorationId.
  final String? restorationId;

  /// onDatePickerModeChange.
  final ValueChanged<MorphDatePickerEntryMode>? onDatePickerModeChange;

  /// insetPadding.
  final EdgeInsets insetPadding;

  /// When null, uses dialog theme `resizeToAvoidBottomInset`.
  final bool? resizeToAvoidBottomInset;

  @override
  State<MorphDatePickerDialog> createState() => _MorphDatePickerDialogState();
}

class _MorphDatePickerDialogState extends State<MorphDatePickerDialog>
    with RestorationMixin {
  late final RestorableDateTimeN _selectedDate = RestorableDateTimeN(
    widget.initialDate,
  );
  late final _RestorableMorphDatePickerEntryMode _entryMode =
      _RestorableMorphDatePickerEntryMode(widget.initialEntryMode);
  final _RestorableAutovalidateMode _autovalidateMode =
      _RestorableAutovalidateMode(AutovalidateMode.disabled);
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  String? get restorationId => widget.restorationId;

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_selectedDate, 'selected_date');
    registerForRestoration(_autovalidateMode, 'autovalidateMode');
    registerForRestoration(_entryMode, 'calendar_entry_mode');
  }

  @override
  void dispose() {
    _selectedDate.dispose();
    _entryMode.dispose();
    _autovalidateMode.dispose();
    super.dispose();
  }

  void _handleOk() {
    if (_entryMode.value == MorphDatePickerEntryMode.input ||
        _entryMode.value == MorphDatePickerEntryMode.inputOnly) {
      final FormState? form = _formKey.currentState;
      if (form == null || !form.validate()) {
        setState(() => _autovalidateMode.value = AutovalidateMode.always);
        return;
      }
      form.save();
    }
    Navigator.of(context).pop(_selectedDate.value);
  }

  void _handleCancel() {
    Navigator.of(context).pop();
  }

  void _handleEntryModeToggle() {
    setState(() {
      switch (_entryMode.value) {
        case MorphDatePickerEntryMode.calendar:
          _autovalidateMode.value = AutovalidateMode.disabled;
          _entryMode.value = MorphDatePickerEntryMode.input;
        case MorphDatePickerEntryMode.input:
          _formKey.currentState?.save();
          _entryMode.value = MorphDatePickerEntryMode.calendar;
        case MorphDatePickerEntryMode.calendarOnly:
        case MorphDatePickerEntryMode.inputOnly:
          break;
      }
      widget.onDatePickerModeChange?.call(_entryMode.value);
    });
  }

  void _handleDateChanged(DateTime date) {
    setState(() => _selectedDate.value = MorphDatePickerUtils.dateOnly(date));
  }

  Widget _buildPickerBody({required Widget picker, required bool isInputMode}) {
    if (!isInputMode) {
      return picker;
    }
    return MorphDatePickerInputLayout(child: picker);
  }

  Widget _buildContentColumn({
    required Widget pickerBody,
    required Widget actions,
  }) {
    // Inset picker + actions from dialog edges (input was flush to the top;
    // actions sat on the bottom/side edges).
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(child: pickerBody),
          actions,
        ],
      ),
    );
  }

  Size _dialogSize(BuildContext context) {
    final bool isCalendar = switch (_entryMode.value) {
      MorphDatePickerEntryMode.calendar ||
      MorphDatePickerEntryMode.calendarOnly => true,
      MorphDatePickerEntryMode.input ||
      MorphDatePickerEntryMode.inputOnly => false,
    };
    final Orientation orientation = MediaQuery.orientationOf(context);
    return switch ((isCalendar, orientation)) {
      (true, Orientation.portrait) =>
        MorphDatePickerConstants.calendarPortraitDialogSize,
      (false, Orientation.portrait) =>
        MorphDatePickerConstants.inputPortraitDialogSize,
      (true, Orientation.landscape) =>
        MorphDatePickerConstants.calendarLandscapeDialogSize,
      (false, Orientation.landscape) =>
        MorphDatePickerConstants.inputLandscapeDialogSize,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = MorphTheme.of(context);
    final dateTheme = theme.datePickerTheme;
    final localizations = MaterialLocalizations.of(context);
    final Orientation orientation = MediaQuery.orientationOf(context);
    final DateTime firstDate = MorphDatePickerUtils.dateOnly(widget.firstDate);
    final DateTime lastDate = MorphDatePickerUtils.dateOnly(widget.lastDate);
    final DateTime currentDate = MorphDatePickerUtils.dateOnly(
      widget.currentDate ?? DateTime.now(),
    );
    final String titleText = _selectedDate.value == null
        ? ''
        : localizations.formatMediumDate(_selectedDate.value!);
    final ({Widget picker, Widget? entryModeButton}) resolved =
        _resolvePickerAndEntryButton(
          localizations: localizations,
          firstDate: firstDate,
          lastDate: lastDate,
          currentDate: currentDate,
        );
    final bool isInputMode =
        _entryMode.value == MorphDatePickerEntryMode.input ||
        _entryMode.value == MorphDatePickerEntryMode.inputOnly;
    final Widget header = MorphDatePickerHeader(
      helpText: widget.helpText ?? localizations.datePickerHelpText,
      titleText: titleText,
      showTitle: _selectedDate.value != null,
      orientation: orientation,
      isShort: orientation == Orientation.landscape,
      alignHelpWithSubHeader:
          orientation == Orientation.landscape && !isInputMode,
      entryModeButton: resolved.entryModeButton,
    );
    final Widget actions = MorphDatePickerActions(
      cancelText: widget.cancelText ?? localizations.cancelButtonLabel,
      confirmText: widget.confirmText ?? localizations.okButtonLabel,
      onCancel: _handleCancel,
      onConfirm: _handleOk,
    );
    final double textScaleFactor =
        MediaQuery.textScalerOf(context)
            .clamp(maxScaleFactor: MorphDatePickerConstants.maxTextScaleFactor)
            .scale(MorphDatePickerConstants.fontSizeToScale) /
        MorphDatePickerConstants.fontSizeToScale;
    final Size dialogSize = _dialogSize(context) * textScaleFactor;
    final Widget pickerBody = _buildPickerBody(
      picker: resolved.picker,
      isInputMode: isInputMode,
    );
    final Widget dialog = Material(
      color: dateTheme.backgroundColor(theme.colorScheme),
      elevation: dateTheme.elevation,
      shape: RoundedRectangleBorder(borderRadius: dateTheme.dialogShape),
      clipBehavior: Clip.antiAlias,
      child: AnimatedContainer(
        width: dialogSize.width,
        height: dialogSize.height,
        duration: MorphDatePickerConstants.dialogSizeAnimationDuration,
        curve: MorphMotion.exit,
        child: switch (orientation) {
          Orientation.portrait => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              header,
              MorphDivider(color: dateTheme.dividerColor(theme.colorScheme)),
              Expanded(
                child: _buildContentColumn(
                  pickerBody: pickerBody,
                  actions: actions,
                ),
              ),
            ],
          ),
          Orientation.landscape => Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              header,
              MorphDivider(
                axis: MorphDividerAxis.vertical,
                color: dateTheme.dividerColor(theme.colorScheme),
              ),
              Expanded(
                child: _buildContentColumn(
                  pickerBody: pickerBody,
                  actions: actions,
                ),
              ),
            ],
          ),
        },
      ),
    );
    return MorphDialogInset(
      padding: widget.insetPadding,
      resizeToAvoidBottomInset: widget.resizeToAvoidBottomInset,
      child: isInputMode
          ? SizedBox(
              width: dialogSize.width,
              child: SingleChildScrollView(child: dialog),
            )
          : dialog,
    );
  }

  ({Widget picker, Widget? entryModeButton}) _resolvePickerAndEntryButton({
    required MaterialLocalizations localizations,
    required DateTime firstDate,
    required DateTime lastDate,
    required DateTime currentDate,
  }) {
    switch (_entryMode.value) {
      case MorphDatePickerEntryMode.calendar:
        return (
          picker: _buildCalendarPicker(
            firstDate: firstDate,
            lastDate: lastDate,
            currentDate: currentDate,
          ),
          entryModeButton: MorphDatePickerEntryModeButton(
            icon: MorphIcons.edit_outlined,
            tooltip: localizations.inputDateModeButtonLabel,
            onPressed: _handleEntryModeToggle,
          ),
        );
      case MorphDatePickerEntryMode.calendarOnly:
        return (
          picker: _buildCalendarPicker(
            firstDate: firstDate,
            lastDate: lastDate,
            currentDate: currentDate,
          ),
          entryModeButton: null,
        );
      case MorphDatePickerEntryMode.input:
      case MorphDatePickerEntryMode.inputOnly:
        return (
          picker: Form(
            key: _formKey,
            autovalidateMode: _autovalidateMode.value,
            child: Shortcuts(
              shortcuts: const <ShortcutActivator, Intent>{
                SingleActivator(LogicalKeyboardKey.enter): NextFocusIntent(),
              },
              child: MorphInputDatePickerFormField(
                initialDate: _selectedDate.value,
                firstDate: firstDate,
                lastDate: lastDate,
                onDateSubmitted: _handleDateChanged,
                onDateSaved: _handleDateChanged,
                selectableDayPredicate: widget.selectableDayPredicate,
                errorFormatText: widget.errorFormatText,
                errorInvalidText: widget.errorInvalidText,
                fieldHintText: widget.fieldHintText,
                fieldLabelText: widget.fieldLabelText,
                keyboardType: widget.keyboardType,
                autofocus: true,
              ),
            ),
          ),
          entryModeButton: _entryMode.value == MorphDatePickerEntryMode.input
              ? MorphDatePickerEntryModeButton(
                  icon: MorphIcons.calendar_today,
                  tooltip: localizations.calendarModeButtonLabel,
                  onPressed: _handleEntryModeToggle,
                )
              : null,
        );
    }
  }

  Widget _buildCalendarPicker({
    required DateTime firstDate,
    required DateTime lastDate,
    required DateTime currentDate,
  }) {
    return MorphCalendarDatePicker(
      key: ValueKey<DateTime?>(_selectedDate.value),
      initialDate: _selectedDate.value,
      firstDate: firstDate,
      lastDate: lastDate,
      currentDate: currentDate,
      initialCalendarMode: widget.initialCalendarMode,
      selectableDayPredicate: widget.selectableDayPredicate,
      onDateChanged: _handleDateChanged,
      expandToFit: true,
    );
  }
}

class _RestorableAutovalidateMode extends RestorableValue<AutovalidateMode> {
  _RestorableAutovalidateMode(this.defaultValue);

  final AutovalidateMode defaultValue;

  @override
  AutovalidateMode createDefaultValue() => defaultValue;

  @override
  void didUpdateValue(AutovalidateMode? oldValue) {
    notifyListeners();
  }

  @override
  AutovalidateMode fromPrimitives(Object? data) {
    return AutovalidateMode.values[data! as int];
  }

  @override
  Object? toPrimitives() => value.index;
}

class _RestorableMorphDatePickerEntryMode
    extends RestorableValue<MorphDatePickerEntryMode> {
  _RestorableMorphDatePickerEntryMode(this.defaultValue);

  final MorphDatePickerEntryMode defaultValue;

  @override
  MorphDatePickerEntryMode createDefaultValue() => defaultValue;

  @override
  void didUpdateValue(MorphDatePickerEntryMode? oldValue) {
    notifyListeners();
  }

  @override
  MorphDatePickerEntryMode fromPrimitives(Object? data) {
    return MorphDatePickerEntryMode.values[data! as int];
  }

  @override
  Object? toPrimitives() => value.index;
}
