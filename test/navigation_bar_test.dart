import 'package:flutter_test/flutter_test.dart';
import 'package:morph_expressive/components/navigation_bar/components/morph_nav_bar_destination_button.dart';
import 'package:morph_expressive/components/navigation_rail/components/morph_nav_selection_indicator.dart';
import 'package:morph_expressive/morph_components.dart';
import 'package:material_ui/material_ui.dart'
    show
        Align,
        Alignment,
        BoxDecoration,
        BuildContext,
        Color,
        DecoratedBox,
        Decoration,
        DefaultMaterialLocalizations,
        DefaultWidgetsLocalizations,
        LocalizationsDelegate,
        MaterialApp,
        Opacity,
        PageRouteBuilder,
        Rect,
        RouteSettings,
        Scaffold,
        SizedBox,
        StateSetter,
        StatefulBuilder,
        Transform,
        Widget,
        WidgetBuilder,
        WidgetsApp;

Widget _host(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  testWidgets(
    'MorphNavigationBar renders destinations and reports selection',
    _morphnavigationbarRendersDestinationsAndReportsSelection,
  );
  testWidgets(
    'MorphNavigationBar selection indicator scales in place',
    _morphnavigationbarSelectionIndicatorScalesInPlace,
  );
  testWidgets(
    'MorphNavigationBar works under a WidgetsApp with the Material delegate',
    _morphnavigationbarWorksUnderAWidgetsappWithTheMaterial,
  );
  testWidgets(
    'MorphNavigationBar autoLayout uses wide at wide breakpoint',
    _morphnavigationbarAutolayoutUsesWideAtWideBreakpoint,
  );
  testWidgets(
    'MorphNavigationBar forced wide aligns destination group',
    _morphnavigationbarForcedWideAlignsDestinationGroup,
  );
  testWidgets(
    'MorphNavigationBar supports icon-only and label-only destinations',
    _morphnavigationbarSupportsIconOnlyAndLabelOnlyDestinations,
  );
  testWidgets(
    'MorphNavigationBar wide chips use fixed equal width',
    _morphnavigationbarWideChipsUseFixedEqualWidth,
  );
  testWidgets(
    'MorphNavigationBar respects custom wideBreakpoint and width',
    _morphnavigationbarRespectsCustomWidebreakpointAndWidth,
  );
  testWidgets(
    'MorphNavigationBar pill remeasures when alignment changes',
    _morphnavigationbarPillRemeasuresWhenAlignmentChanges,
  );
}

Future<void> _morphnavigationbarRendersDestinationsAndReportsSelection(
  WidgetTester tester,
) async {
  var selected = -1;
  await tester.pumpWidget(
    _host(
      Align(
        alignment: Alignment.bottomCenter,
        child: MorphNavigationBar(
          onDestinationSelected: (i) => selected = i,
          destinations: const <MorphNavigationBarDestination>[
            MorphNavigationBarDestination(icon: MorphIcons.home, label: 'Home'),
            MorphNavigationBarDestination(
              icon: MorphIcons.search,
              label: 'Search',
            ),
          ],
        ),
      ),
    ),
  );

  expect(find.text('Home'), findsOneWidget);
  await tester.tap(find.text('Search'));
  expect(selected, 1);
}

double _indicatorScaleX(
  WidgetTester tester,
  MorphSelectionIndicator indicator,
) {
  final Transform transform = tester.widget<Transform>(
    find.descendant(
      of: find.byWidget(indicator),
      matching: find.byType(Transform),
    ),
  );
  return transform.transform.storage[0];
}

double _indicatorOpacity(
  WidgetTester tester,
  MorphSelectionIndicator indicator,
) {
  final Opacity opacity = tester.widget<Opacity>(
    find.descendant(
      of: find.byWidget(indicator),
      matching: find.byType(Opacity),
    ),
  );
  return opacity.opacity;
}

