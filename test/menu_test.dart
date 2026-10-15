import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morph_expressive/morph_components.dart';
import 'package:material_ui/material_ui.dart';

Widget _host(Widget child) {
  return MorphMaterialApp(
    data: MorphThemeData.light(),
    home: Scaffold(
      body: MediaQuery(
        data: const MediaQueryData(size: Size(800, 600)),
        child: Center(child: child),
      ),
    ),
  );
}

Future<void> _settleSpring(WidgetTester tester) async {
  // Expressive spatial springs can overshoot; settle fully like dropdown tests.
  await tester.pump();
  await tester.pumpAndSettle(const Duration(milliseconds: 50));
}

void main() {
  testWidgets(
    'MorphMenu opens and dismisses on scrim tap',
    _morphmenuOpensAndDismissesOnScrimTap,
  );
  testWidgets(
    'MorphMenu entry onPressed fires and closes',
    _morphmenuEntryOnpressedFiresAndCloses,
  );
  testWidgets(
    'showMorphMenu returns selectable value',
    _showmorphmenuReturnsSelectableValue,
  );
  testWidgets(
    'disabled menu entry is not tappable',
    _disabledMenuEntryIsNotTappable,
  );
  testWidgets(
    'system back closes the menu before the route',
    _systemBackClosesMenuBeforeRoute,
  );
  testWidgets(
    'system back closes a submenu before its parent menu',
    _systemBackClosesSubmenuBeforeParent,
  );
  test('menu theme defaults follow the spec presets', _menuThemeDefaults);
  testWidgets(
    'opening a menu focuses the first enabled item',
    _openingFocusesFirstItem,
  );
  testWidgets(
    'arrow keys move focus and skip disabled items',
    _arrowKeysSkipDisabledItems,
  );
  testWidgets('letter keys move focus by typeahead', _letterKeysTypeahead);
  testWidgets('multi-select keeps the menu open', _multiSelectKeepsMenuOpen);
  testWidgets(
    'multi-select can rebuild the anchor while the menu is open',
    _multiSelectRebuildsAnchor,
  );
  testWidgets(
    'a scrolling menu uses dividers instead of gaps',
    _scrollingMenuUsesDividers,
  );
  testWidgets(
    'grouped menus keep a gap when they do not scroll',
    _groupedMenusKeepGapWhenNotScrolling,
  );
}

Future<void> _morphmenuOpensAndDismissesOnScrimTap(WidgetTester tester) async {
  await tester.pumpWidget(
    _host(
      MorphMenu(
        anchorBuilder: (BuildContext context, VoidCallback open) {
          return TextButton(onPressed: open, child: const Text('Open'));
        },
        children: const <MorphMenuNode>[
          MorphMenuEntry(label: 'One'),
          MorphMenuEntry(label: 'Two'),
        ],
      ),
    ),
  );

  expect(find.text('One'), findsNothing);

  await tester.tap(find.text('Open'));
  await _settleSpring(tester);

  expect(find.text('One'), findsOneWidget);
  expect(find.text('Two'), findsOneWidget);

  await tester.tapAt(const Offset(10, 10));
  await _settleSpring(tester);

  expect(find.text('One'), findsNothing);
}

Future<void> _morphmenuEntryOnpressedFiresAndCloses(WidgetTester tester) async {
  var pressed = false;

  await tester.pumpWidget(
    _host(
      MorphMenu(
        anchorBuilder: (BuildContext context, VoidCallback open) {
          return TextButton(onPressed: open, child: const Text('Open'));
        },
        children: <MorphMenuNode>[
          MorphMenuEntry(label: 'Action', onPressed: () => pressed = true),
        ],
      ),
    ),
  );

  await tester.tap(find.text('Open'));
  await _settleSpring(tester);

  await tester.tap(find.text('Action'));
  await _settleSpring(tester);

  expect(pressed, isTrue);
  expect(find.text('Action'), findsNothing);
}

