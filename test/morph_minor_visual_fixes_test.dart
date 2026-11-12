import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart' as mui show MaterialApp;
import 'package:morph_expressive/morph_expressive.dart';
import 'package:morph_expressive/components/date_pickers/components/morph_day_cell.dart';
import 'package:morph_expressive/components/text_fields/components/morph_text_field_container_painter.dart';

void main() {
  test('internal list corners track outer radius until overridden', () {
    const defaults = MorphListCardListTheme();
    expect(defaults.innerRadius, 9.0);
    expect(defaults.copyWith(outerRadius: 32).innerRadius, 18);
    const manual = MorphListCardListTheme(outerRadius: 32, innerRadius: 7);
    expect(manual.copyWith(outerRadius: 24).innerRadius, 7);
  });

  test('smaller checkbox radius scales with the checkbox dimensions', () {
    const defaultTheme = MorphCheckboxTheme();
    expect(defaultTheme.borderRadius.topLeft.x, closeTo(3.6, 1e-8));
    expect(
      defaultTheme.copyWith(boxSize: 24).borderRadius.topLeft.x,
      closeTo(4.8, 1e-8),
    );
    const override = MorphCheckboxTheme(
      boxSize: 24,
      borderRadius: BorderRadius.all(Radius.circular(2)),
    );
    expect(override.borderRadius.topLeft.x, 2);
  });

  test('pressed button corners gain softness but stay below resting radii', () {
    const theme = MorphButtonTheme.defaults;
    expect(theme.pressedRadius(MorphButtonSize.xs), 10);
    expect(theme.pressedRadius(MorphButtonSize.md), 15);
    expect(theme.pressedRadius(MorphButtonSize.lg), 20);
    expect(theme.connectedInnerRadius, 11);
    expect(theme.connectedPressedInnerRadius, 6);
    expect(
      theme.pressedRadius(MorphButtonSize.md),
      lessThan(theme.squareRadius(MorphButtonSize.md)),
    );
  });

  testWidgets('filled input keeps its painted surface in place on focus', (
    tester,
  ) async {
    final node = FocusNode();
    addTearDown(node.dispose);
    await tester.pumpWidget(
      MorphMaterialApp(
        data: MorphThemeData.light(),
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 280,
              child: MorphTextField(label: 'Email', focusNode: node),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    Rect container() => tester.getRect(
      find
          .byWidgetPredicate(
            (widget) =>
                widget is CustomPaint &&
                widget.painter is MorphTextFieldContainerPainter,
          )
          .first,
    );
    final before = container();
    node.requestFocus();
    await tester.pumpAndSettle();
    expect(container().top, closeTo(before.top, 0.01));
    expect(container().height, before.height);
  });

  testWidgets('MorphMaterialApp uses native scrollbar behavior by default', (
    tester,
  ) async {
    await tester.pumpWidget(
      MorphMaterialApp(
        data: MorphThemeData.light(),
        home: const Scaffold(body: SizedBox(height: 100)),
      ),
    );
    final app = tester.widget<mui.MaterialApp>(find.byType(mui.MaterialApp));
    // Null lets MaterialApp supply the platform's standard ScrollBehavior.
    expect(app.scrollBehavior, isNull);
  });

  testWidgets(
    'MorphScrollBehavior delegates to the native scrollbar by default',
    (tester) async {
      final controller = ScrollController();
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(platform: TargetPlatform.linux),
          home: Builder(
            builder: (context) {
              const child = SizedBox(key: ValueKey('scroll-content'));
              final details = ScrollableDetails.vertical(
                controller: controller,
              );
              final native = const MaterialScrollBehavior().buildScrollbar(
                context,
                child,
                details,
              );
              final morph = const MorphScrollBehavior().buildScrollbar(
                context,
                child,
                details,
              );
              expect(morph.runtimeType, native.runtimeType);
              expect(morph, isA<Scrollbar>());
              return const SizedBox();
            },
          ),
        ),
      );
    },
  );

  testWidgets('standalone day cells work without MaterialLocalizations', (
    tester,
  ) async {
    await tester.pumpWidget(
      MorphTheme(
        data: MorphThemeData.light(),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
            child: SizedBox(
              width: 48,
              height: 48,
              child: MorphDayCell(
                date: DateTime(2026, 11, 8),
                selected: false,
                today: false,
                enabled: true,
                inRange: true,
                onTap: () {},
              ),
            ),
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('range caps use the weekday index supplied by the month', (
    tester,
  ) async {
    // November 8, 2026 is a Sunday. Under Monday-first calendars it must
    // terminate the week on the right, not start it on the left.
    await tester.pumpWidget(
      MaterialApp(
        home: MorphTheme(
          data: MorphThemeData.light(),
          child: Scaffold(
            body: Center(
              child: SizedBox(
                width: 48,
                height: 48,
                child: MorphDayCell(
                  date: DateTime(2026, 11, 8),
                  selected: false,
                  today: false,
                  enabled: true,
                  inRange: true,
                  firstDayOfWeekIndex: 1,
                  onTap: () {},
                ),
              ),
            ),
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    final decorations = tester.widgetList<DecoratedBox>(
      find.descendant(
        of: find.byType(MorphDayCell),
        matching: find.byType(DecoratedBox),
      ),
    );
    expect(
      decorations.any((box) {
        final decoration = box.decoration;
        final radius = decoration is BoxDecoration
            ? decoration.borderRadius
            : null;
        return radius is BorderRadius &&
            radius.topRight.x > 0 &&
            radius.topLeft.x == 0;
      }),
      isTrue,
    );
  });

  testWidgets('week row range highlight rounds its exterior end', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MorphTheme(
          data: MorphThemeData.light(),
          child: Scaffold(
            body: Center(
              child: SizedBox(
                width: 48,
                height: 48,
                child: MorphDayCell(
                  date: DateTime(2026, 11, 8), // Sunday, default week start.
                  selected: false,
                  today: false,
                  enabled: true,
                  inRange: true,
                  onTap: () {},
                ),
              ),
            ),
          ),
        ),
      ),
    );
    final decorations = tester.widgetList<DecoratedBox>(
      find.descendant(
        of: find.byType(MorphDayCell),
        matching: find.byType(DecoratedBox),
      ),
    );
    expect(
      decorations.any((d) {
        final decoration = d.decoration;
        return decoration is BoxDecoration &&
            decoration.borderRadius is BorderRadius &&
            (decoration.borderRadius! as BorderRadius).topLeft.x > 0;
      }),
      isTrue,
    );
  });
}
