import 'package:flutter_test/flutter_test.dart';
import 'package:morph_expressive/morph_components.dart';
import 'package:material_ui/material_ui.dart';

Widget _host({required Widget child}) {
  return Directionality(
    textDirection: TextDirection.ltr,
    child: MediaQuery(
      data: const MediaQueryData(),
      child: MorphTheme(
        data: MorphThemeData.light(seedColor: const Color(0xFF6750A4)),
        child: Center(child: child),
      ),
    ),
  );
}

void main() {
  testWidgets('MorphRadio label tap selects value', (
    WidgetTester tester,
  ) async {
    String? plan = 'standard';

    await tester.pumpWidget(
      _host(
        child: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                MorphRadio<String>(
                  value: 'standard',
                  groupValue: plan,
                  label: const Text('standard'),
                  onChanged: (String value) => setState(() => plan = value),
                ),
                MorphRadio<String>(
                  value: 'pro',
                  groupValue: plan,
                  label: const Text('pro'),
                  onChanged: (String value) => setState(() => plan = value),
                ),
              ],
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('pro'));
    await tester.pumpAndSettle();
    expect(plan, 'pro');

    await tester.tap(find.text('standard'));
    await tester.pumpAndSettle();
    expect(plan, 'standard');
  });
}
