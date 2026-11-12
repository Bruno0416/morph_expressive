import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart' show Scaffold;
import 'package:morph_expressive/morph_expressive.dart';

import 'helpers/raster_capture.dart';

Widget host(Widget child, {bool reduced = false, MorphThemeData? data}) =>
    MorphMaterialApp(
      data: data ?? MorphThemeData.light().copyWith(reduceMotion: reduced),
      home: Scaffold(body: Center(child: child)),
    );

MorphButtonDecoration decorationOf(WidgetTester t) =>
    t.widget<MorphButton>(find.byType(MorphButton)).decoration!;

Color? fg(WidgetTester t) => decorationOf(t).foregroundColor?.resolve({});
Color? bg(WidgetTester t) => decorationOf(t).backgroundColor?.resolve({});

double contrast(Color a, Color b) {
  final la = a.computeLuminance(), lb = b.computeLuminance();
  return (math.max(la, lb) + .05) / (math.min(la, lb) + .05);
}

void main() {
  group('AsyncButton error colors', () {
    for (final dark in [false, true]) {
      final data = dark ? MorphThemeData.dark() : MorphThemeData.light();
      for (final style in MorphButtonStyle.values) {
        testWidgets('${style.name} error ${dark ? 'dark' : 'light'}', (
          tester,
        ) async {
          await tester.pumpWidget(
            host(
              MorphAsyncButton(
                label: 'Save',
                style: style,
                state: MorphOperationState.error,
                onPressed: () {},
              ),
              data: data,
            ),
          );
          await tester.pumpAndSettle();
          final c = data.colorScheme;
          final expectedFg = switch (style) {
            MorphButtonStyle.filled => c.onError,
            MorphButtonStyle.tonal => c.onErrorContainer,
            _ => c.error,
          };
          expect(fg(tester), expectedFg);
          if (style == MorphButtonStyle.filled) expect(bg(tester), c.error);
          if (style == MorphButtonStyle.tonal) {
            expect(bg(tester), c.errorContainer);
          }
          if (style == MorphButtonStyle.outlined) {
            expect(decorationOf(tester).side?.resolve({})?.color, c.error);
            expect(bg(tester)!.a, 0);
          }
          if (style == MorphButtonStyle.text) expect(bg(tester)!.a, 0);
          final surface = bg(tester)!.a == 0 ? c.surface : bg(tester)!;
          expect(contrast(fg(tester)!, surface), greaterThan(3));
          // Not color alone: label + error glyph.
          expect(find.byIcon(MorphIcons.error), findsOneWidget);
        });
      }
    }

    testWidgets('overrides beat defaults; disabled differs from error', (
      tester,
    ) async {
      const custom = Color(0xff123456);
      await tester.pumpWidget(
        host(
          MorphAsyncButton(
            label: 'Save',
            state: MorphOperationState.error,
            onPressed: () {},
            stateDecorations: const {
              MorphOperationState.error: MorphButtonDecoration(
                backgroundColor: WidgetStatePropertyAll(custom),
              ),
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(bg(tester), custom);
      expect(fg(tester), MorphThemeData.light().colorScheme.onError);
      await tester.pumpWidget(
        host(
          MorphAsyncButton(
            label: 'Save',
            state: MorphOperationState.error,
            onPressed: null,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(bg(tester), isNot(MorphThemeData.light().colorScheme.error));
    });

    testWidgets('theme error decoration beats defaults, widget beats theme', (
      tester,
    ) async {
      const fromTheme = Color(0xff00aa00), fromWidget = Color(0xffaa00aa);
      final data = MorphThemeData.light().copyWith(
        asyncButtonTheme: const MorphAsyncButtonTheme(
          decorations: {
            MorphOperationState.error: MorphButtonDecoration(
              foregroundColor: WidgetStatePropertyAll(fromTheme),
            ),
          },
        ),
      );
      Widget build({Map<MorphOperationState, MorphButtonDecoration>? s}) =>
          host(
            MorphAsyncButton(
              label: 'Save',
              state: MorphOperationState.error,
              onPressed: () {},
              stateDecorations: s ?? const {},
            ),
            data: data,
          );
      await tester.pumpWidget(build());
      await tester.pumpAndSettle();
      expect(fg(tester), fromTheme);
      await tester.pumpWidget(
        build(
          s: const {
            MorphOperationState.error: MorphButtonDecoration(
              foregroundColor: WidgetStatePropertyAll(fromWidget),
            ),
          },
        ),
      );
      await tester.pumpAndSettle();
      expect(fg(tester), fromWidget);
    });
  });

  group('AsyncButton success transition', () {
    Widget app(
      MorphOperationState s, {
      Widget? success,
      MorphOperationIconTransition? t,
      bool reduced = false,
    }) => host(
      MorphAsyncButton(
        label: 'Save',
        state: s,
        onPressed: () {},
        successIcon: success,
        iconTransition: t,
      ),
      reduced: reduced,
    );

    double rotationOf(WidgetTester t, Finder f) {
      final w = t
          .widgetList<Transform>(
            find.ancestor(of: f, matching: find.byType(Transform)),
          )
          .map((e) => e.transform)
          .toList();
      var best = 0.0;
      for (final m in w) {
        final r = math.atan2(m.entry(1, 0), m.entry(0, 0));
        if (r.abs() > best.abs()) best = r;
      }
      return best;
    }

    testWidgets('custom widget enters rotated -45° and ends straight', (
      tester,
    ) async {
      const key = Key('custom-success');
      await tester.pumpWidget(app(MorphOperationState.loading));
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpWidget(
        app(
          MorphOperationState.success,
          success: const SizedBox.square(key: key, dimension: 20),
        ),
      );
      await tester.pump(const Duration(milliseconds: 40));
      final early = rotationOf(tester, find.byKey(key));
      expect(early, lessThan(-.1));
      expect(early, greaterThan(-math.pi / 4 - .01));
      expect(find.byKey(key), findsOneWidget, reason: 'no internal copy');
      await tester.pumpAndSettle();
      expect(rotationOf(tester, find.byKey(key)), 0);
      expect(find.byType(MorphLoadingIndicator), findsNothing);
    });

    testWidgets(
      'loader fades/scales out while success enters, no full overlap',
      (tester) async {
        await tester.pumpWidget(app(MorphOperationState.loading));
        await tester.pump(const Duration(milliseconds: 300));
        await tester.pumpWidget(app(MorphOperationState.success));
        await tester.pump(const Duration(milliseconds: 100));
        final loader = find.byType(MorphLoadingIndicator);
        expect(loader, findsOneWidget);
        double opacityOf(Finder f) => tester
            .widget<Opacity>(
              find.ancestor(of: f, matching: find.byType(Opacity)).first,
            )
            .opacity;
        final lo = opacityOf(loader);
        final so = opacityOf(find.byIcon(MorphIcons.check_rounded));
        expect(lo, lessThan(1));
        expect(lo + so, lessThanOrEqualTo(1.05));
        await tester.pumpAndSettle();
      },
    );

    testWidgets('disabled transition and reduced motion: no rotation', (
      tester,
    ) async {
      for (final reduced in [false, true]) {
        await tester.pumpWidget(
          app(
            MorphOperationState.loading,
            reduced: reduced,
            t: MorphOperationIconTransition.none,
          ),
        );
        await tester.pump(const Duration(milliseconds: 300));
        await tester.pumpWidget(
          app(
            MorphOperationState.success,
            reduced: reduced,
            t: MorphOperationIconTransition.none,
          ),
        );
        await tester.pump(const Duration(milliseconds: 16));
        expect(rotationOf(tester, find.byIcon(MorphIcons.check_rounded)), 0);
        expect(find.byType(MorphLoadingIndicator), findsNothing);
        await tester.pumpAndSettle();
      }
      await tester.pumpWidget(app(MorphOperationState.loading, reduced: true));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpWidget(app(MorphOperationState.success, reduced: true));
      await tester.pump(const Duration(milliseconds: 16));
      expect(rotationOf(tester, find.byIcon(MorphIcons.check_rounded)), 0);
      expect(find.byType(MorphLoadingIndicator), findsNothing);
    });

    testWidgets('interruptions start from visible values and settle straight', (
      tester,
    ) async {
      await tester.pumpWidget(app(MorphOperationState.loading));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpWidget(app(MorphOperationState.success));
      await tester.pump(const Duration(milliseconds: 80));
      final mid = rotationOf(tester, find.byIcon(MorphIcons.check_rounded));
      await tester.pumpWidget(app(MorphOperationState.loading));
      await tester.pump(const Duration(milliseconds: 1));
      // the check is now leaving from its visible pose, not reset.
      expect(
        rotationOf(tester, find.byIcon(MorphIcons.check_rounded)),
        closeTo(mid, .12),
      );
      await tester.pumpWidget(app(MorphOperationState.error));
      await tester.pump(const Duration(milliseconds: 60));
      await tester.pumpWidget(app(MorphOperationState.success));
      await tester.pumpAndSettle();
      expect(find.byIcon(MorphIcons.check_rounded), findsOneWidget);
      expect(find.byIcon(MorphIcons.error), findsNothing);
      expect(rotationOf(tester, find.byIcon(MorphIcons.check_rounded)), 0);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('compact → success never overflows while widening', (
      tester,
    ) async {
      Widget c(MorphOperationState s) => host(
        MorphAsyncButton(
          label: 'Save',
          state: s,
          presentation: MorphOperationPresentation.compact,
          onPressed: () {},
        ),
      );
      await tester.pumpWidget(c(MorphOperationState.loading));
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpWidget(c(MorphOperationState.success));
      for (var i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }
      expect(tester.takeException(), isNull);
      await tester.pumpAndSettle();
    });

    testWidgets('small preserved button keeps glyph and label readable', (
      tester,
    ) async {
      Widget a(MorphOperationState st) => host(
        MorphAsyncButton(
          label: 'Save',
          state: st,
          labels: const {
            MorphOperationState.loading: 'Saving',
            MorphOperationState.success: 'Saved',
            MorphOperationState.error: 'Retry',
          },
          onPressed: () {},
        ),
      );
      await tester.pumpWidget(a(MorphOperationState.idle));
      final idle = tester.getSize(find.byType(MorphAsyncButton)).width;
      for (final st in [
        MorphOperationState.loading,
        MorphOperationState.success,
        MorphOperationState.error,
      ]) {
        await tester.pumpWidget(a(st));
        await tester.pump(const Duration(seconds: 1));
        final width = tester.getSize(find.byType(MorphAsyncButton)).width;
        expect(width, greaterThanOrEqualTo(idle));
        final label = find.text(
          tester.widgetList<Text>(find.byType(Text)).first.data!,
        );
        expect(
          tester.getSize(label).width,
          greaterThan(24),
          reason: 'label not squeezed to an ellipsis',
        );
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('no internal timers: idle never returns by itself', (
      tester,
    ) async {
      await tester.pumpWidget(app(MorphOperationState.success));
      await tester.pump(const Duration(seconds: 10));
      expect(find.byIcon(MorphIcons.check_rounded), findsOneWidget);
    });
  });

  group('Shimmer angle', () {
    test('geometry: 0° is original; ± symmetric; band width stable', () {
      const size = Size(300, 100);
      final g0 = morphShimmerGeometry(
        size,
        MorphShimmerDirection.leftToRight,
        0,
      );
      expect(g0.normal, const Offset(1, 0));
      expect(g0.length, 300);
      expect(g0.halfWidth, closeTo(60, 1e-9));
      for (final deg in [15.0, 30, 45]) {
        final a = deg * math.pi / 180;
        final p = morphShimmerGeometry(
          size,
          MorphShimmerDirection.leftToRight,
          a,
        );
        final n = morphShimmerGeometry(
          size,
          MorphShimmerDirection.leftToRight,
          -a,
        );
        expect(p.length, closeTo(n.length, 1e-9));
        for (final c in const [
          Offset(0, 0),
          Offset(300, 0),
          Offset(0, 100),
          Offset(300, 100),
        ]) {
          final u = c.dx * p.normal.dx + c.dy * p.normal.dy;
          expect(
            u,
            greaterThanOrEqualTo(p.min - 1e-9),
            reason: 'covers corners',
          );
          expect(u, lessThanOrEqualTo(p.min + p.length + 1e-9));
        }
        expect(p.normal.dy, closeTo(-n.normal.dy, 1e-9));
        expect(p.halfWidth, closeTo(60, 1e-9));
      }
      final near = morphShimmerGeometry(
        size,
        MorphShimmerDirection.leftToRight,
        85 * math.pi / 180,
      );
      expect(near.length.isFinite && near.length > 0, isTrue);
      expect(near.halfWidth, lessThanOrEqualTo(.45 * near.length + 1e-9));
    });

    Widget group(
      double? angle, {
      MorphSkeletonEffect effect = MorphSkeletonEffect.shimmer,
      GlobalKey? key,
    }) => RepaintBoundary(
      key: key,
      child: SizedBox(
        width: 240,
        child: MorphSkeletonGroup(
          renderer: MorphShapeRenderer.canvas,
          effect: effect,
          angle: angle,
          intensity: 1,
          baseColor: const Color(0xff222222),
          highlightColor: const Color(0xffeeeeee),
          placeholder: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MorphSkeleton(width: 240, height: 40, radius: 0),
              SizedBox(height: 10),
              MorphSkeleton(width: 120, height: 40, radius: 0),
            ],
          ),
        ),
      ),
    );

    testWidgets('angle 0 equals default; angle tilts; rows share one space', (
      tester,
    ) async {
      final a = GlobalKey(), b = GlobalKey(), c = GlobalKey();
      await tester.pumpWidget(
        host(
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              group(null, key: a),
              group(0, key: b),
              group(30, key: c),
            ],
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 650));
      final ra = await captureRaster(tester, a),
          rb = await captureRaster(tester, b),
          tilted = await captureRaster(tester, c);
      expect(ra.rgba, orderedEquals(rb.rgba));
      expect(tilted.rgba, isNot(orderedEquals(ra.rgba)));
      // Same iso-line (constant dot with normal) → same colour in both rows.
      final n = Offset(
        math.cos(30 * math.pi / 180),
        math.sin(30 * math.pi / 180),
      );
      var checked = 0;
      for (var x = 5; x < 115; x += 3) {
        final u = x * n.dx + 20 * n.dy; // row 1 sample (y=20)
        // row 2 spans y 50..90 in group space; solve y so dot matches.
        final y2 = (u - 60 * n.dx) / n.dy; // x2=60
        if (y2 < 52 || y2 > 88) continue;
        for (var ch = 0; ch < 3; ch++) {
          expect(
            tilted.channel(x, 20, ch),
            closeTo(tilted.channel(60, y2.round(), ch), 14),
          );
        }
        checked++;
      }
      expect(checked, greaterThan(0));
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('pulse and static ignore angle; theme angle applies', (
      tester,
    ) async {
      final a = GlobalKey(), b = GlobalKey();
      await tester.pumpWidget(
        host(
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              group(0, effect: MorphSkeletonEffect.pulse, key: a),
              group(40, effect: MorphSkeletonEffect.pulse, key: b),
            ],
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));
      expect(
        (await captureRaster(tester, a)).rgba,
        orderedEquals((await captureRaster(tester, b)).rgba),
      );
      final t = GlobalKey(), w = GlobalKey();
      await tester.pumpWidget(
        host(
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [group(null, key: t)],
          ),
          data: MorphThemeData.light().copyWith(
            skeletonTheme: const MorphSkeletonTheme(angle: 30),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 650));
      final themed = await captureRaster(tester, t);
      await tester.pumpWidget(
        host(
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [group(30, key: w)],
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 650));
      expect(themed.rgba, orderedEquals((await captureRaster(tester, w)).rgba));
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('phase survives rebuild with new angle; dispose clean', (
      tester,
    ) async {
      final k = GlobalKey();
      await tester.pumpWidget(host(group(15, key: k)));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpWidget(host(group(-15, key: k)));
      await tester.pump(const Duration(milliseconds: 1));
      await tester.pumpWidget(const SizedBox());
      expect(tester.takeException(), isNull);
    });
  });
}
