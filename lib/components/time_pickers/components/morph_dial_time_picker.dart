import 'dart:math' as math;

import 'package:material_ui/material_ui.dart'
    show
        Alignment,
        BoxConstraints,
        BoxDecoration,
        BuildContext,
        Center,
        Column,
        Container,
        CrossAxisAlignment,
        CustomPaint,
        Directionality,
        DragStartDetails,
        DragUpdateDetails,
        EdgeInsets,
        EdgeInsetsDirectional,
        ExcludeSemantics,
        Expanded,
        FittedBox,
        GestureDetector,
        LayoutBuilder,
        MainAxisAlignment,
        MainAxisSize,
        MaterialLocalizations,
        MediaQuery,
        Offset,
        Orientation,
        Padding,
        RepaintBoundary,
        Row,
        Semantics,
        SizedBox,
        Stack,
        State,
        StatefulWidget,
        TapDownDetails,
        Text,
        TextDirection,
        ValueChanged,
        Widget;

import '../../../foundations/foundations.dart';
import '../enums/morph_time_picker_enums.dart';
import '../models/morph_time.dart';
import '../res/morph_time_picker_constants.dart';
import '../styles/morph_time_picker_theme.dart';
import '../utils/morph_time_picker_utils.dart';
import 'morph_day_period_control.dart';
import 'morph_time_dial_painter.dart';

const String _timeSeparator = ':';
const String _zeroPad = '0';
const double _minInteractiveDimension = 48;

/// Embeddable clock dial for choosing an hour and minute.
class MorphDialTimePicker extends StatefulWidget {
  /// MorphDialTimePicker.
  const MorphDialTimePicker({
    required this.value,
    required this.onChanged,
    this.use24HourFormat,
    this.expandToFit = false,
    this.orientation,
    this.helpText,
    super.key,
  });

  /// value.
  final MorphTime value;

  /// onChanged.
  final ValueChanged<MorphTime> onChanged;

  /// use24HourFormat.
  final bool? use24HourFormat;

  /// expandToFit.
  final bool expandToFit;

  /// Forces dial header layout; defaults to [MediaQuery] orientation.
  final Orientation? orientation;

  /// Optional help label above the time fields (dialog dial mode).
  final String? helpText;

  @override
  State<MorphDialTimePicker> createState() => _MorphDialTimePickerState();
}

class _MorphDialTimePickerState extends State<MorphDialTimePicker> {
  MorphTimePickerMode _mode = MorphTimePickerMode.hour;

  bool _use24HourFormat(BuildContext context) {
    return MorphTimePickerUtils.use24HourFormat(
      context,
      alwaysUse24HourFormat: widget.use24HourFormat,
    );
  }

