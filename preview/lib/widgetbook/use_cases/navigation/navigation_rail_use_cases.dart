import 'package:material_ui/material_ui.dart'
    show
        BuildContext,
        Center,
        Expanded,
        Icon,
        Row,
        State,
        StatefulWidget,
        Text,
        Widget;
import 'package:morph_expressive/morph_expressive.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../utilities/demo.dart';
import '../../utilities/knobs.dart';

@widgetbook.UseCase(
  name: 'Playground',
  type: MorphNavigationRail,
  path: '[Navigation]/Rail',
)
Widget navigationRailPlaygroundUseCase(BuildContext context) {
  final morph = context.knobs.boolean(
    label: 'morph constructor',
    initialValue: true,
  );
  final type = enumKnob<MorphNavigationRailType>(
    context,
    label: 'type',
    values: MorphNavigationRailType.values,
  );
  final labels = enumKnob<MorphNavigationRailLabelBehavior>(
    context,
    label: 'label behavior',
    values: MorphNavigationRailLabelBehavior.values,
  );
  final alignment = enumKnob<MorphNavigationRailAlignment>(
    context,
    label: 'alignment',
    values: MorphNavigationRailAlignment.values,
  );
  final divider = context.knobs.boolean(label: 'divider');
  final fab = context.knobs.boolean(label: 'FAB');
  final stretch = context.knobs.double.slider(
    label: 'organic stretch',
    initialValue: 0.4,
    min: 0,
    max: 1,
    divisions: 20,
    precision: 2,
  );
  return _RailHarness(
    key: resetKey([morph, type]),
    morph: morph,
    type: type,
    labels: labels,
    alignment: alignment,
    divider: divider,
    fab: fab,
    stretch: stretch,
  );
}

class _RailHarness extends StatefulWidget {
  const _RailHarness({
    super.key,
    required this.morph,
    required this.type,
    required this.labels,
    required this.alignment,
    required this.divider,
    required this.fab,
    required this.stretch,
  });

  final bool morph;
  final MorphNavigationRailType type;
  final MorphNavigationRailLabelBehavior labels;
  final MorphNavigationRailAlignment alignment;
  final bool divider;
  final bool fab;
  final double stretch;

  @override
  State<_RailHarness> createState() => _RailHarnessState();
}

class _RailHarnessState extends State<_RailHarness> {
  int _index = 0;
  late MorphNavigationRailType _type = widget.type;

  @override
  Widget build(BuildContext context) {
    final sections = [
      MorphNavigationRailSection(
        header: const Text('Main'),
        destinations: [
          MorphNavigationRailDestination(
            label: 'Home',
            icon: Icon(FluentIcons.line.home),
          ),
          MorphNavigationRailDestination(
            label: 'Search',
            icon: Icon(FluentIcons.line.search),
          ),
        ],
      ),
      MorphNavigationRailSection(
        header: const Text('Library'),
        destinations: [
          MorphNavigationRailDestination(
            label: 'Saved',
            icon: Icon(FluentIcons.line.heart),
            badgeCount: 3,
          ),
          MorphNavigationRailDestination(
            label: 'Profile',
            icon: Icon(FluentIcons.line.person),
          ),
        ],
      ),
    ];
    final fab = widget.fab
        ? MorphNavigationRailFabSlot(
            icon: Icon(FluentIcons.line.add),
            label: 'Compose',
            onPressed: () {},
          )
        : null;
    final rail = widget.morph
        ? MorphNavigationRail.morph(
            sections: sections,
            selectedIndex: _index,
            onDestinationSelected: (i) => setState(() => _index = i),
            type: _type,
            onTypeChanged: (t) => setState(() => _type = t),
            labelBehavior: widget.labels,
            alignment: widget.alignment,
            showDivider: widget.divider,
            fab: fab,
            organicStretchIntensity: widget.stretch,
            scrollUnder: false,
          )
        : MorphNavigationRail(
            sections: sections,
            selectedIndex: _index,
            onDestinationSelected: (i) => setState(() => _index = i),
            type: _type,
            onTypeChanged: (t) => setState(() => _type = t),
            labelBehavior: widget.labels,
            alignment: widget.alignment,
            showDivider: widget.divider,
            fab: fab,
            organicStretchIntensity: widget.stretch,
            scrollUnder: false,
          );
    return Row(
      children: [
        rail,
        Expanded(
          child: Center(child: DemoReadout('Selected index $_index · $_type')),
        ),
      ],
    );
  }
}
