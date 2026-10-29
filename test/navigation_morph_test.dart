import 'dart:async';
import 'dart:ui' show PointerDeviceKind;

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart'
    show
        Align,
        Alignment,
        AlwaysScrollableScrollPhysics,
        BackdropFilter,
        Color,
        DecoratedBox,
        BoxDecoration,
        EdgeInsets,
        Icon,
        ListView,
        MaterialApp,
        MediaQuery,
        Offset,
        Row,
        Scaffold,
        ScrollController,
        SizedBox,
        StateSetter,
        StatefulBuilder,
        Text,
        TextDirection,
        TextScaler,
        Widget,
        Directionality;
import 'package:morph_expressive/morph_expressive.dart';
import 'package:morph_expressive/components/navigation_rail/components/morph_sliding_indicator.dart';

const destinations = [
  MorphNavigationBarDestination(icon: MorphIcons.home, label: 'Home'),
  MorphNavigationBarDestination(icon: MorphIcons.search, label: 'Search'),
  MorphNavigationBarDestination(icon: MorphIcons.mail, label: 'Inbox'),
];

Widget app(
  Widget child, {
  TextDirection direction = TextDirection.ltr,
  bool reduced = false,
}) => MaterialApp(
  home: Scaffold(
    body: Directionality(
      textDirection: direction,
      child: MorphMotionScope(reduceMotion: reduced, child: child),
    ),
  ),
);

RenderMorphSlidingIndicator indicator(WidgetTester tester) =>
    tester.renderObject<RenderMorphSlidingIndicator>(
      find.byType(MorphSlidingIndicator).first,
    );

bool reduced(WidgetTester tester) => MorphMotion.reduceMotionOf(
  tester.element(find.byType(MorphSlidingIndicator).first),
);

