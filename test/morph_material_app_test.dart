import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morph_expressive/morph_components.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'deriveDarkTemplate preserves non-color tokens',
    _derivedarktemplatePreservesNonColorTokens,
  );
  testWidgets(
    'MorphThemeScope caches dark template across resolve calls',
    _morphthemescopeCachesDarkTemplateAcrossResolveCalls,
  );
  testWidgets(
    'MorphMaterialApp aligns themeMode with autoTheming platform brightness',
    _morphmaterialappAlignsThememodeWithAutothemingPlatformBr,
  );
  testWidgets(
    'MorphMaterialApp toggle via controllerOf updates brightness',
    _morphmaterialappToggleViaControllerofUpdatesBrightness,
  );
  testWidgets(
    'MorphTheme.controllerOf returns controller from MorphMaterialApp',
    _morphthemeControllerofReturnsControllerFromM3ematerialapp,
  );
  testWidgets(
    'MorphMaterialApp forwards MaterialApp constructor fields',
    _morphmaterialappForwardsMaterialappConstructorFields,
  );
  testWidgets(
    'MorphMaterialApp applies light overlay style for light brightness',
    _morphmaterialappAppliesLightOverlayStyleForLightBrightn,
  );
  testWidgets(
    'MorphMaterialApp updates overlay style after brightness toggle',
    _morphmaterialappUpdatesOverlayStyleAfterBrightnessToggle,
  );
  testWidgets(
    'MorphMaterialApp accepts drawUnderSystemBars without error',
    _morphmaterialappAcceptsDrawundersystembarsWithoutError,
  );
  test(
    'MorphMaterialApp defaults drawUnderSystemBars to false',
    _morphmaterialappDefaultsDrawundersystembarsToFalse,
  );
  testWidgets(
    'MorphMaterialApp clears bottom padding when drawUnderSystemBars is true',
    _morphmaterialappClearsBottomPaddingWhenDrawundersystembar,
  );
}

void _derivedarktemplatePreservesNonColorTokens() {
  final light = MorphThemeData.light(seedColor: const Color(0xFF6750A4));
  final MorphThemeData dark = light.deriveDarkTemplate();

  expect(dark.brightness, Brightness.dark);
  expect(dark.typeScale, light.typeScale);
  expect(dark.spacing, light.spacing);
  expect(dark.buttonTheme, light.buttonTheme);
  expect(dark.cardTheme, light.cardTheme);
  expect(dark.colorScheme.primary, isNot(equals(light.colorScheme.primary)));
}

Future<void> _morphthemescopeCachesDarkTemplateAcrossResolveCalls(
  WidgetTester tester,
) async {
  final base = MorphThemeData.light(seedColor: const Color(0xFF6750A4));

  await tester.pumpWidget(
    MediaQuery(
      data: const MediaQueryData(platformBrightness: Brightness.dark),
      child: MorphTheme(
        data: base,
        autoTheming: true,
        child: Builder(
          builder: (BuildContext context) {
            final MorphThemeScopeState? scope = MorphThemeScope.maybeOf(context);
            final MorphThemeData first = scope!.resolve(context);
            final MorphThemeData second = scope.resolve(context);
            expect(identical(first, second), isTrue);
            return const SizedBox.shrink();
          },
        ),
      ),
    ),
  );
}

