import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart' show MaterialApp, Scaffold;
import 'package:morph_expressive/morph_components.dart';

const Key _indicator = ValueKey<String>('morph-tabs-indicator');
const Key _group = ValueKey<String>('morph-tabs-group');
const Key _interaction = ValueKey<String>('morph-tabs-interaction');
const Key _focus = ValueKey<String>('morph-tabs-focus');

class _Bar extends StatefulWidget {
  const _Bar({
    super.key,
    required this.tabs,
    this.theme = const MorphTabTheme(),
    this.fit = MorphTabsIndicatorFit.tab,
    this.style = MorphTabsIndicatorStyle.surface,
    this.alignment = MorphTabsAlignment.fill,
    this.scrollable,
    this.variant = MorphTabsVariant.primary,
    this.renderer,
    this.onRenderer,
  });

  final List<MorphTab> tabs;
  final MorphTabTheme theme;
  final MorphTabsIndicatorFit fit;
  final MorphTabsIndicatorStyle style;
  final MorphTabsAlignment alignment;
  final bool? scrollable;
  final MorphTabsVariant variant;
  final MorphShapeRenderer? renderer;
  final ValueChanged<MorphShapeRenderStatus>? onRenderer;

  @override
  State<_Bar> createState() => _BarState();
}

class _BarState extends State<_Bar> {
  int selected = 0;

  void select(int i) => setState(() => selected = i);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: 500,
            child: MorphTabs(
              tabs: widget.tabs,
              selectedIndex: selected,
              onTabSelected: (int i) => setState(() => selected = i),
              tabTheme: widget.theme,
              indicatorFit: widget.fit,
              indicatorStyle: widget.style,
              alignment: widget.alignment,
              scrollable: widget.scrollable,
              variant: widget.variant,
              indicatorRenderer: widget.renderer,
              onIndicatorRendererChanged: widget.onRenderer,
            ),
          ),
        ),
      ),
    );
  }
}

List<MorphTab> _tabs() => const <MorphTab>[
  MorphTab(label: 'Overview'),
  MorphTab(label: 'Activity'),
  MorphTab(label: 'Updates'),
];

Future<_BarState> _pump(WidgetTester tester, _Bar bar) async {
  final GlobalKey<_BarState> key = GlobalKey<_BarState>();
  await tester.pumpWidget(
    _Bar(
      key: key,
      tabs: bar.tabs,
      theme: bar.theme,
      fit: bar.fit,
      style: bar.style,
      alignment: bar.alignment,
      scrollable: bar.scrollable,
      variant: bar.variant,
      renderer: bar.renderer,
      onRenderer: bar.onRenderer,
    ),
  );
  await tester.pumpAndSettle();
  return key.currentState!;
}

Rect _rect(WidgetTester tester, Key key) => tester.getRect(find.byKey(key));
Rect _bar(WidgetTester tester) => tester.getRect(find.byType(MorphTabs));
Rect _slot(WidgetTester tester, String label) => tester.getRect(
  find.ancestor(of: find.text(label), matching: find.byType(MorphTappable)),
);

Finder _in(String label, Key key) => find.descendant(
  of: find.ancestor(of: find.text(label), matching: find.byType(MorphTappable)),
  matching: find.byKey(key),
);

BorderRadius _radius(WidgetTester tester, Finder f) =>
    (tester.widget<DecoratedBox>(f).decoration as BoxDecoration).borderRadius!
        as BorderRadius;

Future<TestGesture> _hover(WidgetTester tester, Offset at) async {
  final TestGesture g = await tester.createGesture(
    kind: PointerDeviceKind.mouse,
  );
  await g.addPointer(location: const Offset(1, 1));
  addTearDown(g.removePointer);
  await g.moveTo(at);
  await tester.pump(const Duration(milliseconds: 50));
  return g;
}

