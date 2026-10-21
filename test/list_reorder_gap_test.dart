import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morph_expressive/components/lists/components/morph_card_list_item.dart';
import 'package:morph_expressive/components/lists/components/morph_expandable_sublist.dart';
import 'package:morph_expressive/components/lists/components/morph_list_drag_proxy_scope.dart';
import 'package:morph_expressive/components/lists/components/morph_list_reorder_placeholder.dart';
import 'package:morph_expressive/morph_components.dart';
import 'package:material_ui/material_ui.dart'
    show
        BoxDecoration,
        BuildContext,
        DecoratedBox,
        DismissDirection,
        PhysicalModel,
        Rect,
        Size,
        SizedBox,
        StateSetter,
        StatefulBuilder,
        Text;

import 'helpers/list_test_helpers.dart';

void main() {
  testWidgets(
    'dragged card proxy is the card height, not card + gap',
    _draggedProxyExcludesGap,
  );
  testWidgets(
    'dragged dismissible-item proxy is the card height, not card + gap',
    _draggedDismissibleProxyExcludesGap,
  );
  testWidgets(
    'dragged expandable-item proxy is the card height, not card + gap',
    _draggedExpandableProxyExcludesGap,
  );
  testWidgets(
    'header-to-sublist gap survives reorder support',
    _expandableSublistGapSurvivesReorder,
  );
  testWidgets(
    'destination slot fill follows the drag target and clears on drop',
    _placeholderFillsDestinationSlot,
  );
}

Future<void> _placeholderFillsDestinationSlot(WidgetTester tester) async {
  final items = <String>['A', 'B', 'C'];
  await pumpList(
    tester,
    StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        return MorphList(
          reorder: true,
          onReorder: (int oldIndex, int newIndex) {
            setState(() {
              final String item = items.removeAt(oldIndex);
              items.insert(newIndex, item);
            });
          },
          itemCount: items.length,
          itemBuilder: (BuildContext context, int index) =>
              MorphListItem(headline: items[index]),
        );
      },
    ),
  );

  Rect cardRect(String label) => tester.getRect(
    find
        .ancestor(
          of: find.text(label),
          matching: find.byType(MorphCardListItem),
        )
        .first,
  );
  final Finder fill = find.descendant(
    of: find.byType(MorphListReorderPlaceholder),
    matching: find.byType(DecoratedBox),
  );

  final Rect a = cardRect('A');
  final Rect c = cardRect('C');
  expect(find.byType(MorphListReorderPlaceholder), findsNothing);

  final TestGesture gesture = await tester.startGesture(a.center);
  await tester.pump(kLongPressTimeout + const Duration(milliseconds: 50));
  await tester.pumpAndSettle();

  expect(tester.getRect(fill), a, reason: 'fill starts in the source slot');

  await gesture.moveTo(c.center);
  await tester.pumpAndSettle();

  final Rect target = tester.getRect(fill);
  expect(
    target.top,
    moreOrLessEquals(c.top, epsilon: 0.5),
    reason: 'fill moves to the destination slot',
  );
  expect(
    target.size.width,
    moreOrLessEquals(a.width, epsilon: 0.05),
    reason: 'fill width matches the dragged row',
  );
  expect(
    target.size.height,
    moreOrLessEquals(a.height, epsilon: 0.05),
    reason: 'fill height matches the dragged row',
  );

  final DecoratedBox box = tester.widget<DecoratedBox>(fill);
  final MorphThemeData theme = MorphTheme.of(tester.element(fill));
  expect(
    (box.decoration as BoxDecoration).color,
    MorphListReorderState.defaults.resolvedPlaceholderColor(theme.colorScheme),
  );

  await gesture.up();
  await tester.pumpAndSettle();

  expect(find.byType(MorphListReorderPlaceholder), findsNothing);
  expect(items, <String>['B', 'C', 'A']);
}

Future<void> _draggedProxyExcludesGap(WidgetTester tester) async {
  final items = <String>['A', 'B'];
  await pumpList(
    tester,
    StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        return MorphList(
          reorder: true,
          onReorder: (int oldIndex, int newIndex) {
            setState(() {
              final String item = items.removeAt(oldIndex);
              items.insert(newIndex, item);
            });
          },
          itemCount: items.length,
          itemBuilder: (BuildContext context, int index) =>
              MorphListItem(headline: items[index]),
        );
      },
    ),
  );

  final TestGesture gesture = await tester.startGesture(
    tester.getCenter(find.text('A')),
  );
  await tester.pump(kLongPressTimeout + const Duration(milliseconds: 50));

  // The floating proxy's card, identified by `MorphListDragProxyScope`.
  final Size proxySize = tester.getSize(
    find
        .ancestor(
          of: find.byType(MorphListDragProxyScope),
          matching: find.byType(PhysicalModel),
        )
        .first,
  );

  // The still-resting sibling's own card, for the same content shape.
  final Size restingSize = tester.getSize(
    find
        .ancestor(of: find.text('B'), matching: find.byType(MorphCardListItem))
        .first,
  );

  expect(
    proxySize.height,
    restingSize.height,
    reason: 'the dragged card must not carry the trailing gap as extra height',
  );

  await gesture.up();
  await tester.pumpAndSettle();
}

