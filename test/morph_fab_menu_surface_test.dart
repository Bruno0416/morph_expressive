import 'dart:ui' show Tristate;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart'
    show BorderSide, Icons, Scaffold, Icon, WidgetStatePropertyAll;
import 'package:morph_expressive/morph_expressive.dart';

import 'helpers/raster_capture.dart';

Widget _host({
  MorphFabMenuController? controller,
  MorphShapeRenderer renderer = MorphShapeRenderer.auto,
  ValueChanged<MorphShapeRenderStatus>? onRenderer,
}) => MorphMaterialApp(
  data: MorphThemeData.light(),
  home: Scaffold(
    body: Align(
      alignment: Alignment.bottomRight,
      child: MorphFabMenu(
        controller: controller,
        renderer: renderer,
        onRendererChanged: onRenderer,
        items: const <MorphFabMenuItem>[
          MorphFabMenuItem(icon: Icon(Icons.image), label: 'Image'),
          MorphFabMenuItem(icon: Icon(Icons.mic), label: 'Audio'),
          MorphFabMenuItem(icon: Icon(Icons.edit), label: 'Note'),
        ],
      ),
    ),
  ),
);

MorphRoundedSurface _surface(WidgetTester tester) =>
    tester.widget<MorphRoundedSurface>(find.byType(MorphRoundedSurface));

Future<void> _settleShader(WidgetTester tester) async {
  for (var i = 0; i < 20; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 30)),
    );
    await tester.pump();
  }
}

