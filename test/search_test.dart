import 'package:flutter_test/flutter_test.dart';
import 'package:morph_expressive/morph_components.dart';
import 'package:material_ui/material_ui.dart';

Widget _host(Widget child) {
  return MorphMaterialApp(
    data: MorphThemeData.light(seedColor: const Color(0xFF6750A4)),
    home: Scaffold(
      body: Align(
        alignment: Alignment.topCenter,
        child: Padding(padding: const EdgeInsets.all(24), child: child),
      ),
    ),
  );
}

void main() {
  testWidgets(
    'MorphSearchBar lays out at default height without overflow',
    _morphsearchbarLaysOutAtDefaultHeightWithoutOverflow,
  );
  testWidgets(
    'MorphSearchBar applies hint inset only without leading',
    _morphsearchbarAppliesHintInsetOnlyWithoutLeading,
  );
  testWidgets(
    'disabled MorphSearchBar applies reduced opacity',
    _disabledM3esearchbarAppliesReducedOpacity,
  );
  testWidgets(
    'MorphSearchAnchor.bar opens view on tap without typing',
    _morphsearchanchorBarOpensViewOnTapWithoutTyping,
  );
  testWidgets(
    'full-screen back closes view without reopening',
    _fullScreenBackClosesViewWithoutReopening,
  );
  testWidgets(
    'MorphSearchAnchor.bar opens and closes the search view',
    _morphsearchanchorBarOpensAndClosesTheSearchView,
  );
  testWidgets(
    'closeView populates the read-only anchor bar',
    _closeviewPopulatesTheReadOnlyAnchorBar,
  );
  testWidgets(
    'anchor bar stays at resting unexpanded inset',
    _anchorBarStaysAtRestingUnexpandedInset,
  );
  testWidgets(
    'full-screen search view header uses contained search bar styling',
    _fullScreenSearchViewHeaderUsesContainedSearchBarSty,
  );
  testWidgets(
    'MorphSearchBar expands horizontally on focus',
    _morphsearchbarExpandsHorizontallyOnFocus,
  );
  testWidgets(
    'MorphSearchBar expands on focus in narrow gallery layout',
    _morphsearchbarExpandsOnFocusInNarrowGalleryLayout,
  );
  testWidgets(
    'MorphSearchBarTheme overrides container color',
    _morphsearchbarthemeOverridesContainerColor,
  );
}

Future<void> _morphsearchbarLaysOutAtDefaultHeightWithoutOverflow(
  WidgetTester tester,
) async {
  await tester.pumpWidget(
    _host(
      const SizedBox(width: 400, child: MorphSearchBar(hintText: 'Search')),
    ),
  );

  expect(find.text('Search'), findsOneWidget);
  expect(tester.takeException(), isNull);
}

Future<void> _morphsearchbarAppliesHintInsetOnlyWithoutLeading(
  WidgetTester tester,
) async {
  // 4 container padding + 12 label inset = 16 without actions.
  const double extraInset = 12;

  await tester.pumpWidget(
    _host(
      const SizedBox(width: 400, child: MorphSearchBar(hintText: 'Search')),
    ),
  );

  final MorphSearchBarInput withoutLeading = tester.widget<MorphSearchBarInput>(
    find.byType(MorphSearchBarInput),
  );
  expect(
    withoutLeading.contentPadding,
    const EdgeInsetsDirectional.only(start: extraInset, end: extraInset),
  );

  await tester.pumpWidget(
    _host(
      const SizedBox(
        width: 400,
        child: MorphSearchBar(
          hintText: 'Search',
          leading: Icon(MorphIcons.search),
        ),
      ),
    ),
  );

  final MorphSearchBarInput withLeading = tester.widget<MorphSearchBarInput>(
    find.byType(MorphSearchBarInput),
  );
  // Leading tap target → label gap is 4.
  expect(
    withLeading.contentPadding,
    const EdgeInsetsDirectional.only(start: 4, end: extraInset),
  );
}

Future<void> _disabledM3esearchbarAppliesReducedOpacity(
  WidgetTester tester,
) async {
  await tester.pumpWidget(
    _host(
      const SizedBox(
        width: 400,
        child: MorphSearchBar(hintText: 'Search', enabled: false),
      ),
    ),
  );

  final Opacity opacity = tester.widget<Opacity>(
    find.descendant(
      of: find.byType(MorphSearchBar),
      matching: find.byType(Opacity),
    ),
  );
  expect(opacity.opacity, MorphSearchConstants.disabledOpacity);
}

