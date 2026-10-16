import 'package:flutter_test/flutter_test.dart';
import 'package:morph_expressive/morph_components.dart';

void main() {
  final curves = <String, double Function(double)>{
    'wavy slider and range slider':
        const MorphSliderTheme().amplitudeForProgress,
    'linear wavy progress':
        const MorphLinearProgressTheme().amplitudeForProgress,
    'circular wavy progress':
        const MorphCircularProgressTheme().amplitudeForProgress,
  };

  for (final entry in curves.entries) {
    test('${entry.key} smoothly fades at both ends', () {
      final amplitude = entry.value;
      expect(amplitude(0), 0);
      expect(amplitude(0.10), 0);
      expect(amplitude(0.125), closeTo(0.5, 1e-10));
      expect(amplitude(0.15), 1);
      expect(amplitude(0.5), 1);
      expect(amplitude(0.90), 1);
      expect(amplitude(0.94), closeTo(0.5, 1e-10));
      expect(amplitude(0.95), closeTo(0.31640625, 1e-10));
      expect(amplitude(0.97), closeTo(0.04296875, 1e-10));
      expect(amplitude(0.98), 0);
      expect(amplitude(1), 0);

      // No sudden jump at the new 98% endpoint or the former 95% cutoff.
      expect(amplitude(0.98 - 0.0001), lessThan(0.00002));
      expect(amplitude(0.98 + 0.0001), 0);
      expect(amplitude(0.95 - 0.0001), greaterThan(amplitude(0.95)));
      expect(amplitude(0.95 + 0.0001), lessThan(amplitude(0.95)));
      expect(amplitude(0.10 + 0.0001), lessThan(0.00002));

      // Both transitions are monotone and remain normalized.
      var previous = 0.0;
      for (var i = 0; i <= 50; i++) {
        final current = amplitude(0.10 + i * 0.001);
        expect(current, inInclusiveRange(previous, 1));
        previous = current;
      }
      previous = 1.0;
      for (var i = 0; i <= 80; i++) {
        final current = amplitude(0.90 + i * 0.001);
        expect(current, inInclusiveRange(0, previous));
        previous = current;
      }
    });
  }
}
