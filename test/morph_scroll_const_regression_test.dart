import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morph_expressive/morph_expressive.dart';

void main() {
  testWidgets('const MorphScrollBehavior works inside ScrollConfiguration', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ScrollConfiguration(
          behavior: const MorphScrollBehavior(),
          child: ListView(
            children: const [SizedBox(height: 800, child: Text('Scroll'))],
          ),
        ),
      ),
    );

    expect(find.text('Scroll'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('negative releaseDuration fails at indicator construction', (
    tester,
  ) async {
    const invalid = MorphScrollBehavior(
      releaseDuration: Duration(milliseconds: -1),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            expect(
              () => invalid.buildOverscrollIndicator(
                context,
                const SizedBox.shrink(),
                const ScrollableDetails.vertical(),
              ),
              throwsAssertionError,
            );
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  });
}
