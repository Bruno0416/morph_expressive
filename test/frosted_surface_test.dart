import 'package:flutter_test/flutter_test.dart';
import 'package:morph_expressive/morph_components.dart';
import 'package:morph_expressive/foundations/surface/morph_glass_surface.dart';
import 'package:material_ui/material_ui.dart'
    show
        BackdropFilter,
        BuildContext,
        Center,
        MediaQuery,
        MediaQueryData,
        Scaffold,
        Size,
        SizedBox,
        TextButton,
        Text,
        VoidCallback,
        Widget;

const List<MorphDropdownItem<String>> _items = <MorphDropdownItem<String>>[
  MorphDropdownItem(label: 'Flutter', value: 'flutter'),
  MorphDropdownItem(label: 'Dart', value: 'dart'),
  MorphDropdownItem(label: 'Material 3', value: 'm3'),
];

Widget _host(Widget child, {MorphThemeData? data}) {
  return MorphMaterialApp(
    data: data ?? MorphThemeData.light(),
    home: Scaffold(
      body: MediaQuery(
        data: const MediaQueryData(size: Size(800, 600)),
        child: Center(child: SizedBox(width: 320, child: child)),
      ),
    ),
  );
}

Future<void> _openDropdown(WidgetTester tester) async {
  await tester.tap(find.text('Choose framework'));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
}

Future<void> _openMenu(WidgetTester tester) async {
  await tester.tap(find.text('Open'));
  await tester.pump();
  await tester.pumpAndSettle(const Duration(milliseconds: 50));
}

