import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart' show MaterialApp, Scaffold;
import 'package:morph_expressive/morph_expressive.dart';

Widget _host({
  double? spacing,
  double? themeGap,
  double width = 900,
  Axis direction = Axis.horizontal,
  TextDirection textDirection = TextDirection.ltr,
  List<String> labels = const ['Day', 'Week', 'Month'],
}) {
  final theme = themeGap == null
      ? MorphThemeData.light()
      : MorphThemeData.light().copyWith(
          buttonGroupTheme: MorphButtonGroupTheme(connectedGap: themeGap),
        );
  return MaterialApp(
    home: MorphTheme(
      data: theme,
      child: Directionality(
        textDirection: textDirection,
        child: Scaffold(
          body: Align(
            alignment: AlignmentDirectional.topStart,
            child: SizedBox(
              width: direction == Axis.horizontal ? width : 200,
              child: MorphButtonGroup(
                type: MorphButtonGroupType.connected,
                overflow: MorphButtonGroupOverflow.none,
                direction: direction,
                spacing: spacing,
                selectedIndex: 1,
                selectionRequired: true,
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
  );
}

Finder _b() => find.byType(MorphButton).hitTestable();

List<double> _gaps(WidgetTester tester, {bool vertical = false}) {
  final out = <double>[];
  for (var i = 0; i < 2; i++) {
    final a = tester.getRect(_b().at(i)), b = tester.getRect(_b().at(i + 1));
    out.add(
      vertical
          ? b.top - a.bottom
          : (b.left - a.right).abs() < (a.left - b.right).abs()
          ? b.left - a.right
          : a.left - b.right,
    );
  }
  return out;
}

void main() {
  testWidgets('default gap is 4 dp and uniform', (tester) async {
    await tester.pumpWidget(_host());
    await tester.pumpAndSettle();
    for (final g in _gaps(tester)) {
      expect(g, closeTo(4, .01));
    }
  });

  testWidgets('precedence: widget override > theme > default', (tester) async {
    await tester.pumpWidget(_host(themeGap: 8));
    await tester.pumpAndSettle();
    expect(_gaps(tester).first, closeTo(8, .01));
    await tester.pumpWidget(_host(themeGap: 8, spacing: 2));
    await tester.pumpAndSettle();
    expect(_gaps(tester).first, closeTo(2, .01));
    await tester.pumpWidget(_host(spacing: 12));
    await tester.pumpAndSettle();
    expect(_gaps(tester).first, closeTo(12, .01));
  });

  testWidgets('zero gap is allowed and buttons keep the shared width', (
    tester,
  ) async {
    await tester.pumpWidget(_host(spacing: 0));
    await tester.pumpAndSettle();
    for (final g in _gaps(tester)) {
      expect(g, closeTo(0, .01));
    }
    final w = [for (var i = 0; i < 3; i++) tester.getSize(_b().at(i)).width];
    expect(w[0], closeTo(w[1], .01));
    expect(w[1], closeTo(w[2], .01));
  });

  testWidgets('theme gap 0 and negative widget values never go negative', (
    tester,
  ) async {
    await tester.pumpWidget(_host(themeGap: 0));
    await tester.pumpAndSettle();
    expect(_gaps(tester).first, closeTo(0, .01));
    await tester.pumpWidget(_host(spacing: -6));
    await tester.pumpAndSettle();
    expect(_gaps(tester).first, greaterThanOrEqualTo(0));
  });

  for (final gap in [0.0, 4.0, 8.0]) {
    testWidgets('gap $gap dp is deducted from the width budget, labels stay', (
      tester,
    ) async {
      // Tight budget: items shrink to (width - gaps) / 3 and ellipsize.
      const width = 210.0;
      await tester.pumpWidget(
        _host(
          spacing: gap,
          width: width,
          labels: const ['Alpha', 'A much longer label here', 'Omega'],
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      final first = tester.getRect(_b().first),
          last = tester.getRect(_b().last);
      expect(last.right - first.left, lessThanOrEqualTo(width + .01));
      final w = [for (var i = 0; i < 3; i++) tester.getSize(_b().at(i)).width];
      expect(w[0], closeTo(w[1], .01));
      expect(w[0], closeTo((width - 2 * gap) / 3, .5));
      // Labels stay inside their buttons during a press.
      final g = await tester.startGesture(tester.getCenter(_b().at(0)));
      for (var f = 0; f < 8; f++) {
        await tester.pump(const Duration(milliseconds: 16));
        for (var i = 0; i < 3; i++) {
          final b = tester.getRect(_b().at(i));
          final t = tester.getRect(
            find
                .descendant(of: _b().at(i), matching: find.byType(RichText))
                .first,
          );
          expect(t.left, greaterThanOrEqualTo(b.left - .01));
          expect(t.right, lessThanOrEqualTo(b.right + .01));
        }
      }
      await g.up();
      await tester.pumpAndSettle();
    });
  }

  testWidgets('RTL keeps the same gap', (tester) async {
    await tester.pumpWidget(
      _host(spacing: 8, textDirection: TextDirection.rtl),
    );
    await tester.pumpAndSettle();
    for (final g in _gaps(tester)) {
      expect(g.abs(), closeTo(8, .01));
    }
  });

  testWidgets('vertical groups apply the gap on their main axis', (
    tester,
  ) async {
    await tester.pumpWidget(_host(spacing: 8, direction: Axis.vertical));
    await tester.pumpAndSettle();
    for (final g in _gaps(tester, vertical: true)) {
      expect(g, closeTo(8, .01));
    }
  });

  test('theme token integrates with copyWith and lerp', () {
    const a = MorphButtonGroupTheme(),
        b = MorphButtonGroupTheme(connectedGap: 8);
    expect(a.connectedGap, 4);
    expect(a.copyWith(connectedGap: 0).connectedGap, 0);
    expect(a.lerp(b, .5).connectedGap, 6);
    expect(
      a
          .metricsFor(
            MorphButtonSize.sm,
            MorphButtonGroupDensity.regular,
            isConnected: true,
          )
          .spacing,
      4,
    );
  });
}
