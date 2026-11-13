import 'package:flutter/widgets.dart';
import 'package:flutter/gestures.dart';
import 'package:material_ui/material_ui.dart' show MaterialApp, Scaffold;
import 'package:flutter/services.dart' show LogicalKeyboardKey;
import 'package:flutter_test/flutter_test.dart';
import 'package:morph_expressive/components/buttons/components/morph_radius_and_padding_motion.dart';
import 'package:morph_expressive/morph_expressive.dart';

void main() {
  bool pressed(WidgetTester tester) => tester
      .widget<MorphRadiusAndPaddingMotion>(
        find.byType(MorphRadiusAndPaddingMotion).first,
      )
      .pressed;
  Widget host(Widget child) => MaterialApp(
    home: Scaffold(body: Center(child: child)),
  );

  testWidgets('down is visual only; second pointer cannot release the first', (
    tester,
  ) async {
    var actions = 0;
    await tester.pumpWidget(
      host(
        MorphButton(onPressed: () => actions++, child: const Text('Action')),
      ),
    );
    final center = tester.getCenter(find.byType(MorphButton));
    final first = await tester.startGesture(center, pointer: 1);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 16));
    expect(pressed(tester), isTrue);
    expect(actions, 0);
    final second = await tester.startGesture(center, pointer: 2);
    await second.up();
    await tester.pump();
    expect(pressed(tester), isTrue);
    await first.up();
    await tester.pump();
    expect(pressed(tester), isFalse);
    expect(actions, 1);
  });

  testWidgets('scroll arena cancels before physical pointer up', (
    tester,
  ) async {
    var actions = 0;
    await tester.pumpWidget(
      host(
        SizedBox(
          height: 200,
          child: ListView(
            children: [
              MorphButton(
                onPressed: () => actions++,
                child: const Text('Action'),
              ),
              const SizedBox(height: 1000),
            ],
          ),
        ),
      ),
    );
    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(MorphButton)),
    );
    await tester.pump();
    await gesture.moveBy(const Offset(0, -70));
    await tester.pump();
    expect(pressed(tester), isFalse);
    expect(actions, 0);
    await gesture.up();
    await tester.pump(const Duration(milliseconds: 200));
    expect(actions, 0);
  });

  testWidgets('eager competing recognizer cancels immediate visual feedback', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(
        RawGestureDetector(
          gestures: {
            EagerGestureRecognizer:
                GestureRecognizerFactoryWithHandlers<EagerGestureRecognizer>(
                  EagerGestureRecognizer.new,
                  (_) {},
                ),
          },
          child: MorphButton(onPressed: () {}, child: const Text('Action')),
        ),
      ),
    );
    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(MorphButton)),
    );
    await tester.pump();
    expect(pressed(tester), isFalse);
    await gesture.up();
  });

  testWidgets(
    'cancel, outside release and disable do not leave feedback stuck',
    (tester) async {
      var actions = 0;
      Widget button(bool enabled) => host(
        MorphButton(
          enabled: enabled,
          onPressed: () => actions++,
          child: const Text('Action'),
        ),
      );
      await tester.pumpWidget(button(true));
      var gesture = await tester.startGesture(
        tester.getCenter(find.byType(MorphButton)),
      );
      await tester.pump();
      await gesture.cancel();
      await tester.pump();
      expect(pressed(tester), isFalse);
      gesture = await tester.startGesture(
        tester.getCenter(find.byType(MorphButton)),
      );
      await tester.pump();
      await gesture.moveTo(Offset.zero);
      await tester.pump();
      expect(pressed(tester), isFalse);
      await gesture.up();
      gesture = await tester.startGesture(
        tester.getCenter(find.byType(MorphButton)),
      );
      await tester.pump();
      await tester.pumpWidget(button(false));
      await tester.pump();
      await gesture.up();
      await tester.pump();
      expect(actions, 0);
      expect(pressed(tester), isFalse);
    },
  );

  testWidgets(
    'long-press-only button responds and keyboard tap remains semantic',
    (tester) async {
      var holds = 0, actions = 0;
      await tester.pumpWidget(
        host(
          MorphButton(
            onPressed: null,
            onLongPress: () => holds++,
            child: const Text('Hold'),
          ),
        ),
      );
      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(MorphButton)),
      );
      await tester.pump();
      expect(pressed(tester), isTrue);
      expect(holds, 0);
      await tester.pump(const Duration(milliseconds: 600));
      expect(holds, 1);
      await gesture.up();
      await tester.pump();
      final focus = FocusNode();
      await tester.pumpWidget(
        host(
          MorphButton(
            focusNode: focus,
            onPressed: () => actions++,
            child: const Text('Action'),
          ),
        ),
      );
      focus.requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(actions, 1);
      await tester.pumpWidget(const SizedBox());
      focus.dispose();
    },
  );

  test('duration overrides survive styleFrom, merge, copy and theme lerp', () {
    final local = MorphButtonDecoration.styleFrom(
      pressDuration: Duration.zero,
      releaseDuration: const Duration(milliseconds: 220),
    );
    final merged = const MorphButtonDecoration(
      pressDuration: Duration(milliseconds: 60),
    ).merge(local);
    expect(merged.pressDuration, Duration.zero);
    expect(
      merged.copyWith().releaseDuration,
      const Duration(milliseconds: 220),
    );
    final theme = MorphButtonTheme.defaults.copyWith(
      pressDuration: Duration.zero,
    );
    expect(
      theme.lerp(MorphButtonTheme.defaults, .5).pressDuration,
      const Duration(milliseconds: 45),
    );
  });
  testWidgets('secondary mouse down does not press button geometry', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: MorphButton(onPressed: () {}, child: const Text('Action')),
          ),
        ),
      ),
    );
    final target = find.byType(MorphButton);
    final gesture = await tester.startGesture(
      tester.getCenter(target),
      kind: PointerDeviceKind.mouse,
      buttons: kSecondaryMouseButton,
    );
    await tester.pump();
    expect(
      tester
          .widget<MorphRadiusAndPaddingMotion>(
            find.byType(MorphRadiusAndPaddingMotion),
          )
          .pressed,
      isFalse,
    );
    await gesture.up();
  });

  testWidgets('default press and release reach their targets in 90/160 ms', (
    tester,
  ) async {
    var pressed = false;
    var radius = 28.0;
    late StateSetter update;
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: StatefulBuilder(
          builder: (context, setState) {
            update = setState;
            return MorphRadiusAndPaddingMotion(
              motion: MorphButtonMotion.standardSpatialFast.toMotion(),
              internalLeft: 0,
              internalRight: 0,
              internalTop: 0,
              internalBottom: 0,
              targetRadius: BorderRadius.circular(pressed ? 10 : 28),
              pressed: pressed,
              builder: (_, value) {
                radius = value.topLeft.x;
                return const SizedBox();
              },
            );
          },
        ),
      ),
    );
    update(() => pressed = true);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 90));
    expect(radius, closeTo(10, 1e-9));
    update(() => pressed = false);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 80));
    expect(radius, allOf(greaterThan(10), lessThan(28)));
    await tester.pump(const Duration(milliseconds: 80));
    expect(radius, closeTo(28, 1e-9));
  });
}
