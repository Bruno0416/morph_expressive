import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morph_expressive/morph_components.dart';
import 'package:material_ui/material_ui.dart'
    show
        Align,
        Alignment,
        AppBar,
        BuildContext,
        Builder,
        Center,
        Clip,
        FocusHighlightStrategy,
        FocusManager,
        Icon,
        IconButton,
        Icons,
        MaterialPageRoute,
        Navigator,
        Scaffold,
        SingleChildScrollView,
        Size,
        SizedBox,
        Stack,
        Text,
        TextButton,
        Widget;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  tearDown(MorphFocusInteraction.resetForTest);
  group('MorphFabMenuTheme defaults', _fabMenuThemeDefaults);
  group('MorphFabMenuController', _fabMenuController);
  _registerFabMenuOpenTests();
  _registerFabMenuLayoutTests();
}

void _fabMenuThemeDefaults() {
  test('measurement tokens match spec', _measurementTokensMatchSpec);
  test(
    'closed size follows MorphFabSize when override is null',
    _closedSizeFollowsM3efabsizeWhenOverrideIsNull,
  );
  test(
    'color sets resolve filled close and container items',
    _colorSetsResolveFilledCloseAndContainerItems,
  );
}

void _fabMenuController() {
  test('updateOpen tracks isOpen', _updateOpenTracksIsOpen);
}

void _registerFabMenuOpenTests() {
  testWidgets('MorphFabMenu opens and shows items', _fabMenuOpensAndShowsItems);
  testWidgets(
    'MorphFabMenu controller open / close',
    _fabMenuControllerOpenClose,
  );
  testWidgets(
    'MorphFabMenu item container transform opens and closes',
    _fabMenuItemContainerTransformOpensAndCloses,
  );
}

void _registerFabMenuLayoutTests() {
  testWidgets(
    'focused item ring paints above neighboring pills',
    _focusedItemRingPaintsAboveNeighboringPills,
  );
  testWidgets(
    'large FAB keeps last item above close with menuOffset',
    _largeFabKeepsLastItemAboveCloseWithMenuOffset,
  );
  testWidgets(
    'short viewport keeps close hittable while items scroll',
    _shortViewportKeepsCloseHittableWhileItemsScroll,
  );
  testWidgets(
    'system back closes the menu before the route',
    _systemBackClosesTheMenuBeforeTheRoute,
  );
}

void _measurementTokensMatchSpec() {
  const theme = MorphFabMenuTheme.defaults;
  expect(theme.itemHeight, 56);
  expect(theme.itemLeading, 24);
  expect(theme.itemTrailing, 24);
  expect(theme.iconLabelGap, 8);
  expect(theme.itemGap, 4);
  expect(theme.menuOffset, 8);
  expect(theme.iconSize, 24);
  expect(theme.closeIconSize, 20);
  expect(theme.openFabContainer, 56);
  expect(theme.focusRingWidth, 3);
  expect(theme.focusRingGap, 2);
  expect(theme.itemElevation, 0);
  expect(theme.closeElevation, MorphElevation.level3);
  expect(theme.closeHoverElevation, MorphElevation.level4);
}

void _closedSizeFollowsM3efabsizeWhenOverrideIsNull() {
  const theme = MorphFabMenuTheme.defaults;
  const fabTheme = MorphFabTheme.defaults;
  expect(
    theme.resolveClosedContainer(
      size: MorphFabSize.regular,
      fabTheme: fabTheme,
    ),
    56,
  );
  expect(
    theme.resolveClosedContainer(size: MorphFabSize.medium, fabTheme: fabTheme),
    80,
  );
  expect(
    theme.resolveClosedContainer(size: MorphFabSize.large, fabTheme: fabTheme),
    96,
  );
}

void _colorSetsResolveFilledCloseAndContainerItems() {
  const theme = MorphFabMenuTheme.defaults;
  final scheme = MorphThemeData.light().colorScheme;

  expect(
    MorphFabMenuTheme.colorSetFor(MorphFabColor.primary),
    MorphFabMenuColorSet.primary,
  );
  expect(
    MorphFabMenuTheme.colorSetFor(MorphFabColor.surface),
    MorphFabMenuColorSet.primary,
  );
  expect(
    MorphFabMenuTheme.colorSetFor(MorphFabColor.secondaryFilled),
    MorphFabMenuColorSet.secondary,
  );

  expect(
    theme.itemContainerColor(scheme, MorphFabMenuColorSet.primary),
    scheme.primaryContainer,
  );
  expect(
    theme.itemForegroundColor(scheme, MorphFabMenuColorSet.primary),
    scheme.onPrimaryContainer,
  );
  expect(
    theme.closeContainerColor(scheme, MorphFabMenuColorSet.secondary),
    scheme.secondary,
  );
  expect(
    theme.closeForegroundColor(scheme, MorphFabMenuColorSet.tertiary),
    scheme.onTertiary,
  );
}

