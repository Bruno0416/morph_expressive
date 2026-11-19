import 'package:material_ui/material_ui.dart'
    show
        BuildContext,
        Column,
        Icon,
        IconData,
        MainAxisSize,
        SizedBox,
        State,
        StatefulWidget,
        Text,
        VoidCallback,
        Widget;
import 'package:morph_expressive/morph_expressive.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../../chip_organic_lab.dart';
import '../../utilities/demo.dart';
import '../../utilities/knobs.dart';
import '../../utilities/stage.dart';

const _path = '[Selection]/Chips';

/// Builds a chip through the named constructor of [type].
Widget _chipOfType(
  MorphChipType type, {
  required String label,
  VoidCallback? onPressed,
  VoidCallback? onDeleted,
  bool selected = false,
  bool elevated = false,
  Widget? leading,
  Widget? trailing,
}) {
  return switch (type) {
    MorphChipType.assist => MorphChip.assist(
      label: label,
      onPressed: onPressed,
      onDeleted: onDeleted,
      selected: selected,
      elevated: elevated,
      leading: leading,
      trailing: trailing,
    ),
    MorphChipType.filter => MorphChip.filter(
      label: label,
      onPressed: onPressed,
      onDeleted: onDeleted,
      selected: selected,
      elevated: elevated,
      leading: leading,
      trailing: trailing,
    ),
    MorphChipType.input => MorphChip.input(
      label: label,
      onPressed: onPressed,
      onDeleted: onDeleted,
      selected: selected,
      elevated: elevated,
      leading: leading,
      trailing: trailing,
    ),
    MorphChipType.suggestion => MorphChip.suggestion(
      label: label,
      onPressed: onPressed,
      onDeleted: onDeleted,
      selected: selected,
      elevated: elevated,
      leading: leading,
      trailing: trailing,
    ),
  };
}

@widgetbook.UseCase(name: 'Matrix', type: MorphChip, path: _path)
Widget chipMatrixUseCase(BuildContext context) {
  final elevated = context.knobs.boolean(label: 'elevated');
  final enabled = context.knobs.boolean(label: 'enabled', initialValue: true);
  final withIcon = context.knobs.boolean(label: 'leading icon');
  final label = context.knobs.string(label: 'label', initialValue: 'Chip');
  final icon = iconKnob(context, initial: 'star');
  return Stage(
    children: [
      for (final type in MorphChipType.values)
        StageSection(
          title: 'MorphChip.${type.name}',
          child: StageWrap(
            children: [
              for (final selected in [false, true])
                StageCell(
                  caption: selected ? 'selected' : 'unselected',
                  child: _chipOfType(
                    type,
                    label: label,
                    selected: selected,
                    elevated: elevated,
                    leading: withIcon ? Icon(icon, size: 18) : null,
                    onPressed: enabled ? () {} : null,
                  ),
                ),
              StageCell(
                caption: 'removable',
                child: _chipOfType(
                  type,
                  label: label,
                  elevated: elevated,
                  onPressed: enabled ? () {} : null,
                  onDeleted: enabled ? () {} : null,
                ),
              ),
            ],
          ),
        ),
    ],
  );
}

@widgetbook.UseCase(name: 'Playground', type: MorphChip, path: _path)
Widget chipPlaygroundUseCase(BuildContext context) {
  final type = enumKnob<MorphChipType>(
    context,
    label: 'type',
    values: MorphChipType.values,
    initial: MorphChipType.filter,
  );
  final elevated = context.knobs.boolean(label: 'elevated');
  final enabled = context.knobs.boolean(label: 'enabled', initialValue: true);
  final removable = context.knobs.boolean(label: 'removable');
  final withIcon = context.knobs.boolean(label: 'leading icon');
  final label = context.knobs.string(label: 'label', initialValue: 'Filter');
  final icon = iconKnob(context, initial: 'star');
  return _ChipHarness(
    key: resetKey([type, elevated, removable, withIcon]),
    type: type,
    elevated: elevated,
    enabled: enabled,
    removable: removable,
    icon: withIcon ? icon : null,
    label: label,
  );
}

class _ChipHarness extends StatefulWidget {
  const _ChipHarness({
    super.key,
    required this.type,
    required this.elevated,
    required this.enabled,
    required this.removable,
    required this.icon,
    required this.label,
  });

  final MorphChipType type;
  final bool elevated;
  final bool enabled;
  final bool removable;
  final IconData? icon;
  final String label;

  @override
  State<_ChipHarness> createState() => _ChipHarnessState();
}

class _ChipHarnessState extends State<_ChipHarness> {
  bool _selected = false;
  bool _removed = false;
  int _presses = 0;

