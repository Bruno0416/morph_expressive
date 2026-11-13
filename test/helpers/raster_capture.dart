import 'dart:ui' as ui;

import 'package:flutter/rendering.dart' show RenderRepaintBoundary;
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// Raw RGBA capture of a [RepaintBoundary] at [pixelRatio].
class Raster {
  Raster(this.width, this.height, this.rgba);
  final int width, height;
  final List<int> rgba;
  int alpha(int x, int y) => rgba[(y * width + x) * 4 + 3];
  int channel(int x, int y, int c) => rgba[(y * width + x) * 4 + c];
}

Future<Raster> captureRaster(
  WidgetTester tester,
  GlobalKey key, {
  double pixelRatio = 1,
}) async {
  late Raster result;
  await tester.runAsync(() async {
    final image =
        await (key.currentContext!.findRenderObject() as RenderRepaintBoundary)
            .toImage(pixelRatio: pixelRatio);
    final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    result = Raster(image.width, image.height, data!.buffer.asUint8List());
    image.dispose();
  });
  return result;
}