Future<void> _morphmaterialappAlignsThememodeWithAutothemingPlatformBr(
  WidgetTester tester,
) async {
  final base = MorphThemeData.light(seedColor: const Color(0xFF6750A4));

  Future<void> pumpWithBrightness(Brightness brightness) {
    return tester.pumpWidget(
      MediaQuery(
        data: MediaQueryData(platformBrightness: brightness),
        child: MorphMaterialApp(
          data: base,
          autoTheming: true,
          home: const MorphButton(onPressed: null, child: Text('Probe')),
        ),
      ),
    );
  }

  await pumpWithBrightness(Brightness.light);
  await tester.pumpAndSettle();

  final MaterialApp lightApp = tester.widget(find.byType(MaterialApp));
  expect(lightApp.themeMode, ThemeMode.light);
  expect(
    MorphTheme.of(tester.element(find.byType(MorphButton))).brightness,
    Brightness.light,
  );

  await pumpWithBrightness(Brightness.dark);
  await tester.pumpAndSettle();

  final MaterialApp darkApp = tester.widget(find.byType(MaterialApp));
  expect(darkApp.themeMode, ThemeMode.dark);
  expect(
    MorphTheme.of(tester.element(find.byType(MorphButton))).brightness,
    Brightness.dark,
  );
}

Future<void> _morphmaterialappToggleViaControllerofUpdatesBrightness(
  WidgetTester tester,
) async {
  final base = MorphThemeData.light(seedColor: const Color(0xFF6750A4));

  await tester.pumpWidget(
    MorphMaterialApp(
      data: base,
      autoTheming: true,
      home: Builder(
        builder: (BuildContext context) {
          return MorphButton(
            onPressed: () {
              MorphTheme.controllerOf(context)
                  ?.toggleBrightness(autoTheming: true);
            },
            child: const Text('Toggle'),
          );
        },
      ),
    ),
  );
  await tester.pumpAndSettle();

  expect(
    MorphTheme.of(tester.element(find.byType(MorphButton))).brightness,
    Brightness.light,
  );
  expect(
    tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
    ThemeMode.light,
  );

  await tester.tap(find.text('Toggle'));
  await tester.pumpAndSettle();

  expect(
    MorphTheme.of(tester.element(find.byType(MorphButton))).brightness,
    Brightness.dark,
  );
  expect(
    tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
    ThemeMode.dark,
  );
}

Future<void> _morphthemeControllerofReturnsControllerFromM3ematerialapp(
  WidgetTester tester,
) async {
  final controller = MorphThemeController();
  final base = MorphThemeData.light(seedColor: const Color(0xFF6750A4));

  await tester.pumpWidget(
    MorphMaterialApp(
      data: base,
      autoTheming: true,
      controller: controller,
      home: const MorphButton(onPressed: null, child: Text('Probe')),
    ),
  );
  await tester.pumpAndSettle();

  expect(
    MorphTheme.controllerOf(tester.element(find.byType(MorphButton))),
    controller,
  );
}

Future<void> _morphmaterialappForwardsMaterialappConstructorFields(
  WidgetTester tester,
) async {
  final base = MorphThemeData.light(seedColor: const Color(0xFF6750A4));
  const locale = Locale('en', 'US');
  const supportedLocales = <Locale>[Locale('en', 'US')];

  await tester.pumpWidget(
    MorphMaterialApp(
      data: base,
      locale: locale,
      showPerformanceOverlay: true,
      home: const MorphButton(onPressed: null, child: Text('Probe')),
    ),
  );
  await tester.pumpAndSettle();

  final MaterialApp app = tester.widget(find.byType(MaterialApp));
  expect(app.locale, locale);
  expect(app.supportedLocales, supportedLocales);
  expect(app.showPerformanceOverlay, isTrue);
}

Future<void> _morphmaterialappAppliesLightOverlayStyleForLightBrightn(
  WidgetTester tester,
) async {
  final base = MorphThemeData.light(seedColor: const Color(0xFF6750A4));

  await tester.pumpWidget(
    MediaQuery(
      data: const MediaQueryData(),
      child: MorphMaterialApp(
        data: base,
        autoTheming: true,
        home: const MorphButton(onPressed: null, child: Text('Probe')),
      ),
    ),
  );
  await tester.pumpAndSettle();

  final AnnotatedRegion<SystemUiOverlayStyle> region = tester.widget(
    find.byType(AnnotatedRegion<SystemUiOverlayStyle>),
  );
  final SystemUiOverlayStyle style = region.value;

  expect(style.statusBarColor, Colors.transparent);
  expect(style.systemNavigationBarColor, Colors.transparent);
  expect(style.statusBarIconBrightness, Brightness.dark);
  expect(style.systemNavigationBarIconBrightness, Brightness.dark);
  expect(style.statusBarBrightness, Brightness.dark);
  expect(style.systemStatusBarContrastEnforced, isFalse);
  expect(style.systemNavigationBarContrastEnforced, isFalse);
}

