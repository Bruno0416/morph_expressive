import 'dart:async';
import 'dart:ui' show PointerDeviceKind;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart'
    show Material, MaterialApp, Scaffold, Icon;
import 'package:morph_expressive/morph_expressive.dart';
import 'package:morph_expressive/components/navigation_rail/components/morph_sliding_indicator.dart';

const _destinations = [
  MorphNavigationBarDestination(icon: Icon(MorphIcons.home), label: 'Home'),
  MorphNavigationBarDestination(icon: Icon(MorphIcons.search), label: 'Search'),
];

Widget _app(Widget child) => MaterialApp(home: Scaffold(body: child));

RenderMorphSlidingIndicator _indicator(WidgetTester tester) =>
    tester.renderObject<RenderMorphSlidingIndicator>(
      find.byType(MorphSlidingIndicator),
    );

bool _reduced(WidgetTester tester) => MorphMotion.reduceMotionOf(
  tester.element(find.byType(MorphSlidingIndicator)),
);

Widget _targets(Axis axis, int selected, {Duration? delay}) {
  final children = List.generate(
    3,
    (i) => SizedBox(
      width: 60,
      height: 32,
      child: MorphIndicatorTarget(
        selected: selected == i,
        decoration: const BoxDecoration(color: Color(0xffd84769)),
      ),
    ),
  );
  return Align(
    alignment: Alignment.topLeft,
    child: MorphSlidingIndicator(
      axis: axis,
      selectionDelay: delay,
      child: axis == Axis.horizontal
          ? Row(mainAxisSize: MainAxisSize.min, children: children)
          : Column(mainAxisSize: MainAxisSize.min, children: children),
    ),
  );
}

Widget _host({
  bool hideOnScroll = true,
  MorphNavigationGlass glass = const MorphNavigationGlass(),
  EdgeInsets margin = const EdgeInsets.all(12),
  Future<void> Function()? onRefresh,
  ScrollController? controller,
}) => MorphNavigationBarHost(
  hideOnScroll: hideOnScroll,
  scrollController: controller,
  floatingMargin: margin,
  backToTopLabel: 'Return to start',
  onRefresh: onRefresh,
  bar: MorphNavigationBar.expressive(
    floating: true,
    safeArea: false,
    glass: glass,
    destinations: _destinations,
  ),
  body: (context, controller, padding) => ListView.builder(
    controller: controller,
    padding: padding,
    physics: const AlwaysScrollableScrollPhysics(
      parent: ClampingScrollPhysics(),
    ),
    itemCount: 30,
    itemBuilder: (context, i) => SizedBox(height: 64, child: Text('Row $i')),
  ),
);

