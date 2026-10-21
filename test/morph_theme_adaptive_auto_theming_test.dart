import 'package:flutter_test/flutter_test.dart';
import 'package:morph_expressive/morph_components.dart';
import 'package:material_ui/material_ui.dart'
    show
        AnimatedContainer,
        BoxDecoration,
        Brightness,
        BuildContext,
        Builder,
        ButtonStyle,
        Color,
        Icon,
        IconButton,
        Icons,
        Material,
        MaterialApp,
        MediaQuery,
        MediaQueryData,
        Text,
        TextStyle,
        WidgetState;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'static MorphTheme defaults to light when adaptive fields are null',
    _staticM3ethemeDefaultsToLightWhenAdaptiveFieldsAreN,
  );
  testWidgets(
    'autoTheming resolves platform brightness without app setState',
    _autothemingResolvesPlatformBrightnessWithoutAppSetstat,
  );
  testWidgets(
    'autoTheming updates when platform brightness changes without setState',
    _autothemingUpdatesWhenPlatformBrightnessChangesWithout,
  );
  testWidgets(
    'autoTheming updates card painted color when platform brightness changes without setState',
    _autothemingUpdatesCardPaintedColorWhenPlatformBrightn,
  );
  testWidgets(
    'autoTheming updates icon button painted color when platform brightness changes without setState',
    _autothemingUpdatesIconButtonPaintedColorWhenPlatform,
  );
  testWidgets(
    'autoTheming updates navigation bar painted color when platform brightness changes without setState',
    _autothemingUpdatesNavigationBarPaintedColorWhenPlatfo,
  );
}

Future<void> _staticM3ethemeDefaultsToLightWhenAdaptiveFieldsAreN(
  WidgetTester tester,
) async {
  final base = MorphThemeData.light(seedColor: const Color(0xFF6750A4));

  await tester.pumpWidget(
    MaterialApp(
      home: MorphTheme(
        data: base,
        child: Builder(
          builder: (BuildContext context) {
            final theme = MorphTheme.of(context);
            return Text(
              'brightness:${theme.brightness.name}',
              style: TextStyle(color: theme.colorScheme.primary),
            );
          },
        ),
      ),
    ),
  );

  expect(find.text('brightness:light'), findsOneWidget);
}