Future<void> _morphnavigationbarSelectionIndicatorScalesInPlace(
  WidgetTester tester,
) async {
  var index = 0;
  await tester.pumpWidget(
    _host(
      StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return MorphNavigationBar(
            selectedIndex: index,
            onDestinationSelected: (int i) => setState(() => index = i),
            destinations: const <MorphNavigationBarDestination>[
              MorphNavigationBarDestination(
                icon: MorphIcons.home,
                label: 'Home',
              ),
              MorphNavigationBarDestination(
                icon: MorphIcons.search,
                label: 'Search',
              ),
            ],
          );
        },
      ),
    ),
  );
  await tester.pump();

  List<MorphSelectionIndicator> indicators = tester
      .widgetList<MorphSelectionIndicator>(find.byType(MorphSelectionIndicator))
      .toList();
  expect(indicators, hasLength(2));
  expect(_indicatorScaleX(tester, indicators[0]), 1);
  expect(_indicatorOpacity(tester, indicators[0]), 1);
  expect(_indicatorScaleX(tester, indicators[1]), closeTo(0.64, 0.001));
  expect(_indicatorOpacity(tester, indicators[1]), 0);

  await tester.tap(find.text('Search'));
  await tester.pump();

  indicators = tester
      .widgetList<MorphSelectionIndicator>(find.byType(MorphSelectionIndicator))
      .toList();
  // La entrada anima alfa y escala; no muestra de golpe la pildora.
  final reduced = MorphMotion.reduceMotionOf(
    tester.element(find.byType(MorphNavigationBar)),
  );
  expect(
    _indicatorOpacity(tester, indicators[1]),
    reduced ? equals(1) : lessThan(1),
  );
  expect(_indicatorScaleX(tester, indicators[1]), greaterThanOrEqualTo(0.64));

  await tester.pump(const Duration(milliseconds: 32));

  indicators = tester
      .widgetList<MorphSelectionIndicator>(find.byType(MorphSelectionIndicator))
      .toList();
  final double incoming = _indicatorScaleX(tester, indicators[1]);
  expect(incoming, greaterThan(0.64));
  expect(incoming, reduced ? equals(1) : lessThan(1));
  expect(_indicatorOpacity(tester, indicators[1]), greaterThan(0));
  expect(
    _indicatorOpacity(tester, indicators[1]),
    reduced ? equals(1) : lessThan(1),
  );
  expect(
    _indicatorOpacity(tester, indicators[0]),
    reduced ? equals(0) : lessThan(1),
  );
}

Future<void> _morphnavigationbarWorksUnderAWidgetsappWithTheMaterial(
  WidgetTester tester,
) async {
  // Mirrors the example app: no MaterialApp, just WidgetsApp + the Material
  // localizations delegate so the wrapped Material widgets can resolve.
  await tester.pumpWidget(
    WidgetsApp(
      color: const Color(0xFF6750A4),
      pageRouteBuilder: <T>(RouteSettings settings, WidgetBuilder builder) {
        return PageRouteBuilder<T>(
          settings: settings,
          pageBuilder: (context, _, _) => builder(context),
        );
      },
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        DefaultMaterialLocalizations.delegate,
        DefaultWidgetsLocalizations.delegate,
      ],
      home: const Align(
        alignment: Alignment.bottomCenter,
        child: MorphNavigationBar(
          destinations: <MorphNavigationBarDestination>[
            MorphNavigationBarDestination(icon: MorphIcons.home, label: 'Home'),
            MorphNavigationBarDestination(
              icon: MorphIcons.search,
              label: 'Search',
            ),
          ],
        ),
      ),
    ),
  );

  expect(tester.takeException(), isNull);
  expect(find.text('Home'), findsOneWidget);
}

