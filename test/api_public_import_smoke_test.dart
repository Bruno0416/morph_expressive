// Imports ONLY the public entrypoint: the redesigned API must be reachable
// from `package:morph_expressive/morph_expressive.dart` alone.
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morph_expressive/morph_expressive.dart';

Widget _host(Widget child) => MorphMaterialApp(
  data: MorphThemeData.light(),
  home: Center(child: child),
);

void main() {
  testWidgets('type, role and finish compile and mount from one import', (
    tester,
  ) async {
    int taps = 0;
    await tester.pumpWidget(
      _host(
        Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            MorphButton.outlined(
              variant: .primary,
              surface: .frosted,
              onPressed: () => taps++,
              child: const Text('Outlined'),
            ),
            MorphIconButton.filled(
              variant: .danger,
              icon: const Icon(MorphIcons.add),
              onPressed: () {},
            ),
            const MorphCard.filled(
              variant: .muted,
              headline: 'Card',
              supportingText: 'Muted filled card',
            ),
            MorphTextField.outlined(label: 'Name', onChanged: (_) {}),
            MorphChip.assist(label: 'Assist', onPressed: () {}),
            MorphChip.filter(label: 'Filter', onPressed: () {}),
            MorphChip.input(label: 'Input', onPressed: () {}),
            MorphChip.suggestion(label: 'Suggestion', onPressed: () {}),
          ],
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Outlined'));
    await tester.pump();
    expect(taps, 1);
    expect(find.byType(MorphIconButton), findsOneWidget);
    expect(find.byType(MorphCard), findsOneWidget);
    expect(find.byType(MorphTextField), findsOneWidget);
    expect(find.byType(MorphChip), findsNWidgets(4));
  });

  test('shared types are exported from the entrypoint', () {
    expect(MorphVariant.values, hasLength(5));
    expect(MorphSurface.frosted.isFrosted, isTrue);
    expect(MorphIconButtonType.values, hasLength(4));
    expect(MorphCardType.values, hasLength(3));
    final MorphVariantPalette palette = MorphVariantPalette.of(
      MorphColorScheme.light(),
      MorphVariant.danger,
    );
    expect(palette.color, MorphColorScheme.light().error);
  });
}
