import 'package:flutter_test/flutter_test.dart';
import 'package:morph_expressive/components/navigation_rail/components/morph_nav_selection_indicator.dart';
import 'package:morph_expressive/morph_components.dart';
import 'package:material_ui/material_ui.dart'
    show
        AnimatedContainer,
        BoxDecoration,
        BuildContext,
        Builder,
        Color,
        DecoratedBox,
        EdgeInsets,
        Icon,
        Key,
        ListView,
        MaterialApp,
        MediaQuery,
        Offset,
        Rect,
        Scaffold,
        Scrollable,
        ShapeDecoration,
        SizedBox,
        StatefulBuilder,
        ValueKey,
        Widget;

Widget _host(Widget child) => MaterialApp(home: Scaffold(body: child));

Finder _tooltip(String message) {
  return find.byWidgetPredicate(
    (Widget widget) => widget is MorphTooltip && widget.message == message,
  );
}

bool _railHasSelectionFill(WidgetTester tester) {
  final Finder indicator = find.descendant(
    of: find.byType(MorphNavigationRail),
    matching: find.byWidgetPredicate(
      (Widget widget) => widget is MorphSelectionIndicator && widget.selected,
    ),
  );
  return tester
      .widgetList<DecoratedBox>(
        find.descendant(of: indicator, matching: find.byType(DecoratedBox)),
      )
      .any((DecoratedBox box) {
        final Color? color = switch (box.decoration) {
          BoxDecoration(:final Color? color) => color,
          ShapeDecoration(:final Color? color) => color,
          _ => null,
        };
        return color != null && color.a > 0;
      });
}

void main() {
  testWidgets(
    'MorphIconButton renders its icon and fires onPressed',
    _morphiconbuttonRendersItsIconAndFiresOnpressed,
  );
  testWidgets(
    'MorphNavigationRail renders section destinations',
    _morphnavigationrailRendersSectionDestinations,
  );
  testWidgets(
    'MorphNavigationRail supports custom expand and collapse tooltips',
    _morphnavigationrailSupportsCustomExpandAndCollapseTooltips,
  );
  testWidgets(
    'MorphNavigationRail FAB slot supports custom elevation',
    _morphnavigationrailFabSlotSupportsCustomElevation,
  );
  testWidgets(
    'MorphNavigationRail indicator scrolls with its destination',
    _morphnavigationrailRestingIndicatorTracksSelectionWhileS,
  );
  testWidgets(
    'MorphNavigationRail indicator stays on selection after MediaQuery churn',
    _morphnavigationrailIndicatorStaysOnSelectionAfterMediaqu,
  );
  testWidgets(
    'nav selection content is centered and the collapsed rail pill matches its theme',
    _navSelectionContentIsCentered,
  );
  testWidgets(
    'MorphNavigationRail expand does not overflow the destination row',
    _morphnavigationrailExpandDoesNotOverflow,
  );
  testWidgets(
    'MorphSlider reports value changes',
    _morphsliderReportsValueChanges,
  );
  testWidgets(
    'MorphSlider renders without a Scaffold/Material ancestor',
    _morphsliderRendersWithoutAScaffoldMaterialAncestor,
  );
}

Future<void> _morphiconbuttonRendersItsIconAndFiresOnpressed(
  WidgetTester tester,
) async {
  var taps = 0;
  await tester.pumpWidget(
    _host(
      MorphIconButton(
        variant: MorphIconButtonVariant.standard,
        icon: const Icon(MorphIcons.menu),
        onPressed: () => taps++,
      ),
    ),
  );

  expect(find.byIcon(MorphIcons.menu), findsOneWidget);
  await tester.tap(find.byType(MorphIconButton));
  expect(taps, 1);
}