void _updateOpenTracksIsOpen() {
  final controller = MorphFabMenuController();
  expect(controller.isOpen, isFalse);
  controller.updateOpen(open: true);
  expect(controller.isOpen, isTrue);
  controller.updateOpen(open: false);
  expect(controller.isOpen, isFalse);
  controller.dispose();
}

Future<void> _fabMenuOpensAndShowsItems(WidgetTester tester) async {
  await tester.pumpWidget(
    MorphMaterialApp(
      data: MorphThemeData.light(),
      home: Scaffold(
        body: Align(
          alignment: Alignment.bottomCenter,
          child: MorphFabMenu(
            items: const <MorphFabMenuItem>[
              MorphFabMenuItem(icon: Icon(Icons.image), label: 'Image'),
              MorphFabMenuItem(icon: Icon(Icons.mic), label: 'Audio'),
            ],
          ),
        ),
      ),
    ),
  );

  await tester.tap(find.byType(MorphFab));
  await tester.pumpAndSettle();
  expect(find.text('Image'), findsOneWidget);
  expect(find.text('Audio'), findsOneWidget);
}

Future<void> _fabMenuControllerOpenClose(WidgetTester tester) async {
  final controller = MorphFabMenuController();
  await tester.pumpWidget(
    MorphMaterialApp(
      data: MorphThemeData.light(),
      home: Scaffold(
        body: Align(
          alignment: Alignment.bottomCenter,
          child: MorphFabMenu(
            controller: controller,
            items: const <MorphFabMenuItem>[
              MorphFabMenuItem(icon: Icon(Icons.image), label: 'Image'),
              MorphFabMenuItem(icon: Icon(Icons.mic), label: 'Audio'),
            ],
          ),
        ),
      ),
    ),
  );

  controller.open();
  await tester.pumpAndSettle();
  expect(controller.isOpen, isTrue);
  expect(find.text('Image'), findsOneWidget);

  controller.close();
  await tester.pumpAndSettle();
  expect(controller.isOpen, isFalse);
  expect(find.text('Image'), findsNothing);
  controller.dispose();
}

