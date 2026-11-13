import 'package:flutter/rendering.dart' show RenderParagraph;
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart' show MaterialApp, Scaffold;
import 'package:morph_expressive/morph_expressive.dart';

Widget _host(
  List<MorphButtonGroupAction> actions, {
  int? selected = 0,
  double? width,
  double? itemWidth,
  double textScale = 1,
  TextDirection direction = TextDirection.ltr,
  bool unbounded = false,
}) {
  Widget group = MorphButtonGroup(
    type: MorphButtonGroupType.connected,
    overflow: MorphButtonGroupOverflow.none,
    selectionRequired: true,
    selectedIndex: selected,
    itemWidth: itemWidth,
    onSelectedIndexChanged: (_) {},
    actions: actions,
  );
  if (width != null) group = SizedBox(width: width, child: group);
  if (unbounded) group = UnconstrainedBox(child: group);
  return MaterialApp(
    home: Directionality(
      textDirection: direction,
      child: MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
        child: Scaffold(
          body: Align(alignment: AlignmentDirectional.topStart, child: group),
        ),
      ),
    ),
  );
}

Finder _buttons() => find.byType(MorphButton).hitTestable();

bool _exceeds(WidgetTester tester, int i) => tester
    .renderObject<RenderParagraph>(
      find
          .descendant(of: _buttons().at(i), matching: find.byType(RichText))
          .first,
    )
    .didExceedMaxLines;

List<MorphButtonGroupAction> _labels(List<String> l) => [
  for (final s in l) MorphButtonGroupAction(label: Text(s)),
];

List<double> _widths(WidgetTester tester) => [
  for (var i = 0; i < tester.widgetList(_buttons()).length; i++)
    tester.getSize(_buttons().at(i)).width,
];

void _expectEqual(List<double> w) {
  for (final x in w) {
    expect(x, closeTo(w.first, .01));
    expect(x, greaterThan(0));
  }
}

