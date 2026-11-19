import 'package:material_ui/material_ui.dart'
    show
        BuildContext,
        Column,
        CrossAxisAlignment,
        EdgeInsets,
        Expanded,
        Icon,
        MediaQuery,
        Padding,
        Row,
        Size,
        SizedBox,
        State,
        StatefulWidget,
        StatelessWidget,
        Text,
        TextScaler,
        Widget;
import 'package:morph_expressive/morph_expressive.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../utilities/demo.dart';
import '../../utilities/density_lab.dart';
import '../../utilities/stage.dart';

const _path = '[Foundations]/Density';

const _buttonSizes = <(String, MorphButtonSize)>[
  ('xs', MorphButtonSize.xs),
  ('sm', MorphButtonSize.sm),
  ('md', MorphButtonSize.md),
  ('lg', MorphButtonSize.lg),
  ('xl', MorphButtonSize.xl),
];

@widgetbook.UseCase(name: 'Overview', type: MorphDensity, path: _path)
Widget densityOverviewUseCase(BuildContext context) {
  final morph = MorphTheme.of(context);
  return Stage(
    children: [
      StageSection(
        title: 'Density',
        note:
            'MorphThemeData.density is a layout axis independent of each '
            'component\'s size. It moves visual heights, padding and gaps; '
            'it never scales text, never transforms and never changes '
            'colors. Every column below is a real nested MorphTheme built '
            'with copyWith(density: ...). The global value (Morph panel '
            '> density) is ${densityLabels[morph.density]}.',
        child: DensityColumns(
          builder: (context, density) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MeasuredBox(
                prefix: 'button ',
                child: MorphButton.filled(
                  onPressed: () {},
                  label: const Text('Button'),
                ),
              ),
              MeasuredBox(
                prefix: 'chip ',
                child: MorphChip.filter(
                  label: 'Filter',
                  selected: true,
                  onPressed: () {},
                ),
              ),
              SizedBox(
                width: 260,
                child: MorphList(
                  itemCount: 1,
                  itemBuilder: (context, i) => MorphListItem(
                    headline: 'List item',
                    supportingText: 'Supporting text',
                    leading: Icon(FluentIcons.line.heart),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      const StageSection(
        title: 'Where to look next',
        note:
            'Controls Matrix, Input Matrix, Navigation Matrix and Content '
            'compare components; Spacing & Tokens prints the metrics; '
            'Accessibility shows visual size versus the accessible target.',
        child: SizedBox.shrink(),
      ),
    ],
  );
}

@widgetbook.UseCase(name: 'Controls Matrix', type: MorphDensity, path: _path)
Widget densityControlsMatrixUseCase(BuildContext context) {
  return Stage(
    children: [
      StageSection(
        title: 'Buttons: size x density',
        note: 'Measured visual size of the real render box.',
        child: DensityColumns(
          builder: (context, density) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final (name, size) in _buttonSizes)
                MeasuredBox(
                  prefix: '$name ',
                  child: MorphButton.filled(
                    size: size,
                    onPressed: () {},
                    label: Text(name),
                  ),
                ),
            ],
          ),
        ),
      ),
      StageSection(
        title: 'Button styles at size sm',
        child: DensityColumns(
          builder: (context, density) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MeasuredBox(
                child: MorphButton.tonal(
                  onPressed: () {},
                  icon: Icon(FluentIcons.line.add),
                  label: const Text('Tonal'),
                ),
              ),
              MeasuredBox(
                child: MorphButton.outlined(
                  onPressed: () {},
                  label: const Text('Outlined'),
                ),
              ),
              MeasuredBox(
                child: MorphButton.text(
                  onPressed: () {},
                  child: const Text('Text'),
                ),
              ),
            ],
          ),
        ),
      ),
      StageSection(
        title: 'Icon buttons',
        child: DensityColumns(
          builder: (context, density) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final size in MorphIconButtonSize.values)
                MeasuredBox(
                  prefix: '${size.name} ',
                  child: MorphIconButton.filled(
                    icon: Icon(FluentIcons.line.heart),
                    size: size,
                    tooltip: 'Icon button ${size.name}',
                    onPressed: () {},
                  ),
                ),
            ],
          ),
        ),
      ),
      StageSection(
        title: 'Chips',
        child: DensityColumns(
          builder: (context, density) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MeasuredBox(
                child: MorphChip.assist(label: 'Assist', onPressed: () {}),
              ),
              MeasuredBox(
                child: MorphChip.filter(
                  label: 'Filter',
                  selected: true,
                  onPressed: () {},
                ),
              ),
              MeasuredBox(
                child: MorphChip.input(
                  label: 'Input',
                  onPressed: () {},
                  onDeleted: () {},
                ),
              ),
              MeasuredBox(
                child: MorphChip.suggestion(
                  label: 'Suggestion',
                  onPressed: () {},
                ),
              ),
            ],
          ),
        ),
      ),
      StageSection(
        title: 'Segmented button',
        child: DensityColumns(
          width: 340,
          builder: (context, density) => const _SegmentedColumn(),
        ),
      ),
    ],
  );
}

