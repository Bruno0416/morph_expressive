import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morph_expressive/morph_expressive.dart';

import 'foundations_color_test_utils.dart';

void main() {
  for (final MapEntry<String, Color> seed in kFoundationsSeeds.entries) {
    for (final Brightness b in Brightness.values) {
      final MorphColorScheme s = MorphColorScheme.fromSeed(
        seed.value,
        brightness: b,
      );
      final String label = '${seed.key} / ${b.name}';

      group('MorphVariantPalette.of $label', () {
        test('primary maps to the primary roles', () {
          final MorphVariantPalette p = MorphVariantPalette.of(
            s,
            MorphVariant.primary,
          );
          expect(p.color, s.primary);
          expect(p.onColor, s.onPrimary);
          expect(p.container, s.primaryContainer);
          expect(p.onContainer, s.onPrimaryContainer);
          expect(p.accent, s.primary);
          expect(p.outline, s.outline);
        });

        test('secondary maps to the secondary roles', () {
          final MorphVariantPalette p = MorphVariant.secondary.resolve(s);
          expect(p.color, s.secondary);
          expect(p.onColor, s.onSecondary);
          expect(p.container, s.secondaryContainer);
          expect(p.onContainer, s.onSecondaryContainer);
          expect(p.accent, s.secondary);
          expect(p.outline, s.outline);
        });

        test('tertiary maps to the tertiary roles', () {
          final MorphVariantPalette p = MorphVariant.tertiary.resolve(s);
          expect(p.color, s.tertiary);
          expect(p.onColor, s.onTertiary);
          expect(p.container, s.tertiaryContainer);
          expect(p.onContainer, s.onTertiaryContainer);
          expect(p.accent, s.tertiary);
          expect(p.outline, s.outline);
        });

        test('muted uses neutral surface roles, not a chromatic role', () {
          final MorphVariantPalette p = MorphVariant.muted.resolve(s);
          expect(p.color, s.surfaceContainerHighest);
          expect(p.onColor, s.onSurface);
          expect(p.container, s.surfaceContainerHigh);
          expect(p.onContainer, s.onSurfaceVariant);
          expect(p.accent, s.onSurfaceVariant);
          expect(p.outline, s.outlineVariant);
          for (final Color c in <Color>[p.color, p.container]) {
            expect(c, isNot(s.primary));
            expect(c, isNot(s.secondaryContainer));
          }
        });

        test('danger uses the error roles', () {
          final MorphVariantPalette p = MorphVariant.danger.resolve(s);
          expect(p.color, s.error);
          expect(p.onColor, s.onError);
          expect(p.container, s.errorContainer);
          expect(p.onContainer, s.onErrorContainer);
          expect(p.accent, s.error);
          expect(p.outline, s.error);
        });

        // Chromatic variants and danger inherit the M3 tonal pairs (tone gap
        // >= 50), so color/onColor and container/onContainer meet AA (4.5:1).
        test('chromatic and danger pairs reach 4.5:1', () {
          for (final MorphVariant v in <MorphVariant>[
            MorphVariant.primary,
            MorphVariant.secondary,
            MorphVariant.tertiary,
            MorphVariant.danger,
          ]) {
            final MorphVariantPalette p = v.resolve(s);
            expect(
              contrastRatio(p.color, p.onColor),
              greaterThanOrEqualTo(4.5),
              reason: '${v.name} color/onColor',
            );
            expect(
              contrastRatio(p.container, p.onContainer),
              greaterThanOrEqualTo(4.5),
              reason: '${v.name} container/onContainer',
            );
          }
        });

        // Muted: color/onColor is surfaceContainerHighest vs onSurface
        // (tone gap ~70+) so 4.5:1 holds. The container slot pairs
        // surfaceContainerHigh with onSurfaceVariant (tone 30/80 vs ~92/17),
        // which M3 only guarantees at ~3:1 in the worst case, so assert that
        // lower bound for the container pair, and 4.5:1 for the primary pair.
        test('muted pairs keep readable contrast', () {
          final MorphVariantPalette p = MorphVariant.muted.resolve(s);
          expect(
            contrastRatio(p.color, p.onColor),
            greaterThanOrEqualTo(4.5),
            reason: 'color/onColor',
          );
          expect(
            contrastRatio(p.container, p.onContainer),
            greaterThanOrEqualTo(3),
            reason: 'container/onContainer',
          );
        });

        test('muted accent stays legible on the plain surface', () {
          // Accent text of outlined/text/elevated types sits on `surface`
          // (or surfaceContainerLow for elevated). 4.5:1 for normal text.
          final MorphVariantPalette p = MorphVariant.muted.resolve(s);
          expect(contrastRatio(p.accent, s.surface), greaterThanOrEqualTo(4.5));
          expect(
            contrastRatio(p.accent, s.surfaceContainerLow),
            greaterThanOrEqualTo(4.5),
          );
        });

        test('chromatic accents stay visible on surfaces (3:1)', () {
          // Accent is the role color itself (tone 40 light / 80 dark), used
          // for outlined/text content; 3:1 is the non-text/large-text floor
          // that tone gap against surface (T98/T6) guarantees.
          for (final MorphVariant v in <MorphVariant>[
            MorphVariant.primary,
            MorphVariant.secondary,
            MorphVariant.tertiary,
            MorphVariant.danger,
          ]) {
            expect(
              contrastRatio(v.resolve(s).accent, s.surface),
              greaterThanOrEqualTo(3),
              reason: v.name,
            );
          }
        });
      });
    }
  }

  group('MorphVariantPalette value semantics', () {
    final MorphColorScheme s = MorphColorScheme.light();

    test('resolve equals of and equality/hashCode are value based', () {
      for (final MorphVariant v in MorphVariant.values) {
        expect(v.resolve(s), MorphVariantPalette.of(s, v));
        expect(v.resolve(s).hashCode, MorphVariantPalette.of(s, v).hashCode);
      }
      expect(
        MorphVariant.primary.resolve(s),
        isNot(MorphVariant.danger.resolve(s)),
      );
    });

    test('light and dark schemes resolve differently', () {
      final MorphColorScheme dark = MorphColorScheme.dark();
      for (final MorphVariant v in MorphVariant.values) {
        expect(v.resolve(s), isNot(v.resolve(dark)), reason: v.name);
      }
    });

    test('a seed change updates the chromatic variants only', () {
      final MorphColorScheme other = MorphColorScheme.fromSeed(
        kFoundationsSeeds['red']!,
      );
      expect(
        MorphVariant.primary.resolve(s).color,
        isNot(MorphVariant.primary.resolve(other).color),
      );
      expect(
        MorphVariant.danger.resolve(s).color,
        MorphVariant.danger.resolve(other).color,
      );
    });

    test('all five variants are covered', () {
      expect(MorphVariant.values, hasLength(5));
      expect(MorphSurface.values, hasLength(2));
      expect(MorphSurface.frosted.isFrosted, isTrue);
      expect(MorphSurface.solid.isFrosted, isFalse);
    });
  });

  group('MorphColorScheme variant and contrast options', () {
    final Color seed = kFoundationsSeeds['blue']!;

    test('defaults are tonal spot with zero contrast (unchanged identity)', () {
      final MorphColorScheme implicit = MorphColorScheme.fromSeed(seed);
      final MorphColorScheme explicit = MorphColorScheme.fromSeed(
        seed,
        dynamicSchemeVariant: DynamicSchemeVariant.tonalSpot,
        contrastLevel: 0,
      );
      final Map<String, Color> a = morphRoles(implicit);
      final Map<String, Color> e = morphRoles(explicit);
      for (final String role in a.keys) {
        expect(a[role], e[role], reason: role);
      }
      expect(implicit.dynamicSchemeVariant, DynamicSchemeVariant.tonalSpot);
      expect(implicit.contrastLevel, 0);
      expect(implicit.seedColor, seed);
    });

    test('each variant produces its own palette', () {
      final Set<int> primaries = <int>{};
      for (final DynamicSchemeVariant v in DynamicSchemeVariant.values) {
        final MorphColorScheme s = MorphColorScheme.fromSeed(
          seed,
          dynamicSchemeVariant: v,
        );
        expect(s.dynamicSchemeVariant, v);
        primaries.add(s.secondaryContainer.toARGB32());
      }
      // At least tonalSpot, monochrome and a chromatic variant differ.
      expect(primaries.length, greaterThan(2));
    });

    test('monochrome is achromatic', () {
      final MorphColorScheme s = MorphColorScheme.fromSeed(
        seed,
        dynamicSchemeVariant: DynamicSchemeVariant.monochrome,
      );
      final Color p = s.primary;
      expect(p.r, closeTo(p.g, 0.02));
      expect(p.g, closeTo(p.b, 0.02));
    });

    test('contrast level raises the contrast of tonal pairs', () {
      for (final Brightness b in Brightness.values) {
        final MorphColorScheme normal = MorphColorScheme.fromSeed(
          seed,
          brightness: b,
        );
        final MorphColorScheme high = MorphColorScheme.fromSeed(
          seed,
          brightness: b,
          contrastLevel: 1,
        );
        final MorphColorScheme reduced = MorphColorScheme.fromSeed(
          seed,
          brightness: b,
          contrastLevel: -1,
        );
        double c(MorphColorScheme s) =>
            contrastRatio(s.primaryContainer, s.onPrimaryContainer);
        expect(c(high), greaterThanOrEqualTo(c(normal)));
        expect(c(reduced), lessThanOrEqualTo(c(normal)));
        expect(c(high), greaterThanOrEqualTo(7), reason: 'AAA at max contrast');
      }
    });

    test('every variant keeps AA on primary/onPrimary at contrast 0', () {
      for (final DynamicSchemeVariant v in DynamicSchemeVariant.values) {
        for (final Brightness b in Brightness.values) {
          final MorphColorScheme s = MorphColorScheme.fromSeed(
            seed,
            brightness: b,
            dynamicSchemeVariant: v,
          );
          expect(
            contrastRatio(s.primary, s.onPrimary),
            greaterThanOrEqualTo(4.5),
            reason: '${v.name} ${b.name}',
          );
          expect(
            contrastRatio(s.surface, s.onSurface),
            greaterThanOrEqualTo(4.5),
            reason: '${v.name} ${b.name}',
          );
        }
      }
    });

    test('MorphThemeData factories forward variant and contrast', () {
      final MorphThemeData light = MorphThemeData.light(
        seedColor: seed,
        dynamicSchemeVariant: DynamicSchemeVariant.expressive,
        contrastLevel: 0.5,
      );
      final MorphThemeData dark = MorphThemeData.dark(
        seedColor: seed,
        dynamicSchemeVariant: DynamicSchemeVariant.expressive,
        contrastLevel: 0.5,
      );
      expect(
        light.colorScheme.dynamicSchemeVariant,
        DynamicSchemeVariant.expressive,
      );
      expect(light.colorScheme.contrastLevel, 0.5);
      expect(dark.colorScheme.brightness, Brightness.dark);
      expect(
        dark.colorScheme.dynamicSchemeVariant,
        DynamicSchemeVariant.expressive,
      );
      expect(
        light.colorScheme.primary,
        isNot(MorphThemeData.light(seedColor: seed).colorScheme.primary),
      );
    });
  });
}
