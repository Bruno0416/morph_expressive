import 'dart:ui' show Path, Size;

import 'geometry/morph_contour.dart';

/// Converts normalized common-space cubics without re-centering/re-normalizing
/// each frame. Non-square sizes deliberately stretch x/y independently.
Path morphContourPath(MorphContour contour, Size size) {
  final path = Path();
  final first = contour.curves.first.start;
  path.moveTo(first.dx * size.width, first.dy * size.height);
  for (final c in contour.curves) {
    path.cubicTo(
      c.control1.dx * size.width,
      c.control1.dy * size.height,
      c.control2.dx * size.width,
      c.control2.dy * size.height,
      c.end.dx * size.width,
      c.end.dy * size.height,
    );
  }
  return path..close();
}
