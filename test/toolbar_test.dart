import 'package:flutter_test/flutter_test.dart';
import 'package:morph_expressive/morph_components.dart';
import 'package:material_ui/material_ui.dart';

Widget _host({required Widget child}) {
  return Directionality(
    textDirection: TextDirection.ltr,
    child: MorphTheme(
      data: MorphThemeData.light(seedColor: const Color(0xFF6750A4)),
      child: Center(child: child),
    ),
  );
}

void _setViewPadding(WidgetTester tester, EdgeInsets padding) {
  final double dpr = tester.view.devicePixelRatio;
  tester.view.viewPadding = FakeViewPadding(
    left: padding.left * dpr,
    top: padding.top * dpr,
    right: padding.right * dpr,
    bottom: padding.bottom * dpr,
  );
  addTearDown(tester.view.reset);
}

List<MorphToolbarItem> _actions() => <MorphToolbarItem>[
  MorphToolbarAction(icon: MorphIcons.edit, onPressed: () {}),
  MorphToolbarAction(icon: MorphIcons.share, onPressed: () {}),
];

void main() {
  testWidgets(
    'floating default builds pill wrap-content bar',
    _floatingDefaultBuildsPillWrapContentBar,
  );
  testWidgets('docked is full width', _dockedIsFullWidth);
  testWidgets(
    'vertical floating uses cross-axis width',
    _verticalFloatingUsesCrossAxisWidth,
  );
  testWidgets(
    'floating safeArea and screen offset pad outside the pill',
    _floatingSafeareaPadsOutsideThePillOnOneEdge,
  );
  testWidgets(
    'floating safeArea top pads the top edge plus screen offset',
    _floatingSafeareaTopPadsOnlyTopOutsidePill,
  );
  testWidgets(
    'floating alignment positions pill in parent',
    _floatingAlignmentPositionsPillInParent,
  );
  testWidgets(
    'docked icons-only uses the preferred gap inside the padding',
    _dockedIconsOnlyPinsFirstLastToPaddedEdges,
  );
  testWidgets(
    'floating title gets optical start inset',
    _floatingTitleGetsOpticalStartInset,
  );
  testWidgets(
    'docked bottom safeArea pads only bottom',
    _dockedBottomSafeareaPadsOnlyBottom,
  );
  testWidgets(
    'docked top safeArea pads only top',
    _dockedTopSafeareaPadsOnlyTop,
  );
  testWidgets(
    'docked with title lays out without flex overflow',
    _dockedWithTitleLaysOutWithoutFlexOverflow,
  );
  testWidgets('vibrant color style builds', _vibrantColorStyleBuilds);
  testWidgets(
    'FAB slot is present when fabIcon provided',
    _fabSlotIsPresentWhenFabiconProvided,
  );
  testWidgets(
    'collapsed with FAB shows FAB and hides pill actions',
    _collapsedWithFabShowsFabAndHidesPillActions,
  );
  testWidgets(
    'visibility controller hide moves offset to limit',
    _visibilityControllerHideMovesOffsetToLimit,
  );
  testWidgets(
    'expand trigger tap does not throw on pointer up after rebuild',
    _expandTriggerTapDoesNotThrowOnPointerUpAfter,
  );
  testWidgets(
    'toolbar widget items stay inline and height-capped',
    _toolbarWidgetItemsStayInlineAndHeightCapped,
  );
}

Future<void> _floatingDefaultBuildsPillWrapContentBar(
  WidgetTester tester,
) async {
  await tester.pumpWidget(_host(child: MorphToolbar(actions: _actions())));
  expect(find.byType(MorphToolbar), findsOneWidget);
  expect(find.byType(MorphIconButton), findsWidgets);
  expect(tester.takeException(), isNull);
}

Future<void> _dockedIsFullWidth(WidgetTester tester) async {
  await tester.pumpWidget(
    _host(
      child: const SizedBox(
        width: 400,
        child: MorphToolbar.docked(
          safeArea: false,
          actions: <MorphToolbarItem>[
            MorphToolbarAction(icon: MorphIcons.edit, onPressed: _noop),
          ],
        ),
      ),
    ),
  );
  final Size size = tester.getSize(find.byType(MorphToolbar));
  expect(size.width, 400);
  expect(size.height, greaterThanOrEqualTo(64));
}

