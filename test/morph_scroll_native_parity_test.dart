import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morph_expressive/morph_expressive.dart';

/// The official Flutter stretch controller's normalized pull equation.
double _flutterPull(double normalized) {
  final magnitude = normalized.abs();
  final intensity =
      0.016 * (magnitude + 1 - math.exp(-magnitude * math.e / 0.33));
  return normalized.sign * intensity;
}

void main() {
  testWidgets('geometric transform matches Flutter native pull strength', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            height: 400,
            child: ScrollConfiguration(
              behavior: const MorphScrollBehavior(),
              child: SingleChildScrollView(
                child: const SizedBox(height: 900, child: Text('Target')),
              ),
            ),
          ),
        ),
      ),
    );

    // Use Flutter's notification origin (above the viewport but below the
    // overscroll indicator). Dispatching from Text('Target') crosses the
    // viewport, increments notification.depth, and gets ignored by the
    // depth == 0 predicate in MorphScrollBehavior.
    final target = tester
        .state<ScrollableState>(find.byType(Scrollable))
        .notificationContext!;
    final metrics = FixedScrollMetrics(
      minScrollExtent: 0,
      maxScrollExtent: 500,
      pixels: 0,
      viewportDimension: 400,
      axisDirection: AxisDirection.down,
      devicePixelRatio: 1,
    );

    ScrollStartNotification(metrics: metrics, context: target).dispatch(target);
    OverscrollNotification(
      metrics: metrics,
      context: target,
      overscroll: -200,
      dragDetails: DragUpdateDetails(globalPosition: const Offset(200, 100)),
    ).dispatch(target);
    await tester.pump();

    final scale = tester
        .widgetList<Transform>(find.byType(Transform))
        .map((transform) => transform.transform.entry(1, 1))
        .where((value) => value > 1.001)
        .reduce((a, b) => a > b ? a : b);
    expect(scale - 1, closeTo(_flutterPull(0.5), 0.0001));
    expect(find.byType(ImageFiltered), findsNothing);

    ScrollEndNotification(metrics: metrics, context: target).dispatch(target);
    await tester.pumpAndSettle();
    expect(
      tester
          .widgetList<Transform>(find.byType(Transform))
          .any((transform) => transform.transform.entry(1, 1) > 1.001),
      isFalse,
    );
    expect(tester.takeException(), isNull);
  });
}
