import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:morph_expressive/morph_components.dart';

void main() {
  testWidgets('dropdown stays visible during close and can reopen mid-exit', (
    tester,
  ) async {
    final controller = MorphDropdownController<String>();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MorphMaterialApp(
        data: MorphThemeData.light(),
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 320,
              child: MorphDropdownMenu<String>(
                controller: controller,
                singleSelect: true,
                fieldStyle: const MorphDropdownFieldStyle(
                  hintText: 'Choose framework',
                ),
                items: const [
                  MorphDropdownItem(label: 'Flutter', value: 'flutter'),
                  MorphDropdownItem(label: 'Dart', value: 'dart'),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    controller.setOpen(open: true);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('Dart'), findsOneWidget);

    controller.setOpen(open: false);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 60));
    expect(find.text('Dart'), findsOneWidget);

    // Reopening before the exit finishes must reuse the live overlay.
    controller.setOpen(open: true);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('Dart'), findsOneWidget);

    controller.setOpen(open: false);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 900));
    expect(find.text('Dart'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
