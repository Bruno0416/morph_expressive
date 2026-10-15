import 'package:flutter_test/flutter_test.dart';
import 'package:morph_expressive/morph_components.dart';

void main() {
  test('MorphSpacing.regular aliases MorphDimensions space steps', () {
    const spacing = MorphSpacing.regular();
    expect(spacing.xs, MorphDimensions.spaceXs);
    expect(spacing.sm, MorphDimensions.spaceSm);
    expect(spacing.md, MorphDimensions.spaceMd);
    expect(spacing.lg, MorphDimensions.spaceLg);
    expect(spacing.xl, MorphDimensions.spaceXl);
    expect(spacing.xxl, MorphDimensions.spaceXxl);
  });

  test('MorphShapes radius aliases MorphDimensions', () {
    expect(MorphShapes.none, MorphDimensions.radiusNone);
    expect(MorphShapes.small, MorphDimensions.radiusSmall);
    expect(MorphShapes.largeIncreased, MorphDimensions.radiusLargeIncreased);
    expect(MorphShapes.full, MorphDimensions.radiusFull);
    expect(MorphShapes.radiusMedium, MorphDimensions.borderRadiusMedium);
    expect(MorphShapes.resolve(12), MorphDimensions.resolveRadius(12));
  });
}
