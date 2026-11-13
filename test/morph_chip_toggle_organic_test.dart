import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morph_expressive/morph_expressive.dart';

const _options = <MorphChipToggleOption<String>>[
  MorphChipToggleOption(value: 'A', label: 'Alpha'),
  MorphChipToggleOption(value: 'B', label: 'Beta'),
  MorphChipToggleOption(value: 'C', label: 'Gamma'),
];

void main() {
  testWidgets('0 intensity keeps the exact original rendering path', (
    tester,
  ) async {
    var single = 'A';
    var multi = <String>{};
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, update) => Column(
              children: [
                MorphChipToggle<String>(
                  options: _options,
                  selected: single,
                  organicIntensity: 0,
                  onChanged: (next) => update(() => single = next),
                ),
                MorphChipToggle<String>(
                  options: _options,
                  multiSelection: true,
                  selectedValues: multi,
                  organicIntensity: 0,
                  onSelectionChanged: (next) => update(() => multi = next),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    expect(
      find.byKey(const ValueKey('morph_chip_organic_surface')),
      findsNothing,
    );
    await tester.tap(find.text('Beta').first);
    await tester.pump();
    expect(single, 'B');
    await tester.tap(find.text('Gamma').last);
    await tester.pump();
    expect(multi, {'C'});
    expect(
      find.byKey(const ValueKey('morph_chip_organic_surface')),
      findsNothing,
    );
    await tester.pumpAndSettle();
  });

  testWidgets('organic paths participate in single and multi selection', (
    tester,
  ) async {
    var single = 'A';
    var multi = <String>{};
    var intensity = 0.5;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, update) => Column(
              children: [
                MorphChipToggle<String>(
                  options: _options,
                  organicIntensity: intensity,
                  selected: single,
                  onChanged: (next) => update(() => single = next),
                ),
                MorphChipToggle<String>(
                  options: _options,
                  multiSelection: true,
                  organicIntensity: intensity,
                  selectedValues: multi,
                  onSelectionChanged: (next) => update(() => multi = next),
                ),
                TextButton(
                  onPressed: () => update(() => intensity = 0),
                  child: const Text('Disable ink'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    expect(
      find.byKey(const ValueKey('morph_chip_organic_surface')),
      findsOneWidget,
    );
    await tester.tap(find.text('Beta').first);
    await tester.pump();
    expect(single, 'B');
    await tester.tap(find.text('Gamma').last);
    await tester.pump();
    expect(multi, {'C'});
    expect(
      find.byKey(const ValueKey('morph_chip_organic_surface')),
      findsWidgets,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Alpha').last);
    await tester.pump();
    expect(multi, {'A', 'C'});
    await tester.pumpAndSettle();
    await tester.tap(find.text('Disable ink'));
    await tester.pump();
    expect(
      find.byKey(const ValueKey('morph_chip_organic_surface')),
      findsNothing,
    );
    await tester.pumpAndSettle();
  });

  testWidgets('reduced motion bypasses shader and preserves selection', (
    tester,
  ) async {
    var selected = 'A';
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: Scaffold(
            body: StatefulBuilder(
              builder: (context, update) => MorphChipToggle<String>(
                options: _options,
                organicIntensity: 1,
                selected: selected,
                onChanged: (next) => update(() => selected = next),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Beta'));
    await tester.pumpAndSettle();
    expect(selected, 'B');
    expect(
      find.byKey(const ValueKey('morph_chip_organic_surface')),
      findsNothing,
    );
  });

  testWidgets(
    'multiple selection retains organic stretch without extra surfaces',
    (tester) async {
      var values = <String>{};
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, update) => MorphChipToggle<String>(
                options: _options,
                multiSelection: true,
                selectedValues: values,
                organicBloomIntensity: 0.25,
                organicStretchIntensity: 0.40,
                onSelectionChanged: (next) => update(() => values = next),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Alpha'));
      await tester.pumpAndSettle();
      expect(values, {'A'});
      await tester.tap(find.text('Gamma'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));
      expect(values, {'A', 'C'});
      expect(
        find.byKey(const ValueKey('morph_chip_organic_surface')),
        findsWidgets,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Gamma'));
      await tester.pumpAndSettle();
      expect(values, {'A'});
    },
  );
}
