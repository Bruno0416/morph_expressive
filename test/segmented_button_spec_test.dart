import 'package:flutter_test/flutter_test.dart';
import 'package:morph_expressive/morph_components.dart';
import 'package:material_ui/material_ui.dart';

Widget _host(Widget child) => MaterialApp(
  home: MorphTheme(
    data: MorphThemeData.light(),
    child: Scaffold(body: Center(child: child)),
  ),
);

void main() {
  _registerSegmentedLayoutTests();
  _registerSegmentedSelectionTests();
  _registerSegmentedThemeTests();
}

void _registerSegmentedLayoutTests() {
  testWidgets(
    'density shrinks visual height and keeps ≥48 layout',
    _densityShrinksVisualHeightAndKeeps48Layout,
  );
  testWidgets(
    'icon-only selected shows check instead of category icon',
    _iconOnlySelectedShowsCheckInsteadOfCategoryIcon,
  );
}

void _registerSegmentedSelectionTests() {
  testWidgets(
    'single-select cannot clear the selected segment',
    _singleSelectCannotClearTheSelectedSegment,
  );
  testWidgets(
    'multi-select toggles and allows empty',
    _multiSelectTogglesAndAllowsEmpty,
  );
  testWidgets(
    'disabled segment does not change selection',
    _disabledSegmentDoesNotChangeSelection,
  );
}

void _registerSegmentedThemeTests() {
  test('theme density heights match spec', _themeDensityHeightsMatchSpec);
  test(
    'segment count assert rejects fewer than 2',
    _segmentCountAssertRejectsFewerThan2,
  );
}

Future<void> _densityShrinksVisualHeightAndKeeps48Layout(
  WidgetTester tester,
) async {
  await tester.pumpWidget(
    _host(
      MorphSegmentedButton<int>(
        density: MorphSegmentedButtonDensity.dense,
        selected: const <int>{0},
        onSelectionChanged: (_) {},
        segments: const <MorphSegment<int>>[
          MorphSegment<int>(value: 0, label: 'A'),
          MorphSegment<int>(value: 1, label: 'B'),
        ],
      ),
    ),
  );
  await tester.pumpAndSettle();

  final Size size = tester.getSize(find.byType(MorphSegmentedButton<int>));
  expect(size.height, 48);
}

Future<void> _singleSelectCannotClearTheSelectedSegment(
  WidgetTester tester,
) async {
  var selected = <int>{0};

  await tester.pumpWidget(
    _host(
      StatefulBuilder(
        builder: (context, setState) {
          return MorphSegmentedButton<int>(
            selected: selected,
            onSelectionChanged: (next) => setState(() => selected = next),
            segments: const <MorphSegment<int>>[
              MorphSegment<int>(value: 0, label: 'Day'),
              MorphSegment<int>(value: 1, label: 'Week'),
              MorphSegment<int>(value: 2, label: 'Month'),
            ],
          );
        },
      ),
    ),
  );
  await tester.pumpAndSettle();

  await tester.tap(find.text('Day').hitTestable().first);
  await tester.pumpAndSettle();
  expect(selected, <int>{0});

  await tester.tap(find.text('Week').hitTestable().first);
  await tester.pumpAndSettle();
  expect(selected, <int>{1});
}

Future<void> _multiSelectTogglesAndAllowsEmpty(WidgetTester tester) async {
  var selected = <int>{0};

  await tester.pumpWidget(
    _host(
      StatefulBuilder(
        builder: (context, setState) {
          return MorphSegmentedButton<int>(
            multiSelect: true,
            selected: selected,
            onSelectionChanged: (next) => setState(() => selected = next),
            segments: const <MorphSegment<int>>[
              MorphSegment<int>(value: 0, label: 'A'),
              MorphSegment<int>(value: 1, label: 'B'),
            ],
          );
        },
      ),
    ),
  );
  await tester.pumpAndSettle();

  await tester.tap(find.text('B').hitTestable().first);
  await tester.pumpAndSettle();
  expect(selected, <int>{0, 1});

  await tester.tap(find.text('A').hitTestable().first);
  await tester.pumpAndSettle();
  expect(selected, <int>{1});

  await tester.tap(find.text('B').hitTestable().first);
  await tester.pumpAndSettle();
  expect(selected, isEmpty);
}

Future<void> _disabledSegmentDoesNotChangeSelection(WidgetTester tester) async {
  var selected = <int>{0};

  await tester.pumpWidget(
    _host(
      StatefulBuilder(
        builder: (context, setState) {
          return MorphSegmentedButton<int>(
            selected: selected,
            onSelectionChanged: (next) => setState(() => selected = next),
            segments: const <MorphSegment<int>>[
              MorphSegment<int>(value: 0, label: 'On'),
              MorphSegment<int>(value: 1, label: 'Off', enabled: false),
            ],
          );
        },
      ),
    ),
  );
  await tester.pumpAndSettle();

  await tester.tap(find.text('Off').hitTestable().first);
  await tester.pumpAndSettle();
  expect(selected, <int>{0});
}

Future<void> _iconOnlySelectedShowsCheckInsteadOfCategoryIcon(
  WidgetTester tester,
) async {
  await tester.pumpWidget(
    _host(
      MorphSegmentedButton<int>(
        selected: const <int>{0},
        onSelectionChanged: (_) {},
        segments: const <MorphSegment<int>>[
          MorphSegment<int>(
            value: 0,
            icon: Icon(MorphIcons.home),
            semanticLabel: 'Home',
          ),
          MorphSegment<int>(
            value: 1,
            icon: Icon(MorphIcons.star),
            semanticLabel: 'Star',
          ),
        ],
      ),
    ),
  );
  await tester.pumpAndSettle();

  expect(find.byIcon(MorphIcons.check), findsOneWidget);
  expect(find.byIcon(MorphIcons.home), findsNothing);
  expect(find.byIcon(MorphIcons.star), findsOneWidget);
}

void _themeDensityHeightsMatchSpec() {
  const theme = MorphSegmentedButtonTheme.defaults;
  expect(theme.heightFor(MorphSegmentedButtonDensity.regular), 40);
  expect(theme.heightFor(MorphSegmentedButtonDensity.comfortable), 36);
  expect(theme.heightFor(MorphSegmentedButtonDensity.compact), 32);
  expect(theme.heightFor(MorphSegmentedButtonDensity.dense), 28);
  expect(theme.focusIndicatorWidth, 3);
  expect(theme.focusIndicatorGap, 2);
  expect(theme.targetSize, 48);
}

void _segmentCountAssertRejectsFewerThan2() {
  expect(
    () => MorphSegmentedButton<int>(
      selected: const <int>{},
      onSelectionChanged: (_) {},
      segments: const <MorphSegment<int>>[
        MorphSegment<int>(value: 0, label: 'A'),
      ],
    ),
    throwsAssertionError,
  );
}
