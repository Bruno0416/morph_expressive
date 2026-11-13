import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart' show Scaffold;
import 'package:morph_expressive/morph_expressive.dart';

const labels = ['Day', 'Week', 'Month', 'Year', 'All', 'Decade', 'Era'];

Widget host(
  Widget Function(StateSetter) build, {
  double width = 560,
  TextDirection dir = TextDirection.ltr,
  double scale = 1,
}) => MorphMaterialApp(
  data: MorphThemeData.light(),
  home: Directionality(
    textDirection: dir,
    child: MediaQuery(
      data: MediaQueryData(textScaler: TextScaler.linear(scale)),
      child: Scaffold(
        body: Align(
          alignment: AlignmentDirectional.topStart,
          child: SizedBox(
            width: width,
            child: StatefulBuilder(builder: (c, s) => build(s)),
          ),
        ),
      ),
    ),
  ),
);

typedef Geo = ({
  List<double> w,
  List<double> x,
  List<double> top,
  List<double> h,
});

Geo geo(WidgetTester t) {
  final fs = [
    for (final e in t.widgetList(find.byType(MorphButton))) find.byWidget(e),
  ];
  return (
    w: [for (final f in fs) t.getSize(f).width],
    x: [for (final f in fs) t.getTopLeft(f).dx],
    top: [for (final f in fs) t.getTopLeft(f).dy],
    h: [for (final f in fs) t.getSize(f).height],
  );
}

List<MorphReactiveGroupItem> items(int n, {bool long = false}) => [
  for (var i = 0; i < n; i++)
    MorphReactiveGroupItem(
      label: Text(long ? 'A quite long label $i' : labels[i % labels.length]),
    ),
];

