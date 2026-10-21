import 'package:flutter_test/flutter_test.dart';
import 'package:morph_expressive/morph_components.dart';
import 'package:material_ui/material_ui.dart'
    show
        Brightness,
        Builder,
        Color,
        ColorScheme,
        DefaultMaterialLocalizations,
        DefaultTextStyle,
        DefaultWidgetsLocalizations,
        Icon,
        IconTheme,
        IconThemeData,
        LocalizationsDelegate,
        MaterialApp,
        PageRouteBuilder,
        RouteSettings,
        SizedBox,
        Theme,
        ThemeData,
        Widget,
        WidgetBuilder,
        WidgetsApp;

/// Captures the resolved [MorphThemeData] beneath [app].
Future<MorphThemeData> _resolve(WidgetTester tester, Widget app) async {
  await tester.pumpWidget(app);
  return MorphTheme.of(tester.element(find.byType(SizedBox)));
}

Widget _capture(ThemeData theme, {MorphThemeData? tokens}) {
  const probe = SizedBox.shrink();
  return MaterialApp(
    theme: theme,
    home: tokens == null ? probe : MorphTheme(data: tokens, child: probe),
  );
}

void main() {
  testWidgets(
    'MorphTheme.of derives from the ambient Material theme',
    _morphthemeOfDerivesFromTheAmbientMaterialTheme,
  );
  testWidgets(
    'an explicit MorphTheme overrides the ambient Material theme',
    _anExplicitM3ethemeOverridesTheAmbientMaterialTheme,
  );
  test(
    'toThemeData projects the expressive tokens onto Material',
    _tothemedataProjectsTheExpressiveTokensOntoMaterial,
  );
  test(
    'textTheme and iconTheme track colorScheme via withColorScheme',
    _textthemeAndIconthemeTrackColorschemeViaWithcolorschem,
  );
  test(
    'explicit iconTheme color is preserved across scheme changes',
    _explicitIconthemeColorIsPreservedAcrossSchemeChanges,
  );
  testWidgets(
    'MorphResolvedTheme projects text/icon/color onto Material Theme',
    _morphresolvedthemeProjectsTextIconColorOntoMaterialThem,
  );
  testWidgets(
    'Material Theme tracks withColorScheme under MorphTheme',
    _materialThemeTracksWithcolorschemeUnderM3etheme,
  );
  testWidgets(
    'MorphTheme.of is stable across rebuilds under a Material theme',
    _morphthemeOfIsStableAcrossRebuildsUnderAMaterialTheme,
  );
  testWidgets(
    'component theme override via copyWith',
    _componentThemeOverrideViaCopywith,
  );
  testWidgets(
    'MorphNavigationRail renders under MorphTheme without Material Theme',
    _morphnavigationrailRendersUnderM3ethemeWithoutMaterialTh,
  );
}

Future<void> _morphthemeOfDerivesFromTheAmbientMaterialTheme(
  WidgetTester tester,
) async {
  final scheme = ColorScheme.fromSeed(seedColor: const Color(0xFF00695C));
  final resolved = await _resolve(
    tester,
    _capture(ThemeData(colorScheme: scheme, useMaterial3: true)),
  );
  expect(resolved.colorScheme.primary, scheme.primary);
  expect(resolved.colorScheme.surface, scheme.surface);
}

Future<void> _anExplicitM3ethemeOverridesTheAmbientMaterialTheme(
  WidgetTester tester,
) async {
  final tokens = MorphThemeData.light(seedColor: const Color(0xFFB3261E));
  final resolved = await _resolve(
    tester,
    _capture(
      ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF00695C)),
      ),
      tokens: tokens,
    ),
  );
  expect(resolved.colorScheme.primary, tokens.colorScheme.primary);
}

void _tothemedataProjectsTheExpressiveTokensOntoMaterial() {
  final tokens = MorphThemeData.light(seedColor: const Color(0xFF6750A4));
  final material = tokens.toThemeData();
  expect(material.useMaterial3, isTrue);
  expect(material.colorScheme.primary, tokens.colorScheme.primary);
  expect(
    material.textTheme.labelLarge?.fontSize,
    tokens.typeScale.labelLarge.fontSize,
  );
  expect(material.textTheme.bodyMedium?.color, tokens.colorScheme.onSurface);
  expect(material.iconTheme.color, tokens.colorScheme.onSurface);
  expect(material.iconTheme.size, 24);
}

void _textthemeAndIconthemeTrackColorschemeViaWithcolorschem() {
  final light = MorphThemeData.light(seedColor: const Color(0xFF6750A4));
  final darkScheme = MorphColorScheme.fromSeed(
    const Color(0xFF6750A4),
    brightness: Brightness.dark,
  );
  final updated = light.withColorScheme(darkScheme);

  expect(updated.textTheme.bodyMedium?.color, darkScheme.onSurface);
  expect(updated.resolvedIconTheme.color, darkScheme.onSurface);
  expect(updated.resolvedIconTheme.size, light.iconTheme.size);
}