void main() {
  for (final axis in Axis.values) {
    for (final forward in [true, false]) {
      testWidgets('custom trailing edge waits 90ms: $axis forward=$forward', (
        tester,
      ) async {
        var selected = forward ? 0 : 2;
        late StateSetter update;
        await tester.pumpWidget(
          _app(
            StatefulBuilder(
              builder: (context, setState) {
                update = setState;
                return _targets(
                  axis,
                  selected,
                  delay: const Duration(milliseconds: 90),
                );
              },
            ),
          ),
        );
        final start = _indicator(tester).indicatorRect!;
        update(() => selected = forward ? 2 : 0);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 16));
        await tester.pump(const Duration(milliseconds: 40));
        final stretched = _indicator(tester).indicatorRect!;
        final startEdges = [start.left, start.top, start.right, start.bottom];
        final edges = [
          stretched.left,
          stretched.top,
          stretched.right,
          stretched.bottom,
        ];
        final trailing = axis == Axis.horizontal
            ? (forward ? 0 : 2)
            : (forward ? 1 : 3);
        final leading = axis == Axis.horizontal
            ? (forward ? 2 : 0)
            : (forward ? 3 : 1);
        if (!_reduced(tester)) {
          expect(edges[trailing], startEdges[trailing]);
          expect(edges[leading], isNot(startEdges[leading]));
        }
        await tester.pumpAndSettle();
        final last = _indicator(tester).indicatorRect!;
        expect(last.width, closeTo(start.width, 0.01));
        expect(last.height, closeTo(start.height, 0.01));
        expect(last, isNot(start));
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets('axis-specific default and local override selection delay', (
    tester,
  ) async {
    await tester.pumpWidget(_app(_targets(Axis.horizontal, 0)));
    expect(_indicator(tester).selectionDelay, const Duration(milliseconds: 60));
    await tester.pumpWidget(_app(_targets(Axis.vertical, 0)));
    expect(_indicator(tester).selectionDelay, const Duration(milliseconds: 20));
    await tester.pumpWidget(
      _app(_targets(Axis.vertical, 0, delay: Duration.zero)),
    );
    expect(_indicator(tester).selectionDelay, Duration.zero);
    await tester.pumpWidget(
      _app(
        _targets(Axis.horizontal, 0, delay: const Duration(milliseconds: 150)),
      ),
    );
    expect(
      _indicator(tester).selectionDelay,
      const Duration(milliseconds: 150),
    );
  });

  testWidgets('public navigation widgets forward selectionDelay', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        MorphNavigationBar.morph(
          destinations: _destinations,
          safeArea: false,
          selectionDelay: const Duration(milliseconds: 110),
        ),
      ),
    );
    expect(
      _indicator(tester).selectionDelay,
      const Duration(milliseconds: 110),
    );
    await tester.pumpWidget(
      _app(
        const MorphPageIndicator(
          count: 3,
          selectedIndex: 1,
          selectionDelay: Duration(milliseconds: 45),
        ),
      ),
    );
    expect(_indicator(tester).selectionDelay, const Duration(milliseconds: 45));
  });

  testWidgets('zero delay animates both sides without a held edge', (
    tester,
  ) async {
    var selected = 0;
    late StateSetter update;
    await tester.pumpWidget(
      _app(
        StatefulBuilder(
          builder: (context, setState) {
            update = setState;
            return _targets(Axis.vertical, selected, delay: Duration.zero);
          },
        ),
      ),
    );
    final start = _indicator(tester).indicatorRect!;
    update(() => selected = 2);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 30));
    final moved = _indicator(tester).indicatorRect!;
    if (!_reduced(tester)) {
      expect(moved.top, isNot(start.top));
      expect(moved.bottom, isNot(start.bottom));
    }
    await tester.pumpAndSettle();
  });

  testWidgets('rapid reversal cancels old trailing target', (tester) async {
    var selected = 0;
    late StateSetter update;
    await tester.pumpWidget(
      _app(
        StatefulBuilder(
          builder: (context, setState) {
            update = setState;
            return _targets(Axis.horizontal, selected);
          },
        ),
      ),
    );
    final start = _indicator(tester).indicatorRect!;
    update(() => selected = 2);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 45));
    update(() => selected = 0);
    await tester.pumpAndSettle();
    expect(
      _indicator(tester).indicatorRect,
      rectMoreOrLessEquals(start, epsilon: 0.01),
    );
    await tester.pump(const Duration(milliseconds: 200));
    expect(
      _indicator(tester).indicatorRect,
      rectMoreOrLessEquals(start, epsilon: 0.01),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('reduced motion cancels pending delay and snaps both edges', (
    tester,
  ) async {
    var selected = 0;
    var reduce = false;
    late StateSetter update;
    await tester.pumpWidget(
      _app(
        StatefulBuilder(
          builder: (context, setState) {
            update = setState;
            return MorphMotionScope(
              reduceMotion: reduce,
              child: _targets(Axis.horizontal, selected),
            );
          },
        ),
      ),
    );
    update(() => selected = 2);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 30));
    update(() => reduce = true);
    await tester.pump();
    final rect = _indicator(tester).indicatorRect!;
    expect(rect, const Rect.fromLTWH(120, 0, 60, 32));
    await tester.pump(const Duration(milliseconds: 200));
    expect(_indicator(tester).indicatorRect, rect);
    await tester.pumpWidget(const SizedBox.shrink());
    expect(tester.takeException(), isNull);
  });

  testWidgets('removing an indicator cancels the pending delayed edge', (
    tester,
  ) async {
    await tester.pumpWidget(_app(_targets(Axis.horizontal, 0)));
    await tester.pumpWidget(_app(_targets(Axis.horizontal, 2)));
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 200));
    expect(tester.takeException(), isNull);
  });

  testWidgets('return button shares the bar center with asymmetric margins', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(_host(margin: const EdgeInsets.fromLTRB(24, 0, 80, 12))),
    );
    await tester.pumpAndSettle();
    final center = tester.getCenter(find.byType(MorphNavigationBar)).dx;
    await tester.drag(find.byType(ListView), const Offset(0, -350));
    await tester.pumpAndSettle();
    final button = find.byType(MorphIconButton);
    expect(tester.getCenter(button).dx, closeTo(center, 0.01));
    expect(find.byType(MorphNavigationBar), findsNothing);
    expect(
      find.byType(MorphNavigationBar, skipOffstage: false),
      findsOneWidget,
    );
    final disabledTickers = find.ancestor(
      of: find.byType(MorphNavigationBar, skipOffstage: false),
      matching: find.byWidgetPredicate(
        (w) => w is TickerMode && !w.enabled,
        skipOffstage: false,
      ),
    );
    expect(disabledTickers, findsOneWidget);
    await tester.tap(button);
    await tester.pumpAndSettle();
    expect(find.byType(MorphNavigationBar), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  for (final live in [false, true]) {
    testWidgets('glass scroll policy preserves tint, live=$live', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          _host(
            hideOnScroll: false,
            glass: MorphNavigationGlass(blurDuringScroll: live),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        tester.widget<BackdropFilter>(find.byType(BackdropFilter)).enabled,
        isTrue,
      );
      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(ListView)),
      );
      await gesture.moveBy(const Offset(0, -120));
      await tester.pump();
      expect(
        tester.widget<BackdropFilter>(find.byType(BackdropFilter)).enabled,
        live,
      );
      await gesture.up();
      await tester.pumpAndSettle();
      expect(
        tester.widget<BackdropFilter>(find.byType(BackdropFilter)).enabled,
        isTrue,
      );
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('frosted backdrop stays separate from animated navigation', (
    tester,
  ) async {
    await tester.pumpWidget(_app(_host(hideOnScroll: false)));
    await tester.pumpAndSettle();
    final filter = find.byType(BackdropFilter);
    expect(filter, findsOneWidget);
    // The filter contains only its decorative surface, not the Material,
    // destination buttons, or their spring-driven indicators.
    expect(
      find.descendant(of: filter, matching: find.byType(Material)),
      findsNothing,
    );
    expect(
      find.ancestor(of: filter, matching: find.byType(RepaintBoundary)),
      findsWidgets,
    );
    final barMaterial = find.descendant(
      of: find.byType(MorphNavigationBar),
      matching: find.byType(Material),
    );
    expect(barMaterial, findsWidgets);
    expect(tester.widget<Material>(barMaterial.first).elevation, 0);
    expect(tester.takeException(), isNull);
  });

  testWidgets('zero-blur glass avoids the backdrop filter layer', (
    tester,
  ) async {
    expect(const MorphNavigationGlass().blurX, 8);
    expect(const MorphNavigationGlass().blurY, 8);
    await tester.pumpWidget(
      _app(
        _host(
          hideOnScroll: false,
          glass: const MorphNavigationGlass(blurX: 0, blurY: 0),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(BackdropFilter), findsNothing);
    expect(find.byType(MorphNavigationBar), findsOneWidget);
  });

  testWidgets('web backdrop opt-out retains the native glass policy', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        _host(
          hideOnScroll: false,
          glass: const MorphNavigationGlass(webBackdropBlur: false),
        ),
      ),
    );
    expect(find.byType(MorphNavigationBar), findsOneWidget);
    expect(find.byType(BackdropFilter), kIsWeb ? findsNothing : findsOneWidget);

    await tester.pumpWidget(
      _app(
        _host(
          hideOnScroll: false,
          glass: const MorphNavigationGlass(webBackdropBlur: true),
        ),
      ),
    );
    expect(find.byType(BackdropFilter), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('ancestor gallery scroll does not suppress nested frosted blur', (
    tester,
  ) async {
    final outer = ScrollController();
    addTearDown(outer.dispose);
    await tester.pumpWidget(
      _app(
        ListView(
          controller: outer,
          children: [
            const SizedBox(height: 250),
            SizedBox(height: 310, child: _host(hideOnScroll: false)),
            const SizedBox(height: 1100),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(BackdropFilter), findsOneWidget);

    // Drag outside the inner host: its body receives no scroll notification.
    final gesture = await tester.startGesture(const Offset(150, 100));
    await gesture.moveBy(const Offset(0, -110));
    await tester.pump();
    expect(outer.offset, greaterThan(0));
    expect(
      tester.widget<BackdropFilter>(find.byType(BackdropFilter)).enabled,
      isTrue,
    );

    await gesture.up();
    await tester.pumpAndSettle();
    expect(find.byType(BackdropFilter), findsOneWidget);
    expect(
      tester.widget<BackdropFilter>(find.byType(BackdropFilter)).enabled,
      isTrue,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('native blur returns during an upward reveal without waiting '
      'for the drag to finish', (tester) async {
    const glass = MorphNavigationGlass(blurRevealProgress: 0.35);
    expect(glass.blurRevealProgress, 0.35);
    await tester.pumpWidget(_app(_host(glass: glass)));
    await tester.pumpAndSettle();
    final filter = find.byType(BackdropFilter);

    // First hide the bar with a downward content scroll.
    await tester.drag(find.byType(ListView), const Offset(0, -350));
    await tester.pumpAndSettle();
    expect(find.byType(MorphIconButton), findsOneWidget);

    // Keep the pointer down to prove the blur can return before ScrollEnd.
    final gesture = await tester.startGesture(const Offset(150, 150));
    await gesture.moveBy(const Offset(0, 100));
    await tester.pump();
    expect(find.byType(MorphNavigationBar), findsOneWidget);
    expect(tester.widget<BackdropFilter>(filter).enabled, isFalse);

    var restored = false;
    for (var i = 0; i < 60; i++) {
      await tester.pump(const Duration(milliseconds: 16));
      if (tester.widget<BackdropFilter>(filter).enabled) {
        restored = true;
        break;
      }
    }
    expect(restored, !kIsWeb);
    await gesture.up();
    await tester.pumpAndSettle();
    expect(tester.widget<BackdropFilter>(filter).enabled, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('floating visibility spring does not sample the backdrop', (
    tester,
  ) async {
    await tester.pumpWidget(_app(_host()));
    await tester.pumpAndSettle();
    expect(find.byType(BackdropFilter), findsOneWidget);

    await tester.drag(find.byType(ListView), const Offset(0, -320));
    await tester.pumpAndSettle();
    expect(find.byType(MorphIconButton), findsOneWidget);
    await tester.tap(find.byType(MorphIconButton));
    await tester.pump(const Duration(milliseconds: 16));
    expect(find.byType(MorphNavigationBar), findsOneWidget);
    expect(
      tester.widget<BackdropFilter>(find.byType(BackdropFilter)).enabled,
      isFalse,
    );
    await tester.pumpAndSettle();
    expect(find.byType(BackdropFilter), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  for (final kind in [PointerDeviceKind.touch, PointerDeviceKind.mouse]) {
    testWidgets('desktop pull refresh waits for release and callback: $kind', (
      tester,
    ) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.linux;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);
      final complete = Completer<void>();
      var calls = 0;
      await tester.pumpWidget(
        _app(
          _host(
            onRefresh: () {
              calls++;
              return complete.future;
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      final gesture = await tester.startGesture(
        const Offset(300, 100),
        kind: kind,
      );
      for (var i = 0; i < 12; i++) {
        await gesture.moveBy(const Offset(0, 15));
        await tester.pump(const Duration(milliseconds: 16));
      }
      expect(calls, 0);
      await gesture.up();
      await tester.pump();
      expect(calls, 1);
      await tester.pump(const Duration(milliseconds: 300));
      expect(calls, 1);
      complete.complete();
      await tester.pumpAndSettle();
      expect(find.byType(MorphNavigationBar), findsOneWidget);
      expect(tester.takeException(), isNull);
      debugDefaultTargetPlatformOverride = null;
    });
  }
}
