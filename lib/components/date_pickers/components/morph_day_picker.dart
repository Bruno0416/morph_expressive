import 'package:flutter/animation.dart' show Animation;

import 'package:material_ui/material_ui.dart'
    show
        BoxConstraints,
        BuildContext,
        Center,
        Column,
        Expanded,
        GridView,
        LayoutBuilder,
        MainAxisSize,
        MaterialLocalizations,
        NeverScrollableScrollPhysics,
        Row,
        SizedBox,
        SliverGridDelegateWithFixedCrossAxisCount,
        StatelessWidget,
        Text,
        ValueChanged,
        Widget;

import '../../../foundations/foundations.dart';
import '../res/morph_date_picker_constants.dart';
import '../styles/morph_date_picker_theme.dart';
import '../utils/morph_date_picker_utils.dart';
import 'morph_day_cell.dart';

/// Weekday headers and day grid for one month.
class MorphDayPicker extends StatelessWidget {
  /// MorphDayPicker.
  const MorphDayPicker({
    required this.displayedMonth,
    required this.selectedDate,
    required this.currentDate,
    required this.firstDate,
    required this.lastDate,
    required this.onChanged,
    this.selectableDayPredicate,
    this.rangeStart,
    this.rangeEnd,
    this.rangeReveal,
    this.rangeStretchIntensity = 0.40,
    this.fitHeight = false,
    super.key,
  });

  /// displayedMonth.

  final DateTime displayedMonth;

  /// selectedDate.
  final DateTime? selectedDate;

  /// currentDate.
  final DateTime currentDate;

  /// firstDate.
  final DateTime firstDate;

  /// lastDate.
  final DateTime lastDate;

  /// onChanged.
  final ValueChanged<DateTime> onChanged;

  /// Function.
  final bool Function(DateTime day)? selectableDayPredicate;

  /// rangeStart.
  final DateTime? rangeStart;

  /// rangeEnd.
  final DateTime? rangeEnd;

  /// Shared animation from the range picker; null keeps the static highlight.
  final Animation<double>? rangeReveal;

  /// Cross-axis stretch of the progressive range highlight.
  final double rangeStretchIntensity;

  /// fitHeight.
  final bool fitHeight;

  @override
  Widget build(BuildContext context) {
    final theme = MorphTheme.of(context);
    final dateTheme = theme.datePickerTheme;
    final MaterialLocalizations localizations = MaterialLocalizations.of(
      context,
    );
    final int year = displayedMonth.year;
    final int month = displayedMonth.month;
    final int daysInMonth = MorphDatePickerUtils.daysInMonth(year, month);
    final int firstDayOffset =
        ((DateTime(year, month).weekday % 7) -
            localizations.firstDayOfWeekIndex +
            7) %
        7;
    final int cellCount =
        ((daysInMonth + firstDayOffset) / dateTheme.daysPerWeek).ceil() *
        dateTheme.daysPerWeek;
    final int rowCount =
        ((daysInMonth + firstDayOffset) / dateTheme.daysPerWeek).ceil();

    if (fitHeight) {
      return Column(
        children: <Widget>[
          _buildWeekdayHeader(theme, dateTheme, localizations),
          Expanded(
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final double rowHeight =
                    (constraints.maxHeight - dateTheme.gridPadding.vertical) /
                    rowCount;
                return GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  padding: dateTheme.gridPadding,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    mainAxisExtent: rowHeight.clamp(
                      0.0,
                      MorphDatePickerConstants.dayPickerRowHeight,
                    ),
                  ),
                  itemCount: cellCount,
                  itemBuilder: (BuildContext context, int index) {
                    return _buildDayCell(
                      index: index,
                      firstDayOffset: firstDayOffset,
                      firstDayOfWeekIndex: localizations.firstDayOfWeekIndex,
                      daysInMonth: daysInMonth,
                      year: year,
                      month: month,
                    );
                  },
                );
              },
            ),
          ),
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _buildWeekdayHeader(theme, dateTheme, localizations),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: dateTheme.gridPadding,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisExtent: MorphDatePickerConstants.dayPickerRowHeight,
          ),
          itemCount: cellCount,
          itemBuilder: (BuildContext context, int index) {
            return _buildDayCell(
              index: index,
              firstDayOffset: firstDayOffset,
              firstDayOfWeekIndex: localizations.firstDayOfWeekIndex,
              daysInMonth: daysInMonth,
              year: year,
              month: month,
            );
          },
        ),
      ],
    );
  }

  Widget _buildWeekdayHeader(
    MorphThemeData theme,
    MorphDatePickerTheme dateTheme,
    MaterialLocalizations localizations,
  ) {
    return Row(
      children: <Widget>[
        for (int i = 0; i < dateTheme.daysPerWeek; i++)
          Expanded(
            child: Center(
              child: Text(
                localizations
                    .narrowWeekdays[(localizations.firstDayOfWeekIndex + i) %
                    7],
                style: dateTheme.weekdayStyle(
                  theme.typeScale,
                  theme.colorScheme,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDayCell({
    required int index,
    required int firstDayOffset,
    required int firstDayOfWeekIndex,
    required int daysInMonth,
    required int year,
    required int month,
  }) {
    final int day = index - firstDayOffset + 1;
    if (day < 1 || day > daysInMonth) {
      return const SizedBox.shrink();
    }
    final date = DateTime(year, month, day);
    final bool enabled = MorphDatePickerUtils.isSelectable(
      date,
      firstDate,
      lastDate,
      predicate: selectableDayPredicate,
    );
    final DateTime? start = rangeStart;
    final DateTime? end = rangeEnd;
    return MorphDayCell(
      date: date,
      selected: MorphDatePickerUtils.isSameDay(date, selectedDate),
      today: MorphDatePickerUtils.isSameDay(date, currentDate),
      enabled: enabled,
      inRange:
          start != null &&
          end != null &&
          MorphDatePickerUtils.isInRange(date, start, end),
      rangeStart: start != null && MorphDatePickerUtils.isSameDay(date, start),
      rangeEnd: end != null && MorphDatePickerUtils.isSameDay(date, end),
      firstDayOfWeekIndex: firstDayOfWeekIndex,
      rangeReveal: rangeReveal,
      rangeStretchIntensity: rangeStretchIntensity,
      rangeDayIndex: start == null
          ? 0
          : DateTime.utc(date.year, date.month, date.day)
                .difference(DateTime.utc(start.year, start.month, start.day))
                .inDays,
      rangeDayCount: start == null || end == null
          ? 1
          : DateTime.utc(end.year, end.month, end.day)
                    .difference(
                      DateTime.utc(start.year, start.month, start.day),
                    )
                    .inDays +
                1,
      onTap: enabled ? () => onChanged(date) : null,
    );
  }
}
