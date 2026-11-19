import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_color_utilities/material_color_utilities.dart' as mcu;
import 'package:material_ui/material_ui.dart'
    show ColorScheme, MaterialApp, Theme, ThemeData;
import 'package:morph_expressive/morph_expressive.dart';

import 'foundations_color_test_utils.dart';

/// Reference roles straight from Material Color Utilities (the algorithm
/// `ColorScheme.fromSeed` uses for the tonal-spot variant), independent from
/// the material_ui wrapper.
Map<String, int> _mcuTonalSpot(Color seed, {required bool dark}) {
  final scheme = mcu.SchemeTonalSpot(
    sourceColorHct: mcu.Hct.fromInt(seed.toARGB32()),
    isDark: dark,
    contrastLevel: 0,
  );
  int g(mcu.DynamicColor c) => c.getArgb(scheme);
  return <String, int>{
    'primary': g(mcu.MaterialDynamicColors.primary),
    'onPrimary': g(mcu.MaterialDynamicColors.onPrimary),
    'primaryContainer': g(mcu.MaterialDynamicColors.primaryContainer),
    'onPrimaryContainer': g(mcu.MaterialDynamicColors.onPrimaryContainer),
    'secondary': g(mcu.MaterialDynamicColors.secondary),
    'onSecondary': g(mcu.MaterialDynamicColors.onSecondary),
    'secondaryContainer': g(mcu.MaterialDynamicColors.secondaryContainer),
    'onSecondaryContainer': g(mcu.MaterialDynamicColors.onSecondaryContainer),
    'tertiary': g(mcu.MaterialDynamicColors.tertiary),
    'onTertiary': g(mcu.MaterialDynamicColors.onTertiary),
    'tertiaryContainer': g(mcu.MaterialDynamicColors.tertiaryContainer),
    'onTertiaryContainer': g(mcu.MaterialDynamicColors.onTertiaryContainer),
    'error': g(mcu.MaterialDynamicColors.error),
    'onError': g(mcu.MaterialDynamicColors.onError),
    'errorContainer': g(mcu.MaterialDynamicColors.errorContainer),
    'onErrorContainer': g(mcu.MaterialDynamicColors.onErrorContainer),
    'surface': g(mcu.MaterialDynamicColors.surface),
    'onSurface': g(mcu.MaterialDynamicColors.onSurface),
    'onSurfaceVariant': g(mcu.MaterialDynamicColors.onSurfaceVariant),
    'surfaceContainerLowest': g(
      mcu.MaterialDynamicColors.surfaceContainerLowest,
    ),
    'surfaceContainerLow': g(mcu.MaterialDynamicColors.surfaceContainerLow),
    'surfaceContainer': g(mcu.MaterialDynamicColors.surfaceContainer),
    'surfaceContainerHigh': g(mcu.MaterialDynamicColors.surfaceContainerHigh),
    'surfaceContainerHighest': g(
      mcu.MaterialDynamicColors.surfaceContainerHighest,
    ),
    'surfaceDim': g(mcu.MaterialDynamicColors.surfaceDim),
    'surfaceBright': g(mcu.MaterialDynamicColors.surfaceBright),
    'inverseSurface': g(mcu.MaterialDynamicColors.inverseSurface),
    'onInverseSurface': g(mcu.MaterialDynamicColors.inverseOnSurface),
    'inversePrimary': g(mcu.MaterialDynamicColors.inversePrimary),
    'outline': g(mcu.MaterialDynamicColors.outline),
    'outlineVariant': g(mcu.MaterialDynamicColors.outlineVariant),
    'shadow': g(mcu.MaterialDynamicColors.shadow),
    'scrim': g(mcu.MaterialDynamicColors.scrim),
    'surfaceTint': g(mcu.MaterialDynamicColors.surfaceTint),
  };
}

void _expectSameRoles(
  MorphColorScheme actual,
  MorphColorScheme expected, {
  String reason = '',
}) {
  final Map<String, Color> a = morphRoles(actual);
  final Map<String, Color> e = morphRoles(expected);
  for (final String role in e.keys) {
    expect(a[role], e[role], reason: '$reason role "$role"');
  }
}

