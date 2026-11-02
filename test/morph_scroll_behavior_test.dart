import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morph_expressive/morph_expressive.dart';

class _CustomBehavior extends MaterialScrollBehavior {
  const _CustomBehavior();

  @override
  TargetPlatform getPlatform(BuildContext context) => TargetPlatform.windows;

  @override
  Widget buildScrollbar(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) => Semantics(label: 'existing scrollbar policy', child: child);
}

Widget _scrollable(String type, {bool reverse = false}) {
  switch (type) {
    case 'list':
      return ListView(
        reverse: reverse,
        children: const [SizedBox(height: 500, child: Text('List item'))],
      );
    case 'single':
      return SingleChildScrollView(
        reverse: reverse,
        child: const SizedBox(height: 500, child: Text('Single child')),
      );
    case 'grid':
      return GridView.count(
        reverse: reverse,
        crossAxisCount: 2,
        children: const [
          SizedBox(height: 500, child: Text('Grid A')),
          SizedBox(height: 500, child: Text('Grid B')),
          SizedBox(height: 500, child: Text('Grid C')),
          SizedBox(height: 500, child: Text('Grid D')),
        ],
      );
    case 'custom':
      return CustomScrollView(
        reverse: reverse,
        slivers: const [
          SliverToBoxAdapter(
            child: SizedBox(height: 500, child: Text('Sliver')),
          ),
        ],
      );
    default:
      throw ArgumentError.value(type);
  }
}

Widget _host(Widget scrollable, {ScrollBehavior? behavior}) => MaterialApp(
  home: Scaffold(
    body: Center(
      child: SizedBox(
        width: 310,
        height: 300,
        child: Stack(
          fit: StackFit.expand,
          children: [
            const ColoredBox(color: Colors.pink),
            ScrollConfiguration(
              behavior: behavior ?? const MorphScrollBehavior(),
              child: scrollable,
            ),
          ],
        ),
      ),
    ),
  ),
);

bool _isStretched(WidgetTester tester, Axis axis) => tester
    .widgetList<Transform>(find.byType(Transform))
    .any(
      (t) =>
          t.transform.entry(
            axis == Axis.vertical ? 1 : 0,
            axis == Axis.vertical ? 1 : 0,
          ) >
          1.001,
    );

void main() {
  testWidgets(
    'adopts ListView, SingleChildScrollView, GridView and CustomScrollView without replacing them',
    (tester) async {
      for (final type in ['list', 'single', 'grid', 'custom']) {
        await tester.pumpWidget(_host(_scrollable(type)));
        await tester.pumpAndSettle();
        final gesture = await tester.startGesture(const Offset(400, 270));
        await gesture.moveBy(const Offset(0, 100));
        await tester.pump();
        expect(_isStretched(tester, Axis.vertical), isTrue, reason: type);
        expect(find.byType(ImageFiltered), findsNothing, reason: type);
        await gesture.up();
        await tester.pumpAndSettle();
        expect(_isStretched(tester, Axis.vertical), isFalse, reason: type);
      }
    },
  );

  testWidgets(
    'supports horizontal scroll direction without an image-filter layer',
    (tester) async {
      await tester.pumpWidget(
        _host(
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: const SizedBox(
              width: 900,
              child: Text('Horizontal content'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final gesture = await tester.startGesture(const Offset(400, 270));
      await gesture.moveBy(const Offset(100, 0));
      await tester.pump();
      expect(_isStretched(tester, Axis.horizontal), isTrue);
      await gesture.up();
      await tester.pumpAndSettle();
      expect(_isStretched(tester, Axis.horizontal), isFalse);
    },
  );

  testWidgets(
    'real BackdropFilter remains inside transformed scroll without ImageFiltered ancestor',
    (tester) async {
      await tester.pumpWidget(
        _host(
          ListView(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: const SizedBox(height: 520, child: Text('Glass')),
                ),
              ),
            ],
          ),
        ),
      );
      final gesture = await tester.startGesture(const Offset(400, 270));
      await gesture.moveBy(const Offset(0, 100));
      await tester.pump();
      expect(find.byType(BackdropFilter), findsOneWidget);
      expect(find.byType(ImageFiltered), findsNothing);
      expect(_isStretched(tester, Axis.vertical), isTrue);
      await gesture.up();
      await tester.pumpAndSettle();
    },
  );

  testWidgets(
    'preserves delegated scrollbars, input policies and supports explicit physics',
    (tester) async {
      const base = _CustomBehavior();
      const behavior = MorphScrollBehavior(delegate: base);
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(behavior.getPlatform(context), TargetPlatform.windows);
              expect(behavior.dragDevices, base.dragDevices);
              expect(behavior.pointerAxisModifiers, base.pointerAxisModifiers);
              expect(
                behavior.getScrollPhysics(context),
                isA<ClampingScrollPhysics>(),
              );
              final decorated = behavior.buildScrollbar(
                context,
                const SizedBox(),
                const ScrollableDetails.vertical(),
              );
              expect(decorated, isA<Semantics>());
              return const SizedBox();
            },
          ),
        ),
      );
      const custom = MorphScrollBehavior(physics: BouncingScrollPhysics());
      expect(custom.physics, isA<BouncingScrollPhysics>());
      expect(
        behavior.shouldNotify(const MorphScrollBehavior(delegate: base)),
        false,
      );
      expect(
        behavior.shouldNotify(const MorphScrollBehavior(maxStretch: 0.2)),
        true,
      );
    },
  );

  testWidgets(
    'geometric behavior is opt-in and changes only its scroll subtree',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                Expanded(
                  child: ScrollConfiguration(
                    behavior: const MorphScrollBehavior(),
                    child: ListView(
                      children: const [
                        SizedBox(height: 500, child: Text('Opt-in')),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: ListView(
                    children: const [
                      SizedBox(height: 500, child: Text('Default')),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(ListView).first),
      );
      await gesture.moveBy(const Offset(0, 100));
      await tester.pump();
      expect(_isStretched(tester, Axis.vertical), isTrue);
      await gesture.up();
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );
}