Future<void> _verticalFloatingUsesCrossAxisWidth(WidgetTester tester) async {
  await tester.pumpWidget(
    _host(
      child: SizedBox(
        height: 240,
        child: MorphToolbar(axis: Axis.vertical, actions: _actions()),
      ),
    ),
  );
  final Size pillSize = tester.getSize(
    find
        .descendant(
          of: find.byType(MorphToolbar),
          matching: find.byType(Material),
        )
        .first,
  );
  expect(pillSize.width, 64);
}

Future<void> _floatingSafeareaPadsOutsideThePillOnOneEdge(
  WidgetTester tester,
) async {
  _setViewPadding(tester, const EdgeInsets.fromLTRB(10, 20, 30, 40));
  await tester.pumpWidget(
    _host(child: MorphToolbar(safeArea: true, actions: _actions())),
  );

  final Size materialSize = tester.getSize(
    find
        .descendant(
          of: find.byType(MorphToolbar),
          matching: find.byType(Material),
        )
        .first,
  );
  expect(materialSize.height, 64);

  final Padding safePadding = tester.widget(
    find.descendant(
      of: find.byType(MorphToolbar),
      matching: find.byWidgetPredicate((Widget w) {
        if (w is! Padding) {
          return false;
        }
        final EdgeInsets insets = w.padding.resolve(TextDirection.ltr);
        return insets.bottom == 40 + MorphToolbarTokens.screenOffset &&
            insets.top == MorphToolbarTokens.screenOffset &&
            insets.left == MorphToolbarTokens.screenOffset &&
            insets.right == MorphToolbarTokens.screenOffset;
      }),
    ),
  );
  expect(
    safePadding.padding.resolve(TextDirection.ltr).bottom,
    40 + MorphToolbarTokens.screenOffset,
  );
}

Future<void> _floatingSafeareaTopPadsOnlyTopOutsidePill(
  WidgetTester tester,
) async {
  _setViewPadding(tester, const EdgeInsets.fromLTRB(10, 20, 30, 40));
  await tester.pumpWidget(
    _host(
      child: MorphToolbar(
        safeArea: true,
        dockEdge: MorphToolbarDockEdge.top,
        actions: _actions(),
      ),
    ),
  );

  final Size materialSize = tester.getSize(
    find
        .descendant(
          of: find.byType(MorphToolbar),
          matching: find.byType(Material),
        )
        .first,
  );
  expect(materialSize.height, 64);

  expect(
    find.descendant(
      of: find.byType(MorphToolbar),
      matching: find.byWidgetPredicate((Widget w) {
        if (w is! Padding) {
          return false;
        }
        final EdgeInsets insets = w.padding.resolve(TextDirection.ltr);
        return insets.top == 20 + MorphToolbarTokens.screenOffset &&
            insets.bottom == MorphToolbarTokens.screenOffset &&
            insets.left == MorphToolbarTokens.screenOffset &&
            insets.right == MorphToolbarTokens.screenOffset;
      }),
    ),
    findsOneWidget,
  );
}

Future<void> _floatingAlignmentPositionsPillInParent(
  WidgetTester tester,
) async {
  await tester.pumpWidget(
    _host(
      child: SizedBox(
        width: 300,
        height: 200,
        child: MorphToolbar(
          alignment: Alignment.bottomCenter,
          actions: _actions(),
        ),
      ),
    ),
  );

  final Rect parent = tester.getRect(find.byType(SizedBox).first);
  final Rect pill = tester.getRect(
    find
        .descendant(
          of: find.byType(MorphToolbar),
          matching: find.byType(Material),
        )
        .first,
  );
  expect(pill.center.dx, closeTo(parent.center.dx, 0.5));
  expect(
    pill.bottom,
    closeTo(parent.bottom - MorphToolbarTokens.screenOffset, 0.5),
  );
}

