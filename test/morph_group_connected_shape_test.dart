import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart' show MaterialApp, Scaffold;
import 'package:morph_expressive/components/buttons/components/morph_radius_and_padding_motion.dart';
import 'package:morph_expressive/morph_expressive.dart';

import 'helpers/raster_capture.dart';

Widget _host({
  required int? selected,
  MorphButtonGroupType type = MorphButtonGroupType.connected,
  double width = 300,
  TextDirection direction = TextDirection.ltr,
  double textScale = 1,
  GlobalKey? key,
  List<String> labels = const ['One', 'Two', 'Three'],
}) => MaterialApp(
  home: Directionality(
    textDirection: direction,
    child: MediaQuery(
      data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
      child: Scaffold(
        body: Align(
          alignment: AlignmentDirectional.topStart,
          child: RepaintBoundary(
            key: key,
            child: SizedBox(
              width: width,
              child: MorphButtonGroup(
                type: type,
                overflow: MorphButtonGroupOverflow.none,
                selectionRequired: true,
                selectedIndex: selected,
                onSelectedIndexChanged: (_) {},
                actions: [
                  for (final l in labels)
                    MorphButtonGroupAction(label: Text(l)),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  ),
);

BorderRadius _radius(WidgetTester tester, int i) => tester
    .widget<MorphRadiusAndPaddingMotion>(
      find
          .descendant(
            of: find.byType(MorphButton).at(i),
            matching: find.byType(MorphRadiusAndPaddingMotion),
          )
          .first,
    )
    .targetRadius;

void main() {
  for (final selected in [0, 1, 2]) {
    for (final dir in TextDirection.values) {
      testWidgets('connected radii: selected $selected ${dir.name}', (
        tester,
      ) async {
        await tester.pumpWidget(_host(selected: selected, direction: dir));
        await tester.pumpAndSettle();
        final theme = MorphTheme.of(
          tester.element(find.byType(MorphButtonGroup)),
        ).buttonGroupTheme;
        final inner = theme.connectedInnerRadiusFor(MorphButtonSize.sm);
        final h = tester.getSize(find.byType(MorphButton).first).height;
        bool near(double a, double b) => (a - b).abs() < 1;
        final ltr = dir == TextDirection.ltr;
        for (var i = 0; i < 3; i++) {
          final r = _radius(tester, i);
          final corners = [
            r.topLeft.x,
            r.topRight.x,
            r.bottomRight.x,
            r.bottomLeft.x,
          ];
          if (i == selected) {
            // Pill wherever it sits, including the center.
            expect(
              corners.every((c) => near(c, h / 2)),
              isTrue,
              reason: 'selected $i corners $corners',
            );
            continue;
          }
          // Visual index: LTR first = left; RTL first = right.
          final first = i == 0, last = i == 2;
          final leftOuter = ltr ? first : last;
          final rightOuter = ltr ? last : first;
          expect(
            near(r.topLeft.x, leftOuter ? h / 2 : inner),
            isTrue,
            reason: 'i=$i tl ${r.topLeft.x}',
          );
          expect(near(r.bottomLeft.x, leftOuter ? h / 2 : inner), isTrue);
          expect(
            near(r.topRight.x, rightOuter ? h / 2 : inner),
            isTrue,
            reason: 'i=$i tr ${r.topRight.x}',
          );
          expect(near(r.bottomRight.x, rightOuter ? h / 2 : inner), isTrue);
        }
      });
    }
  }

  testWidgets('standard (gapped) group is not a connected group', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(selected: 1, type: MorphButtonGroupType.standard),
    );
    await tester.pumpAndSettle();
    final gap =
        tester.getRect(find.byType(MorphButton).at(1)).left -
        tester.getRect(find.byType(MorphButton).at(0)).right;
    expect(gap, greaterThan(3));
  });

  for (final scale in [1.0, 2.0]) {
    for (final selected in [0, 1, 2]) {
      testWidgets(
        'standard squish keeps total width and label inside, x$scale sel $selected',
        (tester) async {
          await tester.pumpWidget(
            _host(
              selected: selected,
              type: MorphButtonGroupType.standard,
              width: 600,
              textScale: scale,
            ),
          );
          await tester.pumpAndSettle();
          final rest = tester.getRect(find.byType(MorphButtonGroup)).width;
          final restWidths = [
            for (var i = 0; i < 3; i++)
              tester.getSize(find.byType(MorphButton).at(i)).width,
          ];
          for (var target = 0; target < 3; target++) {
            final g = await tester.startGesture(
              tester.getCenter(find.byType(MorphButton).at(target)),
            );
            for (var f = 0; f < 14; f++) {
              await tester.pump(const Duration(milliseconds: 16));
              expect(
                tester.getRect(find.byType(MorphButtonGroup)).width,
                closeTo(rest, .01),
              );
              for (var i = 0; i < 3; i++) {
                final b = tester.getRect(find.byType(MorphButton).at(i));
                expect(b.width, greaterThan(0));
                if (i != target) {
                  // Never gives up more than the bounded slack.
                  expect(restWidths[i] - b.width, lessThanOrEqualTo(14.01));
                }
                final label = tester.getRect(
                  find.text(['One', 'Two', 'Three'][i]).first,
                );
                // Label stays within its segment in every frame (no clipping).
                expect(label.left, greaterThanOrEqualTo(b.left - .01));
                expect(label.right, lessThanOrEqualTo(b.right + .01));
              }
            }
            await g.up();
            await tester.pumpAndSettle();
          }
        },
      );
    }
  }

  testWidgets('label pixels are painted in every squish frame (raster)', (
    tester,
  ) async {
    final key = GlobalKey();
    await tester.pumpWidget(
      _host(
        selected: 1,
        type: MorphButtonGroupType.standard,
        width: 600,
        key: key,
      ),
    );
    await tester.pumpAndSettle();
    final g = await tester.startGesture(
      tester.getCenter(find.byType(MorphButton).at(0)),
    );
    for (var f = 0; f < 8; f++) {
      await tester.pump(const Duration(milliseconds: 20));
      final origin = tester.getTopLeft(find.byKey(key));
      final r = await captureRaster(tester, key);
      for (var i = 0; i < 3; i++) {
        final seg = tester
            .getRect(find.byType(MorphButton).at(i))
            .shift(-origin);
        final label = tester
            .getRect(find.text(['One', 'Two', 'Three'][i]).first)
            .shift(-origin);
        // The label box has more than one distinct color: glyph vs fill.
        final colors = <int>{};
        for (var y = label.top.ceil(); y < label.bottom.floor(); y++) {
          for (var x = label.left.ceil(); x < label.right.floor(); x++) {
            if (x < seg.left || x >= seg.right) continue;
            colors.add(
              r.channel(x, y, 0) << 16 |
                  r.channel(x, y, 1) << 8 |
                  r.channel(x, y, 2),
            );
          }
        }
        expect(
          colors.length,
          greaterThan(1),
          reason: 'label $i frame $f not painted',
        );
      }
    }
    await g.up();
    await tester.pumpAndSettle();
  });
}