Future<void> _draggedDismissibleProxyExcludesGap(WidgetTester tester) async {
  final items = <String>['A', 'B'];
  await pumpList(
    tester,
    StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        return MorphList(
          reorder: true,
          onReorder: (int oldIndex, int newIndex) {
            setState(() {
              final String item = items.removeAt(oldIndex);
              items.insert(newIndex, item);
            });
          },
          itemCount: items.length,
          itemBuilder: (BuildContext context, int index) => MorphListItem(
            headline: items[index],
            swipe: MorphListItemSwipe(
              onDismiss: (DismissDirection direction) async => false,
            ),
          ),
        );
      },
    ),
  );

  final TestGesture gesture = await tester.startGesture(
    tester.getCenter(find.text('A')),
  );
  await tester.pump(kLongPressTimeout + const Duration(milliseconds: 50));

  // The floating proxy's card, identified by `MorphListDragProxyScope`.
  final Size proxySize = tester.getSize(
    find
        .ancestor(
          of: find.byType(MorphListDragProxyScope),
          matching: find.byType(PhysicalModel),
        )
        .first,
  );

  // The still-resting sibling's own card surface, for the same content shape.
  final Size restingSize = tester.getSize(
    find
        .ancestor(
          of: find.text('B'),
          matching: find.byType(MorphListRowSurface),
        )
        .first,
  );

  expect(
    proxySize.height,
    restingSize.height,
    reason:
        'the dragged dismissible card must not carry the trailing gap as '
        'extra height',
  );

  await gesture.up();
  await tester.pumpAndSettle();
}

Future<void> _draggedExpandableProxyExcludesGap(WidgetTester tester) async {
  final titles = <String>['Alpha', 'Beta'];
  await pumpList(
    tester,
    StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        return MorphList(
          reorder: true,
          onReorder: (int oldIndex, int newIndex) {
            setState(() {
              final String title = titles.removeAt(oldIndex);
              titles.insert(newIndex, title);
            });
          },
          itemCount: titles.length,
          itemBuilder: (BuildContext context, int index) => MorphListItem(
            headline: titles[index],
            expanded: MorphExpandableExpanded.content(
              Text('${titles[index]} body'),
            ),
          ),
        );
      },
    ),
  );

  final TestGesture gesture = await tester.startGesture(
    tester.getCenter(find.text('Alpha')),
  );
  await tester.pump(kLongPressTimeout + const Duration(milliseconds: 50));

  // The floating proxy's card, identified by `MorphListDragProxyScope`.
  final Size proxySize = tester.getSize(
    find
        .ancestor(
          of: find.byType(MorphListDragProxyScope),
          matching: find.byType(PhysicalModel),
        )
        .first,
  );

  // The still-resting sibling's own header card surface.
  final Size restingSize = tester.getSize(
    find
        .ancestor(
          of: find.text('Beta'),
          matching: find.byType(MorphListRowSurface),
        )
        .first,
  );

  expect(
    proxySize.height,
    restingSize.height,
    reason:
        'the dragged expandable header must not carry the trailing gap as '
        'extra height',
  );

  await gesture.up();
  await tester.pumpAndSettle();
}

Future<void> _expandableSublistGapSurvivesReorder(WidgetTester tester) async {
  await pumpList(
    tester,
    MorphList(
      reorder: true,
      onReorder: (int oldIndex, int newIndex) {},
      initiallyExpanded: const <int>{0},
      itemCount: 1,
      itemBuilder: (BuildContext context, int index) {
        return MorphListItem(
          headline: 'Parent',
          expanded: MorphExpandableExpanded.list(
            MorphList(
              embedded: true,
              itemCount: 1,
              itemBuilder: (BuildContext context, int index) {
                return const MorphListItem(headline: 'Child');
              },
            ),
          ),
        );
      },
    ),
  );

  final SizedBox gapBox = tester.widget<SizedBox>(
    find
        .descendant(
          of: find.byType(MorphExpandableSublist),
          matching: find.byType(SizedBox),
        )
        .first,
  );

  final MorphThemeData theme = MorphTheme.of(
    tester.element(find.text('Parent')),
  );
  expect(gapBox.height, theme.listTheme.expandable.gap);
  expect(gapBox.height, greaterThan(0));
}
