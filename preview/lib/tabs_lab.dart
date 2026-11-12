import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:material_ui/material_ui.dart' show AppBar, IconButton, Scaffold;
import 'package:morph_expressive/morph_expressive.dart';

/// Tabs laboratory: continuous selection, page-linked progress and the
/// controls to compare presentations, motion profiles, fits and renderers.
///
/// Open with `?lab=tabs` (web) or `--dart-define=MORPH_LAB=tabs` (native).
class TabsLab extends StatefulWidget {
  const TabsLab({super.key, this.onToggleTheme});

  final VoidCallback? onToggleTheme;

  @override
  State<TabsLab> createState() => _TabsLabState();
}

class _TabsLabState extends State<TabsLab> {
  // Presentation and motion.
  MorphTabsIndicatorStyle style = MorphTabsIndicatorStyle.surface;
  MorphTabsIndicatorMotion motion = MorphTabsIndicatorMotion.slide;
  MorphShapeRenderer renderer = MorphShapeRenderer.auto;
  MorphShapeRenderer? effective;
  String? effectiveReason;

  // Numbers.
  double durationMs = 300;
  double elasticity = 0.3;
  double thickness = 3;
  double radius = 12;
  double padding = 16;
  double verticalPadding = 8;
  double surfaceInset = 4;
  bool pill = true;
  bool roundedEnds = true;
  bool group = false;

  // Environment.
  bool reduced = false;
  bool rtl = false;
  bool largeText = false;
  bool mobile = false;

  // Section state.
  int underline = 0, pillIndex = 0, rect = 0, compare = 0, fit = 0;
  int distribution = 0, scrolling = 0, icons = 0;
  int linked = 0, independent = 0;
  int callbacks = 0;
  bool appRejects = false;
  int pageMs = 300;

  final MorphTabsController linkedController = MorphTabsController();
  final MorphTabsController independentController = MorphTabsController();
  final List<Timer> timers = <Timer>[];
  int nextId = 5;
  bool longLabel = false;
  bool badge = false;
  late List<MorphTab> linkedTabs = <MorphTab>[
    for (final String s in <String>[
      'Overview',
      'Activity',
      'Updates',
      'Reports',
      'Settings',
    ])
      MorphTab(label: s, id: s),
  ];

  static const List<String> uneven = <String>[
    'All',
    'Recently played',
    'Albums',
    'Artists and bands',
    'Podcasts',
  ];

  @override
  void dispose() {
    for (final Timer t in timers) {
      t.cancel();
    }
    linkedController.dispose();
    independentController.dispose();
    super.dispose();
  }

  void later(int ms, VoidCallback action) {
    timers.add(
      Timer(Duration(milliseconds: ms), () {
        if (mounted) setState(action);
      }),
    );
  }

  void cancelTimers() {
    for (final Timer t in timers) {
      t.cancel();
    }
    timers.clear();
  }

  // -- configuration ------------------------------------------------------

  MorphTabTheme get cfg => MorphTabTheme(
    indicatorDuration: Duration(milliseconds: durationMs.round()),
    indicatorElasticity: elasticity,
    indicatorHeight: thickness,
    secondaryIndicatorHeight: thickness,
    indicatorRoundedEnds: roundedEnds,
    indicatorSurfaceRadius: pill ? null : radius,
    indicatorPadding: padding,
    indicatorVerticalPadding: verticalPadding,
    indicatorSurfaceInset: surfaceInset,
    indicatorGroupBackground: group,
    indicatorRenderer: renderer,
  );

  void report(MorphShapeRenderStatus status) {
    if (effective == status.effective && effectiveReason == status.reason) {
      return;
    }
    setState(() {
      effective = status.effective;
      effectiveReason = status.reason;
    });
  }

  // -- building blocks ----------------------------------------------------

  Widget choice(String text, VoidCallback action, {bool selected = false}) =>
      selected
      ? MorphButton.filled(onPressed: action, child: Text(text))
      : MorphButton.tonal(onPressed: action, child: Text(text));

  Widget choices(Iterable<Widget> items) =>
      Wrap(spacing: 8, runSpacing: 8, children: items.toList());

