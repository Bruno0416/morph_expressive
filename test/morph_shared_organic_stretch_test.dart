import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morph_expressive/components/navigation_rail/components/morph_sliding_indicator.dart';
import 'package:morph_expressive/morph_expressive.dart';

void main() {
  testWidgets('shared slider preserves its axis, 0 mode, and reduced motion', (
    tester,
  ) async {
    bool chosen = false;
    double strength = 0.40;
    Axis axis = Axis.vertical;
    bool reduced = false;
    await tester.pumpWidget(
      MaterialApp(
        home: StatefulBuilder(
          builder: (context, setState) {
            return MorphMotionScope(
              reduceMotion: reduced,
              child: Column(
                children: [
                  MorphSlidingIndicator(
                    axis: axis,
                    organicStretchIntensity: strength,
                    child: Row(
                      children: [
                        for (final i in [false, true])
                          SizedBox(
                            width: 70,
                            height: 40,
                            child: MorphIndicatorTarget(
                              selected: chosen == i,
                              decoration: const BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(20),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () => setState(() => chosen = !chosen),
                    child: const Text('Select'),
                  ),
                  TextButton(
                    onPressed: () => setState(() {
                      strength = 0;
                      axis = Axis.horizontal;
                      reduced = true;
                    }),
                    child: const Text('Reset'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    expect(find.byType(MorphSlidingIndicator), findsOneWidget);
    var render = tester.renderObject<RenderMorphSlidingIndicator>(
      find.byType(MorphSlidingIndicator),
    );
    expect(render.axis, Axis.vertical);
    expect(render.organicStretchIntensity, 0.40);
    await tester.tap(find.text('Select'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Reset'));
    await tester.pump();
    render = tester.renderObject<RenderMorphSlidingIndicator>(
      find.byType(MorphSlidingIndicator),
    );
    expect(render.axis, Axis.horizontal);
    expect(render.organicStretchIntensity, 0);
    expect(render.reduced, isTrue);
    expect(tester.takeException(), isNull);
  });

  test('all moving selectors default to the chip stretch preset', () {
    const page = MorphPageIndicator(count: 3, selectedIndex: 0);
    expect(page.organicStretchIntensity, 0.40);
    final toggle = MorphSegmentedToggle<String>(
      options: const [
        MorphSegmentedToggleOption(value: 'a', label: 'A'),
        MorphSegmentedToggleOption(value: 'b', label: 'B'),
      ],
      selected: 'a',
      onChanged: _noop,
    );
    expect(toggle.organicStretchIntensity, 0.40);
  });
}

void _noop(String value) {}
