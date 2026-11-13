import 'package:flutter/widgets.dart'
    show Align, Alignment, Offset, Opacity, TextDirection, Transform, ValueKey;
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart'
    show
        BuildContext,
        Center,
        Scaffold,
        SizedBox,
        Text,
        TextButton,
        VoidCallback;
import 'package:morph_expressive/morph_components.dart';

const _choices = <MorphDropdownItem<String>>[
  MorphDropdownItem(label: 'Dart', value: 'dart'),
  MorphDropdownItem(label: 'Kotlin', value: 'kotlin'),
];

void main() {
  test('search-to-item gap matches the default panel inset', () {
    const panel = MorphDropdownPanelStyle();
    const search = MorphDropdownSearchStyle();
    final inset = panel.contentPadding.resolve(TextDirection.ltr);
    final margin = search.margin.resolve(TextDirection.ltr);
    expect(margin.bottom + inset.top, inset.left);
    expect(margin.top, inset.top);
  });

  testWidgets(
    'dropdown defaults to centered fade and scale, with faster content',
    (tester) async {
      final controller = MorphDropdownController<String>();
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        MorphMaterialApp(
          data: MorphThemeData.light(),
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 300,
                child: MorphDropdownMenu<String>(
                  controller: controller,
                  items: _choices,
                  fieldStyle: const MorphDropdownFieldStyle(hintText: 'Choose'),
                ),
              ),
            ),
          ),
        ),
      );
      controller.setOpen(open: true);
      await tester.pump();
      final panel = find.byKey(const ValueKey('morph-dropdown-panel-opacity'));
      final scale = find.byKey(const ValueKey('morph-dropdown-centered-scale'));
      final rows = find.byKey(const ValueKey('morph-dropdown-content-opacity'));
      final height = find.byKey(const ValueKey('morph-dropdown-height-reveal'));
      expect(find.byType(MorphLiquidUnfold), findsNothing);
      expect(panel, findsOneWidget);
      expect(tester.widget<Opacity>(panel).opacity, closeTo(0, 1e-5));
      expect(tester.widget<Transform>(scale).alignment, Alignment.center);
      expect(
        tester.widget<Transform>(scale).transform.storage[0],
        closeTo(0.80, 1e-5),
      );
      expect(tester.widget<Align>(height).heightFactor, closeTo(0, 1e-5));

      await tester.pump(const Duration(milliseconds: 150));
      expect(tester.widget<Opacity>(panel).opacity, greaterThan(0));
      expect(tester.widget<Opacity>(panel).opacity, lessThan(1));
      expect(
        tester.widget<Transform>(scale).transform.storage[0],
        greaterThan(0.80),
      );
      expect(tester.widget<Align>(height).heightFactor, greaterThan(0));
      expect(tester.widget<Align>(height).heightFactor, lessThan(1));
      expect(tester.widget<Opacity>(rows).opacity, closeTo(1, 1e-5));

      // Height finishes at 240ms; fade/scale continue until 300ms.
      await tester.pump(const Duration(milliseconds: 110));
      expect(tester.widget<Align>(height).heightFactor, closeTo(1, 1e-5));
      expect(tester.widget<Opacity>(panel).opacity, lessThan(1));

      await tester.pumpAndSettle();
      expect(tester.widget<Opacity>(panel).opacity, closeTo(1, 1e-5));
      expect(
        tester.widget<Transform>(scale).transform.storage[0],
        closeTo(1, 1e-5),
      );
      expect(find.text('Dart'), findsOneWidget);

      controller.setOpen(open: false);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 105));
      expect(tester.widget<Opacity>(rows).opacity, closeTo(0, 1e-5));
      expect(tester.widget<Opacity>(panel).opacity, greaterThan(0));
      expect(tester.widget<Transform>(scale).alignment, Alignment.center);
      expect(tester.widget<Align>(height).heightFactor, greaterThan(0));
      await tester.pump(const Duration(milliseconds: 105));
      expect(tester.widget<Align>(height).heightFactor, closeTo(0, 1e-5));
      expect(tester.widget<Opacity>(panel).opacity, greaterThan(0));
      await tester.pumpAndSettle();
      expect(panel, findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('centered dropdown height reverses smoothly when reopened', (
    tester,
  ) async {
    final controller = MorphDropdownController<String>();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      MorphMaterialApp(
        data: MorphThemeData.light(),
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 300,
              child: MorphDropdownMenu<String>(
                controller: controller,
                items: _choices,
              ),
            ),
          ),
        ),
      ),
    );
    controller.setOpen(open: true);
    await tester.pump();
    await tester.pumpAndSettle();
    final height = find.byKey(const ValueKey('morph-dropdown-height-reveal'));
    controller.setOpen(open: false);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 80));
    final duringClose = tester.widget<Align>(height).heightFactor!;
    expect(duringClose, greaterThan(0));
    expect(duringClose, lessThan(1));
    controller.setOpen(open: true);
    await tester.pump();
    expect(
      tester.widget<Align>(height).heightFactor,
      closeTo(duringClose, 1e-5),
    );
    await tester.pumpAndSettle();
    expect(tester.widget<Align>(height).heightFactor, closeTo(1, 1e-5));
    expect(tester.takeException(), isNull);
  });

  testWidgets('explicit liquid still unfolds from the field pointer origin', (
    tester,
  ) async {
    final controller = MorphDropdownController<String>();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      MorphMaterialApp(
        data: MorphThemeData.light(),
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 300,
              child: MorphDropdownMenu<String>(
                controller: controller,
                items: _choices,
                motionStyle: MorphDropdownMotionStyle.liquid,
                originFromTap: false,
              ),
            ),
          ),
        ),
      ),
    );
    controller.setOpen(open: true);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 90));
    final reveal = tester.widget<MorphLiquidUnfold>(
      find.byType(MorphLiquidUnfold),
    );
    expect(reveal.intensity, 0.35);
    expect(reveal.originX, 0.5);
    expect(
      find.byKey(const ValueKey('morph-dropdown-panel-opacity')),
      findsNothing,
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('menu popup enters from the center, with a faster content fade', (
    tester,
  ) async {
    await tester.pumpWidget(
      MorphMaterialApp(
        data: MorphThemeData.light(),
        home: Scaffold(
          body: Center(
            child: MorphMenu(
              anchorBuilder: (BuildContext context, VoidCallback open) =>
                  TextButton(onPressed: open, child: const Text('Open menu')),
              children: const [MorphMenuEntry(label: 'First choice')],
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open menu'));
    await tester.pump();

    final panel = find.byKey(const ValueKey('morph-popup-panel-opacity'));
    final scale = find.byKey(const ValueKey('morph-popup-centered-scale'));
    final rows = find.byKey(const ValueKey('morph-popup-content-opacity'));
    final height = find.byKey(const ValueKey('morph-popup-height-reveal'));
    expect(
      find.byWidgetPredicate((widget) => widget is MorphMenuPopup),
      findsOneWidget,
    );
    expect(find.byType(MorphLiquidUnfold), findsNothing);
    expect(panel, findsOneWidget);
    expect(tester.widget<Opacity>(panel).opacity, closeTo(0, 1e-5));
    expect(tester.widget<Transform>(scale).alignment, Alignment.center);
    expect(
      tester.widget<Transform>(scale).transform.storage[0],
      closeTo(0.80, 1e-5),
    );
    expect(tester.widget<Align>(height).heightFactor, closeTo(0, 1e-5));

    await tester.pump(const Duration(milliseconds: 150));
    expect(tester.widget<Opacity>(panel).opacity, greaterThan(0));
    expect(
      tester.widget<Transform>(scale).transform.storage[0],
      greaterThan(0.80),
    );
    expect(tester.widget<Align>(height).heightFactor, greaterThan(0));
    expect(tester.widget<Align>(height).heightFactor, lessThan(1));
    expect(tester.widget<Opacity>(rows).opacity, closeTo(1, 1e-5));

    await tester.pump(const Duration(milliseconds: 110));
    expect(tester.widget<Align>(height).heightFactor, closeTo(1, 1e-5));
    expect(tester.widget<Opacity>(panel).opacity, lessThan(1));

    await tester.pumpAndSettle();
    expect(tester.widget<Opacity>(panel).opacity, closeTo(1, 1e-5));
    expect(
      tester.widget<Transform>(scale).transform.storage[0],
      closeTo(1, 1e-5),
    );
    expect(find.text('First choice'), findsOneWidget);

    // Exit: rows disappear in the first 35% of 250ms while the surface
    // is still on-screen and always contracts around its own center.
    await tester.tapAt(const Offset(5, 5));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(tester.widget<Opacity>(rows).opacity, closeTo(0, 1e-5));
    expect(tester.widget<Opacity>(panel).opacity, greaterThan(0));
    expect(tester.widget<Transform>(scale).alignment, Alignment.center);
    expect(tester.widget<Align>(height).heightFactor, greaterThan(0));
    await tester.pump(const Duration(milliseconds: 105));
    expect(tester.widget<Align>(height).heightFactor, closeTo(0, 1e-5));
    expect(tester.widget<Opacity>(panel).opacity, greaterThan(0));
    await tester.pumpAndSettle();
    expect(
      find.byWidgetPredicate((widget) => widget is MorphMenuPopup),
      findsNothing,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('zero intensity preserves the unfold but disables tension', (
    tester,
  ) async {
    final controller = MorphDropdownController<String>();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      MorphMaterialApp(
        data: MorphThemeData.light(),
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 300,
              child: MorphDropdownMenu<String>(
                controller: controller,
                organicStretchIntensity: 0,
                motionStyle: MorphDropdownMotionStyle.liquid,
                items: _choices,
              ),
            ),
          ),
        ),
      ),
    );
    controller.setOpen(open: true);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 80));
    expect(
      tester
          .widget<MorphLiquidUnfold>(find.byType(MorphLiquidUnfold))
          .intensity,
      0,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('legacy preserves the old reveal without liquid clipping', (
    tester,
  ) async {
    final controller = MorphDropdownController<String>();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      MorphMaterialApp(
        data: MorphThemeData.light(),
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 300,
              child: MorphDropdownMenu<String>(
                controller: controller,
                motionStyle: MorphDropdownMotionStyle.legacy,
                items: _choices,
              ),
            ),
          ),
        ),
      ),
    );
    controller.setOpen(open: true);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 90));
    expect(find.byType(MorphLiquidUnfold), findsNothing);
    expect(find.text('Dart'), findsOneWidget);
  });
}
