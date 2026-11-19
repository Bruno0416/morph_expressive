import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morph_expressive/foundations/surface/morph_glass_surface.dart';
import 'package:morph_expressive/morph_expressive.dart';

import 'helpers/api_test_helpers.dart';

const Key _surface = ValueKey<String>('surface');

MorphCard _byType(
  MorphCardType type, {
  VoidCallback? onPressed,
  MorphVariant? variant,
  MorphSurface surface = MorphSurface.solid,
  bool enabled = true,
  Color? color,
  BorderSide? border,
  Key? key,
}) {
  const String headline = 'Headline';
  const String supporting = 'Supporting text';
  return switch (type) {
    MorphCardType.elevated => MorphCard.elevated(
      key: key,
      surfaceKey: _surface,
      onPressed: onPressed,
      variant: variant,
      surface: surface,
      enabled: enabled,
      color: color,
      border: border,
      headline: headline,
      supportingText: supporting,
    ),
    MorphCardType.filled => MorphCard.filled(
      key: key,
      surfaceKey: _surface,
      onPressed: onPressed,
      variant: variant,
      surface: surface,
      enabled: enabled,
      color: color,
      border: border,
      headline: headline,
      supportingText: supporting,
    ),
    MorphCardType.outlined => MorphCard.outlined(
      key: key,
      surfaceKey: _surface,
      onPressed: onPressed,
      variant: variant,
      surface: surface,
      enabled: enabled,
      color: color,
      border: border,
      headline: headline,
      supportingText: supporting,
    ),
  };
}

BoxDecoration _decoration(WidgetTester tester) {
  final AnimatedContainer box = tester.widget(find.byKey(_surface));
  return box.decoration! as BoxDecoration;
}

Color? _fill(WidgetTester tester) => _decoration(tester).color;

Color? _borderColor(WidgetTester tester) =>
    (_decoration(tester).border as Border?)?.top.color;

Color? _textColor(WidgetTester tester, String text) =>
    tester.widget<Text>(find.text(text)).style?.color;