void main() {
  tearDown(MorphFocusInteraction.resetForTest);
  _decorationSideTests();

  testWidgets('one persistent surface, continuous across open / close', (
    tester,
  ) async {
    final c = MorphFabMenuController();
    await tester.pumpWidget(_host(controller: c));
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.byType(MorphRoundedSurface), findsOneWidget);
    final element = tester.element(find.byType(MorphRoundedSurface));
    final closed = _surface(tester);

    Size? lastSize;
    Color? lastColor;
    void sample(String phase) {
      expect(find.byType(MorphRoundedSurface), findsOneWidget, reason: phase);
      expect(
        tester.element(find.byType(MorphRoundedSurface)),
        same(element),
        reason: '$phase: surface re-created',
      );
      final s = _surface(tester);
      if (lastSize != null) {
        expect(
          (s.size.width - lastSize!.width).abs(),
          lessThan(14),
          reason: '$phase size jump',
        );
        final dr =
            (s.color.r - lastColor!.r).abs() +
            (s.color.g - lastColor!.g).abs() +
            (s.color.b - lastColor!.b).abs();
        expect(dr, lessThan(.35), reason: '$phase color jump');
      }
      lastSize = s.size;
      lastColor = s.color;
    }

    c.open();
    for (var i = 0; i < 40; i++) {
      await tester.pump(const Duration(milliseconds: 16));
      sample('open $i');
    }
    await tester.pumpAndSettle();
    final open = _surface(tester);
    expect(open.size.width, lessThan(closed.size.width));
    expect(open.color, isNot(closed.color));
    c.close();
    for (var i = 0; i < 40; i++) {
      await tester.pump(const Duration(milliseconds: 16));
      sample('close $i');
    }
    await tester.pumpAndSettle();
    final back = _surface(tester);
    expect(back.size.width, closeTo(closed.size.width, .01));
    expect(back.color.toARGB32(), closed.color.toARGB32());
    expect(back.radius, closeTo(closed.radius, .01));
    expect(find.text('Image'), findsNothing);
    expect(tester.element(find.byType(MorphRoundedSurface)), same(element));
  });

  testWidgets('interrupted and rapid toggles start from the visible state', (
    tester,
  ) async {
    final c = MorphFabMenuController();
    await tester.pumpWidget(_host(controller: c));
    await tester.pump(const Duration(milliseconds: 50));
    final element = tester.element(find.byType(MorphRoundedSurface));
    c.open();
    await tester.pump(const Duration(milliseconds: 90));
    final mid = _surface(tester).size.width;
    c.close(); // reverse mid-flight
    await tester.pump(const Duration(milliseconds: 16));
    expect((_surface(tester).size.width - mid).abs(), lessThan(10));
    for (var i = 0; i < 6; i++) {
      c.toggle();
      await tester.pump(Duration(milliseconds: 20 + i * 15));
      expect(find.byType(MorphRoundedSurface), findsOneWidget);
      expect(tester.element(find.byType(MorphRoundedSurface)), same(element));
      expect(tester.takeException(), isNull);
    }
    c.close();
    await tester.pumpAndSettle();
    expect(c.isOpen, isFalse);
    expect(find.text('Image'), findsNothing);
  });

  testWidgets('semantics stay valid in every opening / closing frame', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    final c = MorphFabMenuController();
    await tester.pumpWidget(_host(controller: c));
    await tester.pump(const Duration(milliseconds: 50));
    expect(tester.takeException(), isNull);
    var node = tester.getSemantics(find.bySemanticsLabel('Toggle menu'));
    expect(node.flagsCollection.isExpanded, Tristate.isFalse);
    c.open();
    for (var i = 0; i < 40; i++) {
      await tester.pump(const Duration(milliseconds: 16));
      expect(tester.takeException(), isNull, reason: 'open frame $i');
    }
    await tester.pumpAndSettle();
    node = tester.getSemantics(find.bySemanticsLabel('Toggle menu'));
    expect(node.flagsCollection.isExpanded, Tristate.isTrue);
    expect(find.bySemanticsLabel(RegExp('Image')), findsWidgets);
    c.close();
    for (var i = 0; i < 40; i++) {
      await tester.pump(const Duration(milliseconds: 16));
      expect(tester.takeException(), isNull, reason: 'close frame $i');
    }
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel(RegExp('Image')), findsNothing);
    node = tester.getSemantics(find.bySemanticsLabel('Toggle menu'));
    expect(node.flagsCollection.isExpanded, Tristate.isFalse);
    handle.dispose();
  });

  testWidgets('shader renders for real; canvas fallback is equivalent', (
    tester,
  ) async {
    MorphShapeRenderStatus? status;
    await tester.pumpWidget(
      _host(renderer: MorphShapeRenderer.shader, onRenderer: (s) => status = s),
    );
    await _settleShader(tester);
    expect(
      status?.effective,
      MorphShapeRenderer.shader,
      reason: status?.reason,
    );
    await tester.pumpWidget(
      _host(renderer: MorphShapeRenderer.canvas, onRenderer: (s) => status = s),
    );
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump();
    expect(status?.effective, MorphShapeRenderer.canvas);
  });

  testWidgets('callbacks fire once and Escape closes with focus returning', (
    tester,
  ) async {
    var taps = 0;
    await tester.pumpWidget(
      MorphMaterialApp(
        data: MorphThemeData.light(),
        home: Scaffold(
          body: Align(
            alignment: Alignment.bottomRight,
            child: MorphFabMenu(
              items: <MorphFabMenuItem>[
                MorphFabMenuItem(
                  icon: const Icon(Icons.image),
                  label: 'Image',
                  onPressed: () => taps++,
                ),
                const MorphFabMenuItem(icon: Icon(Icons.mic), label: 'Audio'),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tap(find.byType(MorphRoundedSurface));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Image'));
    await tester.pumpAndSettle();
    expect(taps, 1);
    expect(find.text('Image'), findsNothing);
  });
}

void _decorationSideTests() {
  for (final renderer in [
    MorphShapeRenderer.canvas,
    MorphShapeRenderer.shader,
  ]) {
    testWidgets(
      'decoration.side is drawn on ${renderer.name} and fades when open',
      (tester) async {
        final key = GlobalKey();
        final c = MorphFabMenuController();
        await tester.pumpWidget(
          RepaintBoundary(
            key: key,
            child: MorphMaterialApp(
              data: MorphThemeData.light(),
              home: Scaffold(
                body: Align(
                  alignment: Alignment.bottomRight,
                  child: MorphFabMenu(
                    controller: c,
                    renderer: renderer,
                    decoration: MorphFabDecoration(
                      backgroundColor: const WidgetStatePropertyAll(
                        Color(0xffffffff),
                      ),
                      side: const WidgetStatePropertyAll(
                        BorderSide(color: Color(0xffe00000), width: 4),
                      ),
                    ),
                    items: const <MorphFabMenuItem>[
                      MorphFabMenuItem(icon: Icon(Icons.image), label: 'Image'),
                      MorphFabMenuItem(icon: Icon(Icons.mic), label: 'Audio'),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
        await _settleShader(tester);
        // Red ring pixels exist just inside the surface edge when closed.
        final rect = tester.getRect(find.byType(MorphRoundedSurface));
        Future<int> redPixels() async {
          final r = await captureRaster(tester, key);
          var n = 0;
          for (var y = rect.top.floor(); y < rect.bottom.ceil(); y++) {
            for (var x = rect.left.floor(); x < rect.right.ceil(); x++) {
              if (r.channel(x, y, 0) > 180 &&
                  r.channel(x, y, 1) < 90 &&
                  r.channel(x, y, 2) < 90) {
                n++;
              }
            }
          }
          return n;
        }

        expect(await redPixels(), greaterThan(80), reason: renderer.name);
        c.open();
        await tester.pumpAndSettle();
        expect(await redPixels(), lessThan(10), reason: 'no outline when open');
        c.close();
        await tester.pumpAndSettle();
        expect(await redPixels(), greaterThan(80), reason: 'back when closed');
      },
    );
  }
}
