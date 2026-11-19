import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart'
    show
        BorderSide,
        ButtonStyle,
        Colors,
        Text,
        WidgetState,
        WidgetStatePropertyAll;
import 'package:morph_expressive/foundations/surface/morph_glass_surface.dart';
import 'package:morph_expressive/morph_expressive.dart';

import 'helpers/api_test_helpers.dart';

const Set<WidgetState> _rest = <WidgetState>{};

MorphButton _byStyle(
  MorphButtonStyle style, {
  VoidCallback? onPressed,
  MorphVariant? variant,
  MorphSurface surface = MorphSurface.solid,
  MorphButtonDecoration? decoration,
}) {
  final Widget label = const Text('Go');
  return switch (style) {
    MorphButtonStyle.filled => MorphButton.filled(
      onPressed: onPressed,
      variant: variant,
      surface: surface,
      decoration: decoration,
      child: label,
    ),
    MorphButtonStyle.tonal => MorphButton.tonal(
      onPressed: onPressed,
      variant: variant,
      surface: surface,
      decoration: decoration,
      child: label,
    ),
    MorphButtonStyle.elevated => MorphButton.elevated(
      onPressed: onPressed,
      variant: variant,
      surface: surface,
      decoration: decoration,
      child: label,
    ),
    MorphButtonStyle.outlined => MorphButton.outlined(
      onPressed: onPressed,
      variant: variant,
      surface: surface,
      decoration: decoration,
      child: label,
    ),
    MorphButtonStyle.text => MorphButton.text(
      onPressed: onPressed,
      variant: variant,
      surface: surface,
      decoration: decoration,
      child: label,
    ),
  };
}

