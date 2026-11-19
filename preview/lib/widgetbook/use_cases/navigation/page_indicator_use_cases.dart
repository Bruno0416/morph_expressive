import 'package:material_ui/material_ui.dart'
    show BuildContext, State, StatefulWidget, Text, Widget;
import 'package:morph_expressive/morph_expressive.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../utilities/demo.dart';
import '../../utilities/knobs.dart';
import '../../utilities/stage.dart';

@widgetbook.UseCase(
  name: 'Playground',
  type: MorphPageIndicator,
  path: '[Navigation]/Page Indicator',
)
Widget pageIndicatorPlaygroundUseCase(BuildContext context) {
  final effect = enumKnob<MorphPageIndicatorEffect>(
    context,
    label: 'effect',
    values: MorphPageIndicatorEffect.values,
  );
  final count = context.knobs.int.slider(
    label: 'pages',
    initialValue: 5,
    min: 2,
    max: 12,
  );
  final active = context.knobs.double.slider(
    label: 'active width',
    initialValue: 40,
    min: 8,
    max: 80,
  );
  final inactive = context.knobs.double.slider(
    label: 'inactive width',
    initialValue: 16,
    min: 8,
    max: 40,
  );
  final height = context.knobs.double.slider(
    label: 'height',
    initialValue: 16,
    min: 6,
    max: 32,
  );
  final spacing = context.knobs.double.slider(
    label: 'spacing',
    initialValue: 6,
    min: 0,
    max: 24,
  );
  final interactive = context.knobs.boolean(
    label: 'interactive',
    initialValue: true,
  );
  final stretch = context.knobs.double.slider(
    label: 'organic stretch',
    initialValue: 0.4,
    min: 0,
    max: 1,
    divisions: 20,
    precision: 2,
  );
  return _IndicatorHarness(
    key: resetKey([count]),
    effect: effect,
    count: count,
    active: active,
    inactive: inactive,
    height: height,
    spacing: spacing,
    interactive: interactive,
    stretch: stretch,
  );
}

class _IndicatorHarness extends StatefulWidget {
  const _IndicatorHarness({
    super.key,
    required this.effect,
    required this.count,
    required this.active,
    required this.inactive,
    required this.height,
    required this.spacing,
    required this.interactive,
    required this.stretch,
  });

  final MorphPageIndicatorEffect effect;
  final int count;
  final double active;
  final double inactive;
  final double height;
  final double spacing;
  final bool interactive;
  final double stretch;

  @override
  State<_IndicatorHarness> createState() => _IndicatorHarnessState();
}

class _IndicatorHarnessState extends State<_IndicatorHarness> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Stage(
      children: [
        MorphPageIndicator(
          count: widget.count,
          selectedIndex: _index,
          effect: widget.effect,
          activeWidth: widget.active,
          inactiveWidth: widget.inactive,
          height: widget.height,
          spacing: widget.spacing,
          organicStretchIntensity: widget.stretch,
          onPageSelected: widget.interactive
              ? (i) => setState(() => _index = i)
              : null,
        ),
        StageWrap(
          children: [
            MorphButton.tonal(
              onPressed: () => setState(
                () => _index = (_index - 1 + widget.count) % widget.count,
              ),
              label: const Text('Previous'),
            ),
            MorphButton.tonal(
              onPressed: () =>
                  setState(() => _index = (_index + 1) % widget.count),
              label: const Text('Next'),
            ),
          ],
        ),
        DemoReadout('Page ${_index + 1} of ${widget.count}'),
      ],
    );
  }
}