Future<void> _fabMenuItemContainerTransformOpensAndCloses(
  WidgetTester tester,
) async {
  await tester.pumpWidget(
    MorphMaterialApp(
      data: MorphThemeData.light(),
      home: Scaffold(
        body: Align(
          alignment: Alignment.bottomCenter,
          child: MorphFabMenu(
            items: const <MorphFabMenuItem>[
              MorphFabMenuItem(
                icon: Icon(Icons.image),
                label: 'Image',
                openBuilder: _composeDestination,
              ),
              MorphFabMenuItem(icon: Icon(Icons.mic), label: 'Audio'),
            ],
          ),
        ),
      ),
    ),
  );

  await tester.tap(find.byType(MorphFab));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Image'));
  await tester.pumpAndSettle();
  expect(find.text('Compose dest'), findsOneWidget);

  await tester.tap(find.byIcon(Icons.arrow_back));
  await tester.pumpAndSettle();
  expect(find.text('Compose dest'), findsNothing);
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

Future<void> _focusedItemRingPaintsAboveNeighboringPills(
  WidgetTester tester,
) async {
  FocusManager.instance.highlightStrategy =
      FocusHighlightStrategy.alwaysTraditional;
  addTearDown(_restoreAutomaticHighlight);

  await tester.pumpWidget(
    MorphMaterialApp(
      data: MorphThemeData.light(),
      home: Scaffold(
        body: Align(
          alignment: Alignment.bottomCenter,
          child: MorphFabMenu(
            size: MorphFabSize.regular,
            items: const <MorphFabMenuItem>[
              MorphFabMenuItem(icon: Icon(Icons.image), label: 'Image'),
              MorphFabMenuItem(icon: Icon(Icons.videocam), label: 'Video'),
              MorphFabMenuItem(icon: Icon(Icons.mic), label: 'Audio'),
            ],
          ),
        ),
      ),
    ),
  );

  await tester.tap(find.byType(MorphFab));
  await tester.pumpAndSettle();

  MorphFocusInteraction.instance.noteKeyboardHighlight();
  await tester.sendKeyEvent(LogicalKeyboardKey.tab);
  await tester.pumpAndSettle();

  expect(find.byType(MorphFocusRing), findsWidgets);
  // Ring is layered in the items Stack after the pills column (paint-on-top).
  final Finder itemsStackFinder = find
      .descendant(
        of: find.byType(SingleChildScrollView),
        matching: find.byType(Stack),
      )
      .first;
  final Stack itemsStack = tester.widget(itemsStackFinder);
  expect(itemsStack.clipBehavior, Clip.none);
  expect(itemsStack.children.length, 2);
}

void _restoreAutomaticHighlight() {
  FocusManager.instance.highlightStrategy = FocusHighlightStrategy.automatic;
}

Future<void> _largeFabKeepsLastItemAboveCloseWithMenuOffset(
  WidgetTester tester,
) async {
  await tester.pumpWidget(
    MorphMaterialApp(
      data: MorphThemeData.light(),
      home: Scaffold(
        body: Align(
          alignment: Alignment.bottomCenter,
          child: MorphFabMenu(
            size: MorphFabSize.large,
            items: const <MorphFabMenuItem>[
              MorphFabMenuItem(icon: Icon(Icons.image), label: 'Image'),
              MorphFabMenuItem(icon: Icon(Icons.videocam), label: 'Video'),
              MorphFabMenuItem(icon: Icon(Icons.mic), label: 'Audio'),
            ],
          ),
        ),
      ),
    ),
  );

  await tester.tap(find.byType(MorphFab));
  await tester.pumpAndSettle();

  final lastItem = tester.getBottomRight(find.text('Audio'));
  // Overlay close is the last MorphFab; its top must sit below the item + gap.
  final closeTop = tester.getTopRight(find.byType(MorphFab).last).dy;
  expect(lastItem.dy, lessThanOrEqualTo(closeTop - 8));
}

Future<void> _shortViewportKeepsCloseHittableWhileItemsScroll(
  WidgetTester tester,
) async {
  await tester.binding.setSurfaceSize(const Size(400, 320));
  addTearDown(() => tester.binding.setSurfaceSize(null));

  await tester.pumpWidget(
    MorphMaterialApp(
      data: MorphThemeData.light(),
      home: Scaffold(
        body: const SizedBox.shrink(),
        floatingActionButton: MorphFabMenu(
          items: const <MorphFabMenuItem>[
            MorphFabMenuItem(icon: Icon(Icons.one_k), label: 'One'),
            MorphFabMenuItem(icon: Icon(Icons.two_k), label: 'Two'),
            MorphFabMenuItem(icon: Icon(Icons.three_k), label: 'Three'),
            MorphFabMenuItem(icon: Icon(Icons.four_k), label: 'Four'),
            MorphFabMenuItem(icon: Icon(Icons.five_k), label: 'Five'),
            MorphFabMenuItem(icon: Icon(Icons.six_k), label: 'Six'),
          ],
        ),
      ),
    ),
  );

  await tester.tap(find.byType(MorphFab).first);
  await tester.pumpAndSettle();
  expect(find.byType(SingleChildScrollView), findsWidgets);

  // Close remains tappable (overlay close FAB).
  await tester.tap(find.byType(MorphFab).last);
  await tester.pumpAndSettle();
  expect(find.text('One'), findsNothing);
}

Future<void> _systemBackClosesTheMenuBeforeTheRoute(WidgetTester tester) async {
  await tester.pumpWidget(
    MorphMaterialApp(
      data: MorphThemeData.light(),
      home: Builder(
        builder: (BuildContext context) {
          return Scaffold(
            body: TextButton(
              onPressed: () => _pushFabMenuRoute(context),
              child: const Text('Root'),
            ),
          );
        },
      ),
    ),
  );
  await tester.tap(find.text('Root'));
  await tester.pumpAndSettle();

  await tester.tap(find.byType(MorphFab));
  await tester.pumpAndSettle();
  expect(find.text('Image'), findsOneWidget);

  await tester.binding.handlePopRoute();
  await tester.pumpAndSettle();

  expect(find.text('Image'), findsNothing);
  expect(find.byType(MorphFabMenu), findsOneWidget);

  await tester.binding.handlePopRoute();
  await tester.pumpAndSettle();

  expect(find.byType(MorphFabMenu), findsNothing);
  expect(find.text('Root'), findsOneWidget);
}

void _pushFabMenuRoute(BuildContext context) {
  Navigator.of(context).push(MaterialPageRoute<void>(builder: _fabMenuRoute));
}

Widget _fabMenuRoute(BuildContext context) {
  return Scaffold(
    body: Align(
      alignment: Alignment.bottomCenter,
      child: MorphFabMenu(
        items: const <MorphFabMenuItem>[
          MorphFabMenuItem(icon: Icon(Icons.image), label: 'Image'),
          MorphFabMenuItem(icon: Icon(Icons.mic), label: 'Audio'),
        ],
      ),
    ),
  );
}