Future<void> _morphnavigationrailRendersSectionDestinations(
  WidgetTester tester,
) async {
  await tester.pumpWidget(
    _host(
      MorphNavigationRail(
        selectedIndex: 0,
        onDestinationSelected: (_) {},
        sections: const <MorphNavigationRailSection>[
          MorphNavigationRailSection(
            destinations: <MorphNavigationRailDestination>[
              MorphNavigationRailDestination(
                icon: Icon(MorphIcons.inbox),
                label: 'Inbox',
              ),
              MorphNavigationRailDestination(
                icon: Icon(MorphIcons.send),
                label: 'Sent',
              ),
            ],
          ),
        ],
      ),
    ),
  );
  await tester.pump();

  expect(find.text('Inbox'), findsWidgets);
  expect(find.byIcon(MorphIcons.inbox), findsOneWidget);
}

Future<void> _morphnavigationrailSupportsCustomExpandAndCollapseTooltips(
  WidgetTester tester,
) async {
  Widget buildRail(MorphNavigationRailType type, Key key) =>
      MorphNavigationRail(
        key: key,
        type: type,
        selectedIndex: 0,
        onDestinationSelected: (_) {},
        sections: const <MorphNavigationRailSection>[
          MorphNavigationRailSection(
            destinations: <MorphNavigationRailDestination>[
              MorphNavigationRailDestination(
                icon: Icon(MorphIcons.inbox),
                label: 'Inbox',
              ),
            ],
          ),
        ],
      );

  await tester.pumpWidget(
    _host(
      buildRail(MorphNavigationRailType.collapsed, const ValueKey('collapsed')),
    ),
  );
  expect(_tooltip('Expand'), findsOneWidget);

  await tester.pumpWidget(
    _host(
      buildRail(MorphNavigationRailType.expanded, const ValueKey('expanded')),
    ),
  );
  await tester.pump();
  expect(_tooltip('Collapse'), findsOneWidget);
}

Future<void> _morphnavigationrailFabSlotSupportsCustomElevation(
  WidgetTester tester,
) async {
  await tester.pumpWidget(
    _host(
      MorphNavigationRail(
        type: MorphNavigationRailType.collapsed,
        selectedIndex: 0,
        onDestinationSelected: (_) {},
        fab: const MorphNavigationRailFabSlot(
          icon: Icon(MorphIcons.add),
          label: 'Create',
          elevation: 0,
          hoverElevation: 0,
        ),
        sections: const <MorphNavigationRailSection>[
          MorphNavigationRailSection(
            destinations: <MorphNavigationRailDestination>[
              MorphNavigationRailDestination(
                icon: Icon(MorphIcons.inbox),
                label: 'Inbox',
              ),
            ],
          ),
        ],
      ),
    ),
  );
  await tester.pump();

  final fabContainer = tester.widget<AnimatedContainer>(
    find.descendant(
      of: find.byType(MorphFab),
      matching: find.byType(AnimatedContainer),
    ),
  );
  final decoration = fabContainer.decoration;

  expect(decoration, isA<BoxDecoration>());
  expect((decoration! as BoxDecoration).boxShadow, isEmpty);
}

Future<void> _morphnavigationrailRestingIndicatorTracksSelectionWhileS(
  WidgetTester tester,
) async {
  final destinations = List<MorphNavigationRailDestination>.generate(
    20,
    (int i) => MorphNavigationRailDestination(
      icon: const Icon(MorphIcons.menu),
      label: 'Item $i',
    ),
  );

  await tester.pumpWidget(
    _host(
      SizedBox(
        height: 240,
        child: MorphNavigationRail(
          type: MorphNavigationRailType.alwaysExpand,
          selectedIndex: 0,
          onDestinationSelected: (_) {},
          sections: <MorphNavigationRailSection>[
            MorphNavigationRailSection(destinations: destinations),
          ],
        ),
      ),
    ),
  );
  await tester.pump();
  await tester.pump();

  final Finder selectedLabel = find.text('Item 0');
  final double before = tester.getTopLeft(selectedLabel).dy;

  await tester.drag(find.byType(Scrollable), const Offset(0, -40));
  await tester.pump();
  await tester.pump();

  // The indicator is part of the destination, so it scrolls with the row.
  expect(tester.getTopLeft(selectedLabel).dy, lessThan(before));
  expect(_railHasSelectionFill(tester), isTrue);
}

