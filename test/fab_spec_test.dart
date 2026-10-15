import 'package:flutter_test/flutter_test.dart';
import 'package:morph_expressive/morph_components.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('MorphFabTheme metrics', _fabThemeMetrics);
  group('MorphFabController', _fabController);
  _registerFabWidgetTests();
}

void _fabThemeMetrics() {
  test(
    'size tokens match Morph expressive tables',
    _sizeTokensMatchExpressiveTables,
  );
  test('filled colors use primary roles', _filledColorsUsePrimaryRoles);
  test('disabled uses on-surface alphas', _disabledUsesOnSurfaceAlphas);
}

void _fabController() {
  test('show / hide toggles visibility', _showHideTogglesVisibility);
  testWidgets(
    'scroll notifications hide and show',
    _scrollNotificationsHideAndShow,
  );
}

void _registerFabWidgetTests() {
  testWidgets(
    'MorphFab appear morph starts below resting scale',
    _appearMorphStartsBelowRestingScale,
  );
  testWidgets(
    'MorphFab container transform opens and closes',
    _containerTransformOpensAndCloses,
  );
}

void _sizeTokensMatchExpressiveTables() {
  const theme = MorphFabTheme.defaults;
  final scheme = MorphThemeData.light().colorScheme;

  expect(
    theme
        .resolve(
          size: MorphFabSize.small,
          color: MorphFabColor.primary,
          scheme: scheme,
        )
        .container,
    40,
  );
  expect(
    theme
        .resolve(
          size: MorphFabSize.regular,
          color: MorphFabColor.primary,
          scheme: scheme,
        )
        .container,
    56,
  );
  expect(
    theme
        .resolve(
          size: MorphFabSize.medium,
          color: MorphFabColor.primary,
          scheme: scheme,
        )
        .container,
    80,
  );
  expect(
    theme
        .resolve(
          size: MorphFabSize.medium,
          color: MorphFabColor.primary,
          scheme: scheme,
        )
        .iconSize,
    28,
  );
  expect(
    theme
        .resolve(
          size: MorphFabSize.medium,
          color: MorphFabColor.primary,
          scheme: scheme,
        )
        .radius,
    20,
  );
  expect(
    theme
        .resolve(
          size: MorphFabSize.large,
          color: MorphFabColor.primary,
          scheme: scheme,
        )
        .container,
    96,
  );
}

void _filledColorsUsePrimaryRoles() {
  const theme = MorphFabTheme.defaults;
  final scheme = MorphThemeData.light().colorScheme;

  final filled = theme.resolve(
    size: MorphFabSize.regular,
    color: MorphFabColor.primaryFilled,
    scheme: scheme,
  );
  expect(filled.background, scheme.primary);
  expect(filled.foreground, scheme.onPrimary);

  final container = theme.resolve(
    size: MorphFabSize.regular,
    color: MorphFabColor.primary,
    scheme: scheme,
  );
  expect(container.background, scheme.primaryContainer);
  expect(container.foreground, scheme.onPrimaryContainer);
}

void _disabledUsesOnSurfaceAlphas() {
  const theme = MorphFabTheme.defaults;
  final scheme = MorphThemeData.light().colorScheme;

  final disabled = theme.resolve(
    size: MorphFabSize.regular,
    color: MorphFabColor.primary,
    scheme: scheme,
    enabled: false,
  );
  expect(disabled.background.a, closeTo(0.1, 0.001));
  expect(disabled.foreground.a, closeTo(0.38, 0.001));
}

void _showHideTogglesVisibility() {
  final controller = MorphFabController();
  expect(controller.isVisible, isTrue);
  controller.hide();
  expect(controller.isVisible, isFalse);
  controller.show();
  expect(controller.isVisible, isTrue);
  controller.dispose();
}

Future<void> _scrollNotificationsHideAndShow(WidgetTester tester) async {
  final controller = MorphFabController(scrollThreshold: 4);
  await tester.pumpWidget(
    MorphMaterialApp(
      data: MorphThemeData.light(),
      home: Scaffold(
        body: MorphFabScrollVisibility(
          controller: controller,
          child: ListView.builder(itemCount: 40, itemBuilder: _scrollItem),
        ),
      ),
    ),
  );

  await tester.drag(find.byType(ListView), const Offset(0, -80));
  await tester.pumpAndSettle();
  expect(controller.isVisible, isFalse);

  await tester.drag(find.byType(ListView), const Offset(0, 80));
  await tester.pumpAndSettle();
  expect(controller.isVisible, isTrue);
  controller.dispose();
}

Widget _scrollItem(BuildContext context, int i) {
  return SizedBox(height: 48, child: Text('$i'));
}

Future<void> _appearMorphStartsBelowRestingScale(WidgetTester tester) async {
  await tester.pumpWidget(
    MorphMaterialApp(
      data: MorphThemeData.light(),
      home: const Scaffold(
        body: Center(
          child: MorphFab(appear: true, icon: Icon(Icons.add), onPressed: _noop),
        ),
      ),
    ),
  );

  await tester.pump();
  final transforms = tester.widgetList<Transform>(
    find.descendant(of: find.byType(MorphFab), matching: find.byType(Transform)),
  );
  final scales = transforms
      .map((Transform t) => t.transform.storage[0])
      .where(_belowRestingScale)
      .toList();
  expect(scales, isNotEmpty);

  await tester.pumpAndSettle();
}

bool _belowRestingScale(double scale) => scale < 0.999;

Future<void> _containerTransformOpensAndCloses(WidgetTester tester) async {
  await tester.pumpWidget(
    MorphMaterialApp(
      data: MorphThemeData.light(),
      home: const Scaffold(
        body: Center(
          child: MorphFab(
            icon: Icon(Icons.add),
            tooltip: 'Add',
            openBuilder: _composeDestination,
          ),
        ),
      ),
    ),
  );

  await tester.tap(find.byType(MorphFab));
  await tester.pumpAndSettle();
  expect(find.text('Compose'), findsOneWidget);

  // Navigator back reverses the transform route (not just overlay).
  await tester.tap(find.byIcon(Icons.arrow_back));
  await tester.pumpAndSettle();
  expect(find.text('Compose'), findsNothing);
  expect(find.byType(MorphFab), findsOneWidget);
}

Widget _composeDestination(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('Opened'),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.of(context).maybePop(),
      ),
    ),
    body: const Center(child: Text('Compose')),
  );
}

void _noop() {}
