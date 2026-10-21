import 'package:flutter_test/flutter_test.dart';
import 'package:morph_expressive/morph_components.dart';
import 'package:material_ui/material_ui.dart'
    show
        AnimatedContainer,
        BoxDecoration,
        Brightness,
        Color,
        MaterialApp,
        MediaQuery,
        MediaQueryData,
        Text;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'MorphThemeController toggles wrapped component brightness',
    _morphthemecontrollerTogglesWrappedComponentBrightness,
  );
  testWidgets(
    'MorphThemeController updates card background color after toggle',
    _morphthemecontrollerUpdatesCardBackgroundColorAfterToggl,
  );
  testWidgets(
    'autoTheming toggle inverts platform brightness',
    _autothemingToggleInvertsPlatformBrightness,
  );
  testWidgets(
    'autoTheming toggle keeps tracking platform brightness when OS changes',
    _autothemingToggleKeepsTrackingPlatformBrightnessWhenO,
  );
  testWidgets(
    'toggle without autoTheming locks absolute brightness',
    _toggleWithoutAutothemingLocksAbsoluteBrightness,
  );
}

Future<void> _morphthemecontrollerTogglesWrappedComponentBrightness(
  WidgetTester tester,
) async {
  final controller = MorphThemeController();
  final base = MorphThemeData.light(seedColor: const Color(0xFF6750A4));

  await tester.pumpWidget(
    MaterialApp(
      theme: base.toThemeData(),
      home: MorphTheme(
        data: base,
        controller: controller,
        child: const MorphButton(onPressed: null, child: Text('Probe')),
      ),
    ),
  );
  await tester.pumpAndSettle();

  expect(
    MorphTheme.of(tester.element(find.byType(MorphButton))).brightness,
    Brightness.light,
  );

  controller.setBrightness(Brightness.dark);
  await tester.pumpAndSettle();

  expect(
    MorphTheme.of(tester.element(find.byType(MorphButton))).brightness,
    Brightness.dark,
  );
}

Future<void> _morphthemecontrollerUpdatesCardBackgroundColorAfterToggl(
  WidgetTester tester,
) async {
  final controller = MorphThemeController();
  final base = MorphThemeData.light(seedColor: const Color(0xFF6750A4));

  await tester.pumpWidget(
    MaterialApp(
      theme: base.toThemeData(),
      home: MorphTheme(
        data: base,
        controller: controller,
        child: const MorphCard(child: Text('Card')),
      ),
    ),
  );
  await tester.pumpAndSettle();

  final Finder containerFinder = find.byType(AnimatedContainer);
  expect(containerFinder, findsOneWidget);

  MorphThemeData theme = MorphTheme.of(tester.element(find.byType(MorphCard)));
  final Color lightColor = theme.cardTheme.backgroundColor(
    theme.colorScheme,
    MorphCardVariant.elevated,
  );

  AnimatedContainer container = tester.widget(containerFinder);
  expect((container.decoration! as BoxDecoration).color, lightColor);

  controller.setBrightness(Brightness.dark);
  await tester.pump();

  theme = MorphTheme.of(tester.element(find.byType(MorphCard)));
  final Color darkColor = theme.cardTheme.backgroundColor(
    theme.colorScheme,
    MorphCardVariant.elevated,
  );

  container = tester.widget(containerFinder);
  expect((container.decoration! as BoxDecoration).color, darkColor);
  expect(darkColor, isNot(equals(lightColor)));
}

Future<void> _autothemingToggleInvertsPlatformBrightness(
  WidgetTester tester,
) async {
  final controller = MorphThemeController();
  final base = MorphThemeData.light(seedColor: const Color(0xFF6750A4));

  Future<void> pumpWithController() {
    return tester.pumpWidget(
      MaterialApp(
        theme: base.toThemeData(),
        home: MediaQuery(
          data: const MediaQueryData(),
          child: MorphTheme(
            data: base,
            autoTheming: true,
            controller: controller,
            child: const MorphButton(onPressed: null, child: Text('Probe')),
          ),
        ),
      ),
    );
  }

  await pumpWithController();
  await tester.pumpAndSettle();

  expect(
    MorphTheme.of(tester.element(find.byType(MorphButton))).brightness,
    Brightness.light,
  );

  controller.toggleBrightness(autoTheming: true);
  await tester.pumpAndSettle();

  expect(
    MorphTheme.of(tester.element(find.byType(MorphButton))).brightness,
    Brightness.dark,
  );
  expect(controller.invertPlatformBrightness, isTrue);
  expect(controller.brightnessOverride, isNull);

  controller.toggleBrightness(autoTheming: true);
  await tester.pumpAndSettle();

  expect(
    MorphTheme.of(tester.element(find.byType(MorphButton))).brightness,
    Brightness.light,
  );
  expect(controller.invertPlatformBrightness, isFalse);
}

Future<void> _autothemingToggleKeepsTrackingPlatformBrightnessWhenO(
  WidgetTester tester,
) async {
  final controller = MorphThemeController();
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
            controller: controller,
            child: const MorphButton(onPressed: null, child: Text('Probe')),
          ),
        ),
      ),
    );
  }

  await pumpWithBrightness(Brightness.light);
  await tester.pumpAndSettle();

  controller.toggleBrightness(autoTheming: true);
  await tester.pumpAndSettle();

  expect(
    MorphTheme.of(tester.element(find.byType(MorphButton))).brightness,
    Brightness.dark,
  );

  await pumpWithBrightness(Brightness.dark);
  await tester.pumpAndSettle();

  expect(
    MorphTheme.of(tester.element(find.byType(MorphButton))).brightness,
    Brightness.light,
  );
}

Future<void> _toggleWithoutAutothemingLocksAbsoluteBrightness(
  WidgetTester tester,
) async {
  final controller = MorphThemeController();
  final base = MorphThemeData.light(seedColor: const Color(0xFF6750A4));

  await tester.pumpWidget(
    MaterialApp(
      theme: base.toThemeData(),
      home: MediaQuery(
        data: const MediaQueryData(platformBrightness: Brightness.dark),
        child: MorphTheme(
          data: base,
          controller: controller,
          child: const MorphButton(onPressed: null, child: Text('Probe')),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();

  controller.toggleBrightness();
  await tester.pumpAndSettle();

  expect(
    MorphTheme.of(tester.element(find.byType(MorphButton))).brightness,
    Brightness.dark,
  );
  expect(controller.brightnessOverride, Brightness.dark);

  await tester.pumpWidget(
    MaterialApp(
      theme: base.toThemeData(),
      home: MediaQuery(
        data: const MediaQueryData(),
        child: MorphTheme(
          data: base,
          controller: controller,
          child: const MorphButton(onPressed: null, child: Text('Probe')),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();

  expect(
    MorphTheme.of(tester.element(find.byType(MorphButton))).brightness,
    Brightness.dark,
  );
}
