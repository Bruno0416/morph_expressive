import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morph_expressive/morph_expressive.dart';

/// Measures the geometric transform for identical real drag gestures.
Future<double> _dragScale(
  WidgetTester tester,
  MorphScrollBehavior behavior,
) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 320,
            height: 360,
            child: ScrollConfiguration(
              behavior: behavior,
              child: ListView(
                children: [
                  ClipRRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                      child: const SizedBox(height: 750),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );

  final gesture = await tester.startGesture(const Offset(400, 300));
  await gesture.moveBy(const Offset(0, 100));
  await tester.pump();
  final scales = tester
      .widgetList<Transform>(find.byType(Transform))
      .map((widget) => widget.transform.entry(1, 1))
      .where((value) => value > 1.001);
  expect(scales, isNotEmpty);
  expect(find.byType(BackdropFilter), findsOneWidget);
  expect(find.byType(ImageFiltered), findsNothing);
  final scale = scales.reduce((a, b) => a > b ? a : b);
  await gesture.up();
  await tester.pumpAndSettle();
  await tester.pumpWidget(const SizedBox.shrink());
  return scale;
}

void main() {
  testWidgets('stretchGain scales Flutter-native pull proportionally', (
    tester,
  ) async {
    final originalScale = await _dragScale(
      tester,
      const MorphScrollBehavior(stretchGain: 1),
    );
    final reducedScale = await _dragScale(
      tester,
      const MorphScrollBehavior(stretchGain: 0.5),
    );

    expect(originalScale, greaterThan(1.005));
    expect(reducedScale, greaterThan(1.001));
    expect(reducedScale, lessThanOrEqualTo(1.016 + 0.0001));
    expect((reducedScale - 1) / (originalScale - 1), closeTo(0.5, 0.05));
    expect(tester.takeException(), isNull);
  });
}
