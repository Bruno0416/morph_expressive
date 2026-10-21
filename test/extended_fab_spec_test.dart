import 'package:flutter_test/flutter_test.dart';
import 'package:morph_expressive/morph_components.dart';
import 'package:material_ui/material_ui.dart'
    show
        AppBar,
        BuildContext,
        Center,
        Column,
        Icon,
        IconButton,
        Icons,
        ListView,
        Navigator,
        Offset,
        Scaffold,
        Size,
        SizedBox,
        Text,
        Widget;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('MorphExtendedFabTheme metrics', _extendedFabThemeMetrics);
  group('MorphExtendedFab colors', _extendedFabColors);
  group('MorphExtendedFabController', _extendedFabController);
  _registerExtendedFabWidgetTests();
}

void _extendedFabThemeMetrics() {
  test(
    'size tokens match Morph expressive tables',
    _sizeTokensMatchExpressiveTables,
  );
  test('min width and focus defaults', _minWidthAndFocusDefaults);
}

void _extendedFabColors() {
  test(
    'container vs filled resolve via MorphFabColor',
    _containerVsFilledResolveViaM3efabcolor,
  );
}

void _extendedFabController() {
  test('expand / collapse toggles extended', _expandCollapseTogglesExtended);
  testWidgets(
    'scroll notifications collapse and expand',
    _scrollNotificationsCollapseAndExpand,
  );
}

void _registerExtendedFabWidgetTests() {
  testWidgets(
    'MorphExtendedFab builds with optional icon and label-only',
    _extendedFabBuildsWithOptionalIconAndLabelOnly,
  );
  testWidgets(
    'MorphExtendedFab sizes use themed heights',
    _extendedFabSizesUseThemedHeights,
  );
  testWidgets(
    'MorphExtendedFab container transform opens and closes',
    _extendedFabContainerTransformOpensAndCloses,
  );
}

void _sizeTokensMatchExpressiveTables() {
  const theme = MorphExtendedFabTheme.defaults;
  final small = theme.resolve(MorphExtendedFabSize.small);
  expect(small.height, 56);
  expect(small.iconSize, 24);
  expect(small.cornerRadius, 16);
  expect(small.leadingSpace, 16);
  expect(small.trailingSpace, 16);
  expect(small.iconLabelGap, 8);
  expect(small.labelRole, MorphTypeRole.titleMedium);

  final medium = theme.resolve(MorphExtendedFabSize.medium);
  expect(medium.height, 80);
  expect(medium.iconSize, 28);
  expect(medium.cornerRadius, 20);
  expect(medium.leadingSpace, 26);
  expect(medium.trailingSpace, 26);
  expect(medium.iconLabelGap, 12);
  expect(medium.labelRole, MorphTypeRole.titleLarge);

  final large = theme.resolve(MorphExtendedFabSize.large);
  expect(large.height, 96);
  expect(large.iconSize, 36);
  expect(large.cornerRadius, 28);
  expect(large.leadingSpace, 28);
  expect(large.trailingSpace, 28);
  expect(large.iconLabelGap, 16);
  expect(large.labelRole, MorphTypeRole.headlineSmall);
}

void _minWidthAndFocusDefaults() {
  const theme = MorphExtendedFabTheme.defaults;
  expect(theme.minWidth, 80);
  expect(theme.focusRingWidth, 3);
  expect(theme.focusRingGap, 2);
}

void _containerVsFilledResolveViaM3efabcolor() {
  final scheme = MorphThemeData.light().colorScheme;
  const fabTheme = MorphFabTheme.defaults;

  final filled = fabTheme.resolve(
    size: MorphFabSize.regular,
    color: MorphFabColor.primaryFilled,
    scheme: scheme,
  );
  expect(filled.background, scheme.primary);
  expect(filled.foreground, scheme.onPrimary);

  final container = fabTheme.resolve(
    size: MorphFabSize.regular,
    color: MorphFabColor.primary,
    scheme: scheme,
  );
  expect(container.background, scheme.primaryContainer);
  expect(container.foreground, scheme.onPrimaryContainer);
}

void _expandCollapseTogglesExtended() {
  final controller = MorphExtendedFabController();
  expect(controller.isExtended, isTrue);
  controller.collapse();
  expect(controller.isExtended, isFalse);
  controller.expand();
  expect(controller.isExtended, isTrue);
  controller.dispose();
}

Future<void> _scrollNotificationsCollapseAndExpand(WidgetTester tester) async {
  final controller = MorphExtendedFabController(scrollThreshold: 4);
  await tester.pumpWidget(
    MorphMaterialApp(
      data: MorphThemeData.light(),
      home: Scaffold(
        body: MorphExtendedFabScrollVisibility(
          controller: controller,
          child: ListView.builder(itemCount: 40, itemBuilder: _scrollItem),
        ),
      ),
    ),
  );

  await tester.drag(find.byType(ListView), const Offset(0, -80));
  await tester.pumpAndSettle();
  expect(controller.isExtended, isFalse);

  await tester.drag(find.byType(ListView), const Offset(0, 80));
  await tester.pumpAndSettle();
  expect(controller.isExtended, isTrue);
  controller.dispose();
}

Widget _scrollItem(BuildContext context, int i) {
  return SizedBox(height: 48, child: Text('$i'));
}

Future<void> _extendedFabBuildsWithOptionalIconAndLabelOnly(
  WidgetTester tester,
) async {
  await tester.pumpWidget(
    MorphMaterialApp(
      data: MorphThemeData.light(),
      home: const Scaffold(
        body: Column(
          children: [
            MorphExtendedFab(
              label: 'Compose',
              icon: Icon(Icons.edit),
              onPressed: _noop,
            ),
            MorphExtendedFab(label: 'Label only', onPressed: _noop),
          ],
        ),
      ),
    ),
  );

  expect(find.text('Compose'), findsOneWidget);
  expect(find.text('Label only'), findsOneWidget);
  expect(find.byIcon(Icons.edit), findsOneWidget);
}

Future<void> _extendedFabSizesUseThemedHeights(WidgetTester tester) async {
  await tester.pumpWidget(
    MorphMaterialApp(
      data: MorphThemeData.light(),
      home: const Scaffold(
        body: Center(
          child: MorphExtendedFab(
            label: 'Compose',
            icon: Icon(Icons.edit),
            size: MorphExtendedFabSize.medium,
            onPressed: _noop,
          ),
        ),
      ),
    ),
  );

  final Size size = tester.getSize(find.byType(MorphExtendedFab));
  expect(size.height, 80);
  expect(size.width, greaterThanOrEqualTo(80));
}

Future<void> _extendedFabContainerTransformOpensAndCloses(
  WidgetTester tester,
) async {
  await tester.pumpWidget(
    MorphMaterialApp(
      data: MorphThemeData.light(),
      home: const Scaffold(
        body: Center(
          child: MorphExtendedFab(
            label: 'Compose',
            icon: Icon(Icons.edit),
            openBuilder: _composeDestination,
          ),
        ),
      ),
    ),
  );

  await tester.tap(find.byType(MorphExtendedFab));
  await tester.pumpAndSettle();
  expect(find.text('Compose dest'), findsOneWidget);

  await tester.tap(find.byIcon(Icons.arrow_back));
  await tester.pumpAndSettle();
  expect(find.text('Compose dest'), findsNothing);
  expect(find.byType(MorphExtendedFab), findsOneWidget);
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
    body: const Center(child: Text('Compose dest')),
  );
}

void _noop() {}