void main() {
  testWidgets(
    'uneven labels share the widest width and the group does not fill',
    (tester) async {
      await tester.pumpWidget(
        _host(_labels(['A', 'Recently played', 'Mid']), width: 900),
      );
      await tester.pumpAndSettle();
      final w = _widths(tester);
      _expectEqual(w);
      final span =
          tester.getRect(_buttons().last).right -
          tester.getRect(_buttons().first).left;
      expect(span, lessThan(700), reason: 'does not fill the 800 dp viewport');
      // Widest label fits entirely.
      final label = tester.getRect(
        find
            .descendant(of: _buttons().at(1), matching: find.byType(RichText))
            .first,
      );
      final b = tester.getRect(_buttons().at(1));
      expect(label.left, greaterThanOrEqualTo(b.left));
      expect(label.right, lessThanOrEqualTo(b.right));
      expect(_exceeds(tester, 1), isFalse);
    },
  );

  testWidgets('icon + label content shares one width', (tester) async {
    await tester.pumpWidget(
      _host(
        [
          MorphButtonGroupAction(
            icon: const SizedBox(width: 18, height: 18),
            label: const Text('Favorites'),
          ),
          MorphButtonGroupAction(
            icon: const SizedBox(width: 18, height: 18),
            label: const Text('Recently played'),
          ),
          MorphButtonGroupAction(
            icon: const SizedBox(width: 18, height: 18),
            label: const Text('Paused'),
          ),
        ],
        selected: 1,
        width: 900,
      ),
    );
    await tester.pumpAndSettle();
    _expectEqual(_widths(tester));
    expect(_exceeds(tester, 1), isFalse);
  });

  testWidgets('hot content change recomputes the shared width', (tester) async {
    await tester.pumpWidget(
      _host(_labels(['One', 'Two', 'Three']), width: 700),
    );
    await tester.pumpAndSettle();
    final before = _widths(tester).first;
    await tester.pumpWidget(
      _host(
        _labels(['One', 'Two', 'Three and a much longer label']),
        width: 700,
      ),
    );
    await tester.pumpAndSettle();
    final after = _widths(tester);
    _expectEqual(after);
    expect(after.first, greaterThan(before + 40));
    await tester.pumpWidget(
      _host(_labels(['One', 'Two', 'Three']), width: 700),
    );
    await tester.pumpAndSettle();
    expect(_widths(tester).first, closeTo(before, .01));
  });

  testWidgets('selecting never changes the shared width', (tester) async {
    Widget build(int sel) => _host(
      [
        MorphButtonGroupAction(
          label: const Text('Play'),
          selectedLabel: const Text('Playing now'),
        ),
        const MorphButtonGroupAction(label: Text('B')),
        const MorphButtonGroupAction(label: Text('C')),
      ],
      selected: sel,
      width: 700,
    );
    await tester.pumpWidget(build(1));
    await tester.pumpAndSettle();
    final unselected = _widths(tester);
    await tester.pumpWidget(build(0));
    for (var f = 0; f < 20; f++) {
      await tester.pump(const Duration(milliseconds: 16));
      final w = _widths(tester);
      _expectEqual(w);
    }
    await tester.pumpAndSettle();
    expect(_widths(tester).first, closeTo(unselected.first, .01));
  });

  for (final scale in [1.0, 2.0]) {
    for (final dir in TextDirection.values) {
      testWidgets(
        'text x$scale ${dir.name}: equal widths, content inside, order',
        (tester) async {
          await tester.pumpWidget(
            _host(
              _labels(['Day', 'Week', 'Month']),
              selected: 1,
              width: 900,
              textScale: scale,
              direction: dir,
            ),
          );
          await tester.pumpAndSettle();
          _expectEqual(_widths(tester));
          final x0 = tester.getTopLeft(_buttons().at(0)).dx;
          final x2 = tester.getTopLeft(_buttons().at(2)).dx;
          expect(dir == TextDirection.ltr ? x0 < x2 : x0 > x2, isTrue);
          for (var i = 0; i < 3; i++) {
            final b = tester.getRect(_buttons().at(i));
            final t = tester.getRect(
              find.text(['Day', 'Week', 'Month'][i]).first,
            );
            expect(t.left, greaterThanOrEqualTo(b.left - .01));
            expect(t.right, lessThanOrEqualTo(b.right + .01));
          }
        },
      );
    }
  }

  testWidgets('limited width: budget per item, ellipsis, full semantics', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    const long = 'An extraordinarily long label that cannot possibly fit';
    await tester.pumpWidget(_host(_labels(['A', long, 'C']), width: 210));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    final w = _widths(tester);
    _expectEqual(w);
    expect(
      tester.getSize(find.byType(MorphButtonGroup)).width,
      lessThanOrEqualTo(210.01),
    );
    final para = tester.renderObject<RenderParagraph>(
      find
          .descendant(of: _buttons().at(1), matching: find.byType(RichText))
          .first,
    );
    expect(para.size.height, lessThan(20), reason: 'single line');
    expect(para.size.width, lessThanOrEqualTo(w.first + .01));
    expect(para.didExceedMaxLines || para.size.width < 600, isTrue);
    expect(find.bySemanticsLabel(RegExp('extraordinarily')), findsWidgets);
    handle.dispose();
  });

  testWidgets('tiny constraints never produce negative widths or overflow', (
    tester,
  ) async {
    await tester.pumpWidget(_host(_labels(['One', 'Two', 'Three']), width: 20));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    for (final x in _widths(tester)) {
      expect(x, greaterThanOrEqualTo(0));
    }
  });

  testWidgets(
    'explicit itemWidth wins over automatic, clamped by constraints',
    (tester) async {
      await tester.pumpWidget(
        _host(_labels(['One', 'Two', 'Three']), width: 700, itemWidth: 120),
      );
      await tester.pumpAndSettle();
      for (final x in _widths(tester)) {
        expect(x, closeTo(120, .01));
      }
      await tester.pumpWidget(
        _host(_labels(['One', 'Two', 'Three']), width: 200, itemWidth: 120),
      );
      await tester.pumpAndSettle();
      final w = _widths(tester);
      _expectEqual(w);
      expect(w.first, lessThan(120));
      // Per-action width keeps priority for that action only.
      await tester.pumpWidget(
        _host(const [
          MorphButtonGroupAction(label: Text('One')),
          MorphButtonGroupAction(label: Text('Two'), width: 150),
          MorphButtonGroupAction(label: Text('Three')),
        ], width: 700),
      );
      await tester.pumpAndSettle();
      final p = _widths(tester);
      expect(p[1], closeTo(150, .01));
      expect(p[0], closeTo(p[2], .01));
    },
  );

  testWidgets('unbounded width uses the finite natural width', (tester) async {
    await tester.pumpWidget(
      _host(_labels(['One', 'Recently played', 'Three']), unbounded: true),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    _expectEqual(_widths(tester));
    expect(
      tester.getSize(find.byType(MorphButtonGroup)).width.isFinite,
      isTrue,
    );
  });

  testWidgets('press keeps shared widths and legible labels in every frame', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(_labels(['Day', 'Week', 'Month']), selected: 1, width: 700),
    );
    await tester.pumpAndSettle();
    final rest = _widths(tester);
    final g = await tester.startGesture(tester.getCenter(_buttons().at(0)));
    for (var f = 0; f < 12; f++) {
      await tester.pump(const Duration(milliseconds: 16));
      final w = _widths(tester);
      for (var i = 0; i < 3; i++) {
        expect(w[i], closeTo(rest[i], .01));
        final b = tester.getRect(_buttons().at(i));
        final t = tester.getRect(find.text(['Day', 'Week', 'Month'][i]).first);
        expect(t.left, greaterThanOrEqualTo(b.left));
        expect(t.right, lessThanOrEqualTo(b.right));
      }
    }
    await g.up();
    await tester.pumpAndSettle();
  });
}
