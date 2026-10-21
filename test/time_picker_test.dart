import 'package:flutter_test/flutter_test.dart';
import 'package:morph_expressive/morph_components.dart';
import 'package:material_ui/material_ui.dart'
    show
        BuildContext,
        Builder,
        Center,
        CustomPaint,
        EdgeInsets,
        MaterialApp,
        Padding,
        Scaffold,
        Size,
        Text,
        Widget;

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
  testWidgets(
    'MorphDialTimePicker scales down without overflow on narrow width',
    _dialLayout,
  );
  testWidgets('MorphDialTimePicker toggles AM and PM', _periodToggle);
  testWidgets('MorphTimePicker.show returns null on cancel', _dialogCancel);
  testWidgets('MorphTimePicker.show returns time on confirm', _dialogConfirm);
  testWidgets(
    'MorphTimePickerTheme overrides layout without ThemeData',
    _themeOverride,
  );
  testWidgets(
    'MorphTimePickerDialog portrait layout has no overflow',
    _dialogLayout,
  );
  testWidgets(
    'MorphTimePickerDialog landscape dial keeps full dial size',
    _landscapeDialLayout,
  );
  testWidgets(
    'MorphTimePicker toggles to input mode without error',
    _inputModeToggle,
  );
  test('MorphTimePickerUtils clamps and parses input time', _utils);
}

Future<void> _dialLayout(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(320, 640));
  addTearDown(() => tester.binding.setSurfaceSize(null));

  await tester.pumpWidget(
    MaterialApp(
      home: MorphTheme(
        data: MorphThemeData.light(),
        child: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(24),
            child: MorphDialTimePicker(
              value: const MorphTime(hour: 9, minute: 30),
              onChanged: (_) {},
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();

  expect(tester.takeException(), isNull);
}

Future<void> _periodToggle(WidgetTester tester) async {
  MorphTime? selected;
  await tester.pumpWidget(
    _host(
      MorphDialTimePicker(
        value: const MorphTime(hour: 9, minute: 30),
        onChanged: (MorphTime value) => selected = value,
      ),
    ),
  );
  await tester.pumpAndSettle();

  await tester.tap(find.text('PM').first);
  await tester.pumpAndSettle();

  expect(selected?.hour, 21);
}

Future<void> _dialogCancel(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(800, 900));
  addTearDown(() => tester.binding.setSurfaceSize(null));

  MorphTime? result;
  await tester.pumpWidget(
    MaterialApp(
      home: MorphTheme(
        data: MorphThemeData.light(),
        child: Builder(
          builder: (BuildContext context) {
            return MorphButton(
              onPressed: () async {
                result = await MorphTimePicker.show(
                  context,
                  initialTime: const MorphTime(hour: 9, minute: 30),
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

  MorphTime? result;
  await tester.pumpWidget(
    MaterialApp(
      home: MorphTheme(
        data: MorphThemeData.light(),
        child: Builder(
          builder: (BuildContext context) {
            return MorphButton(
              onPressed: () async {
                result = await MorphTimePicker.show(
                  context,
                  initialTime: const MorphTime(hour: 9, minute: 30),
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

  expect(result, const MorphTime(hour: 9, minute: 30));
}

Future<void> _themeOverride(WidgetTester tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: MorphTheme(
        data: MorphThemeData.light().copyWith(
          timePickerTheme: const MorphTimePickerTheme(dialSize: 200),
        ),
        child: MorphDialTimePicker(
          value: const MorphTime(hour: 9, minute: 30),
          onChanged: (_) {},
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
                MorphTimePicker.show(
                  context,
                  initialTime: const MorphTime(hour: 9, minute: 30),
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

Future<void> _landscapeDialLayout(WidgetTester tester) async {
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
                MorphTimePicker.show(
                  context,
                  initialTime: const MorphTime(hour: 11, minute: 42),
                  helpText: 'Select time (dial dialog)',
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

  final Size dialSize = tester.getSize(
    find.descendant(
      of: find.byType(MorphDialTimePicker),
      matching: find.byType(CustomPaint),
    ),
  );
  // material_ui landscape budget is tight (216 + 64 + 256 vs 524); dial stays
  // near full size without FittedBox scale-down of the whole column.
  expect(dialSize.shortestSide, greaterThanOrEqualTo(240));
  expect(dialSize.width, closeTo(dialSize.height, 1));
  expect(find.text('Select time (dial dialog)'), findsOneWidget);
  expect(find.text('AM'), findsOneWidget);
}

Future<void> _inputModeToggle(WidgetTester tester) async {
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
                MorphTimePicker.show(
                  context,
                  initialTime: const MorphTime(hour: 9, minute: 30),
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
  await tester.tap(_tooltip('Switch to text input mode'));
  await tester.pumpAndSettle();

  expect(tester.takeException(), isNull);
  expect(find.text('Hour'), findsOneWidget);
  expect(find.text('Minute'), findsOneWidget);
}

void _utils() {
  expect(
    MorphTimePickerUtils.clampRaw(hour: 25, minute: 70),
    const MorphTime(hour: 23, minute: 59),
  );
  expect(
    MorphTimePickerUtils.parseInputTime(
      hourText: '09',
      minuteText: '30',
      use24HourFormat: false,
      isPm: false,
    ),
    const MorphTime(hour: 9, minute: 30),
  );
  expect(MorphTimePickerUtils.to24Hour(12, pm: true), 12);
}
