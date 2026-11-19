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

@widgetbook.UseCase(name: 'Playground', type: MorphFab, path: '[Actions]/FAB')
Widget fabPlaygroundUseCase(BuildContext context) {
  final size = enumKnob<MorphFabSize>(
    context,
    label: 'size',
    values: MorphFabSize.values,
    initial: MorphFabSize.medium,
  );
  final color = enumKnob<MorphFabColor>(
    context,
    label: 'color',
    values: MorphFabColor.values,
  );
  final enabled = context.knobs.boolean(label: 'enabled', initialValue: true);
  final icon = iconKnob(context);
  return _CountingHarness(
    builder: (count, bump) => Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        MorphFab(
          icon: Icon(icon),
          size: size,
          color: color,
          tooltip: 'Floating action button',
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
  type: MorphFab,
  path: '[Actions]/FAB',
)
Widget fabMatrixUseCase(BuildContext context) {
  return Stage(
    children: [
      for (final color in MorphFabColor.values)
        StageSection(
          title: 'color: ${color.name}',
          child: StageWrap(
            spacing: 16,
            children: [
              for (final size in MorphFabSize.values)
                StageCell(
                  caption: size.name,
                  child: MorphFab(
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
  type: MorphFabScrollVisibility,
  path: '[Actions]/FAB',
)
Widget fabScrollVisibilityUseCase(BuildContext context) {
  return const _FabScrollDemo();
}

class _FabScrollDemo extends StatefulWidget {
  const _FabScrollDemo();

  @override
  State<_FabScrollDemo> createState() => _FabScrollDemoState();
}

class _FabScrollDemoState extends State<_FabScrollDemo> {
  final MorphFabController _controller = MorphFabController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: MorphFabScrollVisibility(
        controller: _controller,
        child: ListView.builder(
          itemCount: 40,
          itemBuilder: (context, i) =>
              MorphListItem(headline: 'Scroll down to hide the FAB (${i + 1})'),
        ),
      ),
      floatingActionButton: MorphFab(
        controller: _controller,
        icon: Icon(FluentIcons.line.add),
        onPressed: () {},
      ),
    );
  }
}

class _CountingHarness extends StatefulWidget {
  const _CountingHarness({required this.builder});

  final Widget Function(int count, VoidCallback bump) builder;

  @override
  State<_CountingHarness> createState() => _CountingHarnessState();
}

class _CountingHarnessState extends State<_CountingHarness> {
  int _count = 0;

  @override
  Widget build(BuildContext context) => StageCenter(
    child: widget.builder(_count, () => setState(() => _count++)),
  );
}