Future<void> _morphsearchanchorBarOpensViewOnTapWithoutTyping(
  WidgetTester tester,
) async {
  final controller = MorphSearchController();

  await tester.pumpWidget(
    _host(
      SizedBox(
        width: 420,
        child: MorphSearchAnchor.bar(
          searchController: controller,
          isFullScreen: true,
          barHintText: 'Find components',
          suggestionsBuilder: (BuildContext context, MorphSearchController c) {
            return <Widget>[
              ListTile(
                title: Text('Result for ${c.text}'),
                onTap: () => c.closeView('Buttons'),
              ),
            ];
          },
        ),
      ),
    ),
  );

  final MorphSearchBar anchorBar = tester.widget<MorphSearchBar>(
    find.byType(MorphSearchBar),
  );
  expect(anchorBar.readOnly, isTrue);

  await tester.tap(find.byType(MorphSearchBar));
  await tester.pumpAndSettle();
  await tester.pump();

  expect(controller.isOpen, isTrue);
  expect(controller.text, isEmpty);
  expect(find.text('Result for '), findsOneWidget);

  // View search bar is editable and focused; anchor bar stays unfocused.
  // Focus is requested after the open transition, not via autoFocus, so the
  // soft keyboard attaches once.
  final Finder viewBar = find.byWidgetPredicate(
    (Widget widget) => widget is MorphSearchBar && !widget.readOnly,
  );
  expect(
    tester
        .widget<EditableText>(
          find.descendant(of: viewBar, matching: find.byType(EditableText)),
        )
        .focusNode
        .hasFocus,
    isTrue,
  );
}

Future<void> _fullScreenBackClosesViewWithoutReopening(
  WidgetTester tester,
) async {
  final controller = MorphSearchController();

  await tester.pumpWidget(
    _host(
      SizedBox(
        width: 420,
        child: MorphSearchAnchor.bar(
          searchController: controller,
          isFullScreen: true,
          barHintText: 'Find components',
          suggestionsBuilder: (BuildContext context, MorphSearchController c) {
            return <Widget>[ListTile(title: Text('Result for ${c.text}'))];
          },
        ),
      ),
    ),
  );

  await tester.tap(find.byType(MorphSearchBar));
  await tester.pumpAndSettle();
  expect(controller.isOpen, isTrue);

  await tester.tap(find.byIcon(MorphIcons.arrow_back));
  await tester.pumpAndSettle();
  await tester.pump();

  expect(controller.isOpen, isFalse);
  expect(find.text('Result for '), findsNothing);
}

Future<void> _morphsearchanchorBarOpensAndClosesTheSearchView(
  WidgetTester tester,
) async {
  final controller = MorphSearchController();

  await tester.pumpWidget(
    _host(
      SizedBox(
        width: 420,
        child: MorphSearchAnchor.bar(
          searchController: controller,
          isFullScreen: false,
          barHintText: 'Find components',
          suggestionsBuilder: (BuildContext context, MorphSearchController c) {
            return <Widget>[
              ListTile(
                title: Text('Result for ${c.text}'),
                onTap: () => c.closeView('Buttons'),
              ),
            ];
          },
        ),
      ),
    ),
  );

  expect(controller.isAttached, isTrue);
  expect(controller.isOpen, isFalse);

  controller.openView();
  await tester.pumpAndSettle();
  await tester.pump();

  expect(controller.isOpen, isTrue);
  expect(find.text('Result for '), findsOneWidget);

  await tester.tap(find.byIcon(MorphIcons.arrow_back));
  await tester.pumpAndSettle();

  expect(controller.isOpen, isFalse);
}

Future<void> _closeviewPopulatesTheReadOnlyAnchorBar(
  WidgetTester tester,
) async {
  final controller = MorphSearchController();

  await tester.pumpWidget(
    _host(
      SizedBox(
        width: 420,
        child: MorphSearchAnchor.bar(
          searchController: controller,
          isFullScreen: false,
          barHintText: 'Find',
          suggestionsBuilder: (BuildContext context, MorphSearchController c) {
            return <Widget>[
              ListTile(
                title: const Text('Buttons'),
                onTap: () => c.closeView('Buttons'),
              ),
            ];
          },
        ),
      ),
    ),
  );

  expect(
    tester.widget<MorphSearchBar>(find.byType(MorphSearchBar)).readOnly,
    isTrue,
  );
  expect(find.byIcon(MorphIcons.close), findsNothing);

  await tester.tap(find.byType(MorphSearchBar));
  await tester.pumpAndSettle();
  await tester.pump();
  await tester.tap(find.text('Buttons'));
  await tester.pumpAndSettle();

  expect(controller.isOpen, isFalse);
  expect(controller.text, 'Buttons');
  expect(find.text('Buttons'), findsOneWidget);
  expect(find.byIcon(MorphIcons.close), findsOneWidget);

  await tester.tap(find.byIcon(MorphIcons.close));
  await tester.pumpAndSettle();
  expect(controller.text, isEmpty);
  expect(find.byIcon(MorphIcons.close), findsNothing);
}

