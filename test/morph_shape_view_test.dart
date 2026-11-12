import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'dart:ui' as ui;

import 'package:flutter/rendering.dart' show RenderRepaintBoundary;
import 'package:morph_expressive/morph_expressive.dart';

void main() {
  testWidgets(
    'Canvas and procedural Shader raster agree for translucent ellipse',
    (tester) async {
      MorphShapeRenderStatus? status;
      final canvasKey = GlobalKey(), shaderKey = GlobalKey();
      final ellipse = MorphShape.ellipse(width: 1, height: .64);
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Row(
            children: [
              RepaintBoundary(
                key: canvasKey,
                child: MorphShapeView(
                  shape: ellipse,
                  color: const Color(0x809050d0),
                ),
              ),
              RepaintBoundary(
                key: shaderKey,
                child: MorphShapeView(
                  shape: ellipse,
                  color: const Color(0x809050d0),
                  renderer: MorphShapeRenderer.shader,
                  onRendererChanged: (s) => status = s,
                ),
              ),
            ],
          ),
        ),
      );
      for (
        var i = 0;
        i < 10 && status?.effective != MorphShapeRenderer.shader;
        i++
      ) {
        await tester.runAsync(() async {
          await Future<void>.delayed(const Duration(milliseconds: 10));
        });
        await tester.pump();
      }
      expect(status?.effective, MorphShapeRenderer.shader);
      await tester.runAsync(() async {
        Future<List<int>> capture(GlobalKey key) async {
          final image =
              await (key.currentContext!.findRenderObject()
                      as RenderRepaintBoundary)
                  .toImage(pixelRatio: 2);
          final data = await image.toByteData(
            format: ui.ImageByteFormat.rawRgba,
          );
          image.dispose();
          return data!.buffer.asUint8List();
        }

        final a = await capture(canvasKey), b = await capture(shaderKey);
        expect(a.length, b.length);
        var error = 0;
        for (var i = 0; i < a.length; i++) {
          error += (a[i] - b[i]).abs();
        }
        // Mean channel error in 0..255; includes antialiasing and the bounded
        // four-cubic versus analytic ellipse edge difference (0.00014 units).
        expect(error / a.length, lessThan(2));
      });
    },
  );
  testWidgets('procedural Shader loads and paints independent instances', (
    tester,
  ) async {
    final program = await ui.FragmentProgram.fromAsset(
      'shaders/morph_ellipse.frag',
    );
    final a = program.fragmentShader(), b = program.fragmentShader();
    expect(a, isNot(same(b)));
    a.dispose();
    b.dispose();
    final statuses = <MorphShapeRenderStatus>[];
    final ellipse = MorphShape.ellipse(width: 1, height: .64);
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Row(
          children: [
            MorphShapeView(
              shape: ellipse,
              renderer: MorphShapeRenderer.shader,
              onRendererChanged: statuses.add,
            ),
            MorphShapeView(
              shape: MorphShape.ellipse(),
              renderer: MorphShapeRenderer.shader,
              onRendererChanged: statuses.add,
            ),
          ],
        ),
      ),
    );
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 50));
    });
    await tester.pump();
    await tester.pump();
    expect(
      statuses.where((s) => s.effective == MorphShapeRenderer.shader).length,
      2,
    );
    expect(tester.takeException(), isNull);
  });
  testWidgets('unsupported shader request reports Canvas fallback', (
    tester,
  ) async {
    MorphShapeRenderStatus? status;
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: MorphShapeView(
            shape: MorphShapeCatalog.softBurst,
            renderer: MorphShapeRenderer.shader,
            onRendererChanged: (s) => status = s,
          ),
        ),
      ),
    );
    await tester.pump();
    expect(status?.effective, MorphShapeRenderer.canvas);
    expect(status?.reason, contains('unsupported'));
    expect(tester.takeException(), isNull);
  });
}