Future<void> _morphmaterialappUpdatesOverlayStyleAfterBrightnessToggle(
  WidgetTester tester,
) async {
  final base = MorphThemeData.light(seedColor: const Color(0xFF6750A4));

  await tester.pumpWidget(
    MorphMaterialApp(
      data: base,
      autoTheming: true,
      home: Builder(
        builder: (BuildContext context) {
          return MorphButton(
            onPressed: () {
              MorphTheme.controllerOf(context)
                  ?.toggleBrightness(autoTheming: true);
            },
            child: const Text('Toggle'),
          );
        },
      ),
    ),
  );
  await tester.pumpAndSettle();

  SystemUiOverlayStyle overlayStyle() => tester
      .widget<AnnotatedRegion<SystemUiOverlayStyle>>(
        find.byType(AnnotatedRegion<SystemUiOverlayStyle>),
      )
      .value;

  expect(overlayStyle().statusBarIconBrightness, Brightness.dark);

  await tester.tap(find.text('Toggle'));
  await tester.pumpAndSettle();

  expect(overlayStyle().statusBarIconBrightness, Brightness.light);
  expect(overlayStyle().systemNavigationBarIconBrightness, Brightness.light);
  expect(overlayStyle().statusBarBrightness, Brightness.light);
}

Future<void> _morphmaterialappAcceptsDrawundersystembarsWithoutError(
  WidgetTester tester,
) async {
  final base = MorphThemeData.light(seedColor: const Color(0xFF6750A4));

  await tester.pumpWidget(
    MorphMaterialApp(
      data: base,
      drawUnderSystemBars: true,
      home: const MorphButton(onPressed: null, child: Text('Probe')),
    ),
  );
  await tester.pumpAndSettle();

  expect(find.byType(MorphMaterialApp), findsOneWidget);
  expect(find.byType(AnnotatedRegion<SystemUiOverlayStyle>), findsOneWidget);

  await tester.pumpWidget(
    MorphMaterialApp(
      data: base,
      home: const MorphButton(onPressed: null, child: Text('Probe')),
    ),
  );
  await tester.pumpAndSettle();

  expect(find.byType(MorphMaterialApp), findsOneWidget);
}

void _morphmaterialappDefaultsDrawundersystembarsToFalse() {
  final app = MorphMaterialApp(
    data: MorphThemeData.light(seedColor: const Color(0xFF6750A4)),
    home: const SizedBox.shrink(),
  );

  expect(app.drawUnderSystemBars, isFalse);
}

Future<void> _morphmaterialappClearsBottomPaddingWhenDrawundersystembar(
  WidgetTester tester,
) async {
  final base = MorphThemeData.light(seedColor: const Color(0xFF6750A4));
  const media = MediaQueryData(
    padding: EdgeInsets.only(bottom: 48),
    viewPadding: EdgeInsets.only(bottom: 48),
  );
  double capturedBottom = -1;

  Future<void> pump({required bool drawUnderSystemBars}) {
    return tester.pumpWidget(
      MediaQuery(
        data: media,
        child: MorphMaterialApp(
          data: base,
          drawUnderSystemBars: drawUnderSystemBars,
          home: Builder(
            builder: (BuildContext context) {
              capturedBottom = MediaQuery.paddingOf(context).bottom;
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  await pump(drawUnderSystemBars: true);
  await tester.pumpAndSettle();
  expect(capturedBottom, 0);

  await pump(drawUnderSystemBars: false);
  await tester.pumpAndSettle();
  expect(capturedBottom, 48);
}
