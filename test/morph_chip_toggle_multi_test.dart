import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morph_expressive/morph_expressive.dart';

const _options = <MorphChipToggleOption<String>>[
  MorphChipToggleOption(value: 'A', label: 'Alpha'),
  MorphChipToggleOption(value: 'B', label: 'Beta'),
  MorphChipToggleOption(value: 'C', label: 'Gamma'),
];

void main() {
  testWidgets('multi selection adds independent animated pills', (tester) async {
    var selected = <String>{'A'};
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: StatefulBuilder(builder: (context, update) =>
          MorphChipToggle<String>(
            multiSelection: true,
            options: _options,
            selectedValues: selected,
            onSelectionChanged: (next) => update(() => selected = next),
          ),
        ),
      ),
    ));
    expect(find.byKey(const ValueKey<String>('A')), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('B')), findsNothing);
    await tester.tap(find.text('Beta'));
    await tester.pump();
    expect(selected, {'A', 'B'});
    expect(find.byKey(const ValueKey<String>('A')), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('B')), findsOneWidget);

    await tester.tap(find.text('Gamma'));
    await tester.pump();
    expect(selected, {'A', 'B', 'C'});
    expect(find.byKey(const ValueKey<String>('C')), findsOneWidget);

    await tester.tap(find.text('Beta'));
    await tester.pump();
    expect(selected, {'A', 'C'});
    // A non-last indicator stays alive while merging toward a survivor.
    expect(find.byKey(const ValueKey<String>('B')), findsOneWidget);
    // Allow the reverse animation to finish and remove the exiting pill.
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey<String>('B')), findsNothing);
    expect(find.byKey(const ValueKey<String>('A')), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('C')), findsOneWidget);
  });

  testWidgets('last pill collapses, then a fresh selection can begin', (tester) async {
    var selected = <String>{'A'};
    await tester.pumpWidget(MaterialApp(home: Scaffold(
      body: StatefulBuilder(builder: (context, update) =>
        MorphChipToggle<String>(
          multiSelection: true,
          options: _options,
          selectedValues: selected,
          onSelectionChanged: (next) => update(() => selected = next),
        ),
      ),
    )));
    await tester.tap(find.text('Alpha'));
    await tester.pump();
    expect(selected, isEmpty);
    // Allow the reverse animation to finish and remove the exiting pill.
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey<String>('A')), findsNothing);
    await tester.tap(find.text('Beta'));
    await tester.pump();
    expect(selected, {'B'});
    expect(find.byKey(const ValueKey<String>('B')), findsOneWidget);
  });

  testWidgets('rapid toggle reverses a closing indicator safely', (tester) async {
    var selected = <String>{'A', 'B'};
    await tester.pumpWidget(MaterialApp(home: Scaffold(
      body: StatefulBuilder(builder: (context, update) =>
        MorphChipToggle<String>(
          multiSelection: true,
          options: _options,
          selectedValues: selected,
          onSelectionChanged: (next) => update(() => selected = next),
        ),
      ),
    )));
    await tester.tap(find.text('Beta'));
    await tester.pump(const Duration(milliseconds: 30));
    await tester.tap(find.text('Beta'));
    // Allow the reverse animation to finish and remove the exiting pill.
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(selected, {'A', 'B'});
    expect(find.byKey(const ValueKey<String>('B')), findsOneWidget);
  });

  // Captures actual pixels in a true 0 -> 1 -> 0 boundary transition.
  // Adding a second chip deliberately uses the stretched transfer instead.
  testWidgets('boundary pills bloom visibly from a small circle', (tester) async {
    var selected = <String>{};
    const captureKey = ValueKey<String>('chip-bloom-capture');
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 390,
            height: 44,
            child: RepaintBoundary(
              key: captureKey,
              child: StatefulBuilder(
                builder: (context, update) => MorphChipToggle<String>(
                  multiSelection: true,
                  options: _options,
                  selectedValues: selected,
                  onSelectionChanged: (next) => update(() => selected = next),
                ),
              ),
            ),
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();

    final capture = find.byKey(captureKey);
    final chipCenter = tester.getCenter(find.text('Beta'));
    // Two pixels below the top of a 40px chip: the small circle must NOT
    // reach this pixel, but the fully expanded pill must fill it. Sampling
    // near the edge avoids false failures from an antialiased circular rim
    // that can still touch a pixel 16px away during reversal.
    final topPixel = Offset(chipCenter.dx, chipCenter.dy - 18);
    final background = await _pixelAt(tester, capture, topPixel);

    await tester.tap(find.text('Beta'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 95));
    expect(selected, {'B'});
    expect(await _pixelAt(tester, capture, topPixel), background,
        reason: 'A new chip must not paint at full height immediately.');

    await tester.pumpAndSettle();
    final fullPill = await _pixelAt(tester, capture, topPixel);
    expect(fullPill, isNot(background));

    await tester.tap(find.text('Beta'));
    await tester.pump();
    // Check after the circle is well within the chip, not while its
    // antialiased rim is grazing the sample point.
    await tester.pump(const Duration(milliseconds: 180));
    expect(selected, isEmpty);
    expect(await _pixelAt(tester, capture, topPixel), background,
        reason: 'The shrinking indicator must return to a circle.');
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey<String>('B')), findsNothing);
  });

  testWidgets('second and non-last chips use nearest-pill transfer', (tester) async {
    var selected = <String>{'A'};
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: StatefulBuilder(
          builder: (context, update) => MorphChipToggle<String>(
            multiSelection: true,
            options: _options,
            selectedValues: selected,
            onSelectionChanged: (next) => update(() => selected = next),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('Beta'));
    await tester.pump();
    expect(selected, {'A', 'B'});
    // A transferring pill has full-height, two-edge tween geometry, not a dot.
    expect(find.descendant(
      of: find.byKey(const ValueKey<String>('B')),
      matching: find.byType(CustomPaint),
    ), findsNothing);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Beta'));
    await tester.pump();
    expect(selected, {'A'});
    expect(find.descendant(
      of: find.byKey(const ValueKey<String>('B')),
      matching: find.byType(CustomPaint),
    ), findsNothing);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey<String>('B')), findsNothing);

    // The remaining chip alone now disappears by circle bloom.
    await tester.tap(find.text('Alpha'));
    await tester.pump();
    expect(selected, isEmpty);
    expect(find.descendant(
      of: find.byKey(const ValueKey<String>('A')),
      matching: find.byType(CustomPaint),
    ), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey<String>('A')), findsNothing);
  });

  testWidgets('preview case duplicates rather than blooms', (tester) async {
    var selected = <String>{'A', 'C'};
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: StatefulBuilder(
          builder: (context, update) => MorphChipToggle<String>(
            multiSelection: true,
            options: _options,
            selectedValues: selected,
            onSelectionChanged: (next) => update(() => selected = next),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('Beta'));
    await tester.pump();
    expect(selected, {'A', 'B', 'C'});
    expect(find.descendant(
      of: find.byKey(const ValueKey<String>('B')),
      matching: find.byType(CustomPaint),
    ), findsNothing);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Beta'));
    await tester.pump();
    expect(selected, {'A', 'C'});
    expect(find.descendant(
      of: find.byKey(const ValueKey<String>('B')),
      matching: find.byType(CustomPaint),
    ), findsNothing);
    await tester.pumpAndSettle();
  });

  testWidgets('last selected chip also blooms from a dot', (tester) async {
    var selected = <String>{};
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: StatefulBuilder(
          builder: (context, update) => MorphChipToggle<String>(
            multiSelection: true,
            options: _options,
            selectedValues: selected,
            onSelectionChanged: (next) => update(() => selected = next),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('Alpha'));
    await tester.pump();
    expect(selected, {'A'});
    expect(find.descendant(
      of: find.byKey(const ValueKey<String>('A')),
      matching: find.byType(CustomPaint),
    ), findsWidgets);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Alpha'));
    await tester.pump();
    expect(selected, isEmpty);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey<String>('A')), findsNothing);
  });

  testWidgets('single selection preserves its original callback', (tester) async {
    var selected = 'A';
    await tester.pumpWidget(MaterialApp(home: Scaffold(
      body: StatefulBuilder(builder: (context, update) =>
        MorphChipToggle<String>(
          options: _options,
          selected: selected,
          onChanged: (next) => update(() => selected = next),
        ),
      ),
    )));
    await tester.tap(find.text('Gamma'));
    await tester.pump();
    expect(selected, 'C');
  });
}

