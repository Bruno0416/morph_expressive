import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart'
    show
        Alignment,
        Axis,
        BuildContext,
        Clip,
        Column,
        EdgeInsetsDirectional,
        Expanded,
        Flexible,
        Focus,
        FocusNode,
        Icon,
        KeyEvent,
        KeyEventResult,
        MainAxisAlignment,
        MainAxisSize,
        MaterialLocalizations,
        Padding,
        PageController,
        PageView,
        Row,
        SizedBox,
        State,
        StatefulWidget,
        StatelessWidget,
        Text,
        TextOverflow,
        UnconstrainedBox,
        ValueChanged,
        VoidCallback,
        Widget;

import '../../../foundations/foundations.dart';
import '../enums/morph_date_picker_enums.dart';
import '../res/morph_date_picker_constants.dart';
import '../utils/morph_date_picker_utils.dart';
import 'morph_day_picker.dart';

/// Month navigation with a [PageView] of day grids.
class MorphMonthPicker extends StatefulWidget {
  /// MorphMonthPicker.
  const MorphMonthPicker({
    required this.initialMonth,
    required this.firstDate,
    required this.lastDate,
    required this.selectedDate,
    required this.currentDate,
    required this.onChanged,
    required this.onMonthChanged,
    this.selectableDayPredicate,
    this.rangeStart,
    this.rangeEnd,
    this.expandToFit = false,
    this.mode,
    this.onModeChanged,
    super.key,
  });

  /// initialMonth.

  final DateTime initialMonth;

  /// firstDate.
  final DateTime firstDate;

  /// lastDate.
  final DateTime lastDate;

  /// selectedDate.
  final DateTime? selectedDate;

  /// currentDate.
  final DateTime currentDate;

  /// onChanged.
  final ValueChanged<DateTime> onChanged;

  /// onMonthChanged.
  final ValueChanged<DateTime> onMonthChanged;

  /// Function.
  final bool Function(DateTime day)? selectableDayPredicate;

  /// rangeStart.
  final DateTime? rangeStart;

  /// rangeEnd.
  final DateTime? rangeEnd;

  /// expandToFit.
  final bool expandToFit;

  /// mode.
  final MorphDatePickerMode? mode;

  /// onModeChanged.
  final ValueChanged<MorphDatePickerMode>? onModeChanged;

  @override
  State<MorphMonthPicker> createState() => _MorphMonthPickerState();
}

class _MorphMonthPickerState extends State<MorphMonthPicker> {
  late PageController _pageController;
  late DateTime _currentMonth;
  late int _monthCount;

  @override
  void initState() {
    super.initState();
    _currentMonth = MorphDatePickerUtils.getMonth(
      widget.initialMonth.year,
      widget.initialMonth.month,
    );
    _monthCount =
        MorphDatePickerUtils.monthDelta(widget.firstDate, widget.lastDate) + 1;
    final int initialPage = MorphDatePickerUtils.monthDelta(
      widget.firstDate,
      _currentMonth,
    );
    _pageController = PageController(initialPage: initialPage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  DateTime _monthForPage(int page) {
    return MorphDatePickerUtils.addMonthsToMonthDate(widget.firstDate, page);
  }

  void _goToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: MorphDatePickerConstants.monthScrollDuration,
      curve: MorphMotion.standard,
    );
  }

  void _handlePreviousMonth() {
    final int page = _pageController.page?.round() ?? 0;
    if (page > 0) {
      _goToPage(page - 1);
    }
  }