Future<void> _autothemingResolvesPlatformBrightnessWithoutAppSetstat(
  WidgetTester tester,
) async {
  final base = MorphThemeData.light(seedColor: const Color(0xFF6750A4));

  await tester.pumpWidget(
    MaterialApp(
      theme: base.toThemeData(),
      home: MediaQuery(
        data: const MediaQueryData(platformBrightness: Brightness.dark),
        child: MorphTheme(
          data: base,
          autoTheming: true,
          child: const MorphButton(onPressed: null, child: Text('Probe')),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();

  final MorphThemeData resolved = MorphTheme.of(
    tester.element(find.byType(MorphButton)),
  );
  expect(resolved.brightness, Brightness.dark);
}

Future<void> _autothemingUpdatesWhenPlatformBrightnessChangesWithout(
  WidgetTester tester,
) async {
  final base = MorphThemeData.light(seedColor: const Color(0xFF6750A4));

  Future<void> pumpWithBrightness(Brightness brightness) {
    return tester.pumpWidget(
      MaterialApp(
        theme: base.toThemeData(),
        home: MediaQuery(
          data: MediaQueryData(platformBrightness: brightness),
          child: MorphTheme(
            data: base,
            autoTheming: true,
            child: const MorphButton(onPressed: null, child: Text('Probe')),
          ),
        ),
      ),
    );
  }

  await pumpWithBrightness(Brightness.light);
  await tester.pumpAndSettle();

  expect(
    MorphTheme.of(tester.element(find.byType(MorphButton))).brightness,
    Brightness.light,
  );

  await pumpWithBrightness(Brightness.dark);
  await tester.pumpAndSettle();

  expect(
    MorphTheme.of(tester.element(find.byType(MorphButton))).brightness,
    Brightness.dark,
  );
}

Future<void> _autothemingUpdatesCardPaintedColorWhenPlatformBrightn(
  WidgetTester tester,
) async {
  final base = MorphThemeData.light(seedColor: const Color(0xFF6750A4));

  Future<void> pumpWithBrightness(Brightness brightness) {
    return tester.pumpWidget(
      MaterialApp(
        theme: base.toThemeData(),
        home: MediaQuery(
          data: MediaQueryData(platformBrightness: brightness),
          child: MorphTheme(
            data: base,
            autoTheming: true,
            child: const MorphCard(child: Text('Card')),
          ),
        ),
      ),
    );
  }

  await pumpWithBrightness(Brightness.light);
  await tester.pumpAndSettle();

  final Finder containerFinder = find.byType(AnimatedContainer);
  MorphThemeData lightTheme = MorphTheme.of(
    tester.element(find.byType(MorphCard)),
  );
  final Color lightColor = lightTheme.cardTheme.backgroundColor(
    lightTheme.colorScheme,
    MorphCardVariant.elevated,
  );
  expect(
    (tester.widget<AnimatedContainer>(containerFinder).decoration!
            as BoxDecoration)
        .color,
    lightColor,
  );

  await pumpWithBrightness(Brightness.dark);
  await tester.pump();

  final MorphThemeData darkTheme = MorphTheme.of(
    tester.element(find.byType(MorphCard)),
  );
  final Color darkColor = darkTheme.cardTheme.backgroundColor(
    darkTheme.colorScheme,
    MorphCardVariant.elevated,
  );
  expect(
    (tester.widget<AnimatedContainer>(containerFinder).decoration!
            as BoxDecoration)
        .color,
    darkColor,
  );
  expect(darkColor, isNot(equals(lightColor)));
}

Future<void> _autothemingUpdatesIconButtonPaintedColorWhenPlatform(
  WidgetTester tester,
) async {
  final base = MorphThemeData.light(seedColor: const Color(0xFF6750A4));

  Future<void> pumpWithBrightness(Brightness brightness) {
    return tester.pumpWidget(
      MaterialApp(
        theme: base.toThemeData(),
        home: MediaQuery(
          data: MediaQueryData(platformBrightness: brightness),
          child: MorphTheme(
            data: base,
            autoTheming: true,
            child: MorphIconButton(
              icon: const Icon(Icons.add),
              onPressed: () {},
            ),
          ),
        ),
      ),
    );
  }

  await pumpWithBrightness(Brightness.light);
  await tester.pumpAndSettle();

  final Finder iconButtonFinder = find.byType(IconButton);
  final Color lightPrimary = MorphTheme.of(
    tester.element(find.byType(MorphIconButton)),
  ).colorScheme.primary;
  final ButtonStyle lightStyle = tester
      .widget<IconButton>(iconButtonFinder)
      .style!;
  expect(lightStyle.backgroundColor!.resolve(<WidgetState>{}), lightPrimary);

  await pumpWithBrightness(Brightness.dark);
  await tester.pump();

  final Color darkPrimary = MorphTheme.of(
    tester.element(find.byType(MorphIconButton)),
  ).colorScheme.primary;
  final ButtonStyle darkStyle = tester
      .widget<IconButton>(iconButtonFinder)
      .style!;
  expect(darkStyle.backgroundColor!.resolve(<WidgetState>{}), darkPrimary);
  expect(darkPrimary, isNot(equals(lightPrimary)));
}

Future<void> _autothemingUpdatesNavigationBarPaintedColorWhenPlatfo(
  WidgetTester tester,
) async {
  final base = MorphThemeData.light(seedColor: const Color(0xFF6750A4));
  const destinations = <MorphNavigationBarDestination>[
    MorphNavigationBarDestination(icon: Icon(Icons.home), label: 'Home'),
    MorphNavigationBarDestination(icon: Icon(Icons.search), label: 'Search'),
  ];

  Future<void> pumpWithBrightness(Brightness brightness) {
    return tester.pumpWidget(
      MaterialApp(
        theme: base.toThemeData(),
        home: MediaQuery(
          data: MediaQueryData(platformBrightness: brightness),
          child: MorphTheme(
            data: base,
            autoTheming: true,
            child: const MorphNavigationBar(destinations: destinations),
          ),
        ),
      ),
    );
  }

  await pumpWithBrightness(Brightness.light);
  await tester.pumpAndSettle();

  final Finder materialFinder = find.descendant(
    of: find.byType(MorphNavigationBar),
    matching: find.byType(Material),
  );
  final MorphThemeData lightTheme = MorphTheme.of(
    tester.element(find.byType(MorphNavigationBar)),
  );
  final Color lightBg = lightTheme.navigationBarTheme.containerColor(
    lightTheme.colorScheme,
  );
  expect(tester.widget<Material>(materialFinder.first).color, lightBg);

  await pumpWithBrightness(Brightness.dark);
  await tester.pump();

  final MorphThemeData darkTheme = MorphTheme.of(
    tester.element(find.byType(MorphNavigationBar)),
  );
  final Color darkBg = darkTheme.navigationBarTheme.containerColor(
    darkTheme.colorScheme,
  );
  expect(tester.widget<Material>(materialFinder.first).color, darkBg);
  expect(darkBg, isNot(equals(lightBg)));
}