/// Returns the exact RGBA pixel displayed by a repaint boundary in the test.
Future<List<int>> _pixelAt(
  WidgetTester tester,
  Finder boundaryFinder,
  Offset globalPosition,
) async {
  final boundary = tester.renderObject<RenderRepaintBoundary>(boundaryFinder);
  final origin = tester.getTopLeft(boundaryFinder);
  final x = (globalPosition.dx - origin.dx).floor();
  final y = (globalPosition.dy - origin.dy).floor();

  // toImage/toByteData use asynchronous engine callbacks. A widget test runs
  // in FakeAsync, so awaiting either call outside runAsync can hang forever.
  // Keep both operations inside the same real-async callback.
  final pixel = await tester.runAsync<List<int>>(() async {
    final image = await boundary.toImage(pixelRatio: 1);
    try {
      final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
      if (data == null) throw StateError('Could not capture chip paint.');
      if (x < 0 || y < 0 || x >= image.width || y >= image.height) {
        throw RangeError('Pixel ($x, $y) outside ${image.width}×${image.height}');
      }
      final index = (y * image.width + x) * 4;
      return [for (var i = 0; i < 4; i++) data.getUint8(index + i)];
    } finally {
      image.dispose();
    }
  });
  if (pixel == null) {
    // runAsync forwards engine errors to the widget-test binding.
    final error = tester.takeException();
    if (error != null) throw error;
    throw StateError('Could not capture chip paint asynchronously.');
  }
  return pixel;
}
