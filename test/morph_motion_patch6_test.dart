import 'package:flutter_test/flutter_test.dart';
import 'package:morph_expressive/morph_expressive.dart';
import 'package:motor/motor.dart';

void main() {
  group('Morph Motion foundation', () {
    test('adapts custom springs to Motor without a Material preset', () {
      const spring = MorphSpring(stiffness: 960, damping: 0.87);
      expect(MorphMotion.springMotion(spring), isA<SpringMotion>());
      final description = spring.toDescription();
      expect(description.stiffness, 960);
      expect(description.damping, greaterThan(0));
    });

    test('custom spring description preserves theme-provided damping and stiffness', () {
      const gentle = MorphSpring(stiffness: 720, damping: 0.88);
      const responsive = MorphSpring(stiffness: 1400, damping: 1.0);

      expect(gentle.toDescription().stiffness, 720);
      expect(responsive.toDescription().stiffness, 1400);
      expect(
        gentle.toDescription().damping,
        lessThan(responsive.toDescription().damping),
      );
      expect(MorphMotion.springMotion(gentle), isA<SpringMotion>());
      expect(MorphMotion.springMotion(responsive), isA<SpringMotion>());
    });

    test('keeps bounded curves separate from spatial motion', () {
      for (final curve in [
        MorphMotion.enter,
        MorphMotion.exit,
        MorphMotion.standard,
      ]) {
        expect(curve.transform(0), closeTo(0, 0.0001));
        expect(curve.transform(1), closeTo(1, 0.0001));
        for (var step = 0; step <= 20; step++) {
          final value = curve.transform(step / 20);
          expect(value, inInclusiveRange(0, 1));
        }
      }
      expect(MorphMotion.spatial, same(MorphMotion.subtleOvershoot));
      expect(MorphMotion.effectsFast.damping, 1);
      expect(MorphMotion.expressiveSpatialDefault.damping, lessThan(1));
    });

    test('provides consistent selection and carousel durations', () {
      expect(MorphMotion.selectionFlip.inMilliseconds, 220);
      expect(MorphMotion.selectionExit.inMilliseconds, 90);
      expect(MorphMotion.carouselPulse.inMilliseconds, 180);
      expect(MorphMotion.carouselReturn.inMilliseconds, 220);
      expect(MorphMotion.medium2.inMilliseconds, 300);
    });

    test('shared tweens choreograph fast chips with bounded effects', () {
      expect(MorphMotion.chipDuration.inMilliseconds, 289);
      expect(MorphMotion.chipStretchDelay.inMilliseconds, 77);
      final trailing = MorphMotion.staggeredTween(
        begin: 10,
        end: 60,
        delayFraction: 0.3,
      );
      expect(trailing.transform(0), 10);
      expect(trailing.transform(0.2), 10);
      expect(trailing.transform(1), closeTo(60, 0.0001));
      final leading = MorphMotion.spatialTween(begin: 10, end: 60);
      expect(leading.transform(0.3), greaterThan(10));
      expect(leading.transform(1), closeTo(60, 0.0001));
      final effect = MorphMotion.effectsTween(begin: 0, end: 1);
      for (var i = 0; i <= 20; i++) {
        expect(effect.transform(i / 20), inInclusiveRange(0, 1));
      }
    });

    test('button presets retain the extensible custom spring API', () {
      expect(
        MorphButtonMotion.standard.stiffness,
        MorphMotion.buttonMorph.stiffness,
      );
      expect(
        MorphButtonMotion.standard.damping,
        MorphMotion.buttonMorph.damping,
      );
      expect(
        MorphButtonMotion.shapeMorph.stiffness,
        MorphMotion.buttonMorph.stiffness,
      );
      expect(
        MorphButtonMotion.shapeMorph.damping,
        MorphMotion.buttonMorph.damping,
      );
      const custom = MorphButtonMotion(stiffness: 820, damping: 0.91);
      expect(custom.toMotion(), isA<SpringMotion>());
      expect(custom, MorphButtonMotion.custom(820, 0.91));
    });
  });
}
