import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:morph_expressive/components/text_fields/components/morph_text_field_container_painter.dart';
import 'package:morph_expressive/morph_components.dart';

Widget _host(Widget child) {
  return MaterialApp(
    home: MorphTheme(
      data: MorphThemeData.light(),
      child: Scaffold(body: Center(child: child)),
    ),
  );
}

Finder _tooltip(String message) {
  return find.byWidgetPredicate(
    (Widget widget) => widget is MorphTooltip && widget.message == message,
  );
}

void main() {
  testWidgets('MorphCalendarDatePicker selects a day', _calendarSelectsDay);
  testWidgets(
    'MorphCalendarDatePicker respects firstDate and lastDate',
    _dateBounds,
  );
  testWidgets(
    'MorphCalendarDatePicker respects selectableDayPredicate',
    _predicate,
  );
  testWidgets('MorphDatePicker.show returns null on cancel', _dialogCancel);
  testWidgets('MorphDatePicker.show returns date on confirm', _dialogConfirm);
  testWidgets('MorphCalendarDatePicker year mode renders', _yearMode);
  testWidgets('MorphDatePicker.showRange selects a range', _rangeSelection);
  testWidgets(
    'MorphDatePickerTheme overrides layout without ThemeData',
    _themeOverride,
  );
  testWidgets(
    'MorphDatePickerDialog portrait layout has no overflow',
    _dialogLayout,
  );
  testWidgets(
    'MorphDatePickerDialog landscape calendar and input have no overflow',
    _landscapeDialogLayout,
  );
  testWidgets(
    'MorphCalendarDatePicker has no overflow paging into a 6-row month',
    _sixRowMonthPaging,
  );
  testWidgets(
    'filled date input shows errors without overflow',
    _filledDateInputValidation,
  );
  testWidgets(
    'filled date range input shows errors without overflow',
    _filledRangeInputValidation,
  );
  testWidgets(
    'compact input dialog remains scrollable',
    _compactDateInputLayout,
  );
  testWidgets(
    'range filled surfaces stay aligned in portrait',
    (tester) => _rangeSurfaceAlignment(tester, const Size(360, 640)),
  );
  testWidgets(
    'range filled surfaces stay aligned in landscape',
    (tester) => _rangeSurfaceAlignment(tester, const Size(800, 360)),
  );
}

Future<void> _calendarSelectsDay(WidgetTester tester) async {
  DateTime? selected;
  await tester.pumpWidget(
    _host(
      MorphCalendarDatePicker(
        firstDate: DateTime(2026),
        lastDate: DateTime(2026, 12, 31),
        currentDate: DateTime(2026, 3, 15),
        onDateChanged: (DateTime value) => selected = value,
      ),
    ),
  );
  await tester.pumpAndSettle();

  await tester.tap(find.text('15').first);
  await tester.pumpAndSettle();

  expect(selected, DateTime(2026, 3, 15));
}

Future<void> _dateBounds(WidgetTester tester) async {
  await tester.pumpWidget(
    _host(
      MorphCalendarDatePicker(
        firstDate: DateTime(2026, 3, 10),
        lastDate: DateTime(2026, 3, 20),
        currentDate: DateTime(2026, 3, 15),
        onDateChanged: (_) {},
      ),
    ),
  );
  await tester.pumpAndSettle();

  final Finder disabledDay = find.text('9');
  if (disabledDay.evaluate().isNotEmpty) {
    await tester.tap(disabledDay.first);
    await tester.pump();
  }
  expect(tester.takeException(), isNull);
}

Future<void> _predicate(WidgetTester tester) async {
  await tester.pumpWidget(
    _host(
      MorphCalendarDatePicker(
        firstDate: DateTime(2026, 3),
        lastDate: DateTime(2026, 3, 31),
        currentDate: DateTime(2026, 3, 15),
        selectableDayPredicate: (DateTime day) => day.day.isEven,
        onDateChanged: (_) {},
      ),
    ),
  );
  await tester.pumpAndSettle();
  expect(tester.takeException(), isNull);
}

Future<void> _dialogCancel(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(800, 900));
  addTearDown(() => tester.binding.setSurfaceSize(null));

  DateTime? result;
  await tester.pumpWidget(
    MaterialApp(
      home: MorphTheme(
        data: MorphThemeData.light(),
        child: Builder(
          builder: (BuildContext context) {
            return MorphButton(
              onPressed: () async {
                result = await MorphDatePicker.show(
                  context,
                  firstDate: DateTime(2026),
                  lastDate: DateTime(2027),
                );
              },
              child: const Text('open'),
            );
          },
        ),
      ),
    ),
  );

  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Cancel'));
  await tester.pumpAndSettle();

  expect(result, isNull);
}

