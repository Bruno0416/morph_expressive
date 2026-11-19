import 'package:material_ui/material_ui.dart'
    show Axis, BuildContext, Icon, State, StatefulWidget, Text, Widget;
import 'package:morph_expressive/morph_expressive.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../utilities/demo.dart';
import '../../utilities/knobs.dart';
import '../../utilities/stage.dart';

const _path = '[Actions]/Button Groups';

@widgetbook.UseCase(name: 'Playground', type: MorphButtonGroup, path: _path)
Widget buttonGroupPlaygroundUseCase(BuildContext context) {
  final style = enumKnob<MorphButtonStyle>(
    context,
    label: 'style',
    values: MorphButtonStyle.values,
    initial: MorphButtonStyle.tonal,
  );
  final variant = variantKnob(context);
  final size = buttonSizeKnob(context, initial: MorphButtonSize.sm);
  final shape = enumKnob<MorphButtonShape>(
    context,
    label: 'shape',
    values: MorphButtonShape.values,
  );
  final density = enumKnob<MorphButtonGroupDensity>(
    context,
    label: 'density',
    values: MorphButtonGroupDensity.values,
  );
  final overflow = enumKnob<MorphButtonGroupOverflow>(
    context,
    label: 'overflow',
    values: MorphButtonGroupOverflow.values,
    initial: MorphButtonGroupOverflow.none,
  );
  final multiSelect = context.knobs.boolean(label: 'multi select');
  final selectionRequired = context.knobs.boolean(label: 'selection required');
  final squish = context.knobs.boolean(
    label: 'neighbor squish',
    initialValue: true,
  );
  final count = context.knobs.int.slider(
    label: 'actions',
    initialValue: 4,
    min: 2,
    max: 8,
  );
  return _GroupHarness(
    key: resetKey([multiSelect, count, overflow]),
    style: style,
    variant: variant,
    size: size,
    shape: shape,
    density: density,
    overflow: overflow,
    multiSelect: multiSelect,
    selectionRequired: selectionRequired,
    neighborSquish: squish,
    count: count,
  );
}

class _GroupHarness extends StatefulWidget {
  const _GroupHarness({
    super.key,
    required this.style,
    required this.variant,
    required this.size,
    required this.shape,
    required this.density,
    required this.overflow,
    required this.multiSelect,
    required this.selectionRequired,
    required this.neighborSquish,
    required this.count,
  });

  final MorphButtonStyle style;
  final MorphVariant? variant;
  final MorphButtonSize size;
  final MorphButtonShape shape;
  final MorphButtonGroupDensity density;
  final MorphButtonGroupOverflow overflow;
  final bool multiSelect;
  final bool selectionRequired;
  final bool neighborSquish;
  final int count;

  @override
  State<_GroupHarness> createState() => _GroupHarnessState();
}

class _GroupHarnessState extends State<_GroupHarness> {
  int? _selected = 0;
  Set<int> _selectedMany = {0};

  static const _labels = [
    'Day',
    'Week',
    'Month',
    'Year',
    'Decade',
    'Century',
    'Era',
    'All',
  ];

  @override
  Widget build(BuildContext context) {
    return Stage(
      children: [
        MorphButtonGroup(
          type: MorphButtonGroupType.standard,
          style: widget.style,
          variant: widget.variant,
          size: widget.size,
          shape: widget.shape,
          density: widget.density,
          overflow: widget.overflow,
          multiSelect: widget.multiSelect,
          selectionRequired: widget.selectionRequired,
          neighborSquish: widget.neighborSquish,
          selectedIndex: widget.multiSelect ? null : _selected,
          selectedIndices: widget.multiSelect ? _selectedMany : null,
          onSelectedIndexChanged: (next) => setState(() => _selected = next),
          onSelectedIndicesChanged: (next) =>
              setState(() => _selectedMany = next),
          actions: [
            for (var i = 0; i < widget.count; i++)
              MorphButtonGroupAction(label: Text(_labels[i])),
          ],
        ),
        DemoReadout(
          widget.multiSelect
              ? 'Selected: ${_selectedMany.toList()..sort()}'
              : 'Selected: $_selected',
        ),
      ],
    );
  }
}