void main() {
  group('Card glass', () {
    testWidgets('inherits, overrides and disables global glass', (
      tester,
    ) async {
      const global = MorphSurfaceGlass(blurX: 7);
      const local = MorphSurfaceGlass(blurX: 19);
      await tester.pumpWidget(
        _host(
          const MorphCard(headline: 'Card'),
          data: MorphThemeData.light().copyWith(surfaceGlass: global),
        ),
      );
      // Cards do not pay the blur cost merely because the theme has glass.
      expect(find.byType(MorphGlassSurface), findsNothing);
      expect(find.byType(BackdropFilter), findsNothing);

      await tester.pumpWidget(
        _host(
          const MorphCard(headline: 'Card', frosted: true),
          data: MorphThemeData.light().copyWith(surfaceGlass: global),
        ),
      );
      expect(
        tester.widget<MorphGlassSurface>(find.byType(MorphGlassSurface)).glass,
        global,
      );
      expect(find.byType(BackdropFilter), findsOneWidget);

      await tester.pumpWidget(
        _host(
          const MorphCard(headline: 'Card', glass: local),
          data: MorphThemeData.light().copyWith(surfaceGlass: global),
        ),
      );
      expect(
        tester.widget<MorphGlassSurface>(find.byType(MorphGlassSurface)).glass,
        local,
      );

      await tester.pumpWidget(
        _host(
          const MorphCard(
            headline: 'Card',
            frosted: true,
            glass: MorphSurfaceGlass.disabled(),
          ),
          data: MorphThemeData.light().copyWith(surfaceGlass: global),
        ),
      );
      expect(find.byType(BackdropFilter), findsNothing);
      expect(find.byType(MorphGlassSurface), findsNothing);
    });

    testWidgets('frosted flag with no theme remains opaque', (tester) async {
      await tester.pumpWidget(
        _host(const MorphCard(headline: 'No theme', frosted: true)),
      );
      expect(find.byType(MorphGlassSurface), findsNothing);
      expect(find.byType(BackdropFilter), findsNothing);
    });

    testWidgets('explicit glass works with frosted false', (tester) async {
      const custom = MorphSurfaceGlass(blurX: 16, blurY: 16);
      await tester.pumpWidget(
        _host(const MorphCard(headline: 'Explicit', glass: custom)),
      );
      expect(find.byType(MorphGlassSurface), findsOneWidget);
      expect(find.byType(BackdropFilter), findsOneWidget);
      expect(
        tester.widget<MorphGlassSurface>(find.byType(MorphGlassSurface)).glass,
        custom,
      );
    });

    testWidgets(
      'local glass works without a global theme and remains tappable',
      (tester) async {
        var taps = 0;
        await tester.pumpWidget(
          _host(
            MorphCard(
              headline: 'Tap card',
              glass: const MorphSurfaceGlass(),
              onPressed: () => taps++,
            ),
          ),
        );
        expect(find.byType(BackdropFilter), findsOneWidget);
        await tester.tap(find.text('Tap card'));
        expect(taps, 1);
      },
    );
  });

  group('MorphSurfaceGlass model', () {
    test('defaults match the public contract', () {
      const g = MorphSurfaceGlass();
      expect(g.enabled, isTrue);
      expect(g.blurX, 12);
      expect(g.blurY, 12);
      expect(g.tint, isNull);
      expect(g.tintOpacity, 0.65);
      expect(g.borderColor, isNull);
      expect(g.borderWidth, 0);
      expect(g.opaqueInHighContrast, isTrue);
      expect(g.webBackdropBlur, isTrue);
    });

    test('disabled() turns the whole effect off', () {
      const g = MorphSurfaceGlass.disabled();
      expect(g.enabled, isFalse);
      expect(g.wantsBlur, isFalse);
    });

    test('blur zero keeps tint but drops the backdrop filter', () {
      const g = MorphSurfaceGlass(blurX: 0, blurY: 0);
      expect(g.enabled, isTrue);
      expect(g.wantsBlur, isFalse);
      expect(g.tintOpacity, 0.65);
    });

    test('validates ranges', () {
      expect(() => MorphSurfaceGlass(blurX: -1), throwsAssertionError);
      expect(() => MorphSurfaceGlass(blurY: -0.5), throwsAssertionError);
      expect(() => MorphSurfaceGlass(tintOpacity: 1.2), throwsAssertionError);
      expect(() => MorphSurfaceGlass(borderWidth: -1), throwsAssertionError);
    });

    test('value equality and copyWith', () {
      const g = MorphSurfaceGlass(blurX: 4, tintOpacity: 0.5);
      expect(g, const MorphSurfaceGlass(blurX: 4, tintOpacity: 0.5));
      expect(
        g.copyWith(blurX: 9),
        const MorphSurfaceGlass(blurX: 9, tintOpacity: 0.5),
      );
      expect(g.copyWith().tintOpacity, 0.5);
      expect(
        g.hashCode,
        const MorphSurfaceGlass(blurX: 4, tintOpacity: 0.5).hashCode,
      );
    });
  });

  group('MorphThemeData integration', () {
    test('copyWith sets and preserves floatingSurfaceGlass', () {
      final base = MorphThemeData.light();
      expect(base.floatingSurfaceGlass, isNull);
      const g = MorphSurfaceGlass(blurX: 6);
      final withGlass = base.copyWith(floatingSurfaceGlass: g);
      expect(withGlass.floatingSurfaceGlass, g);
      expect(withGlass.copyWith().floatingSurfaceGlass, g);
      expect(withGlass.colorScheme, base.colorScheme);
    });

    test('deriveDarkTemplate keeps the glass configuration', () {
      final light = MorphThemeData.light().copyWith(
        floatingSurfaceGlass: const MorphSurfaceGlass(),
      );
      expect(light.deriveDarkTemplate().floatingSurfaceGlass, isNotNull);
    });
  });

  group('Dropdown panel surface', () {
    testWidgets('no configuration keeps the classic opaque panel', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          const MorphDropdownMenu<String>(
            items: _items,
            fieldStyle: MorphDropdownFieldStyle(hintText: 'Choose framework'),
          ),
        ),
      );
      await _openDropdown(tester);
      expect(find.text('Dart'), findsOneWidget);
      expect(find.byType(MorphGlassSurface), findsNothing);
      expect(find.byType(BackdropFilter), findsNothing);
    });

    testWidgets('theme global frosts the opened panel', (tester) async {
      await tester.pumpWidget(
        _host(
          const MorphDropdownMenu<String>(
            items: _items,
            fieldStyle: MorphDropdownFieldStyle(hintText: 'Choose framework'),
          ),
          data: MorphThemeData.light().copyWith(
            floatingSurfaceGlass: const MorphSurfaceGlass(),
          ),
        ),
      );
      await _openDropdown(tester);
      expect(find.text('Dart'), findsOneWidget);
      expect(find.byType(MorphGlassSurface), findsOneWidget);
      expect(find.byType(BackdropFilter), findsOneWidget);
    });

    testWidgets('local disabled() wins over an active global', (tester) async {
      await tester.pumpWidget(
        _host(
          const MorphDropdownMenu<String>(
            items: _items,
            glass: MorphSurfaceGlass.disabled(),
            fieldStyle: MorphDropdownFieldStyle(hintText: 'Choose framework'),
          ),
          data: MorphThemeData.light().copyWith(
            floatingSurfaceGlass: const MorphSurfaceGlass(),
          ),
        ),
      );
      await _openDropdown(tester);
      expect(find.text('Dart'), findsOneWidget);
      expect(find.byType(BackdropFilter), findsNothing);
    });

    testWidgets('explicit local glass overrides the theme', (tester) async {
      await tester.pumpWidget(
        _host(
          const MorphDropdownMenu<String>(
            items: _items,
            glass: MorphSurfaceGlass(blurX: 3, blurY: 3),
            fieldStyle: MorphDropdownFieldStyle(hintText: 'Choose framework'),
          ),
        ),
      );
      await _openDropdown(tester);
      expect(find.byType(BackdropFilter), findsOneWidget);
    });

    testWidgets('sliders update an already open panel without closing it', (
      tester,
    ) async {
      Widget app(MorphSurfaceGlass glass) => _host(
        const MorphDropdownMenu<String>(
          items: _items,
          fieldStyle: MorphDropdownFieldStyle(hintText: 'Choose framework'),
        ),
        data: MorphThemeData.light().copyWith(floatingSurfaceGlass: glass),
      );

      await tester.pumpWidget(app(const MorphSurfaceGlass(blurX: 4, blurY: 4)));
      await _openDropdown(tester);
      expect(find.text('Dart'), findsOneWidget);

      await tester.pumpWidget(
        app(const MorphSurfaceGlass(blurX: 24, blurY: 24)),
      );
      await tester.pump();

      // Still open, now with the new sigma and no extra filters mounted.
      expect(find.text('Dart'), findsOneWidget);
      expect(find.byType(BackdropFilter), findsOneWidget);
      final filter = tester
          .widget<BackdropFilter>(find.byType(BackdropFilter))
          .filter;
      expect(filter.toString(), contains('24.0'));
    });

    testWidgets('zero sigma keeps tint without a backdrop filter', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          const MorphDropdownMenu<String>(
            items: _items,
            fieldStyle: MorphDropdownFieldStyle(hintText: 'Choose framework'),
          ),
          data: MorphThemeData.light().copyWith(
            floatingSurfaceGlass: const MorphSurfaceGlass(blurX: 0, blurY: 0),
          ),
        ),
      );
      await _openDropdown(tester);
      expect(find.byType(MorphGlassSurface), findsOneWidget);
      expect(find.byType(BackdropFilter), findsNothing);
    });
  });

  group('Menu surfaces', () {
    testWidgets('theme global frosts every menu card', (tester) async {
      await tester.pumpWidget(
        _host(
          MorphMenu(
            anchorBuilder: (BuildContext context, VoidCallback open) =>
                TextButton(onPressed: open, child: const Text('Open')),
            children: const <MorphMenuNode>[
              MorphMenuEntry(label: 'One'),
              MorphMenuEntry(label: 'Two'),
            ],
          ),
          data: MorphThemeData.light().copyWith(
            floatingSurfaceGlass: const MorphSurfaceGlass(),
          ),
        ),
      );
      await _openMenu(tester);
      expect(find.text('One'), findsOneWidget);
      expect(find.byType(MorphGlassSurface), findsWidgets);
      expect(find.byType(BackdropFilter), findsWidgets);
    });

    testWidgets('menu keeps the classic surfaces without configuration', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          MorphMenu(
            anchorBuilder: (BuildContext context, VoidCallback open) =>
                TextButton(onPressed: open, child: const Text('Open')),
            children: const <MorphMenuNode>[MorphMenuEntry(label: 'One')],
          ),
        ),
      );
      await _openMenu(tester);
      expect(find.text('One'), findsOneWidget);
      expect(find.byType(MorphGlassSurface), findsNothing);
      expect(find.byType(BackdropFilter), findsNothing);
    });
  });
}
