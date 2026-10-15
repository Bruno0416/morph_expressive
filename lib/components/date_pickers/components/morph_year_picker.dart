import 'package:material_ui/material_ui.dart';

import '../../../foundations/foundations.dart';
import '../../divider/morph_divider.dart';
import '../res/morph_date_picker_constants.dart';
import '../styles/morph_date_picker_theme.dart';
import '../utils/morph_date_picker_utils.dart';

/// Scrollable year grid for calendar date pickers.
///
/// Matches material_ui [YearPicker]: top/bottom dividers with an [Expanded]
/// [GridView] between them. The mode toggle lives in the parent calendar
/// (stacked / padded), not inside this column.
class MorphYearPicker extends StatefulWidget {
  /// MorphYearPicker.
  const MorphYearPicker({
    required this.selectedDate,
    required this.firstDate,
    required this.lastDate,
    required this.onChanged,
    this.selectableDayPredicate,
    this.displayedMonth,
    super.key,
  });

  /// selectedDate.
  final DateTime? selectedDate;

  /// firstDate.
  final DateTime firstDate;

  /// lastDate.
  final DateTime lastDate;

  /// onChanged.
  final ValueChanged<DateTime> onChanged;

  /// Function.
  final bool Function(DateTime day)? selectableDayPredicate;

  /// displayedMonth.
  final DateTime? displayedMonth;

  @override
  State<MorphYearPicker> createState() => _MorphYearPickerState();
}

class _MorphYearPickerState extends State<MorphYearPicker> {
  late final ScrollController _controller;

  @override
  void initState() {
    super.initState();
    final selectedYear = widget.selectedDate?.year ?? widget.firstDate.year;
    _controller = ScrollController(
      initialScrollOffset: _initialOffset(selectedYear, widget.firstDate.year),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = MorphTheme.of(context);
    final dateTheme = theme.datePickerTheme;
    final localizations = MaterialLocalizations.of(context);
    final firstYear = widget.firstDate.year;
    final lastYear = widget.lastDate.year;
    final yearCount = lastYear - firstYear + 1;
    final selectedYear = widget.selectedDate?.year ?? firstYear;

    return Column(
      children: <Widget>[
        const MorphDivider(),
        Expanded(
          child: GridView.builder(
            controller: _controller,
            padding: const EdgeInsets.symmetric(
              horizontal: MorphDatePickerConstants.yearPickerPadding,
            ),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: MorphDatePickerConstants.yearPickerColumnCount,
              mainAxisExtent: MorphDatePickerConstants.yearPickerRowHeight,
              mainAxisSpacing: MorphDatePickerConstants.yearPickerRowSpacing,
              crossAxisSpacing: MorphDatePickerConstants.yearPickerRowSpacing,
            ),
            itemCount: yearCount,
            itemBuilder: (BuildContext context, int index) {
              return _buildYearCell(
                theme: theme,
                dateTheme: dateTheme,
                localizations: localizations,
                year: firstYear + index,
                selectedYear: selectedYear,
              );
            },
          ),
        ),
        const MorphDivider(),
      ],
    );
  }

  Widget _buildYearCell({
    required MorphThemeData theme,
    required MorphDatePickerTheme dateTheme,
    required MaterialLocalizations localizations,
    required int year,
    required int selectedYear,
  }) {
    final normalized = MorphDatePickerUtils.clampDate(
      MorphDatePickerUtils.normalizeSelectedDay(
        widget.selectedDate ?? DateTime(year),
        DateTime(year, widget.selectedDate?.month ?? 1),
      ),
      widget.firstDate,
      widget.lastDate,
    );
    final candidate = DateTime(year, normalized.month, normalized.day);
    final enabled = MorphDatePickerUtils.isSelectable(
      candidate,
      widget.firstDate,
      widget.lastDate,
      predicate: widget.selectableDayPredicate,
    );
    final selected = year == selectedYear;
    final foreground = dateTheme.yearForegroundColor(
      theme.colorScheme,
      selected: selected,
      enabled: enabled,
    );
    return MorphTappable(
      enabled: enabled,
      onTap: enabled ? () => widget.onChanged(candidate) : null,
      semanticLabel: localizations.formatYear(DateTime(year)),
      builder: (BuildContext context, MorphInteractionState state) {
        return Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: selected
                ? dateTheme.selectedDayBackgroundColor(theme.colorScheme)
                : null,
          ),
          child: Text(
            localizations.formatYear(DateTime(year)),
            style:
                (selected ? dateTheme.selectedYearStyle : dateTheme.yearStyle)(
                  theme.typeScale,
                  theme.colorScheme,
                ).copyWith(color: foreground),
          ),
        );
      },
    );
  }

  static double _initialOffset(int selectedYear, int firstYear) {
    const rowHeight =
        MorphDatePickerConstants.yearPickerRowHeight +
        MorphDatePickerConstants.yearPickerRowSpacing;
    const columns = MorphDatePickerConstants.yearPickerColumnCount;
    final row = ((selectedYear - firstYear) / columns).floor();
    return row * rowHeight;
  }
}
