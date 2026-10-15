import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:morph_expressive_preview/component_gif_capture.dart';

void main() {
  for (final scene in const [
    'buttons',
    'dropdown',
    'segmented',
    'textfields',
    'chips',
    'sliders',
  ]) {
    testWidgets('GIF scene $scene renders within capture viewport',
        (tester) async {
      tester.view.physicalSize = const Size(640, 360);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(MorphGifCaptureApp(scene: scene));
      await tester.pump();
      expect(find.byKey(ValueKey('morph_gif_$scene')), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