Future<void> _showmorphmenuReturnsSelectableValue(WidgetTester tester) async {
  Object? selected;

  await tester.pumpWidget(
    _host(
      Builder(
        builder: (BuildContext context) {
          return TextButton(
            onPressed: () async {
              final buttonBox = context.findRenderObject()! as RenderBox;
              selected = await showMorphMenu<String>(
                context: context,
                anchor: buttonBox.localToGlobal(Offset.zero) & buttonBox.size,
                children: const <MorphMenuNode>[
                  MorphMenuSelectable(label: 'Alpha', value: 'a'),
                  MorphMenuSelectable(label: 'Beta', value: 'b'),
                ],
              );
            },
            child: const Text('Show'),
          );
        },
      ),
    ),
  );

  await tester.tap(find.text('Show'));
  await _settleSpring(tester);

  await tester.tap(find.text('Beta'));
  await _settleSpring(tester);

  expect(selected, 'b');
}

Future<void> _disabledMenuEntryIsNotTappable(WidgetTester tester) async {
  var pressed = false;

  await tester.pumpWidget(
    _host(
      MorphMenu(
        anchorBuilder: (BuildContext context, VoidCallback open) {
          return TextButton(onPressed: open, child: const Text('Open'));
        },
        children: <MorphMenuNode>[
          MorphMenuEntry(
            label: 'Nope',
            enabled: false,
            onPressed: () => pressed = true,
          ),
        ],
      ),
    ),
  );

  await tester.tap(find.text('Open'));
  await _settleSpring(tester);

  await tester.tap(find.text('Nope'));
  await tester.pump();

  expect(pressed, isFalse);
  expect(find.text('Nope'), findsOneWidget);
}

Future<void> _openPushedPage(WidgetTester tester, Widget page) async {
  await tester.pumpWidget(
    MorphMaterialApp(
      data: MorphThemeData.light(),
      home: Builder(
        builder: (BuildContext context) {
          return Scaffold(
            body: TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) => page,
                  ),
                );
              },
              child: const Text('Root'),
            ),
          );
        },
      ),
    ),
  );
  await tester.tap(find.text('Root'));
  await tester.pumpAndSettle();
}

Future<void> _systemBackClosesMenuBeforeRoute(WidgetTester tester) async {
  await _openPushedPage(
    tester,
    Scaffold(
      body: MorphMenu(
        anchorBuilder: (BuildContext context, VoidCallback open) {
          return TextButton(onPressed: open, child: const Text('Open'));
        },
        children: const <MorphMenuNode>[MorphMenuEntry(label: 'One')],
      ),
    ),
  );

  await tester.tap(find.text('Open'));
  await _settleSpring(tester);
  expect(find.text('One'), findsOneWidget);

  await tester.binding.handlePopRoute();
  await _settleSpring(tester);

  expect(find.text('One'), findsNothing);
  expect(find.text('Open'), findsOneWidget);

  await tester.binding.handlePopRoute();
  await tester.pumpAndSettle();

  expect(find.text('Open'), findsNothing);
  expect(find.text('Root'), findsOneWidget);
}

Future<void> _systemBackClosesSubmenuBeforeParent(WidgetTester tester) async {
  await _openPushedPage(
    tester,
    Scaffold(
      body: MorphMenu(
        anchorBuilder: (BuildContext context, VoidCallback open) {
          return TextButton(onPressed: open, child: const Text('Open'));
        },
        children: const <MorphMenuNode>[
          MorphMenuSubmenu(
            label: 'More',
            children: <MorphMenuNode>[MorphMenuEntry(label: 'Nested')],
          ),
        ],
      ),
    ),
  );

  await tester.tap(find.text('Open'));
  await _settleSpring(tester);
  await tester.tap(find.text('More'));
  await _settleSpring(tester);
  expect(find.text('Nested'), findsOneWidget);

  await tester.binding.handlePopRoute();
  await _settleSpring(tester);

  expect(find.text('Nested'), findsNothing);
  expect(find.text('More'), findsOneWidget);

  await tester.binding.handlePopRoute();
  await _settleSpring(tester);

  expect(find.text('More'), findsNothing);
  expect(find.text('Open'), findsOneWidget);

  await tester.binding.handlePopRoute();
  await tester.pumpAndSettle();
  expect(find.text('Root'), findsOneWidget);
}

