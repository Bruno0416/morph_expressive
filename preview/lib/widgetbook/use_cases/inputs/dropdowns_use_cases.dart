import 'package:material_ui/material_ui.dart'
    show BuildContext, Icon, SizedBox, State, StatefulWidget, Widget;
import 'package:morph_expressive/morph_expressive.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../utilities/demo.dart';
import '../../utilities/knobs.dart';
import '../../utilities/stage.dart';

const _path = '[Inputs]/Dropdowns';

const _items = <MorphDropdownItem<String>>[
  MorphDropdownItem(label: 'Flutter', value: 'flutter'),
  MorphDropdownItem(label: 'Dart', value: 'dart'),
  MorphDropdownItem(label: 'Kotlin', value: 'kotlin'),
  MorphDropdownItem(label: 'Swift', value: 'swift'),
  MorphDropdownItem(label: 'Rust', value: 'rust'),
  MorphDropdownItem(label: 'Disabled option', value: 'off', disabled: true),
];

@widgetbook.UseCase(name: 'Playground', type: MorphDropdownMenu, path: _path)
Widget dropdownPlaygroundUseCase(BuildContext context) {
  final single = context.knobs.boolean(
    label: 'single select',
    initialValue: true,
  );
  final search = context.knobs.boolean(label: 'search', initialValue: true);
  final enabled = context.knobs.boolean(label: 'enabled', initialValue: true);
  final motion = enumKnob<MorphDropdownMotionStyle>(
    context,
    label: 'motion style',
    values: MorphDropdownMotionStyle.values,
  );
  final radius = context.knobs.double.slider(
    label: 'container radius',
    initialValue: 28,
    min: 8,
    max: 40,
  );
  final maxSelections = context.knobs.int.slider(
    label: 'max selections (0 = unlimited)',
    initialValue: 0,
    min: 0,
    max: 5,
  );
  return _DropdownHarness(
    key: resetKey([single, search, motion, maxSelections]),
    single: single,
    search: search,
    enabled: enabled,
    motion: motion,
    radius: radius,
    maxSelections: maxSelections,
  );
}

class _DropdownHarness extends StatefulWidget {
  const _DropdownHarness({
    super.key,
    required this.single,
    required this.search,
    required this.enabled,
    required this.motion,
    required this.radius,
    required this.maxSelections,
  });

  final bool single;
  final bool search;
  final bool enabled;
  final MorphDropdownMotionStyle motion;
  final double radius;
  final int maxSelections;

  @override
  State<_DropdownHarness> createState() => _DropdownHarnessState();
}

class _DropdownHarnessState extends State<_DropdownHarness> {
  List<String> _selected = const [];

  @override
  Widget build(BuildContext context) {
    return Stage(
      children: [
        SizedBox(
          width: 420,
          child: MorphDropdownMenu<String>(
            items: _items,
            singleSelect: widget.single,
            searchEnabled: widget.search,
            enabled: widget.enabled,
            motionStyle: widget.motion,
            containerRadius: widget.radius,
            maxSelections: widget.maxSelections,
            searchStyle: MorphDropdownSearchStyle(
              searchIcon: Icon(FluentIcons.line.search, size: 23),
              minHeight: 54,
            ),
            onSelectionChanged: (items) =>
                setState(() => _selected = [for (final i in items) i.label]),
          ),
        ),
        DemoReadout('Selected: ${_selected.join(', ')}'),
      ],
    );
  }
}

@widgetbook.UseCase(name: 'Async items', type: MorphDropdownItem, path: _path)
Widget dropdownFutureUseCase(BuildContext context) {
  final delay = context.knobs.int.slider(
    label: 'load delay (ms)',
    initialValue: 600,
    min: 0,
    max: 3000,
  );
  return _FutureDropdown(key: resetKey([delay]), delay: delay);
}

class _FutureDropdown extends StatefulWidget {
  const _FutureDropdown({super.key, required this.delay});

  final int delay;

  @override
  State<_FutureDropdown> createState() => _FutureDropdownState();
}

class _FutureDropdownState extends State<_FutureDropdown> {
  Future<List<MorphDropdownItem<String>>> _load() =>
      Future.delayed(Duration(milliseconds: widget.delay), () => _items);

  @override
  Widget build(BuildContext context) {
    return Stage(
      children: [
        SizedBox(
          width: 420,
          child: MorphDropdownMenu<String>.future(
            future: _load,
            singleSelect: true,
            onSelectionChanged: (_) {},
          ),
        ),
      ],
    );
  }
}