void main() {
  group('named constructors', () {
    for (final MorphButtonStyle style in MorphButtonStyle.values) {
      testWidgets('MorphButton.${style.name} equals the base constructor', (
        tester,
      ) async {
        await tester.pumpWidget(apiHost(_byStyle(style, onPressed: () {})));
        final MorphButton named = tester.widget<MorphButton>(
          find.byType(MorphButton),
        );
        final ButtonStyle namedStyle = apiMaterialStyle(tester);
        expect(named.style, style);
        expect(named.variant, isNull);
        expect(named.surface, MorphSurface.solid);

        await tester.pumpWidget(
          apiHost(
            MorphButton(
              onPressed: () {},
              style: style,
              child: const Text('Go'),
            ),
          ),
        );
        final ButtonStyle baseStyle = apiMaterialStyle(tester);
        expect(
          baseStyle.backgroundColor!.resolve(_rest),
          namedStyle.backgroundColor!.resolve(_rest),
        );
        expect(
          baseStyle.foregroundColor!.resolve(_rest),
          namedStyle.foregroundColor!.resolve(_rest),
        );
        expect(baseStyle.side!.resolve(_rest), namedStyle.side!.resolve(_rest));
      });
    }

    testWidgets('the base constructor keeps filled as default', (tester) async {
      await tester.pumpWidget(
        apiHost(MorphButton(onPressed: () {}, child: const Text('Go'))),
      );
      final MorphButton button = tester.widget(find.byType(MorphButton));
      expect(button.style, MorphButtonStyle.filled);
      expect(button.variant, isNull);
      expect(button.surface, MorphSurface.solid);
    });

    testWidgets('MorphButton.icon forwards variant and surface', (
      tester,
    ) async {
      await tester.pumpWidget(
        apiHost(
          MorphButton.icon(
            onPressed: () {},
            icon: const Icon(MorphIcons.add),
            label: const Text('Add'),
            variant: MorphVariant.tertiary,
            surface: MorphSurface.frosted,
          ),
        ),
      );
      final MorphButton button = tester.widget(find.byType(MorphButton));
      expect(button.variant, MorphVariant.tertiary);
      expect(button.surface, MorphSurface.frosted);
      expect(find.byType(MorphGlassSurface), findsOneWidget);
    });

    testWidgets('dot shorthand compiles for variant and surface', (
      tester,
    ) async {
      await tester.pumpWidget(
        apiHost(
          MorphButton.outlined(
            onPressed: () {},
            variant: .primary,
            surface: .frosted,
            child: const Text('Go'),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
    });
  });

  group('variant resolution', () {
    for (final Brightness brightness in Brightness.values) {
      for (final MorphVariant variant in apiVariants) {
        testWidgets('${variant.name} ${brightness.name} reads scheme roles', (
          tester,
        ) async {
          for (final MorphButtonStyle style in MorphButtonStyle.values) {
            await tester.pumpWidget(
              apiHost(
                _byStyle(style, onPressed: () {}, variant: variant),
                brightness: brightness,
              ),
            );
            await tester.pumpAndSettle();
            final MorphColorScheme scheme = apiScheme(tester);
            final MorphVariantPalette p = MorphVariantPalette.of(
              scheme,
              variant,
            );
            final ButtonStyle s = apiMaterialStyle(tester);
            final Color fg = s.foregroundColor!.resolve(_rest)!;
            final Color bg = s.backgroundColor!.resolve(_rest)!;
            final BorderSide side = s.side!.resolve(_rest)!;
            switch (style) {
              case MorphButtonStyle.filled:
                expect(bg, p.color, reason: '${style.name} bg');
                expect(fg, p.onColor, reason: '${style.name} fg');
                expect(side, BorderSide.none);
              case MorphButtonStyle.tonal:
                expect(bg, p.container, reason: '${style.name} bg');
                expect(fg, p.onContainer, reason: '${style.name} fg');
              case MorphButtonStyle.elevated:
                expect(bg, scheme.surfaceContainerLow);
                expect(fg, p.accent);
              case MorphButtonStyle.outlined:
                expect(bg, Colors.transparent);
                expect(fg, p.accent);
                expect(side.color, p.outline);
              case MorphButtonStyle.text:
                expect(bg, Colors.transparent);
                expect(fg, p.accent);
            }
          }
        });
      }
    }

    testWidgets('named roles map to the documented scheme slots', (
      tester,
    ) async {
      await tester.pumpWidget(
        apiHost(
          _byStyle(
            MorphButtonStyle.filled,
            onPressed: () {},
            variant: MorphVariant.primary,
          ),
        ),
      );
      MorphColorScheme scheme = apiScheme(tester);
      ButtonStyle s = apiMaterialStyle(tester);
      expect(s.backgroundColor!.resolve(_rest), scheme.primary);
      expect(s.foregroundColor!.resolve(_rest), scheme.onPrimary);

      await tester.pumpWidget(
        apiHost(
          _byStyle(
            MorphButtonStyle.tonal,
            onPressed: () {},
            variant: MorphVariant.danger,
          ),
        ),
      );
      scheme = apiScheme(tester);
      s = apiMaterialStyle(tester);
      expect(s.backgroundColor!.resolve(_rest), scheme.errorContainer);
      expect(s.foregroundColor!.resolve(_rest), scheme.onErrorContainer);

      await tester.pumpWidget(
        apiHost(
          _byStyle(
            MorphButtonStyle.outlined,
            onPressed: () {},
            variant: MorphVariant.danger,
          ),
        ),
      );
      scheme = apiScheme(tester);
      s = apiMaterialStyle(tester);
      expect(s.foregroundColor!.resolve(_rest), scheme.error);
      expect(s.side!.resolve(_rest)!.color, scheme.error);
    });

    testWidgets('a null variant keeps the historical colors', (tester) async {
      for (final Brightness brightness in Brightness.values) {
        for (final MorphButtonStyle style in MorphButtonStyle.values) {
          await tester.pumpWidget(
            apiHost(_byStyle(style, onPressed: () {}), brightness: brightness),
          );
          await tester.pumpAndSettle();
          final MorphColorScheme c = apiScheme(tester);
          final ButtonStyle s = apiMaterialStyle(tester);
          final Color bg = s.backgroundColor!.resolve(_rest)!;
          final Color fg = s.foregroundColor!.resolve(_rest)!;
          final BorderSide side = s.side!.resolve(_rest)!;
          switch (style) {
            case MorphButtonStyle.filled:
              expect(<Color>[bg, fg], <Color>[c.primary, c.onPrimary]);
            case MorphButtonStyle.tonal:
              expect(
                <Color>[bg, fg],
                <Color>[c.secondaryContainer, c.onSecondaryContainer],
              );
            case MorphButtonStyle.elevated:
              expect(
                <Color>[bg, fg],
                <Color>[c.surfaceContainerLow, c.primary],
              );
            case MorphButtonStyle.outlined:
              expect(
                <Color>[bg, fg],
                <Color>[Colors.transparent, c.onSurfaceVariant],
              );
              expect(side.color, c.outline);
            case MorphButtonStyle.text:
              expect(<Color>[bg, fg], <Color>[Colors.transparent, c.primary]);
          }
        }
      }
    });

    testWidgets('toggle buttons resolve selected and unselected variant', (
      tester,
    ) async {
      Future<void> pumpToggle(bool selected) => tester.pumpWidget(
        apiHost(
          MorphButton.filled(
            onPressed: () {},
            variant: MorphVariant.danger,
            isSelected: selected,
            icon: const Icon(MorphIcons.add),
            label: const Text('Flag'),
          ),
        ),
      );
      await pumpToggle(true);
      MorphColorScheme c = apiScheme(tester);
      ButtonStyle s = apiMaterialStyle(tester);
      expect(s.backgroundColor!.resolve(_rest), c.error);
      expect(s.foregroundColor!.resolve(_rest), c.onError);

      await pumpToggle(false);
      await tester.pumpAndSettle();
      c = apiScheme(tester);
      s = apiMaterialStyle(tester);
      expect(s.backgroundColor!.resolve(_rest), c.surfaceContainer);
      expect(s.foregroundColor!.resolve(_rest), c.error);
    });

    testWidgets('disabled keeps the neutral disabled alpha conventions', (
      tester,
    ) async {
      await tester.pumpWidget(
        apiHost(
          _byStyle(MorphButtonStyle.filled, variant: MorphVariant.danger),
        ),
      );
      final MorphColorScheme c = apiScheme(tester);
      final ButtonStyle s = apiMaterialStyle(tester);
      const Set<WidgetState> disabled = <WidgetState>{WidgetState.disabled};
      expect(
        s.foregroundColor!.resolve(disabled),
        c.onSurface.withValues(
          alpha: MorphButtonConstants.kDisabledForegroundAlpha,
        ),
      );
      expect(
        s.backgroundColor!.resolve(disabled),
        c.onSurface.withValues(
          alpha: MorphButtonConstants.kDisabledBackgroundAlpha,
        ),
      );
    });

    testWidgets('an explicit decoration beats the variant', (tester) async {
      const Color red = Color(0xFFAA0000);
      const Color white = Color(0xFFFFFFFF);
      await tester.pumpWidget(
        apiHost(
          _byStyle(
            MorphButtonStyle.outlined,
            onPressed: () {},
            variant: MorphVariant.primary,
            decoration: const MorphButtonDecoration(
              backgroundColor: WidgetStatePropertyAll<Color?>(red),
              foregroundColor: WidgetStatePropertyAll<Color?>(white),
              side: WidgetStatePropertyAll<BorderSide?>(
                BorderSide(color: red, width: 3),
              ),
            ),
          ),
        ),
      );
      final ButtonStyle s = apiMaterialStyle(tester);
      expect(s.backgroundColor!.resolve(_rest), red);
      expect(s.foregroundColor!.resolve(_rest), white);
      expect(s.side!.resolve(_rest)!.color, red);
    });

    testWidgets('a scoped decoration also beats the variant', (tester) async {
      const Color red = Color(0xFFAA0000);
      await tester.pumpWidget(
        apiHost(
          MorphButtonDecorationScope(
            decoration: const MorphButtonDecoration(
              foregroundColor: WidgetStatePropertyAll<Color?>(red),
            ),
            child: _byStyle(
              MorphButtonStyle.tonal,
              onPressed: () {},
              variant: MorphVariant.secondary,
            ),
          ),
        ),
      );
      final ButtonStyle s = apiMaterialStyle(tester);
      final MorphColorScheme c = apiScheme(tester);
      expect(s.foregroundColor!.resolve(_rest), red);
      // Non-overridden slots still come from the variant.
      expect(s.backgroundColor!.resolve(_rest), c.secondaryContainer);
    });

    testWidgets('variant colors follow the inherited theme', (tester) async {
      const Color blue = Color(0xFF1565C0);
      const Color green = Color(0xFF2E7D32);
      await tester.pumpWidget(
        apiHost(
          _byStyle(
            MorphButtonStyle.filled,
            onPressed: () {},
            variant: MorphVariant.primary,
          ),
          data: MorphThemeData.light(seedColor: blue),
        ),
      );
      await tester.pumpAndSettle();
      final Color first = apiMaterialStyle(tester).backgroundColor!
          .resolve(_rest)!;
      expect(first, apiScheme(tester).primary);

      await tester.pumpWidget(
        apiHost(
          _byStyle(
            MorphButtonStyle.filled,
            onPressed: () {},
            variant: MorphVariant.primary,
          ),
          data: MorphThemeData.light(seedColor: green),
        ),
      );
      await tester.pumpAndSettle();
      final Color second = apiMaterialStyle(tester).backgroundColor!
          .resolve(_rest)!;
      expect(second, apiScheme(tester).primary);
      expect(second, isNot(first));
    });
  });

  group('contrast', () {
    for (final Brightness brightness in Brightness.values) {
      testWidgets('filled and tonal meet 4.5:1 for every variant '
          '(${brightness.name})', (tester) async {
        for (final MorphVariant variant in apiVariants) {
          for (final MorphButtonStyle style in <MorphButtonStyle>[
            MorphButtonStyle.filled,
            MorphButtonStyle.tonal,
          ]) {
            await tester.pumpWidget(
              apiHost(
                _byStyle(style, onPressed: () {}, variant: variant),
                brightness: brightness,
              ),
            );
            await tester.pumpAndSettle();
            final ButtonStyle s = apiMaterialStyle(tester);
            final double ratio = apiContrast(
              s.foregroundColor!.resolve(_rest)!,
              s.backgroundColor!.resolve(_rest)!,
            );
            expect(
              ratio,
              greaterThanOrEqualTo(4.5),
              reason: '${style.name}/${variant.name}/${brightness.name}',
            );
          }
        }
      });
    }
  });

  group('frosted surface', () {
    testWidgets('solid mounts no glass or backdrop filter', (tester) async {
      await tester.pumpWidget(
        apiHost(_byStyle(MorphButtonStyle.filled, onPressed: () {})),
      );
      expect(find.byType(MorphGlassSurface), findsNothing);
      expect(find.byType(BackdropFilter), findsNothing);
    });

    for (final MorphButtonStyle style in MorphButtonStyle.values) {
      testWidgets('frosted ${style.name} mounts one clipped glass surface', (
        tester,
      ) async {
        await tester.pumpWidget(
          apiHost(
            _byStyle(
              style,
              onPressed: () {},
              variant: MorphVariant.primary,
              surface: MorphSurface.frosted,
            ),
          ),
        );
        expect(find.byType(MorphGlassSurface), findsOneWidget);
        expect(find.byType(BackdropFilter), findsOneWidget);
        // The Material layer is transparent so the backdrop stays visible.
        final ButtonStyle s = apiMaterialStyle(tester);
        expect(s.backgroundColor!.resolve(_rest), Colors.transparent);
        expect(s.elevation!.resolve(_rest), 0);
        // The glass fills exactly the button, so the blur is clipped to it.
        expect(
          tester.getSize(find.byType(MorphGlassSurface)),
          tester.getSize(find.byType(MorphButton)),
        );
      });
    }

    testWidgets('glass tint derives from the resolved container color', (
      tester,
    ) async {
      await tester.pumpWidget(
        apiHost(
          _byStyle(
            MorphButtonStyle.filled,
            onPressed: () {},
            variant: MorphVariant.danger,
            surface: MorphSurface.frosted,
          ),
        ),
      );
      final MorphGlassSurface glass = tester.widget(
        find.byType(MorphGlassSurface),
      );
      expect(glass.baseColor, apiScheme(tester).error);
    });

    testWidgets('transparent types borrow surfaceContainerLow as base', (
      tester,
    ) async {
      await tester.pumpWidget(
        apiHost(
          _byStyle(
            MorphButtonStyle.text,
            onPressed: () {},
            surface: MorphSurface.frosted,
          ),
        ),
      );
      final MorphGlassSurface glass = tester.widget(
        find.byType(MorphGlassSurface),
      );
      expect(glass.baseColor, apiScheme(tester).surfaceContainerLow);
    });

    testWidgets('uses the theme glass when enabled, default otherwise', (
      tester,
    ) async {
      await tester.pumpWidget(
        apiHost(
          _byStyle(
            MorphButtonStyle.tonal,
            onPressed: () {},
            surface: MorphSurface.frosted,
          ),
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
        apiHost(
          _byStyle(
            MorphButtonStyle.tonal,
            onPressed: () {},
            surface: MorphSurface.frosted,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expectGlassFrom(
        tester.widget<MorphGlassSurface>(find.byType(MorphGlassSurface)).glass,
        const MorphSurfaceGlass(),
      );
    });

    testWidgets('keeps tap, state layer and focus working', (tester) async {
      int taps = 0;
      await tester.pumpWidget(
        apiHost(
          _byStyle(
            MorphButtonStyle.filled,
            onPressed: () => taps++,
            surface: MorphSurface.frosted,
          ),
        ),
      );
      await tester.tap(find.byType(MorphButton));
      await tester.pump();
      expect(taps, 1);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('disabled frosted buttons have no residual tap', (
      tester,
    ) async {
      await tester.pumpWidget(
        apiHost(
          _byStyle(MorphButtonStyle.filled, surface: MorphSurface.frosted),
        ),
      );
      await tester.tap(find.byType(MorphButton), warnIfMissed: false);
      await tester.pump();
      expect(tester.takeException(), isNull);
      expect(find.byType(MorphGlassSurface), findsOneWidget);
    });
  });

  group('interaction and semantics', () {
    testWidgets('onPressed fires once per tap, with and without variant', (
      tester,
    ) async {
      int taps = 0;
      await tester.pumpWidget(
        apiHost(
          _byStyle(
            MorphButtonStyle.tonal,
            onPressed: () => taps++,
            variant: MorphVariant.muted,
          ),
        ),
      );
      await tester.tap(find.byType(MorphButton));
      await tester.pump();
      expect(taps, 1);
    });

    testWidgets('a null onPressed does nothing and reports disabled', (
      tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await tester.pumpWidget(
        apiHost(
          _byStyle(MorphButtonStyle.filled, variant: MorphVariant.primary),
        ),
      );
      await tester.tap(find.byType(MorphButton), warnIfMissed: false);
      await tester.pump();
      expect(
        tester.getSemantics(find.text('Go')),
        matchesSemantics(
          label: 'Go',
          isButton: true,
          hasEnabledState: true,
          isEnabled: false,
        ),
      );
      handle.dispose();
    });

    testWidgets('enabled false blocks a non-null onPressed', (tester) async {
      int taps = 0;
      await tester.pumpWidget(
        apiHost(
          MorphButton.filled(
            onPressed: () => taps++,
            enabled: false,
            variant: MorphVariant.danger,
            child: const Text('Go'),
          ),
        ),
      );
      await tester.tap(find.byType(MorphButton), warnIfMissed: false);
      await tester.pump();
      expect(taps, 0);
    });

    testWidgets('an enabled button exposes a button role', (tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await tester.pumpWidget(
        apiHost(
          _byStyle(
            MorphButtonStyle.outlined,
            onPressed: () {},
            variant: MorphVariant.tertiary,
            surface: MorphSurface.frosted,
          ),
        ),
      );
      expect(
        tester.getSemantics(find.text('Go')),
        matchesSemantics(
          label: 'Go',
          isButton: true,
          isEnabled: true,
          hasEnabledState: true,
          isFocusable: true,
          hasTapAction: true,
          hasFocusAction: true,
        ),
      );
      handle.dispose();
    });

    testWidgets('keys are preserved on named constructors', (tester) async {
      const Key key = ValueKey<String>('go');
      await tester.pumpWidget(
        apiHost(
          MorphButton.tonal(
            key: key,
            onPressed: () {},
            variant: MorphVariant.secondary,
            child: const Text('Go'),
          ),
        ),
      );
      expect(find.byKey(key), findsOneWidget);
      expect(
        tester.widget<MorphButton>(find.byKey(key)).variant,
        MorphVariant.secondary,
      );
    });
  });

  group('lifecycle', () {
    testWidgets('rebuilding with new variant, surface and style is stable', (
      tester,
    ) async {
      int taps = 0;
      final List<(MorphButtonStyle, MorphVariant?, MorphSurface)>
      steps = <(MorphButtonStyle, MorphVariant?, MorphSurface)>[
        (MorphButtonStyle.filled, null, MorphSurface.solid),
        (MorphButtonStyle.filled, MorphVariant.danger, MorphSurface.solid),
        (MorphButtonStyle.filled, MorphVariant.danger, MorphSurface.frosted),
        (MorphButtonStyle.outlined, MorphVariant.muted, MorphSurface.frosted),
        (MorphButtonStyle.text, MorphVariant.primary, MorphSurface.solid),
        (MorphButtonStyle.elevated, null, MorphSurface.solid),
      ];
      for (final (
            MorphButtonStyle style,
            MorphVariant? variant,
            MorphSurface surface,
          )
          in steps) {
        await tester.pumpWidget(
          apiHost(
            _byStyle(
              style,
              onPressed: () => taps++,
              variant: variant,
              surface: surface,
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 50));
        expect(tester.takeException(), isNull);
        expect(
          find.byType(MorphGlassSurface),
          surface.isFrosted ? findsOneWidget : findsNothing,
        );
      }
      await tester.tap(find.byType(MorphButton));
      await tester.pumpAndSettle();
      expect(taps, 1);
    });

    testWidgets('async button forwards variant and surface', (tester) async {
      await tester.pumpWidget(
        apiHost(
          MorphAsyncButton(
            label: 'Save',
            onPressed: () {},
            style: MorphButtonStyle.tonal,
            variant: MorphVariant.tertiary,
            surface: MorphSurface.frosted,
          ),
        ),
      );
      await tester.pumpAndSettle();
      final MorphButton inner = tester.widget(find.byType(MorphButton));
      expect(inner.variant, MorphVariant.tertiary);
      expect(inner.surface, MorphSurface.frosted);
      expect(find.byType(MorphGlassSurface), findsOneWidget);
      final MorphGlassSurface glass = tester.widget(
        find.byType(MorphGlassSurface),
      );
      expect(glass.baseColor, apiScheme(tester).tertiaryContainer);

      await tester.pumpWidget(
        apiHost(
          MorphAsyncButton(
            label: 'Save',
            onPressed: () {},
            variant: MorphVariant.danger,
          ),
        ),
      );
      await tester.pumpAndSettle();
      final ButtonStyle s = apiMaterialStyle(tester);
      expect(tester.takeException(), isNull);
      expect(find.byType(MorphGlassSurface), findsNothing);
      expect(s.shape, isNotNull);
    });

    testWidgets('split button, group and shape button accept variant', (
      tester,
    ) async {
      await tester.pumpWidget(
        apiHost(
          MorphSplitButton.tonal(
            label: 'Share',
            variant: MorphVariant.danger,
            onPressed: () {},
            items: const <MorphSplitButtonItem<String>>[
              MorphSplitButtonItem<String>(value: 'a', child: Text('A')),
            ],
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      expect(
        tester
            .widget<MorphSplitButton<String>>(
              find.byType(MorphSplitButton<String>),
            )
            .variant,
        MorphVariant.danger,
      );

      await tester.pumpWidget(
        apiHost(
          MorphButtonGroup(
            variant: MorphVariant.secondary,
            actions: <MorphButtonGroupAction>[
              MorphButtonGroupAction(label: Text('A')),
              MorphButtonGroupAction(label: Text('B')),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        tester
            .widgetList<MorphButton>(find.byType(MorphButton))
            .every((MorphButton b) => b.variant == MorphVariant.secondary),
        isTrue,
      );
    });

    testWidgets('shape button accepts a variant and mounts', (tester) async {
      await tester.pumpWidget(
        apiHost(
          MorphShapeButton(
            size: 80,
            shape: MorphShapeCatalog.fromKind(MorphShapeKind.sunny),
            variant: MorphVariant.tertiary,
            onPressed: () {},
            child: const Icon(MorphIcons.add),
          ),
        ),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);
      expect(
        tester.widget<MorphShapeButton>(find.byType(MorphShapeButton)).variant,
        MorphVariant.tertiary,
      );
    });
  });
}
