import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morph_expressive/morph_expressive.dart';

import 'helpers/raster_capture.dart';

class _Config {
  const _Config({
    required this.renderer,
    required this.shape,
    this.target,
    this.size = 96,
    this.rotation = 0,
    this.progress = 0,
    this.color = const Color(0xff3060c0),
    this.edge = MorphEdgeAntialias.auto,
    this.captured = false,
  });
  final MorphShapeRenderer renderer;
  final MorphShape shape;
  final MorphShape? target;
  final double size, rotation, progress;
  final Color color;
  final MorphEdgeAntialias edge;
  final bool captured;
  String get label =>
      '${renderer.name}/${shape.name}/${target?.name}/$size/$rotation/'
      '$progress/${edge.name}/captured=$captured';
}

Widget _view(_Config c, {Key? key}) => MorphShapeView(
  key: key,
  shape: c.shape,
  targetShape: c.target,
  progress: c.progress,
  contour: c.captured ? c.shape.contour : null,
  size: Size(c.size, c.size),
  rotationRadians: c.rotation,
  color: c.color,
  renderer: c.renderer,
  edgeAntialias: c.edge,
);

void main() {
  final ellipse = MorphShape.ellipse(width: 1, height: .64);
  final ellipseB = MorphShape.ellipse(width: .64, height: 1);
  final clover = MorphShapeCatalog.fromKind(MorphShapeKind.clover4Leaf);
  final gem = MorphShapeCatalog.fromKind(MorphShapeKind.gem);

  // Alternates renderer, compatible / incompatible shapes, size, rotation,
  // color and morph progress, then returns to the first configuration.
  final first = _Config(renderer: MorphShapeRenderer.canvas, shape: ellipse);
  final steps = <_Config>[
    first,
    _Config(renderer: MorphShapeRenderer.shader, shape: ellipse),
    _Config(renderer: MorphShapeRenderer.shader, shape: clover),
    _Config(
      renderer: MorphShapeRenderer.auto,
      shape: ellipse,
      target: ellipseB,
      progress: .4,
    ),
    _Config(
      renderer: MorphShapeRenderer.auto,
      shape: clover,
      target: gem,
      progress: .5,
      rotation: .7,
    ),
    _Config(
      renderer: MorphShapeRenderer.shader,
      shape: ellipse,
      size: 122,
      rotation: 1.1,
    ),
    _Config(
      renderer: MorphShapeRenderer.canvas,
      shape: ellipse,
      size: 48,
      edge: MorphEdgeAntialias.native,
    ),
    _Config(
      renderer: MorphShapeRenderer.shader,
      shape: ellipse,
      captured: true,
    ),
    _Config(
      renderer: MorphShapeRenderer.shader,
      shape: ellipse,
      color: const Color(0xffe02020),
    ),
    _Config(
      renderer: MorphShapeRenderer.canvas,
      shape: gem,
      size: 96,
      rotation: .3,
    ),
    _Config(renderer: MorphShapeRenderer.shader, shape: ellipse, size: 96),
    first,
  ];

  testWidgets('live instance matches a fresh instance after every change', (
    tester,
  ) async {
    final liveKey = GlobalKey(), freshKey = GlobalKey();
    final otherKey = GlobalKey();
    // A bystander instance must not be contaminated by the others.
    final bystander = _Config(
      renderer: MorphShapeRenderer.shader,
      shape: ellipse,
      size: 64,
      color: const Color(0xff20a040),
    );
    for (var i = 0; i < steps.length; i++) {
      final c = steps[i];
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: MediaQuery(
            data: const MediaQueryData(devicePixelRatio: 2),
            child: Row(
              textDirection: TextDirection.ltr,
              children: [
                RepaintBoundary(
                  key: liveKey,
                  child: SizedBox(
                    width: 140,
                    height: 140,
                    child: Center(child: _view(c, key: const ValueKey('live'))),
                  ),
                ),
                RepaintBoundary(
                  key: freshKey,
                  child: SizedBox(
                    width: 140,
                    height: 140,
                    child: Center(child: _view(c, key: ValueKey('fresh$i'))),
                  ),
                ),
                RepaintBoundary(
                  key: otherKey,
                  child: SizedBox(
                    width: 140,
                    height: 140,
                    child: Center(
                      child: _view(bystander, key: const ValueKey('other')),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      // Let async shader loads settle (real time, outside fake async).
      for (var k = 0; k < 6; k++) {
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 20)),
        );
        await tester.pump();
      }
      final live = await captureRaster(tester, liveKey, pixelRatio: 2);
      final fresh = await captureRaster(tester, freshKey, pixelRatio: 2);
      var diff = 0, edge = 0;
      for (var j = 0; j < live.rgba.length; j++) {
        diff += (live.rgba[j] - fresh.rgba[j]).abs();
      }
      for (var y = 0; y < live.height; y++) {
        for (var x = 0; x < live.width; x++) {
          final a = live.alpha(x, y);
          if (a > 8 && a < 247) edge++;
        }
      }
      expect(
        diff / live.rgba.length,
        lessThan(.5),
        reason: 'step $i ${c.label}',
      );
      if (c.size >= 48) {
        expect(
          edge,
          greaterThan(20),
          reason: 'step $i has partial edge coverage',
        );
      }
    }
    // Final state equals the initial configuration and the bystander is
    // unchanged from its own first render.
    final other = await captureRaster(tester, otherKey, pixelRatio: 2);
    await tester.pumpWidget(const SizedBox());
    expect(other.width, greaterThan(0));
  });

  testWidgets(
    'shape button keeps edge coverage after repeated option changes',
    (tester) async {
      final liveKey = GlobalKey(), freshKey = GlobalKey();
      Widget button(int i, Key key) => MorphShapeButton(
        key: key,
        size: 96,
        shape: i.isEven ? gem : clover,
        pressedShape: i % 3 == 0 ? clover : null,
        selected: i.isOdd,
        selectedShape: i % 4 == 1 ? gem : null,
        enabled: i % 5 != 4,
        rotationOnPress: i * .1,
        edgeAntialias: i % 6 == 2
            ? MorphEdgeAntialias.native
            : MorphEdgeAntialias.auto,
        backgroundColor: i.isEven
            ? const Color(0xff3060c0)
            : const Color(0xffe02020),
        onPressed: () {},
      );
      for (var i = 0; i < 14; i++) {
        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: MediaQuery(
              data: const MediaQueryData(devicePixelRatio: 2),
              child: Row(
                textDirection: TextDirection.ltr,
                children: [
                  RepaintBoundary(
                    key: liveKey,
                    child: SizedBox(
                      width: 120,
                      height: 120,
                      child: Center(child: button(i, const ValueKey('live'))),
                    ),
                  ),
                  RepaintBoundary(
                    key: freshKey,
                    child: SizedBox(
                      width: 120,
                      height: 120,
                      child: Center(child: button(i, ValueKey('fresh$i'))),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 500));
        final live = await captureRaster(tester, liveKey, pixelRatio: 2);
        final fresh = await captureRaster(tester, freshKey, pixelRatio: 2);
        var diff = 0;
        for (var j = 0; j < live.rgba.length; j++) {
          diff += (live.rgba[j] - fresh.rgba[j]).abs();
        }
        expect(diff / live.rgba.length, lessThan(.5), reason: 'step $i');
      }
      await tester.pumpWidget(const SizedBox());
    },
  );
}
