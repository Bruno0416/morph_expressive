import 'package:material_ui/material_ui.dart'
    show
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
        MainAxisSize,
        Material,
        MaterialLocalizations,
        MediaQuery,
        Navigator,
        Orientation,
        Padding,
        RestorableDateTimeN,
        RestorableValue,
        RestorationBucket,
        RestorationMixin,
        RoundedRectangleBorder,
        Row,
        SingleChildScrollView,
        Size,
        SizedBox,
        State,
        StatefulWidget,
        ValueChanged,
        Widget;

import '../../foundations/foundations.dart';
import '../dialogs/components/morph_dialog_inset.dart';
import '../divider/morph_divider.dart';
import 'components/morph_calendar_date_range_picker.dart';
import 'components/morph_date_picker_actions.dart';
import 'components/morph_date_picker_header.dart';
import 'components/morph_date_picker_input_layout.dart';
import 'components/morph_input_date_range_picker_form_field.dart';
import 'enums/morph_date_picker_enums.dart';
import 'models/morph_date_picker_models.dart';
import 'res/morph_date_picker_constants.dart';
import 'utils/morph_date_picker_utils.dart';

/// Dialog for picking a date range.
class MorphDateRangePickerDialog extends StatefulWidget {
  /// MorphDateRangePickerDialog.
  const MorphDateRangePickerDialog({
    required this.firstDate,
    required this.lastDate,
    this.initialStartDate,
    this.initialEndDate,
    this.currentDate,
    this.initialEntryMode = MorphDatePickerEntryMode.calendar,
    this.selectableDayPredicate,
    this.helpText,
    this.cancelText,
    this.confirmText,
    this.errorFormatText,
    this.errorInvalidText,
    this.fieldStartHintText,
    this.fieldEndHintText,
    this.fieldStartLabelText,
    this.fieldEndLabelText,
    this.restorationId,
    this.onDatePickerModeChange,
    this.insetPadding = MorphDatePickerConstants.defaultInsetPadding,
    this.resizeToAvoidBottomInset,
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

  /// currentDate.
  final DateTime? currentDate;

  /// initialEntryMode.
  final MorphDatePickerEntryMode initialEntryMode;

  /// selectableDayPredicate.
  final MorphSelectableDayForRangePredicate? selectableDayPredicate;

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

  /// fieldStartHintText.
  final String? fieldStartHintText;

  /// fieldEndHintText.
  final String? fieldEndHintText;

  /// fieldStartLabelText.
  final String? fieldStartLabelText;

  /// fieldEndLabelText.
  final String? fieldEndLabelText;

  /// restorationId.
  final String? restorationId;

  /// onDatePickerModeChange.
  final ValueChanged<MorphDatePickerEntryMode>? onDatePickerModeChange;

  /// insetPadding.
  final EdgeInsets insetPadding;

  /// When null, uses dialog theme `resizeToAvoidBottomInset`.
  final bool? resizeToAvoidBottomInset;

  @override
  State<MorphDateRangePickerDialog> createState() =>
      _MorphDateRangePickerDialogState();
}

class _MorphDateRangePickerDialogState extends State<MorphDateRangePickerDialog>
    with RestorationMixin {
  late final RestorableDateTimeN _startDate = RestorableDateTimeN(
    widget.initialStartDate,
  );
  late final RestorableDateTimeN _endDate = RestorableDateTimeN(
    widget.initialEndDate,
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
    registerForRestoration(_startDate, 'start_date');
    registerForRestoration(_endDate, 'end_date');
    registerForRestoration(_autovalidateMode, 'autovalidateMode');
    registerForRestoration(_entryMode, 'calendar_entry_mode');
  }

  @override
  void dispose() {
    _startDate.dispose();
    _endDate.dispose();
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
    if (_startDate.value == null) {
      return;
    }
    Navigator.of(context)
        .pop(MorphDateRange(start: _startDate.value!, end: _endDate.value));
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

  String _headerTitle(MaterialLocalizations localizations) {
    if (_startDate.value == null) {
      return '';
    }
    if (_endDate.value == null) {
      return localizations.formatMediumDate(_startDate.value!);
    }
    return '${localizations.formatMediumDate(_startDate.value!)} – ${localizations.formatMediumDate(_endDate.value!)}';
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
    final ({Widget picker, Widget? entryModeButton}) resolved =
        _resolveRangePickerAndEntryButton(
          localizations: localizations,
          firstDate: firstDate,
          lastDate: lastDate,
          currentDate: currentDate,
        );
    final bool isInputMode =
        _entryMode.value == MorphDatePickerEntryMode.input ||
        _entryMode.value == MorphDatePickerEntryMode.inputOnly;
    final Size dialogSize =
        (switch ((isInputMode, orientation)) {
          (false, Orientation.portrait) =>
            MorphDatePickerConstants.calendarPortraitDialogSize,
          (true, Orientation.portrait) =>
            MorphDatePickerConstants.inputPortraitDialogSize,
          (false, Orientation.landscape) =>
            MorphDatePickerConstants.calendarLandscapeDialogSize,
          (true, Orientation.landscape) =>
            MorphDatePickerConstants.inputRangeLandscapeDialogSize,
        }) *
        (MediaQuery.textScalerOf(context)
                .clamp(
                  maxScaleFactor:
                      MorphDatePickerConstants.maxRangeTextScaleFactor,
                )
                .scale(MorphDatePickerConstants.fontSizeToScale) /
            MorphDatePickerConstants.fontSizeToScale);
    final Widget pickerBody = isInputMode
        ? MorphDatePickerInputLayout(child: resolved.picker)
        : resolved.picker;
    final Widget header = MorphDatePickerHeader(
      helpText: widget.helpText ?? localizations.dateRangePickerHelpText,
      titleText: _headerTitle(localizations),
      showTitle: _startDate.value != null,
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
    final Widget content = Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(child: pickerBody),
          actions,
        ],
      ),
    );
    final Widget dialog = Material(
      animationDuration: MorphMotion.durationOf(context, MorphMotion.short4),
      color: dateTheme.backgroundColor(theme.colorScheme),
      elevation: dateTheme.elevation,
      shape: RoundedRectangleBorder(borderRadius: dateTheme.dialogShape),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        width: dialogSize.width,
        height: dialogSize.height,
        child: switch (orientation) {
          Orientation.portrait => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              header,
              MorphDivider(color: dateTheme.dividerColor(theme.colorScheme)),
              Expanded(child: content),
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
              Expanded(child: content),
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

  ({Widget picker, Widget? entryModeButton}) _resolveRangePickerAndEntryButton({
    required MaterialLocalizations localizations,
    required DateTime firstDate,
    required DateTime lastDate,
    required DateTime currentDate,
  }) {
    switch (_entryMode.value) {
      case MorphDatePickerEntryMode.calendar:
        return (
          picker: _buildRangeCalendar(
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
          picker: _buildRangeCalendar(
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
            child: MorphInputDateRangePickerFormField(
              firstDate: firstDate,
              lastDate: lastDate,
              initialStartDate: _startDate.value,
              initialEndDate: _endDate.value,
              onStartDateSaved: (DateTime value) {
                setState(() => _startDate.value = value);
              },
              onEndDateSaved: (DateTime value) {
                setState(() => _endDate.value = value);
              },
              selectableDayPredicate: widget.selectableDayPredicate,
              errorFormatText: widget.errorFormatText,
              errorInvalidText: widget.errorInvalidText,
              fieldStartHintText: widget.fieldStartHintText,
              fieldEndHintText: widget.fieldEndHintText,
              fieldStartLabelText: widget.fieldStartLabelText,
              fieldEndLabelText: widget.fieldEndLabelText,
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

  Widget _buildRangeCalendar({
    required DateTime firstDate,
    required DateTime lastDate,
    required DateTime currentDate,
  }) {
    return MorphCalendarDateRangePicker(
      firstDate: firstDate,
      lastDate: lastDate,
      currentDate: currentDate,
      initialStartDate: _startDate.value,
      initialEndDate: _endDate.value,
      selectableDayPredicate: widget.selectableDayPredicate,
      onStartDateChanged: (DateTime value) {
        setState(() => _startDate.value = value);
      },
      onEndDateChanged: (DateTime value) {
        setState(() => _endDate.value = value);
      },
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
