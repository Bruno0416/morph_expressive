import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:material_ui/material_ui.dart' show MaterialLocalizations;

import '../../../foundations/foundations.dart';
import 'morph_date_range_ink.dart';

/// A single day cell in the calendar grid.
class MorphDayCell extends StatefulWidget {
  /// MorphDayCell.
  const MorphDayCell({
    required this.date,
    required this.selected,
    required this.today,
    required this.enabled,
    required this.onTap,
    this.inRange = false,
    this.rangeStart = false,
    this.rangeEnd = false,
    this.firstDayOfWeekIndex,
    this.rangeReveal,
    this.rangeStretchIntensity = 0.40,
    this.rangeDayIndex = 0,
    this.rangeDayCount = 1,
    super.key,
  });

  /// date.

  final DateTime date;

  /// selected.
  final bool selected;

  /// today.
  final bool today;

  /// enabled.
  final bool enabled;

  /// onTap.
  final VoidCallback? onTap;

  /// inRange.
  final bool inRange;

  /// rangeStart.
  final bool rangeStart;

  /// rangeEnd.
  final bool rangeEnd;

  /// Optional locale's first weekday (Sunday = 0). The day picker passes its
  /// resolved value so the row caps always match the calendar header.
  final int? firstDayOfWeekIndex;

  /// Paints the selected range progressively when provided by its parent.
  final Animation<double>? rangeReveal;
  final double rangeStretchIntensity;
  final int rangeDayIndex;
  final int rangeDayCount;

  @override
  State<MorphDayCell> createState() => _MorphDayCellState();
}

class _MorphDayCellState extends State<MorphDayCell>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bounce = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 250),
    value: 1,
  );

  @override
  void didUpdateWidget(covariant MorphDayCell oldWidget) {
    super.didUpdateWidget(oldWidget);
    final wasSelected =
        oldWidget.selected || oldWidget.rangeStart || oldWidget.rangeEnd;
    final isSelected = widget.selected || widget.rangeStart || widget.rangeEnd;
    if (!wasSelected &&
        isSelected &&
        !(MediaQuery.maybeOf(context)?.disableAnimations ?? false)) {
      _bounce.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _bounce.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final date = widget.date;
    final selected = widget.selected;
    final today = widget.today;
    final enabled = widget.enabled;
    final onTap = widget.onTap;
    final inRange = widget.inRange;
    final rangeStart = widget.rangeStart;
    final rangeEnd = widget.rangeEnd;
    final firstDayOfWeekIndex = widget.firstDayOfWeekIndex;
    final theme = MorphTheme.of(context);
    final scheme = theme.colorScheme;
    final dateTheme = theme.datePickerTheme;
    final Color foreground = dateTheme.dayForegroundColor(
      scheme,
      selected: selected || rangeStart || rangeEnd,
      enabled: enabled,
    );
    final bool showCaps = rangeStart || rangeEnd;
    // A standalone day cell may not have MaterialLocalizations (for example,
    // in a lightweight test host). Never make the visual range cap depend on
    // a Material ancestor; the parent day picker supplies the actual locale.
    final int firstWeekday =
        firstDayOfWeekIndex ??
        (Localizations.of<MaterialLocalizations>(
              context,
              MaterialLocalizations,
            )?.firstDayOfWeekIndex ??
            0);
    final int weekday = date.weekday % 7;
    final bool rowStart = weekday == firstWeekday;
    final bool rowEnd = (weekday + 1) % 7 == firstWeekday;
    final double rangeRadius = dateTheme.daySize / 2;

    return MorphTappable(
      enabled: enabled,
      onTap: onTap,
      semanticLabel: '${date.day}',
      builder: (BuildContext context, MorphInteractionState state) {
        return Stack(
          alignment: Alignment.center,
          children: <Widget>[
            if (inRange && !(rangeStart && rangeEnd))
              Positioned(
                left: rangeEnd && !rangeStart
                    ? 0
                    : (rangeStart ? dateTheme.daySize / 2 : 0),
                right: rangeStart && !rangeEnd
                    ? 0
                    : (rangeEnd ? dateTheme.daySize / 2 : 0),
                top: (48 - dateTheme.daySize) / 2,
                bottom: (48 - dateTheme.daySize) / 2,
                child: widget.rangeReveal == null
                    ? DecoratedBox(
                        // Standalone cells preserve the conventional static
                        // band, including its locale-specific rounded ends.
                        decoration: BoxDecoration(
                          color: dateTheme.rangeHighlightColor(scheme),
                          borderRadius: BorderRadius.horizontal(
                            left: Radius.circular(
                              rowStart && !rangeStart ? rangeRadius : 0,
                            ),
                            right: Radius.circular(
                              rowEnd && !rangeEnd ? rangeRadius : 0,
                            ),
                          ),
                        ),
                      )
                    : MorphDateRangeInk(
                        color: dateTheme.rangeHighlightColor(scheme),
                        progress: widget.rangeReveal!,
                        dayIndex: widget.rangeDayIndex,
                        dayCount: widget.rangeDayCount,
                        radius: rangeRadius,
                        roundLeft: rowStart && !rangeStart,
                        roundRight: rowEnd && !rangeEnd,
                        organicStretchIntensity: widget.rangeStretchIntensity,
                      ),
              ),
            AnimatedBuilder(
              animation: _bounce,
              builder: (context, child) {
                final t = _bounce.value;
                // Critically damped, tiny press/release recoil. The layout is
                // never scaled, and the selected date settles at 1.0.
                final scale =
                    (MediaQuery.maybeOf(context)?.disableAnimations ?? false)
                    ? 1.0
                    : 1.0 - 0.12 * math.exp(-7 * t) * math.cos(12 * t);
                return Transform.scale(scale: scale, child: child);
              },
              child: Container(
                width: dateTheme.daySize,
                height: dateTheme.daySize,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: (selected || showCaps)
                      ? dateTheme.selectedDayBackgroundColor(scheme)
                      : null,
                  border: today && !selected && !showCaps
                      ? Border.all(color: dateTheme.todayColor(scheme))
                      : null,
                ),
                child: Text(
                  '${date.day}',
                  style: dateTheme
                      .dayStyle(theme.typeScale, scheme)
                      .copyWith(color: foreground),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