Future<void> _anchorBarStaysAtRestingUnexpandedInset(
  WidgetTester tester,
) async {
  final controller = MorphSearchController();
  const double hostWidth = 420;

  await tester.pumpWidget(
    _host(
      SizedBox(
        width: hostWidth,
        child: MorphSearchAnchor.bar(
          searchController: controller,
          isFullScreen: false,
          barHintText: 'Find',
          suggestionsBuilder: (BuildContext context, MorphSearchController c) {
            return const <Widget>[];
          },
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();

  final Finder barMaterial = find
      .descendant(
        of: find.byType(MorphSearchBar),
        matching: find.byType(Material),
      )
      .first;
  final double barWidth = tester.getSize(barMaterial).width;
  final double restingInset =
      MorphSearchBarTheme.defaults.restingExpandPadding * 2;
  expect(barWidth, closeTo(hostWidth - restingInset, 0.1));
}

Future<void> _fullScreenSearchViewHeaderUsesContainedSearchBarSty(
  WidgetTester tester,
) async {
  final controller = MorphSearchController();
  final theme = MorphThemeData.light(seedColor: const Color(0xFF6750A4));

  await tester.pumpWidget(
    MorphMaterialApp(
      data: theme,
      home: Scaffold(
        body: Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: SizedBox(
              width: 420,
              child: MorphSearchAnchor.bar(
                searchController: controller,
                isFullScreen: true,
                barHintText: 'Find',
                suggestionsBuilder:
                    (BuildContext context, MorphSearchController c) {
                      return <Widget>[ListTile(title: Text('Item ${c.text}'))];
                    },
              ),
            ),
          ),
        ),
      ),
    ),
  );

  controller.openView();
  await tester.pumpAndSettle();
  await tester.pump();

  final Iterable<Material> materials = tester.widgetList<Material>(
    find.byType(Material),
  );
  expect(
    materials.any(
      (Material material) =>
          material.elevation == 0 &&
          material.color == theme.colorScheme.surfaceContainerHigh,
    ),
    isTrue,
  );
}

Future<void> _morphsearchbarExpandsHorizontallyOnFocus(
  WidgetTester tester,
) async {
  final focusNode = FocusNode();

  await tester.pumpWidget(
    _host(
      SizedBox(
        width: 420,
        child: MorphSearchBar(focusNode: focusNode, hintText: 'Search'),
      ),
    ),
  );
  await tester.pumpAndSettle();

  final Finder barMaterial = find
      .descendant(
        of: find.byType(MorphSearchBar),
        matching: find.byType(Material),
      )
      .first;
  final double widthBefore = tester.getSize(barMaterial).width;
  focusNode.requestFocus();
  await tester.pumpAndSettle();

  final double widthFocused = tester.getSize(barMaterial).width;
  expect(widthFocused, greaterThan(widthBefore));
  // Margins 24 → 12 on each side.
  expect(widthFocused - widthBefore, closeTo(24, 0.1));

  focusNode.unfocus();
  await tester.pumpAndSettle();

  final double widthAfter = tester.getSize(barMaterial).width;
  expect(widthAfter, lessThan(widthFocused));
  expect(widthAfter, closeTo(widthBefore, 0.1));
}

Future<void> _morphsearchbarExpandsOnFocusInNarrowGalleryLayout(
  WidgetTester tester,
) async {
  await tester.binding.setSurfaceSize(const Size(390, 800));
  addTearDown(() => tester.binding.setSurfaceSize(null));

  await tester.pumpWidget(
    MorphMaterialApp(
      data: MorphThemeData.light(seedColor: const Color(0xFF6750A4)),
      home: Scaffold(
        body: ListView(
          padding: const EdgeInsets.all(24),
          children: const <Widget>[
            MorphSearchBar(hintText: 'Search components'),
          ],
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();

  final Finder barMaterial = find
      .descendant(
        of: find.byType(MorphSearchBar),
        matching: find.byType(Material),
      )
      .first;
  final double widthBefore = tester.getSize(barMaterial).width;

  await tester.tap(find.byType(EditableText));
  await tester.pumpAndSettle();

  final double widthFocused = tester.getSize(barMaterial).width;
  expect(widthFocused, greaterThan(widthBefore));
}

Future<void> _morphsearchbarthemeOverridesContainerColor(
  WidgetTester tester,
) async {
  const custom = Color(0xFFFF00FF);
  await tester.pumpWidget(
    MorphMaterialApp(
      data: MorphThemeData.light(seedColor: const Color(0xFF6750A4))
          .copyWith(searchBarTheme: MorphSearchBarTheme.defaults),
      home: const Scaffold(
        body: Center(
          child: SizedBox(
            width: 400,
            child: MorphSearchBar(
              hintText: 'Search',
              backgroundColor: WidgetStatePropertyAll<Color>(custom),
            ),
          ),
        ),
      ),
    ),
  );

  final Material material = tester.widget<Material>(
    find
        .descendant(
          of: find.byType(MorphSearchBar),
          matching: find.byType(Material),
        )
        .first,
  );
  expect(material.color, custom);
}
