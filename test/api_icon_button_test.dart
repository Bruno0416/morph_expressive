import 'package:flutter/semantics.dart' show SemanticsNode;
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart'
    show
        BorderSide,
        ButtonStyle,
        Colors,
        IconButton,
        WidgetState,
        WidgetStatePropertyAll;
import 'package:morph_expressive/foundations/surface/morph_glass_surface.dart';
import 'package:morph_expressive/morph_expressive.dart';

import 'helpers/api_test_helpers.dart';

const Set<WidgetState> _rest = <WidgetState>{};
const Icon _icon = Icon(MorphIcons.add);

MorphIconButton _byType(
  MorphIconButtonType type, {
  VoidCallback? onPressed,
  MorphVariant? variant,
  MorphSurface surface = MorphSurface.solid,
  bool? isSelected,
  MorphIconButtonDecoration? decoration,
  Key? key,
}) {
  return switch (type) {
    MorphIconButtonType.standard => MorphIconButton.standard(
      key: key,
      icon: _icon,
      onPressed: onPressed,
      variant: variant,
      surface: surface,
      isSelected: isSelected,
      decoration: decoration,
      semanticLabel: 'Add',
    ),
    MorphIconButtonType.filled => MorphIconButton.filled(
      key: key,
      icon: _icon,
      onPressed: onPressed,
      variant: variant,
      surface: surface,
      isSelected: isSelected,
      decoration: decoration,
      semanticLabel: 'Add',
    ),
    MorphIconButtonType.tonal => MorphIconButton.tonal(
      key: key,
      icon: _icon,
      onPressed: onPressed,
      variant: variant,
      surface: surface,
      isSelected: isSelected,
      decoration: decoration,
      semanticLabel: 'Add',
    ),
    MorphIconButtonType.outlined => MorphIconButton.outlined(
      key: key,
      icon: _icon,
      onPressed: onPressed,
      variant: variant,
      surface: surface,
      isSelected: isSelected,
      decoration: decoration,
      semanticLabel: 'Add',
    ),
  };
}

