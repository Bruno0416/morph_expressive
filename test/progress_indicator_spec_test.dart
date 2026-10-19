import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morph_expressive/components/progress_indicators/components/morph_linear_progress_painter.dart';
import 'package:morph_expressive/morph_components.dart';
import 'package:material_ui/material_ui.dart';

Widget _host(Widget child, {TextDirection textDirection = TextDirection.ltr}) {
  return MaterialApp(
    home: Directionality(
      textDirection: textDirection,
      child: MorphTheme(
        data: MorphThemeData.light(),
        child: Scaffold(
          body: Center(child: SizedBox(width: 200, child: child)),
        ),
      ),
    ),
  );
}

MorphLinearProgressPainter _linearPainter(WidgetTester tester) {
  final CustomPaint paint = tester.widget(
    find.descendant(
      of: find.byType(MorphProgressIndicator),
      matching: find.byType(CustomPaint),
    ),
  );
  return paint.painter! as MorphLinearProgressPainter;
}

void main() {
  _registerProgressThemeTests();
  _registerProgressSemanticsTests();
  _registerProgressPainterTests();
}

void _registerProgressThemeTests() {
  test('circular gap defaults to 4', _circularGapDefaultsTo4);
  test('linear trailingMargin is 4 for both sizes', _linearTrailingMarginIs4);
  test(
    'linear trackColor is secondaryContainer',
    _linearTrackColorIsSecondaryContainer,
  );
  testWidgets(
    'linear uses secondaryContainer track by default',
    _linearUsesSecondaryContainerTrackByDefault,
  );
}

void _registerProgressSemanticsTests() {
  testWidgets('exposes progressBar semantics', _exposesProgressBarSemantics);
  testWidgets(
    'indeterminate semantics use 0% and optional hint',
    _indeterminateSemanticsUse0AndOptionalHint,
  );
}

void _registerProgressPainterTests() {
  testWidgets(
    'RTL passes textDirection to linear painter',
    _rtlPassesTextDirectionToLinearPainter,
  );
  testWidgets(
    'showTrack false is passed to linear painter',
    _showTrackFalseIsPassedToLinearPainter,
  );
  testWidgets(
    'determinate linear draws with a stop size',
    _determinateLinearDrawsWithAStopSize,
  );
  testWidgets(
    'indeterminate linear has null value (no stop path)',
    _indeterminateLinearHasNullValue,
  );
}

void _circularGapDefaultsTo4() {
  expect(MorphCircularProgressTheme.defaults.gapSize, 4);
  expect(MorphLinearProgressTheme.defaults.gapSize, 4);
}

void _linearTrailingMarginIs4() {
  const theme = MorphLinearProgressTheme.defaults;
  expect(theme.resolveFlat(MorphProgressIndicatorSize.s).trailingMargin, 4);
  expect(theme.resolveFlat(MorphProgressIndicatorSize.m).trailingMargin, 4);
}

void _linearTrackColorIsSecondaryContainer() {
  final scheme = MorphThemeData.light().colorScheme;
  expect(
    MorphLinearProgressTheme.defaults.trackColor(scheme),
    scheme.secondaryContainer,
  );
}

Future<void> _linearUsesSecondaryContainerTrackByDefault(
  WidgetTester tester,
) async {
  await tester.pumpWidget(
    _host(const MorphProgressIndicator.linear(value: 0.5)),
  );
  final scheme = MorphThemeData.light().colorScheme;
  expect(_linearPainter(tester).track, scheme.secondaryContainer);
}

Future<void> _exposesProgressBarSemantics(WidgetTester tester) async {
  await tester.pumpWidget(
    _host(
      const MorphProgressIndicator.circular(
        value: 0.6,
        semanticsLabel: 'Upload',
      ),
    ),
  );

  final semantics = tester.getSemantics(find.byType(MorphProgressIndicator));
  expect(semantics.label, 'Upload');
  expect(semantics.role, SemanticsRole.progressBar);
  expect(semantics.value, '60%');
}

Future<void> _indeterminateSemanticsUse0AndOptionalHint(
  WidgetTester tester,
) async {
  await tester.pumpWidget(
    _host(
      const MorphProgressIndicator.linear(
        semanticsLabel: 'Loading',
        semanticsValue: 'In progress',
      ),
    ),
  );

  final semantics = tester.getSemantics(find.byType(MorphProgressIndicator));
  expect(semantics.role, SemanticsRole.progressBar);
  expect(semantics.value, '0%');
  expect(semantics.hint, 'In progress');
}

Future<void> _rtlPassesTextDirectionToLinearPainter(WidgetTester tester) async {
  await tester.pumpWidget(
    _host(
      const MorphProgressIndicator.linear(value: 0.4),
      textDirection: TextDirection.rtl,
    ),
  );
  expect(_linearPainter(tester).textDirection, TextDirection.rtl);
}

Future<void> _showTrackFalseIsPassedToLinearPainter(WidgetTester tester) async {
  await tester.pumpWidget(
    _host(const MorphProgressIndicator.linear(value: 0.5, showTrack: false)),
  );
  expect(_linearPainter(tester).showTrack, isFalse);
}

Future<void> _determinateLinearDrawsWithAStopSize(WidgetTester tester) async {
  await tester.pumpWidget(
    _host(const MorphProgressIndicator.linear(value: 0.5)),
  );
  final painter = _linearPainter(tester);
  expect(painter.value, 0.5);
  expect(painter.stopSize, greaterThan(0));
}

Future<void> _indeterminateLinearHasNullValue(WidgetTester tester) async {
  await tester.pumpWidget(_host(const MorphProgressIndicator.linear()));
  expect(_linearPainter(tester).value, isNull);
}