  @override
  Widget build(BuildContext context) {
    return StageCenter(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!_removed)
            _chipOfType(
              widget.type,
              label: widget.label,
              selected: _selected,
              elevated: widget.elevated,
              leading: widget.icon == null ? null : Icon(widget.icon, size: 18),
              onPressed: widget.enabled
                  ? () => setState(() {
                      _presses++;
                      _selected = !_selected;
                    })
                  : null,
              onDeleted: widget.removable && widget.enabled
                  ? () => setState(() => _removed = true)
                  : null,
            )
          else
            MorphButton.text(
              onPressed: () => setState(() => _removed = false),
              child: const Text('Restore chip'),
            ),
          const SizedBox(height: 16),
          DemoReadout('Pressed $_presses times · selected: $_selected'),
        ],
      ),
    );
  }
}

@widgetbook.UseCase(name: 'Chip group', type: MorphChipGroup, path: _path)
Widget chipGroupUseCase(BuildContext context) {
  final type = enumKnob<MorphChipType>(
    context,
    label: 'type',
    values: MorphChipType.values,
    initial: MorphChipType.filter,
  );
  return _ChipGroupHarness(key: resetKey([type]), type: type);
}

class _ChipGroupHarness extends StatefulWidget {
  const _ChipGroupHarness({super.key, required this.type});

  final MorphChipType type;

  @override
  State<_ChipGroupHarness> createState() => _ChipGroupHarnessState();
}

class _ChipGroupHarnessState extends State<_ChipGroupHarness> {
  final Set<String> _selected = {'Flutter'};
  static const _tags = ['Flutter', 'Dart', 'Kotlin', 'Swift', 'Rust'];

  @override
  Widget build(BuildContext context) {
    return Stage(
      children: [
        MorphChipGroup(
          groupLabel: 'Languages',
          child: StageWrap(
            children: [
              for (final tag in _tags)
                _chipOfType(
                  widget.type,
                  label: tag,
                  selected: _selected.contains(tag),
                  onPressed: () => setState(() {
                    if (!_selected.add(tag)) _selected.remove(tag);
                  }),
                ),
            ],
          ),
        ),
        DemoReadout('Selected: ${_selected.join(', ')}'),
      ],
    );
  }
}

@widgetbook.UseCase(name: 'Chip toggle', type: MorphChipToggle, path: _path)
Widget chipToggleUseCase(BuildContext context) {
  final multi = context.knobs.boolean(label: 'multi selection');
  final organic = context.knobs.double.slider(
    label: 'organic intensity',
    initialValue: 0,
    min: 0,
    max: 1,
    divisions: 20,
    precision: 2,
  );
  final stretch = context.knobs.double.slider(
    label: 'organic stretch',
    initialValue: 0.4,
    min: 0,
    max: 1,
    divisions: 20,
    precision: 2,
  );
  final icons = context.knobs.boolean(label: 'icons');
  final scrollable = context.knobs.boolean(
    label: 'scrollable',
    initialValue: true,
  );
  return _ChipToggleHarness(
    key: resetKey([multi]),
    multi: multi,
    organic: organic,
    stretch: stretch,
    icons: icons,
    scrollable: scrollable,
  );
}

class _ChipToggleHarness extends StatefulWidget {
  const _ChipToggleHarness({
    super.key,
    required this.multi,
    required this.organic,
    required this.stretch,
    required this.icons,
    required this.scrollable,
  });

  final bool multi;
  final double organic;
  final double stretch;
  final bool icons;
  final bool scrollable;

  @override
  State<_ChipToggleHarness> createState() => _ChipToggleHarnessState();
}

class _ChipToggleHarnessState extends State<_ChipToggleHarness> {
  String _single = 'Daily';
  Set<String> _many = {'Daily', 'Monthly'};

  @override
  Widget build(BuildContext context) {
    final options = [
      MorphChipToggleOption<String>(
        value: 'Daily',
        label: 'Daily',
        icon: widget.icons ? FluentIcons.line.home : null,
      ),
      MorphChipToggleOption<String>(
        value: 'Weekly',
        label: 'Weekly',
        icon: widget.icons ? FluentIcons.line.star : null,
      ),
      MorphChipToggleOption<String>(
        value: 'Monthly',
        label: 'Monthly',
        icon: widget.icons ? FluentIcons.line.heart : null,
      ),
    ];
    return Stage(
      children: [
        MorphChipToggle<String>(
          options: options,
          multiSelection: widget.multi,
          selected: widget.multi ? null : _single,
          selectedValues: widget.multi ? _many : null,
          onChanged: (value) => setState(() => _single = value),
          onSelectionChanged: (values) => setState(() => _many = values),
          organicIntensity: widget.organic,
          organicStretchIntensity: widget.stretch,
          scrollable: widget.scrollable,
        ),
        DemoReadout(
          widget.multi ? 'Selected: ${_many.join(', ')}' : 'Selected: $_single',
        ),
      ],
    );
  }
}

@widgetbook.UseCase(
  name: 'Organic ink lab',
  type: MorphChipToggleOption,
  path: _path,
)
Widget chipOrganicLabUseCase(BuildContext context) =>
    const MorphChipOrganicLab();