  Orientation _orientation(BuildContext context) {
    return widget.orientation ?? MediaQuery.orientationOf(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = MorphTheme.of(context);
    final scheme = theme.colorScheme;
    final timeTheme = theme.timePickerTheme;
    final MaterialLocalizations localizations = MaterialLocalizations.of(
      context,
    );
    final bool use24Hour = _use24HourFormat(context);
    final Orientation orientation = _orientation(context);

    final Widget content = switch (orientation) {
      Orientation.portrait => _buildPortrait(theme, localizations, use24Hour),
      Orientation.landscape => _buildLandscape(theme, localizations, use24Hour),
    };

    if (widget.expandToFit) {
      return content;
    }

    return MorphComponentTheme(
      builder: (BuildContext context) => Container(
        padding: timeTheme.padding,
        decoration: BoxDecoration(
          color: timeTheme.containerColor(scheme),
          borderRadius: timeTheme.borderRadius,
        ),
        child: content,
      ),
    );
  }

  Widget _buildPortrait(
    MorphThemeData theme,
    MaterialLocalizations localizations,
    bool use24Hour,
  ) {
    final timeTheme = theme.timePickerTheme;
    final double periodHeight = timeTheme.periodPortraitSize.height;
    final double minInteractiveVerticalPadding = math.max(
      0,
      2 * _minInteractiveDimension - periodHeight,
    );
    final dialPadding = EdgeInsets.only(
      left: MorphTimePickerConstants.dialPortraitHorizontalPadding,
      right: MorphTimePickerConstants.dialPortraitHorizontalPadding,
      top:
          MorphTimePickerConstants.dialPortraitTopPadding -
          minInteractiveVerticalPadding / 2,
    );

    final Widget help = widget.helpText == null
        ? const SizedBox.shrink()
        : Padding(
            padding: EdgeInsets.only(
              bottom: 20 - minInteractiveVerticalPadding / 2,
            ),
            child: Text(
              widget.helpText!,
              style: timeTheme.headerHelpStyle(
                theme.typeScale,
                theme.colorScheme,
              ),
            ),
          );
    final Widget fields = _buildPortraitFieldsHeader(
      theme,
      localizations,
      use24Hour,
    );
    final Widget dial = Padding(
      padding: dialPadding,
      child: Center(child: _buildDial(theme, use24Hour)),
    );

    if (widget.expandToFit) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          help,
          fields,
          Expanded(child: dial),
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        help,
        fields,
        SizedBox(height: timeTheme.headerDialGap),
        dial,
      ],
    );
  }

  Widget _buildLandscape(
    MorphThemeData theme,
    MaterialLocalizations localizations,
    bool use24Hour,
  ) {
    final timeTheme = theme.timePickerTheme;
    final double periodHeight = timeTheme.periodLandscapeSize.height;
    final double minInteractiveVerticalPadding = math.max(
      0,
      _minInteractiveDimension - periodHeight,
    );

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool boundedHeight = constraints.hasBoundedHeight;
        final Widget row = Row(
          crossAxisAlignment: boundedHeight
              ? CrossAxisAlignment.stretch
              : CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              width: timeTheme.headerLandscapeWidth,
              height: boundedHeight ? null : timeTheme.dialSize,
              child: _buildLandscapeFieldsHeader(
                theme,
                localizations,
                use24Hour,
                minInteractiveVerticalPadding,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsetsDirectional.only(
                  start: MorphTimePickerConstants.dialLandscapeStartPadding,
                ),
                child: Center(child: _buildDial(theme, use24Hour)),
              ),
            ),
          ],
        );
        if (boundedHeight) {
          return row;
        }
        return SizedBox(height: timeTheme.dialSize, child: row);
      },
    );
  }

  Widget _buildPortraitFieldsHeader(
    MorphThemeData theme,
    MaterialLocalizations localizations,
    bool use24Hour,
  ) {
    final timeTheme = theme.timePickerTheme;
    final Widget fields = _buildHourMinuteFields(theme, localizations);
    final Widget? period = use24Hour
        ? null
        : MorphDayPeriodControl(isPm: widget.value.isPm, onChanged: _setPeriod);

    return Row(
      children: <Widget>[
        Expanded(child: fields),
        if (period != null) ...<Widget>[
          SizedBox(width: timeTheme.fieldPeriodGap),
          period,
        ],
      ],
    );
  }

  Widget _buildLandscapeFieldsHeader(
    MorphThemeData theme,
    MaterialLocalizations localizations,
    bool use24Hour,
    double minInteractiveVerticalPadding,
  ) {
    final timeTheme = theme.timePickerTheme;
    final Widget fields = _buildHourMinuteFields(theme, localizations);
    final Widget? period = use24Hour
        ? null
        : MorphDayPeriodControl(
            isPm: widget.value.isPm,
            onChanged: _setPeriod,
            orientation: Orientation.landscape,
          );

    return Stack(
      children: <Widget>[
        if (widget.helpText != null)
          Text(
            widget.helpText!,
            style: timeTheme.headerHelpStyle(
              theme.typeScale,
              theme.colorScheme,
            ),
          ),
        // Fill the header column and center fields so help text stays visible
        // above them (material_ui landscape dial header).
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            fields,
            if (period != null) ...<Widget>[
              SizedBox(
                height: math.max(0, 16 - minInteractiveVerticalPadding / 2),
              ),
              period,
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildHourMinuteFields(
    MorphThemeData theme,
    MaterialLocalizations localizations,
  ) {
    final bool use24Hour = _use24HourFormat(context);
    final String hourText = use24Hour
        ? widget.value.hour.toString().padLeft(2, _zeroPad)
        : widget.value.hourOf12.toString().padLeft(2, _zeroPad);
    return Row(
      // Hour/minutes should not swap in RTL (matches Material).
      textDirection: TextDirection.ltr,
      children: <Widget>[
        Expanded(child: _buildField(theme, hourText, MorphTimePickerMode.hour)),
        Semantics(
          label: localizations.timePickerHourModeAnnouncement,
          excludeSemantics: true,
          child: Text(
            _timeSeparator,
            style: theme.typeScale.displayMedium.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
        Expanded(
          child: _buildField(
            theme,
            widget.value.minuteLabel,
            MorphTimePickerMode.minute,
          ),
        ),
      ],
    );
  }

  Widget _buildField(
    MorphThemeData theme,
    String text,
    MorphTimePickerMode mode,
  ) {
    final scheme = theme.colorScheme;
    final timeTheme = theme.timePickerTheme;
    final active = _mode == mode;
    return Semantics(
      selected: active,
      button: true,
      child: MorphTappable(
        onTap: () => setState(() => _mode = mode),
        builder: (BuildContext context, MorphInteractionState state) {
          return Container(
            height: timeTheme.fieldSize.height,
            alignment: Alignment.center,
            margin: timeTheme.fieldMargin,
            decoration: BoxDecoration(
              color: timeTheme.fieldBackgroundColor(scheme, active: active),
              borderRadius: MorphShapes.radiusSmall,
            ),
            child: Text(
              text,
              style: theme.typeScale.displayMedium.copyWith(
                color: timeTheme.fieldForegroundColor(scheme, active: active),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDial(MorphThemeData theme, bool use24Hour) {
    final scheme = theme.colorScheme;
    final timeTheme = theme.timePickerTheme;
    return ExcludeSemantics(
      child: FittedBox(
        child: SizedBox.square(
          dimension: timeTheme.dialSize,
          child: RepaintBoundary(
            child: GestureDetector(
              onTapDown: (TapDownDetails d) {
                MorphHaptics.selectionFor(context);
                _handleDial(
                  d.localPosition,
                  timeTheme,
                  use24Hour,
                  roundMinutes: true,
                );
              },
              onPanStart: (DragStartDetails d) {
                _handleDial(
                  d.localPosition,
                  timeTheme,
                  use24Hour,
                  roundMinutes: false,
                );
              },
              onPanUpdate: (DragUpdateDetails d) {
                _handleDial(
                  d.localPosition,
                  timeTheme,
                  use24Hour,
                  roundMinutes: false,
                );
              },
              child: CustomPaint(
                painter: MorphTimeDialPainter(
                  labels: _dialLabels(use24Hour),
                  handAngle: _handAngle(use24Hour),
                  highlightedLabelIndex: _highlightedLabelIndex(use24Hour),
                  showSelectorDot: _showSelectorDot(),
                  dialColor: scheme.surfaceContainerHighest,
                  accentColor: scheme.primary,
                  onAccentColor: scheme.onPrimary,
                  labelColor: scheme.onSurface,
                  labelStyle: theme.typeScale.labelLarge,
                  textDirection: Directionality.of(context),
                  timeTheme: timeTheme,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<String> _dialLabels(bool use24Hour) {
    if (_mode == MorphTimePickerMode.hour) {
      if (use24Hour) {
        return <String>[
          for (int i = 0; i < 12; i++) (i * 2).toString().padLeft(2, '0'),
        ];
      }
      return <String>['12', for (int i = 1; i <= 11; i++) '$i'];
    }
    return <String>[
      for (int i = 0; i < 12; i++) (i * 5).toString().padLeft(2, '0'),
    ];
  }

  double _handAngle(bool use24Hour) {
    final double fraction;
    if (_mode == MorphTimePickerMode.hour) {
      if (use24Hour) {
        fraction = (widget.value.hour / 24) % 1;
      } else {
        fraction = (widget.value.hourOf12 % 12) / 12;
      }
    } else {
      fraction = (widget.value.minute / 60) % 1;
    }
    return -math.pi / 2 + fraction * 2 * math.pi;
  }

  int? _highlightedLabelIndex(bool use24Hour) {
    if (_mode == MorphTimePickerMode.hour) {
      if (use24Hour) {
        return (widget.value.hour / 2).round() % 12;
      }
      return widget.value.hourOf12 % 12;
    }
    final int minute = widget.value.minute;
    if (minute % 5 != 0) {
      return null;
    }
    return (minute ~/ 5) % 12;
  }

  bool _showSelectorDot() {
    return _mode == MorphTimePickerMode.minute && widget.value.minute % 5 != 0;
  }

  void _handleDial(
    Offset position,
    MorphTimePickerTheme timeTheme,
    bool use24Hour, {
    required bool roundMinutes,
  }) {
    final dimension = timeTheme.dialSize;
    final center = Offset(dimension / 2, dimension / 2);
    final delta = position - center;
    final fraction =
        ((math.atan2(delta.dy, delta.dx) + math.pi / 2) / (2 * math.pi)) % 1;
    if (_mode == MorphTimePickerMode.hour) {
      if (use24Hour) {
        final hour = (fraction * 24).round() % 24;
        widget.onChanged(widget.value.copyWith(hour: hour));
      } else {
        _setHour((fraction * 12).round() % 12);
      }
      return;
    }
    var minute = (fraction * 60).round() % 60;
    if (roundMinutes) {
      minute = ((minute + 2) ~/ 5) * 5 % 60;
    }
    _setMinute(minute);
  }

  void _setHour(int slot) {
    final hour12 = slot == 0 ? 12 : slot;
    final hour24 = MorphTimePickerUtils.to24Hour(hour12, pm: widget.value.isPm);
    widget.onChanged(widget.value.copyWith(hour: hour24));
  }

  void _setMinute(int minute) {
    widget.onChanged(widget.value.copyWith(minute: minute));
  }

  void _setPeriod(bool pm) {
    final hour24 = MorphTimePickerUtils.to24Hour(widget.value.hourOf12, pm: pm);
    widget.onChanged(widget.value.copyWith(hour: hour24));
  }
}