Future<void> _morphnavigationbarAutolayoutUsesWideAtWideBreakpoint(
  WidgetTester tester,
) async {
  const destinations = <MorphNavigationBarDestination>[
    MorphNavigationBarDestination(icon: MorphIcons.home, label: 'Home'),
    MorphNavigationBarDestination(icon: MorphIcons.search, label: 'Search'),
  ];
  const double breakpoint = MorphNavBarConstants.mediumWindowBreakpoint;

  await tester.pumpWidget(
    _host(
      const SizedBox(
        width: breakpoint,
        child: MorphNavigationBar(safeArea: false, destinations: destinations),
      ),
    ),
  );
  await tester.pump();

  expect(find.text('Home'), findsOneWidget);
  expect(find.text('Search'), findsOneWidget);
  final double wideWidth = tester
      .getSize(find.byType(MorphNavBarDestinationButton).first)
      .width;
  expect(wideWidth, lessThan(breakpoint / 2));

  await tester.pumpWidget(
    _host(
      const SizedBox(
        width: breakpoint - 1,
        child: MorphNavigationBar(safeArea: false, destinations: destinations),
      ),
    ),
  );
  await tester.pump();
  expect(
    tester.getSize(find.byType(MorphNavBarDestinationButton).first).width,
    closeTo((breakpoint - 1) / destinations.length, 1),
  );
}

Future<void> _morphnavigationbarForcedWideAlignsDestinationGroup(
  WidgetTester tester,
) async {
  await tester.pumpWidget(
    _host(
      const SizedBox(
        width: 800,
        child: MorphNavigationBar(
          autoLayout: false,
          layout: MorphNavBarLayout.wide,
          alignment: MorphNavBarAlignment.end,
          safeArea: false,
          destinations: <MorphNavigationBarDestination>[
            MorphNavigationBarDestination(icon: MorphIcons.home, label: 'Home'),
            MorphNavigationBarDestination(
              icon: MorphIcons.search,
              label: 'Search',
            ),
          ],
        ),
      ),
    ),
  );
  await tester.pump();

  final Rect bar = tester.getRect(find.byType(MorphNavigationBar));
  final Rect search = tester.getRect(
    find.byType(MorphNavBarDestinationButton).last,
  );
  expect(
    search.right,
    closeTo(bar.right - MorphNavigationBarTheme.defaults.wideEdgePadding, 1),
  );
  expect(search.left, greaterThan(bar.left + 100));
}

Future<void> _morphnavigationbarSupportsIconOnlyAndLabelOnlyDestinations(
  WidgetTester tester,
) async {
  var selected = -1;
  await tester.pumpWidget(
    _host(
      Align(
        alignment: Alignment.bottomCenter,
        child: MorphNavigationBar(
          autoLayout: false,
          layout: MorphNavBarLayout.wide,
          safeArea: false,
          onDestinationSelected: (int i) => selected = i,
          destinations: const <MorphNavigationBarDestination>[
            MorphNavigationBarDestination(icon: MorphIcons.home),
            MorphNavigationBarDestination(label: 'Browse'),
            MorphNavigationBarDestination(
              icon: MorphIcons.radio,
              label: 'Radio',
            ),
          ],
        ),
      ),
    ),
  );
  await tester.pump();

  expect(find.byIcon(MorphIcons.home), findsOneWidget);
  expect(find.text('Browse'), findsOneWidget);
  expect(find.text('Radio'), findsOneWidget);
  await tester.tap(find.text('Browse'));
  expect(selected, 1);
}