void main() {
  testWidgets('named bottom bar variants retain their distinct contracts', (
    tester,
  ) async {
    const expressive = MorphNavigationBar.expressive(
      destinations: destinations,
    );
    const morph = MorphNavigationBar.morph(destinations: destinations);
    const standard = MorphNavigationBar(destinations: destinations);

    expect(expressive.motion, MorphNavigationMotion.morph);
    expect(expressive.labelBehavior, MorphNavBarLabelBehavior.alwaysShow);
    expect(expressive.autoLayout, isTrue);
    expect(expressive.iconSize, isNull);
    expect(expressive.unselectedIconScale, 1.0);
    expect(expressive.size, MorphNavBarSize.small);

    expect(morph.motion, MorphNavigationMotion.morph);
    expect(morph.labelBehavior, MorphNavBarLabelBehavior.onlySelected);
    expect(morph.autoLayout, isFalse);
    expect(morph.iconSize, 32);
    expect(morph.unselectedIconScale, 1.0);
    expect(morph.topIndicatorWidth, 40);
    expect(morph.size, MorphNavBarSize.small);
    expect(standard.motion, MorphNavigationMotion.standard);
    expect(standard.unselectedIconScale, 1.0);
    expect(standard.size, MorphNavBarSize.medium);

    await tester.pumpWidget(
      app(
        const MorphNavigationBar.morph(
          destinations: destinations,
          safeArea: false,
        ),
      ),
    );
    expect(indicator(tester).indicatorRect!.width, closeTo(40, 0.01));
    // The top dash and active icon have breathing room in the 76dp Morph bar.
    final dash = find.byType(MorphIndicatorTarget).first;
    expect(
      tester.getTopLeft(dash).dy -
          tester.getTopLeft(find.byType(MorphNavigationBar)).dy,
      closeTo(3, 0.01),
    );
    expect(
      tester.getSize(find.byType(MorphNavigationBar)).height,
      closeTo(76, 0.01),
    );
    final selectedIcon = find.byIcon(MorphIcons.home);
    expect(selectedIcon, findsOneWidget);
    expect(
      tester.getTopLeft(selectedIcon).dy - tester.getBottomLeft(dash).dy,
      greaterThanOrEqualTo(6),
    );
    expect(tester.takeException(), isNull);

    // The medium Morph bar retains its pre-existing minimum 80dp sizing
    // and keeps the dash clear of the selected icon.
    await tester.pumpWidget(
      app(
        const MorphNavigationBar.morph(
          destinations: destinations,
          size: MorphNavBarSize.medium,
          safeArea: false,
        ),
      ),
    );
    expect(
      tester.getSize(find.byType(MorphNavigationBar)).height,
      greaterThanOrEqualTo(80),
    );
    expect(
      tester.getTopLeft(find.byIcon(MorphIcons.home)).dy -
          tester.getBottomLeft(find.byType(MorphIndicatorTarget).first).dy,
      greaterThanOrEqualTo(6),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'Morph inactive icons stay centered while active dash keeps clearance',
    (tester) async {
      var selectedIndex = 0;
      late StateSetter update;
      await tester.pumpWidget(
        app(
          StatefulBuilder(
            builder: (context, setState) {
              update = setState;
              return MorphNavigationBar.morph(
                destinations: destinations,
                selectedIndex: selectedIndex,
                safeArea: false,
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      double barCenterY() =>
          tester.getCenter(find.byType(MorphNavigationBar)).dy;

      for (final icon in [MorphIcons.search, MorphIcons.mail]) {
        expect(
          tester.getCenter(find.byIcon(icon)).dy,
          closeTo(barCenterY(), 0.01),
        );
      }

      update(() => selectedIndex = 2);
      await tester.pumpAndSettle();

      for (final icon in [MorphIcons.home, MorphIcons.search]) {
        expect(
          tester.getCenter(find.byIcon(icon)).dy,
          closeTo(barCenterY(), 0.01),
        );
      }
      final selectedIcon = find.byIcon(MorphIcons.mail);
      final dash = find.byType(MorphIndicatorTarget).last;
      expect(
        tester.getTopLeft(selectedIcon).dy - tester.getBottomLeft(dash).dy,
        greaterThanOrEqualTo(6),
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('icon size and inactive scale are independently configurable', (
    tester,
  ) async {
    for (final makeBar in <Widget Function(int, void Function(int))>[
      (index, onSelected) => MorphNavigationBar.morph(
        destinations: destinations,
        iconSize: 30,
        unselectedIconScale: 0.9,
        selectedIndex: index,
        onDestinationSelected: onSelected,
        safeArea: false,
      ),
      (index, onSelected) => MorphNavigationBar.expressive(
        destinations: destinations,
        iconSize: 30,
        unselectedIconScale: 0.9,
        selectedIndex: index,
        onDestinationSelected: onSelected,
        safeArea: false,
      ),
      (index, onSelected) => MorphNavigationBar(
        destinations: destinations,
        iconSize: 30,
        unselectedIconScale: 0.9,
        selectedIndex: index,
        onDestinationSelected: onSelected,
        safeArea: false,
      ),
    ]) {
      var index = 0;
      late StateSetter update;
      await tester.pumpWidget(
        app(
          StatefulBuilder(
            builder: (context, setState) {
              update = setState;
              return makeBar(index, (value) => setState(() => index = value));
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Compare painted geometry, not layout: Transform.scale intentionally
      // keeps the tappable destination and Icon widget's layout unchanged.
      expect(
        tester.getRect(find.byIcon(MorphIcons.home)).width,
        closeTo(30, 0.2),
      );
      expect(
        tester.getRect(find.byIcon(MorphIcons.search)).width,
        closeTo(27, 0.2),
      );

      update(() => index = 1);
      await tester.pump();
      await tester.pumpAndSettle();
      expect(
        tester.getRect(find.byIcon(MorphIcons.home)).width,
        closeTo(27, 0.2),
      );
      expect(
        tester.getRect(find.byIcon(MorphIcons.search)).width,
        closeTo(30, 0.2),
      );
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('scale 1.0 preserves equal icon sizes', (tester) async {
    await tester.pumpWidget(
      app(
        const MorphNavigationBar.morph(
          destinations: destinations,
          iconSize: 30,
          unselectedIconScale: 1.0,
          safeArea: false,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      tester.getRect(find.byIcon(MorphIcons.home)).width,
      closeTo(30, 0.2),
    );
    expect(
      tester.getRect(find.byIcon(MorphIcons.search)).width,
      closeTo(30, 0.2),
    );
  });

  testWidgets('unselected scale above one enlarges only inactive glyphs', (
    tester,
  ) async {
    await tester.pumpWidget(
      app(
        const MorphNavigationBar.morph(
          destinations: destinations,
          iconSize: 30,
          unselectedIconScale: 1.1,
          safeArea: false,
        ),
        reduced: true,
      ),
    );
    await tester.pumpAndSettle();
    expect(
      tester.getRect(find.byIcon(MorphIcons.home)).width,
      closeTo(30, 0.2),
    );
    expect(
      tester.getRect(find.byIcon(MorphIcons.search)).width,
      closeTo(33, 0.2),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'destination IconData builds selected glyphs and widget fallback',
    (tester) async {
      const glyph = MorphNavigationBarDestination(
        icon: MorphIcons.home,
        selectedIcon: MorphIcons.search,
        label: 'Home',
      );
      expect(glyph.icon, MorphIcons.home);
      expect(glyph.selectedIcon, MorphIcons.search);
      expect(glyph.hasIcon, isTrue);
      expect((glyph.buildIcon() as Icon).icon, MorphIcons.home);
      expect((glyph.buildIcon(selected: true) as Icon).icon, MorphIcons.search);

      const custom = MorphNavigationBarDestination(
        iconWidget: SizedBox(width: 24, height: 24),
        selectedIconWidget: SizedBox(width: 28, height: 28),
      );
      expect(custom.hasIcon, isTrue);
      expect((custom.buildIcon() as SizedBox).width, 24);
      expect((custom.buildIcon(selected: true) as SizedBox).width, 28);

      await tester.pumpWidget(
        app(
          const Align(
            alignment: Alignment.bottomCenter,
            child: MorphNavigationBar.expressive(
              destinations: destinations,
              safeArea: false,
            ),
          ),
        ),
      );
      expect(
        tester.getSize(find.byType(MorphNavigationBar)).height,
        closeTo(64, 0.01),
      );
      expect(tester.takeException(), isNull);
    },
  );

  for (final wide in [false, true]) {
    for (final direction in TextDirection.values) {
      testWidgets(
        'shared bar pill travels continuously, wide=$wide $direction',
        (tester) async {
          var index = 0;
          late StateSetter update;
          await tester.pumpWidget(
            app(
              StatefulBuilder(
                builder: (context, setState) {
                  update = setState;
                  return Align(
                    alignment: Alignment.bottomCenter,
                    child: SizedBox(
                      width: 560,
                      child: MorphNavigationBar.expressive(
                        destinations: destinations,
                        autoLayout: false,
                        safeArea: false,
                        layout: wide
                            ? MorphNavBarLayout.wide
                            : MorphNavBarLayout.compact,
                        selectedIndex: index,
                        onDestinationSelected: (i) => setState(() => index = i),
                      ),
                    ),
                  );
                },
              ),
              direction: direction,
            ),
          );
          final first = indicator(tester).indicatorRect!;
          update(() => index = 2);
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 60));
          final middle = indicator(tester).indicatorRect!;
          await tester.pumpAndSettle();
          final last = indicator(tester).indicatorRect!;
          expect(first, isNot(last));
          if (!reduced(tester)) {
            expect(middle, isNot(first));
            expect(middle, isNot(last));
            expect(
              (middle.center.dx - first.center.dx).abs(),
              lessThan((last.center.dx - first.center.dx).abs()),
            );
          } else {
            expect(middle, last);
          }
          expect(
            last.center.dx > first.center.dx,
            direction == TextDirection.ltr,
          );
          expect(find.byType(MorphSlidingIndicator), findsOneWidget);
          expect(tester.takeException(), isNull);
        },
      );
    }
  }

  testWidgets('rail pill crosses headers and different destination widths', (
    tester,
  ) async {
    var index = 0;
    late StateSetter update;
    await tester.pumpWidget(
      app(
        StatefulBuilder(
          builder: (context, setState) {
            update = setState;
            return Row(
              children: [
                MorphNavigationRail.morph(
                  type: MorphNavigationRailType.alwaysExpand,
                  selectedIndex: index,
                  onDestinationSelected: (i) => setState(() => index = i),
                  sections: const [
                    MorphNavigationRailSection(
                      destinations: [
                        MorphNavigationRailDestination(
                          icon: Icon(MorphIcons.home),
                          label: 'Home',
                        ),
                      ],
                    ),
                    MorphNavigationRailSection(
                      header: Text('Collection'),
                      destinations: [
                        MorphNavigationRailDestination(
                          icon: Icon(MorphIcons.mail),
                          label: 'Long inbox label',
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
    final start = indicator(tester).indicatorRect!;
    update(() => index = 1);
    await tester.pump();
    await tester.pumpAndSettle();
    final end = indicator(tester).indicatorRect!;
    expect(end.top, greaterThan(start.bottom));
    expect(end.width, greaterThan(start.width));
    expect(end.height, closeTo(48, 0.01));
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'drawer pill crosses section dividers and retains keyboard selection',
    (tester) async {
      var index = 0;
      await tester.pumpWidget(
        app(
          StatefulBuilder(
            builder: (context, setState) => MorphNavigationDrawer.morph(
              selectedIndex: index,
              onDestinationSelected: (i) => setState(() => index = i),
              destinations: const [
                MorphNavigationDestination(
                  icon: Icon(MorphIcons.home),
                  label: 'Home',
                ),
              ],
              sections: const [
                MorphNavigationDrawerSection(
                  header: 'Library',
                  destinations: [
                    MorphNavigationDestination(
                      icon: Icon(MorphIcons.mail),
                      label: 'Inbox',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
      final start = indicator(tester).indicatorRect!;
      await tester.tap(find.text('Home'));
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(index, 1);
      expect(indicator(tester).indicatorRect!.top, greaterThan(start.bottom));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('rapid retarget and preference change snap all shared edges', (
    tester,
  ) async {
    var index = 0;
    var reduce = false;
    late StateSetter update;
    await tester.pumpWidget(
      app(
        StatefulBuilder(
          builder: (context, setState) {
            update = setState;
            return MorphMotionScope(
              reduceMotion: reduce,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: MorphNavigationBar.expressive(
                  destinations: destinations,
                  autoLayout: false,
                  safeArea: false,
                  selectedIndex: index,
                ),
              ),
            );
          },
        ),
      ),
    );
    update(() => index = 2);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 30));
    update(() {
      index = 1;
      reduce = true;
    });
    await tester.pump();
    final snapped = indicator(tester).indicatorRect!;
    await tester.pump(const Duration(seconds: 2));
    expect(indicator(tester).indicatorRect, snapped);
    expect(
      snapped.center.dx,
      closeTo(tester.getSize(find.byType(MorphNavigationBar)).width / 2, 0.5),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'morph top dash, glass options and opaque high-contrast fallback',
    (tester) async {
      var index = 0;
      Widget build(bool contrast) => MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            highContrast: contrast,
            textScaler: const TextScaler.linear(2),
          ),
          child: child!,
        ),
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) => Align(
              alignment: Alignment.bottomCenter,
              child: MorphNavigationBar.morph(
                destinations: destinations,
                floating: true,
                selectedIndex: index,
                onDestinationSelected: (i) => setState(() => index = i),
                topIndicatorWidth: 32,
                glass: const MorphNavigationGlass(
                  blurX: 9,
                  blurY: 15,
                  tintOpacity: 0.4,
                  tint: Color(0xff221122),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpWidget(build(false));
      expect(find.byType(BackdropFilter), findsOneWidget);
      expect(indicator(tester).indicatorRect!.width, 32);
      final first = indicator(tester).indicatorRect!;
      await tester.tap(find.byIcon(MorphIcons.mail));
      await tester.pumpAndSettle();
      expect(index, 2);
      expect(indicator(tester).indicatorRect!.left, greaterThan(first.left));
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(build(true));
      await tester.pumpAndSettle();
      expect(find.byType(BackdropFilter), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  for (final floating in [true, false]) {
    testWidgets(
      'native host scroll, back to top and safe clearance, floating=$floating',
      (tester) async {
        final scroll = ScrollController();
        addTearDown(scroll.dispose);
        EdgeInsets? padding;
        await tester.pumpWidget(
          app(
            MorphNavigationBarHost(
              scrollController: scroll,
              bar: MorphNavigationBar.morph(
                destinations: destinations,
                floating: floating,
              ),
              backToTopLabel: 'Return to start',
              body: (context, controller, inset) {
                padding = inset;
                return ListView.builder(
                  controller: controller,
                  padding: inset,
                  itemCount: 100,
                  itemBuilder: (context, i) =>
                      SizedBox(height: 60, child: Text('Row $i')),
                );
              },
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(padding!.bottom > 0, floating);
        await tester.drag(find.byType(ListView), const Offset(0, -350));
        await tester.pumpAndSettle();
        if (floating) {
          expect(
            find.byWidgetPredicate(
              (widget) =>
                  widget is MorphIconButton &&
                  widget.tooltip == 'Return to start',
            ),
            findsOneWidget,
          );
          await tester.tap(
            find.byWidgetPredicate(
              (widget) =>
                  widget is MorphIconButton &&
                  widget.tooltip == 'Return to start',
            ),
          );
          await tester.pumpAndSettle();
          expect(scroll.offset, closeTo(0, 1));
        } else {
          expect(
            find.byWidgetPredicate(
              (widget) =>
                  widget is MorphIconButton &&
                  widget.tooltip == 'Return to start',
            ),
            findsNothing,
          );
        }
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('host without onRefresh never installs a refresh indicator', (
    tester,
  ) async {
    await tester.pumpWidget(
      app(
        MorphNavigationBarHost(
          bar: const MorphNavigationBar.morph(
            destinations: destinations,
            floating: true,
          ),
          body: (context, controller, padding) => ListView(
            controller: controller,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: padding,
            children: const [SizedBox(height: 1200, child: Text('Rows'))],
          ),
        ),
      ),
    );
    expect(find.byType(MorphRefreshIndicator), findsNothing);
    expect(find.byType(MorphNavigationBarHost), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'native refresh controller awaits one callback without hiding the bar',
    (tester) async {
      final complete = Completer<void>();
      var calls = 0;
      final refresh = MorphRefreshIndicatorController();
      addTearDown(refresh.dispose);
      await tester.pumpWidget(
        app(
          MorphMotionScope(
            reduceMotion: true,
            child: MorphNavigationBarHost(
              refreshController: refresh,
              onRefresh: () {
                calls++;
                return complete.future;
              },
              bar: const MorphNavigationBar.morph(
                destinations: destinations,
                floating: true,
              ),
              body: (context, controller, padding) => ListView(
                controller: controller,
                physics: const AlwaysScrollableScrollPhysics(),
                padding: padding,
                children: const [
                  SizedBox(height: 1200, child: Text('Refresh content')),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final future = refresh.show();
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(calls, 1);
      expect(find.byType(MorphNavigationBar), findsOneWidget);
      complete.complete();
      await tester.pumpAndSettle();
      await future;
      expect(calls, 1);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('collapsed rail keeps icon pill geometry and item spacing', (
    tester,
  ) async {
    var index = 0;
    late StateSetter update;
    await tester.pumpWidget(
      app(
        StatefulBuilder(
          builder: (context, setState) {
            update = setState;
            return Row(
              children: [
                MorphNavigationRail.morph(
                  type: MorphNavigationRailType.alwaysCollapse,
                  selectedIndex: index,
                  onDestinationSelected: (i) => setState(() => index = i),
                  sections: const [
                    MorphNavigationRailSection(
                      destinations: [
                        MorphNavigationRailDestination(
                          icon: Icon(MorphIcons.home),
                          label: 'Home',
                        ),
                        MorphNavigationRailDestination(
                          icon: Icon(MorphIcons.search),
                          label: 'Search',
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
    final start = indicator(tester).indicatorRect!;
    expect(start.width, 56);
    expect(start.height, 32);
    final first = tester.getRect(find.bySemanticsLabel('Home'));
    final second = tester.getRect(find.bySemanticsLabel('Search'));
    expect(second.top - first.bottom, greaterThanOrEqualTo(6));
    update(() => index = 1);
    await tester.pumpAndSettle();
    expect(indicator(tester).indicatorRect!.top, greaterThan(start.top));
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'floating host stays visible for accessible navigation and handles keyboard',
    (tester) async {
      var accessible = true;
      var keyboard = false;
      late StateSetter update;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                update = setState;
                return MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    accessibleNavigation: accessible,
                    viewInsets: EdgeInsets.only(bottom: keyboard ? 260 : 0),
                  ),
                  child: MorphNavigationBarHost(
                    bar: const MorphNavigationBar.morph(
                      destinations: destinations,
                      floating: true,
                    ),
                    body: (context, controller, padding) => ListView.builder(
                      controller: controller,
                      padding: padding,
                      itemCount: 100,
                      itemBuilder: (context, index) =>
                          SizedBox(height: 60, child: Text('Item $index')),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.drag(find.byType(ListView), const Offset(0, -300));
      await tester.pumpAndSettle();
      expect(find.byType(MorphIconButton), findsNothing);
      expect(find.byType(MorphNavigationBar), findsOneWidget);
      update(() => accessible = false);
      await tester.pump();
      await tester.drag(find.byType(ListView), const Offset(0, -250));
      await tester.pumpAndSettle();
      expect(find.byType(MorphIconButton), findsOneWidget);
      update(() => keyboard = true);
      await tester.pumpAndSettle();
      expect(find.byType(MorphNavigationBar), findsNothing);
      expect(find.byType(MorphIconButton), findsNothing);
      update(() {
        keyboard = false;
        accessible = true;
      });
      await tester.pumpAndSettle();
      expect(find.byType(MorphNavigationBar), findsOneWidget);
      expect(find.byType(MorphIconButton), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('native downward pull triggers exactly one refresh on release', (
    tester,
  ) async {
    var calls = 0;
    final complete = Completer<void>();
    await tester.pumpWidget(
      app(
        MorphMotionScope(
          reduceMotion: true,
          child: MorphNavigationBarHost(
            bar: const MorphNavigationBar.morph(
              destinations: destinations,
              floating: true,
            ),
            onRefresh: () {
              calls++;
              return complete.future;
            },
            body: (context, controller, padding) => ListView(
              controller: controller,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: padding,
              children: const [
                SizedBox(height: 1200, child: Text('Pull content')),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.timedDrag(
      find.byType(ListView),
      const Offset(0, 500),
      const Duration(milliseconds: 600),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(calls, 1);
    expect(find.byType(MorphIconButton), findsNothing);
    complete.complete();
    await tester.pumpAndSettle();
    expect(calls, 1);
    expect(tester.takeException(), isNull);
  });
  testWidgets('mouse hover and press never duplicate the moving pill', (
    tester,
  ) async {
    var index = 0;
    const fill = Color(0xffb34065);
    await tester.pumpWidget(
      app(
        StatefulBuilder(
          builder: (context, setState) => Align(
            alignment: Alignment.bottomCenter,
            child: MorphNavigationBar.expressive(
              destinations: destinations,
              autoLayout: false,
              selectedIndex: index,
              indicatorColor: fill,
              onDestinationSelected: (i) => setState(() => index = i),
            ),
          ),
        ),
      ),
    );
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: const Offset(2, 2));
    final target = tester.getCenter(find.byIcon(MorphIcons.mail));
    await mouse.moveTo(target);
    await tester.pump();
    await mouse.down(target);
    await mouse.up();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 60));
    expect(index, 2);
    final localFills = find.descendant(
      of: find.byType(MorphNavigationBar),
      matching: find.byWidgetPredicate(
        (widget) =>
            widget is DecoratedBox &&
            widget.decoration is BoxDecoration &&
            (widget.decoration as BoxDecoration).color == fill,
      ),
    );
    expect(
      localFills,
      findsNothing,
      reason: 'Only the shared render surface paints the active fill.',
    );
    await mouse.removePointer();
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
