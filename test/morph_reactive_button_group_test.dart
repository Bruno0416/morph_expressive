import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart' show Scaffold;
import 'package:morph_expressive/morph_expressive.dart';

Widget host(
  Widget child, {
  bool reduced = false,
  double? width,
  TextDirection dir = TextDirection.ltr,
  double textScale = 1,
}) => MorphMaterialApp(
  data: MorphThemeData.light().copyWith(reduceMotion: reduced),
  home: Directionality(
    textDirection: dir,
    child: MediaQuery(
      data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
      child: Scaffold(
        body: Align(
          alignment: AlignmentDirectional.topStart,
          child: width == null ? child : SizedBox(width: width, child: child),
        ),
      ),
    ),
  ),
);

List<MorphReactiveGroupItem> items(int n, {bool icons = false}) => [
  for (var i = 0; i < n; i++)
    MorphReactiveGroupItem(
      label: Text('Item $i'),
      icon: icons ? const Icon(MorphIcons.check_rounded) : null,
    ),
];

List<double> widthsOf(WidgetTester t) => [
  for (final e in t.widgetList(find.byType(MorphButton)))
    t.getSize(find.byWidget(e)).width,
];

/// Frame-by-frame pump: the bank clamps dt like a real frame pipeline.
Future<void> frames(WidgetTester t, int ms) async {
  for (var i = 0; i < ms / 16; i++) {
    await t.pump(const Duration(milliseconds: 16));
  }
}