void main() {
  group('type and named constructors', () {
    for (final MorphCardType type in MorphCardType.values) {
      testWidgets('MorphCard.${type.name} equals the base type', (
        tester,
      ) async {
        await tester.pumpWidget(apiHost(_byType(type)));
        final MorphCard named = tester.widget(find.byType(MorphCard));
        expect(named.type, type);
        expect(named.variant, isNull);
        expect(named.surface, MorphSurface.solid);
        final Color? namedFill = _fill(tester);
        final Color? namedBorder = _borderColor(tester);

        await tester.pumpWidget(
          apiHost(
            MorphCard(
              type: type,
              surfaceKey: _surface,
              headline: 'Headline',
              supportingText: 'Supporting text',
            ),
          ),
        );
        expect(_fill(tester), namedFill);
        expect(_borderColor(tester), namedBorder);
      });
    }

    testWidgets('the base constructor keeps elevated as default', (
      tester,
    ) async {
      await tester.pumpWidget(apiHost(const MorphCard(headline: 'Headline')));
      expect(
        tester.widget<MorphCard>(find.byType(MorphCard)).type,
        MorphCardType.elevated,
      );
    });

    test('the deprecated alias still names the type enum', () {
      // ignore: deprecated_member_use_from_same_package
      const MorphCardVariant legacy = MorphCardVariant.outlined;
      expect(legacy, MorphCardType.outlined);
    });
  });

  group('variant resolution', () {
    testWidgets('a null variant keeps the historical colors', (tester) async {
      for (final Brightness brightness in Brightness.values) {
        await tester.pumpWidget(
          apiHost(_byType(MorphCardType.elevated), brightness: brightness),
        );
        await tester.pumpAndSettle();
        final MorphColorScheme c = apiScheme(tester);
        expect(_fill(tester), c.surfaceContainerLow);
        expect(_textColor(tester, 'Headline'), c.onSurface);
        expect(_textColor(tester, 'Supporting text'), c.onSurfaceVariant);

        await tester.pumpWidget(
          apiHost(_byType(MorphCardType.filled), brightness: brightness),
        );
        await tester.pumpAndSettle();
        expect(_fill(tester), c.surfaceContainerHighest);

        await tester.pumpWidget(
          apiHost(_byType(MorphCardType.outlined), brightness: brightness),
        );
        await tester.pumpAndSettle();
        expect(_fill(tester), c.surface);
        expect(_borderColor(tester), c.outlineVariant);
      }
    });

    for (final Brightness brightness in Brightness.values) {
      for (final MorphVariant variant in apiVariants) {
        testWidgets('${variant.name} ${brightness.name} reads scheme roles', (
          tester,
        ) async {
          await tester.pumpWidget(
            apiHost(
              _byType(MorphCardType.filled, variant: variant),
              brightness: brightness,
            ),
          );
          await tester.pumpAndSettle();
          MorphColorScheme c = apiScheme(tester);
          MorphVariantPalette p = MorphVariantPalette.of(c, variant);
          expect(_fill(tester), p.container);
          expect(_textColor(tester, 'Headline'), p.onContainer);
          expect(_textColor(tester, 'Supporting text'), p.onContainer);

          await tester.pumpWidget(
            apiHost(
              _byType(MorphCardType.outlined, variant: variant),
              brightness: brightness,
            ),
          );
          await tester.pumpAndSettle();
          c = apiScheme(tester);
          p = MorphVariantPalette.of(c, variant);
          expect(_fill(tester), c.surface);
          // Roles sharing the scheme outline keep the card's own border and
          // show the role in the headline; danger/muted use their outline.
          expect(
            _borderColor(tester),
            p.outline == c.outline ? c.outlineVariant : p.outline,
          );
          expect(_textColor(tester, 'Headline'), p.accent);

          await tester.pumpWidget(
            apiHost(
              _byType(MorphCardType.elevated, variant: variant),
              brightness: brightness,
            ),
          );
          await tester.pumpAndSettle();
          c = apiScheme(tester);
          p = MorphVariantPalette.of(c, variant);
          expect(_fill(tester), c.surfaceContainerLow);
          expect(_textColor(tester, 'Headline'), p.accent);
          expect(_textColor(tester, 'Supporting text'), c.onSurfaceVariant);
        });
      }
    }

    testWidgets('named roles map to the documented scheme slots', (
      tester,
    ) async {
      await tester.pumpWidget(
        apiHost(_byType(MorphCardType.filled, variant: MorphVariant.danger)),
      );
      final MorphColorScheme c = apiScheme(tester);
      expect(_fill(tester), c.errorContainer);
      expect(_textColor(tester, 'Headline'), c.onErrorContainer);
    });

    testWidgets('explicit widget color and border beat the variant', (
      tester,
    ) async {
      const Color red = Color(0xFFAA0000);
      const Color blue = Color(0xFF0000AA);
      await tester.pumpWidget(
        apiHost(
          _byType(
            MorphCardType.outlined,
            variant: MorphVariant.primary,
            color: red,
            border: const BorderSide(color: blue, width: 3),
          ),
        ),
      );
      expect(_fill(tester), red);
      expect(_borderColor(tester), blue);
    });

    testWidgets('component theme colors apply without a variant only', (
      tester,
    ) async {
      const Color themed = Color(0xFF123456);
      final MorphThemeData data = MorphThemeData.light().copyWith(
        cardTheme: const MorphCardTheme(filledContainerColor: themed),
      );
      await tester.pumpWidget(
        apiHost(_byType(MorphCardType.filled), data: data),
      );
      expect(_fill(tester), themed);

      await tester.pumpWidget(
        apiHost(
          _byType(MorphCardType.filled, variant: MorphVariant.tertiary),
          data: data,
        ),
      );
      await tester.pumpAndSettle();
      expect(_fill(tester), apiScheme(tester).tertiaryContainer);
    });

    testWidgets('variant colors follow the inherited theme', (tester) async {
      Future<Color?> fillFor(Color seed) async {
        await tester.pumpWidget(
          apiHost(
            _byType(MorphCardType.filled, variant: MorphVariant.primary),
            data: MorphThemeData.light(seedColor: seed),
          ),
        );
        await tester.pumpAndSettle();
        expect(_fill(tester), apiScheme(tester).primaryContainer);
        return _fill(tester);
      }

      final Color? blue = await fillFor(const Color(0xFF1565C0));
      final Color? green = await fillFor(const Color(0xFF2E7D32));
      expect(blue, isNot(green));
    });

    testWidgets('disabled cards keep the disabled tokens', (tester) async {
      await tester.pumpWidget(
        apiHost(
          _byType(
            MorphCardType.filled,
            variant: MorphVariant.primary,
            enabled: false,
          ),
        ),
      );
      final MorphColorScheme c = apiScheme(tester);
      expect(_fill(tester), c.onSurface);
      expect(_fill(tester), isNot(c.primaryContainer));
    });
  });

  group('contrast', () {
    for (final Brightness brightness in Brightness.values) {
      testWidgets('filled headline meets 4.5:1 for every variant '
          '(${brightness.name})', (tester) async {
        for (final MorphVariant variant in apiVariants) {
          await tester.pumpWidget(
            apiHost(
              _byType(MorphCardType.filled, variant: variant),
              brightness: brightness,
            ),
          );
          await tester.pumpAndSettle();
          expect(
            apiContrast(_textColor(tester, 'Headline')!, _fill(tester)!),
            greaterThanOrEqualTo(4.5),
            reason: '${variant.name}/${brightness.name}',
          );
        }
      });
    }
  });

  group('frosted surface', () {
    testWidgets('solid mounts no glass', (tester) async {
      await tester.pumpWidget(apiHost(_byType(MorphCardType.filled)));
      expect(find.byType(MorphGlassSurface), findsNothing);
      expect(find.byType(BackdropFilter), findsNothing);
    });

    for (final MorphCardType type in MorphCardType.values) {
      testWidgets('frosted ${type.name} mounts glass tinted by its fill', (
        tester,
      ) async {
        await tester.pumpWidget(
          apiHost(
            _byType(
              type,
              variant: MorphVariant.secondary,
              surface: MorphSurface.frosted,
            ),
          ),
        );
        expect(find.byType(MorphGlassSurface), findsOneWidget);
        expect(find.byType(BackdropFilter), findsOneWidget);
        final MorphColorScheme c = apiScheme(tester);
        final MorphGlassSurface glass = tester.widget(
          find.byType(MorphGlassSurface),
        );
        expect(glass.baseColor, switch (type) {
          MorphCardType.filled => c.secondaryContainer,
          MorphCardType.elevated => c.surfaceContainerLow,
          MorphCardType.outlined => c.surface,
        });
        // The container itself no longer paints an opaque fill.
        expect(_fill(tester), isNull);
      });
    }

    testWidgets('uses the theme glass when enabled, default otherwise', (
      tester,
    ) async {
      await tester.pumpWidget(
        apiHost(
          _byType(MorphCardType.filled, surface: MorphSurface.frosted),
          data: MorphThemeData.light().copyWith(
            surfaceGlass: const MorphSurfaceGlass(blurX: 7, blurY: 7),
          ),
        ),
      );
      expectGlassFrom(
        tester.widget<MorphGlassSurface>(find.byType(MorphGlassSurface)).glass,
        const MorphSurfaceGlass(blurX: 7, blurY: 7),
      );

      await tester.pumpWidget(
        apiHost(_byType(MorphCardType.filled, surface: MorphSurface.frosted)),
      );
      await tester.pumpAndSettle();
      expectGlassFrom(
        tester.widget<MorphGlassSurface>(find.byType(MorphGlassSurface)).glass,
        const MorphSurfaceGlass(),
      );
    });

    testWidgets('the deprecated frosted flag keeps its theme-only behavior', (
      tester,
    ) async {
      await tester.pumpWidget(
        apiHost(
          // ignore: deprecated_member_use_from_same_package
          const MorphCard(headline: 'Legacy', frosted: true),
        ),
      );
      expect(find.byType(MorphGlassSurface), findsNothing);

      await tester.pumpWidget(
        apiHost(
          // ignore: deprecated_member_use_from_same_package
          const MorphCard(headline: 'Legacy', frosted: true),
          data: MorphThemeData.light().copyWith(
            surfaceGlass: const MorphSurfaceGlass(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(MorphGlassSurface), findsOneWidget);
    });

    testWidgets('an explicit glass override keeps priority', (tester) async {
      const MorphSurfaceGlass local = MorphSurfaceGlass(blurX: 19);
      await tester.pumpWidget(
        apiHost(
          const MorphCard(
            headline: 'Local',
            surface: MorphSurface.frosted,
            glass: local,
          ),
        ),
      );
      expect(
        tester.widget<MorphGlassSurface>(find.byType(MorphGlassSurface)).glass,
        local,
      );

      await tester.pumpWidget(
        apiHost(
          const MorphCard(
            headline: 'Off',
            surface: MorphSurface.frosted,
            glass: MorphSurfaceGlass.disabled(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(MorphGlassSurface), findsNothing);
    });
  });

  group('interaction, semantics and lifecycle', () {
    testWidgets('onPressed fires and keys are preserved', (tester) async {
      int taps = 0;
      const Key key = ValueKey<String>('card');
      await tester.pumpWidget(
        apiHost(
          _byType(
            MorphCardType.filled,
            key: key,
            onPressed: () => taps++,
            variant: MorphVariant.muted,
            surface: MorphSurface.frosted,
          ),
        ),
      );
      await tester.tap(find.byKey(key));
      await tester.pump();
      expect(taps, 1);
    });

    testWidgets('disabled cards have no residual tap', (tester) async {
      int taps = 0;
      await tester.pumpWidget(
        apiHost(
          _byType(
            MorphCardType.outlined,
            onPressed: () => taps++,
            enabled: false,
            variant: MorphVariant.danger,
          ),
        ),
      );
      await tester.tap(find.byType(MorphCard), warnIfMissed: false);
      await tester.pump();
      expect(taps, 0);
    });

    testWidgets('an actionable card exposes a button role', (tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await tester.pumpWidget(
        apiHost(
          _byType(
            MorphCardType.filled,
            onPressed: () {},
            variant: MorphVariant.primary,
          ),
        ),
      );
      expect(
        tester.getSemantics(find.text('Headline')),
        isSemantics(
          isButton: true,
          isFocusable: true,
          hasEnabledState: true,
          isEnabled: true,
          hasTapAction: true,
          hasFocusAction: true,
        ),
      );
      handle.dispose();
    });

    testWidgets('rebuilding with new type, variant and surface is stable', (
      tester,
    ) async {
      final List<(MorphCardType, MorphVariant?, MorphSurface)> steps =
          <(MorphCardType, MorphVariant?, MorphSurface)>[
            (MorphCardType.elevated, null, MorphSurface.solid),
            (MorphCardType.filled, MorphVariant.danger, MorphSurface.solid),
            (MorphCardType.filled, MorphVariant.danger, MorphSurface.frosted),
            (MorphCardType.outlined, MorphVariant.muted, MorphSurface.frosted),
            (MorphCardType.elevated, MorphVariant.tertiary, MorphSurface.solid),
          ];
      for (final (
            MorphCardType type,
            MorphVariant? variant,
            MorphSurface surface,
          )
          in steps) {
        await tester.pumpWidget(
          apiHost(
            _byType(type, onPressed: () {}, variant: variant, surface: surface),
          ),
        );
        await tester.pump(const Duration(milliseconds: 50));
        expect(tester.takeException(), isNull);
        expect(
          find.byType(MorphGlassSurface),
          surface.isFrosted ? findsOneWidget : findsNothing,
        );
      }
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });
}
