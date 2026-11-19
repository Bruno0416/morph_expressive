import 'package:material_ui/material_ui.dart'
    show
        BuildContext,
        Column,
        Icon,
        MainAxisSize,
        SizedBox,
        State,
        StatefulWidget,
        Widget;
import 'package:morph_expressive/morph_expressive.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../utilities/demo.dart';
import '../../utilities/stage.dart';

@widgetbook.UseCase(
  name: 'Playground',
  type: MorphSwitch,
  path: '[Selection]/Switch',
)
Widget switchUseCase(BuildContext context) {
  final enabled = context.knobs.boolean(label: 'enabled', initialValue: true);
  final icons = context.knobs.boolean(label: 'icons');
  return _SwitchHarness(enabled: enabled, icons: icons);
}

class _SwitchHarness extends StatefulWidget {
  const _SwitchHarness({required this.enabled, required this.icons});

  final bool enabled;
  final bool icons;

  @override
  State<_SwitchHarness> createState() => _SwitchHarnessState();
}

class _SwitchHarnessState extends State<_SwitchHarness> {
  bool _value = true;

  @override
  Widget build(BuildContext context) {
    return StageCenter(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          MorphSwitch(
            value: _value,
            selectedIcon: widget.icons
                ? Icon(FluentIcons.filled.checkmark)
                : null,
            unselectedIcon: widget.icons ? Icon(FluentIcons.line.add) : null,
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
