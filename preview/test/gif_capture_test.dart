import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart'
    show Icon, Size, SizedBox, ValueKey;
import 'package:morph_expressive/morph_expressive.dart';
import 'package:morph_expressive_preview/component_gif_capture.dart';

/// Ahem, the font used by widget tests, is wider than Roboto: the selected
/// label of a navigation bar overflows by a few pixels only in tests.
void expectNoErrors(WidgetTester tester, String scene, String reason) {
  final error = tester.takeException();
  if (scene == 'navigation' && '$error'.contains('overflowed')) return;
  expect(error, isNull, reason: reason);
}

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
      // Every showcase is captured on the same 640x360 canvas.
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

  for (final (scene, height) in const [('navigation_rail_drawer', 380)]) {
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

  testWidgets('chip capture has filter, input, assist and group chips', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(640, 360);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MorphGifCaptureApp(scene: 'chips'));
    await tester.pump();
    expect(find.text('Filter chips · select and deselect'), findsOneWidget);
    expect(find.text('Chip group · multiple selection'), findsOneWidget);
    final types = tester
        .widgetList<MorphChip>(find.byType(MorphChip))
        .map((chip) => chip.type)
        .toSet();
    expect(types, {
      MorphChipType.filter,
      MorphChipType.input,
      MorphChipType.assist,
    });
    final group = tester.widget<MorphChipToggle<String>>(
      find.byKey(const ValueKey('gif_chips_multi')),
    );
    expect(group.multiSelection, true);
    expect(group.selectedValues, isEmpty);
    expect(find.text('Ana'), findsOneWidget);
    expect(tester.takeException(), isNull);

    // The real timeline: a filter chip is selected by a scripted tap, then the
    // input chips lose and regain people (the clip ends where it began).
    await tester.pump(const Duration(milliseconds: 1500));
    expect(
      tester
          .widgetList<MorphChip>(find.byType(MorphChip))
          .where((chip) => chip.type == MorphChipType.filter && chip.selected)
          .map((chip) => chip.label),
      contains('Movies'),
    );
    var people = <int>{};
    for (var ms = 0; ms < 7000; ms += 100) {
      await tester.pump(const Duration(milliseconds: 100));
      people = {
        ...people,
        tester
            .widgetList<MorphChip>(find.byType(MorphChip))
            .where((chip) => chip.type == MorphChipType.input)
            .length,
      };
    }
    expect(people, containsAll(<int>[1, 2, 3]));
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('text-field capture shows filled, outlined and search fields', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(640, 360);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MorphGifCaptureApp(scene: 'textfields'));
    await tester.pump();
    expect(find.text('Filled · floating label and error'), findsOneWidget);
    expect(find.text('Outlined · counter'), findsOneWidget);
    expect(find.text('Search · clear button'), findsOneWidget);
    MorphTextField field(String key) => tester.widget<MorphTextField>(
      find.byKey(ValueKey('gif_textfield_$key')),
    );
    expect(field('filled').variant, MorphTextFieldVariant.filled);
    expect(field('outlined').variant, MorphTextFieldVariant.outlined);
    expect(field('filled').errorText, isNull);
    // Real typing: the incomplete address raises the error once the field is
    // left, and completing it clears the error again.
    var sawError = false;
    var sawTyped = false;
    for (var ms = 0; ms < 5000; ms += 50) {
      await tester.pump(const Duration(milliseconds: 50));
      sawError = sawError || field('filled').errorText != null;
      sawTyped = sawTyped || find.text('hello@morph.dev').evaluate().isNotEmpty;
    }
    expect(sawError, isTrue);
    expect(sawTyped, isTrue);
    expect(field('filled').errorText, isNull);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  // The new scenes run their whole scripted timeline (real pointer events,
  // controlled states) inside the capture viewport without layout errors.
  for (final (scene, height, seconds) in const [
    ('buttons', 360, 8),
    ('dropdown', 360, 8),
    ('segmented', 360, 8),
    ('textfields', 360, 8),
    ('chips', 360, 8),
    ('sliders', 360, 8),
    ('loading', 360, 8),
    ('navigation', 360, 8),
    ('async_button', 340, 11),
    ('skeleton', 340, 9),
    ('tabs', 380, 9),
    ('fab_menu', 400, 8),
    ('navigation_rail_drawer', 380, 9),
    ('variants', 360, 7),
    ('density', 360, 8),
    ('context_menu', 360, 9),
  ]) {
    testWidgets('GIF scene $scene runs its full timeline', (tester) async {
      tester.view.physicalSize = Size(640, height.toDouble());
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(MorphGifCaptureApp(scene: scene));
      for (var ms = 0; ms < seconds * 1000; ms += 50) {
        await tester.pump(const Duration(milliseconds: 50));
        expectNoErrors(tester, scene, '$scene at ${ms}ms');
      }
      await tester.pumpWidget(const SizedBox());
    });
  }

  testWidgets('async fixed-state cells stay inside the capture width', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(640, 340);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MorphGifCaptureApp(scene: 'async_button'));
    await tester.pump();
    expect(tester.takeException(), isNull);
    final row = find.byKey(const ValueKey('async_fixed_states'));
    expect(row, findsOneWidget);
    final bounds = tester.getRect(row);
    final buttons = find.descendant(
      of: row,
      matching: find.byType(MorphAsyncButton),
    );
    expect(buttons, findsNWidgets(4));
    expect(
      tester.widgetList<MorphAsyncButton>(buttons).map((b) => b.state).toSet(),
      MorphOperationState.values.toSet(),
    );
    for (var i = 0; i < 4; i++) {
      final rect = tester.getRect(buttons.at(i));
      expect(rect.width, greaterThan(0));
      expect(rect.left, greaterThanOrEqualTo(bounds.left - 0.01));
      expect(rect.right, lessThanOrEqualTo(bounds.right + 0.01));
    }
    await tester.pumpWidget(const SizedBox());
    expect(tester.takeException(), isNull);
  });

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

  testWidgets('segmented scene has a toggle, a segmented button and a group', (
    tester,
  ) async {
    await open(tester, 'segmented', 360);
    expect(find.byType(MorphSegmentedToggle<String>), findsOneWidget);
    final segmented = tester.widget<MorphSegmentedButton<String>>(
      find.byType(MorphSegmentedButton<String>),
    );
    expect(segmented.multiSelect, isTrue);
    final connected = tester.widget<MorphButtonGroup>(
      find.byType(MorphButtonGroup),
    );
    expect(connected.type, MorphButtonGroupType.connected);
    expect(find.text('Connected button group'), findsOneWidget);
    // Real taps: the toggle, the segmented button and the group all respond,
    // and every one is back on its first value when the clip ends.
    final seen = <String>{};
    for (var ms = 0; ms < 8000; ms += 50) {
      await tester.pump(const Duration(milliseconds: 50));
      expect(tester.takeException(), isNull, reason: 'at ${ms}ms');
      for (final text in const [
        'Calendar: Month',
        'Selected: Train + Walk',
        'Size: Large',
      ]) {
        if (find.text(text).evaluate().isNotEmpty) seen.add(text);
      }
    }
    expect(
      seen,
      containsAll(['Calendar: Month', 'Selected: Train + Walk', 'Size: Large']),
    );
    expect(find.text('Calendar: Day'), findsOneWidget);
    expect(find.text('Nothing selected'), findsOneWidget);
    expect(find.text('Size: Medium'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('buttons scene shows five styles and several ShapeButtons', (
    tester,
  ) async {
    await open(tester, 'buttons', 360);
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
    await open(tester, 'loading', 360);
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
    expect(find.textContaining('Progress '), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('sliders scene drags real sliders and returns to the start', (
    tester,
  ) async {
    await open(tester, 'sliders', 360);
    expect(find.text('Volume'), findsOneWidget);
    expect(find.text('35%'), findsOneWidget);
    var peak = 0.0;
    for (var ms = 0; ms < 8000; ms += 50) {
      await tester.pump(const Duration(milliseconds: 50));
      expect(tester.takeException(), isNull, reason: 'at ${ms}ms');
      final slider = tester.widget<MorphSlider>(find.byType(MorphSlider).first);
      if (slider.value > peak) peak = slider.value;
    }
    expect(peak, greaterThan(.8), reason: 'the drag moved the thumb');
    expect(find.text('35%'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('dropdown scene selects in both menus and resets', (
    tester,
  ) async {
    await open(tester, 'dropdown', 360);
    expect(find.text('Single select'), findsOneWidget);
    var sawSwift = false;
    var sawChips = false;
    for (var ms = 0; ms < 8000; ms += 50) {
      await tester.pump(const Duration(milliseconds: 50));
      expect(tester.takeException(), isNull, reason: 'at ${ms}ms');
      sawSwift = sawSwift || find.text('Swift').evaluate().length == 1;
      sawChips = sawChips || find.text('Web').evaluate().length >= 2;
    }
    expect(sawSwift, isTrue, reason: 'Swift was chosen');
    expect(sawChips, isTrue, reason: 'Android and Web were chosen');
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('navigation scene taps change both bars and the indicators', (
    tester,
  ) async {
    await open(tester, 'navigation', 360);
    expect(find.text('Home'), findsWidgets);
    final seen = <int>{};
    for (var ms = 0; ms < 8000; ms += 50) {
      await tester.pump(const Duration(milliseconds: 50));
      expectNoErrors(tester, 'navigation', 'at ${ms}ms');
      seen.add(
        tester
            .widget<MorphPageIndicator>(
              find.byKey(const ValueKey('gif_page_slide')),
            )
            .selectedIndex,
      );
    }
    expect(seen, {0, 1, 2});
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('variants scene shows five variants of four styles and icons', (
    tester,
  ) async {
    await open(tester, 'variants', 360);
    expect(find.byType(MorphButton), findsNWidgets(20));
    expect(find.byType(MorphIconButton), findsNWidgets(5));
    final variants = tester
        .widgetList<MorphButton>(find.byType(MorphButton))
        .map((button) => button.variant)
        .toSet();
    expect(variants, MorphVariant.values.toSet());
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('density scene changes only the theme density', (tester) async {
    await open(tester, 'density', 360);
    MorphDensity current() =>
        MorphTheme.of(tester.element(find.byType(MorphButton).first)).density;
    expect(current(), MorphDensity.standard);
    expect(find.text('density: .standard'), findsOneWidget);
    final seen = <MorphDensity>[];
    for (var ms = 0; ms < 8000; ms += 100) {
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.takeException(), isNull);
      final density = current();
      if (seen.isEmpty || seen.last != density) seen.add(density);
    }
    expect(seen, [
      MorphDensity.standard,
      MorphDensity.compact,
      MorphDensity.standard,
      MorphDensity.comfortable,
      MorphDensity.standard,
    ]);
    expect(find.byType(MorphChip), findsNWidgets(3));
    expect(find.byType(MorphTextField), findsOneWidget);
    expect(find.byType(MorphListItem), findsNWidgets(3));
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('context menu scene opens a real desktop menu and submenu', (
    tester,
  ) async {
    await open(tester, 'context_menu', 360);
    expect(find.byType(MorphContextMenuRegion<String>), findsNWidgets(3));
    expect(find.text('Rename'), findsNothing);
    var sawMenu = false;
    var sawSubmenu = false;
    var sawResult = false;
    for (var ms = 0; ms < 8000; ms += 50) {
      await tester.pump(const Duration(milliseconds: 50));
      expect(tester.takeException(), isNull, reason: 'at ${ms}ms');
      sawMenu = sawMenu || find.text('Rename').evaluate().isNotEmpty;
      sawSubmenu = sawSubmenu || find.text('Projects').evaluate().isNotEmpty;
      sawResult =
          sawResult ||
          find
              .text('Moved Meeting notes.md to Documents')
              .evaluate()
              .isNotEmpty;
    }
    expect(sawMenu, isTrue, reason: 'the secondary click opened the menu');
    expect(sawSubmenu, isTrue, reason: 'hovering Move to opened its submenu');
    expect(sawResult, isTrue, reason: 'choosing Documents reported the move');
    expect(find.text('Rename'), findsNothing, reason: 'the menu closed');
    await tester.pumpWidget(const SizedBox());
  });
}
