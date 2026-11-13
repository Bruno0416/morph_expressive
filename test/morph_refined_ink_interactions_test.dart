import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morph_expressive/morph_expressive.dart';
import 'package:morph_expressive/components/chips/morph_chip_organic_surface.dart';
import 'package:morph_expressive/components/date_pickers/components/morph_date_range_ink.dart';

void main() {
  testWidgets('the first chip bloom follows the actual tap position', (
    tester,
  ) async {
    var selected = <String>{};
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: StatefulBuilder(
              builder: (context, update) => MorphChipToggle<String>(
                options: const [
                  MorphChipToggleOption(value: 'a', label: 'Alpha'),
                  MorphChipToggleOption(value: 'b', label: 'Beta'),
                ],
                multiSelection: true,
                selectedValues: selected,
                organicBloomIntensity: 0.25,
                organicStretchIntensity: 0.40,
                onSelectionChanged: (value) => update(() => selected = value),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final bounds = tester.getRect(find.text('Alpha'));
    // Place the pointer away from the center but inside the first chip.
    await tester.tapAt(Offset(bounds.left + 3, bounds.center.dy));
    await tester.pump();
    final surface = tester.widget<MorphChipOrganicSurface>(
      find.byType(MorphChipOrganicSurface).first,
    );
    expect(surface.mode, MorphChipInkMode.bloom);
    expect(surface.bloomOrigin.dx, lessThan(0.5));
    await tester.pumpAndSettle();
    expect(selected, {'a'});
  });

  test('date-range stretch uses spatial timing and returns to full height', () {
    expect(MorphDateRangeInk.revealAt(0), 0);
    expect(MorphDateRangeInk.revealAt(1), 1);
    expect(MorphDateRangeInk.revealAt(0.5), greaterThan(0.5));
    expect(MorphDateRangeInk.stretchAt(0, 0.40), closeTo(0, 1e-10));
    expect(MorphDateRangeInk.stretchAt(0.5, 0.40), closeTo(0.056, 1e-10));
    expect(MorphDateRangeInk.stretchAt(1, 0.40), closeTo(0, 1e-10));
    expect(MorphDateRangeInk.stretchAt(0.5, 0), 0);
    expect(MorphDateRangeInk.stretchAt(0.5, 1), lessThanOrEqualTo(0.14));
  });

  testWidgets('a date range reveals progressively and finishes in 320 ms', (
    tester,
  ) async {
    // The calendar uses material_ui's MaterialLocalizations, which a Flutter
    // MaterialApp does not supply. Exercise it under the actual Morph app host.
    await tester.pumpWidget(
      MorphMaterialApp(
        data: MorphThemeData.light(),
        home: Scaffold(
          body: MorphCalendarDateRangePicker(
            firstDate: DateTime(2026, 11, 1),
            lastDate: DateTime(2026, 11, 30),
            currentDate: DateTime(2026, 11, 10),
            onStartDateChanged: (_) {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('13'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('18'));
    await tester.pump();
    expect(find.byType(MorphDateRangeInk), findsWidgets);
    final first = tester.widget<MorphDateRangeInk>(
      find.byType(MorphDateRangeInk).first,
    );
    expect(first.progress.value, lessThan(1));
    expect(first.organicStretchIntensity, 0.40);
    await tester.pump(const Duration(milliseconds: 16));
    await tester.pump(const Duration(milliseconds: 120));
    expect(first.progress.value, greaterThan(0));
    expect(first.progress.value, lessThan(1));
    await tester.pumpAndSettle();
    expect(first.progress.value, 1);
    expect(tester.takeException(), isNull);
  });
}
