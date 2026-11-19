import 'package:flutter_test/flutter_test.dart';
import 'package:morph_expressive/components/shared/morph_surface_glass_resolution.dart';
import 'package:morph_expressive/morph_expressive.dart';
import 'package:material_ui/material_ui.dart' show Brightness, Color, Colors;

double _contrast(Color a, Color b) {
  final double la = a.computeLuminance();
  final double lb = b.computeLuminance();
  return ((la > lb ? la : lb) + 0.05) / ((la > lb ? lb : la) + 0.05);
}

double _worstContrast(Color base, double opacity, Color content) {
  double worst = double.infinity;
  for (final Color backdrop in const <Color>[Colors.white, Colors.black]) {
    final Color tint = Color.alphaBlend(
      base.withValues(alpha: base.a * opacity),
      backdrop,
    );
    final double c = _contrast(tint, content);
    if (c < worst) {
      worst = c;
    }
  }
  return worst;
}

void main() {
  const MorphSurfaceGlass glass = MorphSurfaceGlass();

  group('morphLegibleGlass', () {
    for (final Brightness brightness in Brightness.values) {
      for (final MorphVariant variant in MorphVariant.values) {
        test('${brightness.name} ${variant.name} filled and tonal reach 4.5:1 '
            'over white and black backdrops', () {
          final MorphColorScheme scheme = MorphColorScheme.fromSeed(
            const Color(0xFF6750A4),
            brightness: brightness,
          );
          final MorphVariantPalette p = variant.resolve(scheme);
          for (final (Color base, Color content) in <(Color, Color)>[
            (p.color, p.onColor),
            (p.container, p.onContainer),
          ]) {
            final MorphSurfaceGlass result = morphLegibleGlass(
              glass,
              base: base,
              content: content,
            );
            expect(result.tintOpacity, greaterThanOrEqualTo(glass.tintOpacity));
            expect(
              _worstContrast(base, result.tintOpacity, content),
              greaterThanOrEqualTo(4.5),
            );
          }
        });
      }
    }

    test('high-contrast content keeps the configured translucency', () {
      final MorphColorScheme scheme = MorphColorScheme.fromSeed(
        const Color(0xFF6750A4),
      );
      final MorphSurfaceGlass result = morphLegibleGlass(
        glass,
        base: Colors.white,
        content: Colors.black,
      );
      expect(identical(result, glass), isTrue);
      expect(scheme.brightness, Brightness.light);
    });

    test('an explicit tint or a disabled glass is never changed', () {
      const MorphSurfaceGlass tinted = MorphSurfaceGlass(
        tint: Color(0xFF6750A4),
        tintOpacity: 0.3,
      );
      expect(
        identical(
          morphLegibleGlass(tinted, base: tinted.tint!, content: Colors.white),
          tinted,
        ),
        isTrue,
      );
      const MorphSurfaceGlass off = MorphSurfaceGlass.disabled();
      expect(
        identical(
          morphLegibleGlass(
            off,
            base: const Color(0xFF6750A4),
            content: Colors.white,
          ),
          off,
        ),
        isTrue,
      );
    });

    test('icon buttons may use the 3:1 graphical-object threshold', () {
      final MorphColorScheme scheme = MorphColorScheme.fromSeed(
        const Color(0xFF6750A4),
      );
      final MorphSurfaceGlass icon = morphLegibleGlass(
        glass,
        base: scheme.primary,
        content: scheme.onPrimary,
        minContrast: 3,
      );
      final MorphSurfaceGlass text = morphLegibleGlass(
        glass,
        base: scheme.primary,
        content: scheme.onPrimary,
      );
      expect(icon.tintOpacity, lessThanOrEqualTo(text.tintOpacity));
      expect(
        _worstContrast(scheme.primary, icon.tintOpacity, scheme.onPrimary),
        greaterThanOrEqualTo(3),
      );
    });
  });
}
