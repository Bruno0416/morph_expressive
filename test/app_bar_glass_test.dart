import 'package:flutter/rendering.dart' show RenderStack;
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart'
    show
        BackdropFilter,
        BoxDecoration,
        DecoratedBox,
        LinearGradient,
        Positioned;
import 'package:material_ui/material_ui.dart'
    show MaterialApp, Scaffold, ListView, Text, SizedBox, Offset;
import 'package:morph_expressive/morph_expressive.dart';

void main() {
  testWidgets(
    'frosted AppBar has stronger tint and a clear edge with six blur strips',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            extendBodyBehindAppBar: true,
            appBar: MorphAppBar.frosted(titleText: 'Gradient glass'),
            body: ListView.builder(
              itemCount: 20,
              itemBuilder: (context, index) =>
                  SizedBox(height: 80, child: Text('Item $index')),
            ),
          ),
        ),
      );

      final appBar = tester.widget<MorphAppBar>(find.byType(MorphAppBar));
      expect(appBar.glass, isNotNull);
      expect(appBar.elevation, 0);
      final filters = find.descendant(
        of: find.byType(MorphAppBar),
        matching: find.byType(BackdropFilter),
      );
      expect(filters, findsNWidgets(6));
      final gradients = find.descendant(
        of: find.byType(MorphAppBar),
        matching: find.byType(DecoratedBox),
      );
      final gradient = tester
          .widgetList<DecoratedBox>(gradients)
          .map((box) => box.decoration)
          .whereType<BoxDecoration>()
          .map((decoration) => decoration.gradient)
          .whereType<LinearGradient>()
          .single;
      expect(gradient.colors, hasLength(65));
      expect(gradient.stops, hasLength(65));
      expect(gradient.colors.first.a, closeTo(0.90, 0.001));
      expect(gradient.colors.last.a, 0);
      expect(gradient.stops!.first, 0);
      expect(gradient.stops!.last, 1);
      // The lower half rises linearly from zero to the 50% midpoint.
      // The upper half then accelerates exponentially to 90% opacity.
      final midpoint = gradient.colors[32].a;
      expect(midpoint, closeTo(0.26164, 0.001));
      expect(gradient.colors[48].a, closeTo(midpoint / 2, 0.001));
      expect(gradient.colors[56].a, closeTo(midpoint / 4, 0.001));
      expect(gradient.colors[16].a, greaterThan(midpoint * 1.5));
      for (var i = 1; i < gradient.colors.length; i++) {
        expect(
          gradient.colors[i].a,
          lessThanOrEqualTo(gradient.colors[i - 1].a),
        );
      }

      // The last blurred strip ends four logical pixels before the glass
      // bottom; no BackdropFilter is painted in that clear edge region.
      final stripElements = filters.evaluate().toList();
      final strips = <Positioned>[
        for (final element in stripElements)
          element.findAncestorWidgetOfExactType<Positioned>()!,
      ];
      expect(strips, hasLength(6));
      final lastStrip = strips.last;
      expect(lastStrip.height, lessThan(4));
      expect(lastStrip.height, greaterThan(0));
      final glassStackHeight = stripElements.first
          .findAncestorRenderObjectOfType<RenderStack>()!
          .size
          .height;
      expect(
        lastStrip.top! + lastStrip.height!,
        closeTo(glassStackHeight - 4, 0.01),
      );
      expect(appBar.glass!.blurClearExtent, 4);

      await tester.drag(find.byType(ListView), const Offset(0, -300));
      await tester.pumpAndSettle();
      expect(find.text('Gradient glass'), findsOneWidget);
      expect(filters, findsNWidgets(6));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('custom falloff controls tint without changing its clear edge', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          appBar: MorphAppBar.frosted(
            titleText: 'Linear tint',
            glass: const MorphAppBarGlass(
              topOpacity: 0.8,
              blurBands: 3,
              tintCurvePower: 1,
              blurCurvePower: 2,
              blurClearExtent: 8,
            ),
          ),
        ),
      ),
    );
    final gradient = tester
        .widgetList<DecoratedBox>(
          find.descendant(
            of: find.byType(MorphAppBar),
            matching: find.byType(DecoratedBox),
          ),
        )
        .map((box) => box.decoration)
        .whereType<BoxDecoration>()
        .map((decoration) => decoration.gradient)
        .whereType<LinearGradient>()
        .single;
    expect(gradient.colors, hasLength(65));
    expect(gradient.colors.first.a, closeTo(0.8, 0.001));
    // tintCurvePower: 1 adjusts the upper exponential growth while the
    // lower half remains linear and the fully transparent edge stays intact.
    final midpoint = gradient.colors[32].a;
    expect(midpoint, closeTo(0.17213, 0.001));
    expect(gradient.colors[48].a, closeTo(midpoint / 2, 0.001));
    expect(gradient.colors[56].a, closeTo(midpoint / 4, 0.001));
    expect(gradient.colors[16].a, greaterThan(midpoint * 1.5));
    expect(gradient.colors.last.a, 0);
    expect(find.byType(BackdropFilter), findsNWidgets(2));
    expect(
      tester
          .widget<MorphAppBar>(find.byType(MorphAppBar))
          .glass!
          .blurClearExtent,
      8,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('clear edge covering the whole bar skips all blur filters', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          appBar: MorphAppBar.frosted(
            titleText: 'Clear glass',
            glass: const MorphAppBarGlass(blurClearExtent: 200),
          ),
        ),
      ),
    );
    expect(find.byType(BackdropFilter), findsNothing);
    expect(find.text('Clear glass'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('zero blur uses tint gradient without a backdrop filter', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          extendBodyBehindAppBar: true,
          appBar: MorphAppBar.frosted(
            titleText: 'No blur',
            glass: const MorphAppBarGlass(maxBlurSigma: 0, topOpacity: 0.25),
          ),
          body: const SizedBox.expand(),
        ),
      ),
    );
    expect(find.byType(BackdropFilter), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
