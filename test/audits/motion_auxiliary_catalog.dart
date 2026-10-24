import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart' show Scaffold;
import 'package:morph_expressive/morph_expressive.dart';

/// Complements the gallery and interaction suites with less common public
/// component classes, not just their more frequently used parent widgets.
void _mount(String name, Widget Function(WidgetTester tester) create) {
  testWidgets('motion catalog auxiliary: $name', (tester) async {
    tester.view.physicalSize = const Size(1000, 1100);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final child = create(tester);
    await tester.pumpWidget(
      MorphMaterialApp(
        data: MorphThemeData.light(seedColor: const Color(0xFF6750A4)),
        home: Scaffold(
          body: Center(child: SizedBox(width: 650, height: 950, child: child)),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 160));
    expect(
      find.byWidgetPredicate(
        (widget) => widget.runtimeType.toString().split('<').first == name,
      ),
      findsWidgets,
    );
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(tester.binding.transientCallbackCount, 0);
  });
}

void main() {
  final first = DateTime(2025);
  final last = DateTime(2027, 12, 31);
  final selected = DateTime(2026, 10, 22);
  _mount(
    'MorphBottomSheet',
    (_) => const MorphBottomSheet.standard(child: Text('Sheet')),
  );
  _mount(
    'MorphCalendarDateRangePicker',
    (_) => MorphCalendarDateRangePicker(
      firstDate: first,
      lastDate: last,
      initialStartDate: selected,
      currentDate: selected,
      onStartDateChanged: (_) {},
    ),
  );
  _mount(
    'MorphDatePickerDialog',
    (_) => MorphDatePickerDialog(
      firstDate: first,
      lastDate: last,
      initialDate: selected,
      currentDate: selected,
    ),
  );
  _mount(
    'MorphDateRangePickerDialog',
    (_) => MorphDateRangePickerDialog(
      firstDate: first,
      lastDate: last,
      initialStartDate: selected,
      currentDate: selected,
    ),
  );
  _mount(
    'MorphDatePickerActions',
    (_) => MorphDatePickerActions(
      onCancel: () {},
      onConfirm: () {},
      cancelText: 'Cancel',
      confirmText: 'Confirm',
    ),
  );
  _mount(
    'MorphDatePickerHeader',
    (_) => const MorphDatePickerHeader(
      helpText: 'Date',
      titleText: 'October 22',
      showTitle: true,
      orientation: Orientation.portrait,
    ),
  );
  _mount(
    'MorphDatePickerEntryModeButton',
    (_) => MorphDatePickerEntryModeButton(
      icon: MorphIcons.edit,
      tooltip: 'Input',
      onPressed: () {},
    ),
  );
  _mount(
    'MorphInputDatePickerFormField',
    (_) => MorphInputDatePickerFormField(
      firstDate: first,
      lastDate: last,
      initialDate: selected,
    ),
  );
  _mount(
    'MorphInputDateRangePickerFormField',
    (_) => MorphInputDateRangePickerFormField(
      firstDate: first,
      lastDate: last,
      initialStartDate: selected,
    ),
  );
  _mount(
    'MorphYearPicker',
    (_) => MorphYearPicker(
      selectedDate: selected,
      firstDate: first,
      lastDate: last,
      onChanged: (_) {},
    ),
  );
  _mount('MorphListAvatar', (_) => const MorphListAvatar(label: 'ME'));
  _mount(
    'MorphListImage',
    (_) => const MorphListImage(child: ColoredBox(color: Color(0xFF6750A4))),
  );
  _mount(
    'MorphListVideo',
    (_) => const MorphListVideo(child: ColoredBox(color: Color(0xFF6750A4))),
  );
  _mount(
    'MorphSelectionLeading',
    (_) => const MorphSelectionLeading(
      selected: true,
      selectedChild: SizedBox(
        width: 24,
        height: 24,
        child: ColoredBox(color: Color(0xFF6750A4)),
      ),
      child: Text('A'),
    ),
  );
  _mount(
    'MorphTimePickerDialogContent',
    (_) => const MorphTimePickerDialogContent(
      isInputMode: true,
      child: Text('Time'),
    ),
  );
  _mount(
    'MorphTimePickerHeader',
    (_) => const MorphTimePickerHeader(
      helpText: 'Time',
      titleText: '09:30',
      showTitle: true,
      orientation: Orientation.portrait,
    ),
  );
  _mount('MorphToolbarScrollWrapper', (tester) {
    final controller = MorphToolbarVisibilityController();
    addTearDown(controller.dispose);
    return MorphToolbarScrollWrapper(
      behavior: MorphToolbarScrollBehavior(controller: controller),
      child: ListView(children: const [Text('Scroll content')]),
    );
  });
}
