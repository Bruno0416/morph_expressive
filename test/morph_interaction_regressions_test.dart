import 'package:morph_expressive/components/buttons/components/morph_radius_and_padding_motion.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:morph_expressive/morph_components.dart';

MorphThemeData _theme({bool enabled = true}) =>
    MorphThemeData.light(seedColor: const Color(0xFF6750A4))
        .copyWith(hapticsEnabled: enabled);

Widget _host(Widget child, {bool hapticsEnabled = true}) => MorphMaterialApp(
  data: _theme(enabled: hapticsEnabled),
  home: Scaffold(body: Center(child: child)),
);

void main() {
  testWidgets('centered AppBar title ignores asymmetric custom actions', (
    tester,
  ) async {
    await tester.pumpWidget(
      MorphMaterialApp(
        data: _theme(),
        home: const Scaffold(
          appBar: MorphAppBar.top(
            centerTitle: true,
            titleText: 'Centered title',
            leading: SizedBox(width: 48, child: Icon(MorphIcons.arrow_back)),
            actions: <Widget>[
              SizedBox(width: 136, child: Center(child: Text('Actions'))),
            ],
          ),
          body: SizedBox.expand(),
        ),
      ),
    );
    final double titleX = tester.getCenter(find.text('Centered title')).dx;
    final double barX = tester.getCenter(find.byType(MorphAppBar)).dx;
    expect((titleX - barX).abs(), lessThanOrEqualTo(1));
  });

  testWidgets('global haptics disabled suppresses button group feedback', (
    tester,
  ) async {
    final calls = <MethodCall>[];
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'HapticFeedback.vibrate') calls.add(call);
      return null;
    });
    addTearDown(() {
      messenger.setMockMethodCallHandler(SystemChannels.platform, null);
    });

    Future<void> tapGroup(bool enabled) async {
      await tester.pumpWidget(
        _host(
          MorphButtonGroup(
            overflow: MorphButtonGroupOverflow.none,
            neighborSquish: false,
            actions: const <MorphButtonGroupAction>[
              MorphButtonGroupAction(label: Text('Choose')),
            ],
          ),
          hapticsEnabled: enabled,
        ),
      );
      final label = find.descendant(
        of: find.byType(MorphButtonGroupItemScope),
        matching: find.text('Choose'),
      );
      expect(label, findsOneWidget);
      await tester.tap(label);
      await tester.pump();
    }

    await tapGroup(false);
    expect(calls, isEmpty);
    await tapGroup(true);
    expect(calls.length, 1);
  });

  testWidgets('snackbar close surface is square', (tester) async {
    await tester.pumpWidget(
      _host(const MorphSnackbar(message: 'Saved', showCloseButton: true)),
    );
    final Size size = tester.getSize(find.byType(MorphIconButton));
    expect(size.width, size.height);
    expect(size.width, 32);
  });

  testWidgets('snackbar swipe is opt-in', (tester) async {
    final controller = MorphSnackbarController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      _host(
        Builder(
          builder: (context) => Column(
            children: [
              TextButton(
                onPressed: () => MorphSnackbar.show(
                  context,
                  controller: controller,
                  message: 'No swipe',
                  duration: const Duration(seconds: 20),
                ),
                child: const Text('Default'),
              ),
              TextButton(
                onPressed: () => MorphSnackbar.show(
                  context,
                  controller: controller,
                  message: 'Swipe enabled',
                  swipeDismissible: true,
                  duration: const Duration(seconds: 20),
                ),
                child: const Text('Enabled'),
              ),
            ],
          ),
        ),
      ),
    );

    await tester.tap(find.text('Default'));
    await tester.pumpAndSettle();
    await tester.drag(find.text('No swipe'), const Offset(270, 0));
    await tester.pumpAndSettle();
    expect(controller.isShowing, isTrue);

    await tester.tap(find.text('Enabled'));
    await tester.pumpAndSettle();
    await tester.drag(find.text('Swipe enabled'), const Offset(-270, 0));
    await tester.pumpAndSettle();
    expect(controller.isShowing, isFalse);
  });

  testWidgets('swipe row restores more-options trigger', (tester) async {
    await tester.pumpWidget(
      _host(
        MorphList(
          itemCount: 1,
          itemBuilder: (context, index) => const MorphListItem(
            headline: 'Swipable item',
            swipe: MorphListItemSwipe(
              trailing: <MorphListSwipeAction>[
                MorphListSwipeAction(icon: Icon(MorphIcons.archive), width: 56),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byIcon(MorphIcons.more_vert), findsOneWidget);
    final MorphIconButton overflow = tester.widget<MorphIconButton>(
      find.byWidgetPredicate(
        (widget) =>
            widget is MorphIconButton &&
            widget.semanticLabel == 'Show swipe actions',
      ),
    );
    expect(overflow.variant, MorphIconButtonVariant.standard);
    await tester.tap(find.byIcon(MorphIcons.more_vert));
    await tester.pumpAndSettle();
    expect(find.byIcon(MorphIcons.archive), findsOneWidget);
  });

  testWidgets('radius tween smoothly reverses after a short press', (
    tester,
  ) async {
    BorderRadius current = BorderRadius.zero;

    Widget sample({required bool pressed}) => _host(
      MorphRadiusAndPaddingMotion(
        motion: MorphMotion.springMotion(MorphMotion.expressiveSpatialDefault),
        internalLeft: 8,
        internalRight: 8,
        internalTop: 4,
        internalBottom: 4,
        pressed: pressed,
        targetRadius: BorderRadius.circular(pressed ? 6 : 28),
        builder: (padding, radius) {
          current = radius;
          return Padding(
            padding: padding,
            child: const SizedBox(width: 72, height: 40),
          );
        },
      ),
    );

    await tester.pumpWidget(sample(pressed: false));
    await tester.pump();
    expect(current.topLeft.x, closeTo(28, 0.01));

    await tester.pumpWidget(sample(pressed: true));
    await tester.pump(const Duration(milliseconds: 60));
    final held = current.topLeft.x;
    expect(held, greaterThan(5));
    expect(held, lessThan(28));

    await tester.pumpWidget(sample(pressed: false));
    await tester.pump(const Duration(milliseconds: 16));
    expect(current.topLeft.x, greaterThan(held));
    expect(current.topLeft.x, lessThan(28));
    await tester.pumpAndSettle();
    expect(current.topLeft.x, closeTo(28, 0.01));

    await tester.pumpWidget(sample(pressed: true));
    await tester.pump(const Duration(milliseconds: 16));
    await tester.pumpWidget(sample(pressed: false));
    await tester.pumpAndSettle();
    expect(current.topLeft.x, closeTo(28, 0.01));
  });

  testWidgets('release radius visibly interpolates across several frames', (
    tester,
  ) async {
    double radius = 0;

    Widget sample(bool pressed) => _host(
      MorphRadiusAndPaddingMotion(
        motion: MorphMotion.springMotion(MorphMotion.expressiveSpatialDefault),
        internalLeft: 12,
        internalRight: 12,
        internalTop: 0,
        internalBottom: 0,
        targetRadius: BorderRadius.circular(pressed ? 5 : 28),
        pressed: pressed,
        builder: (padding, animated) {
          radius = animated.topLeft.x;
          return Padding(
            padding: padding,
            child: const SizedBox(width: 84, height: 44),
          );
        },
      ),
    );

    await tester.pumpWidget(sample(false));
    await tester.pumpWidget(sample(true));
    await tester.pump(const Duration(milliseconds: 220));
    expect(radius, closeTo(5, 0.1));

    await tester.pumpWidget(sample(false));
    await tester.pump(const Duration(milliseconds: 75));
    final first = radius;
    await tester.pump(const Duration(milliseconds: 100));
    final second = radius;
    await tester.pump(const Duration(milliseconds: 110));
    final third = radius;

    expect(first, greaterThan(5));
    expect(first, lessThan(28));
    expect(second, greaterThan(first));
    expect(second, lessThan(28));
    expect(third, greaterThan(second));
    expect(third, lessThan(28));

    await tester.pumpAndSettle();
    expect(radius, closeTo(28, 0.01));
  });

  test('drawer destinations have default vertical separation', () {
    expect(MorphNavigationDrawerTheme.defaults.destinationVerticalPadding, 4);
  });
}
