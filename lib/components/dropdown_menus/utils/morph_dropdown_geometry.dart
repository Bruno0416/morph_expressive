import 'dart:math' as math;

import 'package:flutter/widgets.dart';

// ---------- geometria del dropdown ----------

/// Mantiene las esquinas interiores concéntricas con el panel.
abstract final class MorphDropdownGeometry {
  const MorphDropdownGeometry._();

  /// El radio interior es el radio exterior menos el espacio del panel.
  ///
  /// En padding asimetrico se utiliza el mayor lado para evitar que
  /// las esquinas interiores sobrepasen el contorno exterior.
  static double innerRadius({
    required double outerRadius,
    required EdgeInsetsGeometry padding,
    required TextDirection direction,
  }) {
    final inset = padding.resolve(direction);
    final distance = math.max(
      math.max(inset.left, inset.right),
      math.max(inset.top, inset.bottom),
    );
    return math.max(0.0, outerRadius - distance);
  }
}
