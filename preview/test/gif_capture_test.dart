import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart'
    show Icon, Size, SizedBox, ValueKey;
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
    'loading',
  ]) {
    testWidgets('GIF scene $scene renders within capture viewport', (
      tester,
    ) async {
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

  for (final (scene, height) in const [
    ('navigation', 350),
    ('navigation_rail_drawer', 380),
  ]) {
    testWidgets('GIF scene $scene uses its dedicated capture canvas', (
      tester,
    ) async {
      tester.view.physicalSize = Size(640, height.toDouble());
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(MorphGifCaptureApp(scene: scene));
      await tester.pump();
      expect(find.byKey(ValueKey('morph_gif_$scene')), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets(
    'Morph navigation GIF shows only Morph variants and page effects',
    (tester) async {
      tester.view.physicalSize = const Size(640, 520);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(const MorphGifCaptureApp(scene: 'navigation'));
      await tester.pump();
      expect(
        find.byKey(const ValueKey('gif_navigation_morph_bar')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('gif_navigation_expressive_bar')),
        findsOneWidget,
      );
      expect(find.byKey(const ValueKey('gif_page_expand')), findsOneWidget);
      expect(find.byKey(const ValueKey('gif_page_slide')), findsOneWidget);
      expect(
        tester
            .widget<MorphPageIndicator>(
              find.byKey(const ValueKey('gif_page_slide')),
            )
            .effect,
        MorphPageIndicatorEffect.slide,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Morph vertical navigation GIF contains rail and drawer', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(640, 500);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      const MorphGifCaptureApp(scene: 'navigation_rail_drawer'),
    );
    await tester.pump();
    expect(
      find.byKey(const ValueKey('gif_navigation_morph_rail')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('gif_navigation_morph_drawer')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('chip capture includes M3E, expressive single and multi', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(640, 480);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MorphGifCaptureApp(scene: 'chips'));
    await tester.pump();
    expect(
      find.text('Material 3 Expressive · filter, input, assist'),
      findsOneWidget,
    );
    expect(find.text('Morph expressive · single'), findsOneWidget);
    expect(find.text('Morph expressive · multiple'), findsOneWidget);
    final single = tester.widget<MorphChipToggle<String>>(
      find.byKey(const ValueKey('gif_chips_single')),
    );
    final multi = tester.widget<MorphChipToggle<String>>(
      find.byKey(const ValueKey('gif_chips_multi')),
    );
    expect(single.multiSelection, false);
    expect(multi.multiSelection, true);
    expect(multi.selectedValues, isEmpty);
    expect(tester.takeException(), isNull);

    // Advance through the real capture timeline: first circle, then the
    // second option's connected morph, without relying on visual snapshots.
    await tester.pump(const Duration(milliseconds: 1450));
    expect(
      tester
          .widget<MorphChipToggle<String>>(
            find.byKey(const ValueKey('gif_chips_multi')),
          )
          .selectedValues,
      {'Daily'},
    );
    await tester.pump(const Duration(milliseconds: 920));
    expect(
      tester
          .widget<MorphChipToggle<String>>(
            find.byKey(const ValueKey('gif_chips_multi')),
          )
          .selectedValues,
      {'Daily', 'Weekly'},
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('text-field capture retains search and outlined, adds filled', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(640, 480);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MorphGifCaptureApp(scene: 'textfields'));
    await tester.pump();
    expect(find.text('Search'), findsOneWidget);
    expect(find.text('Outlined'), findsOneWidget);
    expect(find.text('Filled · floating label'), findsOneWidget);
    expect(
      tester
          .widget<MorphTextField>(
            find.byKey(const ValueKey('gif_textfield_search')),
          )
          .variant,
      MorphTextFieldVariant.filled,
    );
    expect(
      tester
          .widget<MorphTextField>(
            find.byKey(const ValueKey('gif_textfield_outlined')),
          )
          .variant,
      MorphTextFieldVariant.outlined,
    );
    expect(
      tester
          .widget<MorphTextField>(
            find.byKey(const ValueKey('gif_textfield_filled')),
          )
          .variant,
      MorphTextFieldVariant.filled,
    );
    expect(tester.takeException(), isNull);
  });

  // The new scenes run their whole scripted timeline (real pointer events,
  // controlled states) inside the capture viewport without layout errors.
  for (final (scene, height, seconds) in const [
    ('buttons', 370, 8),
    ('segmented', 350, 8),
    ('loading', 310, 9),
    ('async_button', 340, 11),
    ('skeleton', 340, 9),
    ('tabs', 380, 9),
    ('fab_menu', 400, 8),
    ('navigation_rail_drawer', 380, 9),
  ]) {
    testWidgets('GIF scene $scene runs its full timeline', (tester) async {
      tester.view.physicalSize = Size(640, height.toDouble());
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(MorphGifCaptureApp(scene: scene));
      for (var ms = 0; ms < seconds * 1000; ms += 50) {
        await tester.pump(const Duration(milliseconds: 50));
        expect(tester.takeException(), isNull, reason: '$scene at ${ms}ms');
      }
      await tester.pumpWidget(const SizedBox());
    });
  }

  testWidgets('async button scene shows both widths and every state', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(640, 340);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MorphGifCaptureApp(scene: 'async_button'));
    await tester.pump();
    final buttons = tester.widgetList<MorphAsyncButton>(
      find.byType(MorphAsyncButton),
    );
    expect(buttons.map((b) => b.presentation).toSet(), {
      MorphOperationPresentation.preserveWidth,
      MorphOperationPresentation.compact,
    });
    final seen = <MorphOperationState>{};
    for (var ms = 0; ms < 11000; ms += 100) {
      await tester.pump(const Duration(milliseconds: 100));
      seen.add(
        tester
            .widgetList<MorphAsyncButton>(find.byType(MorphAsyncButton))
            .first
            .state,
      );
    }
    expect(seen, containsAll(MorphOperationState.values));
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('tabs scene drives the real page view', (tester) async {
    tester.view.physicalSize = const Size(640, 380);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MorphGifCaptureApp(scene: 'tabs'));
    await tester.pump();
    expect(find.byType(MorphTabs), findsNWidgets(2));
    expect(find.byType(MorphTabsView), findsNWidgets(2));
    var sawProgress = false;
    for (var ms = 0; ms < 9000; ms += 40) {
      await tester.pump(const Duration(milliseconds: 40));
      final views = tester.widgetList<MorphTabsView>(
        find.byType(MorphTabsView),
      );
      sawProgress =
          sawProgress || views.any((v) => v.controller?.position.value != null);
    }
    expect(sawProgress, isTrue, reason: 'a real drag published page progress');
    await tester.pumpWidget(const SizedBox());
  });

  Future<void> open(WidgetTester tester, String scene, double height) async {
    tester.view.physicalSize = Size(640, height);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MorphGifCaptureApp(scene: scene));
    await tester.pump();
  }

  testWidgets(
    'segmented scene keeps the connected group next to the new ones',
    (tester) async {
      await open(tester, 'segmented', 350);
      expect(find.byType(MorphSegmentedToggle<String>), findsOneWidget);
      final connected = tester.widget<MorphButtonGroup>(
        find.byType(MorphButtonGroup),
      );
      expect(connected.type, MorphButtonGroupType.connected);
      final reactive = tester.widget<MorphReactiveButtonGroup>(
        find.byType(MorphReactiveButtonGroup),
      );
      expect(reactive.selectedExpansion, .08);
      expect(reactive.pressedExpansion, .08);
      expect(find.text('Connected button group'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets('buttons scene shows five styles and several ShapeButtons', (
    tester,
  ) async {
    await open(tester, 'buttons', 370);
    final styles = tester
        .widgetList<MorphButton>(find.byType(MorphButton))
        .map((b) => b.style)
        .toSet();
    expect(styles, MorphButtonStyle.values.toSet());
    final shapes = tester.widgetList<MorphShapeButton>(
      find.byType(MorphShapeButton),
    );
    expect(shapes.length, greaterThanOrEqualTo(3));
    expect(shapes.any((b) => b.rotationEnabled), isTrue);
    expect(shapes.any((b) => b.selectedShape != null), isTrue);
    // The icon of a ShapeButton sits on the centre of its square box.
    for (final b in tester.widgetList<MorphShapeButton>(
      find.byType(MorphShapeButton),
    )) {
      final box = tester.getRect(find.byWidget(b));
      final icon = tester.getRect(
        find.descendant(of: find.byWidget(b), matching: find.byType(Icon)),
      );
      expect(icon.center.dx, closeTo(box.center.dx, .01));
      expect(icon.center.dy, closeTo(box.center.dy, .01));
    }
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('FAB scene shows every FAB size, the extended FAB and the menu', (
    tester,
  ) async {
    await open(tester, 'fab_menu', 400);
    expect(
      tester
          .widgetList<MorphFab>(find.byType(MorphFab))
          .map((f) => f.size)
          .toSet(),
      MorphFabSize.values.toSet(),
    );
    expect(find.byType(MorphExtendedFab), findsWidgets);
    expect(find.byType(MorphFabMenu), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('loading scene has loaders and the four progress indicators', (
    tester,
  ) async {
    await open(tester, 'loading', 310);
    expect(find.byType(MorphLoadingIndicator), findsNWidgets(2));
    expect(find.byType(MorphProgressIndicator), findsNWidgets(4));
    for (final label in const [
      'Linear',
      'Linear wavy',
      'Circular',
      'Circular wavy',
    ]) {
      expect(find.text(label), findsOneWidget);
    }
    await tester.pumpWidget(const SizedBox());
  });
}
