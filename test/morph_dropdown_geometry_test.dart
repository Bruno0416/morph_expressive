import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morph_expressive/components/dropdown_menus/utils/morph_dropdown_geometry.dart';

void main() {
  test('radius interno coincide con el externo menos el padding', () {
    expect(
      MorphDropdownGeometry.innerRadius(
        outerRadius: 28,
        padding: const EdgeInsets.all(8),
        direction: TextDirection.ltr,
      ),
      20,
    );
  });

  test('el radio no puede ser negativo', () {
    expect(
      MorphDropdownGeometry.innerRadius(
        outerRadius: 8,
        padding: const EdgeInsets.all(16),
        direction: TextDirection.rtl,
      ),
      0,
    );
  });
}