Future<void> _dialogConfirm(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(800, 900));
  addTearDown(() => tester.binding.setSurfaceSize(null));

  DateTime? result;
  await tester.pumpWidget(
    MaterialApp(
      home: MorphTheme(
        data: MorphThemeData.light(),
        child: Builder(
          builder: (BuildContext context) {
            return MorphButton(
              onPressed: () async {
                result = await MorphDatePicker.show(
                  context,
                  initialDate: DateTime(2026, 3, 15),
                  firstDate: DateTime(2026),
                  lastDate: DateTime(2027),
                );
              },
              child: const Text('open'),
            );
          },
        ),
      ),
    ),
  );

  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('OK'));
  await tester.pumpAndSettle();

  expect(result, DateTime(2026, 3, 15));
}

Future<void> _yearMode(WidgetTester tester) async {
  await tester.pumpWidget(
    _host(
      MorphCalendarDatePicker(
        firstDate: DateTime(2020),
        lastDate: DateTime(2030),
        initialCalendarMode: MorphDatePickerMode.year,
        onDateChanged: (_) {},
      ),
    ),
  );
  await tester.pumpAndSettle();
  expect(tester.takeException(), isNull);
  expect(find.text('2026'), findsWidgets);
}

Future<void> _rangeSelection(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(800, 900));
  addTearDown(() => tester.binding.setSurfaceSize(null));

  MorphDateRange? result;
  await tester.pumpWidget(
    MaterialApp(
      home: MorphTheme(
        data: MorphThemeData.light(),
        child: Builder(
          builder: (BuildContext context) {
            return MorphButton(
              onPressed: () async {
                result = await MorphDatePicker.showRange(
                  context,
                  firstDate: DateTime(2026, 3),
                  lastDate: DateTime(2026, 3, 31),
                  currentDate: DateTime(2026, 3, 15),
                );
              },
              child: const Text('open range'),
            );
          },
        ),
      ),
    ),
  );

  await tester.tap(find.text('open range'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('10').first);
  await tester.pump();
  await tester.tap(find.text('20').first);
  await tester.pump();
  await tester.tap(find.text('OK'));
  await tester.pumpAndSettle();

  expect(result?.start, DateTime(2026, 3, 10));
  expect(result?.end, DateTime(2026, 3, 20));
}

Future<void> _themeOverride(WidgetTester tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: MorphTheme(
        data: MorphThemeData.light().copyWith(
          datePickerTheme: const MorphDatePickerTheme(daySize: 36),
        ),
        child: MorphCalendarDatePicker(
          firstDate: DateTime(2026),
          lastDate: DateTime(2027),
          onDateChanged: (_) {},
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  expect(tester.takeException(), isNull);
}

Future<void> _dialogLayout(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(800, 900));
  addTearDown(() => tester.binding.setSurfaceSize(null));

  await tester.pumpWidget(
    MaterialApp(
      home: MorphTheme(
        data: MorphThemeData.light(),
        child: Builder(
          builder: (BuildContext context) {
            return MorphButton(
              onPressed: () {
                MorphDatePicker.show(
                  context,
                  initialDate: DateTime(2026, 3, 15),
                  firstDate: DateTime(2026),
                  lastDate: DateTime(2027),
                );
              },
              child: const Text('open'),
            );
          },
        ),
      ),
    ),
  );

  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
  expect(tester.takeException(), isNull);
}

Future<void> _landscapeDialogLayout(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(1200, 800));
  addTearDown(() => tester.binding.setSurfaceSize(null));

  await tester.pumpWidget(
    MaterialApp(
      home: MorphTheme(
        data: MorphThemeData.light(),
        child: Builder(
          builder: (BuildContext context) {
            return MorphButton(
              onPressed: () {
                MorphDatePicker.show(
                  context,
                  initialDate: DateTime(2026, 8, 27),
                  firstDate: DateTime(2026),
                  lastDate: DateTime(2027),
                  helpText: 'Select date (calendar dialog)',
                );
              },
              child: const Text('open'),
            );
          },
        ),
      ),
    ),
  );

  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
  expect(tester.takeException(), isNull);
  expect(find.text('Select date (calendar dialog)'), findsOneWidget);

  final Size headerSize = tester.getSize(find.byType(MorphDatePickerHeader));
  expect(headerSize.width, closeTo(152, 1));
  expect(tester.takeException(), isNull);

  await tester.tap(_tooltip('Switch to input'));
  await tester.pumpAndSettle();
  // The focused filled field reserves room above the surface for its label.
  expect(find.byType(MorphTextField), findsOneWidget);
  expect(tester.takeException(), isNull);
  expect(find.byType(MorphDatePickerHeader), findsOneWidget);
}

Future<void> _sixRowMonthPaging(WidgetTester tester) async {
  // July 2026 has 5 week rows and August 2026 has 6 (Sunday-first).
  await tester.pumpWidget(
    _host(
      MorphCalendarDatePicker(
        firstDate: DateTime(2026),
        lastDate: DateTime(2026, 12, 31),
        initialDate: DateTime(2026, 7, 15),
        currentDate: DateTime(2026, 7, 15),
        onDateChanged: (_) {},
      ),
    ),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.bySemanticsLabel('Next month'));
  // Check every frame of the page animation.
  for (var i = 0; i < 12; i++) {
    await tester.pump(const Duration(milliseconds: 20));
    expect(tester.takeException(), isNull);
  }
  await tester.pumpAndSettle();
  expect(tester.takeException(), isNull);
  expect(find.text('August 2026'), findsWidgets);
}