void main() {
  group('type and named constructors', () {
    for (final MorphIconButtonType type in MorphIconButtonType.values) {
      testWidgets('MorphIconButton.${type.name} equals the base type', (
        tester,
      ) async {
        await tester.pumpWidget(apiHost(_byType(type, onPressed: () {})));
        final MorphIconButton named = tester.widget(
          find.byType(MorphIconButton),
        );
        final ButtonStyle namedStyle = apiMaterialStyle(tester);
        expect(named.type, type);
        expect(named.variant, isNull);
        expect(named.surface, MorphSurface.solid);

        await tester.pumpWidget(
          apiHost(MorphIconButton(icon: _icon, type: type, onPressed: () {})),
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
        apiHost(MorphIconButton(icon: _icon, onPressed: () {})),
      );
      expect(
        tester.widget<MorphIconButton>(find.byType(MorphIconButton)).type,
        MorphIconButtonType.filled,
      );
    });

    test('the deprecated alias still names the type enum', () {
      // ignore: deprecated_member_use_from_same_package
      const MorphIconButtonVariant legacy = MorphIconButtonVariant.tonal;
      expect(legacy, MorphIconButtonType.tonal);
    });
  });

  group('variant resolution', () {
    for (final Brightness brightness in Brightness.values) {
      for (final MorphVariant variant in apiVariants) {
        testWidgets('${variant.name} ${brightness.name} reads scheme roles', (
          tester,
        ) async {
          for (final MorphIconButtonType type in MorphIconButtonType.values) {
            await tester.pumpWidget(
              apiHost(
                _byType(type, onPressed: () {}, variant: variant),
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
            final Color bg = s.backgroundColor!.resolve(_rest)!;
            final Color fg = s.foregroundColor!.resolve(_rest)!;
            final BorderSide? side = s.side!.resolve(_rest);
            switch (type) {
              case MorphIconButtonType.standard:
                expect(bg, Colors.transparent);
                expect(fg, p.accent);
                expect(side, isNull);
              case MorphIconButtonType.filled:
                expect(<Color>[bg, fg], <Color>[p.color, p.onColor]);
              case MorphIconButtonType.tonal:
                expect(<Color>[bg, fg], <Color>[p.container, p.onContainer]);
              case MorphIconButtonType.outlined:
                expect(bg, Colors.transparent);
                expect(fg, p.accent);
                // Roles sharing the scheme outline keep outlineVariant.
                expect(
                  side!.color,
                  p.outline == scheme.outline
                      ? scheme.outlineVariant
                      : p.outline,
                );
            }
          }
        });
      }
    }

    testWidgets('a null variant keeps the historical colors', (tester) async {
      for (final Brightness brightness in Brightness.values) {
        for (final MorphIconButtonType type in MorphIconButtonType.values) {
          await tester.pumpWidget(
            apiHost(_byType(type, onPressed: () {}), brightness: brightness),
          );
          await tester.pumpAndSettle();
          final MorphColorScheme c = apiScheme(tester);
          final ButtonStyle s = apiMaterialStyle(tester);
          final Color bg = s.backgroundColor!.resolve(_rest)!;
          final Color fg = s.foregroundColor!.resolve(_rest)!;
          switch (type) {
            case MorphIconButtonType.standard:
              expect(
                <Color>[bg, fg],
                <Color>[Colors.transparent, c.onSurfaceVariant],
              );
            case MorphIconButtonType.filled:
              expect(<Color>[bg, fg], <Color>[c.primary, c.onPrimary]);
            case MorphIconButtonType.tonal:
              expect(
                <Color>[bg, fg],
                <Color>[c.secondaryContainer, c.onSecondaryContainer],
              );
            case MorphIconButtonType.outlined:
              expect(
                <Color>[bg, fg],
                <Color>[Colors.transparent, c.onSurfaceVariant],
              );
              expect(s.side!.resolve(_rest)!.color, c.outlineVariant);
          }
        }
      }
    });

    testWidgets('toggle buttons resolve selected and unselected variant', (
      tester,
    ) async {
      Future<void> pumpToggle(bool selected) => tester.pumpWidget(
        apiHost(
          _byType(
            MorphIconButtonType.filled,
            onPressed: () {},
            variant: MorphVariant.danger,
            isSelected: selected,
          ),
        ),
      );
      await pumpToggle(true);
      await tester.pumpAndSettle();
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

    testWidgets('an explicit decoration beats the variant', (tester) async {
      const Color red = Color(0xFFAA0000);
      const Color white = Color(0xFFFFFFFF);
      await tester.pumpWidget(
        apiHost(
          _byType(
            MorphIconButtonType.filled,
            onPressed: () {},
            variant: MorphVariant.primary,
            decoration: const MorphIconButtonDecoration(
              backgroundColor: WidgetStatePropertyAll<Color?>(red),
              foregroundColor: WidgetStatePropertyAll<Color?>(white),
            ),
          ),
        ),
      );
      final ButtonStyle s = apiMaterialStyle(tester);
      expect(s.backgroundColor!.resolve(_rest), red);
      expect(s.foregroundColor!.resolve(_rest), white);
    });

    testWidgets('variant colors follow the inherited theme', (tester) async {
      Future<Color> bgFor(Color seed) async {
        await tester.pumpWidget(
          apiHost(
            _byType(
              MorphIconButtonType.filled,
              onPressed: () {},
              variant: MorphVariant.primary,
            ),
            data: MorphThemeData.light(seedColor: seed),
          ),
        );
        await tester.pumpAndSettle();
        final Color bg = apiMaterialStyle(tester).backgroundColor!
            .resolve(_rest)!;
        expect(bg, apiScheme(tester).primary);
        return bg;
      }

      final Color blue = await bgFor(const Color(0xFF1565C0));
      final Color green = await bgFor(const Color(0xFF2E7D32));
      expect(blue, isNot(green));
    });

    testWidgets('disabled uses the neutral disabled colors', (tester) async {
      await tester.pumpWidget(
        apiHost(
          _byType(MorphIconButtonType.filled, variant: MorphVariant.danger),
        ),
      );
      final MorphColorScheme c = apiScheme(tester);
      final ButtonStyle s = apiMaterialStyle(tester);
      expect(
        s.foregroundColor!.resolve(_rest),
        c.onSurface.withValues(
          alpha: MorphIconButtonTheme.disabledForegroundAlpha,
        ),
      );
    });
  });

  group('contrast', () {
    for (final Brightness brightness in Brightness.values) {
      testWidgets('filled and tonal meet 4.5:1 for every variant '
          '(${brightness.name})', (tester) async {
        for (final MorphVariant variant in apiVariants) {
          for (final MorphIconButtonType type in <MorphIconButtonType>[
            MorphIconButtonType.filled,
            MorphIconButtonType.tonal,
          ]) {
            await tester.pumpWidget(
              apiHost(
                _byType(type, onPressed: () {}, variant: variant),
                brightness: brightness,
              ),
            );
            await tester.pumpAndSettle();
            final ButtonStyle s = apiMaterialStyle(tester);
            expect(
              apiContrast(
                s.foregroundColor!.resolve(_rest)!,
                s.backgroundColor!.resolve(_rest)!,
              ),
              greaterThanOrEqualTo(4.5),
              reason: '${type.name}/${variant.name}/${brightness.name}',
            );
          }
        }
      });
    }
  });

  group('frosted surface', () {
    testWidgets('solid mounts no glass', (tester) async {
      await tester.pumpWidget(
        apiHost(_byType(MorphIconButtonType.tonal, onPressed: () {})),
      );
      expect(find.byType(MorphGlassSurface), findsNothing);
      expect(find.byType(BackdropFilter), findsNothing);
    });

    for (final MorphIconButtonType type in MorphIconButtonType.values) {
      testWidgets('frosted ${type.name} mounts one glass surface', (
        tester,
      ) async {
        await tester.pumpWidget(
          apiHost(
            _byType(
              type,
              onPressed: () {},
              variant: MorphVariant.primary,
              surface: MorphSurface.frosted,
            ),
          ),
        );
        expect(find.byType(MorphGlassSurface), findsOneWidget);
        expect(find.byType(BackdropFilter), findsOneWidget);
        expect(
          apiMaterialStyle(tester).backgroundColor!.resolve(_rest),
          Colors.transparent,
        );
        final MorphGlassSurface glass = tester.widget(
          find.byType(MorphGlassSurface),
        );
        // Transparent types borrow the neutral surface for the tint.
        if (type == MorphIconButtonType.standard ||
            type == MorphIconButtonType.outlined) {
          expect(glass.baseColor, apiScheme(tester).surfaceContainerLow);
        }
      });
    }

    testWidgets('frosted filled tints from the resolved color', (tester) async {
      await tester.pumpWidget(
        apiHost(
          _byType(
            MorphIconButtonType.filled,
            onPressed: () {},
            variant: MorphVariant.danger,
            surface: MorphSurface.frosted,
          ),
        ),
      );
      expect(
        tester
            .widget<MorphGlassSurface>(find.byType(MorphGlassSurface))
            .baseColor,
        apiScheme(tester).error,
      );
    });
  });

  group('interaction, semantics and lifecycle', () {
    testWidgets('onPressed fires and keys are preserved', (tester) async {
      int taps = 0;
      const Key key = ValueKey<String>('icon');
      await tester.pumpWidget(
        apiHost(
          _byType(
            MorphIconButtonType.tonal,
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

    testWidgets('disabled buttons have no residual tap and report disabled', (
      tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await tester.pumpWidget(
        apiHost(
          _byType(
            MorphIconButtonType.filled,
            variant: MorphVariant.danger,
            surface: MorphSurface.frosted,
          ),
        ),
      );
      await tester.tap(find.byType(MorphIconButton), warnIfMissed: false);
      await tester.pump();
      expect(tester.takeException(), isNull);
      expect(
        tester.getSemantics(find.bySemanticsLabel('Add')),
        matchesSemantics(label: 'Add', isButton: true, hasSelectedState: true),
      );
      expect(
        tester.getSemantics(find.byType(IconButton)),
        matchesSemantics(isButton: true, hasEnabledState: true),
      );
      handle.dispose();
    });

    testWidgets('an enabled icon button exposes a button role', (tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await tester.pumpWidget(
        apiHost(_byType(MorphIconButtonType.outlined, onPressed: () {})),
      );
      final SemanticsNode node = tester.getSemantics(
        find.bySemanticsLabel('Add'),
      );
      expect(node.label, 'Add');
      expect(
        tester.getSemantics(find.byType(IconButton)),
        matchesSemantics(
          isButton: true,
          hasEnabledState: true,
          isEnabled: true,
          isFocusable: true,
          hasTapAction: true,
          hasFocusAction: true,
        ),
      );
      handle.dispose();
    });

    testWidgets('rebuilding with new type, variant and surface is stable', (
      tester,
    ) async {
      int taps = 0;
      final List<(MorphIconButtonType, MorphVariant?, MorphSurface)>
      steps = <(MorphIconButtonType, MorphVariant?, MorphSurface)>[
        (MorphIconButtonType.filled, null, MorphSurface.solid),
        (MorphIconButtonType.filled, MorphVariant.danger, MorphSurface.solid),
        (MorphIconButtonType.tonal, MorphVariant.danger, MorphSurface.frosted),
        (
          MorphIconButtonType.outlined,
          MorphVariant.muted,
          MorphSurface.frosted,
        ),
        (MorphIconButtonType.standard, null, MorphSurface.solid),
      ];
      for (final (
            MorphIconButtonType type,
            MorphVariant? variant,
            MorphSurface surface,
          )
          in steps) {
        await tester.pumpWidget(
          apiHost(
            _byType(
              type,
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
      await tester.tap(find.byType(MorphIconButton));
      await tester.pumpAndSettle();
      expect(taps, 1);
    });
  });
}