  void _handleNextMonth() {
    final int page = _pageController.page?.round() ?? 0;
    if (page < _monthCount - 1) {
      _goToPage(page + 1);
    }
  }

  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) {
      return KeyEventResult.ignored;
    }
    final int page = _pageController.page?.round() ?? 0;
    if (event.logicalKey == LogicalKeyboardKey.arrowLeft && page > 0) {
      _goToPage(page - 1);
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowRight &&
        page < _monthCount - 1) {
      _goToPage(page + 1);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      onKeyEvent: _handleKey,
      child: PageView.builder(
        controller: _pageController,
        itemCount: _monthCount,
        onPageChanged: (int index) {
          final DateTime month = _monthForPage(index);
          setState(() => _currentMonth = month);
          widget.onMonthChanged(month);
        },
        itemBuilder: _buildMonthPage,
      ),
    );
  }

  Widget _buildMonthPage(BuildContext context, int index) {
    final DateTime month = _monthForPage(index);
    final int page = _pageController.hasClients
        ? (_pageController.page?.round() ?? 0)
        : MorphDatePickerUtils.monthDelta(widget.firstDate, _currentMonth);
    final bool canGoPrevious = page > 0;
    final bool canGoNext = page < _monthCount - 1;

    final Widget content = Column(
      mainAxisSize: widget.expandToFit ? MainAxisSize.max : MainAxisSize.min,
      children: <Widget>[
        _MonthNavRow(
          month: month,
          canGoPrevious: canGoPrevious,
          canGoNext: canGoNext,
          onPrevious: _handlePreviousMonth,
          onNext: _handleNextMonth,
          mode: widget.mode,
          onModeChanged: widget.onModeChanged,
        ),
        if (widget.expandToFit)
          Expanded(
            child: MorphDayPicker(
              displayedMonth: month,
              selectedDate: widget.selectedDate,
              currentDate: widget.currentDate,
              firstDate: widget.firstDate,
              lastDate: widget.lastDate,
              onChanged: widget.onChanged,
              selectableDayPredicate: widget.selectableDayPredicate,
              rangeStart: widget.rangeStart,
              rangeEnd: widget.rangeEnd,
              fitHeight: true,
            ),
          )
        else
          MorphDayPicker(
            displayedMonth: month,
            selectedDate: widget.selectedDate,
            currentDate: widget.currentDate,
            firstDate: widget.firstDate,
            lastDate: widget.lastDate,
            onChanged: widget.onChanged,
            selectableDayPredicate: widget.selectableDayPredicate,
            rangeStart: widget.rangeStart,
            rangeEnd: widget.rangeEnd,
          ),
      ],
    );
    if (widget.expandToFit) {
      return content;
    }
    // The body is sized for the displayed month, so a taller neighbour month
    // (6 rows) clips while paging instead of overflowing.
    return UnconstrainedBox(
      constrainedAxis: Axis.horizontal,
      alignment: Alignment.topCenter,
      clipBehavior: Clip.hardEdge,
      child: content,
    );
  }
}

class _MonthNavRow extends StatelessWidget {
  const _MonthNavRow({
    required this.month,
    required this.canGoPrevious,
    required this.canGoNext,
    required this.onPrevious,
    required this.onNext,
    this.mode,
    this.onModeChanged,
  });

  final DateTime month;
  final bool canGoPrevious;
  final bool canGoNext;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final MorphDatePickerMode? mode;
  final ValueChanged<MorphDatePickerMode>? onModeChanged;

  @override
  Widget build(BuildContext context) {
    final theme = MorphTheme.of(context);
    final dateTheme = theme.datePickerTheme;
    final MaterialLocalizations localizations = MaterialLocalizations.of(
      context,
    );
    final String label = localizations.formatMonthYear(month);

    return SizedBox(
      height: MorphDatePickerConstants.subHeaderHeight,
      child: Row(
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: const EdgeInsetsDirectional.only(start: 16),
              child: mode != null && onModeChanged != null
                  ? MorphTappable(
                      onTap: () => onModeChanged!(MorphDatePickerMode.year),
                      semanticLabel: localizations.selectYearSemanticsLabel,
                      builder:
                          (BuildContext context, MorphInteractionState state) {
                            return Row(
                              children: <Widget>[
                                Flexible(
                                  child: Text(
                                    label,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.typeScale.titleSmall.copyWith(
                                      color: theme.colorScheme.onSurface,
                                    ),
                                  ),
                                ),
                                Icon(
                                  MorphIcons.arrow_drop_down,
                                  size: dateTheme.arrowIconSize,
                                ),
                              ],
                            );
                          },
                    )
                  : Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.typeScale.titleSmall.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
            ),
          ),
          SizedBox(
            width: MorphDatePickerConstants.monthNavButtonsWidth,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                MorphTappable(
                  enabled: canGoPrevious,
                  onTap: canGoPrevious ? onPrevious : null,
                  semanticLabel: localizations.previousMonthTooltip,
                  builder: (BuildContext context, MorphInteractionState state) {
                    return Padding(
                      padding: dateTheme.arrowPadding,
                      child: Icon(
                        MorphIcons.chevron_left,
                        size: dateTheme.arrowIconSize,
                        color: canGoPrevious
                            ? null
                            : MorphColorUtils.withOpacity(
                                theme.colorScheme.onSurface,
                                0.38,
                              ),
                      ),
                    );
                  },
                ),
                MorphTappable(
                  enabled: canGoNext,
                  onTap: canGoNext ? onNext : null,
                  semanticLabel: localizations.nextMonthTooltip,
                  builder: (BuildContext context, MorphInteractionState state) {
                    return Padding(
                      padding: dateTheme.arrowPadding,
                      child: Icon(
                        MorphIcons.chevron_right,
                        size: dateTheme.arrowIconSize,
                        color: canGoNext
                            ? null
                            : MorphColorUtils.withOpacity(
                                theme.colorScheme.onSurface,
                                0.38,
                              ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
