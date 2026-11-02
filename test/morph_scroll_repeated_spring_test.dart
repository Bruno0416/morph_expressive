import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morph_expressive/morph_expressive.dart';

void main() {
  testWidgets(
    'repeated overscroll releases and interrupted springs stay valid',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScrollConfiguration(
              behavior: const MorphScrollBehavior(),
              child: ListView(
                children: const [SizedBox(height: 900, child: Text('Content'))],
              ),
            ),
          ),
        ),
      );

      // Dispatch from the Scrollable's notification context so depth == 0.
      // This exercises the same release -> new spring -> interrupted release
      // path that previously threw on the second AnimationController.unbounded.
      final origin = tester
          .state<ScrollableState>(find.byType(Scrollable))
          .notificationContext!;
      final metrics = FixedScrollMetrics(
        minScrollExtent: 0,
        maxScrollExtent: 600,
        pixels: 0,
        viewportDimension: 300,
        axisDirection: AxisDirection.down,
        devicePixelRatio: 1,
      );

      for (var i = 0; i < 3; i++) {
        ScrollStartNotification(
          metrics: metrics,
          context: origin,
        ).dispatch(origin);
        OverscrollNotification(
          metrics: metrics,
          context: origin,
          overscroll: -90,
          dragDetails: DragUpdateDetails(
            globalPosition: const Offset(200, 120),
          ),
        ).dispatch(origin);
        await tester.pump();
        ScrollEndNotification(
          metrics: metrics,
          context: origin,
        ).dispatch(origin);
        await tester.pump(const Duration(milliseconds: 16));
        expect(tester.takeException(), isNull, reason: 'release ${i + 1}');
      }

      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.byType(ImageFiltered), findsNothing);
    },
  );
}