void _explicitIconthemeColorIsPreservedAcrossSchemeChanges() {
  const override = Color(0xFF123456);
  final tokens = MorphThemeData.light().copyWith(
    iconTheme: const IconThemeData(size: 20, color: override),
  );
  final updated = tokens.withColorScheme(
    MorphColorScheme.fromSeed(
      const Color(0xFF00695C),
      brightness: Brightness.dark,
    ),
  );
  expect(updated.resolvedIconTheme.color, override);
  expect(updated.resolvedIconTheme.size, 20);
}

Future<void> _morphresolvedthemeProjectsTextIconColorOntoMaterialThem(
  WidgetTester tester,
) async {
  final tokens = MorphThemeData.light(seedColor: const Color(0xFFB3261E))
      .copyWith(iconTheme: const IconThemeData(size: 28));
  final stale = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF00695C)),
  );

  await tester.pumpWidget(
    MaterialApp(
      theme: stale,
      home: MorphTheme(
        data: tokens,
        child: Builder(
          builder: (context) {
            final material = Theme.of(context);
            expect(material.colorScheme.primary, tokens.colorScheme.primary);
            expect(
              material.textTheme.bodyMedium?.color,
              tokens.colorScheme.onSurface,
            );
            expect(material.iconTheme.color, tokens.colorScheme.onSurface);
            expect(material.iconTheme.size, 28);
            expect(
              DefaultTextStyle.of(context).style.color,
              tokens.colorScheme.onSurface,
            );
            expect(IconTheme.of(context).size, 28);
            return const SizedBox.shrink();
          },
        ),
      ),
    ),
  );
}

Future<void> _materialThemeTracksWithcolorschemeUnderM3etheme(
  WidgetTester tester,
) async {
  final light = MorphThemeData.light(seedColor: const Color(0xFF6750A4));
  final dark = light.withColorScheme(
    MorphColorScheme.fromSeed(
      const Color(0xFF6750A4),
      brightness: Brightness.dark,
    ),
  );

  await tester.pumpWidget(
    MaterialApp(
      theme: light.toThemeData(),
      home: MorphTheme(
        data: dark,
        child: Builder(
          builder: (context) {
            final material = Theme.of(context);
            expect(material.brightness, Brightness.dark);
            expect(
              material.textTheme.bodyMedium?.color,
              dark.colorScheme.onSurface,
            );
            expect(material.iconTheme.color, dark.colorScheme.onSurface);
            return const SizedBox.shrink();
          },
        ),
      ),
    ),
  );
}

Future<void> _morphthemeOfIsStableAcrossRebuildsUnderAMaterialTheme(
  WidgetTester tester,
) async {
  final first = await _resolve(tester, _capture(ThemeData()));
  tester.element(find.byType(SizedBox)).markNeedsBuild();
  await tester.pump();
  final second = MorphTheme.of(tester.element(find.byType(SizedBox)));
  expect(identical(first, second), isTrue);
}

Future<void> _componentThemeOverrideViaCopywith(WidgetTester tester) async {
  const customCheckbox = MorphCheckboxTheme(boxSize: 24);
  final tokens = MorphThemeData.light().copyWith(checkboxTheme: customCheckbox);
  final resolved = await _resolve(
    tester,
    _capture(ThemeData(), tokens: tokens),
  );
  expect(resolved.checkboxTheme.boxSize, 24);
}

Future<void> _morphnavigationrailRendersUnderM3ethemeWithoutMaterialTh(
  WidgetTester tester,
) async {
  final tokens = MorphThemeData.light();
  await tester.pumpWidget(
    WidgetsApp(
      color: tokens.colorScheme.surface,
      pageRouteBuilder: <T>(RouteSettings settings, WidgetBuilder builder) {
        return PageRouteBuilder<T>(
          settings: settings,
          pageBuilder: (context, _, _) => builder(context),
        );
      },
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        DefaultMaterialLocalizations.delegate,
        DefaultWidgetsLocalizations.delegate,
      ],
      home: MorphTheme(
        data: tokens,
        child: MorphNavigationRail(
          type: MorphNavigationRailType.alwaysExpand,
          selectedIndex: 0,
          onDestinationSelected: (_) {},
          sections: const <MorphNavigationRailSection>[
            MorphNavigationRailSection(
              destinations: <MorphNavigationRailDestination>[
                MorphNavigationRailDestination(
                  icon: Icon(MorphIcons.inbox),
                  label: 'Inbox',
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
  await tester.pump();
  expect(find.text('Inbox'), findsOneWidget);
}
