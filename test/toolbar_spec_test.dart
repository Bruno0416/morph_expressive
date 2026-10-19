import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morph_expressive/morph_components.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  setUp(MorphFocusInteraction.resetForTest);

  test(
    'toolbar color roles follow the scheme',
    _toolbarColorRolesFollowTheScheme,
  );
  testWidgets(
    'floating elevation is level 3 and docked stays flat',
    _floatingElevationIsLevel3AndDockedStaysFlat,
  );
  testWidgets('vertical floating margin is 24', _verticalFloatingMarginIs24);
  testWidgets(
    'horizontal floating margin stays 16',
    _horizontalFloatingMarginStays16,
  );
  testWidgets(
    'wide docked gap stays at 32 and a tight bar stops at 4',
    _wideDockedGapStaysAt32AndATightBarStopsAt4,
  );
  testWidgets(
    'centered and edge alignment apply from 600 wide',
    _centeredAndEdgeAlignmentApplyFrom600Wide,
  );
  testWidgets(
    'standard FAB is secondary container and morphs 80 to 56',
    _standardFabIsSecondaryContainerAndMorphs80To56,
  );
  testWidgets(
    'scroll exit composes with collapse-to-FAB',
    _scrollExitComposesWithCollapseToTheFab,
  );
  testWidgets(
    'arrows move focus and a pointer hides the ring',
    _arrowsMoveFocusAndAPointerHidesTheRing,
  );
  testWidgets(
    'horizontal order follows the reading direction',
    _horizontalOrderFollowsTheReadingDirection,
  );
  testWidgets(
    'selected actions are tonal and the emphasis action is filled',
    _selectedActionsAreTonalAndTheEmphasisActionIsFilled,
  );
}

void _toolbarColorRolesFollowTheScheme() {
  final MorphColorScheme scheme = MorphThemeData.light().colorScheme;
  final MorphToolbarTheme theme = MorphToolbarTheme.defaults;

  final MorphToolbarColors standard = theme.colors(
    scheme,
    MorphToolbarColorStyle.standard,
  );
  expect(standard.container, scheme.surfaceContainer);
  expect(standard.content, scheme.onSurfaceVariant);
  expect(standard.selectedContainer, scheme.secondaryContainer);
  expect(standard.selectedContent, scheme.onSecondaryContainer);
  expect(standard.fabContainer, scheme.secondaryContainer);
  expect(standard.fabContent, scheme.onSecondaryContainer);
  expect(standard.emphasisContainer, scheme.primary);
  expect(standard.emphasisContent, scheme.onPrimary);
  expect(
    standard.disabledContent,
    scheme.onSurface.withValues(alpha: MorphToolbarTokens.disabledContentAlpha),
  );

  final MorphToolbarColors vibrant = theme.colors(
    scheme,
    MorphToolbarColorStyle.vibrant,
  );
  expect(vibrant.container, scheme.primaryContainer);
  expect(vibrant.content, scheme.onPrimaryContainer);
  expect(vibrant.selectedContainer, scheme.surfaceContainer);
  expect(vibrant.selectedContent, scheme.onSurface);
  expect(vibrant.fabContainer, scheme.tertiaryContainer);
  expect(vibrant.fabContent, scheme.onTertiaryContainer);
}

Future<void> _floatingElevationIsLevel3AndDockedStaysFlat(
  WidgetTester tester,
) async {
  await tester.pumpWidget(_host(child: MorphToolbar(actions: _actions())));
  expect(_toolbarMaterial(tester).elevation, MorphElevation.level3);

  await tester.pumpWidget(
    _host(
      child: const MorphToolbar.docked(
        safeArea: false,
        actions: <MorphToolbarItem>[
          MorphToolbarAction(icon: MorphIcons.edit, onPressed: _noop),
        ],
      ),
    ),
  );
  expect(_toolbarMaterial(tester).elevation, 0);
}

