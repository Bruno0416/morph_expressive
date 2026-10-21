import 'package:flutter/painting.dart' show Size;
import 'package:flutter_test/flutter_test.dart';
import 'package:material_new_shapes/material_new_shapes.dart'
    as shapes
    show RoundedPolygon;
import 'package:material_ui/material_ui.dart'
    as material
    show Column, MaterialApp, Scaffold, SizedBox;
import 'package:morph_expressive/foundations/foundations.dart'
    as foundations
    show RoundedPolygon;
import 'package:morph_expressive/morph_components.dart'
    as components
    show RoundedPolygon;
import 'package:morph_expressive/morph_expressive.dart'
    show
        Morph,
        MorphLoadingIndicator,
        MorphMaterialNewShapes,
        MorphRefreshIndicator,
        MorphShapeClipper,
        MorphShapeKind,
        MorphSlider,
        MorphTheme,
        MorphThemeData,
        MorphToPathExtension,
        RoundedPolygon,
        RoundedPolygonToPathExtension;

void main() {
  final List<RoundedPolygon> polygons = [
    MorphMaterialNewShapes.circle,
    MorphMaterialNewShapes.square,
  ];

  test('all public entrypoints preserve the original polygon type', () {
    final shapes.RoundedPolygon original = polygons.first;
    final components.RoundedPolygon component = original;
    final foundations.RoundedPolygon foundation = component;
    final RoundedPolygon public = foundation;

    expect(identical(public, polygons.first), isTrue);
    expect(public.toPath().getBounds().isEmpty, isFalse);
    expect(
      Morph(polygons[0], polygons[1]).toPath(progress: 0.5).getBounds().isEmpty,
      isFalse,
    );
  });

  test('the complete catalog still clips through material_new_shapes', () {
    for (final kind in MorphShapeKind.values) {
      final shapes.RoundedPolygon polygon = kind.polygon;
      expect(polygon.toPath().getBounds().isEmpty, isFalse, reason: '$kind');
      final bounds = MorphShapeClipper(kind)
          .getClip(const Size(40, 60))
          .getBounds();
      expect(bounds.width, closeTo(40, 0.01), reason: '$kind');
      expect(bounds.height, closeTo(60, 0.01), reason: '$kind');
    }
  });

  testWidgets('loading, refresh and slider coexist with Material UI', (
    tester,
  ) async {
    await tester.pumpWidget(
      material.MaterialApp(
        home: MorphTheme(
          data: MorphThemeData.light(),
          child: material.Scaffold(
            body: material.Column(
              children: [
                MorphLoadingIndicator(polygons: polygons),
                MorphSlider(value: 0.5, onChanged: (_) {}),
                material.SizedBox(
                  height: 120,
                  child: MorphRefreshIndicator(
                    polygons: polygons,
                    onRefresh: () async {},
                    child: const material.SizedBox(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));
    expect(tester.takeException(), isNull);
    expect(find.byType(MorphSlider), findsOneWidget);
    expect(find.byType(MorphLoadingIndicator), findsOneWidget);
    expect(find.byType(MorphRefreshIndicator), findsOneWidget);
  });
}
