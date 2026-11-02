import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morph_expressive/morph_expressive.dart';

void main() {
  test('geometric defaults match Flutter native stretch controller', () {
    const behavior = MorphScrollBehavior();
    expect(behavior.maxStretch, 1.0);
    expect(behavior.stretchGain, 1.0);
    expect(behavior.releaseDuration, const Duration(milliseconds: 330));

    // Custom gain, cap and spring speed remain configurable.
    const previousSettings = MorphScrollBehavior(
      maxStretch: 0.03,
      stretchGain: 0.55,
      releaseDuration: Duration(milliseconds: 420),
    );
    expect(previousSettings.maxStretch, 0.03);
    expect(previousSettings.stretchGain, 0.55);
    expect(previousSettings.releaseDuration, const Duration(milliseconds: 420));
  });

  testWidgets(
    'geometric overscroll stays capped, recovers, and keeps backdrop filtering',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScrollConfiguration(
              behavior: const MorphScrollBehavior(),
              child: ListView(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                      child: const SizedBox(
                        height: 900,
                        child: Text('Frosted'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      final gesture = await tester.startGesture(const Offset(200, 200));
      await gesture.moveBy(const Offset(0, 800));
      await tester.pump();

      final scales = tester
          .widgetList<Transform>(find.byType(Transform))
          .map((transform) => transform.transform.entry(1, 1))
          .where((scale) => scale > 1.001)
          .toList();
      expect(scales, isNotEmpty);
      for (final scale in scales) {
        expect(scale, lessThanOrEqualTo(1.032 + 0.0001));
      }
      expect(find.byType(BackdropFilter), findsOneWidget);
      expect(find.byType(ImageFiltered), findsNothing);

      await gesture.up();
      await tester.pumpAndSettle();
      expect(
        tester
            .widgetList<Transform>(find.byType(Transform))
            .any((transform) => transform.transform.entry(1, 1) > 1.001),
        isFalse,
      );
      expect(tester.takeException(), isNull);
    },
  );
}