class _SegmentedColumn extends StatefulWidget {
  const _SegmentedColumn();

  @override
  State<_SegmentedColumn> createState() => _SegmentedColumnState();
}

class _SegmentedColumnState extends State<_SegmentedColumn> {
  Set<String> _selected = {'Day'};

  @override
  Widget build(BuildContext context) {
    return MeasuredBox(
      child: SizedBox(
        width: 320,
        child: MorphSegmentedButton<String>(
          selected: _selected,
          onSelectionChanged: (next) => setState(() => _selected = next),
          segments: const [
            MorphSegment(value: 'Day', label: 'Day'),
            MorphSegment(value: 'Week', label: 'Week'),
            MorphSegment(value: 'Month', label: 'Month'),
          ],
        ),
      ),
    );
  }
}

@widgetbook.UseCase(name: 'Input Matrix', type: MorphDensity, path: _path)
Widget densityInputMatrixUseCase(BuildContext context) {
  return Stage(
    children: [
      StageSection(
        title: 'Text fields',
        child: DensityColumns(
          width: 320,
          builder: (context, density) => const _TextFieldColumn(),
        ),
      ),
      StageSection(
        title: 'Dropdown field',
        child: DensityColumns(
          width: 320,
          builder: (context, density) => MeasuredBox(
            child: SizedBox(
              width: 300,
              child: MorphDropdownMenu<String>(
                items: const [
                  MorphDropdownItem(label: 'Flutter', value: 'flutter'),
                  MorphDropdownItem(label: 'Dart', value: 'dart'),
                  MorphDropdownItem(label: 'Kotlin', value: 'kotlin'),
                ],
                searchEnabled: false,
                onSelectionChanged: (_) {},
              ),
            ),
          ),
        ),
      ),
      StageSection(
        title: 'Checkbox, radio and switch rows',
        child: DensityColumns(
          builder: (context, density) => const _SelectionRows(),
        ),
      ),
      StageSection(
        title: 'Slider',
        child: DensityColumns(
          builder: (context, density) => const _SliderColumn(),
        ),
      ),
    ],
  );
}

class _TextFieldColumn extends StatelessWidget {
  const _TextFieldColumn();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MeasuredBox(
          child: SizedBox(
            width: 300,
            child: MorphTextField.filled(
              label: 'Filled',
              placeholder: 'Type here',
              supportingText: 'Supporting text',
            ),
          ),
        ),
        MeasuredBox(
          child: SizedBox(
            width: 300,
            child: MorphTextField.outlined(
              label: 'Outlined',
              placeholder: 'Type here',
            ),
          ),
        ),
      ],
    );
  }
}

class _SelectionRows extends StatefulWidget {
  const _SelectionRows();

  @override
  State<_SelectionRows> createState() => _SelectionRowsState();
}

