import 'package:material_ui/material_ui.dart'
    show
        Align,
        AlignmentDirectional,
        BuildContext,
        EdgeInsetsDirectional,
        Flexible,
        Icon,
        MaterialLocalizations,
        Padding,
        Row,
        SizedBox,
        StatelessWidget,
        Text,
        TextOverflow,
        ValueChanged,
        Widget;

import '../../../foundations/foundations.dart';
import '../enums/morph_date_picker_enums.dart';
import '../res/morph_date_picker_constants.dart';

/// Toggles between day and year calendar modes.
class MorphDatePickerModeToggle extends StatelessWidget {
  /// MorphDatePickerModeToggle.
  const MorphDatePickerModeToggle({
    required this.mode,
    required this.onChanged,
    required this.monthDate,
    super.key,
  });

  /// mode.

  final MorphDatePickerMode mode;

  /// onChanged.
  final ValueChanged<MorphDatePickerMode> onChanged;

  /// monthDate.
  final DateTime monthDate;

  @override
  Widget build(BuildContext context) {
    final theme = MorphTheme.of(context);
    final dateTheme = theme.datePickerTheme;
    final MaterialLocalizations localizations = MaterialLocalizations.of(
      context,
    );
    final String label = mode == MorphDatePickerMode.day
        ? localizations.formatMonthYear(monthDate)
        : localizations.formatYear(DateTime(monthDate.year));

    return SizedBox(
      height: MorphDatePickerConstants.subHeaderHeight,
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: MorphTappable(
          onTap: () {
            onChanged(
              mode == MorphDatePickerMode.day
                  ? MorphDatePickerMode.year
                  : MorphDatePickerMode.day,
            );
          },
          semanticLabel: mode == MorphDatePickerMode.day
              ? localizations.selectYearSemanticsLabel
              : localizations.formatMonthYear(monthDate),
          builder: (BuildContext context, MorphInteractionState state) {
            return Padding(
              padding: const EdgeInsetsDirectional.only(start: 16),
              child: Row(
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
                    mode == MorphDatePickerMode.day
                        ? MorphIcons.arrow_drop_down
                        : MorphIcons.arrow_drop_up,
                    size: dateTheme.arrowIconSize,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