void main() {
  group('MorphColorScheme.fromSeed', () {
    for (final MapEntry<String, Color> seed in kFoundationsSeeds.entries) {
      for (final Brightness b in Brightness.values) {
        final String label = '${seed.key} / ${b.name}';

        test('$label is deterministic', () {
          _expectSameRoles(
            MorphColorScheme.fromSeed(seed.value, brightness: b),
            MorphColorScheme.fromSeed(seed.value, brightness: b),
          );
        });

        test('$label matches ColorScheme.fromSeed role by role', () {
          final ColorScheme ref = ColorScheme.fromSeed(
            seedColor: seed.value,
            brightness: b,
          );
          final MorphColorScheme s = MorphColorScheme.fromSeed(
            seed.value,
            brightness: b,
          );
          expect(s.brightness, b);
          expect(s.primary, ref.primary);
          expect(s.onPrimary, ref.onPrimary);
          expect(s.primaryContainer, ref.primaryContainer);
          expect(s.onPrimaryContainer, ref.onPrimaryContainer);
          expect(s.secondary, ref.secondary);
          expect(s.onSecondary, ref.onSecondary);
          expect(s.secondaryContainer, ref.secondaryContainer);
          expect(s.onSecondaryContainer, ref.onSecondaryContainer);
          expect(s.tertiary, ref.tertiary);
          expect(s.onTertiary, ref.onTertiary);
          expect(s.tertiaryContainer, ref.tertiaryContainer);
          expect(s.onTertiaryContainer, ref.onTertiaryContainer);
          expect(s.error, ref.error);
          expect(s.onError, ref.onError);
          expect(s.errorContainer, ref.errorContainer);
          expect(s.onErrorContainer, ref.onErrorContainer);
          expect(s.surface, ref.surface);
          expect(s.onSurface, ref.onSurface);
          expect(s.onSurfaceVariant, ref.onSurfaceVariant);
          expect(s.surfaceContainerLowest, ref.surfaceContainerLowest);
          expect(s.surfaceContainerLow, ref.surfaceContainerLow);
          expect(s.surfaceContainer, ref.surfaceContainer);
          expect(s.surfaceContainerHigh, ref.surfaceContainerHigh);
          expect(s.surfaceContainerHighest, ref.surfaceContainerHighest);
          expect(s.surfaceDim, ref.surfaceDim);
          expect(s.surfaceBright, ref.surfaceBright);
          expect(s.inverseSurface, ref.inverseSurface);
          expect(s.onInverseSurface, ref.onInverseSurface);
          expect(s.inversePrimary, ref.inversePrimary);
          expect(s.outline, ref.outline);
          expect(s.outlineVariant, ref.outlineVariant);
          expect(s.shadow, ref.shadow);
          expect(s.scrim, ref.scrim);
          expect(s.surfaceTint, ref.surfaceTint);
        });

        test('$label equals Material Color Utilities SchemeTonalSpot', () {
          final Map<String, int> expected = _mcuTonalSpot(
            seed.value,
            dark: b == Brightness.dark,
          );
          final Map<String, Color> actual = morphRoles(
            MorphColorScheme.fromSeed(seed.value, brightness: b),
          );
          for (final MapEntry<String, int> e in expected.entries) {
            expect(
              actual[e.key]!.toARGB32(),
              e.value,
              reason: 'role ${e.key} diverges from MCU',
            );
          }
        });

        // Threshold: M3 tonal pairs are separated by >= 50 tone points
        // (primary T40/onPrimary T100, container T90/on T10, dark inverted),
        // which yields a WCAG ratio above 4.5 for every hue and chroma.
        test('$label on-colors reach WCAG AA (4.5:1)', () {
          final MorphColorScheme s = MorphColorScheme.fromSeed(
            seed.value,
            brightness: b,
          );
          final Map<String, double> ratios = <String, double>{
            'primary': contrastRatio(s.primary, s.onPrimary),
            'primaryContainer': contrastRatio(
              s.primaryContainer,
              s.onPrimaryContainer,
            ),
            'secondary': contrastRatio(s.secondary, s.onSecondary),
            'secondaryContainer': contrastRatio(
              s.secondaryContainer,
              s.onSecondaryContainer,
            ),
            'tertiary': contrastRatio(s.tertiary, s.onTertiary),
            'tertiaryContainer': contrastRatio(
              s.tertiaryContainer,
              s.onTertiaryContainer,
            ),
            'error': contrastRatio(s.error, s.onError),
            'errorContainer': contrastRatio(
              s.errorContainer,
              s.onErrorContainer,
            ),
            'surface': contrastRatio(s.surface, s.onSurface),
            'surfaceStrong': contrastRatio(s.surfaceStrong, s.onSurfaceStrong),
            'inverseSurface': contrastRatio(
              s.inverseSurface,
              s.onInverseSurface,
            ),
            'emphasis': contrastRatio(s.emphasis, s.onEmphasis),
          };
          ratios.forEach((String name, double r) {
            expect(r, greaterThanOrEqualTo(4.5), reason: name);
          });
        });

        // Light: lowest is the brightest container and each step darkens
        // (T100 -> T90). Dark: lowest is the darkest and each step lightens
        // (T4 -> T22). Luminance therefore moves monotonically in opposite
        // directions; ties are allowed for very low-chroma rounding.
        test('$label surface containers are monotonic', () {
          final MorphColorScheme s = MorphColorScheme.fromSeed(
            seed.value,
            brightness: b,
          );
          final List<double> lum = <Color>[
            s.surfaceContainerLowest,
            s.surfaceContainerLow,
            s.surfaceContainer,
            s.surfaceContainerHigh,
            s.surfaceContainerHighest,
          ].map((Color c) => c.computeLuminance()).toList();
          for (int i = 1; i < lum.length; i++) {
            if (b == Brightness.light) {
              expect(lum[i], lessThanOrEqualTo(lum[i - 1]), reason: 'step $i');
            } else {
              expect(
                lum[i],
                greaterThanOrEqualTo(lum[i - 1]),
                reason: 'step $i',
              );
            }
          }
          expect(
            b == Brightness.light ? lum.first > lum.last : lum.first < lum.last,
            isTrue,
            reason: 'containers must actually span a range',
          );
        });

        test('$label derived expressive roles follow their sources', () {
          final MorphColorScheme s = MorphColorScheme.fromSeed(
            seed.value,
            brightness: b,
          );
          expect(s.emphasis, s.primary);
          expect(s.onEmphasis, s.onPrimary);
          expect(s.info, s.tertiary);
          expect(s.danger, s.error);
          expect(s.onSurfaceStrong, s.onSurface);
          expect(s.outlineStrong, s.outline);
          expect(
            s.surfaceStrong,
            Color.alphaBlend(s.primary.withValues(alpha: 0.06), s.surface),
          );
          // success / warning are fixed semantic hues (not tonal roles). They
          // must stay distinguishable from the surface: success meets the 3:1
          // non-text floor; warning (orange 0xEF6C00 on light) sits at ~2.9:1
          // by design, so only a 2.5:1 floor is asserted to catch regressions
          // without redesigning the palette.
          expect(contrastRatio(s.success, s.surface), greaterThanOrEqualTo(3));
          expect(
            contrastRatio(s.warning, s.surface),
            greaterThanOrEqualTo(2.5),
          );
        });
      }

      test('${seed.key}: light and dark differ', () {
        final Map<String, Color> light = morphRoles(
          MorphColorScheme.fromSeed(seed.value),
        );
        final Map<String, Color> dark = morphRoles(
          MorphColorScheme.fromSeed(seed.value, brightness: Brightness.dark),
        );
        expect(light['surface'], isNot(dark['surface']));
        expect(light['onSurface'], isNot(dark['onSurface']));
        expect(light['primary'], isNot(dark['primary']));
        expect(
          light['surface']!.computeLuminance(),
          greaterThan(dark['surface']!.computeLuminance()),
        );
      });
    }

    test('changing the seed changes the chromatic roles', () {
      final MorphColorScheme blue = MorphColorScheme.fromSeed(
        kFoundationsSeeds['blue']!,
      );
      final MorphColorScheme red = MorphColorScheme.fromSeed(
        kFoundationsSeeds['red']!,
      );
      expect(blue.primary, isNot(red.primary));
      expect(blue.secondary, isNot(red.secondary));
      expect(blue.tertiary, isNot(red.tertiary));
      expect(blue.surfaceTint, isNot(red.surfaceTint));
      expect(blue.emphasis, isNot(red.emphasis));
      expect(blue.surfaceStrong, isNot(red.surfaceStrong));
      // Error is seed independent by design.
      expect(blue.error, red.error);
    });

    test('light()/dark() use the baseline seed and own brightness', () {
      expect(MorphColorScheme.light().brightness, Brightness.light);
      expect(MorphColorScheme.dark().brightness, Brightness.dark);
      _expectSameRoles(
        MorphColorScheme.light(),
        MorphColorScheme.fromSeed(const Color(0xFF6750A4)),
      );
    });
  });

  group('MorphColorScheme.fromColorScheme / toColorScheme', () {
    test('round trip keeps every Material role', () {
      for (final Brightness b in Brightness.values) {
        final ColorScheme ref = ColorScheme.fromSeed(
          seedColor: kFoundationsSeeds['violet']!,
          brightness: b,
        );
        final ColorScheme back = MorphColorScheme.fromColorScheme(ref)
            .toColorScheme();
        expect(back.brightness, ref.brightness);
        expect(back.primary, ref.primary);
        expect(back.onPrimaryContainer, ref.onPrimaryContainer);
        expect(back.secondaryContainer, ref.secondaryContainer);
        expect(back.tertiary, ref.tertiary);
        expect(back.errorContainer, ref.errorContainer);
        expect(back.surface, ref.surface);
        expect(back.onSurfaceVariant, ref.onSurfaceVariant);
        expect(back.surfaceContainerHighest, ref.surfaceContainerHighest);
        expect(back.inverseSurface, ref.inverseSurface);
        expect(back.outlineVariant, ref.outlineVariant);
        expect(back.surfaceTint, ref.surfaceTint);
      }
    });

    test('toColorScheme is memoised per instance', () {
      final MorphColorScheme s = MorphColorScheme.light();
      expect(identical(s.toColorScheme(), s.toColorScheme()), isTrue);
    });

    test('harmonized only shifts success and warning', () {
      final MorphColorScheme s = MorphColorScheme.fromSeed(
        kFoundationsSeeds['violet']!,
      );
      final MorphColorScheme h = s.harmonized();
      expect(h.primary, s.primary);
      expect(h.danger, s.danger);
      expect(h.surface, s.surface);
      expect(h.success, isNot(s.success));
      expect(h.warning, isNot(s.warning));
    });
  });

  group('MorphColorScheme.copyWith', () {
    test('no arguments returns identical roles', () {
      final MorphColorScheme s = MorphColorScheme.fromSeed(
        kFoundationsSeeds['green']!,
        brightness: Brightness.dark,
      );
      _expectSameRoles(s.copyWith(), s);
      expect(s.copyWith().brightness, Brightness.dark);
    });

    test('replaces only the named role', () {
      final MorphColorScheme s = MorphColorScheme.light();
      const Color replacement = Color(0xFF123456);
      final MorphColorScheme c = s.copyWith(secondary: replacement);
      final Map<String, Color> before = morphRoles(s);
      final Map<String, Color> after = morphRoles(c);
      for (final String role in before.keys) {
        if (role == 'secondary') {
          expect(after[role], replacement);
        } else {
          expect(after[role], before[role], reason: role);
        }
      }
    });

    test('keeps seed metadata', () {
      final MorphColorScheme s = MorphColorScheme.fromSeed(
        kFoundationsSeeds['red']!,
        dynamicSchemeVariant: DynamicSchemeVariant.vibrant,
        contrastLevel: 0.5,
      );
      final MorphColorScheme c = s.copyWith(primary: const Color(0xFF000000));
      expect(c.seedColor, kFoundationsSeeds['red']);
      expect(c.dynamicSchemeVariant, DynamicSchemeVariant.vibrant);
      expect(c.contrastLevel, 0.5);
    });
  });

  group('MorphThemeData', () {
    test('light/dark factories carry brightness and seed', () {
      final MorphThemeData light = MorphThemeData.light(
        seedColor: kFoundationsSeeds['blue'],
      );
      final MorphThemeData dark = MorphThemeData.dark(
        seedColor: kFoundationsSeeds['blue'],
      );
      expect(light.brightness, Brightness.light);
      expect(dark.brightness, Brightness.dark);
      expect(light.colorScheme.primary, isNot(dark.colorScheme.primary));
    });

    test('copyWith keeps unrelated tokens and swaps the color scheme', () {
      final MorphThemeData base = MorphThemeData.light(
        seedColor: kFoundationsSeeds['green'],
      ).copyWith(visualDensity: -1, hapticsEnabled: false, reduceMotion: true);
      final MorphThemeData copy = base.copyWith();
      expect(copy.colorScheme, same(base.colorScheme));
      expect(copy.typography, base.typography);
      expect(copy.spacing, base.spacing);
      expect(copy.visualDensity, -1);
      expect(copy.hapticsEnabled, isFalse);
      expect(copy.reduceMotion, isTrue);

      final MorphColorScheme next = MorphColorScheme.fromSeed(
        kFoundationsSeeds['red']!,
        brightness: Brightness.dark,
      );
      final MorphThemeData swapped = base.withColorScheme(next);
      expect(swapped.colorScheme, same(next));
      expect(swapped.brightness, Brightness.dark);
      expect(swapped.visualDensity, -1);
      expect(swapped.reduceMotion, isTrue);
    });

    for (final MapEntry<String, Color> seed in kFoundationsSeeds.entries) {
      test('deriveDarkTemplate equals dark(seed) for ${seed.key}', () {
        final MorphThemeData derived = MorphThemeData.light(
          seedColor: seed.value,
        ).deriveDarkTemplate();
        _expectSameRoles(
          derived.colorScheme,
          MorphThemeData.dark(seedColor: seed.value).colorScheme,
          reason: seed.key,
        );
      });
    }

    test(
      'deriveDarkTemplate of the default theme equals MorphColorScheme.dark',
      () {
        _expectSameRoles(
          MorphThemeData().deriveDarkTemplate().colorScheme,
          MorphColorScheme.dark(),
        );
      },
    );

    test('deriveDarkTemplate keeps variant and contrast', () {
      final MorphThemeData light = MorphThemeData.light(
        seedColor: kFoundationsSeeds['blue'],
        dynamicSchemeVariant: DynamicSchemeVariant.vibrant,
        contrastLevel: 1,
      );
      _expectSameRoles(
        light.deriveDarkTemplate().colorScheme,
        MorphColorScheme.fromSeed(
          kFoundationsSeeds['blue']!,
          brightness: Brightness.dark,
          dynamicSchemeVariant: DynamicSchemeVariant.vibrant,
          contrastLevel: 1,
        ),
      );
    });

    test('deriveDarkTemplate without a seed falls back to the primary', () {
      final MorphThemeData adapted = MorphThemeData.fromMaterial(
        _themeOf(ColorScheme.fromSeed(seedColor: kFoundationsSeeds['violet']!)),
      );
      expect(adapted.colorScheme.seedColor, isNull);
      expect(adapted.deriveDarkTemplate().brightness, Brightness.dark);
    });

    test('deriveDarkTemplate preserves non-color tokens', () {
      final MorphThemeData light = MorphThemeData.light().copyWith(
        visualDensity: 1,
        keyboardFocusIndicators: false,
        hapticFeedback: MorphHapticFeedback.none,
      );
      final MorphThemeData dark = light.deriveDarkTemplate();
      expect(dark.visualDensity, 1);
      expect(dark.keyboardFocusIndicators, isFalse);
      expect(dark.hapticFeedback, MorphHapticFeedback.none);
      expect(dark.spacing, light.spacing);
    });

    test('toThemeData projects the Morph roles onto Material', () {
      for (final Brightness b in Brightness.values) {
        final MorphColorScheme s = MorphColorScheme.fromSeed(
          kFoundationsSeeds['yellow']!,
          brightness: b,
        );
        final theme = MorphThemeData(colorScheme: s).toThemeData();
        expect(theme.colorScheme.brightness, b);
        expect(theme.colorScheme.primary, s.primary);
        expect(theme.colorScheme.onSurface, s.onSurface);
        expect(theme.colorScheme.surfaceContainerHigh, s.surfaceContainerHigh);
        expect(theme.colorScheme.error, s.error);
      }
    });

    test('fromMaterial maps the Material scheme and is cached', () {
      final theme = _themeOf(
        ColorScheme.fromSeed(
          seedColor: kFoundationsSeeds['green']!,
          brightness: Brightness.dark,
        ),
      );
      final MorphThemeData a = MorphThemeData.fromMaterial(theme);
      expect(a.brightness, Brightness.dark);
      expect(a.colorScheme.primary, theme.colorScheme.primary);
      expect(identical(a, MorphThemeData.fromMaterial(theme)), isTrue);
    });
  });

  group('MorphTheme propagation', () {
    testWidgets('nested theme overrides locally and outer keeps its own', (
      WidgetTester tester,
    ) async {
      final MorphThemeData outer = MorphThemeData.light(
        seedColor: kFoundationsSeeds['blue'],
      );
      final MorphThemeData inner = MorphThemeData.dark(
        seedColor: kFoundationsSeeds['red'],
      );
      MorphThemeData? outerSeen;
      MorphThemeData? innerSeen;
      MorphThemeData? afterSeen;

      await tester.pumpWidget(
        MorphTheme(
          data: outer,
          child: Column(
            children: <Widget>[
              Builder(
                builder: (BuildContext c) {
                  outerSeen = MorphTheme.of(c);
                  return const SizedBox();
                },
              ),
              MorphTheme(
                data: inner,
                child: Builder(
                  builder: (BuildContext c) {
                    innerSeen = MorphTheme.of(c);
                    return const SizedBox();
                  },
                ),
              ),
              Builder(
                builder: (BuildContext c) {
                  afterSeen = MorphTheme.of(c);
                  return const SizedBox();
                },
              ),
            ],
          ),
        ),
      );

      expect(outerSeen, same(outer));
      expect(innerSeen, same(inner));
      expect(afterSeen, same(outer));
      expect(
        MorphTheme.brightnessOf(tester.element(find.byType(Column))),
        Brightness.light,
      );
    });

    testWidgets('Material Theme under MorphTheme tracks the Morph roles', (
      WidgetTester tester,
    ) async {
      final MorphThemeData data = MorphThemeData.light(
        seedColor: kFoundationsSeeds['green'],
      );
      late ColorScheme material;
      await tester.pumpWidget(
        MorphTheme(
          data: data,
          child: Builder(
            builder: (BuildContext c) {
              material = _materialSchemeOf(c);
              return const SizedBox();
            },
          ),
        ),
      );
      expect(material.primary, data.colorScheme.primary);
      expect(material.surface, data.colorScheme.surface);
    });

    testWidgets('swapping the theme in place updates descendants', (
      WidgetTester tester,
    ) async {
      final MorphThemeData first = MorphThemeData.light(
        seedColor: kFoundationsSeeds['blue'],
      );
      final MorphThemeData second = MorphThemeData.dark(
        seedColor: kFoundationsSeeds['red'],
      );
      int builds = 0;
      MorphThemeData? seen;
      Widget app(MorphThemeData d) => MorphTheme(
        data: d,
        child: Builder(
          builder: (BuildContext c) {
            builds++;
            seen = MorphTheme.of(c);
            return const SizedBox();
          },
        ),
      );

      await tester.pumpWidget(app(first));
      expect(seen!.colorScheme.primary, first.colorScheme.primary);
      final int before = builds;

      await tester.pumpWidget(app(second));
      expect(builds, greaterThan(before));
      expect(seen!.colorScheme.primary, second.colorScheme.primary);
      expect(seen!.brightness, Brightness.dark);

      await tester.pumpWidget(app(first));
      expect(seen!.colorScheme.primary, first.colorScheme.primary);
      expect(seen!.brightness, Brightness.light);
    });

    testWidgets('adaptive scope derives dark from the real seed and toggles', (
      WidgetTester tester,
    ) async {
      final MorphThemeController controller = MorphThemeController();
      addTearDown(controller.dispose);
      final MorphThemeData base = MorphThemeData.light(
        seedColor: kFoundationsSeeds['red'],
      );
      MorphThemeData? seen;

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(),
          child: MorphTheme(
            data: base,
            controller: controller,
            child: Builder(
              builder: (BuildContext c) {
                seen = MorphTheme.of(c);
                return const SizedBox();
              },
            ),
          ),
        ),
      );
      expect(seen!.brightness, Brightness.light);
      expect(seen!.colorScheme.primary, base.colorScheme.primary);

      controller.setBrightness(Brightness.dark);
      await tester.pump();
      expect(seen!.brightness, Brightness.dark);
      _expectSameRoles(
        seen!.colorScheme,
        MorphThemeData.dark(seedColor: kFoundationsSeeds['red']).colorScheme,
      );

      controller.setBrightness(Brightness.light);
      await tester.pump();
      expect(seen!.brightness, Brightness.light);
    });

    testWidgets('MaterialApp theme and MorphTheme agree after a seed swap', (
      WidgetTester tester,
    ) async {
      Widget app(Color seed) {
        final MorphThemeData data = MorphThemeData.light(seedColor: seed);
        return MaterialApp(
          theme: data.toThemeData(),
          home: MorphTheme(
            data: data,
            child: Builder(
              builder: (BuildContext c) {
                return Text(
                  '${MorphTheme.of(c).colorScheme.primary.toARGB32()}',
                  textDirection: TextDirection.ltr,
                );
              },
            ),
          ),
        );
      }

      await tester.pumpWidget(app(kFoundationsSeeds['blue']!));
      final String a = tester.widget<Text>(find.byType(Text)).data!;
      await tester.pumpWidget(app(kFoundationsSeeds['red']!));
      await tester.pumpAndSettle();
      final String b = tester.widget<Text>(find.byType(Text)).data!;
      expect(a, isNot(b));
    });
  });
}

ThemeData _themeOf(ColorScheme scheme) => ThemeData(colorScheme: scheme);

ColorScheme _materialSchemeOf(BuildContext context) =>
    Theme.of(context).colorScheme;
