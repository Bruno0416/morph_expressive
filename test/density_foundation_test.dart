import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart'
    show
        Brightness,
        BuildContext,
        Builder,
        Center,
        Color,
        Column,
        ColorScheme,
        MainAxisSize,
        Scaffold,
        Text,
        ThemeData,
        Widget;
import 'package:morph_expressive/morph_components.dart';

const Color _seed = Color(0xFF6750A4);

Widget _app(MorphThemeData data, Widget child) {
  return MorphMaterialApp(
    data: data,
    home: Scaffold(body: Center(child: child)),
  );
}

void main() {
  group('density foundation', () {
    test('default theme is standard with zero deltas', () {
      final MorphThemeData theme = MorphThemeData.light(seedColor: _seed);
      expect(theme.density, MorphDensity.standard);
      expect(theme.densityMetrics, MorphDensityMetrics.standard);
      expect(theme.densitySpacing.md, theme.spacing.md);
      final MorphDensityMetrics zero = MorphDensity.standard.metrics;
      expect(zero.controlHeight, everyElement(0));
      expect(zero.rowHeight, 0);
      expect(zero.paddingHorizontal, 0);
      expect(zero.paddingVertical, 0);
      expect(zero.gap, 0);
      expect(zero.iconSize, 0);
    });

    test('metrics are monotonic compact <= standard <= comfortable', () {
      final MorphDensityMetrics c = MorphDensity.compact.metrics;
      final MorphDensityMetrics s = MorphDensity.standard.metrics;
      final MorphDensityMetrics f = MorphDensity.comfortable.metrics;
      for (int step = 0; step < 5; step++) {
        expect(
          c.controlHeightFor(step),
          lessThanOrEqualTo(s.controlHeightFor(step)),
        );
        expect(
          s.controlHeightFor(step),
          lessThanOrEqualTo(f.controlHeightFor(step)),
        );
      }
      expect(c.rowHeight, lessThan(s.rowHeight));
      expect(f.rowHeight, greaterThan(s.rowHeight));
      expect(c.gap, lessThan(f.gap));
      expect(c.paddingHorizontal, lessThan(f.paddingHorizontal));
      expect(c.iconSize, lessThanOrEqualTo(f.iconSize));
    });

    test('adjust never goes below its floor', () {
      expect(MorphDensityMetrics.adjust(4, -8), 0);
      expect(MorphDensityMetrics.adjust(30, -8, min: 28), 28);
      expect(MorphDensityMetrics.adjust(40, 4), 44);
    });

    test('density spacing keeps the scale ordered and non-negative', () {
      for (final MorphDensity d in MorphDensity.values) {
        final MorphSpacing s = d.metrics.spacing(const MorphSpacing.regular());
        expect(s.xs, greaterThanOrEqualTo(0));
        expect(s.xs, lessThanOrEqualTo(s.sm));
        expect(s.sm, lessThanOrEqualTo(s.md));
        expect(s.md, lessThanOrEqualTo(s.lg));
        expect(s.lg, lessThanOrEqualTo(s.xl));
        expect(s.xl, lessThanOrEqualTo(s.xxl));
      }
    });

    test('copyWith sets and preserves density', () {
      final MorphThemeData base = MorphThemeData.light(seedColor: _seed);
      final MorphThemeData compact = base.copyWith(
        density: MorphDensity.compact,
      );
      expect(compact.density, MorphDensity.compact);
      expect(compact.copyWith(visualDensity: 1).density, MorphDensity.compact);
      expect(
        compact.copyWith(density: MorphDensity.comfortable).density,
        MorphDensity.comfortable,
      );
      expect(base.density, MorphDensity.standard);
    });

    test('factories and Material adaptation accept a density', () {
      expect(
        MorphThemeData.light(
          seedColor: _seed,
          density: MorphDensity.compact,
        ).density,
        MorphDensity.compact,
      );
      expect(
        MorphThemeData.dark(
          seedColor: _seed,
          density: MorphDensity.comfortable,
        ).density,
        MorphDensity.comfortable,
      );
      final ThemeData material = ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: _seed),
      );
      expect(
        MorphThemeData.fromMaterial(material).density,
        MorphDensity.standard,
      );
      expect(
        MorphThemeData.fromMaterial(
          material,
          density: MorphDensity.compact,
        ).density,
        MorphDensity.compact,
      );
      // The cached adaptation stays standard after a density request.
      expect(
        MorphThemeData.fromMaterial(material).density,
        MorphDensity.standard,
      );
    });

    test('light and derived dark themes keep the density', () {
      final MorphThemeData light = MorphThemeData.light(
        seedColor: _seed,
        density: MorphDensity.compact,
      );
      final MorphThemeData dark = light.deriveDarkTemplate();
      expect(dark.density, MorphDensity.compact);
      expect(dark.brightness, Brightness.dark);
      expect(
        light
            .copyWith(density: MorphDensity.comfortable)
            .deriveDarkTemplate()
            .density,
        MorphDensity.comfortable,
      );
      expect(
        light.withColorScheme(MorphColorScheme.dark()).density,
        MorphDensity.compact,
      );
    });

    testWidgets('MorphMaterialApp light and dark both follow the density', (
      WidgetTester tester,
    ) async {
      for (final Brightness b in Brightness.values) {
        late MorphThemeData seen;
        await tester.pumpWidget(
          MorphMaterialApp(
            data: MorphThemeData.light(
              seedColor: _seed,
              density: MorphDensity.compact,
            ),
            initialTheme: b,
            home: Scaffold(
              body: Builder(
                builder: (BuildContext context) {
                  seen = MorphTheme.of(context);
                  return const Text('x');
                },
              ),
            ),
          ),
        );
        await tester.pump();
        expect(seen.density, MorphDensity.compact);
        expect(seen.brightness, b);
      }
    });

    testWidgets('a nested MorphTheme overrides the density for its subtree', (
      WidgetTester tester,
    ) async {
      final MorphThemeData base = MorphThemeData.light(seedColor: _seed);
      late MorphDensity outer;
      late MorphDensity inner;
      await tester.pumpWidget(
        _app(
          base.copyWith(density: MorphDensity.comfortable),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Builder(
                builder: (BuildContext context) {
                  outer = MorphTheme.of(context).density;
                  return const Text('outer');
                },
              ),
              MorphTheme(
                data: base.copyWith(density: MorphDensity.compact),
                child: Builder(
                  builder: (BuildContext context) {
                    inner = MorphTheme.of(context).density;
                    return const Text('inner');
                  },
                ),
              ),
            ],
          ),
        ),
      );
      expect(outer, MorphDensity.comfortable);
      expect(inner, MorphDensity.compact);
    });

    testWidgets('changing the density rebuilds dependents at runtime', (
      WidgetTester tester,
    ) async {
      final List<MorphDensity> seen = <MorphDensity>[];
      final Widget probe = Builder(
        builder: (BuildContext context) {
          seen.add(MorphTheme.of(context).density);
          return const Text('probe');
        },
      );
      final MorphThemeData base = MorphThemeData.light(seedColor: _seed);
      for (final MorphDensity d in <MorphDensity>[
        MorphDensity.standard,
        MorphDensity.compact,
        MorphDensity.comfortable,
        MorphDensity.standard,
      ]) {
        await tester.pumpWidget(_app(base.copyWith(density: d), probe));
        await tester.pumpAndSettle();
        expect(seen.last, d);
      }
    });
  });
}
