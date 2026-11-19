import 'package:flutter_test/flutter_test.dart';
import 'package:morph_expressive/morph_components.dart';
import 'package:material_ui/material_ui.dart'
    show
        Align,
        Alignment,
        Brightness,
        Color,
        Container,
        DefaultTextStyle,
        FontWeight,
        Key,
        MediaQuery,
        MediaQueryData,
        Rect,
        Scaffold,
        SizedBox,
        TextScaler,
        Widget;

const Key _contentKey = Key('badge-content');
const Color _seed = Color(0xFF6750A4);

const List<Color> _seeds = <Color>[
  Color(0xFF6750A4),
  Color(0xFF2196F3),
  Color(0xFFFFEB3B),
  Color(0xFF00FF40),
  Color(0xFF050505),
];

double _contrast(Color a, Color b) {
  final double la = a.computeLuminance();
  final double lb = b.computeLuminance();
  final double hi = la > lb ? la : lb;
  final double lo = la > lb ? lb : la;
  return (hi + 0.05) / (lo + 0.05);
}

Widget _host(
  Widget child, {
  MorphDensity density = MorphDensity.standard,
  Brightness brightness = Brightness.light,
  Color seed = _seed,
  double textScale = 1,
}) {
  final MorphThemeData base = brightness == Brightness.dark
      ? MorphThemeData.dark(seedColor: seed)
      : MorphThemeData.light(seedColor: seed);
  return MorphMaterialApp(
    data: base.copyWith(density: density),
    home: Scaffold(
      body: MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
        child: Align(alignment: Alignment.center, child: child),
      ),
    ),
  );
}

Widget _badge({int? count, String? label}) => MorphBadge(
  count: count,
  label: label,
  child: const SizedBox(key: _contentKey, width: 40, height: 40),
);