Future<void> _filledDateInputValidation(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(360, 640));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    _host(
      MorphDatePickerDialog(
        firstDate: DateTime(2026),
        lastDate: DateTime(2027),
        initialEntryMode: MorphDatePickerEntryMode.inputOnly,
      ),
    ),
  );
  await tester.pumpAndSettle();
  expect(find.byType(MorphTextField), findsOneWidget);
  await tester.tap(find.text('OK'));
  await tester.pumpAndSettle();
  expect(tester.takeException(), isNull);
  // The input retains its validation message rather than clipping it.
  expect(
    tester.widget<MorphTextField>(find.byType(MorphTextField)).errorText,
    isNotNull,
  );
  expect(find.text('Cancel'), findsOneWidget);
}

Future<void> _filledRangeInputValidation(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(800, 360));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    _host(
      MorphDateRangePickerDialog(
        firstDate: DateTime(2026),
        lastDate: DateTime(2027),
        initialEntryMode: MorphDatePickerEntryMode.inputOnly,
      ),
    ),
  );
  await tester.pumpAndSettle();
  expect(find.byType(MorphTextField), findsNWidgets(2));
  await tester.tap(find.text('OK'));
  await tester.pumpAndSettle();
  expect(tester.takeException(), isNull);
  for (final field in tester.widgetList<MorphTextField>(
    find.byType(MorphTextField),
  )) {
    expect(field.errorText, isNotNull);
  }
  expect(find.text('Cancel'), findsOneWidget);
}

Future<void> _compactDateInputLayout(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(360, 260));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    _host(
      MorphDatePickerDialog(
        firstDate: DateTime(2026),
        lastDate: DateTime(2027),
        initialEntryMode: MorphDatePickerEntryMode.inputOnly,
      ),
    ),
  );
  await tester.pumpAndSettle();
  expect(tester.takeException(), isNull);
  expect(find.byType(MorphTextField), findsOneWidget);
  await tester.ensureVisible(find.text('OK'));
  await tester.pumpAndSettle();
  expect(tester.takeException(), isNull);
  await tester.tap(find.text('OK'));
  await tester.pumpAndSettle();
  expect(tester.takeException(), isNull);
}

/// Returns the painted surface rather than the outer field wrapper: filled
/// labels used to add a state-dependent top inset before the CustomPaint.
Rect _rangePaintedSurface(WidgetTester tester, int index) {
  final Finder surface = find.descendant(
    of: find.byType(MorphTextField).at(index),
    matching: find.byWidgetPredicate(
      (widget) =>
          widget is CustomPaint &&
          widget.painter is MorphTextFieldContainerPainter,
    ),
  );
  expect(surface, findsOneWidget);
  return tester.getRect(surface);
}

void _expectRangeSurfacesAligned(WidgetTester tester) {
  expect(find.byType(MorphTextField), findsNWidgets(2));
  final Rect start = _rangePaintedSurface(tester, 0);
  final Rect end = _rangePaintedSurface(tester, 1);
  expect(start.top, closeTo(end.top, 0.5));
}

Future<void> _rangeSurfaceAlignment(WidgetTester tester, Size surface) async {
  await tester.binding.setSurfaceSize(surface);
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    _host(
      MorphDateRangePickerDialog(
        firstDate: DateTime(2026),
        lastDate: DateTime(2027),
        initialEntryMode: MorphDatePickerEntryMode.inputOnly,
      ),
    ),
  );
  await tester.pumpAndSettle();
  // Start focused automatically, End still empty: both surfaces align.
  _expectRangeSurfacesAligned(tester);
  expect(tester.takeException(), isNull);

  await tester.tap(find.byType(MorphTextField).at(1));
  await tester.pumpAndSettle();
  _expectRangeSurfacesAligned(tester);
  expect(tester.takeException(), isNull);

  await tester.enterText(find.byType(EditableText).at(1), '12/15/2026');
  await tester.pumpAndSettle();
  _expectRangeSurfacesAligned(tester);
  expect(tester.takeException(), isNull);

  // Only Start is invalid. Error supporting text must not lift either surface.
  await tester.ensureVisible(find.text('OK'));
  await tester.tap(find.text('OK'));
  await tester.pumpAndSettle();
  expect(
    tester.widget<MorphTextField>(find.byType(MorphTextField).first).errorText,
    isNotNull,
  );
  _expectRangeSurfacesAligned(tester);
  expect(tester.takeException(), isNull);
  expect(find.text('Cancel'), findsOneWidget);
}