@widgetbook.UseCase(
  name: 'Icon actions',
  type: MorphButtonGroupAction,
  path: _path,
)
Widget buttonGroupIconActionsUseCase(BuildContext context) {
  final vertical = context.knobs.boolean(label: 'vertical');
  return Stage(
    children: [
      MorphButtonGroup(
        direction: vertical ? Axis.vertical : Axis.horizontal,
        style: MorphButtonStyle.outlined,
        overflow: MorphButtonGroupOverflow.none,
        actions: [
          MorphButtonGroupAction(
            icon: Icon(FluentIcons.line.home),
            tooltip: 'Home',
          ),
          MorphButtonGroupAction(
            icon: Icon(FluentIcons.line.search),
            tooltip: 'Search',
          ),
          MorphButtonGroupAction(
            icon: Icon(FluentIcons.line.settings),
            tooltip: 'Settings',
          ),
        ],
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Reactive group',
  type: MorphReactiveButtonGroup,
  path: _path,
)
Widget reactiveButtonGroupUseCase(BuildContext context) {
  final mode = enumKnob<MorphReactiveGroupMode>(
    context,
    label: 'mode',
    values: MorphReactiveGroupMode.values,
  );
  final fit = enumKnob<MorphReactiveGroupFit>(
    context,
    label: 'fit',
    values: MorphReactiveGroupFit.values,
  );
  final style = enumKnob<MorphButtonStyle>(
    context,
    label: 'style',
    values: MorphButtonStyle.values,
    initial: MorphButtonStyle.tonal,
  );
  final size = buttonSizeKnob(context);
  final pressed = context.knobs.double.slider(
    label: 'pressed expansion',
    initialValue: 0.15,
    min: 0,
    max: 0.5,
    divisions: 25,
    precision: 2,
  );
  final selected = context.knobs.double.slider(
    label: 'selected expansion',
    initialValue: 0.08,
    min: 0,
    max: 0.5,
    divisions: 25,
    precision: 2,
  );
  return _ReactiveHarness(
    key: resetKey([mode]),
    mode: mode,
    fit: fit,
    style: style,
    size: size,
    pressed: pressed,
    selected: selected,
  );
}

class _ReactiveHarness extends StatefulWidget {
  const _ReactiveHarness({
    super.key,
    required this.mode,
    required this.fit,
    required this.style,
    required this.size,
    required this.pressed,
    required this.selected,
  });

  final MorphReactiveGroupMode mode;
  final MorphReactiveGroupFit fit;
  final MorphButtonStyle style;
  final MorphButtonSize size;
  final double pressed;
  final double selected;

  @override
  State<_ReactiveHarness> createState() => _ReactiveHarnessState();
}

class _ReactiveHarnessState extends State<_ReactiveHarness> {
  int? _index = 0;
  Set<int> _indices = {0};

  @override
  Widget build(BuildContext context) {
    final multi = widget.mode != MorphReactiveGroupMode.singleSelect;
    return Stage(
      children: [
        MorphReactiveButtonGroup(
          mode: widget.mode,
          fit: widget.fit,
          style: widget.style,
          size: widget.size,
          pressedExpansion: widget.pressed,
          selectedExpansion: widget.selected,
          selectedIndex: multi ? null : _index,
          selectedIndices: multi ? _indices : const {},
          onSelectedIndexChanged: (i) => setState(() => _index = i),
          onSelectedIndicesChanged: (v) => setState(() => _indices = v),
          items: [
            for (final label in const ['Day', 'Week', 'Month'])
              MorphReactiveGroupItem(label: Text(label)),
          ],
        ),
        DemoReadout(multi ? 'Selected: $_indices' : 'Selected: $_index'),
      ],
    );
  }
}
