import 'dart:ui' show Offset;

import 'package:material_new_shapes/material_new_shapes.dart'
    show RoundedPolygon;

import '../morph_shape_kind.dart';
import 'morph_geometry_engine.dart';
import 'native_shape_contours.g.dart';
export 'morph_geometry_engine.dart';

enum MorphShapeProvenance { native, adapted }

/// Geometry definition independent of its Canvas/Shader presentation.
class MorphShape {
  const MorphShape({
    required this.name,
    required this.contour,
    this.provenance = MorphShapeProvenance.native,
  });
  final String name;
  final MorphContour contour;
  final MorphShapeProvenance provenance;

  factory MorphShape.ellipse({double width = 1, double height = 1}) {
    if (!width.isFinite ||
        !height.isFinite ||
        width <= 0 ||
        height <= 0 ||
        width > 1 ||
        height > 1) {
      throw ArgumentError('Ellipse dimensions must be finite and in (0, 1].');
    }
    const k = .5522847498307936;
    final x = width / 2, y = height / 2;
    const o = Offset(.5, .5);
    MorphCubic c(Offset a, Offset b, Offset d, Offset e) =>
        MorphCubic(a + o, b + o, d + o, e + o);
    return _MorphEllipse(
      width,
      height,
      MorphContour([
        c(Offset(x, 0), Offset(x, k * y), Offset(k * x, y), Offset(0, y)),
        c(Offset(0, y), Offset(-k * x, y), Offset(-x, k * y), Offset(-x, 0)),
        c(Offset(-x, 0), Offset(-x, -k * y), Offset(-k * x, -y), Offset(0, -y)),
        c(Offset(0, -y), Offset(k * x, -y), Offset(x, -k * y), Offset(x, 0)),
      ]),
    );
  }

  /// Procedural GPU capability is restricted to verified ellipse definitions.
  /// Captured arbitrary contours cannot claim this capability.
  Offset? get ellipseRadii => null;

  factory MorphShape.fromPolygon(
    RoundedPolygon polygon, {
    String name = 'custom',
  }) => MorphShape(
    name: name,
    provenance: MorphShapeProvenance.adapted,
    contour: MorphContour(
      polygon.cubics.map(
        (c) => MorphCubic(
          Offset(c.anchor0X, c.anchor0Y),
          Offset(c.control0X, c.control0Y),
          Offset(c.control1X, c.control1Y),
          Offset(c.anchor1X, c.anchor1Y),
        ),
      ),
    ),
  );
}

class _MorphEllipse extends MorphShape {
  _MorphEllipse(double width, double height, MorphContour contour)
    : _radii = Offset(width / 2, height / 2),
      super(name: 'ellipse', contour: contour);
  final Offset _radii;
  @override
  Offset get ellipseRadii => _radii;
}

/// Additive geometry catalog; legacy tokens and polygon identities are intact.
class MorphShapeCatalog {
  MorphShapeCatalog._();
  static final Map<MorphShapeKind, MorphShape> _cache = {};
  static MorphShape fromKind(MorphShapeKind kind) =>
      _cache.putIfAbsent(kind, () {
        final data = nativeShapeContours[kind.name];
        if (data == null) {
          return MorphShape.fromPolygon(kind.polygon, name: kind.name);
        }
        return MorphShape(
          name: kind.name,
          contour: MorphContour(
            data.map(
              (c) => MorphCubic(
                Offset(c[0], c[1]),
                Offset(c[2], c[3]),
                Offset(c[4], c[5]),
                Offset(c[6], c[7]),
              ),
            ),
          ),
        );
      });
  static List<MorphShape> get all =>
      List.unmodifiable(MorphShapeKind.values.map(fromKind));
  static MorphShape get circle => fromKind(MorphShapeKind.circle);
  static MorphShape get oval => fromKind(MorphShapeKind.oval);
  static MorphShape get softBurst => fromKind(MorphShapeKind.softBurst);
  static MorphShape get cookie9Sided => fromKind(MorphShapeKind.cookie9Sided);
  static MorphShape get pentagon => fromKind(MorphShapeKind.pentagon);
  static MorphShape get pill => fromKind(MorphShapeKind.pill);
  static MorphShape get sunny => fromKind(MorphShapeKind.sunny);
  static MorphShape get cookie4Sided => fromKind(MorphShapeKind.cookie4Sided);
  static MorphShape get cookie7Sided => fromKind(MorphShapeKind.cookie7Sided);
}
