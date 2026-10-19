import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morph_expressive/morph_components.dart';
import 'package:material_ui/material_ui.dart';

import 'helpers/list_test_helpers.dart';

MorphList _dataList({
  required List<MorphExpandableData> data,
  bool selection = false,
  MorphListSelectionState? selectionState,
  ValueChanged<Set<int>>? onSelectionChanged,
  bool reorder = false,
  ReorderCallback? onReorder,
  Set<int> initiallyExpanded = const <int>{},
  MorphExpandableStyle? expandStyle,
}) {
  return MorphList(
    itemCount: data.length,
    selection: selection,
    selectionState: selectionState,
    onSelectionChanged: onSelectionChanged,
    reorder: reorder,
    onReorder: onReorder,
    initiallyExpanded: initiallyExpanded,
    expandStyle: expandStyle,
    itemBuilder: (BuildContext context, int index) {
      final MorphExpandableData item = data[index];
      return MorphListItem(
        headline: item.title,
        supportingText: item.subtitle,
        leading: item.leading,
        trailing: item.trailing,
        expanded: item.expanded,
      );
    },
  );
}

void main() {
  testWidgets('expandable sublist appears when expanded', _expandableSublist);
  testWidgets(
    'expandable main selection fill and leading flip',
    _expandableMainSelection,
  );
  testWidgets(
    'expandable leading icon select does not expand',
    _expandableLeadingSelectDoesNotExpand,
  );
  testWidgets(
    'expandable nested last row closes bottom radii',
    _expandableNestedLastClosesBottom,
  );
  testWidgets(
    'expandable parent reorder ignores nested sublist long-press',
    _expandableParentReorderIgnoresNested,
  );
  testWidgets(
    'expandable reorder collapses then restores expansion',
    _expandableReorderRestores,
  );
  testWidgets(
    'expanded row and sublist use the expanded-state fill',
    _expandedStateFill,
  );
  testWidgets(
    'expanded-state fill can be disabled or overridden',
    _expandedStateFillOptOutAndOverride,
  );
  testWidgets(
    'trailing chrome is an unfilled narrow pill at rest',
    _trailingChromeNarrowPill,
  );
  testWidgets(
    'sublist last row rounds its bottom unless opted out',
    _sublistBottomRounding,
  );
}

Future<void> _sublistBottomRounding(WidgetTester tester) async {
  const double outer = 16;
  const double inner = 4.5;

  Future<double> lastNestBottom(MorphExpandableStyle style) async {
    await pumpList(
      tester,
      _dataList(
        expandStyle: style,
        initiallyExpanded: const <int>{0},
        data: <MorphExpandableData>[
          MorphExpandableData(
            title: 'Middle parent',
            expanded: MorphExpandableExpanded.list(
              MorphList(
                embedded: true,
                itemCount: 2,
                itemBuilder: (BuildContext context, int index) =>
                    MorphListItem(headline: 'Nest $index'),
              ),
            ),
          ),
          const MorphExpandableData(
            title: 'Last',
            expanded: MorphExpandableExpanded.content(Text('Last body')),
          ),
        ],
      ),
    );
    return tester
        .widget<MorphCard>(
          find
              .ancestor(
                of: find.text('Nest 1'),
                matching: find.byType(MorphCard),
              )
              .first,
        )
        .borderRadius!
        .bottomLeft
        .x;
  }

  expect(
    await lastNestBottom(const MorphExpandableStyle()),
    moreOrLessEquals(outer, epsilon: 0.01),
  );
  expect(
    await lastNestBottom(const MorphExpandableStyle(roundSublistBottom: false)),
    moreOrLessEquals(inner, epsilon: 0.01),
  );
}

List<MorphExpandableData> _parentWithChildren() => <MorphExpandableData>[
  MorphExpandableData(
    title: 'Parent',
    expanded: MorphExpandableExpanded.list(
      MorphList(
        embedded: true,
        itemCount: 1,
        itemBuilder: (BuildContext context, int index) =>
            const MorphListItem(headline: 'Child'),
      ),
    ),
  ),
];

Color? _headerFill(WidgetTester tester) => tester
    .widget<MorphListRowSurface>(
      find
          .ancestor(
            of: find.text('Parent'),
            matching: find.byType(MorphListRowSurface),
          )
          .first,
    )
    .color;

