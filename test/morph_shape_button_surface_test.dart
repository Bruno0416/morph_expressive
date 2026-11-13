import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart' show MaterialApp, Scaffold;
import 'package:morph_expressive/morph_expressive.dart';

import 'helpers/raster_capture.dart';

const _bg = Color(0xffe02020), _fg = Color(0xffffffff);
final _key = GlobalKey();
final _iconKey = GlobalKey();

Widget _button({
  MorphShape? shape,
  MorphShape? pressedShape,
  bool rotate = false,
  Duration period = const Duration(seconds: 4),
  MorphShapeRotationDirection direction = MorphShapeRotationDirection.clockwise,
  double scale = .96,
  VoidCallback? onPressed,
  bool enabled = true,
  bool reduced = false,
  bool tickers = true,
  Widget? sibling,
}) => MaterialApp(
  home: MorphMotionScope(
    reduceMotion: reduced,
    child: TickerMode(
      enabled: tickers,
      child: Scaffold(
        body: Align(
          alignment: Alignment.topLeft,
          child: RepaintBoundary(
            key: _key,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  MorphShapeButton(
                    size: 96,
                    shape: shape ?? MorphShapeCatalog.circle,
                    pressedShape: pressedShape,
                    rotationEnabled: rotate,
                    rotationDuration: period,
                    rotationDirection: direction,
                    pressedScale: scale,
                    enabled: enabled,
                    backgroundColor: _bg,
                    foregroundColor: _fg,
                    onPressed: onPressed ?? () {},
                    child: SizedBox(key: _iconKey, width: 20, height: 20),
                  ),
                  ?sibling,
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  ),
);

bool _isSurface(Raster r, int x, int y) => r.alpha(x, y) > 128;

Future<Set<int>> _mask(WidgetTester tester) async {
  final r = await captureRaster(tester, _key);
  return {
    for (var y = 0; y < r.height; y++)
      for (var x = 0; x < r.width; x++)
        if (_isSurface(r, x, y)) y * r.width + x,
  };
}

Rect _bbox(Set<int> mask, int width) {
  var l = 1 << 30, t = 1 << 30, rr = -1, b = -1;
  for (final i in mask) {
    final x = i % width, y = i ~/ width;
    if (x < l) l = x;
    if (x > rr) rr = x;
    if (y < t) t = y;
    if (y > b) b = y;
  }
  return Rect.fromLTRB(l.toDouble(), t.toDouble(), rr + 1.0, b + 1.0);
}

double _difference(Set<int> a, Set<int> b) =>
    a.difference(b).union(b.difference(a)).length / a.union(b).length;

void main() {
  const width = 144; // 96 + 2 * 24
  testWidgets(
    'tap compresses uniformly (0.96), keeps shape, activates on up only',
    (tester) async {
      var taps = 0;
      await tester.pumpWidget(_button(onPressed: () => taps++));
      final rest = _bbox(await _mask(tester), width);
      expect(rest.width, closeTo(96, 1.5));
      final icon = tester.getRect(find.byKey(_iconKey));
      final g = await tester.startGesture(
        tester.getCenter(find.byType(MorphShapeButton)),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      expect(taps, 0, reason: 'down is visual only');
      final pressed = _bbox(await _mask(tester), width);
      expect(pressed.width / rest.width, closeTo(.96, .02));
      expect(pressed.height / rest.height, closeTo(.96, .02));
      expect(
        tester.getRect(find.byKey(_iconKey)),
        icon,
        reason: 'content static',
      );
      await g.up();
      await tester.pump();
      expect(taps, 1);
      await tester.pump(const Duration(milliseconds: 400));
      final back = _bbox(await _mask(tester), width);
      expect(back.width / rest.width, closeTo(1, .015));
    },
  );

  testWidgets(
    'release profile is reversible: halfway interrupts from visible size',
    (tester) async {
      await tester.pumpWidget(_button());
      final rest = _bbox(await _mask(tester), width).width;
      final g = await tester.startGesture(
        tester.getCenter(find.byType(MorphShapeButton)),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 40)); // mid press (90 ms)
      final mid = _bbox(await _mask(tester), width).width;
      expect(mid, lessThan(rest));
      expect(mid, greaterThan(rest * .96 - .5));
      await g.up();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 20));
      final afterRelease = _bbox(await _mask(tester), width).width;
      // No snap back to 1 nor to the pressed value: continues from visible size.
      expect((afterRelease - mid).abs(), lessThan(rest * .03));
      await tester.pumpAndSettle();
    },
  );

  testWidgets('pressedShape is opt-in: null keeps the shape, set morphs it', (
    tester,
  ) async {
    for (final morph in [false, true]) {
      await tester.pumpWidget(
        _button(
          pressedShape: morph
              ? MorphShapeCatalog.fromKind(MorphShapeKind.triangle)
              : null,
        ),
      );
      final rest = (await _mask(tester)).length;
      final g = await tester.startGesture(
        tester.getCenter(find.byType(MorphShapeButton)),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      final pressed = (await _mask(tester)).length;
      if (morph) {
        expect(pressed / rest, lessThan(.8));
      } else {
        expect(pressed / rest, closeTo(.96 * .96, .03));
      }
      await g.up();
      await tester.pumpAndSettle();
    }
  });

  testWidgets('rotation spins the surface only; icon, layout and bounds stay', (
    tester,
  ) async {
    await tester.pumpWidget(
      _button(
        shape: MorphShapeCatalog.fromKind(MorphShapeKind.triangle),
        rotate: true,
        sibling: const SizedBox(width: 0, height: 10),
      ),
    );
    final icon = tester.getRect(find.byKey(_iconKey));
    final buttonRect = tester.getRect(find.byType(MorphShapeButton));
    final sibling = tester.getRect(find.byType(SizedBox).last);
    final first = await _mask(tester);
    await tester.pump(const Duration(seconds: 1)); // quarter turn
    final later = await _mask(tester);
    expect(_difference(first, later), greaterThan(.1), reason: 'surface moved');
    expect(tester.getRect(find.byKey(_iconKey)), icon);
    expect(tester.getRect(find.byType(MorphShapeButton)), buttonRect);
    expect(tester.getRect(find.byType(SizedBox).last), sibling);
    // Painted pixels never leave the button box (stable envelope).
    final box = buttonRect.shift(-tester.getTopLeft(find.byKey(_key)));
    for (final i in later) {
      final x = i % width, y = i ~/ width;
      expect(
        box.inflate(1.5).contains(Offset(x + .5, y + .5)),
        isTrue,
        reason: 'pixel $x,$y outside $box',
      );
    }
  });

  testWidgets('speed change and tap keep the visible rotation phase', (
    tester,
  ) async {
    await tester.pumpWidget(
      _button(
        shape: MorphShapeCatalog.fromKind(MorphShapeKind.triangle),
        rotate: true,
        period: const Duration(seconds: 4),
      ),
    );
    await tester.pump(const Duration(milliseconds: 1000));
    final before = await _mask(tester);
    await tester.pumpWidget(
      _button(
        shape: MorphShapeCatalog.fromKind(MorphShapeKind.triangle),
        rotate: true,
        period: const Duration(seconds: 1),
      ),
    );
    await tester.pump(const Duration(milliseconds: 16));
    final after = await _mask(tester);
    expect(_difference(before, after), lessThan(.12), reason: 'phase kept');
    // Direction change also continues from the visible angle.
    await tester.pumpWidget(
      _button(
        shape: MorphShapeCatalog.fromKind(MorphShapeKind.triangle),
        rotate: true,
        period: const Duration(seconds: 1),
        direction: MorphShapeRotationDirection.counterClockwise,
      ),
    );
    await tester.pump(const Duration(milliseconds: 16));
    expect(_difference(after, await _mask(tester)), lessThan(.12));
    // Tapping does not restart the phase.
    final g = await tester.startGesture(
      tester.getCenter(find.byType(MorphShapeButton)),
    );
    await tester.pump(const Duration(milliseconds: 16));
    final pressed = await _mask(tester);
    expect(_difference(after, pressed), lessThan(.35));
    await g.up();
    await tester.pump(const Duration(milliseconds: 300));
  });

  testWidgets(
    'ticker lifecycle: stops for reduced motion, TickerMode, disable, dispose',
    (tester) async {
      await tester.pumpWidget(_button(rotate: true));
      await tester.pump(const Duration(milliseconds: 50));
      expect(tester.binding.transientCallbackCount, greaterThan(0));
      await tester.pumpWidget(_button(rotate: false));
      await tester.pump(const Duration(milliseconds: 400));
      expect(tester.binding.transientCallbackCount, 0, reason: 'rotation off');
      await tester.pumpWidget(_button(rotate: true, reduced: true));
      await tester.pump(const Duration(milliseconds: 400));
      expect(
        tester.binding.transientCallbackCount,
        0,
        reason: 'reduced motion',
      );
      await tester.pumpWidget(_button(rotate: true, tickers: false));
      await tester.pump(const Duration(milliseconds: 400));
      expect(
        tester.binding.transientCallbackCount,
        0,
        reason: 'TickerMode off',
      );
      await tester.pumpWidget(_button(rotate: true));
      await tester.pump(const Duration(milliseconds: 400));
      expect(tester.binding.transientCallbackCount, greaterThan(0));
      await tester.pumpWidget(const SizedBox());
      await tester.pump();
      expect(tester.binding.transientCallbackCount, 0, reason: 'disposed');
    },
  );

  testWidgets('reduced motion: static compression feedback, no rotation', (
    tester,
  ) async {
    var taps = 0;
    await tester.pumpWidget(
      _button(reduced: true, rotate: true, onPressed: () => taps++),
    );
    final rest = _bbox(await _mask(tester), width);
    final g = await tester.startGesture(
      tester.getCenter(find.byType(MorphShapeButton)),
    );
    await tester.pump();
    final pressed = _bbox(await _mask(tester), width);
    expect(pressed.width / rest.width, closeTo(.96, .02));
    await g.up();
    await tester.pump();
    expect(taps, 1);
  });

  testWidgets('scroll cancel and disable release compression without action', (
    tester,
  ) async {
    var taps = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ListView(
            children: [
              MorphShapeButton(
                size: 96,
                shape: MorphShapeCatalog.circle,
                backgroundColor: _bg,
                onPressed: () => taps++,
              ),
              const SizedBox(height: 1500),
            ],
          ),
        ),
      ),
    );
    final g = await tester.startGesture(
      tester.getCenter(find.byType(MorphShapeButton)),
    );
    await tester.pump(const Duration(milliseconds: 200));
    await g.moveBy(const Offset(0, -120));
    await tester.pump();
    await g.up();
    await tester.pumpAndSettle();
    expect(taps, 0);
    // Disable while held.
    var enabled = true;
    late StateSetter set;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (c, s) {
              set = s;
              return MorphShapeButton(
                size: 96,
                shape: MorphShapeCatalog.circle,
                enabled: enabled,
                onPressed: () => taps++,
              );
            },
          ),
        ),
      ),
    );
    final h = await tester.startGesture(
      tester.getCenter(find.byType(MorphShapeButton)),
    );
    await tester.pump(const Duration(milliseconds: 200));
    set(() => enabled = false);
    await tester.pump(const Duration(milliseconds: 300));
    await h.up();
    await tester.pumpAndSettle();
    expect(taps, 0);
  });

  testWidgets('semantics and invalid configuration', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MorphShapeButton(
            shape: MorphShapeCatalog.circle,
            selected: true,
            semanticLabel: 'Fav',
            onPressed: () {},
          ),
        ),
      ),
    );
    expect(
      tester.getSemantics(find.bySemanticsLabel('Fav')),
      matchesSemantics(
        label: 'Fav',
        isButton: true,
        isSelected: true,
        isEnabled: true,
        hasEnabledState: true,
        hasSelectedState: true,
        hasTapAction: true,
        hasFocusAction: true,
        isFocusable: true,
      ),
    );
    handle.dispose();
    for (final bad in [
      (double scale) => MorphShapeButton(
        shape: MorphShapeCatalog.circle,
        pressedScale: scale,
      ),
    ]) {
      await tester.pumpWidget(MaterialApp(home: bad(.2)));
      expect(tester.takeException(), isA<ArgumentError>());
    }
  });
}
