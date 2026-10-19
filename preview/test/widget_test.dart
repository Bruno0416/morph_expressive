import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:morph_expressive/morph_expressive.dart';
import 'package:morph_expressive_preview/main.dart';

import 'showcase_scroll_helper.dart';

void main() {
  Future<void> start(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MorphPreviewApp());
  }

  testWidgets('showcase theme and seed controls remain interactive', (
    tester,
  ) async {
    await start(tester);
    // El nombre aparece en el AppBar y en el encabezado del catalogo.
    // Comprobar la identidad del titulo de la barra evita un falso fallo.
    expect(
      find.descendant(
        of: find.byType(AppBar),
        matching: find.text('Morph Expressive'),
      ),
      findsOneWidget,
    );
    expect(find.byType(MorphButton), findsWidgets);
    expect(find.byKey(const ValueKey('seed_Purple')), findsOneWidget);
    expect(find.byKey(const ValueKey('seed_Teal')), findsOneWidget);

    final dark = tester.widget<Scaffold>(find.byType(Scaffold).first);
    expect(
      dark.backgroundColor,
      MorphThemeData.dark(seedColor: const Color(0xFF6750A4))
          .colorScheme
          .surface,
    );

    await tester.tap(find.byTooltip('Switch theme'));
    await tester.pump();
    final light = tester.widget<Scaffold>(find.byType(Scaffold).first);
    expect(light.backgroundColor, isNot(dark.backgroundColor));
  });

  testWidgets('the gallery scrolls without a sidebar or icon diagnostics', (
    tester,
  ) async {
    await start(tester);
    expect(find.byKey(const ValueKey('morph_showcase_scroll')), findsOneWidget);
    expect(find.byKey(const ValueKey('category_icon_lab')), findsNothing);
    expect(find.byKey(const ValueKey('category_checkbox')), findsNothing);

    await revealShowcaseCategory(tester, 'chips');
    expect(find.byType(MorphChip), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}
