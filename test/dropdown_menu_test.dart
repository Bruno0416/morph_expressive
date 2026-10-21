import 'package:flutter_test/flutter_test.dart';
import 'package:morph_expressive/morph_components.dart';
import 'package:morph_expressive/components/dropdown_menus/components/morph_dropdown_chips.dart';
import 'package:material_ui/material_ui.dart'
    show
        BuildContext,
        Builder,
        Center,
        Column,
        ElevatedButton,
        MaterialPageRoute,
        MediaQuery,
        MediaQueryData,
        Navigator,
        Scaffold,
        Size,
        SizedBox,
        StatefulBuilder,
        Text,
        TextButton,
        Widget;

const List<MorphDropdownItem<String>> _items = <MorphDropdownItem<String>>[
  MorphDropdownItem(label: 'Flutter', value: 'flutter'),
  MorphDropdownItem(label: 'Dart', value: 'dart'),
  MorphDropdownItem(label: 'Material 3', value: 'm3'),
];

Widget _host(Widget child) {
  return MorphMaterialApp(
    data: MorphThemeData.light(),
    home: Scaffold(
      body: MediaQuery(
        data: const MediaQueryData(size: Size(800, 600)),
        child: Center(child: SizedBox(width: 320, child: child)),
      ),
    ),
  );
}

void main() {
  testWidgets(
    'MorphDropdownMenu widget rebuild does not fire onSelectionChanged during build phase',
    _morphdropdownmenuRebuildDoesNotFireOnSelectionChangedDuringBuild,
  );

  testWidgets(
    'MorphDropdownMenu renders field with hint text',
    _morphdropdownmenuRendersFieldWithHintText,
  );
  testWidgets(
    'MorphDropdownMenu opens overlay and reports selection',
    _morphdropdownmenuOpensOverlayAndReportsSelection,
  );
  testWidgets(
    'MorphDropdownMenu single select replaces prior selection',
    _morphdropdownmenuSingleSelectReplacesPriorSelection,
  );
  testWidgets('single-select displays plain selected text without chips', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        const MorphDropdownMenu<String>(
          singleSelect: true,
          items: [
            MorphDropdownItem(label: 'Kotlin', value: 'kotlin', selected: true),
          ],
        ),
      ),
    );

    expect(find.text('Kotlin'), findsOneWidget);
    expect(find.byType(MorphSpringChip<String>), findsNothing);
  });

  testWidgets('multi-select retains removable chips', (tester) async {
    await tester.pumpWidget(
      _host(
        const MorphDropdownMenu<String>(
          singleSelect: false,
          items: [
            MorphDropdownItem(label: 'Kotlin', value: 'kotlin', selected: true),
          ],
        ),
      ),
    );

    expect(find.byType(MorphSpringChip<String>), findsOneWidget);
  });

  testWidgets(
    'MorphDropdownMenu limit blocks extra multi selections',
    _morphdropdownmenuLimitBlocksExtraMultiSelections,
  );
  testWidgets(
    'system back closes the dropdown before the route',
    _systemBackClosesDropdownBeforeRoute,
  );
  testWidgets(
    'outside tap closes the dropdown without activating the page',
    _outsideTapClosesDropdownWithoutActivatingPage,
  );
}

Future<void> _morphdropdownmenuRendersFieldWithHintText(
  WidgetTester tester,
) async {
  await tester.pumpWidget(
    _host(
      const MorphDropdownMenu<String>(
        items: _items,
        fieldStyle: MorphDropdownFieldStyle(hintText: 'Choose framework'),
      ),
    ),
  );

  expect(find.text('Choose framework'), findsOneWidget);
}

Future<void> _morphdropdownmenuOpensOverlayAndReportsSelection(
  WidgetTester tester,
) async {
  var selected = <MorphDropdownItem<String>>[];

  await tester.pumpWidget(
    _host(
      MorphDropdownMenu<String>(
        items: _items,
        fieldStyle: const MorphDropdownFieldStyle(hintText: 'Choose framework'),
        onSelectionChanged: (List<MorphDropdownItem<String>> value) {
          selected = value;
        },
      ),
    ),
  );

  await tester.tap(find.text('Choose framework'));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));

  expect(find.text('Dart'), findsOneWidget);
  await tester.tap(find.text('Dart'));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));

  expect(selected, hasLength(1));
  expect(selected.first.value, 'dart');
  expect(find.text('Dart'), findsWidgets);
}

