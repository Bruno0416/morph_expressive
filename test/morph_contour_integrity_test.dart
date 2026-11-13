import 'package:flutter_test/flutter_test.dart';
import 'package:morph_expressive/morph_expressive.dart';

List<Offset> _poly(MorphContour c, [int n = 12]) => [
  for (final cu in c.curves)
    for (var i = 0; i < n; i++) cu.pointAt(i / n),
];

bool _cross(Offset a, Offset b, Offset c, Offset d) {
  double cr(Offset o, Offset p, Offset q) =>
      (p.dx - o.dx) * (q.dy - o.dy) - (p.dy - o.dy) * (q.dx - o.dx);
  return cr(a, b, c) * cr(a, b, d) < 0 && cr(c, d, a) * cr(c, d, b) < 0;
}

int _selfCrossings(List<Offset> p) {
  var k = 0;
  final n = p.length;
  for (var i = 0; i < n; i++) {
    for (var j = i + 2; j < n; j++) {
      if (i == 0 && j == n - 1) continue;
      if (_cross(p[i], p[(i + 1) % n], p[j], p[(j + 1) % n])) k++;
    }
  }
  return k;
}

MorphContour _c(MorphShapeKind k) => MorphShapeCatalog.fromKind(k).contour;

void main() {
  const engine = MorphGeometryEngine();

  // Pairs published in the lab / loader / shape buttons.
  final published = <(MorphShapeKind, MorphShapeKind)>[
    (MorphShapeKind.clover4Leaf, MorphShapeKind.gem),
    (MorphShapeKind.gem, MorphShapeKind.clover4Leaf),
    (MorphShapeKind.cookie7Sided, MorphShapeKind.softBurst),
    (MorphShapeKind.softBurst, MorphShapeKind.cookie7Sided),
    (MorphShapeKind.cookie7Sided, MorphShapeKind.pentagon),
    (MorphShapeKind.oval, MorphShapeKind.softBurst),
    (MorphShapeKind.pentagon, MorphShapeKind.softBurst),
    (MorphShapeKind.circle, MorphShapeKind.cookie7Sided),
    // Default loader cycle, including the wrap-around.
    (MorphShapeKind.softBurst, MorphShapeKind.cookie9Sided),
    (MorphShapeKind.cookie9Sided, MorphShapeKind.pentagon),
    (MorphShapeKind.pentagon, MorphShapeKind.pill),
    (MorphShapeKind.pill, MorphShapeKind.sunny),
    (MorphShapeKind.sunny, MorphShapeKind.cookie4Sided),
    (MorphShapeKind.cookie4Sided, MorphShapeKind.oval),
    (MorphShapeKind.oval, MorphShapeKind.softBurst),
  ];

  for (final (a, b) in published) {
    test(
      'published pair ${a.name} → ${b.name}: closed, simple, same winding',
      () {
        final prepared = engine.prepare(_c(a), _c(b));
        final area0 = prepared.at(0).signedArea.sign;
        for (var i = 0; i <= 20; i++) {
          final contour = prepared.at(i / 20); // constructor validates closure
          expect(contour.signedArea.sign, area0, reason: 'winding flips at $i');
          expect(
            _selfCrossings(_poly(contour)),
            0,
            reason: 'self-cross at ${i / 20}',
          );
          // No spike: the contour never leaves the union of endpoint extents by
          // more than 2 %.
          final r = contour.maxRadius();
          final limit = [
            _c(a),
            _c(b),
          ].map((c) => c.maxRadius()).reduce((x, y) => x > y ? x : y);
          expect(r, lessThanOrEqualTo(limit * 1.02));
        }
      },
    );
  }

  test('A → B → C retargets keep closure, simplicity and bounded segments', () {
    final a = _c(MorphShapeKind.cookie7Sided),
        b = _c(MorphShapeKind.softBurst),
        c = _c(MorphShapeKind.pentagon);
    var visible = a;
    var counts = <int>[];
    final targets = [b, c, a, b, c, a, b, c];
    for (var step = 0; step < targets.length; step++) {
      final prepared = engine.prepare(visible, targets[step]);
      // Interrupt mid-way (45 %) each time, like repeated press/release.
      visible = prepared.at(.45);
      counts.add(visible.curves.length);
      expect(_selfCrossings(_poly(visible)), 0, reason: 'step $step');
    }
    expect(counts.reduce((x, y) => x > y ? x : y), lessThanOrEqualTo(64));
  });

  test('interrupted morph starts exactly at the visible contour', () {
    final prepared = engine.prepare(
      _c(MorphShapeKind.cookie7Sided),
      _c(MorphShapeKind.softBurst),
    );
    final visible = prepared.at(.37);
    final next = engine.prepare(visible, _c(MorphShapeKind.pentagon)).at(0);
    final p = _poly(visible, 8), q = _poly(next, 8);
    // Same boundary: every point of the visible contour is on the new start.
    var worst = 0.0;
    for (final point in p) {
      var best = double.infinity;
      for (final other in q) {
        best = best < (point - other).distance
            ? best
            : (point - other).distance;
      }
      worst = worst > best ? worst : best;
    }
    expect(worst, lessThan(.02));
  });
}
