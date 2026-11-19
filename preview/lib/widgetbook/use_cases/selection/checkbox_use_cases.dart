import 'package:material_ui/material_ui.dart'
    show
        BuildContext,
        Column,
        MainAxisSize,
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
import '../../utilities/stage.dart';

@widgetbook.UseCase(
  name: 'Playground',
  type: MorphCheckbox,
  path: '[Selection]/Checkbox',
)
Widget checkboxUseCase(BuildContext context) {
  final tristate = context.knobs.boolean(label: 'tristate');
  final error = context.knobs.boolean(label: 'error');
  final enabled = context.knobs.boolean(label: 'enabled', initialValue: true);
  final withLabel = context.knobs.boolean(label: 'label', initialValue: true);
  return _CheckboxHarness(
    key: resetKey([tristate]),
    tristate: tristate,
    error: error,
    enabled: enabled,
    withLabel: withLabel,
  );
}

class _CheckboxHarness extends StatefulWidget {
  const _CheckboxHarness({
    super.key,
    required this.tristate,
    required this.error,
    required this.enabled,
    required this.withLabel,
  });

  final bool tristate;
  final bool error;
  final bool enabled;
  final bool withLabel;

  @override
  State<_CheckboxHarness> createState() => _CheckboxHarnessState();
}

class _CheckboxHarnessState extends State<_CheckboxHarness> {
  bool? _value = true;

  @override
  Widget build(BuildContext context) {
    return StageCenter(
      // The label does not wrap, so large text scrolls instead of overflowing.
      horizontalScroll: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          MorphCheckbox(
            value: _value,
            tristate: widget.tristate,
            error: widget.error,
            label: widget.withLabel ? const Text('Accept the terms') : null,
            onChanged: widget.enabled
                ? (value) => setState(() => _value = value)
                : null,
          ),
          const SizedBox(height: 16),
          DemoReadout('Value: $_value'),
        ],
      ),
    );
  }
}

@widgetbook.UseCase(
  name: 'States',
  type: MorphCheckbox,
  path: '[Selection]/Checkbox',
)
Widget checkboxStatesUseCase(BuildContext context) {
  return Stage(
    children: [
      for (final (title, enabled, error) in const [
        ('Enabled', true, false),
        ('Disabled', false, false),
        ('Error', true, true),
      ])
        StageSection(
          title: title,
          child: StageWrap(
            spacing: 24,
            children: [
              for (final value in <bool?>[false, true, null])
                MorphCheckbox(
                  value: value,
                  tristate: true,
                  error: error,
                  label: Text(
                    value == null
                        ? 'Mixed'
                        : value
                        ? 'Checked'
                        : 'Unchecked',
                  ),
                  onChanged: enabled ? (_) {} : null,
                ),
            ],
          ),
        ),
    ],
  );
}
