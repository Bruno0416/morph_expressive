import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morph_expressive/morph_components.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  registerDismissiblePreviewSnapTests();
  registerDismissibleReorderBlockedTests();
  registerDismissibleFullDismissTests();
  registerDismissibleConfirmationTests();
}

/// Moves in small steps like a real swipe, so the drag wins the gesture arena
/// over the row's tap and still receives the full distance.
Future<void> _swipeBy(
  WidgetTester tester,
  TestGesture gesture,
  double dx,
) async {
  const steps = 5;
  for (var i = 0; i < steps; i++) {
    await gesture.moveBy(Offset(dx / steps, 0));
    await tester.pump();
  }
}

void registerDismissiblePreviewSnapTests() {
  testWidgets('dismissible action preview snaps open and closes on card tap', (
    WidgetTester tester,
  ) async {
    var archiveTaps = 0;
    await tester.pumpWidget(
      MorphMaterialApp(
        data: MorphThemeData.light(seedColor: const Color(0xFF6750A4)),
        home: Scaffold(
          body: MorphList(
            itemCount: 2,
            itemBuilder: (BuildContext context, int index) {
              return MorphListItem(
                headline: 'Item $index',
                swipe: MorphListItemSwipe(
                  onDismiss: (DismissDirection direction) async => false,
                  trailing: <MorphListSwipeAction>[
                    MorphListSwipeAction(
                      icon: const Icon(MorphIcons.archive),
                      width: 56,
                      onPressed: () => archiveTaps++,
                    ),
                    const MorphListSwipeAction(
                      icon: Icon(MorphIcons.delete),
                      width: 56,
                      isPrimary: true,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final Offset start = tester.getCenter(find.text('Item 0'));
    final TestGesture gesture = await tester.startGesture(start);
    // Drag left past 35% of actions width (~(56+56+8*3)=184 → 0.35≈64).
    await _swipeBy(tester, gesture, -100);
    await tester.pump();
    await gesture.up();
    await tester.pumpAndSettle();

    expect(find.byIcon(MorphIcons.archive), findsOneWidget);
    expect(find.byIcon(MorphIcons.delete), findsOneWidget);

    // Card is translated left while open — tap its on-screen body.
    final Finder card = find.ancestor(
      of: find.text('Item 0'),
      matching: find.byType(MorphCard),
    );
    final Rect cardRect = tester.getRect(card.first);
    await tester.tapAt(Offset(cardRect.right - 24, cardRect.center.dy));
    await tester.pumpAndSettle();
    expect(find.byIcon(MorphIcons.archive), findsNothing);

    // Re-open and tap action.
    final TestGesture open = await tester.startGesture(
      tester.getCenter(find.text('Item 0')),
    );
    await _swipeBy(tester, open, -100);
    await tester.pump();
    await open.up();
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(MorphIcons.archive));
    await tester.pumpAndSettle();
    expect(archiveTaps, 1);
    expect(find.byIcon(MorphIcons.archive), findsNothing);
  });
}

List<MorphListSwipeAction> _previewSwipeActions(int index) {
  return const <MorphListSwipeAction>[
    MorphListSwipeAction(icon: Icon(MorphIcons.archive), width: 56),
    MorphListSwipeAction(
      icon: Icon(MorphIcons.delete),
      width: 56,
      isPrimary: true,
    ),
  ];
}

void _applyListReorder(
  List<String> items,
  StateSetter setState,
  int oldIndex,
  int newIndex,
) {
  setState(() {
    final String item = items.removeAt(oldIndex);
    items.insert(newIndex, item);
  });
}

Widget _reorderBlockedColumn(List<String> items, StateSetter setState) {
  return MorphList(
    reorder: true,
    onReorder: (int oldIndex, int newIndex) {
      _applyListReorder(items, setState, oldIndex, newIndex);
    },
    itemCount: items.length,
    itemBuilder: (BuildContext context, int index) {
      return MorphListItem(
        headline: items[index],
        swipe: MorphListItemSwipe(
          onDismiss: (DismissDirection direction) async => false,
          trailing: _previewSwipeActions(index),
        ),
      );
    },
  );
}

Widget _reorderBlockedDismissibleHost(List<String> items) {
  return MorphMaterialApp(
    data: MorphThemeData.light(seedColor: const Color(0xFF6750A4)),
    home: Scaffold(
      body: StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return _reorderBlockedColumn(items, setState);
        },
      ),
    ),
  );
}

Future<void> _openActionPreviewThenAttemptReorder(WidgetTester tester) async {
  final TestGesture open = await tester.startGesture(
    tester.getCenter(find.text('A')),
  );
  await _swipeBy(tester, open, -100);
  await tester.pump();
  await open.up();
  await tester.pumpAndSettle();

  final TestGesture reorder = await tester.startGesture(
    tester.getCenter(find.text('A')),
  );
  await tester.pump(kLongPressTimeout + const Duration(milliseconds: 50));
  await reorder.moveBy(const Offset(0, 120));
  await tester.pump();
  await reorder.up();
  await tester.pumpAndSettle();
}

void registerDismissibleReorderBlockedTests() {
  testWidgets('dismissible action preview blocks reorder long-press', (
    WidgetTester tester,
  ) async {
    final items = <String>['A', 'B', 'C'];
    await tester.pumpWidget(_reorderBlockedDismissibleHost(items));
    await tester.pumpAndSettle();

    final before = List<String>.from(items);
    await _openActionPreviewThenAttemptReorder(tester);
    expect(items, before);
  });
}

void registerDismissibleFullDismissTests() {
  testWidgets('dismissible without actions still full-dismisses', (
    WidgetTester tester,
  ) async {
    var dismissed = false;
    await tester.pumpWidget(
      MorphMaterialApp(
        data: MorphThemeData.light(seedColor: const Color(0xFF6750A4)),
        home: Scaffold(
          body: SizedBox(
            width: 400,
            child: MorphList(
              itemCount: 1,
              dismissStyle: const MorphDismissibleListStyle(
                background: ColoredBox(color: Color(0xFF00FF00)),
              ),
              itemBuilder: (BuildContext context, int index) {
                return MorphListItem(
                  headline: 'Only',
                  swipe: MorphListItemSwipe(
                    onDismiss: (DismissDirection direction) async {
                      dismissed = true;
                      return true;
                    },
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final TestGesture gesture = await tester.startGesture(
      tester.getCenter(find.text('Only')),
    );
    await _swipeBy(tester, gesture, 120);
    await tester.pump();
    await gesture.up();
    await tester.pumpAndSettle();
    expect(dismissed, isTrue);
  });
}

/// Regression coverage for asynchronous dismiss confirmation and disabled rows.
void registerDismissibleConfirmationTests() {
  testWidgets(
    'false dismissal confirmation restores row and skips primary action',
    (WidgetTester tester) async {
      var confirmations = 0;
      var primaryActions = 0;
      await tester.pumpWidget(
        MorphMaterialApp(
          data: MorphThemeData.light(seedColor: const Color(0xFF6750A4)),
          home: Scaffold(
            body: SizedBox(
              width: 400,
              child: MorphList(
                itemCount: 1,
                itemBuilder: (context, index) => MorphListItem(
                  headline: 'Keep me',
                  swipe: MorphListItemSwipe(
                    mode: MorphListSwipeMode.dismiss,
                    onDismiss: (_) async {
                      confirmations++;
                      return false;
                    },
                    leading: [
                      MorphListSwipeAction(
                        icon: const Icon(MorphIcons.delete),
                        isPrimary: true,
                        onPressed: () => primaryActions++,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final gesture = await tester.startGesture(
        tester.getCenter(find.text('Keep me')),
      );
      await _swipeBy(tester, gesture, 160);
      await gesture.up();
      await tester.pumpAndSettle();

      expect(confirmations, 1);
      expect(primaryActions, 0);
      expect(find.text('Keep me'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'pending confirmation prevents a second dismiss and commits once',
    (WidgetTester tester) async {
      final confirmation = Completer<bool>();
      final controller = MorphDismissibleListController();
      var confirmations = 0;
      var primaryActions = 0;
      await tester.pumpWidget(
        MorphMaterialApp(
          data: MorphThemeData.light(seedColor: const Color(0xFF6750A4)),
          home: Scaffold(
            body: SizedBox(
              width: 400,
              child: MorphList(
                itemCount: 1,
                dismissController: controller,
                itemBuilder: (context, index) => MorphListItem(
                  headline: 'Confirm me',
                  swipe: MorphListItemSwipe(
                    mode: MorphListSwipeMode.dismiss,
                    onDismiss: (_) {
                      confirmations++;
                      return confirmation.future;
                    },
                    leading: [
                      MorphListSwipeAction(
                        icon: const Icon(MorphIcons.delete),
                        isPrimary: true,
                        onPressed: () => primaryActions++,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      controller.dismiss(0);
      await tester.pump();
      controller.dismiss(0);
      await tester.pump();
      expect(confirmations, 1);
      expect(primaryActions, 0);
      expect(find.text('Confirm me'), findsOneWidget);

      confirmation.complete(true);
      await tester.pumpAndSettle();
      expect(primaryActions, 1);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('disabled rows refuse controller reveal and dismiss', (
    WidgetTester tester,
  ) async {
    final controller = MorphDismissibleListController();
    var confirmations = 0;
    await tester.pumpWidget(
      MorphMaterialApp(
        data: MorphThemeData.light(seedColor: const Color(0xFF6750A4)),
        home: Scaffold(
          body: MorphList(
            itemCount: 1,
            dismissController: controller,
            itemBuilder: (context, index) => MorphListItem(
              headline: 'Disabled',
              enabled: false,
              swipe: MorphListItemSwipe(
                onDismiss: (_) async {
                  confirmations++;
                  return true;
                },
                trailing: const [
                  MorphListSwipeAction(icon: Icon(MorphIcons.archive)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    controller.reveal(0, leading: false);
    controller.dismiss(0);
    await tester.pumpAndSettle();
    expect(confirmations, 0);
    expect(find.byIcon(MorphIcons.archive), findsNothing);
    expect(find.text('Disabled'), findsOneWidget);
  });
}
