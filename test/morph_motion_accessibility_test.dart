import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morph_expressive/morph_expressive.dart';
import 'package:morph_expressive/foundations/interaction/morph_motion_controller.dart';

Widget _host(Widget child) => MorphMaterialApp(
  data: MorphThemeData.light(),
  home: Center(child: child),
);

class _Probe extends StatefulWidget {
  const _Probe({required this.target, super.key});
  final double target;

  @override
  State<_Probe> createState() => _ProbeState();
}

class _ProbeState extends State<_Probe> with SingleTickerProviderStateMixin {
  late final controller = MorphMotionController(
    vsync: this,
    motion: MorphMotion.springMotion(MorphMotion.spatialSlow),
  );
  bool completed = false;

  @override
  void didUpdateWidget(_Probe oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.target != widget.target) {
      controller.animateTo(widget.target).then((_) => completed = true);
    }
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: controller,
    builder: (context, _) => SizedBox(width: 10 + controller.value, height: 10),
  );

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

class _InitialProbe extends StatefulWidget {
  const _InitialProbe();

  @override
  State<_InitialProbe> createState() => _InitialProbeState();
}

class _InitialProbeState extends State<_InitialProbe>
    with SingleTickerProviderStateMixin {
  late final MorphMotionController controller;
  double? observed;

  @override
  void initState() {
    super.initState();
    controller =
        MorphMotionController(
            vsync: this,
            motion: MorphMotion.springMotion(MorphMotion.spatialSlow),
          )
          ..addListener(() => observed = controller.value)
          ..animateTo(100);
  }

  @override
  Widget build(BuildContext context) => const SizedBox();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

void main() {
  testWidgets(
    'reduced initial animation safely completes cascaded assignments',
    (tester) async {
      await tester.pumpWidget(
        _host(
          const MorphMotionScope(reduceMotion: true, child: _InitialProbe()),
        ),
      );
      final state = tester.state<_InitialProbeState>(
        find.byType(_InitialProbe),
      );
      expect(state.observed, 100);
      expect(state.controller.isAnimating, isFalse);
      expect(tester.takeException(), isNull);
    },
  );

  test('theme copying and dark derivation preserve reduced motion', () {
    final theme = MorphThemeData.light().copyWith(reduceMotion: true);
    expect(theme.copyWith().reduceMotion, isTrue);
    expect(theme.deriveDarkTemplate().reduceMotion, isTrue);
    expect(theme.copyWith(reduceMotion: false).reduceMotion, isFalse);
  });

  testWidgets(
    'nested scopes cannot re-enable motion requested by an ancestor',
    (tester) async {
      bool? reduced;
      await tester.pumpWidget(
        _host(
          MorphMotionScope(
            reduceMotion: true,
            child: MorphMotionScope(
              reduceMotion: false,
              child: Builder(
                builder: (context) {
                  reduced = MorphMotion.reduceMotionOf(context);
                  expect(MediaQuery.disableAnimationsOf(context), isTrue);
                  return const SizedBox();
                },
              ),
            ),
          ),
        ),
      );
      expect(reduced, isTrue);
    },
  );

  testWidgets('theme option reaches all descendant widget families', (
    tester,
  ) async {
    bool? reduced;
    await tester.pumpWidget(
      MorphMaterialApp(
        data: MorphThemeData.light().copyWith(reduceMotion: true),
        home: Builder(
          builder: (context) {
            reduced = MorphMotion.reduceMotionOf(context);
            return const SizedBox();
          },
        ),
      ),
    );
    expect(reduced, isTrue);
  });

  testWidgets(
    'changing scope completes an active spring and its awaited future',
    (tester) async {
      final key = GlobalKey<_ProbeState>();
      var reduced = false;
      var target = 0.0;
      late StateSetter update;
      await tester.pumpWidget(
        _host(
          StatefulBuilder(
            builder: (context, setState) {
              update = setState;
              return MorphMotionScope(
                reduceMotion: reduced,
                child: _Probe(key: key, target: target),
              );
            },
          ),
        ),
      );
      update(() => target = 100);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 16));
      final systemReduced =
          tester.binding.platformDispatcher.accessibilityFeatures;
      if (!systemReduced.disableAnimations && !systemReduced.reduceMotion) {
        expect(key.currentState!.controller.value, lessThan(100));
        expect(key.currentState!.controller.isAnimating, isTrue);
      }
      update(() => reduced = true);
      await tester.pump();
      expect(key.currentState!.controller.value, 100);
      expect(key.currentState!.controller.isAnimating, isFalse);
      expect(key.currentState!.completed, isTrue);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'new transitions after reduced motion preserve completion status',
    (tester) async {
      final key = GlobalKey<_ProbeState>();
      Widget sample(double target) => _host(
        MorphMotionScope(
          reduceMotion: true,
          child: _Probe(key: key, target: target),
        ),
      );
      await tester.pumpWidget(sample(0));
      await tester.pumpWidget(sample(100));
      expect(key.currentState!.controller.value, 100);
      expect(key.currentState!.controller.status, AnimationStatus.completed);
      expect(key.currentState!.completed, isTrue);
      await tester.pumpWidget(sample(0));
      expect(key.currentState!.controller.status, AnimationStatus.dismissed);
    },
  );

  testWidgets('local preference survives captured overlay themes', (
    tester,
  ) async {
    late Widget captured;
    bool? reduced;
    await tester.pumpWidget(
      _host(
        MorphMotionScope(
          reduceMotion: true,
          child: Builder(
            builder: (context) {
              captured = InheritedTheme.captureAll(
                context,
                Builder(
                  builder: (context) {
                    reduced = MorphMotion.reduceMotionOf(context);
                    return const SizedBox();
                  },
                ),
              );
              return const SizedBox();
            },
          ),
        ),
      ),
    );
    await tester.pumpWidget(_host(captured));
    expect(reduced, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('local MediaQuery preference is honored without a Morph theme', (
    tester,
  ) async {
    bool? reduced;
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(disableAnimations: true),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Builder(
            builder: (context) {
              reduced = MorphMotion.reduceMotionOf(context);
              return const SizedBox();
            },
          ),
        ),
      ),
    );
    expect(reduced, isTrue);
  });
}