void main() {
  group('badge refinement', () {
    test('standard theme anchors', () {
      const MorphBadgeTheme t = MorphBadgeTheme.defaults;
      expect(t.labelFontWeight, FontWeight.w600);
      expect(t.labelFontSize, 11);
      expect(t.labelHorizontalPadding, 5);
      expect(t.labelVerticalPadding, 1);
      expect(t.labelMinSize, 18);
      expect(t.dotSize, 6);
      // Pill: radius is half the minimum height.
      expect(t.labelCornerRadius, t.labelMinSize / 2);
    });

    test('density table is monotonic and never touches type or dot', () {
      const MorphBadgeTheme base = MorphBadgeTheme.defaults;
      final MorphBadgeTheme c = base.resolveDensity(MorphDensity.compact);
      final MorphBadgeTheme s = base.resolveDensity(MorphDensity.standard);
      final MorphBadgeTheme f = base.resolveDensity(MorphDensity.comfortable);
      expect(identical(s, base), isTrue);
      expect(c.labelHorizontalPadding, lessThan(s.labelHorizontalPadding));
      expect(f.labelHorizontalPadding, greaterThan(s.labelHorizontalPadding));
      expect(c.labelVerticalPadding, lessThan(s.labelVerticalPadding));
      expect(f.labelVerticalPadding, greaterThan(s.labelVerticalPadding));
      expect(c.labelMinSize, lessThan(s.labelMinSize));
      expect(f.labelMinSize, greaterThan(s.labelMinSize));
      for (final MorphBadgeTheme t in <MorphBadgeTheme>[c, f]) {
        expect(t.labelFontSize, base.labelFontSize);
        expect(t.labelFontWeight, base.labelFontWeight);
        expect(t.labelLineHeight, base.labelLineHeight);
        expect(t.dotSize, base.dotSize);
        expect(t.dotCornerRadius, base.dotCornerRadius);
      }
      // Compact keeps the legacy 16dp footprint.
      expect(c.labelMinSize, 16);
      expect(c.labelVerticalPadding, 0);
    });

    test('component theme density wins over the global density', () {
      const MorphBadgeTheme pinned = MorphBadgeTheme(
        density: MorphDensity.comfortable,
      );
      expect(
        pinned.resolveDensity(MorphDensity.compact).labelMinSize,
        MorphBadgeTheme.defaults.labelMinSize + 1,
      );
    });

    test('text contrast is at least 4.5 for scheme roles, light and dark', () {
      for (final Color seed in _seeds) {
        for (final MorphThemeData t in <MorphThemeData>[
          MorphThemeData.light(seedColor: seed),
          MorphThemeData.dark(seedColor: seed),
        ]) {
          final MorphColorScheme s = t.colorScheme;
          final MorphBadgeTheme b = t.badgeTheme;
          final double ratio = _contrast(b.containerColor(s), b.labelColor(s));
          expect(ratio, greaterThanOrEqualTo(4.5), reason: '$seed $ratio');
          // The badge also stays distinguishable from the page (non-text 3:1).
          expect(
            _contrast(b.containerColor(s), s.surface),
            greaterThanOrEqualTo(3),
          );
        }
      }
    });

    testWidgets('renders semi-bold 11pt label in the scheme onError role', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_host(_badge(count: 7)));
      final DefaultTextStyle style = tester.widget(
        find
            .ancestor(
              of: find.text('7'),
              matching: find.byType(DefaultTextStyle),
            )
            .first,
      );
      final MorphColorScheme scheme = MorphThemeData.light(seedColor: _seed)
          .colorScheme;
      expect(style.style.fontWeight, FontWeight.w600);
      expect(style.style.fontSize, 11);
      expect(style.style.color, scheme.onError);
    });

    testWidgets('min size is 18 and 1/2/3 digits grow, 99+ and maxCount cap', (
      WidgetTester tester,
    ) async {
      final Map<String, double> widths = <String, double>{};
      for (final int count in <int>[1, 22, 333]) {
        await tester.pumpWidget(_host(_badge(count: count)));
        final Rect r = tester.getRect(_pill());
        expect(r.height, 18, reason: '$count');
        widths['$count'] = r.width;
        // Width is the label plus 5dp per side, never below the 18dp minimum
        // (test fonts are wider than real ones, so only the floor is fixed).
        final double text = tester.getSize(find.text('$count')).width;
        expect(r.width, closeTo(text + 10 < 18 ? 18 : text + 10, 0.01));
      }
      expect(widths['22']!, greaterThanOrEqualTo(18));
      expect(widths['333']!, greaterThan(widths['22']!));

      await tester.pumpWidget(
        _host(
          const MorphBadge(
            count: 100,
            maxCount: 99,
            child: SizedBox(key: _contentKey, width: 40, height: 40),
          ),
        ),
      );
      expect(find.text('99+'), findsOneWidget);
    });

    testWidgets('density changes the real pill size monotonically', (
      WidgetTester tester,
    ) async {
      final List<double> heights = <double>[];
      final List<double> widths = <double>[];
      for (final MorphDensity d in MorphDensity.values) {
        await tester.pumpWidget(_host(_badge(label: 'Beta'), density: d));
        final Rect r = tester.getRect(_pill());
        heights.add(r.height);
        widths.add(r.width);
      }
      expect(heights[0], lessThan(heights[1]));
      expect(heights[1], lessThan(heights[2]));
      expect(widths[0], lessThan(widths[1]));
      expect(widths[1], lessThan(widths[2]));
      expect(heights, <double>[16, 18, 19]);
    });

    testWidgets('label padding is applied per side', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_host(_badge(label: 'Beta')));
      final double text = tester.getSize(find.text('Beta')).width;
      final double pill = tester.getSize(_pill()).width;
      expect(pill, closeTo(text + 10, 0.01));
    });

    testWidgets('survives 2x text scale, long labels, dark mode, densities', (
      WidgetTester tester,
    ) async {
      for (final Brightness b in Brightness.values) {
        for (final MorphDensity d in MorphDensity.values) {
          for (final Color seed in _seeds) {
            await tester.pumpWidget(
              _host(
                _badge(label: 'Very long status label'),
                density: d,
                brightness: b,
                seed: seed,
                textScale: 2,
              ),
            );
            expect(tester.takeException(), isNull);
            final Rect r = tester.getRect(_pill());
            expect(
              r.height,
              greaterThanOrEqualTo(18 + (d == MorphDensity.compact ? -2 : 0)),
            );
            // 2x text scale grows the badge rather than clipping the label.
            final Rect text = tester.getRect(
              find.text('Very long status label'),
            );
            expect(r.contains(text.topLeft), isTrue);
            expect(
              r.contains(text.bottomRight - const Offset(0.1, 0.1)),
              isTrue,
            );
          }
        }
      }
    });

    testWidgets('scaled text grows the badge', (WidgetTester tester) async {
      await tester.pumpWidget(_host(_badge(count: 9)));
      final double normal = tester.getSize(_pill()).height;
      await tester.pumpWidget(_host(_badge(count: 9), textScale: 2));
      expect(tester.getSize(_pill()).height, greaterThan(normal));
      expect(tester.takeException(), isNull);
    });
  });
}

Finder _pill() => find.descendant(
  of: find.byType(MorphBadge),
  matching: find.byType(Container),
);
