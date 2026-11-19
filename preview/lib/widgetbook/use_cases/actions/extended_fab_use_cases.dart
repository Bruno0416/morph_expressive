import 'package:material_ui/material_ui.dart'
    show
        BuildContext,
        Colors,
        Column,
        Icon,
        ListView,
        MainAxisSize,
        Scaffold,
        SizedBox,
        State,
        StatefulWidget,
        VoidCallback,
        Widget;
import 'package:morph_expressive/morph_expressive.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../utilities/demo.dart';
import '../../utilities/knobs.dart';
import '../../utilities/stage.dart';

const _path = '[Actions]/Extended FAB';

@widgetbook.UseCase(name: 'Playground', type: MorphExtendedFab, path: _path)
Widget extendedFabPlaygroundUseCase(BuildContext context) {
  final size = enumKnob<MorphExtendedFabSize>(
    context,
    label: 'size',
    values: MorphExtendedFabSize.values,
  );
  final color = enumKnob<MorphFabColor>(
    context,
    label: 'color',
    values: MorphFabColor.values,
  );
  final extended = context.knobs.boolean(label: 'extended', initialValue: true);
  final enabled = context.knobs.boolean(label: 'enabled', initialValue: true);
  final label = context.knobs.string(label: 'label', initialValue: 'Compose');
  final icon = iconKnob(context);
  return _Harness(
    builder: (count, bump) => Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        MorphExtendedFab(
          label: label,
          icon: Icon(icon),
          size: size,
          color: color,
          extended: extended,
          onPressed: enabled ? bump : null,
        ),
        const SizedBox(height: 16),
        DemoReadout('Pressed $count times'),
      ],
    ),
  );
}

@widgetbook.UseCase(
  name: 'Sizes and colors',
  type: MorphExtendedFab,
  path: _path,
)
Widget extendedFabMatrixUseCase(BuildContext context) {
  return Stage(
    children: [
      for (final color in MorphFabColor.values)
        StageSection(
          title: 'color: ${color.name}',
          child: StageWrap(
            spacing: 16,
            children: [
              for (final size in MorphExtendedFabSize.values)
                StageCell(
                  caption: size.name,
                  child: MorphExtendedFab(
                    // A short label keeps the large size inside a phone width
                    // at big text scales.
                    label: 'Add',
                    icon: Icon(FluentIcons.line.add),
                    size: size,
                    color: color,
                    onPressed: () {},
                  ),
                ),
            ],
          ),
        ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Scroll visibility',
  type: MorphExtendedFabScrollVisibility,
  path: _path,
)
Widget extendedFabScrollUseCase(BuildContext context) =>
    const _ExtendedFabScrollDemo();

class _ExtendedFabScrollDemo extends StatefulWidget {
  const _ExtendedFabScrollDemo();

  @override
  State<_ExtendedFabScrollDemo> createState() => _ExtendedFabScrollDemoState();
}

class _ExtendedFabScrollDemoState extends State<_ExtendedFabScrollDemo> {
  final MorphExtendedFabController _controller = MorphExtendedFabController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: MorphExtendedFabScrollVisibility(
        controller: _controller,
        child: ListView.builder(
          itemCount: 40,
          itemBuilder: (context, i) =>
              MorphListItem(headline: 'Scroll to collapse the FAB (${i + 1})'),
        ),
      ),
      floatingActionButton: MorphExtendedFab(
        controller: _controller,
        label: 'Compose',
        icon: Icon(FluentIcons.line.add),
        onPressed: () {},
      ),
    );
  }
}

class _Harness extends StatefulWidget {
  const _Harness({required this.builder});

  final Widget Function(int count, VoidCallback bump) builder;

  @override
  State<_Harness> createState() => _HarnessState();
}

class _HarnessState extends State<_Harness> {
  int _count = 0;

  @override
  Widget build(BuildContext context) => StageCenter(
    child: widget.builder(_count, () => setState(() => _count++)),
  );
}
