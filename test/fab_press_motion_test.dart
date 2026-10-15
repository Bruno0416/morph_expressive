import 'package:flutter_test/flutter_test.dart';
import 'package:morph_expressive/morph_components.dart';
import 'package:material_ui/material_ui.dart';

/// X-axis scale from a [Transform.scale] matrix (Z is always 1.0).
double _xyScale(Transform transform) => transform.transform.storage[0];

double _fabXyScale(WidgetTester tester) {
  final transforms = tester.widgetList<Transform>(
    find.descendant(of: find.byType(MorphFab), matching: find.byType(Transform)),
  );
  // Prefer a non-identity XY scale if the spring has moved; else first matrix.
  for (final transform in transforms) {
    final scale = _xyScale(transform);
    if ((scale - 1.0).abs() > 0.001) {
      return scale;
    }
  }
  return _xyScale(transforms.first);
}

void main() {
  testWidgets('MorphFab springs press scale while held', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      MorphMaterialApp(
        data: MorphThemeData.light(),
        home: Scaffold(
          body: Center(
            child: MorphFab(icon: const Icon(Icons.add), onPressed: () => taps++),
          ),
        ),
      ),
    );

    expect(_fabXyScale(tester), closeTo(1.0, 0.001));

    final Offset center = tester.getCenter(find.byType(MorphFab));
    final TestGesture gesture = await tester.startGesture(center);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 48));

    expect(_fabXyScale(tester), lessThan(0.995));

    await gesture.up();
    await tester.pump();
    expect(taps, 1);
  });

  testWidgets('MorphFab onPressed fires instantly on tap', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      MorphMaterialApp(
        data: MorphThemeData.light(),
        home: Scaffold(
          body: Center(
            child: MorphFab(icon: const Icon(Icons.add), onPressed: () => taps++),
          ),
        ),
      ),
    );

    await tester.tap(find.byType(MorphFab));
    expect(taps, 1);
  });
}
