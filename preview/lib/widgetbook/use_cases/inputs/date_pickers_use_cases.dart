import 'package:material_ui/material_ui.dart'
    show
        BuildContext,
        Column,
        MediaQuery,
        Orientation,
        SizedBox,
        State,
        StatefulWidget,
        Text,
        Widget;
import 'package:morph_expressive/morph_expressive.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../utilities/demo.dart';
import '../../utilities/knobs.dart';
import '../../utilities/nested_dialog.dart';
import '../../utilities/stage.dart';

const _path = '[Inputs]/Date pickers';

final _first = DateTime(2020);
final _last = DateTime(2035);

@widgetbook.UseCase(
  name: 'Calendar',
  type: MorphCalendarDatePicker,
  path: _path,
)
Widget calendarDatePickerUseCase(BuildContext context) {
  final mode = enumKnob<MorphDatePickerMode>(
    context,
    label: 'initial mode',
    values: MorphDatePickerMode.values,
  );
  return _CalendarHarness(key: resetKey([mode]), mode: mode);
}

class _CalendarHarness extends StatefulWidget {
  const _CalendarHarness({super.key, required this.mode});

  final MorphDatePickerMode mode;

  @override
  State<_CalendarHarness> createState() => _CalendarHarnessState();
}

class _CalendarHarnessState extends State<_CalendarHarness> {
  DateTime? _date;

  @override
  Widget build(BuildContext context) {
    return Stage(
      children: [
        SizedBox(
          width: 360,
          child: MorphCalendarDatePicker(
            firstDate: _first,
            lastDate: _last,
            initialCalendarMode: widget.mode,
            onDateChanged: (value) => setState(() => _date = value),
          ),
        ),
        DemoReadout('Selected: $_date'),
      ],
    );
  }
}

@widgetbook.UseCase(
  name: 'Range calendar',
  type: MorphCalendarDateRangePicker,
  path: _path,
)
Widget calendarRangeUseCase(BuildContext context) {
  final stretch = context.knobs.double.slider(
    label: 'organic stretch',
    initialValue: 0.4,
    min: 0,
    max: 1,
    divisions: 20,
    precision: 2,
  );
  return _RangeHarness(stretch: stretch);
}

class _RangeHarness extends StatefulWidget {
  const _RangeHarness({required this.stretch});

  final double stretch;

  @override
  State<_RangeHarness> createState() => _RangeHarnessState();
}

class _RangeHarnessState extends State<_RangeHarness> {
  DateTime? _start;
  DateTime? _end;

  @override
  Widget build(BuildContext context) {
    return Stage(
      children: [
        SizedBox(
          width: 360,
          height: 420,
          child: MorphCalendarDateRangePicker(
            firstDate: _first,
            lastDate: _last,
            organicStretchIntensity: widget.stretch,
            onStartDateChanged: (value) => setState(() => _start = value),
            onEndDateChanged: (value) => setState(() => _end = value),
          ),
        ),
        DemoReadout('Range: $_start to $_end'),
      ],
    );
  }
}

@widgetbook.UseCase(name: 'Dialogs', type: MorphDatePickerDialog, path: _path)
Widget datePickerDialogsUseCase(BuildContext context) {
  final entry = enumKnob<MorphDatePickerEntryMode>(
    context,
    label: 'initial entry mode',
    values: MorphDatePickerEntryMode.values,
  );
  return _DateDialogsHarness(entry: entry);
}

class _DateDialogsHarness extends StatefulWidget {
  const _DateDialogsHarness({required this.entry});

  final MorphDatePickerEntryMode entry;

  @override
  State<_DateDialogsHarness> createState() => _DateDialogsHarnessState();
}

class _DateDialogsHarnessState extends State<_DateDialogsHarness> {
  String _result = 'Nothing picked yet';

