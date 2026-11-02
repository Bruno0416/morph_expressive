import 'package:flutter_test/flutter_test.dart';
import 'package:morph_expressive/morph_expressive.dart';

void main() {
  test('default strength follows the native Flutter drag model', () {
    const behavior = MorphScrollBehavior();
    expect(behavior.maxStretch, 1.0);
    expect(behavior.stretchGain, 1.0);
    expect(behavior.releaseDuration, const Duration(milliseconds: 330));
  });
}
