import 'package:material_ui/material_ui.dart'
    show
        BuildContext,
        Column,
        CrossAxisAlignment,
        EdgeInsetsDirectional,
        ListView,
        MaterialLocalizations,
        Padding,
        ScrollController,
        SizedBox,
        State,
        StatefulWidget,
        Text,
        ValueChanged,
        Widget;

import '../../../foundations/foundations.dart';
import '../models/morph_date_picker_models.dart';
import '../utils/morph_date_picker_utils.dart';
import 'morph_day_picker.dart';

/// Calendar for selecting a date range.
class MorphCalendarDateRangePicker extends StatefulWidget {
  /// MorphCalendarDateRangePicker.
  const MorphCalendarDateRangePicker({
    required this.firstDate,
    required this.lastDate,
    required this.onStartDateChanged,
    this.initialStartDate,
    this.initialEndDate,
    this.currentDate,
    this.onEndDateChanged,
    this.selectableDayPredicate,
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

  /// onStartDateChanged.
  final ValueChanged<DateTime> onStartDateChanged;

  /// onEndDateChanged.
  final ValueChanged<DateTime>? onEndDateChanged;

  /// selectableDayPredicate.
  final MorphSelectableDayForRangePredicate? selectableDayPredicate;

  @override
  State<MorphCalendarDateRangePicker> createState() =>
      _MorphCalendarDateRangePickerState();
}

class _MorphCalendarDateRangePickerState
    extends State<MorphCalendarDateRangePicker> {
  late ScrollController _controller;
  late DateTime _firstDate;
  late DateTime _lastDate;
  late DateTime _currentDate;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
    _firstDate = MorphDatePickerUtils.dateOnly(widget.firstDate);
    _lastDate = MorphDatePickerUtils.dateOnly(widget.lastDate);
    _currentDate = MorphDatePickerUtils.dateOnly(
      widget.currentDate ?? DateTime.now(),
    );
    _startDate = widget.initialStartDate == null
        ? null
        : MorphDatePickerUtils.dateOnly(widget.initialStartDate!);
    _endDate = widget.initialEndDate == null
        ? null
        : MorphDatePickerUtils.dateOnly(widget.initialEndDate!);
  }

  @override
  void didUpdateWidget(covariant MorphCalendarDateRangePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialStartDate != oldWidget.initialStartDate) {
      _startDate = widget.initialStartDate;
    }
    if (widget.initialEndDate != oldWidget.initialEndDate) {
      _endDate = widget.initialEndDate;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  int get _monthCount =>
      MorphDatePickerUtils.monthDelta(_firstDate, _lastDate) + 1;

  DateTime _monthForIndex(int index) {
    return MorphDatePickerUtils.addMonthsToMonthDate(_firstDate, index);
  }

  void _updateSelection(DateTime date) {
    MorphHaptics.selectionFor(context);
    setState(() {
      if (_startDate != null &&
          _endDate == null &&
          !date.isBefore(_startDate!)) {
        _endDate = date;
        widget.onEndDateChanged?.call(_endDate!);
      } else {
        _startDate = date;
        _endDate = null;
        widget.onStartDateChanged(_startDate!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = MorphTheme.of(context);
    final MaterialLocalizations localizations = MaterialLocalizations.of(
      context,
    );

    return ListView.builder(
      controller: _controller,
      itemCount: _monthCount,
      itemBuilder: (BuildContext context, int index) {
        final DateTime month = _monthForIndex(index);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 8),
              child: Text(
                localizations.formatMonthYear(month),
                style: theme.typeScale.titleSmall.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
            MorphDayPicker(
              displayedMonth: month,
              selectedDate: _startDate,
              currentDate: _currentDate,
              firstDate: _firstDate,
              lastDate: _lastDate,
              onChanged: _updateSelection,
              selectableDayPredicate: widget.selectableDayPredicate,
              rangeStart: _startDate,
              rangeEnd: _endDate,
            ),
            const SizedBox(height: 8),
          ],
        );
      },
    );
  }
}
