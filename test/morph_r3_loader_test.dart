import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart' show MaterialApp, Scaffold;
import 'package:morph_expressive/morph_expressive.dart';

void main() {
  testWidgets(
    'running loader retargets from visible geometry and pauses in TickerMode',
    (tester) async {
      final a = [MorphShapeCatalog.softBurst, MorphShapeCatalog.pentagon];
      final b = [MorphShapeCatalog.cookie7Sided, MorphShapeCatalog.oval];
      Widget host(
        List<MorphShape> shapes, {
        bool active = true,
        bool reduced = false,
      }) => MaterialApp(
        home: Scaffold(
          body: MorphMotionScope(
            reduceMotion: reduced,
            child: TickerMode(
              enabled: active,
              child: MorphExpressiveLoadingIndicator(
                shapes: shapes,
                morphInterval: const Duration(milliseconds: 100),
              ),
            ),
          ),
        ),
      );
      await tester.pumpWidget(host(a));
      await tester.pump(const Duration(milliseconds: 40));
      final before = tester
          .widget<MorphShapeView>(find.byType(MorphShapeView))
          .contour!;
      await tester.pumpWidget(host(b));
      final after = tester
          .widget<MorphShapeView>(find.byType(MorphShapeView))
          .contour!;
      expect(
        (before.bounds.topLeft - after.bounds.topLeft).distance,
        lessThan(1e-7),
      );
      await tester.pumpWidget(host(b, active: false));
      final paused = tester
          .widget<MorphShapeView>(find.byType(MorphShapeView))
          .contour!;
      await tester.pump(const Duration(seconds: 3));
      final still = tester
          .widget<MorphShapeView>(find.byType(MorphShapeView))
          .contour!;
      expect(still.bounds, paused.bounds);
      await tester.pumpWidget(host(b, reduced: true));
      await tester.pump(const Duration(seconds: 1));
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
  );
  testWidgets('loader sequence changes without replacing its state', (
    tester,
  ) async {
    Widget host(List<MorphShape> shapes) => MaterialApp(
      home: Scaffold(
        body: MorphLoadingIndicator(shapes: shapes, rotationTurns: 0.25),
      ),
    );
    await tester.pumpWidget(
      host([MorphShapeCatalog.circle, MorphShapeCatalog.pentagon]),
    );
    final before = tester.state(find.byType(MorphExpressiveLoadingIndicator));
    await tester.pumpWidget(
      host([MorphShapeCatalog.softBurst, MorphShapeCatalog.cookie7Sided]),
    );
    expect(
      tester.state(find.byType(MorphExpressiveLoadingIndicator)),
      same(before),
    );
    expect(find.byType(MorphShapeView), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 2));
    expect(tester.takeException(), isNull);
  });
}