Future<void> _verticalFloatingMarginIs24(WidgetTester tester) async {
  await tester.pumpWidget(
    _host(
      child: MorphToolbar(axis: Axis.vertical, actions: _actions()),
    ),
  );
  final EdgeInsets insets = _outerPadding(tester);
  expect(insets.left, MorphToolbarTokens.verticalScreenOffset);
  expect(insets.right, MorphToolbarTokens.verticalScreenOffset);
  expect(insets.top, MorphToolbarTokens.verticalScreenOffset);
  expect(insets.bottom, MorphToolbarTokens.verticalScreenOffset);
}

Future<void> _horizontalFloatingMarginStays16(WidgetTester tester) async {
  await tester.pumpWidget(_host(child: MorphToolbar(actions: _actions())));
  expect(_outerPadding(tester).left, MorphToolbarTokens.screenOffset);
}

Future<void> _wideDockedGapStaysAt32AndATightBarStopsAt4(
  WidgetTester tester,
) async {
  await tester.pumpWidget(
    _host(
      child: const SizedBox(
        width: 800,
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
  expect(_iconGap(tester, 0, 1), closeTo(32, 1));

  await tester.pumpWidget(
    _host(
      child: const SizedBox(
        width: 184,
        child: MorphToolbar.docked(
          safeArea: false,
          maxInlineActions: 8,
          actions: <MorphToolbarItem>[
            MorphToolbarAction(icon: MorphIcons.edit, onPressed: _noop),
            MorphToolbarAction(icon: MorphIcons.share, onPressed: _noop),
            MorphToolbarAction(icon: MorphIcons.favorite, onPressed: _noop),
            MorphToolbarAction(icon: MorphIcons.home, onPressed: _noop),
          ],
        ),
      ),
    ),
  );
  expect(find.byType(MorphToolbarOverflowMenu), findsOneWidget);
  expect(_iconGap(tester, 0, 1), closeTo(4, 0.5));
}

Future<void> _centeredAndEdgeAlignmentApplyFrom600Wide(
  WidgetTester tester,
) async {
  await tester.pumpWidget(
    _host(
      child: const SizedBox(
        width: 800,
        child: MorphToolbar.docked(
          safeArea: false,
          contentAlignment: MorphToolbarContentAlignment.centered,
          actions: <MorphToolbarItem>[
            MorphToolbarAction(icon: MorphIcons.edit, onPressed: _noop),
            MorphToolbarAction(icon: MorphIcons.share, onPressed: _noop),
          ],
        ),
      ),
    ),
  );
  expect(_iconGap(tester, 0, 1), closeTo(8, 1));
  final double mid = tester.getCenter(find.byType(MorphToolbar)).dx;
  final double cluster =
      (tester.getCenter(find.byIcon(MorphIcons.edit)).dx +
          tester.getCenter(find.byIcon(MorphIcons.share)).dx) /
      2;
  expect(cluster, closeTo(mid, 1));

  await tester.pumpWidget(
    _host(
      child: const SizedBox(
        width: 800,
        child: MorphToolbar.docked(
          safeArea: false,
          contentAlignment: MorphToolbarContentAlignment.edges,
          actions: <MorphToolbarItem>[
            MorphToolbarAction(icon: MorphIcons.edit, onPressed: _noop),
            MorphToolbarAction(icon: MorphIcons.share, onPressed: _noop),
            MorphToolbarAction(icon: MorphIcons.favorite, onPressed: _noop),
            MorphToolbarAction(icon: MorphIcons.home, onPressed: _noop),
          ],
        ),
      ),
    ),
  );
  final double toolbarLeft = tester.getTopLeft(find.byType(MorphToolbar)).dx;
  final double toolbarRight = tester.getTopRight(find.byType(MorphToolbar)).dx;
  final Finder buttons = find.byType(MorphIconButton);
  expect(tester.getTopLeft(buttons.at(0)).dx - toolbarLeft, closeTo(16, 1));
  expect(toolbarRight - tester.getTopRight(buttons.at(3)).dx, closeTo(16, 1));
}

Future<void> _standardFabIsSecondaryContainerAndMorphs80To56(
  WidgetTester tester,
) async {
  await tester.pumpWidget(
    _host(
      child: const MorphToolbar(
        expanded: false,
        fabExpandIcon: Icon(MorphIcons.add),
        actions: <MorphToolbarItem>[
          MorphToolbarAction(icon: MorphIcons.edit, onPressed: _noop),
        ],
      ),
    ),
  );
  await tester.pump();
  final MorphFab fab = tester.widget<MorphFab>(find.byType(MorphFab));
  expect(fab.color, MorphFabColor.secondary);
  expect(tester.getSize(find.byType(MorphFab)).width, closeTo(80, 0.5));
  expect(
    IconTheme.of(tester.element(find.byIcon(MorphIcons.add))).size,
    MorphToolbarTokens.fabCollapsedIcon,
  );

  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pumpWidget(
    _host(
      child: const MorphToolbar(
        fabExpandIcon: Icon(MorphIcons.add),
        actions: <MorphToolbarItem>[
          MorphToolbarAction(icon: MorphIcons.edit, onPressed: _noop),
        ],
      ),
    ),
  );
  await tester.pump();
  expect(tester.getSize(find.byType(MorphFab)).width, closeTo(56, 0.5));
  expect(
    IconTheme.of(tester.element(find.byIcon(MorphIcons.close))).size,
    MorphToolbarTokens.fabExpandedIcon,
  );
}

/// Hide-on-scroll no longer disables the FAB expand / collapse: a toolbar
/// that starts collapsed with a scroll-exit behavior sits on its collapsed
/// FAB, the same as one without a scroll behavior.
Future<void> _scrollExitComposesWithCollapseToTheFab(
  WidgetTester tester,
) async {
  await tester.pumpWidget(
    _host(
      child: MorphToolbar(
        expanded: false,
        scrollBehavior: MorphToolbarScrollBehavior.exitAlways(),
        fabExpandIcon: const Icon(MorphIcons.add),
        actions: const <MorphToolbarItem>[
          MorphToolbarAction(icon: MorphIcons.edit, onPressed: _noop),
        ],
      ),
    ),
  );
  await tester.pump();
  expect(tester.getSize(find.byType(MorphFab)).width, closeTo(80, 0.5));
  expect(
    IconTheme.of(tester.element(find.byIcon(MorphIcons.add))).size,
    MorphToolbarTokens.fabCollapsedIcon,
  );
}

Future<void> _arrowsMoveFocusAndAPointerHidesTheRing(
  WidgetTester tester,
) async {
  final FocusHighlightStrategy previous =
      FocusManager.instance.highlightStrategy;
  FocusManager.instance.highlightStrategy =
      FocusHighlightStrategy.alwaysTraditional;
  addTearDown(() => FocusManager.instance.highlightStrategy = previous);

  await tester.pumpWidget(
    _host(
      child: const MorphToolbar(
        actions: <MorphToolbarItem>[
          MorphToolbarAction(icon: MorphIcons.edit, onPressed: _noop),
          MorphToolbarAction(icon: MorphIcons.share, onPressed: _noop),
        ],
      ),
    ),
  );
  await tester.pump();
  await tester.sendKeyDownEvent(LogicalKeyboardKey.tab);
  await tester.pump();
  await tester.sendKeyUpEvent(LogicalKeyboardKey.tab);
  await tester.pump();
  expect(_iconFocused(tester, MorphIcons.edit), isTrue);
  expect(_ringVisible(tester), isTrue);

  await tester.sendKeyDownEvent(LogicalKeyboardKey.arrowRight);
  await tester.pump();
  await tester.sendKeyUpEvent(LogicalKeyboardKey.arrowRight);
  await tester.pump();
  expect(_iconFocused(tester, MorphIcons.share), isTrue);
  expect(_ringVisible(tester), isTrue);

  final TestGesture gesture = await tester.createGesture(
    kind: PointerDeviceKind.mouse,
  );
  await gesture.addPointer();
  await gesture.moveTo(tester.getCenter(find.byIcon(MorphIcons.share)));
  await tester.pump();
  expect(MorphFocusInteraction.instance.ringsAllowed, isFalse);
  expect(_ringVisible(tester), isFalse);
  await gesture.removePointer();
}

Future<void> _horizontalOrderFollowsTheReadingDirection(
  WidgetTester tester,
) async {
  await tester.pumpWidget(
    Directionality(
      textDirection: TextDirection.rtl,
      child: MorphTheme(
        data: MorphThemeData.light(),
        child: const MorphToolbar(
          actions: <MorphToolbarItem>[
            MorphToolbarAction(icon: MorphIcons.edit, onPressed: _noop),
            MorphToolbarAction(icon: MorphIcons.share, onPressed: _noop),
          ],
        ),
      ),
    ),
  );
  expect(
    tester.getCenter(find.byIcon(MorphIcons.edit)).dx,
    greaterThan(tester.getCenter(find.byIcon(MorphIcons.share)).dx),
  );
}

Future<void> _selectedActionsAreTonalAndTheEmphasisActionIsFilled(
  WidgetTester tester,
) async {
  await tester.pumpWidget(
    _host(
      child: const MorphToolbar.docked(
        safeArea: false,
        actions: <MorphToolbarItem>[
          MorphToolbarAction(
            icon: MorphIcons.edit,
            onPressed: _noop,
            active: true,
          ),
        ],
      ),
    ),
  );
  expect(
    tester.widget<MorphIconButton>(find.byType(MorphIconButton)).variant,
    MorphIconButtonVariant.tonal,
  );
  expect(
    tester.widget<MorphIconButton>(find.byType(MorphIconButton)).shape,
    MorphIconButtonShapeVariant.square,
  );

  await tester.pumpWidget(
    _host(
      child: const MorphToolbar(
        actions: <MorphToolbarItem>[
          MorphToolbarAction(
            icon: MorphIcons.share,
            onPressed: _noop,
            isExpandTrigger: true,
          ),
        ],
      ),
    ),
  );
  expect(
    tester.widget<MorphIconButton>(find.byType(MorphIconButton)).variant,
    MorphIconButtonVariant.filled,
  );
  expect(
    tester.widget<MorphIconButton>(find.byType(MorphIconButton)).shape,
    MorphIconButtonShapeVariant.round,
  );
}

void _noop() {}

List<MorphToolbarItem> _actions() => const <MorphToolbarItem>[
  MorphToolbarAction(icon: MorphIcons.edit, onPressed: _noop),
  MorphToolbarAction(icon: MorphIcons.share, onPressed: _noop),
];

Widget _host({required Widget child}) {
  return MaterialApp(
    home: MorphTheme(
      data: MorphThemeData.light(),
      child: Scaffold(body: child),
    ),
  );
}

Material _toolbarMaterial(WidgetTester tester) {
  return tester.widget<Material>(
    find.byWidgetPredicate((Widget widget) {
      return widget is Material &&
          (widget.shape is StadiumBorder ||
              widget.shape is RoundedRectangleBorder);
    }).first,
  );
}

EdgeInsets _outerPadding(WidgetTester tester) {
  final Padding padding = tester.widget<Padding>(
    find.descendant(
      of: find.byType(MorphToolbar),
      matching: find.byWidgetPredicate((Widget widget) {
        if (widget is! Padding) {
          return false;
        }
        final EdgeInsets insets = widget.padding.resolve(TextDirection.ltr);
        return insets.left == insets.right && insets.left >= 16;
      }),
    ),
  );
  return padding.padding.resolve(TextDirection.ltr);
}

double _iconGap(WidgetTester tester, int a, int b) {
  final Finder buttons = find.byType(MorphIconButton);
  return tester.getTopLeft(buttons.at(b)).dx -
      tester.getTopRight(buttons.at(a)).dx;
}

bool _ringVisible(WidgetTester tester) {
  return tester
      .widgetList<MorphFocusRing>(find.byType(MorphFocusRing))
      .any((MorphFocusRing ring) => ring.focused);
}

bool _iconFocused(WidgetTester tester, IconData icon) {
  final FocusNode? node = Focus.maybeOf(tester.element(find.byIcon(icon)));
  return node?.hasPrimaryFocus ?? false;
}
