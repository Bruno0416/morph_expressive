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
  _registerSplitThemeTests();
  _registerSplitLayoutTests();
  _registerSplitNavigationTests();
}

void _registerSplitThemeTests() {
  test('pressed inner radii match hovered', _pressedInnerRadiiMatchHovered);
  test(
    'gap is always 2dp including elevated',
    _gapIsAlways2dpIncludingElevated,
  );
  test('small leading icon is 20dp', _smallLeadingIconIs20dp);
  test('optical vs centered trailing pads', _opticalVsCenteredTrailingPads);
  test('chevron open turns is 180 degrees', _chevronOpenTurnsIs180Degrees);
}

void _registerSplitLayoutTests() {
  testWidgets(
    'xs layout height meets 48dp tap target',
    _xsLayoutHeightMeets48dpTapTarget,
  );
  testWidgets(
    'trailing semantics expose More options',
    _trailingSemanticsExposeMoreOptions,
  );
}

void _registerSplitNavigationTests() {
  testWidgets(
    'system back closes the popup menu before the route',
    _systemBackClosesThePopupMenuBeforeTheRoute,
  );
}

void _pressedInnerRadiiMatchHovered() {
  const theme = MorphSplitButtonTheme.defaults;
  const sizes = <MorphButtonSize>[
    MorphButtonSize.xs,
    MorphButtonSize.sm,
    MorphButtonSize.md,
    MorphButtonSize.lg,
    MorphButtonSize.xl,
  ];
  for (final size in sizes) {
    expect(
      theme.splitPressedRadius(size),
      theme.splitHoveredInnerCornerRadius(size),
      reason: size.name,
    );
  }
}

void _gapIsAlways2dpIncludingElevated() {
  const theme = MorphSplitButtonTheme.defaults;
  expect(theme.innerGap, 2);
  expect(theme.elevatedInnerGap, 2);
}

void _smallLeadingIconIs20dp() {
  const theme = MorphSplitButtonTheme.defaults;
  expect(theme.splitIcon(MorphButtonSize.sm), 20);
  expect(theme.splitLeadingIconBlockWidth(MorphButtonSize.sm), 20);
}

void _opticalVsCenteredTrailingPads() {
  const theme = MorphSplitButtonTheme.defaults;
  expect(theme.splitTrailingOpticalLeading(MorphButtonSize.xs), 12);
  expect(theme.splitTrailingOpticalTrailing(MorphButtonSize.xs), 14);
  expect(theme.splitTrailingOpticalLeading(MorphButtonSize.md), 13);
  expect(theme.splitTrailingOpticalTrailing(MorphButtonSize.md), 17);
  expect(theme.splitTrailingButtonLeadingSpace(MorphButtonSize.md), 15);
  expect(theme.splitTrailingButtonTrailingSpace(MorphButtonSize.md), 15);
  expect(theme.splitSidePaddingSelected(MorphButtonSize.xl), 43);
  expect(theme.splitMenuIconOffset(MorphButtonSize.xl), -6);
}

void _chevronOpenTurnsIs180Degrees() {
  expect(MorphSplitButtonTheme.defaults.chevronOpenTurns, 0.5);
}

Future<void> _xsLayoutHeightMeets48dpTapTarget(WidgetTester tester) async {
  await tester.pumpWidget(
    _host(
      MorphSplitButton<String>(
        size: MorphButtonSize.xs,
        label: 'Edit',
        onPressed: () {},
        onSelected: (_) {},
        items: const <MorphSplitButtonItem<String>>[
          MorphSplitButtonItem(value: 'a', child: Text('A')),
          MorphSplitButtonItem(value: 'b', child: Text('B')),
        ],
      ),
    ),
  );
  await tester.pumpAndSettle();
  final Size size = tester.getSize(find.byType(MorphSplitButton<String>));
  expect(size.height, greaterThanOrEqualTo(48));
}

Future<void> _trailingSemanticsExposeMoreOptions(WidgetTester tester) async {
  await tester.pumpWidget(
    _host(
      MorphSplitButton<String>(
        label: 'Save',
        onPressed: () {},
        onSelected: (_) {},
        items: const <MorphSplitButtonItem<String>>[
          MorphSplitButtonItem(value: 'a', child: Text('A')),
        ],
      ),
    ),
  );
  await tester.pumpAndSettle();
  expect(find.bySemanticsLabel('More options'), findsOneWidget);
}

Future<void> _systemBackClosesThePopupMenuBeforeTheRoute(
  WidgetTester tester,
) async {
  await tester.pumpWidget(_systemBackApp());
  await tester.tap(find.text('Root'));
  await tester.pumpAndSettle();

  await tester.tap(find.byIcon(MorphIcons.keyboard_arrow_down));
  await tester.pump();
  await tester.pumpAndSettle(const Duration(milliseconds: 50));
  expect(find.byType(MorphMenuPopup<String>), findsOneWidget);
  expect(find.text('Archive'), findsOneWidget);

  await tester.binding.handlePopRoute();
  await tester.pump();
  await tester.pumpAndSettle(const Duration(milliseconds: 50));

  expect(find.byType(MorphMenuPopup<String>), findsNothing);
  expect(find.text('Save'), findsOneWidget);

  await tester.binding.handlePopRoute();
  await tester.pumpAndSettle();

  expect(find.text('Save'), findsNothing);
  expect(find.text('Root'), findsOneWidget);
}

Widget _systemBackApp() {
  return MaterialApp(
    home: Builder(
      builder: (BuildContext context) {
        return MorphTheme(
          data: MorphThemeData.light(),
          child: Scaffold(
            body: TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) {
                      return _systemBackRoute();
                    },
                  ),
                );
              },
              child: const Text('Root'),
            ),
          ),
        );
      },
    ),
  );
}

Widget _systemBackRoute() {
  return MorphTheme(
    data: MorphThemeData.light(),
    child: Scaffold(
      body: Align(
        alignment: Alignment.topCenter,
        child: SizedBox(
          height: 48,
          child: MorphSplitButton<String>(
            label: 'Save',
            onPressed: () {},
            onSelected: (_) {},
            items: const <MorphSplitButtonItem<String>>[
              MorphSplitButtonItem(value: 'a', child: Text('Archive')),
            ],
          ),
        ),
      ),
    ),
  );
}