void _menuThemeDefaults() {
  const vertical = MorphMenuTheme.defaults;
  expect(vertical.entryHeight, 48);
  expect(vertical.entryHorizontalPadding, 8);
  expect(vertical.entryVerticalPadding, 0);
  expect(vertical.iconSize, 20);
  expect(vertical.iconGap, 8);
  expect(vertical.verticalPadding, 4);
  expect(vertical.sectionGap, 2);
  expect(vertical.itemGap, 4);
  expect(vertical.containerRadius, 16);
  expect(vertical.containerBottomRadius, 12);
  expect(vertical.itemRadius, 12);
  expect(vertical.stateLayerInset, 4);
  expect(vertical.groupLabelHeight, 32);
  expect(vertical.focusIndicatorWidth, 3);
  expect(vertical.focusIndicatorOffset, -3);

  const MorphMenuTheme baseline = MorphMenuTheme.baselineMetrics;
  expect(baseline.entryHeight, 48);
  expect(baseline.entryHorizontalPadding, 12);
  expect(baseline.iconSize, 24);
  expect(baseline.itemRadius, 4);
  expect(baseline.containerRadius, 4);
  expect(baseline.containerBottomRadius, 4);
  expect(baseline.dividerVerticalPadding, 8);
  expect(baseline.verticalPadding, 8);
  expect(baseline.iconGap, 12);
  expect(baseline.itemGap, 0);
}

bool _focusShows(WidgetTester tester, String label) {
  final BuildContext? context =
      tester.binding.focusManager.primaryFocus?.context;
  if (context == null) {
    return false;
  }
  return find
      .descendant(of: find.byWidget(context.widget), matching: find.text(label))
      .evaluate()
      .isNotEmpty;
}

Future<void> _openingFocusesFirstItem(WidgetTester tester) async {
  await tester.pumpWidget(
    _host(
      MorphMenu(
        anchorBuilder: (BuildContext context, VoidCallback open) {
          return TextButton(onPressed: open, child: const Text('Open'));
        },
        children: const <MorphMenuNode>[
          MorphMenuEntry(label: 'One'),
          MorphMenuEntry(label: 'Two'),
        ],
      ),
    ),
  );

  await tester.tap(find.text('Open'));
  await _settleSpring(tester);

  expect(_focusShows(tester, 'One'), isTrue);
}

Future<void> _arrowKeysSkipDisabledItems(WidgetTester tester) async {
  await tester.pumpWidget(
    _host(
      MorphMenu(
        anchorBuilder: (BuildContext context, VoidCallback open) {
          return TextButton(onPressed: open, child: const Text('Open'));
        },
        children: const <MorphMenuNode>[
          MorphMenuEntry(label: 'One'),
          MorphMenuEntry(label: 'Skip', enabled: false),
          MorphMenuEntry(label: 'Three'),
        ],
      ),
    ),
  );

  await tester.tap(find.text('Open'));
  await _settleSpring(tester);
  await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
  await tester.pump();

  expect(_focusShows(tester, 'Three'), isTrue);
}

Future<void> _letterKeysTypeahead(WidgetTester tester) async {
  await tester.pumpWidget(
    _host(
      MorphMenu(
        anchorBuilder: (BuildContext context, VoidCallback open) {
          return TextButton(onPressed: open, child: const Text('Open'));
        },
        children: const <MorphMenuNode>[
          MorphMenuEntry(label: 'One'),
          MorphMenuEntry(label: 'Two'),
          MorphMenuEntry(label: 'Three'),
        ],
      ),
    ),
  );

  await tester.tap(find.text('Open'));
  await _settleSpring(tester);
  await tester.sendKeyEvent(LogicalKeyboardKey.keyT);
  await tester.pump();

  expect(_focusShows(tester, 'Two'), isTrue);
}

