import 'package:material_ui/material_ui.dart'
    show
        BuildContext,
        Center,
        Column,
        Expanded,
        Icon,
        State,
        StatefulWidget,
        Widget;
import 'package:morph_expressive/morph_expressive.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../../tabs_lab.dart';
import '../../utilities/demo.dart';
import '../../utilities/knobs.dart';

const _path = '[Navigation]/Tabs';

@widgetbook.UseCase(name: 'Playground', type: MorphTabs, path: _path)
Widget tabsPlaygroundUseCase(BuildContext context) {
  final variant = enumKnob<MorphTabsVariant>(
    context,
    label: 'variant',
    values: MorphTabsVariant.values,
  );
  final style = enumKnob<MorphTabsIndicatorStyle>(
    context,
    label: 'indicator style',
    values: MorphTabsIndicatorStyle.values,
  );
  final motion = enumKnob<MorphTabsIndicatorMotion>(
    context,
    label: 'indicator motion',
    values: MorphTabsIndicatorMotion.values,
  );
  final alignment = enumKnob<MorphTabsAlignment>(
    context,
    label: 'alignment',
    values: MorphTabsAlignment.values,
  );
  final count = context.knobs.int.slider(
    label: 'tabs',
    initialValue: 3,
    min: 2,
    max: 10,
  );
  final icons = context.knobs.boolean(label: 'icons');
  final badges = context.knobs.boolean(label: 'badges');
  final scrollable = context.knobs.boolean(
    label: 'scrollable',
    initialValue: true,
  );
  return _TabsHarness(
    key: resetKey([count]),
    variant: variant,
    style: style,
    motion: motion,
    alignment: alignment,
    count: count,
    icons: icons,
    badges: badges,
    scrollable: scrollable,
  );
}

class _TabsHarness extends StatefulWidget {
  const _TabsHarness({
    super.key,
    required this.variant,
    required this.style,
    required this.motion,
    required this.alignment,
    required this.count,
    required this.icons,
    required this.badges,
    required this.scrollable,
  });

  final MorphTabsVariant variant;
  final MorphTabsIndicatorStyle style;
  final MorphTabsIndicatorMotion motion;
  final MorphTabsAlignment alignment;
  final int count;
  final bool icons;
  final bool badges;
  final bool scrollable;

  @override
  State<_TabsHarness> createState() => _TabsHarnessState();
}

class _TabsHarnessState extends State<_TabsHarness> {
  final MorphTabsController _controller = MorphTabsController();
  int _index = 0;

  static const _labels = [
    'Home',
    'Explore',
    'Saved',
    'Mail',
    'Profile',
    'Settings',
    'Library',
    'Archive',
    'Trash',
    'Help',
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final icons = [
      FluentIcons.line.home,
      FluentIcons.line.search,
      FluentIcons.line.heart,
      FluentIcons.line.mail,
      FluentIcons.line.person,
      FluentIcons.line.settings,
      FluentIcons.line.bookmark,
      FluentIcons.line.star,
      FluentIcons.line.info,
      FluentIcons.line.alert,
    ];
    return Column(
      children: [
        MorphTabs(
          controller: _controller,
          variant: widget.variant,
          indicatorStyle: widget.style,
          indicatorMotion: widget.motion,
          alignment: widget.alignment,
          scrollable: widget.scrollable,
          selectedIndex: _index,
          onTabSelected: (i) => setState(() => _index = i),
          tabs: [
            for (var i = 0; i < widget.count; i++)
              MorphTab(
                label: _labels[i],
                icon: widget.icons ? Icon(icons[i]) : null,
                badgeCount: widget.badges && i == 1 ? 3 : null,
                badgeDot: widget.badges && i == 2,
              ),
          ],
        ),
        Expanded(
          child: MorphTabsView(
            controller: _controller,
            selectedIndex: _index,
            onTabSelected: (i) => setState(() => _index = i),
            children: [
              for (var i = 0; i < widget.count; i++)
                Center(child: DemoReadout('Swipe or tap: ${_labels[i]}')),
            ],
          ),
        ),
      ],
    );
  }
}

@widgetbook.UseCase(name: 'Tabs lab', type: MorphTabsView, path: _path)
Widget tabsLabUseCase(BuildContext context) => const TabsLab();
