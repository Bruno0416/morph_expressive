import 'dart:ui' show SemanticsAction;

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart'
    show
        MaterialApp,
        Scaffold,
        Center,
        StatefulBuilder,
        StateSetter,
        Directionality,
        TextDirection;
import 'package:morph_expressive/morph_expressive.dart';
import 'package:morph_expressive/components/navigation_rail/components/morph_sliding_indicator.dart';

void main() {
  for (final effect in MorphPageIndicatorEffect.values) {
    for (final equal in [true, false]) {
      testWidgets('page indicator geometry $effect equal=$equal', (
        tester,
      ) async {
        var index = 0;
        late StateSetter update;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: StatefulBuilder(
                  builder: (context, setState) {
                    update = setState;
                    return MorphPageIndicator(
                      count: 3,
                      selectedIndex: index,
                      effect: effect,
                      activeWidth: equal ? 16 : 40,
                      inactiveWidth: 16,
                      height: 16,
                      inactiveHeight: equal ? 16 : 10,
                    );
                  },
                ),
              ),
            ),
          ),
        );
        final surface = tester.renderObject<RenderMorphSlidingIndicator>(
          find.byType(MorphSlidingIndicator),
        );
        expect(surface.indicatorRect!.width, closeTo(equal ? 16 : 40, 0.01));
        final start = surface.indicatorRect!;
        update(() => index = 2);
        await tester.pumpAndSettle();
        expect(surface.indicatorRect!.left, greaterThan(start.left));
        expect(surface.indicatorRect!.width, closeTo(equal ? 16 : 40, 0.01));
        expect(surface.indicatorRect!.height, closeTo(16, 0.01));
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets(
    'optional page taps and keyboard use 48px targets and selected semantics',
    (tester) async {
      final semantics = tester.ensureSemantics();
      var index = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) => MorphPageIndicator(
                count: 3,
                selectedIndex: index,
                activeWidth: 16,
                inactiveWidth: 8,
                onPageSelected: (i) => setState(() => index = i),
                semanticLabelBuilder: (i, n) => 'Page ${i + 1} of $n',
              ),
            ),
          ),
        ),
      );
      final target = find.bySemanticsLabel('Page 2 of 3');
      expect(tester.getSize(target).height, greaterThanOrEqualTo(48));
      expect(tester.getSize(target).width, greaterThanOrEqualTo(48));
      await tester.tap(target);
      await tester.pumpAndSettle();
      expect(index, 1);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(index, 2);
      expect(tester.takeException(), isNull);
      semantics.dispose();
    },
  );

  testWidgets(
    'informational dots are not buttons and RTL follows reading order',
    (tester) async {
      final semantics = tester.ensureSemantics();
      var index = 0;
      late StateSetter update;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Directionality(
              textDirection: TextDirection.rtl,
              child: Center(
                child: StatefulBuilder(
                  builder: (context, setState) {
                    update = setState;
                    return MorphPageIndicator(
                      count: 3,
                      selectedIndex: index,
                      semanticLabelBuilder: (i, n) => 'Page ${i + 1}',
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      );
      expect(
        tester
            .getSemantics(find.bySemanticsLabel('Page 1'))
            .getSemanticsData()
            .hasAction(SemanticsAction.tap),
        isFalse,
      );
      final render = tester.renderObject<RenderMorphSlidingIndicator>(
        find.byType(MorphSlidingIndicator),
      );
      final start = render.indicatorRect!.center.dx;
      update(() => index = 2);
      await tester.pumpAndSettle();
      expect(render.indicatorRect!.center.dx, lessThan(start));
      semantics.dispose();
    },
  );

  testWidgets(
    'reduced motion settles new selection and dimension changes immediately',
    (tester) async {
      var index = 0;
      var width = 40.0;
      late StateSetter update;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MorphMotionScope(
              reduceMotion: true,
              child: Center(
                child: StatefulBuilder(
                  builder: (context, setState) {
                    update = setState;
                    return MorphPageIndicator(
                      count: 4,
                      selectedIndex: index,
                      activeWidth: width,
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      );
      update(() {
        index = 3;
        width = 56;
      });
      await tester.pump();
      final render = tester.renderObject<RenderMorphSlidingIndicator>(
        find.byType(MorphSlidingIndicator),
      );
      final snap = render.indicatorRect!;
      expect(snap.width, 56);
      await tester.pump(const Duration(seconds: 1));
      expect(render.indicatorRect, snap);
      expect(tester.binding.transientCallbackCount, 0);
      expect(tester.takeException(), isNull);
    },
  );
}
