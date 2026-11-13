import 'dart:async' show unawaited;

import 'package:flutter/animation.dart' show AnimationController;
import 'package:flutter/widgets.dart'
    show MediaQuery, SingleTickerProviderStateMixin;

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
import 'morph_date_range_ink.dart';

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
    this.organicStretchIntensity = 0.40,
    super.key,
  }) : assert(organicStretchIntensity >= 0 && organicStretchIntensity <= 1);

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

  /// Perpendicular ink stretch of the expanding range highlight (0 = none).
  /// Defaults to the same 0.40 intensity as Morph navigation and chips.
  final double organicStretchIntensity;

  @override
  State<MorphCalendarDateRangePicker> createState() =>
      _MorphCalendarDateRangePickerState();
}

class _MorphCalendarDateRangePickerState
    extends State<MorphCalendarDateRangePicker>
    with SingleTickerProviderStateMixin {
  // One timeline shared by every visible month keeps the reveal continuous.
  late final AnimationController _rangeReveal = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 320),
    value: 1,
  );
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
    unawaited(MorphDateRangeInk.warmUp());
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
      if (_startDate != null && _endDate != null) {
        _animateRangeReveal();
      }
    }
  }

  @override
  void dispose() {
    _rangeReveal.dispose();
    _controller.dispose();
    super.dispose();
  }

  int get _monthCount =>
      MorphDatePickerUtils.monthDelta(_firstDate, _lastDate) + 1;

  DateTime _monthForIndex(int index) {
    return MorphDatePickerUtils.addMonthsToMonthDate(_firstDate, index);
  }

  void _animateRangeReveal() {
    if (MediaQuery.maybeOf(context)?.disableAnimations ?? false) {
      _rangeReveal.value = 1;
    } else {
      _rangeReveal.forward(from: 0);
    }
  }

  void _updateSelection(DateTime date) {
    MorphHaptics.selectionFor(context);
    setState(() {
      if (_startDate != null &&
          _endDate == null &&
          !date.isBefore(_startDate!)) {
        _endDate = date;
        _animateRangeReveal();
        widget.onEndDateChanged?.call(_endDate!);
      } else {
        _startDate = date;
        _endDate = null;
        _rangeReveal.value = 1;
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
              rangeReveal: _rangeReveal,
              rangeStretchIntensity: widget.organicStretchIntensity,
            ),
            const SizedBox(height: 8),
          ],
        );
      },
    );
  }
}
