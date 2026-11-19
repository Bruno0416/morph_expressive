import 'package:material_ui/material_ui.dart'
    show
        AlwaysScrollableScrollPhysics,
        BuildContext,
        Center,
        Column,
        Expanded,
        IconData,
        ListView,
        State,
        StatefulWidget,
        Widget;
import 'package:morph_expressive/morph_expressive.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../../floating_navigation_sample.dart';
import '../../utilities/demo.dart';
import '../../utilities/knobs.dart';

const _path = '[Navigation]/Navigation Bar';

enum _BarKind { standard, expressive, morph }

List<MorphNavigationBarDestination> _destinations(int count) {
  final items = <(String, IconData, IconData)>[
    ('Home', FluentIcons.line.home, FluentIcons.filled.home),
    ('Search', FluentIcons.line.search, FluentIcons.line.search),
    ('Saved', FluentIcons.line.bookmark, FluentIcons.line.bookmark),
    ('Mail', FluentIcons.line.mail, FluentIcons.line.mail),
    ('Profile', FluentIcons.line.person, FluentIcons.line.person),
  ];
  return [
    for (var i = 0; i < count; i++)
      MorphNavigationBarDestination(
        icon: items[i].$2,
        selectedIcon: items[i].$3,
        label: items[i].$1,
        badgeCount: i == 3 ? 4 : null,
      ),
  ];
}

@widgetbook.UseCase(name: 'Playground', type: MorphNavigationBar, path: _path)
Widget navigationBarPlaygroundUseCase(BuildContext context) {
  final kind = enumKnob<_BarKind>(
    context,
    label: 'constructor',
    values: _BarKind.values,
  );
  final layout = enumKnob<MorphNavBarLayout>(
    context,
    label: 'layout',
    values: MorphNavBarLayout.values,
  );
  final labels = enumKnob<MorphNavBarLabelBehavior>(
    context,
    label: 'label behavior',
    values: MorphNavBarLabelBehavior.values,
  );
  final size = enumKnob<MorphNavBarSize>(
    context,
    label: 'size',
    values: MorphNavBarSize.values,
  );
  final shape = enumKnob<MorphNavBarShapeFamily>(
    context,
    label: 'shape family',
    values: MorphNavBarShapeFamily.values,
  );
  final density = enumKnob<MorphNavBarDensity>(
    context,
    label: 'density',
    values: MorphNavBarDensity.values,
  );
  final floating = context.knobs.boolean(label: 'floating');
  final distribute = context.knobs.boolean(label: 'distribute wide items');
  final stretch = context.knobs.double.slider(
    label: 'organic stretch',
    initialValue: 0.4,
    min: 0,
    max: 1,
    divisions: 20,
    precision: 2,
  );
  final count = context.knobs.int.slider(
    label: 'destinations',
    initialValue: 3,
    min: 2,
    max: 5,
  );
  return _NavBarHarness(
    key: resetKey([kind, count]),
    kind: kind,
    layout: layout,
    labels: labels,
    size: size,
    shape: shape,
    density: density,
    floating: floating,
    distribute: distribute,
    stretch: stretch,
    count: count,
  );
}

class _NavBarHarness extends StatefulWidget {
  const _NavBarHarness({
    super.key,
    required this.kind,
    required this.layout,
    required this.labels,
    required this.size,
    required this.shape,
    required this.density,
    required this.floating,
    required this.distribute,
    required this.stretch,
    required this.count,
  });

  final _BarKind kind;
  final MorphNavBarLayout layout;
  final MorphNavBarLabelBehavior labels;
  final MorphNavBarSize size;
  final MorphNavBarShapeFamily shape;
  final MorphNavBarDensity density;
  final bool floating;
  final bool distribute;
  final double stretch;
  final int count;

  @override
  State<_NavBarHarness> createState() => _NavBarHarnessState();
}

class _NavBarHarnessState extends State<_NavBarHarness> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final destinations = _destinations(widget.count);
    void select(int i) => setState(() => _index = i);
    final bar = switch (widget.kind) {
      _BarKind.standard => MorphNavigationBar(
        destinations: destinations,
        selectedIndex: _index,
        onDestinationSelected: select,
        autoLayout: false,
        layout: widget.layout,
        labelBehavior: widget.labels,
        size: widget.size,
        shapeFamily: widget.shape,
        density: widget.density,
        floating: widget.floating,
        distributeWideDestinations: widget.distribute,
        organicStretchIntensity: widget.stretch,
        safeArea: false,
      ),
      _BarKind.expressive => MorphNavigationBar.expressive(
        destinations: destinations,
        selectedIndex: _index,
        onDestinationSelected: select,
        autoLayout: false,
        layout: widget.layout,
        labelBehavior: widget.labels,
        size: widget.size,
        shapeFamily: widget.shape,
        density: widget.density,
        floating: widget.floating,
        distributeWideDestinations: widget.distribute,
        organicStretchIntensity: widget.stretch,
        safeArea: false,
      ),
      _BarKind.morph => MorphNavigationBar.morph(
        destinations: destinations,
        selectedIndex: _index,
        onDestinationSelected: select,
        layout: widget.layout,
        labelBehavior: widget.labels,
        size: widget.size,
        shapeFamily: widget.shape,
        density: widget.density,
        floating: widget.floating,
        distributeWideDestinations: widget.distribute,
        organicStretchIntensity: widget.stretch,
        safeArea: false,
      ),
    };
    return Column(
      children: [
        Expanded(
          child: Center(
            child: DemoReadout(
              'Selected: ${destinations[_index].label} (index $_index)',
            ),
          ),
        ),
        bar,
      ],
    );
  }
}

@widgetbook.UseCase(
  name: 'Host with scroll and refresh',
  type: MorphNavigationBarHost,
  path: _path,
)
Widget navigationBarHostUseCase(BuildContext context) {
  final hideOnScroll = context.knobs.boolean(
    label: 'hide on scroll',
    initialValue: true,
  );
  final backToTop = context.knobs.boolean(
    label: 'back to top',
    initialValue: true,
  );
  return _HostHarness(
    key: resetKey([hideOnScroll, backToTop]),
    hideOnScroll: hideOnScroll,
    backToTop: backToTop,
  );
}

class _HostHarness extends StatefulWidget {
  const _HostHarness({
    super.key,
    required this.hideOnScroll,
    required this.backToTop,
  });

  final bool hideOnScroll;
  final bool backToTop;

  @override
  State<_HostHarness> createState() => _HostHarnessState();
}

class _HostHarnessState extends State<_HostHarness> {
  int _index = 0;
  int _refreshes = 0;

  @override
  Widget build(BuildContext context) {
    return MorphNavigationBarHost(
      hideOnScroll: widget.hideOnScroll,
      showBackToTop: widget.backToTop,
      onRefresh: () async {
        await Future<void>.delayed(const Duration(milliseconds: 600));
        if (mounted) setState(() => _refreshes++);
      },
      bar: MorphNavigationBar.morph(
        destinations: _destinations(3),
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        floating: true,
        safeArea: false,
      ),
      body: (context, controller, padding) => ListView.builder(
        controller: controller,
        padding: padding,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: 60,
        itemBuilder: (context, i) => MorphListItem(
          headline: 'Row ${i + 1}',
          supportingText: 'Refreshed $_refreshes times',
        ),
      ),
    );
  }
}

@widgetbook.UseCase(
  name: 'Floating glass sample',
  type: FloatingNavigationSample,
  path: _path,
)
Widget floatingNavigationSampleUseCase(BuildContext context) =>
    const FloatingNavigationSample();
