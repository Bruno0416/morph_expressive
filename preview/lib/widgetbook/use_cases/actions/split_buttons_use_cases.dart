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

const _path = '[Actions]/Split Buttons';

@widgetbook.UseCase(name: 'Playground', type: MorphSplitButton, path: _path)
Widget splitButtonPlaygroundUseCase(BuildContext context) {
  final style = enumKnob<MorphButtonStyle>(
    context,
    label: 'style',
    values: MorphButtonStyle.values,
  );
  final variant = variantKnob(context);
  final size = buttonSizeKnob(context);
  final shape = enumKnob<MorphButtonShape>(
    context,
    label: 'shape',
    values: MorphButtonShape.values,
  );
  final trailing = enumKnob<MorphSplitButtonTrailingAlignment>(
    context,
    label: 'trailing alignment',
    values: MorphSplitButtonTrailingAlignment.values,
  );
  final enabled = context.knobs.boolean(label: 'enabled', initialValue: true);
  final label = context.knobs.string(label: 'label', initialValue: 'Save');
  return _SplitHarness(
    style: style,
    variant: variant,
    size: size,
    shape: shape,
    trailing: trailing,
    enabled: enabled,
    label: label,
  );
}

class _SplitHarness extends StatefulWidget {
  const _SplitHarness({
    required this.style,
    required this.variant,
    required this.size,
    required this.shape,
    required this.trailing,
    required this.enabled,
    required this.label,
  });

  final MorphButtonStyle style;
  final MorphVariant? variant;
  final MorphButtonSize size;
  final MorphButtonShape shape;
  final MorphSplitButtonTrailingAlignment trailing;
  final bool enabled;
  final String label;

  @override
  State<_SplitHarness> createState() => _SplitHarnessState();
}

class _SplitHarnessState extends State<_SplitHarness> {
  String _choice = 'Save as draft';
  int _primary = 0;

  @override
  Widget build(BuildContext context) {
    return StageCenter(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          MorphSplitButton<String>(
            style: widget.style,
            variant: widget.variant,
            size: widget.size,
            shape: widget.shape,
            trailingAlignment: widget.trailing,
            enabled: widget.enabled,
            label: widget.label,
            leadingIcon: FluentIcons.line.bookmark,
            selectedValue: _choice,
            onPressed: () => setState(() => _primary++),
            onSelected: (value) => setState(() => _choice = value),
            items: const [
              MorphSplitButtonItem(
                value: 'Save as draft',
                child: Text('Save as draft'),
              ),
              MorphSplitButtonItem(
                value: 'Save and close',
                child: Text('Save and close'),
              ),
              MorphSplitButtonItem(
                value: 'Disabled option',
                enabled: false,
                child: Text('Disabled option'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          DemoReadout('Primary pressed $_primary times · menu: $_choice'),
        ],
      ),
    );
  }
}