Future<void> _morphnavigationbarWideChipsUseFixedEqualWidth(
  WidgetTester tester,
) async {
  await tester.pumpWidget(
    _host(
      const SizedBox(
        width: 800,
        child: MorphNavigationBar(
          autoLayout: false,
          layout: MorphNavBarLayout.wide,
          safeArea: false,
          destinations: <MorphNavigationBarDestination>[
            MorphNavigationBarDestination(icon: MorphIcons.home, label: 'Home'),
            MorphNavigationBarDestination(
              icon: MorphIcons.search,
              label: 'Browse',
            ),
          ],
        ),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(MorphNavBarConstants.layoutSettleDuration);

  final Rect home = tester.getRect(
    find.byType(MorphNavBarDestinationButton).at(0),
  );
  final Rect browse = tester.getRect(
    find.byType(MorphNavBarDestinationButton).at(1),
  );
  expect(home.width, closeTo(browse.width, 1));
  expect(
    browse.center.dx - home.center.dx,
    closeTo(home.width + MorphNavigationBarTheme.defaults.wideItemGap, 2),
  );
}

Future<void> _morphnavigationbarRespectsCustomWidebreakpointAndWidth(
  WidgetTester tester,
) async {
  const double customWidth = 96;
  const double customBreakpoint = 500;

  await tester.pumpWidget(
    _host(
      const SizedBox(
        width: customBreakpoint,
        child: MorphNavigationBar(
          wideBreakpoint: customBreakpoint,
          wideDestinationWidth: customWidth,
          safeArea: false,
          destinations: <MorphNavigationBarDestination>[
            MorphNavigationBarDestination(icon: MorphIcons.home, label: 'Home'),
            MorphNavigationBarDestination(
              icon: MorphIcons.search,
              label: 'Search',
            ),
          ],
        ),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(MorphNavBarConstants.layoutSettleDuration);

  final Rect home = tester.getRect(
    find.byType(MorphNavBarDestinationButton).at(0),
  );
  final Rect search = tester.getRect(
    find.byType(MorphNavBarDestinationButton).at(1),
  );
  expect(home.width, closeTo(customWidth, 1));
  expect(
    search.center.dx - home.center.dx,
    closeTo(customWidth + MorphNavigationBarTheme.defaults.wideItemGap, 2),
  );

  await tester.pumpWidget(
    _host(
      const SizedBox(
        width: customBreakpoint - 1,
        child: MorphNavigationBar(
          wideBreakpoint: customBreakpoint,
          wideDestinationWidth: customWidth,
          safeArea: false,
          destinations: <MorphNavigationBarDestination>[
            MorphNavigationBarDestination(icon: MorphIcons.home, label: 'Home'),
            MorphNavigationBarDestination(
              icon: MorphIcons.search,
              label: 'Search',
            ),
          ],
        ),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(MorphNavBarConstants.layoutSettleDuration);
  // Compact: equal Expanded cells across almost the full bar.
  final Rect homeCompact = tester.getRect(find.text('Home'));
  final Rect searchCompact = tester.getRect(find.text('Search'));
  expect(
    searchCompact.center.dx - homeCompact.center.dx,
    greaterThan(customWidth + 20),
  );
}

Future<void> _morphnavigationbarPillRemeasuresWhenAlignmentChanges(
  WidgetTester tester,
) async {
  const destinations = <MorphNavigationBarDestination>[
    MorphNavigationBarDestination(icon: MorphIcons.home, label: 'Home'),
    MorphNavigationBarDestination(icon: MorphIcons.search, label: 'Search'),
  ];

  await tester.pumpWidget(
    _host(
      const SizedBox(
        width: 800,
        child: MorphNavigationBar(
          autoLayout: false,
          layout: MorphNavBarLayout.wide,
          alignment: MorphNavBarAlignment.start,
          safeArea: false,
          destinations: destinations,
        ),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(MorphNavBarConstants.layoutSettleDuration);
  await tester.pump(const Duration(milliseconds: 50));

  final double homeLeftStart = tester.getTopLeft(find.text('Home')).dx;

  await tester.pumpWidget(
    _host(
      const SizedBox(
        width: 800,
        child: MorphNavigationBar(
          autoLayout: false,
          layout: MorphNavBarLayout.wide,
          alignment: MorphNavBarAlignment.end,
          safeArea: false,
          destinations: destinations,
        ),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(MorphNavBarConstants.layoutSettleDuration);
  await tester.pump(const Duration(milliseconds: 50));

  final double homeLeftEnd = tester.getTopLeft(find.text('Home')).dx;
  expect(homeLeftEnd, greaterThan(homeLeftStart + 50));

  // Resting pill should sit with the selected destination after alignment change.
  final Iterable<DecoratedBox> boxes = tester.widgetList<DecoratedBox>(
    find.descendant(
      of: find.byType(MorphNavigationBar),
      matching: find.byType(DecoratedBox),
    ),
  );
  final DecoratedBox pill = boxes.firstWhere((DecoratedBox box) {
    final Decoration d = box.decoration;
    return d is BoxDecoration && d.color != null && d.color!.a > 0;
  });
  final Rect pillRect = tester.getRect(find.byWidget(pill));
  final Rect homeRect = tester.getRect(find.text('Home'));
  expect(pillRect.left, lessThan(homeRect.left + 8));
  expect(pillRect.right, greaterThan(homeRect.right - 8));
}
