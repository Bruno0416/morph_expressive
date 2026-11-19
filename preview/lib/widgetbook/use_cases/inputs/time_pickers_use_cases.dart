import 'package:material_ui/material_ui.dart'
    show
        BuildContext,
        Column,
        FocusNode,
        Orientation,
        Size,
        SizedBox,
        State,
        StatefulWidget,
        Text,
        TextEditingController,
        Widget;
import 'package:morph_expressive/morph_expressive.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../utilities/demo.dart';
import '../../utilities/knobs.dart';
import '../../utilities/nested_dialog.dart';
import '../../utilities/stage.dart';

const _path = '[Inputs]/Time pickers';

@widgetbook.UseCase(name: 'Dial', type: MorphDialTimePicker, path: _path)
Widget dialTimePickerUseCase(BuildContext context) {
  final use24 = context.knobs.boolean(label: '24 hour format');
  return _DialHarness(use24: use24);
}

class _DialHarness extends StatefulWidget {
  const _DialHarness({required this.use24});

  final bool use24;

  @override
  State<_DialHarness> createState() => _DialHarnessState();
}

class _DialHarnessState extends State<_DialHarness> {
  MorphTime _time = const MorphTime(hour: 9, minute: 30);

  @override
  Widget build(BuildContext context) {
    return Stage(
      children: [
        SizedBox(
          width: 340,
          height: 520,
          child: MorphDialTimePicker(
            value: _time,
            use24HourFormat: widget.use24,
            onChanged: (value) => setState(() => _time = value),
          ),
        ),
        DemoReadout('Time: ${_time.hour}:${_time.minute}'),
      ],
    );
  }
}

@widgetbook.UseCase(name: 'Dialog', type: MorphTimePickerDialog, path: _path)
Widget timePickerDialogUseCase(BuildContext context) {
  final entry = enumKnob<MorphTimePickerEntryMode>(
    context,
    label: 'initial entry mode',
    values: MorphTimePickerEntryMode.values,
  );
  final use24 = context.knobs.boolean(label: '24 hour format');
  return _TimeDialogHarness(entry: entry, use24: use24);
}

class _TimeDialogHarness extends StatefulWidget {
  const _TimeDialogHarness({required this.entry, required this.use24});

  final MorphTimePickerEntryMode entry;
  final bool use24;

  @override
  State<_TimeDialogHarness> createState() => _TimeDialogHarnessState();
}

class _TimeDialogHarnessState extends State<_TimeDialogHarness> {
  String _result = 'Nothing picked yet';

  @override
  Widget build(BuildContext context) {
    return Stage(
      children: [
        MorphButton.filled(
          label: const Text('Choose time'),
          onPressed: () async {
            final value = await showNestedDialog<MorphTime>(
              context,
              MorphTimePickerDialog(
                initialTime: const MorphTime(hour: 9, minute: 30),
                initialEntryMode: widget.entry,
                alwaysUse24HourFormat: widget.use24,
              ),
            );
            if (mounted) {
              setState(
                () => _result = 'Picked: ${value?.hour}:${value?.minute}',
              );
            }
          },
        ),
        DemoReadout(_result),
      ],
    );
  }
}

@widgetbook.UseCase(
  name: 'Input field',
  type: MorphInputTimePickerFormField,
  path: _path,
)
Widget timeInputFieldUseCase(BuildContext context) {
  final use24 = context.knobs.boolean(label: '24 hour format');
  return Stage(
    children: [
      SizedBox(
        width: 340,
        child: MorphInputTimePickerFormField(
          key: resetKey([use24]),
          initialTime: const MorphTime(hour: 14, minute: 5),
          helpText: 'Enter time',
          use24HourFormat: use24,
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Building blocks',
  type: MorphDayPeriodControl,
  path: _path,
)
Widget timePickerBlocksUseCase(BuildContext context) => const _TimeBlocks();

class _TimeBlocks extends StatefulWidget {
  const _TimeBlocks();

  @override
  State<_TimeBlocks> createState() => _TimeBlocksState();
}

class _TimeBlocksState extends State<_TimeBlocks> {
  bool _isPm = false;
  final TextEditingController _hour = TextEditingController(text: '09');
  final FocusNode _focus = FocusNode();

  @override
  void dispose() {
    _hour.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stage(
      children: [
        StageSection(
          title: 'MorphTimePickerHeader, actions and dialog content',
          child: SizedBox(
            width: 380,
            child: MorphTimePickerDialogContent(
              isInputMode: false,
              child: Column(
                children: [
                  MorphTimePickerHeader(
                    helpText: 'Select time',
                    titleText: '09:30',
                    showTitle: true,
                    orientation: Orientation.portrait,
                  ),
                  MorphTimePickerActions(
                    cancelText: 'Cancel',
                    confirmText: 'OK',
                    onCancel: () {},
                    onConfirm: () {},
                    entryModeButton: MorphTimePickerEntryModeButton(
                      icon: FluentIcons.line.settings,
                      tooltip: 'Switch to input',
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        StageSection(
          title: 'MorphDayPeriodControl',
          child: SizedBox(
            width: 96,
            height: 96,
            child: MorphDayPeriodControl(
              isPm: _isPm,
              onChanged: (value) => setState(() => _isPm = value),
            ),
          ),
        ),
        StageSection(
          title: 'MorphHourMinuteTextField',
          child: SizedBox(
            width: 96,
            height: 72,
            child: MorphHourMinuteTextField(
              controller: _hour,
              focusNode: _focus,
              size: const Size(96, 72),
              semanticLabel: 'Hour',
              hintText: '00',
            ),
          ),
        ),
      ],
    );
  }
}
