import 'package:flutter_test/flutter_test.dart';
import 'package:morph_expressive/morph_components.dart';
import 'package:material_ui/material_ui.dart';

Widget _host(Widget child) {
  return MorphMaterialApp(
    data: MorphThemeData.light(seedColor: const Color(0xFF6750A4)),
    home: Scaffold(body: Center(child: child)),
  );
}

EdgeInsets _padding(WidgetTester tester) {
  final padding = tester.widget<Padding>(
    find.descendant(
      of: find.byType(MorphDivider),
      matching: find.byType(Padding),
    ),
  );
  return padding.padding.resolve(TextDirection.ltr);
}

void main() {
  _registerDividerThemeTests();
  _registerDividerLayoutTests();
}

void _registerDividerThemeTests() {
  test(
    'theme defaults match the divider spec',
    _themeDefaultsMatchTheDividerSpec,
  );
}

void _registerDividerLayoutTests() {
  testWidgets(
    'default line is 1dp, full-bleed, and outline variant',
    _defaultLineIs1dpFullBleedAndOutlineVariant,
  );
  testWidgets(
    'inset is 16 leading and middle is 16 on both sides',
    _insetIs16LeadingAndMiddleIs16OnBothSides,
  );
  testWidgets(
    'outer margin is off until enabled',
    _outerMarginIsOffUntilEnabled,
  );
  testWidgets(
    'vertical line is 1dp wide and fills a bounded height',
    _verticalLineIs1dpWideAndFillsABoundedHeight,
  );
}

void _themeDefaultsMatchTheDividerSpec() {
  const theme = MorphDividerTheme.defaults;
  final scheme = MorphThemeData.light(seedColor: const Color(0xFF6750A4))
      .colorScheme;

  expect(theme.thickness, 1);
  expect(theme.insetStart, 16);
  expect(theme.insetEnd, 0);
  expect(theme.middleInsetStart, 16);
  expect(theme.middleInsetEnd, 16);
  expect(theme.textGap, 4);
  expect(theme.endMargin, 8);
  expect(theme.bottomMargin, 8);
  expect(theme.color(scheme), scheme.outlineVariant);
  expect(theme.startFor(MorphDividerInset.full), 0);
  expect(theme.endFor(MorphDividerInset.inset), 0);
  expect(theme.startFor(MorphDividerInset.middle), 16);
}

Future<void> _defaultLineIs1dpFullBleedAndOutlineVariant(
  WidgetTester tester,
) async {
  final scheme = MorphThemeData.light(seedColor: const Color(0xFF6750A4))
      .colorScheme;
  await tester.pumpWidget(
    _host(const SizedBox(width: 200, child: MorphDivider())),
  );

  final line = tester.widget<SizedBox>(
    find.descendant(
      of: find.byType(MorphDivider),
      matching: find.byType(SizedBox),
    ),
  );
  expect(line.height, 1);
  expect(tester.getSize(find.byType(MorphDivider)), const Size(200, 1));
  expect(_padding(tester), EdgeInsets.zero);
  expect(
    tester
        .widget<ColoredBox>(
          find.descendant(
            of: find.byType(MorphDivider),
            matching: find.byType(ColoredBox),
          ),
        )
        .color,
    scheme.outlineVariant,
  );
  expect(
    find.descendant(
      of: find.byType(MorphDivider),
      matching: find.byType(ExcludeSemantics),
    ),
    findsOneWidget,
  );
}

Future<void> _insetIs16LeadingAndMiddleIs16OnBothSides(
  WidgetTester tester,
) async {
  await tester.pumpWidget(
    _host(
      const SizedBox(
        width: 200,
        child: MorphDivider(inset: MorphDividerInset.inset),
      ),
    ),
  );
  expect(_padding(tester), const EdgeInsets.only(left: 16));

  await tester.pumpWidget(
    _host(
      const SizedBox(
        width: 200,
        child: MorphDivider(inset: MorphDividerInset.middle),
      ),
    ),
  );
  expect(_padding(tester), const EdgeInsets.only(left: 16, right: 16));
}

Future<void> _outerMarginIsOffUntilEnabled(WidgetTester tester) async {
  await tester.pumpWidget(
    _host(const SizedBox(width: 200, child: MorphDivider())),
  );
  expect(_padding(tester).bottom, 0);
  expect(_padding(tester).right, 0);

  await tester.pumpWidget(
    _host(const SizedBox(width: 200, child: MorphDivider(outerMargin: true))),
  );
  expect(_padding(tester), const EdgeInsets.only(right: 8, bottom: 8));
}

Future<void> _verticalLineIs1dpWideAndFillsABoundedHeight(
  WidgetTester tester,
) async {
  await tester.pumpWidget(
    _host(
      const SizedBox(
        height: 48,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[MorphDivider(axis: MorphDividerAxis.vertical)],
        ),
      ),
    ),
  );

  expect(tester.getSize(find.byType(MorphDivider)), const Size(1, 48));
}