  Widget slider(
    String label,
    double value,
    double min,
    double max,
    ValueChanged<double> onChanged, {
    String Function(double)? format,
  }) {
    final String shown = format == null
        ? value.toStringAsFixed(value == value.roundToDouble() ? 0 : 2)
        : format(value);
    final Widget track = MorphSlider(
      value: ((value - min) / (max - min)).clamp(0.0, 1.0),
      onChanged: (double v) => setState(() => onChanged(min + v * (max - min))),
    );
    if (mobile || largeText) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[Text('$label: $shown'), track],
      );
    }
    return Row(
      children: <Widget>[
        SizedBox(width: 190, child: Text('$label: $shown')),
        Expanded(child: track),
      ],
    );
  }

  Widget section(String title, String note, List<Widget> children) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(title, style: MorphTheme.of(context).typeScale.titleLarge),
        const SizedBox(height: 4),
        Text(note, style: MorphTheme.of(context).typeScale.bodySmall),
        const SizedBox(height: 12),
        ...children,
      ],
    ),
  );

  Widget panel(Widget child) {
    final MorphColorScheme scheme = MorphTheme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }

  Widget bar({
    required List<MorphTab> tabs,
    required int index,
    required ValueChanged<int> onChanged,
    MorphTabsIndicatorStyle? styleOverride,
    MorphTabsIndicatorMotion? motionOverride,
    MorphTabsIndicatorFit? fitOverride,
    MorphTabsAlignment alignment = MorphTabsAlignment.fill,
    bool? scrollable,
    MorphTabsVariant variant = MorphTabsVariant.primary,
    MorphTabTheme? theme,
    MorphTabsController? controller,
    bool reportRenderer = false,
    Key? key,
  }) {
    return MorphTabs(
      key: key,
      tabs: tabs,
      selectedIndex: index,
      onTabSelected: (int i) {
        callbacks++;
        onChanged(i);
      },
      variant: variant,
      alignment: alignment,
      scrollable: scrollable,
      controller: controller,
      indicatorStyle: styleOverride ?? style,
      indicatorMotion: motionOverride ?? motion,
      indicatorFit: fitOverride,
      indicatorDuration: Duration(milliseconds: durationMs.round()),
      tabTheme: theme ?? cfg,
      onIndicatorRendererChanged: reportRenderer ? report : null,
    );
  }

  List<MorphTab> labels(List<String> values) => <MorphTab>[
    for (final String v in values) MorphTab(label: v),
  ];

  // -- actions ------------------------------------------------------------

  void firstToLast() {
    cancelTimers();
    setState(() {
      final int last = linkedTabs.length - 1;
      linkedController.select(linked == last ? 0 : last);
    });
  }

  void rapid() {
    cancelTimers();
    final int n = linkedTabs.length;
    final List<int> order = <int>[n - 1, 1, n - 2, 0, 2];
    for (var i = 0; i < order.length; i++) {
      later(i * 110, () => linked = order[i].clamp(0, n - 1));
    }
  }

  void slowTravel() {
    cancelTimers();
    final int last = linkedTabs.length - 1;
    setState(() {
      pageMs = 1600;
      linked = linked == last ? 0 : last;
    });
    later(1800, () => pageMs = durationMs.round());
  }

  void toggleLabel() {
    setState(() {
      longLabel = !longLabel;
      rebuildLinkedTab(1);
    });
  }

  void toggleBadge() {
    setState(() {
      badge = !badge;
      rebuildLinkedTab(1);
    });
  }

  void rebuildLinkedTab(int i) {
    if (i >= linkedTabs.length) return;
    final MorphTab old = linkedTabs[i];
    linkedTabs = <MorphTab>[
      ...linkedTabs.take(i),
      MorphTab(
        id: old.id,
        label: i == 1 && longLabel ? 'Activity and alerts' : 'Activity',
        badgeCount: i == 1 && badge ? 12 : null,
      ),
      ...linkedTabs.skip(i + 1),
    ];
  }

  void addEnd() => setState(() {
    final String id = 'Tab ${nextId++}';
    linkedTabs = <MorphTab>[...linkedTabs, MorphTab(label: id, id: id)];
  });

  void addStart() => setState(() {
    final String id = 'New ${nextId++}';
    // The parent keeps its index: the bar reports the moved selection.
    linkedTabs = <MorphTab>[MorphTab(label: id, id: id), ...linkedTabs];
  });

  void removeSelected() => setState(() {
    if (linkedTabs.length <= 2) return;
    final int i = linked.clamp(0, linkedTabs.length - 1);
    linkedTabs = <MorphTab>[...linkedTabs]..removeAt(i);
    linked = i.clamp(0, linkedTabs.length - 1);
  });

  // -- build --------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final MorphThemeData theme = MorphTheme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tabs Lab'),
        actions: <Widget>[
          IconButton(
            onPressed: widget.onToggleTheme,
            tooltip: 'Light / dark',
            icon: Icon(FluentIcons.line.weather_sunny),
          ),
        ],
      ),
      body: MorphTheme(
        data: theme.copyWith(reduceMotion: reduced || theme.reduceMotion),
        child: Directionality(
          textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
          child: MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: TextScaler.linear(largeText ? 2 : 1)),
            child: Align(
              alignment: Alignment.topCenter,
              child: SizedBox(
                width: mobile ? 390 : 980,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      controls(),
                      underlineSection(),
                      surfaceSections(),
                      compareSection(),
                      fitSection(),
                      distributionSection(),
                      scrollSection(),
                      iconsSection(),
                      linkedSection(),
                      independentSection(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget controls() {
    return section(
      'Controls',
      'One configuration drives every bar below (precedence: widget → tab theme → defaults).',
      <Widget>[
        choices(<Widget>[
          for (final MorphTabsIndicatorStyle s
              in MorphTabsIndicatorStyle.values)
            choice(
              'Presentation: ${s.name}',
              () => setState(() => style = s),
              selected: style == s,
            ),
          for (final MorphTabsIndicatorMotion m
              in MorphTabsIndicatorMotion.values)
            choice(
              'Motion: ${m.name}',
              () => setState(() => motion = m),
              selected: motion == m,
            ),
        ]),
        const SizedBox(height: 8),
        choices(<Widget>[
          for (final MorphShapeRenderer r in MorphShapeRenderer.values)
            choice(
              'Renderer: ${r.name}',
              () => setState(() => renderer = r),
              selected: renderer == r,
            ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              'Requested ${renderer.name} · effective '
              '${effective?.name ?? '…'}'
              '${effectiveReason == null ? '' : ' ($effectiveReason)'}',
              key: const ValueKey<String>('tabs_lab_renderer_status'),
            ),
          ),
        ]),
        const SizedBox(height: 8),
        slider('Duration (ms)', durationMs, 80, 1200, (double v) {
          durationMs = v;
          pageMs = v.round();
        }),
        slider(
          'Elastic amplitude',
          elasticity,
          0,
          1,
          (double v) => elasticity = v,
        ),
        slider(
          'Underline thickness',
          thickness,
          2,
          8,
          (double v) => thickness = v,
        ),
        slider('Inner radius (outer = inner + inset)', radius, 4, 24, (
          double v,
        ) {
          radius = v;
          pill = false;
        }),
        slider(
          'Content padding (horizontal)',
          padding,
          0,
          28,
          (double v) => padding = v,
        ),
        slider(
          'Content padding (vertical)',
          verticalPadding,
          0,
          16,
          (double v) => verticalPadding = v,
        ),
        slider(
          'Container inset (all sides)',
          surfaceInset,
          0,
          12,
          (double v) => surfaceInset = v,
        ),
        const SizedBox(height: 8),
        choices(<Widget>[
          choice(
            'Pill: $pill',
            () => setState(() => pill = !pill),
            selected: pill,
          ),
          choice(
            'Rounded line ends: $roundedEnds',
            () => setState(() => roundedEnds = !roundedEnds),
            selected: roundedEnds,
          ),
          choice(
            'Group background: $group',
            () => setState(() => group = !group),
            selected: group,
          ),
          choice(
            'Reduced motion: $reduced',
            () => setState(() => reduced = !reduced),
            selected: reduced,
          ),
          choice('RTL: $rtl', () => setState(() => rtl = !rtl), selected: rtl),
          choice(
            'Text 2×: $largeText',
            () => setState(() => largeText = !largeText),
            selected: largeText,
          ),
          choice(
            'Mobile width: $mobile',
            () => setState(() => mobile = !mobile),
            selected: mobile,
          ),
        ]),
      ],
    );
  }

  Widget underlineSection() => section(
    '1 · Underline, labels of different length',
    'Rounded line that travels and changes length; content-fit.',
    <Widget>[
      panel(
        bar(
          tabs: labels(uneven),
          index: underline,
          onChanged: (int i) => setState(() => underline = i),
          styleOverride: MorphTabsIndicatorStyle.underline,
          fitOverride: MorphTabsIndicatorFit.content,
          alignment: MorphTabsAlignment.content,
        ),
      ),
      panel(
        bar(
          tabs: labels(uneven.take(3).toList()),
          index: underline.clamp(0, 2),
          onChanged: (int i) => setState(() => underline = i),
          styleOverride: MorphTabsIndicatorStyle.underline,
          variant: MorphTabsVariant.secondary,
        ),
      ),
    ],
  );

  Widget surfaceSections() => section(
    '2 · Pill surface  ·  3 · Rounded-rectangle surface',
    'A persistent surface travels behind the content. Selected content colour follows it.',
    <Widget>[
      panel(
        bar(
          tabs: labels(uneven),
          index: pillIndex,
          onChanged: (int i) => setState(() => pillIndex = i),
          styleOverride: MorphTabsIndicatorStyle.surface,
          fitOverride: MorphTabsIndicatorFit.content,
          alignment: MorphTabsAlignment.content,
          theme: cfg.copyWith(indicatorGroupBackground: group),
          reportRenderer: true,
          key: const ValueKey<String>('tabs_lab_pill'),
        ),
      ),
      panel(
        bar(
          tabs: labels(uneven),
          index: rect,
          onChanged: (int i) => setState(() => rect = i),
          styleOverride: MorphTabsIndicatorStyle.surface,
          fitOverride: MorphTabsIndicatorFit.content,
          alignment: MorphTabsAlignment.content,
          theme: cfg.copyWith(indicatorSurfaceRadius: 10),
          key: const ValueKey<String>('tabs_lab_rect'),
        ),
      ),
    ],
  );

  Widget compareSection() => section(
    '4 · Slide and discreet elastic, side by side',
    'Same selection, same duration. Elastic only moves the leading edge slightly ahead.',
    <Widget>[
      choices(<Widget>[
        for (var i = 0; i < 5; i++)
          choice(
            'Go to $i',
            () => setState(() => compare = i),
            selected: compare == i,
          ),
      ]),
      const SizedBox(height: 8),
      for (final MorphTabsIndicatorMotion m in MorphTabsIndicatorMotion.values)
        panel(
          bar(
            tabs: labels(<String>['One', 'Two', 'Three', 'Four', 'Five']),
            index: compare,
            onChanged: (int i) => setState(() => compare = i),
            motionOverride: m,
            styleOverride: MorphTabsIndicatorStyle.surface,
            fitOverride: MorphTabsIndicatorFit.tab,
            alignment: MorphTabsAlignment.content,
            key: ValueKey<String>('tabs_lab_compare_${m.name}'),
          ),
        ),
    ],
  );

  Widget fitSection() => section(
    '5 · Indicator fit: content and tab',
    'The indicator width is independent of how the tabs are distributed.',
    <Widget>[
      for (final MorphTabsIndicatorFit f in MorphTabsIndicatorFit.values)
        panel(
          bar(
            tabs: labels(<String>['Short', 'A noticeably longer label', 'Mid']),
            index: fit.clamp(0, 2),
            onChanged: (int i) => setState(() => fit = i),
            fitOverride: f,
            styleOverride: MorphTabsIndicatorStyle.surface,
            key: ValueKey<String>('tabs_lab_fit_${f.name}'),
          ),
        ),
    ],
  );

  Widget distributionSection() => section(
    '6 · Distribution: uniform and by content',
    'Tabs stay still; only the indicator moves. Content-fit indicator in both.',
    <Widget>[
      for (final MorphTabsAlignment a in <MorphTabsAlignment>[
        MorphTabsAlignment.fill,
        MorphTabsAlignment.content,
      ])
        panel(
          bar(
            tabs: labels(<String>['Short', 'A noticeably longer label', 'Mid']),
            index: distribution.clamp(0, 2),
            onChanged: (int i) => setState(() => distribution = i),
            alignment: a,
            fitOverride: MorphTabsIndicatorFit.content,
            key: ValueKey<String>('tabs_lab_distribution_${a.name}'),
          ),
        ),
    ],
  );

  Widget scrollSection() => section(
    '7 · Scrollable bar',
    'The indicator lives in the scrolling content: no offset is applied twice. Selecting reveals the tab unless you are scrolling.',
    <Widget>[
      choices(<Widget>[
        choice('First', () => setState(() => scrolling = 0)),
        choice('Middle', () => setState(() => scrolling = 7)),
        choice('Last', () => setState(() => scrolling = 13)),
      ]),
      const SizedBox(height: 8),
      panel(
        bar(
          tabs: labels(<String>[
            for (var i = 0; i < 14; i++) 'Category ${i + 1}',
          ]),
          index: scrolling,
          onChanged: (int i) => setState(() => scrolling = i),
          scrollable: true,
          key: const ValueKey<String>('tabs_lab_scroll'),
        ),
      ),
    ],
  );

  Widget iconsSection() => section(
    '8 · Compact tabs with icons and badges',
    'The label leads; an optional icon sits beside it and the badge stays small next to its content.',
    <Widget>[
      panel(
        bar(
          variant: MorphTabsVariant.secondary,
          tabs: <MorphTab>[
            MorphTab(label: 'Overview', icon: Icon(FluentIcons.line.home)),
            MorphTab(
              label: 'Activity',
              icon: Icon(FluentIcons.line.alert),
              badgeCount: 3,
            ),
            MorphTab(
              label: 'Updates',
              icon: Icon(FluentIcons.line.mail),
              badgeDot: true,
            ),
          ],
          index: icons,
          onChanged: (int i) => setState(() => icons = i),
          fitOverride: MorphTabsIndicatorFit.content,
          alignment: MorphTabsAlignment.content,
          key: const ValueKey<String>('tabs_lab_icons'),
        ),
      ),
      panel(
        bar(
          tabs: const <MorphTab>[
            MorphTab(label: 'Overview'),
            MorphTab(label: 'Activity', badgeCount: 12),
            MorphTab(label: 'Updates', badgeLabel: 'New'),
          ],
          index: icons,
          onChanged: (int i) => setState(() => icons = i),
          fitOverride: MorphTabsIndicatorFit.content,
          alignment: MorphTabsAlignment.content,
        ),
      ),
    ],
  );

  Widget linkedSection() => section(
    '9 · Bar linked to real pages',
    'Swipe the pages: the indicator follows the same fractional progress. The selection callback fires when the dominant page changes, never per frame.',
    <Widget>[
      choices(<Widget>[
        choice('First → last', firstToLast),
        choice('Rapid changes', rapid),
        choice('Slow jump (swipe to interrupt)', slowTravel),
        choice('Label: ${longLabel ? 'long' : 'short'}', toggleLabel),
        choice('Badge on Activity: $badge', toggleBadge),
        choice('Add at end', addEnd),
        choice('Insert at start', addStart),
        choice('Remove selected', removeSelected),
      ]),
      const SizedBox(height: 8),
      panel(
        Column(
          children: <Widget>[
            bar(
              tabs: linkedTabs,
              index: linked.clamp(0, linkedTabs.length - 1),
              onChanged: (int i) => setState(() => linked = i),
              controller: linkedController,
              alignment: MorphTabsAlignment.content,
              key: const ValueKey<String>('tabs_lab_linked_bar'),
            ),
            SizedBox(
              height: 170,
              child: MorphTabsView(
                key: const ValueKey<String>('tabs_lab_linked_view'),
                selectedIndex: linked.clamp(0, linkedTabs.length - 1),
                onTabSelected: (int i) => setState(() {
                  callbacks++;
                  linked = i;
                }),
                controller: linkedController,
                duration: Duration(milliseconds: pageMs),
                children: <Widget>[
                  for (var i = 0; i < linkedTabs.length; i++)
                    Center(
                      child: Text(
                        'Page ${linkedTabs[i].label}\n← swipe →',
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      ValueListenableBuilder<MorphTabsPosition?>(
        valueListenable: linkedController.position,
        builder: (BuildContext context, MorphTabsPosition? p, Widget? _) => Text(
          'page position: ${p == null ? 'at rest' : p.value.toStringAsFixed(3)}'
          ' · selected: $linked · confirmed callbacks: $callbacks',
          key: const ValueKey<String>('tabs_lab_progress'),
        ),
      ),
    ],
  );

  Widget independentSection() => section(
    '10 · Independent bar controlled by the app',
    'No page view. A rejected request leaves the indicator on the confirmed selection.',
    <Widget>[
      choices(<Widget>[
        choice('Select 0', () => independentController.select(0)),
        choice('Select 4', () => independentController.select(4)),
        choice(
          'App rejects changes: $appRejects',
          () => setState(() => appRejects = !appRejects),
          selected: appRejects,
        ),
      ]),
      const SizedBox(height: 8),
      panel(
        bar(
          tabs: labels(<String>['Day', 'Week', 'Month', 'Year', 'All time']),
          index: independent,
          onChanged: (int i) {
            if (!appRejects) setState(() => independent = i);
          },
          controller: independentController,
          alignment: MorphTabsAlignment.content,
          key: const ValueKey<String>('tabs_lab_independent'),
        ),
      ),
      Text(
        'confirmed selection: ${<String>['Day', 'Week', 'Month', 'Year', 'All time'][independent]}',
      ),
    ],
  );
}
