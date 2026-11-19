import 'package:material_ui/material_ui.dart'
    show BuildContext, Icon, State, StatefulWidget, Widget;
import 'package:morph_expressive/morph_expressive.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../utilities/demo.dart';
import '../../utilities/knobs.dart';
import '../../utilities/stage.dart';

const _path = '[Selection]/Segmented';

@widgetbook.UseCase(
  name: 'Segmented button',
  type: MorphSegmentedButton,
  path: _path,
)
Widget segmentedButtonUseCase(BuildContext context) {
  final multi = context.knobs.boolean(label: 'multi select');
  final density = enumKnob<MorphSegmentedButtonDensity>(
    context,
    label: 'density',
    values: MorphSegmentedButtonDensity.values,
  );
  final showIcon = context.knobs.boolean(
    label: 'show selected icon',
    initialValue: true,
  );
  final enabled = context.knobs.boolean(label: 'enabled', initialValue: true);
  final withIcons = context.knobs.boolean(label: 'segment icons');
  final stretch = context.knobs.double.slider(
    label: 'organic stretch',
    initialValue: 0.4,
    min: 0,
    max: 1,
    divisions: 20,
    precision: 2,
  );
  return _SegmentedHarness(
    key: resetKey([multi]),
    multi: multi,
    density: density,
    showIcon: showIcon,
    enabled: enabled,
    withIcons: withIcons,
    stretch: stretch,
  );
}

class _SegmentedHarness extends StatefulWidget {
  const _SegmentedHarness({
    super.key,
    required this.multi,
    required this.density,
    required this.showIcon,
    required this.enabled,
    required this.withIcons,
    required this.stretch,
  });

  final bool multi;
  final MorphSegmentedButtonDensity density;
  final bool showIcon;
  final bool enabled;
  final bool withIcons;
  final double stretch;

  @override
  State<_SegmentedHarness> createState() => _SegmentedHarnessState();
}

class _SegmentedHarnessState extends State<_SegmentedHarness> {
  Set<String> _selected = {'One'};

  @override
  Widget build(BuildContext context) {
    return Stage(
      children: [
        MorphSegmentedButton<String>(
          multiSelect: widget.multi,
          density: widget.density,
          showSelectedIcon: widget.showIcon,
          enabled: widget.enabled,
          organicStretchIntensity: widget.stretch,
          selected: _selected,
          onSelectionChanged: (next) => setState(() => _selected = next),
          segments: [
            MorphSegment(
              value: 'One',
              label: 'One',
              icon: widget.withIcons ? Icon(FluentIcons.line.home) : null,
            ),
            MorphSegment(
              value: 'Two',
              label: 'Two',
              icon: widget.withIcons ? Icon(FluentIcons.line.star) : null,
            ),
            MorphSegment(
              value: 'Three',
              label: 'Three',
              icon: widget.withIcons ? Icon(FluentIcons.line.heart) : null,
            ),
            const MorphSegment(
              value: 'Four',
              label: 'Disabled',
              enabled: false,
            ),
          ],
        ),
        DemoReadout('Selected: ${_selected.join(', ')}'),
      ],
    );
  }
}

@widgetbook.UseCase(
  name: 'Segmented toggle',
  type: MorphSegmentedToggle,
  path: _path,
)
Widget segmentedToggleUseCase(BuildContext context) {
  final height = context.knobs.double.slider(
    label: 'height',
    initialValue: 48,
    min: 36,
    max: 72,
  );
  final stretch = context.knobs.double.slider(
    label: 'organic stretch',
    initialValue: 0.4,
    min: 0,
    max: 1,
    divisions: 20,
    precision: 2,
  );
  final count = context.knobs.int.slider(
    label: 'options',
    initialValue: 3,
    min: 2,
    max: 5,
  );
  return _SegmentedToggleHarness(
    key: resetKey([count]),
    height: height,
    stretch: stretch,
    count: count,
  );
}

class _SegmentedToggleHarness extends StatefulWidget {
  const _SegmentedToggleHarness({
    super.key,
    required this.height,
    required this.stretch,
    required this.count,
  });

  final double height;
  final double stretch;
  final int count;

  @override
  State<_SegmentedToggleHarness> createState() =>
      _SegmentedToggleHarnessState();
}

class _SegmentedToggleHarnessState extends State<_SegmentedToggleHarness> {
  String _selected = 'Movies';
  static const _labels = ['Movies', 'TV Shows', 'Music', 'Books', 'Games'];

  @override
  Widget build(BuildContext context) {
    return Stage(
      children: [
        MorphSegmentedToggle<String>(
          height: widget.height,
          organicStretchIntensity: widget.stretch,
          selected: _selected,
          onChanged: (value) => setState(() => _selected = value),
          options: [
            for (var i = 0; i < widget.count; i++)
              MorphSegmentedToggleOption(value: _labels[i], label: _labels[i]),
          ],
        ),
        DemoReadout('Selected: $_selected'),
      ],
    );
  }
}