Future<void> _expandedStateFill(WidgetTester tester) async {
  await pumpList(tester, _dataList(data: _parentWithChildren()));
  final MorphColorScheme scheme = MorphTheme.of(
    tester.element(find.text('Parent')),
  ).colorScheme;

  expect(
    _headerFill(tester)?.toARGB32(),
    scheme.surfaceContainerHighest.toARGB32(),
  );

  await tester.tap(find.text('Parent'));
  await tester.pumpAndSettle();

  expect(
    _headerFill(tester)?.toARGB32(),
    scheme.surfaceContainerHigh.toARGB32(),
  );
  expect(
    rowColor(tester, 'Child')?.toARGB32(),
    scheme.surfaceContainerHigh.toARGB32(),
  );

  await tester.tap(find.text('Parent'));
  await tester.pumpAndSettle();
  expect(
    _headerFill(tester)?.toARGB32(),
    scheme.surfaceContainerHighest.toARGB32(),
  );
}

Future<void> _expandedStateFillOptOutAndOverride(WidgetTester tester) async {
  await pumpList(
    tester,
    _dataList(
      data: _parentWithChildren(),
      initiallyExpanded: const <int>{0},
      expandStyle: const MorphExpandableStyle(expandedStateFill: false),
    ),
  );
  final MorphColorScheme scheme = MorphTheme.of(
    tester.element(find.text('Parent')),
  ).colorScheme;
  expect(
    _headerFill(tester)?.toARGB32(),
    scheme.surfaceContainerHighest.toARGB32(),
  );
  expect(
    rowColor(tester, 'Child')?.toARGB32(),
    scheme.surfaceContainerHighest.toARGB32(),
  );

  const override = Color(0xFFFFE0B2);
  await pumpList(
    tester,
    _dataList(
      data: _parentWithChildren(),
      initiallyExpanded: const <int>{0},
      expandStyle: const MorphExpandableStyle(expandedStateColor: override),
    ),
  );
  expect(_headerFill(tester), override);
  expect(rowColor(tester, 'Child'), override);
}

Future<void> _trailingChromeNarrowPill(WidgetTester tester) async {
  await pumpList(tester, _dataList(data: _parentWithChildren()));
  final Finder chrome = find
      .ancestor(
        of: find.byIcon(MorphIcons.expand_more_rounded),
        matching: find.byType(DecoratedBox),
      )
      .first;
  Color chromeColor() =>
      (tester.widget<DecoratedBox>(chrome).decoration as BoxDecoration).color!;

  expect(tester.getSize(chrome), const Size(32, 40));
  expect(chromeColor().a, 0, reason: 'no fill at rest');

  await tester.tap(find.text('Parent'));
  await tester.pumpAndSettle();

  final MorphColorScheme scheme = MorphTheme.of(
    tester.element(find.text('Parent')),
  ).colorScheme;
  expect(chromeColor().toARGB32(), scheme.surfaceContainer.toARGB32());
  expect(tester.getSize(chrome), const Size(32, 40));
}

Future<void> _expandableSublist(WidgetTester tester) async {
  await pumpList(
    tester,
    _dataList(
      data: <MorphExpandableData>[
        MorphExpandableData(
          title: 'Parent',
          subtitle: 'Tap to expand',
          expanded: MorphExpandableExpanded.list(
            MorphList(
              embedded: true,
              itemCount: 2,
              itemBuilder: (BuildContext context, int index) {
                return MorphListItem(headline: 'Child ${index + 1}');
              },
            ),
          ),
        ),
      ],
    ),
  );

  // Nested list stays mounted while collapsed (selection/reorder persistence),
  // but must not be hit-testable until expanded.
  expect(find.text('Child 1').hitTestable(), findsNothing);
  await tester.tap(find.text('Parent'));
  await tester.pumpAndSettle();
  expect(find.text('Child 1').hitTestable(), findsOneWidget);
  expect(find.text('Child 2').hitTestable(), findsOneWidget);
}