Future<void> _dockedIconsOnlyPinsFirstLastToPaddedEdges(
  WidgetTester tester,
) async {
  await tester.pumpWidget(
    _host(
      child: const SizedBox(
        width: 300,
        child: MorphToolbar.docked(
          safeArea: false,
          actions: <MorphToolbarItem>[
            MorphToolbarAction(icon: MorphIcons.edit, onPressed: _noop),
            MorphToolbarAction(icon: MorphIcons.share, onPressed: _noop),
            MorphToolbarAction(icon: MorphIcons.favorite, onPressed: _noop),
          ],
        ),
      ),
    ),
  );

  final Finder buttons = find.descendant(
    of: find.byType(MorphToolbar),
    matching: find.byType(MorphIconButton),
  );
  final double toolbarLeft = tester.getTopLeft(find.byType(MorphToolbar)).dx;
  final double toolbarRight = tester.getTopRight(find.byType(MorphToolbar)).dx;
  final double firstLeft = tester.getTopLeft(buttons.at(0)).dx;
  final double lastRight = tester.getTopRight(buttons.at(2)).dx;

  // Leading padding stays 16. Extra width does not stretch the gap past 32,
  // so the last action is not pinned to the trailing edge.
  expect(firstLeft - toolbarLeft, closeTo(16, 0.5));
  expect(toolbarRight - lastRight, greaterThan(16));

  final double editX = tester.getCenter(find.byIcon(MorphIcons.edit)).dx;
  final double shareX = tester.getCenter(find.byIcon(MorphIcons.share)).dx;
  final double favoriteX = tester
      .getCenter(find.byIcon(MorphIcons.favorite))
      .dx;
  expect(shareX - editX, closeTo(80, 1));
  expect(favoriteX - shareX, closeTo(shareX - editX, 0.5));
}

Future<void> _floatingTitleGetsOpticalStartInset(WidgetTester tester) async {
  await tester.pumpWidget(
    _host(
      child: const SizedBox(
        width: 360,
        child: MorphToolbar(
          titleText: 'Inbox',
          actions: <MorphToolbarItem>[
            MorphToolbarAction(icon: MorphIcons.search, onPressed: _noop),
          ],
        ),
      ),
    ),
  );

  final double titleLeft = tester.getTopLeft(find.text('Inbox')).dx;
  final double toolbarLeft = tester.getTopLeft(find.byType(MorphToolbar)).dx;
  // Screen offset 16 + axis-aware start pad 12 (8 + cross optical 4)
  // + (48 target - 24 icon) / 2 = 40
  expect(
    titleLeft - toolbarLeft,
    closeTo(24 + MorphToolbarTokens.screenOffset, 0.5),
  );
}

Future<void> _dockedBottomSafeareaPadsOnlyBottom(WidgetTester tester) async {
  _setViewPadding(tester, const EdgeInsets.fromLTRB(10, 20, 30, 40));
  await tester.pumpWidget(
    _host(
      child: const SizedBox(
        width: 300,
        child: MorphToolbar.docked(
          actions: <MorphToolbarItem>[
            MorphToolbarAction(icon: MorphIcons.edit, onPressed: _noop),
          ],
        ),
      ),
    ),
  );

  final Size size = tester.getSize(find.byType(MorphToolbar));
  // 64 content + 40 bottom inset
  expect(size.height, 104);
  expect(size.width, 300);
}

Future<void> _dockedTopSafeareaPadsOnlyTop(WidgetTester tester) async {
  _setViewPadding(tester, const EdgeInsets.fromLTRB(10, 20, 30, 40));
  await tester.pumpWidget(
    _host(
      child: const SizedBox(
        width: 300,
        child: MorphToolbar.docked(
          dockEdge: MorphToolbarDockEdge.top,
          actions: <MorphToolbarItem>[
            MorphToolbarAction(icon: MorphIcons.edit, onPressed: _noop),
          ],
        ),
      ),
    ),
  );

  final Size size = tester.getSize(find.byType(MorphToolbar));
  // 64 content + 20 top inset
  expect(size.height, 84);
}

Future<void> _dockedWithTitleLaysOutWithoutFlexOverflow(
  WidgetTester tester,
) async {
  _setViewPadding(tester, const EdgeInsets.only(top: 44));
  await tester.pumpWidget(
    _host(
      child: const SizedBox(
        width: 280,
        child: MorphToolbar.docked(
          dockEdge: MorphToolbarDockEdge.top,
          titleText: 'Docked top',
          actions: <MorphToolbarItem>[
            MorphToolbarAction(icon: MorphIcons.edit, onPressed: _noop),
            MorphToolbarAction(icon: MorphIcons.share, onPressed: _noop),
            MorphToolbarAction(icon: MorphIcons.favorite, onPressed: _noop),
          ],
        ),
      ),
    ),
  );
  expect(tester.takeException(), isNull);
  expect(find.text('Docked top'), findsOneWidget);
}

