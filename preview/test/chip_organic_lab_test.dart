import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morph_expressive/morph_expressive.dart';
import 'package:morph_expressive_preview/chip_organic_lab.dart';

void main() {
  testWidgets('single and multiple organic stretch retain separate sliders', (
    tester,
  ) async {
    await tester.pumpWidget(
      MorphMaterialApp(
        data: MorphThemeData.light(seedColor: const Color(0xFF6750A4)),
        home: const SingleChildScrollView(child: MorphChipOrganicLab()),
      ),
    );
    expect(tester.takeException(), isNull);
    for (final key in [
      'chip_organic_bloom_slider',
      'chip_organic_stretch_slider',
    ]) {
      expect(
        find.ancestor(
          of: find.byKey(ValueKey(key)),
          matching: find.byType(Material),
        ),
        findsWidgets,
      );
      final slider = tester.widget<Slider>(find.byKey(ValueKey(key)));
      expect(slider.min, 0);
      expect(slider.max, 1);
    }
    expect(find.byType(MorphChipToggle<String>), findsNWidgets(4));
    var chips = tester
        .widgetList<MorphChipToggle<String>>(
          find.byType(MorphChipToggle<String>),
        )
        .toList();
    expect(chips.map((chip) => chip.organicBloomIntensity).toList(), [
      0.25,
      0.25,
      null,
      null,
    ]);
    expect(chips.map((chip) => chip.organicStretchIntensity).toList(), [
      0.40,
      0.40,
      null,
      null,
    ]);

    tester
        .widget<Slider>(find.byKey(const ValueKey('chip_organic_bloom_slider')))
        .onChanged!(0.2);
    tester
        .widget<Slider>(
          find.byKey(const ValueKey('chip_organic_stretch_slider')),
        )
        .onChanged!(0.6);
    await tester.pump();
    chips = tester
        .widgetList<MorphChipToggle<String>>(
          find.byType(MorphChipToggle<String>),
        )
        .toList();
    expect(chips.first.organicBloomIntensity, 0.2);
    expect(chips.first.organicStretchIntensity, 0.6);
    expect(find.text('0.20'), findsOneWidget);
    expect(find.text('0.60'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
