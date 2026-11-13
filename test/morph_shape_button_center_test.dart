import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart'
    show Center, GlobalKey, Icon, MaterialApp, Scaffold;
import 'package:morph_expressive/morph_expressive.dart';

void main() {
  // Shapes whose lobes repeat around the centre have a bounding box centred on
  // the rotation axis, so an icon looks centred at every angle.
  const symmetric = <MorphShapeKind>[
    MorphShapeKind.sunny,
    MorphShapeKind.softBurst,
    MorphShapeKind.clover4Leaf,
    MorphShapeKind.clover8Leaf,
    MorphShapeKind.flower,
    MorphShapeKind.softBoom,
  ];

  test('recommended icon shapes are centred in their unit square', () {
    for (final kind in symmetric) {
      final center = MorphShapeCatalog.fromKind(kind).contour.bounds.center;
      expect(center.dx, closeTo(.5, .01), reason: '${kind.name} x');
      expect(center.dy, closeTo(.5, .01), reason: '${kind.name} y');
    }
  });

  testWidgets('the child and the rotation axis keep a stable centre', (
    tester,
  ) async {
    final key = GlobalKey();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: MorphShapeButton(
              key: key,
              size: 100,
              shape: MorphShapeCatalog.fromKind(MorphShapeKind.sunny),
              rotationEnabled: true,
              rotationDuration: const Duration(seconds: 2),
              onPressed: () {},
              child: const Icon(MorphIcons.favorite_border),
            ),
          ),
        ),
      ),
    );
    final box = tester.getRect(find.byKey(key));
    for (var i = 0; i < 12; i++) {
      await tester.pump(const Duration(milliseconds: 170));
      final icon = tester.getRect(
        find.descendant(of: find.byKey(key), matching: find.byType(Icon)),
      );
      expect(icon.center.dx, closeTo(box.center.dx, .001), reason: 'frame $i');
      expect(icon.center.dy, closeTo(box.center.dy, .001), reason: 'frame $i');
      expect(
        tester.getRect(find.byKey(key)),
        box,
        reason: 'layout never moves',
      );
    }
  });
}
