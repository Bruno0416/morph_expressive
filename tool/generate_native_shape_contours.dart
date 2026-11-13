// Run explicitly with: flutter test tool/generate_native_shape_contours.dart
// The generator reads only material_new_shapes' public API. No private imports.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_new_shapes/material_new_shapes.dart'
    show MaterialShapes, RoundedPolygon;

void main() {
  test('generate immutable native contour definitions from pinned reference', () {
    final definitions = <String, RoundedPolygon>{
      'circle': MaterialShapes.circle,
      'softBurst': MaterialShapes.softBurst,
      'cookie9Sided': MaterialShapes.cookie9Sided,
      'pentagon': MaterialShapes.pentagon,
      'pill': MaterialShapes.pill,
      'sunny': MaterialShapes.sunny,
      'cookie4Sided': MaterialShapes.cookie4Sided,
      'oval': MaterialShapes.oval,
      'cookie7Sided': MaterialShapes.cookie7Sided,
    };
    final output = StringBuffer('''// GENERATED CODE - DO NOT MODIFY BY HAND.
// Reference: material_new_shapes 1.0.0, public MaterialShapes.*.cubics.
// Reference-derived fixed cubic definitions, generated for Morph Expressive.
// Original package license: MIT. See NOTICE for attribution.
// This is control-point data, not sampled polylines or a morph implementation.
const nativeShapeContours = <String, List<List<double>>>{
''');
    for (final entry in definitions.entries) {
      output.writeln("'${entry.key}': [");
      for (final c in entry.value.cubics) {
        output.writeln(
          '[${[c.anchor0X, c.anchor0Y, c.control0X, c.control0Y, c.control1X, c.control1Y, c.anchor1X, c.anchor1Y].join(',')}],',
        );
      }
      output.writeln('],');
    }
    output.writeln('};');
    File('lib/foundations/shape/geometry/native_shape_contours.g.dart')
        .writeAsStringSync(output.toString());
  });
}
