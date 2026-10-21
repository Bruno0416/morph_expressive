import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morph_expressive/morph_components.dart';
import 'package:material_ui/material_ui.dart'
    show
        BuildContext,
        Center,
        Element,
        FocusHighlightStrategy,
        FocusManager,
        FocusNode,
        Icon,
        Key,
        MediaQuery,
        MediaQueryData,
        Scaffold,
        Size,
        SizedBox,
        Text,
        ValueChanged,
        Widget,
        primaryFocus;

final List<MorphExpandableData> _items = <MorphExpandableData>[
  const MorphExpandableData(
    title: 'Battery level low',
    subtitle: 'Plug in your device.',
    expanded: MorphExpandableExpanded.content(Text('Your battery is at 10%.')),
  ),
  const MorphExpandableData(
    title: 'System update available',
    subtitle: 'Version 2.4.0 is ready.',
    expanded: MorphExpandableExpanded.content(
      Text('This update includes security fixes.'),
    ),
  ),
];

MorphList _dataList({
  required List<MorphExpandableData> data,
  bool selection = false,
  MorphListSelectionState? selectionState,
  ValueChanged<Set<int>>? onSelectionChanged,
  bool? allowMultipleExpanded,
  Set<int> initiallyExpanded = const <int>{},
  void Function(int index, {required bool isExpanded})? onExpansionChanged,
}) {
  return MorphList(
    itemCount: data.length,
    selection: selection,
    selectionState: selectionState,
    onSelectionChanged: onSelectionChanged,
    allowMultipleExpanded: allowMultipleExpanded,
    initiallyExpanded: initiallyExpanded,
    onExpansionChanged: onExpansionChanged,
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

bool _focusInNestedList() {
  var found = false;
  primaryFocus?.context?.visitAncestorElements((Element element) {
    if (element.widget.key == const Key('nested-list')) {
      found = true;
    }
    return !found;
  });
  return found;
}

Widget _host(Widget child) {
  return MorphMaterialApp(
    data: MorphThemeData.light(),
    home: Scaffold(
      body: MediaQuery(
        data: const MediaQueryData(size: Size(800, 600)),
        child: Center(child: SizedBox(width: 400, child: child)),
      ),
    ),
  );
}

Widget _expandedSublistForTabTraversal(List<String> taps) {
  return _dataList(
    initiallyExpanded: const <int>{0},
    data: <MorphExpandableData>[
      MorphExpandableData(
        title: 'Parent',
        subtitle: 'Has nested rows',
        expanded: MorphExpandableExpanded.list(
          MorphList(
            key: const Key('nested-list'),
            embedded: true,
            itemCount: 2,
            onTap: (int index) => taps.add('nested-$index'),
            itemBuilder: (BuildContext context, int index) {
              return MorphListItem(headline: 'Nested $index');
            },
          ),
        ),
      ),
      const MorphExpandableData(
        title: 'Next parent',
        subtitle: 'After sublist',
        expanded: MorphExpandableExpanded.content(Text('Body')),
      ),
    ],
  );
}

Future<void> _pumpExpandedSublistForTabTraversal(
  WidgetTester tester,
  List<String> taps,
) async {
  await tester.pumpWidget(_host(_expandedSublistForTabTraversal(taps)));
  await tester.pumpAndSettle();
  FocusManager.instance.highlightStrategy =
      FocusHighlightStrategy.alwaysTraditional;
}

void main() {
  registerExpandableListRendersTitlesTests();
  registerExpandableListExpandsAndReportsTests();
  registerExpandableListSingleExpandTests();
  registerExpandableSublistTabTraversalTests();
  registerExpandableSublistSelectionPersistenceTests();
  registerExpandableSelectionTrailingExpandTests();
}

void registerExpandableListRendersTitlesTests() {
  testWidgets('MorphExpandableList renders item titles', (tester) async {
    await tester.pumpWidget(_host(_dataList(data: _items)));

    expect(find.text('Battery level low'), findsOneWidget);
    expect(find.text('System update available'), findsOneWidget);
  });
}

void registerExpandableListExpandsAndReportsTests() {
  testWidgets('MorphExpandableList expands item and reports change', (
    tester,
  ) async {
    int? changedIndex;
    bool? changedExpanded;

    await tester.pumpWidget(
      _host(
        _dataList(
          data: _items,
          onExpansionChanged: (int index, {required bool isExpanded}) {
            changedIndex = index;
            changedExpanded = isExpanded;
          },
        ),
      ),
    );

    await tester.tap(find.text('Battery level low'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(changedIndex, 0);
    expect(changedExpanded, isTrue);
    expect(find.text('Your battery is at 10%.'), findsOneWidget);
  });
}

void registerExpandableListSingleExpandTests() {
  testWidgets('MorphExpandableList single-expand collapses prior item', (
    tester,
  ) async {
    final expandedEvents = <int>[];

    await tester.pumpWidget(
      _host(
        _dataList(
          data: _items,
          allowMultipleExpanded: false,
          onExpansionChanged: (int index, {required bool isExpanded}) {
            if (isExpanded) {
              expandedEvents.add(index);
            }
          },
        ),
      ),
    );

    await tester.tap(find.text('Battery level low'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(expandedEvents, <int>[0]);

    await tester.tap(find.text('System update available'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(expandedEvents, <int>[0, 1]);
    expect(find.text('This update includes security fixes.'), findsOneWidget);
  });
}

void registerExpandableSublistTabTraversalTests() {
  testWidgets('expanded sublist rows are reached by arrows, not Tab', (
    WidgetTester tester,
  ) async {
    final taps = <String>[];
    await _pumpExpandedSublistForTabTraversal(tester, taps);

    expect(find.text('Nested 0'), findsOneWidget);
    expect(find.text('Nested 1'), findsOneWidget);

    // The list is one Tab stop: Tab lands on the header and never on a
    // nested row.
    expect(primaryFocus?.nextFocus(), isTrue);
    await tester.pumpAndSettle();
    expect(_focusInNestedList(), isFalse);
    final FocusNode? header = primaryFocus;

    // Nothing else on screen takes focus, so Tab has nowhere to go.
    primaryFocus?.nextFocus();
    await tester.pumpAndSettle();
    expect(_focusInNestedList(), isFalse);

    // Back on the header, arrows step into the sublist.
    header!.requestFocus();
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pumpAndSettle();
    expect(_focusInNestedList(), isTrue);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(taps, <String>['nested-0']);
  });

  testWidgets('arrow keys walk an expanded sublist between headers', (
    WidgetTester tester,
  ) async {
    final taps = <String>[];
    await _pumpExpandedSublistForTabTraversal(tester, taps);

    expect(primaryFocus?.nextFocus(), isTrue);
    await tester.pumpAndSettle();

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(taps, <String>['nested-0']);

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(taps, <String>['nested-0', 'nested-1']);

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pumpAndSettle();
    expect(_focusInNestedList(), isFalse);

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(taps, <String>['nested-0', 'nested-1', 'nested-1']);
  });
}

void registerExpandableSublistSelectionPersistenceTests() {
  testWidgets('nested selection survives collapse and re-expand', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _host(
        _dataList(
          initiallyExpanded: const <int>{0},
          data: <MorphExpandableData>[
            MorphExpandableData(
              title: 'Parent',
              expanded: MorphExpandableExpanded.list(
                MorphList(
                  embedded: true,
                  selection: true,
                  selectionState: const MorphListSelectionState(
                    selectedIcon: Icon(MorphIcons.check_circle),
                  ),
                  itemCount: 2,
                  itemBuilder: (BuildContext context, int index) {
                    return MorphListItem(
                      headline: 'Child $index',
                      leading: const Icon(MorphIcons.star_outline),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byType(MorphSelectionFlip).first);
    await tester.pumpAndSettle();
    expect(
      tester
          .widgetList<MorphSelectionFlip>(find.byType(MorphSelectionFlip))
          .first
          .selected,
      isTrue,
    );

    // Collapse then re-expand — owned FeatureHost must stay mounted.
    await tester.tap(find.text('Parent'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Parent'));
    await tester.pumpAndSettle();

    expect(find.text('Child 0'), findsOneWidget);
    expect(
      tester
          .widgetList<MorphSelectionFlip>(find.byType(MorphSelectionFlip))
          .first
          .selected,
      isTrue,
    );
  });
}

void registerExpandableSelectionTrailingExpandTests() {
  testWidgets('selection on: trailing icon expands when not selecting', (
    WidgetTester tester,
  ) async {
    Set<int>? last;
    await tester.pumpWidget(
      _host(
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
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(MorphIcons.expand_more_rounded));
    await tester.pumpAndSettle();
    expect(find.text('BODY'), findsOneWidget);
    expect(last, isNull);
  });
}