Future<void> _morphdropdownmenuSingleSelectReplacesPriorSelection(
  WidgetTester tester,
) async {
  var selected = <MorphDropdownItem<String>>[];

  await tester.pumpWidget(
    _host(
      MorphDropdownMenu<String>(
        singleSelect: true,
        items: _items,
        fieldStyle: const MorphDropdownFieldStyle(hintText: 'Choose framework'),
        onSelectionChanged: (List<MorphDropdownItem<String>> value) {
          selected = value;
        },
      ),
    ),
  );

  await tester.tap(find.text('Choose framework'));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));

  await tester.tap(find.text('Flutter'));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));

  expect(selected, hasLength(1));
  expect(selected.first.value, 'flutter');

  // Single selection closes the overlay with a visible spring animation.
  // Wait for the closing panel to be removed before tapping the field again:
  // while it is mounted, the same text also belongs to a menu item.
  await tester.pump(const Duration(milliseconds: 900));
  expect(find.text('Flutter'), findsOneWidget);
  expect(find.text('Material 3'), findsNothing);

  await tester.tap(find.text('Flutter'));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 600));
  expect(find.text('Material 3'), findsOneWidget);

  await tester.tap(find.text('Material 3'));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));

  expect(selected, hasLength(1));
  expect(selected.first.value, 'm3');
}

Future<void> _morphdropdownmenuLimitBlocksExtraMultiSelections(
  WidgetTester tester,
) async {
  var selected = <MorphDropdownItem<String>>[];

  await tester.pumpWidget(
    _host(
      MorphDropdownMenu<String>(
        limit: 2,
        items: _items,
        fieldStyle: const MorphDropdownFieldStyle(hintText: 'Choose framework'),
        onSelectionChanged: (List<MorphDropdownItem<String>> value) {
          selected = value;
        },
      ),
    ),
  );

  await tester.tap(find.text('Choose framework'));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));

  await tester.tap(find.text('Flutter'));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 200));
  expect(selected, hasLength(1));

  await tester.tap(find.text('Dart'));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 200));
  expect(selected, hasLength(2));

  await tester.tap(find.text('Material 3'));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 200));
  expect(selected, hasLength(2));
  expect(
    selected.map((MorphDropdownItem<String> i) => i.value),
    containsAll(<String>['flutter', 'dart']),
  );
}

Future<void> _morphdropdownmenuRebuildDoesNotFireOnSelectionChangedDuringBuild(
  WidgetTester tester,
) async {
  var selectionCallCount = 0;
  List<MorphDropdownItem<String>> currentItems = _items;

  await tester.pumpWidget(
    StatefulBuilder(
      builder: (context, setState) {
        return _host(
          Column(
            children: [
              MorphDropdownMenu<String>(
                items: currentItems,
                onSelectionChanged: (_) {
                  selectionCallCount++;
                  setState(() {});
                },
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    currentItems = const [
                      MorphDropdownItem(label: 'Item A', value: 'a'),
                      MorphDropdownItem(label: 'Item B', value: 'b'),
                    ];
                  });
                },
                child: const Text('Update Items'),
              ),
            ],
          ),
        );
      },
    ),
  );

  expect(selectionCallCount, 0);

  // Trigger parent rebuild with updated items -> runs didUpdateWidget
  await tester.tap(find.text('Update Items'));
  await tester.pump();

  expect(tester.takeException(), isNull);
  expect(selectionCallCount, 0);
}

Future<void> _pumpDropdown(
  WidgetTester tester, {
  Duration duration = const Duration(milliseconds: 300),
}) async {
  await tester.pump();
  await tester.pump(duration);
}

Future<void> _systemBackClosesDropdownBeforeRoute(WidgetTester tester) async {
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
                    builder: (BuildContext context) {
                      return const Scaffold(
                        body: MorphDropdownMenu<String>(
                          items: _items,
                          fieldStyle: MorphDropdownFieldStyle(
                            hintText: 'Choose framework',
                          ),
                        ),
                      );
                    },
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

  await tester.tap(find.text('Choose framework'));
  await _pumpDropdown(tester);
  expect(find.text('Dart'), findsOneWidget);

  await tester.binding.handlePopRoute();
  await _pumpDropdown(tester, duration: const Duration(milliseconds: 900));

  expect(find.text('Dart'), findsNothing);
  expect(find.text('Choose framework'), findsOneWidget);

  await tester.binding.handlePopRoute();
  await tester.pumpAndSettle();

  expect(find.text('Choose framework'), findsNothing);
  expect(find.text('Root'), findsOneWidget);
}

Future<void> _outsideTapClosesDropdownWithoutActivatingPage(
  WidgetTester tester,
) async {
  var behindTapped = false;

  await tester.pumpWidget(
    _host(
      Column(
        children: <Widget>[
          TextButton(
            onPressed: () => behindTapped = true,
            child: const Text('Behind'),
          ),
          const SizedBox(height: 240),
          const MorphDropdownMenu<String>(
            items: _items,
            fieldStyle: MorphDropdownFieldStyle(hintText: 'Choose framework'),
          ),
        ],
      ),
    ),
  );

  await tester.tap(find.text('Choose framework'));
  await _pumpDropdown(tester);
  expect(find.text('Dart'), findsOneWidget);

  await tester.tap(find.text('Behind'), warnIfMissed: false);
  await _pumpDropdown(tester, duration: const Duration(milliseconds: 900));

  expect(behindTapped, isFalse);
  expect(find.text('Dart'), findsNothing);
  expect(find.text('Behind'), findsOneWidget);
}
