import 'package:material_ui/material_ui.dart'
    show
        BuildContext,
        Column,
        CrossAxisAlignment,
        State,
        StatefulWidget,
        Text,
        Widget;
import 'package:morph_expressive/morph_expressive.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../utilities/demo.dart';
import '../../utilities/stage.dart';

@widgetbook.UseCase(
  name: 'Radio group',
  type: MorphRadio,
  path: '[Selection]/Radio',
)
Widget radioGroupUseCase(BuildContext context) {
  final error = context.knobs.boolean(label: 'error');
  final enabled = context.knobs.boolean(label: 'enabled', initialValue: true);
  final count = context.knobs.int.slider(
    label: 'options',
    initialValue: 3,
    min: 2,
    max: 6,
  );
  return _RadioHarness(error: error, enabled: enabled, count: count);
}

class _RadioHarness extends StatefulWidget {
  const _RadioHarness({
    required this.error,
    required this.enabled,
    required this.count,
  });

  final bool error;
  final bool enabled;
  final int count;

  @override
  State<_RadioHarness> createState() => _RadioHarnessState();
}

class _RadioHarnessState extends State<_RadioHarness> {
  String _value = 'Option 1';

  @override
  Widget build(BuildContext context) {
    return Stage(
      children: [
        MorphRadioGroup<String>(
          groupValue: _value,
          groupLabel: 'Choose one',
          onChanged: (value) => setState(() => _value = value),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 1; i <= widget.count; i++)
                MorphRadio<String>(
                  value: 'Option $i',
                  groupValue: _value,
                  error: widget.error,
                  label: Text('Option $i'),
                  onChanged: widget.enabled
                      ? (value) => setState(() => _value = value)
                      : null,
                ),
            ],
          ),
        ),
        DemoReadout('Selected: $_value'),
      ],
    );
  }
}