Future<void> _expandableMainSelection(WidgetTester tester) async {
  Set<int>? last;
  await pumpList(
    tester,
    _dataList(
      selection: true,
      selectionState: const MorphListSelectionState(
        mode: MorphListSelectionMode.single,
        selectedIcon: Icon(MorphIcons.check_circle),
      ),
      onSelectionChanged: (Set<int> s) => last = s,
      data: <MorphExpandableData>[
        MorphExpandableData(
          title: 'Section 0',
          leading: const Icon(MorphIcons.inbox),
          expanded: MorphExpandableExpanded.list(
            MorphList(
              embedded: true,
              itemCount: 1,
              itemBuilder: (BuildContext context, int index) {
                return const MorphListItem(
                  headline: 'Nested only',
                  leading: Icon(MorphIcons.folder),
                );
              },
            ),
          ),
        ),
        const MorphExpandableData(
          title: 'Section 1',
          leading: Icon(MorphIcons.inbox),
          expanded: MorphExpandableExpanded.content(Text('Body 1')),
        ),
      ],
    ),
  );

  expect(find.byType(MorphSelectionFlip), findsNWidgets(2));

  await tester.tap(find.text('Section 0'));
  await tester.pumpAndSettle();
  expect(find.text('Nested only'), findsOneWidget);
  // Nested leading must not pick up parent selection flips.
  expect(find.byType(MorphSelectionFlip), findsNWidgets(2));

  await tester.tap(find.byType(MorphSelectionFlip).at(1));
  await tester.pumpAndSettle();
  expect(last, <int>{1});

  final MorphColorScheme scheme = MorphThemeData.light(
    seedColor: const Color(0xFF6750A4),
  ).colorScheme;
  expect(rowColor(tester, 'Section 1'), scheme.secondaryContainer);

  // Selection mode: header tap toggles selection (does not collapse).
  await tester.tap(find.text('Section 0'));
  await tester.pumpAndSettle();
  expect(last, <int>{0});
  expect(find.text('Nested only'), findsOneWidget);
}

Future<void> _expandableLeadingSelectDoesNotExpand(WidgetTester tester) async {
  Set<int>? last;
  await pumpList(
    tester,
    _dataList(
      selection: true,
      onSelectionChanged: (Set<int> s) => last = s,
      selectionState: const MorphListSelectionState(
        selectedIcon: Icon(MorphIcons.check_circle),
      ),
      data: const <MorphExpandableData>[
        MorphExpandableData(
          title: 'Section',
          leading: Icon(MorphIcons.inbox),
          expanded: MorphExpandableExpanded.content(Text('BODY')),
        ),
      ],
    ),
  );

  expect(find.text('BODY'), findsNothing);
  await tester.tap(find.byType(MorphSelectionFlip));
  await tester.pumpAndSettle();
  expect(last, <int>{0});
  expect(find.text('BODY'), findsNothing);

  await tester.tap(find.text('Section'));
  await tester.pumpAndSettle();
  // In selection mode, title tap toggles selection (does not expand).
  expect(last, <int>{});
  expect(find.text('BODY'), findsNothing);
}

Future<void> _expandableNestedLastClosesBottom(WidgetTester tester) async {
  const double outer = 16;
  const double inner = 4.5;

  await pumpList(
    tester,
    _dataList(
      expandStyle: const MorphExpandableStyle(),
      initiallyExpanded: const <int>{1},
      data: <MorphExpandableData>[
        const MorphExpandableData(
          title: 'First',
          expanded: MorphExpandableExpanded.content(Text('First body')),
        ),
        MorphExpandableData(
          title: 'Last parent',
          expanded: MorphExpandableExpanded.list(
            MorphList(
              embedded: true,
              itemCount: 2,
              itemBuilder: (BuildContext context, int index) {
                return MorphListItem(headline: 'Nest $index');
              },
            ),
          ),
        ),
      ],
    ),
  );

  final Finder nest0 = find.ancestor(
    of: find.text('Nest 0'),
    matching: find.byType(MorphCard),
  );
  final Finder nest1 = find.ancestor(
    of: find.text('Nest 1'),
    matching: find.byType(MorphCard),
  );

  expect(
    tester.widget<MorphCard>(nest0).borderRadius,
    BorderRadius.circular(inner),
  );
  expect(
    tester.widget<MorphCard>(nest1).borderRadius,
    const BorderRadius.vertical(
      top: Radius.circular(inner),
      bottom: Radius.circular(outer),
    ),
  );
}

