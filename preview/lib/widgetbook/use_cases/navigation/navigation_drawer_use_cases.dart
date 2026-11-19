import 'package:material_ui/material_ui.dart'
    show
        BuildContext,
        Center,
        Expanded,
        Icon,
        Row,
        SizedBox,
        State,
        StatefulWidget,
        Widget;
import 'package:morph_expressive/morph_expressive.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../utilities/demo.dart';
import '../../utilities/knobs.dart';

@widgetbook.UseCase(
  name: 'Playground',
  type: MorphNavigationDrawer,
  path: '[Navigation]/Drawer',
)
Widget navigationDrawerPlaygroundUseCase(BuildContext context) {
  final morph = context.knobs.boolean(
    label: 'morph constructor',
    initialValue: true,
  );
  final type = enumKnob<MorphNavigationDrawerType>(
    context,
    label: 'type',
    values: MorphNavigationDrawerType.values,
  );
  final headline = context.knobs.string(
    label: 'headline',
    initialValue: 'Navigation',
  );
  final stretch = context.knobs.double.slider(
    label: 'organic stretch',
    initialValue: 0.4,
    min: 0,
    max: 1,
    divisions: 20,
    precision: 2,
  );
  return _DrawerHarness(
    key: resetKey([morph, type]),
    morph: morph,
    type: type,
    headline: headline,
    stretch: stretch,
  );
}

class _DrawerHarness extends StatefulWidget {
  const _DrawerHarness({
    super.key,
    required this.morph,
    required this.type,
    required this.headline,
    required this.stretch,
  });

  final bool morph;
  final MorphNavigationDrawerType type;
  final String headline;
  final double stretch;

  @override
  State<_DrawerHarness> createState() => _DrawerHarnessState();
}

class _DrawerHarnessState extends State<_DrawerHarness> {
  int _index = 0;

  List<MorphNavigationDestination> get _destinations => [
    MorphNavigationDestination(
      label: 'Home',
      icon: Icon(FluentIcons.line.home),
    ),
    MorphNavigationDestination(
      label: 'Search',
      icon: Icon(FluentIcons.line.search),
    ),
    MorphNavigationDestination(
      label: 'Saved',
      icon: Icon(FluentIcons.line.heart),
      badgeLabel: '3',
      showBadge: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final drawer = widget.morph
        ? MorphNavigationDrawer.morph(
            headline: widget.headline,
            destinations: _destinations,
            selectedIndex: _index,
            type: widget.type,
            organicStretchIntensity: widget.stretch,
            onDestinationSelected: (i) => setState(() => _index = i),
          )
        : MorphNavigationDrawer(
            headline: widget.headline,
            destinations: _destinations,
            selectedIndex: _index,
            type: widget.type,
            organicStretchIntensity: widget.stretch,
            onDestinationSelected: (i) => setState(() => _index = i),
          );
    return Row(
      children: [
        SizedBox(width: 320, child: drawer),
        Expanded(child: Center(child: DemoReadout('Selected index $_index'))),
      ],
    );
  }
}
