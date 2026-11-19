import 'package:material_ui/material_ui.dart'
    show BuildContext, Icon, Positioned, Stack, State, StatefulWidget, Widget;
import 'package:morph_expressive/morph_expressive.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../utilities/demo.dart';
import '../../utilities/knobs.dart';

@widgetbook.UseCase(
  name: 'Playground',
  type: MorphFabMenu,
  path: '[Actions]/FAB Menu',
)
Widget fabMenuPlaygroundUseCase(BuildContext context) {
  final position = enumKnob<MorphFabMenuPosition>(
    context,
    label: 'position',
    values: MorphFabMenuPosition.values,
  );
  final color = enumKnob<MorphFabColor>(
    context,
    label: 'color',
    values: MorphFabColor.values,
  );
  final size = enumKnob<MorphFabSize>(
    context,
    label: 'size',
    values: MorphFabSize.values,
    initial: MorphFabSize.medium,
  );
  final count = context.knobs.int.slider(
    label: 'items',
    initialValue: 3,
    min: 1,
    max: 6,
  );
  return _FabMenuHarness(
    key: resetKey([position, color, size, count]),
    position: position,
    color: color,
    size: size,
    count: count,
  );
}

class _FabMenuHarness extends StatefulWidget {
  const _FabMenuHarness({
    super.key,
    required this.position,
    required this.color,
    required this.size,
    required this.count,
  });

  final MorphFabMenuPosition position;
  final MorphFabColor color;
  final MorphFabSize size;
  final int count;

  @override
  State<_FabMenuHarness> createState() => _FabMenuHarnessState();
}

class _FabMenuHarnessState extends State<_FabMenuHarness> {
  String _last = 'Nothing chosen yet';

  @override
  Widget build(BuildContext context) {
    final icons = demoIcons.entries.toList();
    return Stack(
      children: [
        Positioned(
          left: 24,
          top: 24,
          child: DemoReadout('Last action: $_last'),
        ),
        Positioned(
          right: widget.position == MorphFabMenuPosition.right ? 24 : null,
          left: widget.position == MorphFabMenuPosition.right ? null : 24,
          bottom: 24,
          child: MorphFabMenu(
            position: widget.position,
            color: widget.color,
            size: widget.size,
            items: [
              for (var i = 0; i < widget.count; i++)
                MorphFabMenuItem(
                  icon: Icon(icons[i].value),
                  label: icons[i].key,
                  onPressed: () => setState(() => _last = icons[i].key),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
