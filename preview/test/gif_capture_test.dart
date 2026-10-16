import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:morph_expressive/morph_expressive.dart';
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
      // The three-variant capture scenes need the taller output canvas.
      final expanded = scene == 'chips' || scene == 'textfields';
      tester.view.physicalSize = expanded
          ? const Size(640, 480)
          : const Size(640, 360);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(MorphGifCaptureApp(scene: scene));
      await tester.pump();
      expect(find.byKey(ValueKey('morph_gif_$scene')), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('chip capture includes M3E, expressive single and multi',
      (tester) async {
    tester.view.physicalSize = const Size(640, 480);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MorphGifCaptureApp(scene: 'chips'));
    await tester.pump();
    expect(find.text('Material 3 Expressive · filter, input, assist'),
        findsOneWidget);
    expect(find.text('Morph expressive · single'), findsOneWidget);
    expect(find.text('Morph expressive · multiple'), findsOneWidget);
    final single = tester.widget<MorphChipToggle<String>>(
        find.byKey(const ValueKey('gif_chips_single')));
    final multi = tester.widget<MorphChipToggle<String>>(
        find.byKey(const ValueKey('gif_chips_multi')));
    expect(single.multiSelection, false);
    expect(multi.multiSelection, true);
    expect(multi.selectedValues, isEmpty);
    expect(tester.takeException(), isNull);

    // Advance through the real capture timeline: first circle, then the
    // second option's connected morph, without relying on visual snapshots.
    await tester.pump(const Duration(milliseconds: 1450));
    expect(tester.widget<MorphChipToggle<String>>(
        find.byKey(const ValueKey('gif_chips_multi'))).selectedValues,
        {'Daily'});
    await tester.pump(const Duration(milliseconds: 920));
    expect(tester.widget<MorphChipToggle<String>>(
        find.byKey(const ValueKey('gif_chips_multi'))).selectedValues,
        {'Daily', 'Weekly'});
    expect(tester.takeException(), isNull);
  });

  testWidgets('text-field capture retains search and outlined, adds filled',
      (tester) async {
    tester.view.physicalSize = const Size(640, 480);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MorphGifCaptureApp(scene: 'textfields'));
    await tester.pump();
    expect(find.text('Search'), findsOneWidget);
    expect(find.text('Outlined'), findsOneWidget);
    expect(find.text('Filled · floating label'), findsOneWidget);
    expect(tester.widget<MorphTextField>(
        find.byKey(const ValueKey('gif_textfield_search'))).variant,
        MorphTextFieldVariant.filled);
    expect(tester.widget<MorphTextField>(
        find.byKey(const ValueKey('gif_textfield_outlined'))).variant,
        MorphTextFieldVariant.outlined);
    expect(tester.widget<MorphTextField>(
        find.byKey(const ValueKey('gif_textfield_filled'))).variant,
        MorphTextFieldVariant.filled);
    expect(tester.takeException(), isNull);
  });
}