Future<void> _morphnavigationrailIndicatorStaysOnSelectionAfterMediaqu(
  WidgetTester tester,
) async {
  Widget buildRail({required EdgeInsets viewInsets}) {
    return MaterialApp(
      home: Builder(
        builder: (BuildContext context) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(viewInsets: viewInsets),
            child: Scaffold(
              body: MorphNavigationRail(
                type: MorphNavigationRailType.alwaysExpand,
                selectedIndex: 2,
                onDestinationSelected: (_) {},
                sections: const <MorphNavigationRailSection>[
                  MorphNavigationRailSection(
                    destinations: <MorphNavigationRailDestination>[
                      MorphNavigationRailDestination(
                        icon: Icon(MorphIcons.inbox),
                        label: 'Inbox',
                      ),
                      MorphNavigationRailDestination(
                        icon: Icon(MorphIcons.send),
                        label: 'Sent',
                      ),
                      MorphNavigationRailDestination(
                        icon: Icon(MorphIcons.favorite),
                        label: 'Starred',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  await tester.pumpWidget(buildRail(viewInsets: EdgeInsets.zero));
  await tester.pump();
  await tester.pump();
  await tester.pump(MorphNavigationRailLayout.expandDuration);

  final double starredY = tester.getTopLeft(find.text('Starred')).dy;

  // Simulate fullscreen search keyboard / route MediaQuery settle.
  await tester.pumpWidget(
    buildRail(viewInsets: const EdgeInsets.only(bottom: 300)),
  );
  await tester.pump();
  await tester.pump();
  await tester.pump(MorphNavigationRailLayout.expandDuration);
  await tester.pumpWidget(buildRail(viewInsets: EdgeInsets.zero));
  await tester.pump();
  await tester.pump();
  await tester.pump(MorphNavigationRailLayout.expandDuration);
  await tester.pump(const Duration(milliseconds: 16));

  expect(tester.getTopLeft(find.text('Starred')).dy, closeTo(starredY, 1));
  expect(_railHasSelectionFill(tester), isTrue);
}

void _ignoreIndex(int index) {}

Rect _selectedIndicatorRect(WidgetTester tester, Finder scope) {
  final Finder indicator = find.descendant(
    of: scope,
    matching: find.byWidgetPredicate(
      (Widget widget) => widget is MorphSelectionIndicator && widget.selected,
    ),
  );
  final Finder fill = find.descendant(
    of: indicator,
    matching: find.byType(DecoratedBox),
  );
  return tester.getRect(fill);
}

Future<void> _navSelectionContentIsCentered(WidgetTester tester) async {
  const destinations = <MorphNavigationRailDestination>[
    MorphNavigationRailDestination(
      icon: Icon(MorphIcons.inbox),
      label: 'Inbox',
    ),
    MorphNavigationRailDestination(icon: Icon(MorphIcons.send), label: 'Sent'),
  ];

  await tester.pumpWidget(
    _host(
      const MorphNavigationRail(
        type: MorphNavigationRailType.alwaysExpand,
        selectedIndex: 0,
        onDestinationSelected: _ignoreIndex,
        sections: <MorphNavigationRailSection>[
          MorphNavigationRailSection(destinations: destinations),
        ],
      ),
    ),
  );
  await tester.pump();
  final Rect railLabel = tester.getRect(find.text('Inbox'));
  final Rect railPill = _selectedIndicatorRect(
    tester,
    find.byType(MorphNavigationRail),
  );
  expect(railLabel.center.dy, closeTo(railPill.center.dy, 1));

  await tester.pumpWidget(
    _host(
      MorphNavigationDrawer(
        selectedIndex: 0,
        onDestinationSelected: _ignoreIndex,
        destinations: const <MorphNavigationDestination>[
          MorphNavigationDestination(
            icon: Icon(MorphIcons.inbox),
            label: 'Inbox',
          ),
          MorphNavigationDestination(
            icon: Icon(MorphIcons.send),
            label: 'Sent',
          ),
        ],
      ),
    ),
  );
  await tester.pump();
  final Rect drawerLabel = tester.getRect(find.text('Inbox'));
  final Rect drawerPill = _selectedIndicatorRect(
    tester,
    find.byType(MorphNavigationDrawer),
  );
  expect(drawerLabel.center.dy, closeTo(drawerPill.center.dy, 1));

  await tester.pumpWidget(
    _host(
      const MorphNavigationRail(
        type: MorphNavigationRailType.alwaysCollapse,
        selectedIndex: 0,
        onDestinationSelected: _ignoreIndex,
        sections: <MorphNavigationRailSection>[
          MorphNavigationRailSection(destinations: destinations),
        ],
      ),
    ),
  );
  await tester.pump();
  final Rect collapsedPill = _selectedIndicatorRect(
    tester,
    find.byType(MorphNavigationRail),
  );
  final MorphNavigationRailTheme railTheme = MorphTheme.of(
    tester.element(find.byType(MorphNavigationRail)),
  ).navigationRailTheme;
  expect(collapsedPill.width, railTheme.verticalIndicatorWidth);
  expect(collapsedPill.height, railTheme.verticalIndicatorHeight);
}

Future<void> _morphnavigationrailExpandDoesNotOverflow(
  WidgetTester tester,
) async {
  const sections = <MorphNavigationRailSection>[
    MorphNavigationRailSection(
      destinations: <MorphNavigationRailDestination>[
        MorphNavigationRailDestination(
          icon: Icon(MorphIcons.home),
          label: 'Home',
        ),
        MorphNavigationRailDestination(
          icon: Icon(MorphIcons.calendar_today),
          label: 'Agenda',
          badgeCount: 3,
        ),
      ],
    ),
  ];
  const fab = MorphNavigationRailFabSlot(
    icon: Icon(MorphIcons.add),
    label: 'Compose',
  );

  Widget rail(MorphNavigationRailType type) {
    return MorphNavigationRail(
      type: type,
      selectedIndex: 1,
      onDestinationSelected: _ignoreIndex,
      sections: sections,
      fab: fab,
    );
  }

  await tester.pumpWidget(_host(rail(MorphNavigationRailType.collapsed)));
  await tester.pump();
  await tester.tap(find.byIcon(MorphIcons.menu));
  await tester.pump();
  expect(tester.takeException(), isNull);

  const step = Duration(milliseconds: 40);
  var elapsed = Duration.zero;
  while (elapsed < MorphNavigationRailLayout.expandDuration) {
    await tester.pump(step);
    elapsed += step;
    expect(tester.takeException(), isNull);
  }
  await tester.pump(MorphNavigationRailLayout.expandDuration);
  expect(tester.takeException(), isNull);
  expect(find.text('Agenda'), findsOneWidget);
  expect(find.text('Compose'), findsOneWidget);
}

Future<void> _morphsliderReportsValueChanges(WidgetTester tester) async {
  var value = 0.5;
  await tester.pumpWidget(
    _host(
      StatefulBuilder(
        builder: (context, setState) {
          return MorphSlider(
            value: value,
            onChanged: (v) => setState(() => value = v),
          );
        },
      ),
    ),
  );

  final Rect rect = tester.getRect(find.byType(MorphSlider));
  await tester.tapAt(Offset(rect.left + rect.width * 0.2, rect.center.dy));
  expect(value, isNot(0.5));
}

Future<void> _morphsliderRendersWithoutAScaffoldMaterialAncestor(
  WidgetTester tester,
) async {
  // Components placed directly under a ListView with no Material ancestor
  // must not throw.
  await tester.pumpWidget(
    MaterialApp(
      home: ListView(
        children: <Widget>[MorphSlider(value: 0.5, onChanged: (_) {})],
      ),
    ),
  );

  expect(tester.takeException(), isNull);
  expect(find.byType(MorphSlider), findsOneWidget);
}