  @override
  Widget build(BuildContext context) {
    return Stage(
      children: [
        StageWrap(
          children: [
            MorphButton.filled(
              onPressed: () async {
                final value = await showNestedDialog<DateTime>(
                  context,
                  MorphDatePickerDialog(
                    firstDate: _first,
                    lastDate: _last,
                    initialDate: DateTime.now(),
                    initialEntryMode: widget.entry,
                  ),
                );
                if (mounted) setState(() => _result = 'Date: $value');
              },
              label: const Text('Open date picker'),
            ),
            MorphButton.outlined(
              onPressed: () async {
                final value = await showNestedDialog<MorphDateRange>(
                  context,
                  MorphDateRangePickerDialog(
                    firstDate: _first,
                    lastDate: _last,
                    initialEntryMode: widget.entry,
                  ),
                );
                if (mounted) setState(() => _result = 'Range: $value');
              },
              label: const Text('Open range picker'),
            ),
          ],
        ),
        DemoReadout(_result),
      ],
    );
  }
}

@widgetbook.UseCase(
  name: 'Input fields',
  type: MorphInputDatePickerFormField,
  path: _path,
)
Widget dateInputFieldsUseCase(BuildContext context) {
  return Stage(
    children: [
      StageSection(
        title: 'MorphInputDatePickerFormField',
        child: SizedBox(
          width: 360,
          child: MorphInputDatePickerFormField(
            firstDate: _first,
            lastDate: _last,
            initialDate: DateTime(2026, 11, 19),
            fieldLabelText: 'Date',
          ),
        ),
      ),
      StageSection(
        title: 'MorphInputDateRangePickerFormField',
        child: SizedBox(
          width: 520,
          child: MorphInputDateRangePickerFormField(
            firstDate: _first,
            lastDate: _last,
            initialStartDate: DateTime(2026, 11, 1),
            initialEndDate: DateTime(2026, 11, 19),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(name: 'Building blocks', type: MorphDayPicker, path: _path)
Widget datePickerBlocksUseCase(BuildContext context) {
  return const _DateBlocks();
}

class _DateBlocks extends StatefulWidget {
  const _DateBlocks();

  @override
  State<_DateBlocks> createState() => _DateBlocksState();
}

class _DateBlocksState extends State<_DateBlocks> {
  DateTime _selected = DateTime(2026, 11, 19);
  DateTime _month = DateTime(2026, 11);

  @override
  Widget build(BuildContext context) {
    final now = DateTime(2026, 11, 19);
    return Stage(
      children: [
        StageSection(
          title: 'MorphDatePickerHeader and actions',
          // Like the framework's date picker, the fixed-height header clamps
          // text scaling.
          child: MediaQuery.withClampedTextScaling(
            minScaleFactor: 1,
            maxScaleFactor: 1.3,
            child: SizedBox(
              width: 380,
              child: Column(
                children: [
                  MorphDatePickerHeader(
                    helpText: 'Select date',
                    titleText: 'Thu, Nov 19',
                    showTitle: true,
                    orientation: Orientation.portrait,
                    entryModeButton: MorphDatePickerEntryModeButton(
                      icon: FluentIcons.line.settings,
                      tooltip: 'Switch to input',
                      onPressed: () {},
                    ),
                  ),
                  MorphDatePickerActions(
                    cancelText: 'Cancel',
                    confirmText: 'OK',
                    onCancel: () {},
                    onConfirm: () {},
                  ),
                ],
              ),
            ),
          ),
        ),
        StageSection(
          title: 'MorphDayPicker',
          child: SizedBox(
            width: 360,
            height: 330,
            child: MorphDayPicker(
              displayedMonth: _month,
              selectedDate: _selected,
              currentDate: now,
              firstDate: _first,
              lastDate: _last,
              onChanged: (value) => setState(() => _selected = value),
            ),
          ),
        ),
        StageSection(
          title: 'MorphMonthPicker',
          child: SizedBox(
            width: 360,
            height: 330,
            child: MorphMonthPicker(
              initialMonth: _month,
              firstDate: _first,
              lastDate: _last,
              selectedDate: _selected,
              currentDate: now,
              onChanged: (value) => setState(() => _selected = value),
              onMonthChanged: (value) => setState(() => _month = value),
            ),
          ),
        ),
        StageSection(
          title: 'MorphYearPicker',
          child: SizedBox(
            width: 360,
            height: 300,
            child: MorphYearPicker(
              selectedDate: _selected,
              firstDate: _first,
              lastDate: _last,
              onChanged: (value) => setState(() => _selected = value),
            ),
          ),
        ),
        DemoReadout('Selected: $_selected'),
      ],
    );
  }
}