void main() {
  group('resolveReactiveWidths', () {
    test('fill: total constant, neighbours yield, no negatives', () {
      final w = resolveReactiveWidths(
        natural: [60, 60, 60],
        fixed: [null, null, null],
        expansion: [0, .3, 0],
        maxExpansion: .3,
        available: 300,
        gap: 4,
        fit: MorphReactiveGroupFit.fill,
      );
      expect(w.reduce((a, b) => a + b) + 8, closeTo(300, 1e-6));
      expect(w[1], greaterThan(w[0]));
      expect(w[0], closeTo(w[2], 1e-9));
      expect(w.every((e) => e >= 60 - 1e-9), isTrue);
    });
    test('no slack: amplitude collapses, widths stay natural', () {
      final w = resolveReactiveWidths(
        natural: [100, 100],
        fixed: [null, null],
        expansion: [.3, 0],
        maxExpansion: .3,
        available: 204,
        gap: 4,
        fit: MorphReactiveGroupFit.fill,
      );
      expect(w, [100, 100]);
    });
    test('insufficient constraints compress without negatives', () {
      final w = resolveReactiveWidths(
        natural: [100, 100],
        fixed: [null, null],
        expansion: [.3, .3],
        maxExpansion: .3,
        available: 60,
        gap: 4,
        fit: MorphReactiveGroupFit.fill,
      );
      expect(w.reduce((a, b) => a + b) + 4, lessThanOrEqualTo(60.0001));
      expect(w.every((e) => e >= 0), isTrue);
    });
    test('all active: shapes only, widths equal base', () {
      final w = resolveReactiveWidths(
        natural: [50, 80],
        fixed: [null, null],
        expansion: [.1, .1],
        maxExpansion: .1,
        available: 400,
        gap: 4,
        fit: MorphReactiveGroupFit.fill,
      );
      final base = resolveReactiveWidths(
        natural: [50, 80],
        fixed: [null, null],
        expansion: [0, 0],
        maxExpansion: .1,
        available: 400,
        gap: 4,
        fit: MorphReactiveGroupFit.fill,
      );
      expect(w[0], closeTo(base[0], 1e-9));
      expect(w[1], closeTo(base[1], 1e-9));
    });
    test('unbounded: finite, pressed grows by its ratio only', () {
      final w = resolveReactiveWidths(
        natural: [60, 60],
        fixed: [null, null],
        expansion: [.2, 0],
        maxExpansion: .2,
        available: double.infinity,
        gap: 4,
        fit: MorphReactiveGroupFit.fill,
      );
      expect(w, [72, 60]);
    });
    test('uniform bounded splits evenly; fixed width is honoured', () {
      final w = resolveReactiveWidths(
        natural: [30, 90, 50],
        fixed: [null, null, 100],
        expansion: [0, 0, 0],
        maxExpansion: .2,
        available: 304,
        gap: 4,
        fit: MorphReactiveGroupFit.uniform,
      );
      expect(w[2], 100);
      expect(w[0], closeTo(w[1], 1e-9));
      expect(w[0] + w[1] + 100 + 8, closeTo(304, 1e-6));
    });
    test('multiple toggles deterministic', () {
      List<double> run() => resolveReactiveWidths(
        natural: [50, 50, 50, 50],
        fixed: [null, null, null, null],
        expansion: [.1, 0, .1, 0],
        maxExpansion: .2,
        available: 400,
        gap: 4,
        fit: MorphReactiveGroupFit.fill,
      );
      expect(run(), run());
    });
  });

  group('MorphReactiveButtonGroup', () {
    testWidgets('single select: no selection on pointer down; tap once', (
      tester,
    ) async {
      int? selected;
      var calls = 0;
      await tester.pumpWidget(
        host(
          StatefulBuilder(
            builder: (c, set) => MorphReactiveButtonGroup(
              items: items(3),
              selectedIndex: selected,
              onSelectedIndexChanged: (v) => set(() {
                selected = v;
                calls++;
              }),
            ),
          ),
          width: 400,
        ),
      );
      final gesture = await tester.startGesture(
        tester.getCenter(find.text('Item 1')),
      );
      await frames(tester, 300);
      expect(calls, 0, reason: 'down only starts feedback');
      final pressedWidths = widthsOf(tester);
      expect(pressedWidths[1], greaterThan(pressedWidths[0]));
      await gesture.up();
      await tester.pumpAndSettle();
      expect(calls, 1);
      expect(selected, 1);
      // Selected keeps bounded expansion; selecting another releases it.
      final w1 = widthsOf(tester);
      expect(w1[1], greaterThan(w1[0]));
      await tester.tap(find.text('Item 2'));
      await tester.pumpAndSettle();
      expect(selected, 2);
      final w2 = widthsOf(tester);
      expect(w2[2], greaterThan(w2[1]));
      expect(w2[0], closeTo(130.67, .6), reason: 'far item untouched');
      expect(w2[1], lessThan(w2[0]), reason: 'adjacent neighbour donated');
    });

    testWidgets(
      'per-item radius applies in actions mode and keeps press morph',
      (tester) async {
        await tester.pumpWidget(
          host(
            MorphReactiveButtonGroup(
              mode: MorphReactiveGroupMode.actions,
              items: const [
                MorphReactiveGroupItem(label: Text('A'), restRadius: 10),
                MorphReactiveGroupItem(label: Text('B')),
              ],
            ),
            width: 300,
          ),
        );
        final buttons = tester
            .widgetList<MorphButton>(find.byType(MorphButton))
            .toList();
        expect(buttons[0].decoration!.borderRadius, 10);
        expect(buttons[0].decoration!.pressedRadius, isNotNull);
        expect(
          buttons[0].isSelected,
          isNull,
          reason: 'shape never implies selection',
        );
        expect(buttons[1].decoration!.borderRadius, isNull);
      },
    );

    testWidgets('selectionRequired keeps the last selection', (tester) async {
      int? selected = 0;
      await tester.pumpWidget(
        host(
          StatefulBuilder(
            builder: (c, set) => MorphReactiveButtonGroup(
              items: items(2),
              selectedIndex: selected,
              selectionRequired: true,
              onSelectedIndexChanged: (v) => set(() => selected = v),
            ),
          ),
          width: 300,
        ),
      );
      await tester.tap(find.text('Item 0'));
      await tester.pumpAndSettle();
      expect(selected, 0);
    });

    testWidgets('multi toggle keeps several expanded, all active safe', (
      tester,
    ) async {
      var sel = <int>{0, 2};
      await tester.pumpWidget(
        host(
          StatefulBuilder(
            builder: (c, set) => MorphReactiveButtonGroup(
              mode: MorphReactiveGroupMode.multiToggle,
              items: items(3),
              selectedIndices: sel,
              onSelectedIndicesChanged: (v) => set(() => sel = v),
            ),
          ),
          width: 420,
        ),
      );
      await tester.pumpAndSettle();
      var w = widthsOf(tester);
      expect(w[0], closeTo(w[2], .01));
      expect(w[0], greaterThan(w[1]));
      await tester.tap(find.text('Item 1'));
      await tester.pumpAndSettle();
      expect(sel, {0, 1, 2});
      w = widthsOf(tester);
      expect(w.reduce((a, b) => a + b) + 8, closeTo(420, 1));
      await tester.tap(find.text('Item 1'));
      await tester.pumpAndSettle();
      expect(sel, {0, 2});
    });

    testWidgets(
      'actions: widen while pressed, never selected, release restores',
      (tester) async {
        var taps = 0;
        await tester.pumpWidget(
          host(
            MorphReactiveButtonGroup(
              mode: MorphReactiveGroupMode.actions,
              items: [
                for (var i = 0; i < 3; i++)
                  MorphReactiveGroupItem(
                    label: Text('A$i'),
                    onPressed: () => taps++,
                  ),
              ],
            ),
            width: 360,
          ),
        );
        await tester.pumpAndSettle();
        final rest = widthsOf(tester);
        final g = await tester.startGesture(tester.getCenter(find.text('A0')));
        await frames(tester, 400);
        final held = widthsOf(tester);
        expect(held[0], greaterThan(rest[0]));
        expect(held[1], lessThan(rest[1]));
        expect(held.reduce((a, b) => a + b) + 8, closeTo(360, 1));
        await g.up();
        await tester.pumpAndSettle();
        expect(taps, 1);
        final after = widthsOf(tester);
        for (var i = 0; i < 3; i++) {
          expect(after[i], closeTo(rest[i], .5));
        }
        // Cancel (drag away) restores too and does not fire.
        final c = await tester.startGesture(tester.getCenter(find.text('A1')));
        await frames(tester, 300);
        await c.moveBy(const Offset(0, 400));
        await c.cancel();
        await tester.pumpAndSettle();
        expect(taps, 1);
        final end = widthsOf(tester);
        for (var i = 0; i < 3; i++) {
          expect(end[i], closeTo(rest[i], .5));
        }
      },
    );

    testWidgets('narrow and unbounded parents never overflow', (tester) async {
      await tester.pumpWidget(
        host(
          MorphReactiveButtonGroup(
            items: items(4, icons: true),
            selectedIndex: 1,
          ),
          width: 120,
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(
        tester.getSize(find.byType(MorphReactiveButtonGroup)).width,
        lessThanOrEqualTo(120),
      );
      await tester.pumpWidget(
        host(
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: MorphReactiveButtonGroup(items: items(3), selectedIndex: 0),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(
        tester.getSize(find.byType(MorphReactiveButtonGroup)).width.isFinite,
        isTrue,
      );
    });

    testWidgets('RTL mirrors order; text 2x keeps labels', (tester) async {
      await tester.pumpWidget(
        host(
          MorphReactiveButtonGroup(items: items(3), selectedIndex: 0),
          width: 600,
          dir: TextDirection.rtl,
          textScale: 2,
        ),
      );
      await tester.pumpAndSettle();
      expect(
        tester.getCenter(find.text('Item 0')).dx,
        greaterThan(tester.getCenter(find.text('Item 2')).dx),
      );
      expect(find.text('Item 1'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('disabled item ignores taps; keyboard activates once', (
      tester,
    ) async {
      var sel = <int>{};
      var calls = 0;
      await tester.pumpWidget(
        host(
          StatefulBuilder(
            builder: (c, set) => MorphReactiveButtonGroup(
              mode: MorphReactiveGroupMode.multiToggle,
              items: [
                const MorphReactiveGroupItem(
                  label: Text('Off'),
                  enabled: false,
                ),
                const MorphReactiveGroupItem(label: Text('On')),
              ],
              selectedIndices: sel,
              onSelectedIndicesChanged: (v) => set(() {
                sel = v;
                calls++;
              }),
            ),
          ),
          width: 300,
        ),
      );
      await tester.tap(find.text('Off'), warnIfMissed: false);
      await tester.pump();
      expect(calls, 0);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(calls, 1);
      expect(sel, {1});
    });

    testWidgets('reduced motion snaps; dispose mid-press is clean', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(
          MorphReactiveButtonGroup(items: items(3), selectedIndex: 1),
          width: 400,
          reduced: true,
        ),
      );
      await tester.pump();
      final w = widthsOf(tester);
      expect(w[1], greaterThan(w[0]));
      await tester.startGesture(tester.getCenter(find.text('Item 0')));
      await tester.pump(const Duration(milliseconds: 16));
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 1));
      expect(tester.takeException(), isNull);
    });

    testWidgets('semantics keep full label', (tester) async {
      final h = tester.ensureSemantics();
      await tester.pumpWidget(
        host(
          MorphReactiveButtonGroup(
            items: const [
              MorphReactiveGroupItem(
                label: Text('A very long connectivity label'),
              ),
              MorphReactiveGroupItem(label: Text('B')),
            ],
            selectedIndex: 0,
          ),
          width: 140,
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.bySemanticsLabel(RegExp('A very long connectivity label')),
        findsWidgets,
      );
      h.dispose();
    });
  });
}
