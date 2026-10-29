import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart' show MaterialApp, Scaffold;
import 'package:morph_expressive/morph_expressive.dart';

const _destinations = [
  MorphNavigationBarDestination(icon: MorphIcons.home, label: 'Home'),
  MorphNavigationBarDestination(icon: MorphIcons.search, label: 'Lists'),
];

const _scrollPhysics = AlwaysScrollableScrollPhysics(
  parent: BouncingScrollPhysics(),
);

Widget _catalog(String name, {int itemCount = 32}) => CustomScrollView(
  key: ValueKey('catalog-$name'),
  physics: _scrollPhysics,
  slivers: [
    SliverList.builder(
      itemCount: itemCount,
      itemBuilder: (context, index) =>
          SizedBox(height: 72, child: Text('$name item $index')),
    ),
  ],
);

Widget _nestedHost({required Future<void> Function()? onRefresh}) =>
    MaterialApp(
      home: Scaffold(
        body: MorphNavigationBarHost(
          bar: const MorphNavigationBar.morph(
            floating: true,
            safeArea: false,
            destinations: _destinations,
          ),
          onRefresh: onRefresh,
          body: (context, controller, padding) => PrimaryScrollController(
            controller: controller,
            child: NestedScrollView(
              controller: controller,
              physics: _scrollPhysics,
              headerSliverBuilder: (context, innerBoxIsScrolled) => [
                const SliverToBoxAdapter(
                  child: SizedBox(height: 120, child: Text('Header')),
                ),
              ],
              body: PageView(children: [_catalog('movies'), _catalog('tv')]),
            ),
          ),
        ),
      ),
    );

Future<void> _pull(WidgetTester tester, String tab) async {
  await tester.fling(
    find.byKey(ValueKey('catalog-$tab')),
    const Offset(0, 500),
    1500,
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 800));
}

// Reproduce a diagonal drag over multiple frames so NestedScrollView can
// hand off motion between its outer header and the active inner catalog.
Future<void> _diagonalDrag(
  WidgetTester tester,
  String tab,
  Offset step, {
  int steps = 16,
}) async {
  final gesture = await tester.startGesture(
    tester.getCenter(find.byKey(ValueKey('catalog-$tab'))),
  );
  for (var i = 0; i < steps; i++) {
    await gesture.moveBy(step);
    await tester.pump(const Duration(milliseconds: 16));
  }
  await gesture.up();
  await tester.pumpAndSettle();
}

