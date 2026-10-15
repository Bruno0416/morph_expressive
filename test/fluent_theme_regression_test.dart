import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:morph_expressive/morph_expressive.dart';

void main() {
  // ---------- iconos fluent ----------

  test('los iconos internos usan exclusivamente las fuentes de fluent', () {
    for (final glyph in [
      MorphIcons.search,
      MorphIcons.close,
      MorphIcons.check,
      MorphIcons.check_box,
      MorphIcons.arrow_back,
      MorphIcons.favorite,
    ]) {
      expect(glyph.fontPackage, 'fluent_icons_kit');
      expect(glyph.fontFamily, anyOf('FluentKitLine', 'FluentKitFilled'));
    }
  });

  test('el icono de busqueda se puede personalizar sin wrapper', () {
    const replacement = Icon(MorphIcons.search);
    const style = MorphDropdownSearchStyle(searchIcon: replacement);

    expect(style.searchIcon, same(replacement));
    expect(style.copyWith(hintText: 'Find').searchIcon, same(replacement));
    expect(
      MorphDropdownSearchStyle.lerp(
        const MorphDropdownSearchStyle(),
        style,
        1,
      ).searchIcon,
      same(replacement),
    );
  });

  testWidgets('checkbox utiliza la marca Fluent Filled', (tester) async {
    final theme = MorphThemeData.light();
    await tester.pumpWidget(
      MaterialApp(
        home: MorphTheme(
          data: theme,
          child: Scaffold(
            body: MorphCheckbox(value: true, onChanged: (_) {}),
          ),
        ),
      ),
    );

    final marks = tester.widgetList<Icon>(find.byType(Icon));
    expect(
      marks.any((icon) => icon.icon == FluentIcons.filled.checkmark),
      isTrue,
    );
  });

  // ---------- proyeccion del tema ----------

  for (final isDark in [false, true]) {
    testWidgets('colores material coherentes en ${isDark ? 'dark' : 'light'}', (
      tester,
    ) async {
      final data = isDark
          ? MorphThemeData.dark(seedColor: const Color(0xFF6750A4))
          : MorphThemeData.light(seedColor: const Color(0xFF6750A4));
      final expected = data.toThemeData();

      await tester.pumpWidget(
        MaterialApp(
          theme: expected,
          home: MorphTheme(
            data: data,
            child: Builder(
              builder: (context) {
                final material = Theme.of(context);
                expect(material.colorScheme.brightness, data.brightness);
                expect(material.colorScheme.surface, data.colorScheme.surface);
                expect(
                  material.scaffoldBackgroundColor,
                  expected.scaffoldBackgroundColor,
                );
                expect(material.cardColor, expected.cardColor);
                return const Scaffold(body: Text('Theme ready'));
              },
            ),
          ),
        ),
      );

      expect(find.text('Theme ready'), findsOneWidget);
    });
  }
}