void main() {
  setUp(MorphFocusInteraction.resetForTest);

  group('underline ends', () {
    test('rounded ends are the default and can be switched off', () {
      final MorphColorScheme scheme = MorphThemeData.light().colorScheme;
      final MorphTabIndicatorSpec on = MorphTabTheme.defaults.resolveIndicator(
        scheme,
        MorphTabsVariant.primary,
      );
      expect(on.topRadius, on.thickness / 2);
      expect(on.bottomRadius, on.thickness / 2);
      expect(on.uniformRadius, isTrue);
      final MorphTabIndicatorSpec off = const MorphTabTheme(
        indicatorRoundedEnds: false,
      ).resolveIndicator(scheme, MorphTabsVariant.primary);
      expect(off.topRadius, 3);
      expect(off.bottomRadius, 0);
      expect(off.uniformRadius, isFalse);
    });

    for (final MorphTabsIndicatorFit fit in MorphTabsIndicatorFit.values) {
      testWidgets('both ends are round for ${fit.name} fit', (
        WidgetTester tester,
      ) async {
        await _pump(
          tester,
          _Bar(
            tabs: _tabs(),
            fit: fit,
            style: MorphTabsIndicatorStyle.underline,
          ),
        );
        final MorphRoundedSurface line = tester.widget(
          find.descendant(
            of: find.byKey(_indicator),
            matching: find.byType(MorphRoundedSurface),
          ),
        );
        expect(line.radius, line.size.height / 2);
        expect(line.size.height, 3);
        expect(
          _rect(tester, _indicator).bottom,
          closeTo(_bar(tester).bottom, 0.01),
        );
      });
    }

    testWidgets('an explicit opt-out restores the flat bottom (Canvas)', (
      WidgetTester tester,
    ) async {
      final List<MorphShapeRenderStatus> statuses = <MorphShapeRenderStatus>[];
      await _pump(
        tester,
        _Bar(
          tabs: _tabs(),
          style: MorphTabsIndicatorStyle.underline,
          theme: const MorphTabTheme(indicatorRoundedEnds: false),
          onRenderer: statuses.add,
        ),
      );
      expect(find.byType(MorphRoundedSurface), findsNothing);
      expect(statuses.last.effective, MorphShapeRenderer.canvas);
    });

    testWidgets('a scrolling bar clips sideways only, never the line edge', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        _Bar(
          tabs: _tabs(),
          scrollable: true,
          style: MorphTabsIndicatorStyle.underline,
        ),
      );
      final ClipRect clip = tester.widget(
        find.byWidgetPredicate(
          (Widget w) =>
              w is ClipRect && '${w.clipper.runtimeType}' == '_ViewportClipper',
        ),
      );
      const Size bar = Size(500, 48);
      final Rect area = clip.clipper!.getClip(bar);
      expect(area.left, 0);
      expect(area.right, 500);
      expect(area.bottom, greaterThan(bar.height));
      expect(area.top, lessThan(0));
    });
  });

  group('surface geometry', () {
    test('radii stay concentric and inside the geometry', () {
      final MorphColorScheme scheme = MorphThemeData.light().colorScheme;
      MorphTabIndicatorSpec spec(MorphTabTheme t) => t.resolveIndicator(
        scheme,
        MorphTabsVariant.primary,
        style: MorphTabsIndicatorStyle.surface,
      );
      const double bar = 48;
      final MorphTabIndicatorSpec pill = spec(const MorphTabTheme());
      expect(pill.surfaceHeight(bar), 40);
      expect(pill.innerRadius(bar), 20, reason: 'a real capsule');
      expect(pill.outerRadius(bar), 24, reason: 'inner + inset = bar / 2');
      final MorphTabIndicatorSpec rect = spec(
        const MorphTabTheme(indicatorSurfaceRadius: 10),
      );
      expect(rect.innerRadius(bar), 10);
      expect(rect.outerRadius(bar), 14, reason: 'outer = inner + inset');
      final MorphTabIndicatorSpec inset = spec(
        const MorphTabTheme(
          indicatorSurfaceRadius: 10,
          indicatorSurfaceInset: 6,
        ),
      );
      expect(inset.outerRadius(bar), 16);
      // Overrides and lerps cannot exceed the capsule.
      final MorphTabIndicatorSpec huge = spec(
        const MorphTabTheme(indicatorSurfaceRadius: 500),
      );
      expect(huge.innerRadius(bar), 20);
      expect(huge.outerRadius(bar), 24);
      expect(
        spec(const MorphTabTheme(indicatorSurfaceRadius: -4)).innerRadius(bar),
        0,
      );
      // Independent radii stay compatible: both honoured as given...
      final MorphTabIndicatorSpec both = spec(
        const MorphTabTheme(
          indicatorSurfaceRadius: 8,
          indicatorGroupRadius: 20,
        ),
      );
      expect(both.innerRadius(bar), 8);
      expect(both.outerRadius(bar), 20);
      // ...and a lone group radius drives the inner one.
      final MorphTabIndicatorSpec group = spec(
        const MorphTabTheme(indicatorGroupRadius: 16),
      );
      expect(group.innerRadius(bar), 12);
      expect(group.outerRadius(bar), 16);
      final MorphTabTheme mid = const MorphTabTheme(indicatorSurfaceRadius: 4)
          .lerp(const MorphTabTheme(indicatorSurfaceRadius: 40), 0.5);
      expect(spec(mid).innerRadius(bar), lessThanOrEqualTo(20));
    });

    for (final double inset in <double>[4, 7]) {
      testWidgets('the inset to the container is $inset on all four sides', (
        WidgetTester tester,
      ) async {
        final MorphTabTheme theme = MorphTabTheme(
          indicatorSurfaceInset: inset,
          indicatorGroupBackground: true,
        );
        final _BarState state = await _pump(
          tester,
          _Bar(tabs: _tabs(), theme: theme),
        );
        for (final int i in <int>[0, 2]) {
          state.select(i);
          await tester.pumpAndSettle();
          final Rect group = _rect(tester, _group);
          final Rect surface = _rect(tester, _indicator);
          final Rect edge = i == 0 ? surface : surface;
          expect(edge.top - group.top, closeTo(inset, 0.01));
          expect(group.bottom - edge.bottom, closeTo(inset, 0.01));
          if (i == 0) expect(surface.left - group.left, closeTo(inset, 0.01));
          if (i == 2) expect(group.right - surface.right, closeTo(inset, 0.01));
        }
      });
    }

    testWidgets('the container follows the radii of the surface', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        _Bar(
          tabs: _tabs(),
          theme: const MorphTabTheme(
            indicatorSurfaceRadius: 10,
            indicatorGroupBackground: true,
          ),
        ),
      );
      final BorderRadius outer =
          (tester.widget<DecoratedBox>(find.byKey(_group)).decoration
                      as BoxDecoration)
                  .borderRadius!
              as BorderRadius;
      expect(outer.topLeft.x, 14);
      final MorphRoundedSurface inner = tester.widget(
        find.descendant(
          of: find.byKey(_indicator),
          matching: find.byType(MorphRoundedSurface),
        ),
      );
      expect(inner.radius, 10);
      expect(_bar(tester).height, 48, reason: 'the outer track is unchanged');
    });

    testWidgets('content padding is independent of the inset and of the axis', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        _Bar(
          tabs: _tabs(),
          fit: MorphTabsIndicatorFit.content,
          alignment: MorphTabsAlignment.content,
          theme: const MorphTabTheme(
            indicatorPadding: 20,
            indicatorSurfaceInset: 6,
          ),
        ),
      );
      final Rect text = tester.getRect(find.text('Overview'));
      final Rect surface = _rect(tester, _indicator);
      expect(surface.left, closeTo(text.left - 20, 0.01));
      expect(surface.right, closeTo(text.right + 20, 0.01));
      expect(surface.height, 48 - 12);
      // Horizontal padding is larger than the vertical gap around the label.
      expect(text.left - surface.left, greaterThan(text.top - surface.top));
      // The first surface sits exactly one inset from the container edge.
      expect(surface.left - _bar(tester).left, closeTo(6, 0.01));
    });

    testWidgets('vertical padding reserves height and never moves', (
      WidgetTester tester,
    ) async {
      final _BarState state = await _pump(
        tester,
        _Bar(
          tabs: _tabs(),
          theme: const MorphTabTheme(indicatorVerticalPadding: 16),
        ),
      );
      final double height = _bar(tester).height;
      expect(height, greaterThan(48));
      state.select(2);
      await tester.pump();
      for (var i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 16));
        expect(_bar(tester).height, height);
      }
    });

    testWidgets('icon and badge are inside the surface and the bar', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        _Bar(
          variant: MorphTabsVariant.secondary,
          fit: MorphTabsIndicatorFit.content,
          alignment: MorphTabsAlignment.content,
          tabs: const <MorphTab>[
            MorphTab(
              label: 'Activity',
              icon: Icon(MorphIcons.home),
              badgeCount: 3,
            ),
            MorphTab(label: 'Updates'),
          ],
        ),
      );
      final Rect surface = _rect(tester, _indicator);
      final Rect icon = tester.getRect(find.byIcon(MorphIcons.home));
      final Rect badge = tester.getRect(find.text('3'));
      final Rect bar = _bar(tester);
      expect(surface.left, lessThan(icon.left));
      expect(surface.right, greaterThan(badge.right));
      expect(badge.top, greaterThanOrEqualTo(bar.top));
      expect(badge.bottom, lessThanOrEqualTo(bar.bottom));
      expect(tester.takeException(), isNull);
    });
  });

  group('interaction shape', () {
    for (final MapEntry<String, double?> style in <String, double?>{
      'pill': null,
      'rounded rectangle': 10,
    }.entries) {
      for (final MorphTabsIndicatorFit fit in MorphTabsIndicatorFit.values) {
        testWidgets('${style.key} / ${fit.name}: hover, press and focus', (
          WidgetTester tester,
        ) async {
          final _BarState state = await _pump(
            tester,
            _Bar(
              tabs: _tabs(),
              fit: fit,
              alignment: fit == MorphTabsIndicatorFit.content
                  ? MorphTabsAlignment.content
                  : MorphTabsAlignment.fill,
              theme: MorphTabTheme(indicatorSurfaceRadius: style.value),
            ),
          );
          final double inner = style.value ?? 20;
          // Hover an unselected tab.
          final TestGesture mouse = await _hover(
            tester,
            _slot(tester, 'Activity').center,
          );
          final Finder layer = _in('Activity', _interaction);
          expect(_radius(tester, layer).topLeft.x, inner);
          final BoxDecoration d =
              tester.widget<DecoratedBox>(layer).decoration as BoxDecoration;
          expect(d.color, isNotNull, reason: 'hover layer is painted');
          // Same rectangle as the surface would have on that tab.
          final Rect hover = tester.getRect(layer);
          final Rect slot = _slot(tester, 'Activity');
          expect(hover.top - slot.top, 4);
          expect(slot.bottom - hover.bottom, 4);
          if (fit == MorphTabsIndicatorFit.tab) {
            expect(hover.left - slot.left, 4);
            expect(slot.right - hover.right, 4);
          } else {
            final Rect text = tester.getRect(find.text('Activity'));
            expect(hover.left, closeTo(text.left - 16, 0.01));
            expect(hover.right, closeTo(text.right + 16, 0.01));
          }
          // The hit target is still the whole slot.
          expect(slot.height, _bar(tester).height);
          // Selected tab hovered too.
          await mouse.moveTo(_slot(tester, 'Overview').center);
          await tester.pump(const Duration(milliseconds: 50));
          expect(
            _radius(tester, _in('Overview', _interaction)).topLeft.x,
            inner,
          );
          // Pressed, during the transition.
          state.select(2);
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 16));
          await tester.pump(const Duration(milliseconds: 60));
          final TestGesture press = await tester.startGesture(
            _slot(tester, 'Activity').center,
          );
          await tester.pump(const Duration(milliseconds: 30));
          expect(
            _radius(tester, _in('Activity', _interaction)).topLeft.x,
            inner,
          );
          await press.up();
          await tester.pumpAndSettle();
        });
      }
    }

    testWidgets('keyboard focus ring is concentric with its own gap', (
      WidgetTester tester,
    ) async {
      await _pump(tester, _Bar(tabs: _tabs()));
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      expect(find.byKey(_focus), findsOneWidget);
      final Rect ring = tester.getRect(find.byKey(_focus));
      final Rect surface = tester.getRect(_in('Overview', _interaction));
      expect(ring, surface.inflate(2));
      expect(_radius(tester, find.byKey(_focus)).topLeft.x, 22);
      // Inside the slot: nothing painted outside the tab.
      expect(ring.top, greaterThanOrEqualTo(_slot(tester, 'Overview').top));
      // Moving focus does not select or move the indicator.
      final Rect before = _rect(tester, _indicator);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      expect(_rect(tester, _indicator), before);
      expect(find.byKey(_focus), findsOneWidget);
    });

    testWidgets('underline tabs keep their previous interaction layer', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        _Bar(tabs: _tabs(), style: MorphTabsIndicatorStyle.underline),
      );
      await _hover(tester, _slot(tester, 'Activity').center);
      expect(find.byKey(_interaction), findsNothing);
    });
  });
}