Future<void> _vibrantColorStyleBuilds(WidgetTester tester) async {
  await tester.pumpWidget(
    _host(
      child: MorphToolbar(
        colorStyle: MorphToolbarColorStyle.vibrant,
        actions: _actions(),
      ),
    ),
  );
  expect(tester.takeException(), isNull);
}

Future<void> _fabSlotIsPresentWhenFabiconProvided(WidgetTester tester) async {
  await tester.pumpWidget(
    _host(
      child: MorphToolbar(
        actions: _actions(),
        fabIcon: const Icon(MorphIcons.add),
        onFabPressed: () {},
      ),
    ),
  );
  expect(find.byType(MorphFab), findsOneWidget);
}

Future<void> _collapsedWithFabShowsFabAndHidesPillActions(
  WidgetTester tester,
) async {
  await tester.pumpWidget(
    _host(
      child: const MorphToolbar(
        actions: <MorphToolbarItem>[
          MorphToolbarAction(icon: MorphIcons.edit, onPressed: _noop),
          MorphToolbarAction(icon: MorphIcons.share, onPressed: _noop),
          MorphToolbarAction(icon: MorphIcons.favorite, onPressed: _noop),
        ],
        fabIcon: Icon(MorphIcons.add),
        expanded: false,
      ),
    ),
  );
  expect(find.byType(MorphFab), findsOneWidget);
  // Whole pill is clipped when collapsed — actions are not hit-testable.
  expect(find.byIcon(MorphIcons.edit).hitTestable(), findsNothing);
  expect(find.byIcon(MorphIcons.share).hitTestable(), findsNothing);
}

Future<void> _visibilityControllerHideMovesOffsetToLimit(
  WidgetTester tester,
) async {
  final controller = MorphToolbarVisibilityController(exitExtent: 80);
  expect(controller.offsetLimit, -80);
  await tester.pumpWidget(
    _host(
      child: MorphToolbar(
        actions: _actions(),
        visibilityController: controller,
      ),
    ),
  );
  await tester.pumpAndSettle();
  controller.hide();
  await tester.pumpAndSettle();
  expect(controller.offset, closeTo(controller.offsetLimit, 0.5));
  controller.show();
  await tester.pumpAndSettle();
  expect(controller.offset, closeTo(0, 0.5));
}

Future<void> _expandTriggerTapDoesNotThrowOnPointerUpAfter(
  WidgetTester tester,
) async {
  await tester.pumpWidget(
    _host(
      child: const MorphToolbar(
        actions: <MorphToolbarItem>[
          MorphToolbarAction(icon: MorphIcons.edit, onPressed: _noop),
          MorphToolbarAction(
            icon: MorphIcons.menu,
            onPressed: _noop,
            isExpandTrigger: true,
          ),
          MorphToolbarAction(icon: MorphIcons.favorite, onPressed: _noop),
        ],
        expanded: false,
      ),
    ),
  );
  await tester.pumpAndSettle();

  await tester.tap(find.byIcon(MorphIcons.menu));
  await tester.pumpAndSettle();
  expect(tester.takeException(), isNull);
  expect(find.byIcon(MorphIcons.edit), findsOneWidget);

  await tester.tap(find.byIcon(MorphIcons.menu));
  await tester.pumpAndSettle();
  expect(tester.takeException(), isNull);
  expect(find.byIcon(MorphIcons.edit), findsNothing);
}

Future<void> _toolbarWidgetItemsStayInlineAndHeightCapped(
  WidgetTester tester,
) async {
  await tester.pumpWidget(
    _host(
      child: const MorphToolbar(
        actions: <MorphToolbarItem>[
          MorphToolbarAction(icon: MorphIcons.edit, onPressed: _noop),
          MorphToolbarWidget(
            child: SizedBox(
              width: 72,
              height: 120,
              child: ColoredBox(color: Color(0xFF00FF00)),
            ),
          ),
          MorphToolbarAction(icon: MorphIcons.share, onPressed: _noop),
        ],
      ),
    ),
  );
  await tester.pumpAndSettle();
  expect(tester.takeException(), isNull);
  expect(find.byType(ConstrainedBox), findsWidgets);
  expect(find.byType(ColoredBox), findsOneWidget);
  // Floating content padding is 8 on each side → 64 - 16 = 48.
  final Size size = tester.getSize(find.byType(ColoredBox));
  expect(size.height, lessThanOrEqualTo(48.01));
}

void _noop() {}