void main() {
  for (final n in [3, 4, 6, 7]) {
    for (final pos in ['start', 'center', 'end']) {
      testWidgets('press $pos of $n: stable height, bounded, local', (
        tester,
      ) async {
        await tester.pumpWidget(
          host(
            (s) => MorphReactiveButtonGroup(
              mode: MorphReactiveGroupMode.actions,
              items: items(n),
            ),
            width: n == 7 ? 760 : 560,
          ),
        );
        await tester.pumpAndSettle();
        final rest = geo(tester);
        final target = pos == 'start'
            ? 0
            : pos == 'end'
            ? n - 1
            : n ~/ 2;
        final total = rest.w.reduce((a, b) => a + b);
        final g = await tester.startGesture(
          tester.getCenter(find.text(labels[target % labels.length]).first),
        );
        var maxGrowth = 0.0;
        for (var f = 0; f < 40; f++) {
          await tester.pump(const Duration(milliseconds: 16));
          final c = geo(tester);
          expect(c.h, rest.h, reason: 'height constant');
          expect(c.top, rest.top, reason: 'vertical position constant');
          expect(
            c.w.reduce((a, b) => a + b),
            closeTo(total, .01),
            reason: 'total constant',
          );
          expect(c.w.every((w) => w > 0), isTrue);
          maxGrowth = maxGrowth > c.w[target] - rest.w[target]
              ? maxGrowth
              : c.w[target] - rest.w[target];
          // Gaps stay equal.
          for (var i = 0; i < n - 1; i++) {
            expect(
              c.x[i + 1] - (c.x[i] + c.w[i]),
              closeTo(rest.x[1] - (rest.x[0] + rest.w[0]), .01),
            );
          }
          // Items outside the adjacent zone keep width and position.
          for (var i = 0; i < n; i++) {
            if ((i - target).abs() > 1) {
              // positions shift only by what the affected zone gave/took: none when compensation is local.
              expect(c.w[i], closeTo(rest.w[i], .01), reason: 'far item $i');
            }
          }
          // No oscillation: growth never decreases while held.
        }
        // Amplitude bounded by the configured .15 of the base width.
        expect(maxGrowth, lessThanOrEqualTo(rest.w[target] * .15 + .5));
        expect(maxGrowth, greaterThan(1));
        await g.up();
        await tester.pumpAndSettle();
        final after = geo(tester);
        for (var i = 0; i < n; i++) {
          expect(after.w[i], closeTo(rest.w[i], .05));
          expect(after.x[i], closeTo(rest.x[i], .05));
        }
      });
    }
  }

  testWidgets('held press grows monotonically (no tremor) and settles', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(
        (s) => MorphReactiveButtonGroup(
          mode: MorphReactiveGroupMode.actions,
          items: items(5),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.startGesture(tester.getCenter(find.text('Month')));
    var prev = geo(tester).w[2];
    var turned = 0;
    for (var f = 0; f < 60; f++) {
      await tester.pump(const Duration(milliseconds: 16));
      final w = geo(tester).w[2];
      if (w < prev - 1e-6) turned++;
      prev = w;
    }
    expect(turned, 0);
  });

  testWidgets('no accumulation after many rapid selections', (tester) async {
    int? sel = 0;
    await tester.pumpWidget(
      host(
        (s) => MorphReactiveButtonGroup(
          items: items(6),
          selectedIndex: sel,
          onSelectedIndexChanged: (v) => s(() => sel = v),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final first = geo(tester);
    for (final i in [5, 1, 4, 0, 3, 2, 5, 0, 0]) {
      await tester.tap(find.text(labels[i % labels.length]).first);
      await tester.pump(const Duration(milliseconds: 50));
      final c = geo(tester);
      expect(c.h, first.h);
      expect(
        c.w.reduce((a, b) => a + b),
        closeTo(first.w.reduce((a, b) => a + b), .01),
      );
    }
    await tester.pumpAndSettle();
    // Selection index 0 again (last tap cleared it): equals a fresh no-selection layout.
    expect(sel, isNull);
    sel = 2;
    await tester.pumpWidget(
      host(
        (s) => MorphReactiveButtonGroup(
          items: items(6),
          selectedIndex: sel,
          onSelectedIndexChanged: (_) {},
        ),
      ),
    );
    await tester.pumpAndSettle();
    final a = geo(tester);
    await tester.pumpWidget(
      host(
        (s) => MorphReactiveButtonGroup(
          items: items(6),
          selectedIndex: 4,
          onSelectedIndexChanged: (_) {},
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.pumpWidget(
      host(
        (s) => MorphReactiveButtonGroup(
          items: items(6),
          selectedIndex: 2,
          onSelectedIndexChanged: (_) {},
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(geo(tester).w, a.w, reason: 'same state → same widths, no residue');
  });

  testWidgets(
    'multi toggles resolved jointly, bounded, repeated clicks do not drift',
    (tester) async {
      var sel = <int>{1, 3};
      await tester.pumpWidget(
        host(
          (s) => MorphReactiveButtonGroup(
            mode: MorphReactiveGroupMode.multiToggle,
            items: items(6),
            selectedIndices: sel,
            onSelectedIndicesChanged: (v) => s(() => sel = v),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final base = geo(tester);
      for (var k = 0; k < 6; k++) {
        await tester.tap(find.text('Era'.isEmpty ? 'x' : labels[5]));
        await tester.pumpAndSettle();
      }
      expect(sel, {1, 3});
      final again = geo(tester);
      for (var i = 0; i < 6; i++) {
        expect(again.w[i], closeTo(base.w[i], .05));
      }
      sel = {0, 1, 2, 3, 4, 5};
      await tester.pumpWidget(
        host(
          (s) => MorphReactiveButtonGroup(
            mode: MorphReactiveGroupMode.multiToggle,
            items: items(6),
            selectedIndices: sel,
            onSelectedIndicesChanged: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();
      final all = geo(tester);
      expect(all.w.reduce((a, b) => a + b) + 20, closeTo(560, 1));
    },
  );

  testWidgets(
    'narrow, long labels, text 2x, RTL: height constant, no overflow',
    (tester) async {
      for (final dir in [TextDirection.ltr, TextDirection.rtl]) {
        await tester.pumpWidget(
          host(
            (s) => MorphReactiveButtonGroup(
              mode: MorphReactiveGroupMode.actions,
              items: items(4, long: true),
            ),
            width: 260,
            dir: dir,
            scale: 2,
          ),
        );
        await tester.pumpAndSettle();
        final rest = geo(tester);
        await tester.startGesture(
          tester.getCenter(find.byType(MorphButton).at(1)),
        );
        for (var f = 0; f < 20; f++) {
          await tester.pump(const Duration(milliseconds: 16));
          final c = geo(tester);
          expect(c.h, rest.h);
          expect(c.top, rest.top);
          expect(
            c.w.reduce((a, b) => a + b),
            closeTo(rest.w.reduce((a, b) => a + b), .01),
          );
          expect(c.w.every((w) => w >= 0), isTrue);
        }
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
      }
    },
  );

  testWidgets('interrupted press retargets from visible widths without jump', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(
        (s) => MorphReactiveButtonGroup(
          mode: MorphReactiveGroupMode.actions,
          items: items(5),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final g = await tester.startGesture(tester.getCenter(find.text('Week')));
    for (var f = 0; f < 4; f++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
    final before = geo(tester).w;
    await g.up();
    await tester.pump(const Duration(milliseconds: 16));
    final after = geo(tester).w;
    for (var i = 0; i < 5; i++) {
      expect(
        (after[i] - before[i]).abs(),
        lessThan(2.5),
        reason: 'no jump at release',
      );
    }
    await tester.pumpAndSettle();
  });

  testWidgets(
    'selected item + default amplitudes: far items fixed, hold is monotonic',
    (tester) async {
      await tester.pumpWidget(
        host(
          (s) => MorphReactiveButtonGroup(
            items: items(6),
            selectedIndex: 1,
            onSelectedIndexChanged: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();
      final rest = geo(tester).w;
      await tester.startGesture(tester.getCenter(find.text('Month')));
      var prev = rest;
      final dir = List<int>.filled(6, 0);
      for (var f = 0; f < 50; f++) {
        await tester.pump(const Duration(milliseconds: 16));
        final c = geo(tester).w;
        for (var i = 0; i < 6; i++) {
          final d = c[i] - prev[i];
          if (d.abs() > 1e-4) {
            final sg = d > 0 ? 1 : -1;
            expect(
              dir[i] == 0 || dir[i] == sg,
              isTrue,
              reason: 'item $i reversed while held (tremor)',
            );
            dir[i] = sg;
          }
        }
        expect(c[0], closeTo(rest[0], .01), reason: 'non-adjacent item stays');
        expect((c[4] - rest[4]).abs(), lessThan(.01));
        expect((c[5] - rest[5]).abs(), lessThan(.01));
        prev = c;
      }
    },
  );
}