Future<void> _multiSelectKeepsMenuOpen(WidgetTester tester) async {
  final picked = <Object?>[];

  await tester.pumpWidget(
    _host(
      MorphMenu(
        selectionMode: MorphMenuSelectionMode.multi,
        onSelected: picked.add,
        anchorBuilder: (BuildContext context, VoidCallback open) {
          return TextButton(onPressed: open, child: const Text('Open'));
        },
        children: const <MorphMenuNode>[
          MorphMenuSelectable(label: 'Alpha', value: 'a'),
          MorphMenuSelectable(label: 'Beta', value: 'b'),
        ],
      ),
    ),
  );

  await tester.tap(find.text('Open'));
  await _settleSpring(tester);
  await tester.tap(find.text('Alpha'));
  await _settleSpring(tester);

  expect(picked, <Object?>['a']);
  expect(find.text('Beta'), findsOneWidget);
}

Future<void> _multiSelectRebuildsAnchor(WidgetTester tester) async {
  final selected = <String>{};

  await tester.pumpWidget(
    _host(
      StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return MorphMenu(
            selectionMode: MorphMenuSelectionMode.multi,
            onSelected: (Object? value) {
              setState(() => selected.add(value! as String));
            },
            anchorBuilder: (BuildContext context, VoidCallback open) {
              return TextButton(onPressed: open, child: const Text('Open'));
            },
            children: <MorphMenuNode>[
              MorphMenuSelectable(
                label: 'Alpha',
                value: 'a',
                selected: selected.contains('a'),
              ),
              MorphMenuSelectable(
                label: 'Beta',
                value: 'b',
                selected: selected.contains('b'),
              ),
            ],
          );
        },
      ),
    ),
  );

  await tester.tap(find.text('Open'));
  await _settleSpring(tester);
  await tester.tap(find.text('Alpha'));
  await _settleSpring(tester);

  expect(tester.takeException(), isNull);
  expect(selected, <String>{'a'});
  expect(find.text('Beta'), findsOneWidget);
}

Future<void> _scrollingMenuUsesDividers(WidgetTester tester) async {
  await tester.pumpWidget(
    _host(
      Builder(
        builder: (BuildContext context) {
          return TextButton(
            onPressed: () {
              final box = context.findRenderObject()! as RenderBox;
              showMorphMenu<void>(
                context: context,
                anchor: box.localToGlobal(Offset.zero) & box.size,
                themeOverride: const MorphMenuTheme(maxHeight: 80),
                children: const <MorphMenuNode>[
                  MorphMenuGroup(
                    children: <MorphMenuNode>[
                      MorphMenuEntry(label: 'One'),
                      MorphMenuEntry(label: 'Two'),
                      MorphMenuEntry(label: 'Three'),
                      MorphMenuEntry(label: 'Four'),
                    ],
                  ),
                  MorphMenuGroup(
                    children: <MorphMenuNode>[
                      MorphMenuEntry(label: 'Five'),
                      MorphMenuEntry(label: 'Six'),
                    ],
                  ),
                ],
              );
            },
            child: const Text('Show'),
          );
        },
      ),
    ),
  );

  await tester.tap(find.text('Show'));
  await _settleSpring(tester);

  expect(find.byType(MorphMenuDividerWidget), findsOneWidget);
  final RawScrollbar bar = tester.widget<RawScrollbar>(
    find.byType(RawScrollbar),
  );
  expect(bar.thumbVisibility, isTrue);
  expect(bar.controller!.position.maxScrollExtent, greaterThan(0));
}

Future<void> _groupedMenusKeepGapWhenNotScrolling(WidgetTester tester) async {
  await tester.pumpWidget(
    _host(
      MorphMenu(
        anchorBuilder: (BuildContext context, VoidCallback open) {
          return TextButton(onPressed: open, child: const Text('Open'));
        },
        children: const <MorphMenuNode>[
          MorphMenuGroup(children: <MorphMenuNode>[MorphMenuEntry(label: 'One')]),
          MorphMenuGroup(children: <MorphMenuNode>[MorphMenuEntry(label: 'Two')]),
        ],
      ),
    ),
  );

  await tester.tap(find.text('Open'));
  await _settleSpring(tester);

  expect(find.text('One'), findsOneWidget);
  expect(find.byType(MorphMenuDividerWidget), findsNothing);
}
