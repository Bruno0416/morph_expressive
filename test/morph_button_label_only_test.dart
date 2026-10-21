import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart' show MaterialApp, Scaffold, Text;
import 'package:morph_expressive/morph_expressive.dart';

void main() {
  testWidgets('label-only buttons retain their visible content', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MorphTheme(
          data: MorphThemeData.light(),
          child: Scaffold(
            body: MorphButton(
              label: const Text('Visible label'),
              onPressed: () {},
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    expect(find.text('Visible label'), findsOneWidget);
  });
}