class _SelectionRowsState extends State<_SelectionRows> {
  bool _check = true;
  bool _switch = true;
  String _radio = 'a';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MeasuredBox(
          child: MorphCheckbox(
            value: _check,
            label: const Text('Checkbox'),
            onChanged: (v) => setState(() => _check = v ?? false),
          ),
        ),
        MorphRadioGroup<String>(
          groupValue: _radio,
          groupLabel: 'Radio group',
          onChanged: (v) => setState(() => _radio = v),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final v in const ['a', 'b'])
                MeasuredBox(
                  child: MorphRadio<String>(
                    value: v,
                    groupValue: _radio,
                    label: Text('Radio $v'),
                    onChanged: (n) => setState(() => _radio = n),
                  ),
                ),
            ],
          ),
        ),
        MeasuredBox(
          child: MorphSwitch(
            value: _switch,
            onChanged: (v) => setState(() => _switch = v),
          ),
        ),
      ],
    );
  }
}

class _SliderColumn extends StatefulWidget {
  const _SliderColumn();

  @override
  State<_SliderColumn> createState() => _SliderColumnState();
}

class _SliderColumnState extends State<_SliderColumn> {
  double _value = 0.4;

  @override
  Widget build(BuildContext context) {
    return MeasuredBox(
      child: SizedBox(
        width: 260,
        child: MorphSlider(
          value: _value,
          onChanged: (v) => setState(() => _value = v),
        ),
      ),
    );
  }
}

@widgetbook.UseCase(name: 'Navigation Matrix', type: MorphDensity, path: _path)
Widget densityNavigationMatrixUseCase(BuildContext context) {
  return Stage(
    children: [
      StageSection(
        title: 'Navigation bar',
        child: DensityColumns(
          width: 360,
          builder: (context, density) => const _NavBarColumn(),
        ),
      ),
      StageSection(
        title: 'Navigation rail',
        child: DensityColumns(
          width: 300,
          builder: (context, density) => const _RailColumn(),
        ),
      ),
      StageSection(
        title: 'Tabs',
        child: DensityColumns(
          width: 360,
          builder: (context, density) => const _TabsColumn(),
        ),
      ),
    ],
  );
}

class _NavBarColumn extends StatefulWidget {
  const _NavBarColumn();

  @override
  State<_NavBarColumn> createState() => _NavBarColumnState();
}

class _NavBarColumnState extends State<_NavBarColumn> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return MeasuredBox(
      child: SizedBox(
        width: 340,
        child: MorphNavigationBar(
          autoLayout: false,
          safeArea: false,
          selectedIndex: _index,
          onDestinationSelected: (i) => setState(() => _index = i),
          destinations: [
            MorphNavigationBarDestination(
              icon: FluentIcons.line.home,
              selectedIcon: FluentIcons.filled.home,
              label: 'Home',
            ),
            MorphNavigationBarDestination(
              icon: FluentIcons.line.search,
              selectedIcon: FluentIcons.line.search,
              label: 'Search',
            ),
            MorphNavigationBarDestination(
              icon: FluentIcons.line.mail,
              selectedIcon: FluentIcons.line.mail,
              label: 'Mail',
              badgeCount: 4,
            ),
          ],
        ),
      ),
    );
  }
}

class _RailColumn extends StatefulWidget {
  const _RailColumn();

  @override
  State<_RailColumn> createState() => _RailColumnState();
}

class _RailColumnState extends State<_RailColumn> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 320,
      child: Row(
        children: [
          MorphNavigationRail(
            selectedIndex: _index,
            onDestinationSelected: (i) => setState(() => _index = i),
            scrollUnder: false,
            sections: [
              MorphNavigationRailSection(
                destinations: [
                  MorphNavigationRailDestination(
                    label: 'Home',
                    icon: Icon(FluentIcons.line.home),
                  ),
                  MorphNavigationRailDestination(
                    label: 'Search',
                    icon: Icon(FluentIcons.line.search),
                  ),
                  MorphNavigationRailDestination(
                    label: 'Saved',
                    icon: Icon(FluentIcons.line.heart),
                    badgeCount: 3,
                  ),
                ],
              ),
            ],
          ),
          const Expanded(child: SizedBox.shrink()),
        ],
      ),
    );
  }
}

