import 'package:flutter/widgets.dart' show Widget;
import 'package:flutter_test/flutter_test.dart';
import 'package:material_new_shapes/material_new_shapes.dart'
    as shapes
    show Morph, RoundedPolygon;
import 'package:material_ui/material_ui.dart'
    as material
    show Column, ListView, MaterialApp, Scaffold, SizedBox;
import 'package:morph_expressive/morph_expressive.dart' as morph;

void main() {
  final List<shapes.RoundedPolygon> polygons = <shapes.RoundedPolygon>[
    morph.MorphMaterialNewShapes.circle,
    morph.MorphMaterialNewShapes.square,
  ];

  test('the public shape catalog keeps material_new_shapes geometry', () {
    final shapes.RoundedPolygon polygon = morph.MorphShapeKind.circle.polygon;
    final shapes.Morph transition = shapes.Morph(polygons[0], polygons[1]);

    expect(polygon, isNotNull);
    expect(transition, isNotNull);
  });

  testWidgets('loading indicators accept material_new_shapes polygons', (
    tester,
  ) async {
    await tester.pumpWidget(
      material.MaterialApp(
        home: morph.MorphTheme(
          data: morph.MorphThemeData.light(),
          child: material.Scaffold(
            body: material.Column(
              children: <Widget>[
                morph.MorphLoadingIndicator(polygons: polygons),
                morph.MorphExpressiveLoadingIndicator(polygons: polygons),
              ],
            ),
          ),
        ),
      ),
    );

    expect(find.byType(morph.MorphLoadingIndicator), findsOneWidget);
    expect(
      find.byType(morph.MorphExpressiveLoadingIndicator),
      findsNWidgets(2),
    );
  });

  testWidgets('refresh indicator uses the same polygon implementation', (
    tester,
  ) async {
    await tester.pumpWidget(
      material.MaterialApp(
        home: morph.MorphTheme(
          data: morph.MorphThemeData.light(),
          child: material.Scaffold(
            body: morph.MorphRefreshIndicator(
              polygons: polygons,
              onRefresh: () async {},
              child: material.ListView(
                children: const <Widget>[material.SizedBox(height: 1000)],
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.byType(morph.MorphRefreshIndicator), findsOneWidget);
  });
}
