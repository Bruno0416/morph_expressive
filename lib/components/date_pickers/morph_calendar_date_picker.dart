import 'package:material_ui/material_ui.dart'
    show
        Alignment,
        BoxDecoration,
        BuildContext,
        Column,
        Container,
        EdgeInsets,
        MainAxisSize,
        MaterialLocalizations,
        Padding,
        Positioned,
        SizedBox,
        Stack,
        State,
        StatefulWidget,
        ValueChanged,
        Widget;

import '../../foundations/foundations.dart';
import 'components/morph_date_picker_mode_toggle.dart';
import 'components/morph_month_picker.dart';
import 'components/morph_year_picker.dart';
import 'enums/morph_date_picker_enums.dart';
import 'models/morph_date_picker_models.dart';
import 'res/morph_date_picker_constants.dart';
import 'utils/morph_date_picker_utils.dart';

/// Embeddable calendar for selecting a single date.
class MorphCalendarDatePicker extends StatefulWidget {
  /// MorphCalendarDatePicker.
  const MorphCalendarDatePicker({
    required this.onDateChanged,
    required this.firstDate,
    required this.lastDate,
    this.initialDate,
    this.currentDate,
    this.initialCalendarMode = MorphDatePickerMode.day,
    this.onDisplayedMonthChanged,
    this.onCalendarModeChanged,
    this.selectableDayPredicate,
    this.expandToFit = false,
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

  /// onDateChanged.
  final ValueChanged<DateTime> onDateChanged;

  /// onDisplayedMonthChanged.
  final ValueChanged<DateTime>? onDisplayedMonthChanged;

  /// onCalendarModeChanged.
  final ValueChanged<MorphDatePickerMode>? onCalendarModeChanged;

  /// initialCalendarMode.
  final MorphDatePickerMode initialCalendarMode;

  /// selectableDayPredicate.
  final MorphSelectableDayPredicate? selectableDayPredicate;

  /// expandToFit.
  final bool expandToFit;

  @override
  State<MorphCalendarDatePicker> createState() =>
      _MorphCalendarDatePickerState();
}

class _MorphCalendarDatePickerState extends State<MorphCalendarDatePicker> {
  late MorphDatePickerMode _mode;
  late DateTime _displayedMonth;
  late DateTime _firstDate;
  late DateTime _lastDate;
  late DateTime _currentDate;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _firstDate = MorphDatePickerUtils.dateOnly(widget.firstDate);
    _lastDate = MorphDatePickerUtils.dateOnly(widget.lastDate);
    _currentDate = MorphDatePickerUtils.dateOnly(
      widget.currentDate ?? DateTime.now(),
    );
    _mode = widget.initialCalendarMode;
    _selectedDate = widget.initialDate == null
        ? null
        : MorphDatePickerUtils.dateOnly(widget.initialDate!);
    final DateTime base = _selectedDate ?? _currentDate;
    _displayedMonth = MorphDatePickerUtils.getMonth(base.year, base.month);
    assert(
      !_lastDate.isBefore(_firstDate),
      'lastDate must be on or after firstDate',
    );
  }

  void _handleModeChanged(MorphDatePickerMode mode) {
    MorphHaptics.selectionFor(context);
    setState(() => _mode = mode);
    widget.onCalendarModeChanged?.call(mode);
  }

  void _handleMonthChanged(DateTime month) {
    setState(() => _displayedMonth = month);
    widget.onDisplayedMonthChanged?.call(month);
  }

  void _handleYearChanged(DateTime value) {
    MorphHaptics.selectionFor(context);
    final DateTime clamped = MorphDatePickerUtils.clampDate(
      value,
      _firstDate,
      _lastDate,
    );
    setState(() {
      _mode = MorphDatePickerMode.day;
      _displayedMonth = MorphDatePickerUtils.getMonth(
        clamped.year,
        clamped.month,
      );
      if (MorphDatePickerUtils.isSelectable(
        clamped,
        _firstDate,
        _lastDate,
        predicate: widget.selectableDayPredicate,
      )) {
        _selectedDate = clamped;
        widget.onDateChanged(clamped);
      }
    });
    widget.onDisplayedMonthChanged?.call(_displayedMonth);
    widget.onCalendarModeChanged?.call(MorphDatePickerMode.day);
  }

  void _handleDayChanged(DateTime value) {
    MorphHaptics.selectionFor(context);
    setState(() {
      _selectedDate = value;
      widget.onDateChanged(value);
    });
  }

  double _inlinePickerBodyHeight(BuildContext context) {
    final int firstDayOfWeekIndex = MaterialLocalizations.of(context)
        .firstDayOfWeekIndex;
    return switch (_mode) {
      MorphDatePickerMode.day => MorphDatePickerUtils.calendarDayViewHeight(
        _displayedMonth,
        firstDayOfWeekIndex,
      ),
      MorphDatePickerMode.year => MorphDatePickerUtils.calendarYearViewHeight(
        _firstDate,
        _lastDate,
        includeSubHeader: false,
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    return MorphComponentTheme(
      builder: (BuildContext context) {
        final theme = MorphTheme.of(context);
        final dateTheme = theme.datePickerTheme;

        if (widget.expandToFit) {
          // material_ui CalendarDatePicker: picker body + mode toggle in a Stack.
          // Year mode pads below the sub-header so the toggle overlays the top.
          final Widget picker = switch (_mode) {
            MorphDatePickerMode.day => MorphMonthPicker(
              initialMonth: _displayedMonth,
              firstDate: _firstDate,
              lastDate: _lastDate,
              selectedDate: _selectedDate,
              currentDate: _currentDate,
              onChanged: _handleDayChanged,
              onMonthChanged: _handleMonthChanged,
              selectableDayPredicate: widget.selectableDayPredicate,
              expandToFit: true,
              mode: _mode,
              onModeChanged: _handleModeChanged,
            ),
            MorphDatePickerMode.year => Padding(
              padding: const EdgeInsets.only(
                top: MorphDatePickerConstants.subHeaderHeight,
              ),
              child: MorphYearPicker(
                selectedDate: _selectedDate,
                firstDate: _firstDate,
                lastDate: _lastDate,
                onChanged: _handleYearChanged,
                selectableDayPredicate: widget.selectableDayPredicate,
                displayedMonth: _displayedMonth,
              ),
            ),
          };
          return Stack(
            children: <Widget>[
              Positioned.fill(child: picker),
              if (_mode == MorphDatePickerMode.year)
                MorphDatePickerModeToggle(
                  mode: _mode,
                  monthDate: _displayedMonth,
                  onChanged: _handleModeChanged,
                ),
            ],
          );
        }

        final Widget content = Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            MorphDatePickerModeToggle(
              mode: _mode,
              monthDate: _displayedMonth,
              onChanged: _handleModeChanged,
            ),
            MorphMotion.sizeTransition(
              context: context,
              duration: MorphMotion.durationOf(
                context,
                MorphDatePickerConstants.dialogSizeAnimationDuration,
              ),
              curve: MorphMotion.exit,
              alignment: Alignment.topCenter,
              child: SizedBox(
                height: _inlinePickerBodyHeight(context),
                child: switch (_mode) {
                  MorphDatePickerMode.day => MorphMonthPicker(
                    initialMonth: _displayedMonth,
                    firstDate: _firstDate,
                    lastDate: _lastDate,
                    selectedDate: _selectedDate,
                    currentDate: _currentDate,
                    onChanged: _handleDayChanged,
                    onMonthChanged: _handleMonthChanged,
                    selectableDayPredicate: widget.selectableDayPredicate,
                  ),
                  MorphDatePickerMode.year => MorphYearPicker(
                    selectedDate: _selectedDate,
                    firstDate: _firstDate,
                    lastDate: _lastDate,
                    onChanged: _handleYearChanged,
                    selectableDayPredicate: widget.selectableDayPredicate,
                    displayedMonth: _displayedMonth,
                  ),
                },
              ),
            ),
          ],
        );

        return Container(
          width: dateTheme.width,
          padding: dateTheme.padding,
          decoration: BoxDecoration(
            color: dateTheme.containerColor(theme.colorScheme),
            borderRadius: dateTheme.borderRadius,
          ),
          child: content,
        );
      },
    );
  }
}
