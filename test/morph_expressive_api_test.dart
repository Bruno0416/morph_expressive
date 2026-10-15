import 'package:flutter_test/flutter_test.dart';
import 'package:morph_expressive/morph_expressive.dart';

void main() {
  test('the public entrypoint exports the renamed Morph theme', () {
    final data = MorphThemeData.light();
    expect(data, isA<MorphThemeData>());
  });
}