void main() {
  final backToTop = find.byWidgetPredicate(
    (widget) => widget is MorphIconButton && widget.tooltip == 'Scroll to top',
  );

  testWidgets('nested diagonal vertical scroll hides the floating bar', (
    tester,
  ) async {
    await tester.pumpWidget(_nestedHost(onRefresh: () async {}));
    await tester.pumpAndSettle();

    // The vertical movement should win despite the horizontal component.
    // Multiple pointer updates cover the outer/inner scroll hand-off.
    await _diagonalDrag(tester, 'movies', const Offset(-7, -25));
    final nested = tester.state<NestedScrollViewState>(
      find.byType(NestedScrollView),
    );
    expect(nested.outerController.offset, greaterThan(0));
    expect(backToTop, findsOneWidget);

    // Moving toward the leading edge should reveal the bar again.
    await _diagonalDrag(tester, 'movies', const Offset(6, 20));
    expect(backToTop, findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('PageView child scroll hides the bar without a root scroll', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MorphNavigationBarHost(
            bar: const MorphNavigationBar.morph(
              floating: true,
              safeArea: false,
              destinations: _destinations,
            ),
            body: (context, controller, padding) =>
                PageView(children: [_catalog('movies'), _catalog('tv')]),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // CustomScrollView notifications cross PageView's viewport at depth > 0.
    await tester.drag(
      find.byKey(const ValueKey('catalog-movies')),
      const Offset(-100, -380),
    );
    await tester.pumpAndSettle();
    expect(backToTop, findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('horizontal-dominant diagonal page swipe keeps the bar visible', (
    tester,
  ) async {
    var refreshes = 0;
    await tester.pumpWidget(
      _nestedHost(
        onRefresh: () async {
          refreshes++;
        },
      ),
    );
    await tester.pumpAndSettle();

    await tester.drag(find.byType(PageView), const Offset(-450, -35));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('catalog-tv')), findsOneWidget);
    expect(backToTop, findsNothing);
    expect(refreshes, 0);
    expect(tester.takeException(), isNull);
  });

  testWidgets('host refreshes a nested vertical catalog exactly once', (
    tester,
  ) async {
    final pending = Completer<void>();
    var calls = 0;
    await tester.pumpWidget(
      _nestedHost(
        onRefresh: () {
          calls++;
          return pending.future;
        },
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(MorphRefreshIndicator), findsOneWidget);
    await _pull(tester, 'movies');
    expect(calls, 1);

    // A second pull must not start another callback while the first is active.
    await _pull(tester, 'movies');
    expect(calls, 1);
    pending.complete();
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('horizontal page swipe does not refresh; both tabs do', (
    tester,
  ) async {
    var calls = 0;
    await tester.pumpWidget(
      _nestedHost(
        onRefresh: () async {
          calls++;
        },
      ),
    );
    await tester.pumpAndSettle();

    await tester.drag(find.byType(PageView), const Offset(-600, 0));
    await tester.pumpAndSettle();
    expect(calls, 0);
    expect(find.byKey(const ValueKey('catalog-tv')), findsOneWidget);

    await _pull(tester, 'tv');
    expect(calls, 1);
    await tester.pumpAndSettle();

    await tester.drag(find.byType(PageView), const Offset(600, 0));
    await tester.pumpAndSettle();
    await _pull(tester, 'movies');
    expect(calls, 2);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('scrolling away from the leading edge does not refresh', (
    tester,
  ) async {
    var calls = 0;
    await tester.pumpWidget(
      _nestedHost(
        onRefresh: () async {
          calls++;
        },
      ),
    );
    await tester.pumpAndSettle();

    await tester.drag(
      find.byKey(const ValueKey('catalog-movies')),
      const Offset(0, -500),
    );
    await tester.pumpAndSettle();
    await tester.drag(
      find.byKey(const ValueKey('catalog-movies')),
      const Offset(0, 75),
    );
    await tester.pumpAndSettle();
    expect(calls, 0);
    expect(tester.takeException(), isNull);
  });

  testWidgets('collapsed outer header blocks premature inner refresh', (
    tester,
  ) async {
    var calls = 0;
    await tester.pumpWidget(
      _nestedHost(
        onRefresh: () async {
          calls++;
        },
      ),
    );
    await tester.pumpAndSettle();

    await tester.drag(
      find.byKey(const ValueKey('catalog-movies')),
      const Offset(0, -220),
    );
    await tester.pumpAndSettle();
    final nested = tester.state<NestedScrollViewState>(
      find.byType(NestedScrollView),
    );
    expect(nested.outerController.offset, greaterThan(0));

    final gesture = await tester.startGesture(
      tester.getCenter(find.byKey(const ValueKey('catalog-movies'))),
    );
    await gesture.moveBy(const Offset(0, 45));
    await tester.pump();
    expect(calls, 0);
    expect(find.byType(MorphLoadingIndicator), findsNothing);
    await gesture.up();
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('plain ListView keeps the default refresh behavior', (
    tester,
  ) async {
    var calls = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MorphNavigationBarHost(
            bar: const MorphNavigationBar.morph(
              floating: true,
              safeArea: false,
              destinations: _destinations,
            ),
            onRefresh: () async {
              calls++;
            },
            body: (context, controller, padding) => ListView.builder(
              controller: controller,
              physics: _scrollPhysics,
              itemCount: 40,
              itemBuilder: (context, index) =>
                  SizedBox(height: 64, child: Text('row $index')),
            ),
          ),
        ),
      ),
    );
    await tester.fling(find.byType(ListView), const Offset(0, 500), 1500);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 800));
    expect(calls, 1);
    await tester.pumpAndSettle();
  });

  testWidgets('host does not insert a refresh indicator without callback', (
    tester,
  ) async {
    await tester.pumpWidget(_nestedHost(onRefresh: null));
    await tester.pumpAndSettle();
    expect(find.byType(MorphRefreshIndicator), findsNothing);
    await _pull(tester, 'movies');
    expect(find.byType(MorphRefreshIndicator), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