Widget _nestedExpandableReorderList({
  required List<String> parents,
  required List<String> nested,
  required StateSetter setState,
  required VoidCallback onParentReorder,
}) {
  return _dataList(
    reorder: true,
    initiallyExpanded: const <int>{0},
    onReorder: (int oldIndex, int newIndex) {
      onParentReorder();
      setState(() {
        final String item = parents.removeAt(oldIndex);
        parents.insert(newIndex, item);
      });
    },
    data: <MorphExpandableData>[
      for (int i = 0; i < parents.length; i++)
        MorphExpandableData(
          title: parents[i],
          expanded: i == 0
              ? MorphExpandableExpanded.list(
                  MorphList(
                    embedded: true,
                    reorder: true,
                    onReorder: (int oldIndex, int newIndex) {
                      setState(() {
                        final String item = nested.removeAt(oldIndex);
                        nested.insert(newIndex, item);
                      });
                    },
                    itemCount: nested.length,
                    itemBuilder: (BuildContext context, int index) {
                      return MorphListItem(headline: nested[index]);
                    },
                  ),
                )
              : const MorphExpandableExpanded.content(Text('Other body')),
        ),
    ],
  );
}

Future<void> _expandableParentReorderIgnoresNested(WidgetTester tester) async {
  final parents = <String>['Parent A', 'Parent B'];
  final nested = <String>['Nest 0', 'Nest 1', 'Nest 2'];
  var parentReorderCount = 0;

  await pumpList(
    tester,
    StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        return _nestedExpandableReorderList(
          parents: parents,
          nested: nested,
          setState: setState,
          onParentReorder: () => parentReorderCount++,
        );
      },
    ),
  );

  expect(find.text('Nest 0'), findsOneWidget);

  final TestGesture gesture = await tester.startGesture(
    tester.getCenter(find.text('Nest 0').first),
  );
  await tester.pump(kLongPressTimeout + const Duration(milliseconds: 50));
  await tester.pump();
  expect(find.text('Nest 1'), findsOneWidget);
  expect(find.text('Nest 2'), findsOneWidget);

  await gesture.moveBy(const Offset(0, 120));
  await tester.pump();
  await gesture.up();
  await tester.pumpAndSettle();

  expect(parentReorderCount, 0);
  expect(parents, <String>['Parent A', 'Parent B']);
  expect(nested.first, isNot('Nest 0'));
  expect(find.text('Nest 0'), findsOneWidget);
}

Future<void> _expandableReorderRestores(WidgetTester tester) async {
  final titles = <String>['Alpha', 'Beta', 'Gamma'];
  final bodies = <String>['Alpha body', 'Beta body', 'Gamma body'];

  await pumpList(
    tester,
    StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        return _dataList(
          reorder: true,
          initiallyExpanded: const <int>{0},
          onReorder: (int oldIndex, int newIndex) {
            setState(() {
              final String title = titles.removeAt(oldIndex);
              titles.insert(newIndex, title);
              final String body = bodies.removeAt(oldIndex);
              bodies.insert(newIndex, body);
            });
          },
          data: <MorphExpandableData>[
            for (int i = 0; i < titles.length; i++)
              MorphExpandableData(
                title: titles[i],
                subtitle: 'Section',
                expanded: MorphExpandableExpanded.content(Text(bodies[i])),
              ),
          ],
        );
      },
    ),
  );

  expect(find.text('Alpha body'), findsOneWidget);

  final TestGesture gesture = await tester.startGesture(
    tester.getCenter(find.text('Alpha')),
  );
  await tester.pump(kLongPressTimeout + const Duration(milliseconds: 50));
  // Collapse for measure should hide body before/during drag.
  await tester.pump();
  expect(find.text('Alpha body'), findsNothing);

  await gesture.moveBy(const Offset(0, 160));
  await tester.pump();
  await gesture.up();
  await tester.pumpAndSettle();

  expect(titles.first, isNot('Alpha'));
  final int alphaAt = titles.indexOf('Alpha');
  expect(alphaAt, greaterThan(0));
  expect(find.text('Alpha body'), findsOneWidget);
  expect(bodies[alphaAt], 'Alpha body');
}