class _TabsColumn extends StatefulWidget {
  const _TabsColumn();

  @override
  State<_TabsColumn> createState() => _TabsColumnState();
}

class _TabsColumnState extends State<_TabsColumn> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final variant in MorphTabsVariant.values)
          MeasuredBox(
            prefix: '${variant.name} ',
            child: SizedBox(
              width: 340,
              child: MorphTabs(
                variant: variant,
                selectedIndex: _index,
                onTabSelected: (i) => setState(() => _index = i),
                tabs: [
                  MorphTab(label: 'Home', icon: Icon(FluentIcons.line.home)),
                  MorphTab(
                    label: 'Explore',
                    icon: Icon(FluentIcons.line.search),
                  ),
                  const MorphTab(label: 'Saved', badgeCount: 3),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

@widgetbook.UseCase(name: 'Content', type: MorphDensity, path: _path)
Widget densityContentUseCase(BuildContext context) {
  return Stage(
    children: [
      StageSection(
        title: 'List items',
        child: DensityColumns(
          width: 320,
          builder: (context, density) => MeasuredBox(
            child: SizedBox(
              width: 300,
              child: MorphList(
                itemCount: 2,
                itemBuilder: (context, i) => i == 0
                    ? MorphListItem(
                        headline: 'One line',
                        leading: Icon(FluentIcons.line.home),
                      )
                    : MorphListItem(
                        headline: 'Two lines',
                        supportingText: 'Supporting text',
                        leading: Icon(FluentIcons.line.mail),
                        trailingText: '12m',
                      ),
              ),
            ),
          ),
        ),
      ),
      StageSection(
        title: 'Cards',
        child: DensityColumns(
          width: 320,
          builder: (context, density) => MeasuredBox(
            child: MorphCard.filled(
              width: 300,
              headline: 'Card headline',
              subhead: 'Subhead',
              supportingText: 'Supporting text inside a filled card.',
              onPressed: () {},
            ),
          ),
        ),
      ),
      StageSection(
        title: 'Badges',
        note: 'Badge padding and minimum size follow density; text does not.',
        child: DensityColumns(
          builder: (context, density) => Row(
            children: [
              for (final count in const [3, 42, 999])
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: MorphBadge(
                    count: count,
                    child: Icon(FluentIcons.line.mail, size: 32),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: MorphBadge(
                  showDot: true,
                  child: Icon(FluentIcons.line.mail, size: 32),
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(name: 'Spacing & Tokens', type: MorphDensity, path: _path)
Widget densityTokensUseCase(BuildContext context) {
  return Stage(
    children: [
      StageSection(
        title: 'MorphDensityMetrics',
        note:
            'Additive deltas in logical pixels, read live from each '
            'column\'s theme (MorphTheme.of(context).densityMetrics).',
        child: DensityColumns(
          builder: (context, density) {
            final morph = MorphTheme.of(context);
            final m = morph.densityMetrics;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Row(
                  'controlHeight',
                  m.controlHeight.map(formatMetric).join(', '),
                ),
                _Row('rowHeight', formatMetric(m.rowHeight)),
                _Row('paddingHorizontal', formatMetric(m.paddingHorizontal)),
                _Row('paddingVertical', formatMetric(m.paddingVertical)),
                _Row('gap', formatMetric(m.gap)),
                _Row('iconSize', formatMetric(m.iconSize)),
              ],
            );
          },
        ),
      ),
      StageSection(
        title: 'densitySpacing',
        note: 'MorphThemeData.densitySpacing: the spacing scale after the gap delta.',
        child: DensityColumns(
          builder: (context, density) {
            final s = MorphTheme.of(context).densitySpacing;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Row('xs', formatMetric(s.xs)),
                _Row('sm', formatMetric(s.sm)),
                _Row('md', formatMetric(s.md)),
                _Row('lg', formatMetric(s.lg)),
                _Row('xl', formatMetric(s.xl)),
                _Row('xxl', formatMetric(s.xxl)),
              ],
            );
          },
        ),
      ),
      StageSection(
        title: 'MorphMenuDesktopMetrics',
        note:
            'Component table of the desktop menu presentation, one entry '
            'per density (MorphMenuDesktopMetrics.of).',
        child: DensityColumns(
          builder: (context, density) {
            final m = MorphMenuDesktopMetrics.of(density);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Row('itemHeight', formatMetric(m.itemHeight)),
                _Row('iconSize', formatMetric(m.iconSize)),
                _Row('horizontalPadding', formatMetric(m.horizontalPadding)),
                _Row(
                  'verticalPadding',
                  formatMetric(m.containerVerticalPadding),
                ),
                _Row('iconGap', formatMetric(m.iconGap)),
                _Row('shortcutGap', formatMetric(m.shortcutGap)),
                _Row('itemGap', formatMetric(m.itemGap)),
                _Row('groupLabelHeight', formatMetric(m.groupLabelHeight)),
                _Row('containerRadius', formatMetric(m.containerRadius)),
              ],
            );
          },
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(name: 'Accessibility', type: MorphDensity, path: _path)
Widget densityAccessibilityUseCase(BuildContext context) {
  return Stage(
    children: [
      StageSection(
        title: 'Visual size versus accessible target',
        note:
            'The outline is the 48 x 48 minimum tap target. Compact lowers '
            'the visual box; the control keeps its accessible target. Click '
            'inside the outline, around the visual box: the counter shows '
            'the control receiving it.',
        child: DensityColumns(
          builder: (context, density) => const _TargetProbe(),
        ),
      ),
      StageSection(
        title: 'Text scale independence',
        note:
            'The same filled button at 1x and 2x text scale. Density changes '
            'the height by a fixed delta at every scale; it never touches '
            'the text size.',
        child: DensityColumns(
          builder: (context, density) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final scale in const [1.0, 2.0])
                MediaQuery(
                  data: MediaQuery.of(context)
                      .copyWith(textScaler: TextScaler.linear(scale)),
                  child: MeasuredBox(
                    prefix: '${scale}x ',
                    child: MorphButton.filled(
                      onPressed: () {},
                      label: const Text('Button'),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    ],
  );
}

class _TargetProbe extends StatefulWidget {
  const _TargetProbe();

  @override
  State<_TargetProbe> createState() => _TargetProbeState();
}

class _TargetProbeState extends State<_TargetProbe> {
  int _presses = 0;
  Size? _visual;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TargetOutline(
          child: MeasuredBox(
            showReadout: false,
            onSize: (size) => setState(() => _visual = size),
            child: MorphIconButton.filled(
              icon: Icon(FluentIcons.line.heart),
              size: MorphIconButtonSize.xs,
              tooltip: 'Probe',
              onPressed: () => setState(() => _presses++),
            ),
          ),
        ),
        const SizedBox(height: 6),
        DemoReadout(
          'Visual ${_visual == null ? '…' : '${formatMetric(_visual!.width)} x '
                    '${formatMetric(_visual!.height)}'} · target 48 x 48 · '
          'presses: $_presses',
        ),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  const _Row(this.name, this.value);

  final String name;
  final String value;

  @override
  Widget build(BuildContext context) {
    final morph = MorphTheme.of(context);
    return Row(
      children: [
        SizedBox(
          width: 120,
          child: Text(
            name,
            style: morph.textTheme.bodySmall?.copyWith(
              color: morph.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(child: Text(value, style: morph.textTheme.bodyMedium)),
      ],
    );
  }
}
