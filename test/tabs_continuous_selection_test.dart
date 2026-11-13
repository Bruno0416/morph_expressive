import 'dart:ui' show SemanticsRole, Tristate;

import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart' show MaterialApp, Scaffold;
import 'package:morph_expressive/morph_components.dart';

const Key _indicatorKey = ValueKey<String>('morph-tabs-indicator');

/// The reduced-motion audit forces the platform preference for the whole run;
/// tests that need real travel cannot observe it there. The reduced behaviour
/// itself is covered by the dedicated reduced-motion test below.
const bool _platformForcesReducedMotion =
    String.fromEnvironment('MORPH_MOTION_AUDIT_PROFILE') == 'reduced' ||
    String.fromEnvironment('MORPH_MOTION_AUDIT_PROFILE') == 'reduce-only';

/// A bar (and optionally real pages) whose selection is owned by the test.
class _Host extends StatefulWidget {
  const _Host({
    super.key,
    required this.tabs,
    this.initial = 0,
    this.pages = false,
    this.shareController = true,
    this.style,
    this.motion,
    this.fit,
    this.alignment = MorphTabsAlignment.fill,
    this.scrollable,
    this.variant = MorphTabsVariant.primary,
    this.tabTheme,
    this.accept,
    this.renderer,
    this.onRenderer,
    this.duration,
    this.width,
    this.textScale = 1,
    this.rtl = false,
    this.reduced = false,
    this.pageDuration = const Duration(milliseconds: 300),
    this.externalController,
  });

  final List<MorphTab> tabs;
  final int initial;
  final bool pages;
  final bool shareController;
  final MorphTabsIndicatorStyle? style;
  final MorphTabsIndicatorMotion? motion;
  final MorphTabsIndicatorFit? fit;
  final MorphTabsAlignment alignment;
  final bool? scrollable;
  final MorphTabsVariant variant;
  final MorphTabTheme? tabTheme;
  final bool Function(int index)? accept;
  final MorphShapeRenderer? renderer;
  final ValueChanged<MorphShapeRenderStatus>? onRenderer;
  final Duration? duration;
  final double? width;
  final double textScale;
  final bool rtl;
  final bool reduced;
  final Duration pageDuration;
  final MorphTabsController? externalController;

  @override
  State<_Host> createState() => _HostState();
}

class _HostState extends State<_Host> {
  late int selected = widget.initial;
  late List<MorphTab> tabs = widget.tabs;
  late final MorphTabsController controller =
      widget.externalController ?? MorphTabsController();
  final List<int> selections = <int>[];

  void select(int index) => setState(() => selected = index);
  void setTabs(List<MorphTab> value, {int? index}) => setState(() {
    tabs = value;
    if (index != null) selected = index;
  });

  void _onSelected(int index) {
    selections.add(index);
    if (widget.accept?.call(index) ?? true) {
      setState(() => selected = index);
    }
  }

  @override
  void dispose() {
    if (widget.externalController == null) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final MorphTabsController? shared = widget.shareController
        ? controller
        : null;
    Widget body = Column(
      children: <Widget>[
        MorphTabs(
          tabs: tabs,
          selectedIndex: selected,
          onTabSelected: _onSelected,
          controller: shared,
          variant: widget.variant,
          alignment: widget.alignment,
          scrollable: widget.scrollable,
          indicatorStyle: widget.style,
          indicatorMotion: widget.motion,
          indicatorFit: widget.fit,
          indicatorRenderer: widget.renderer,
          indicatorDuration: widget.duration,
          onIndicatorRendererChanged: widget.onRenderer,
          tabTheme: widget.tabTheme,
        ),
        if (widget.pages)
          Expanded(
            child: MorphTabsView(
              selectedIndex: selected,
              onTabSelected: _onSelected,
              controller: shared,
              duration: widget.pageDuration,
              children: <Widget>[
                for (var i = 0; i < tabs.length; i++)
                  Center(child: Text('page $i')),
              ],
            ),
          )
        else
          const Spacer(),
      ],
    );
    if (widget.width != null) {
      body = Align(
        alignment: Alignment.topLeft,
        child: SizedBox(width: widget.width, child: body),
      );
    }
    return MaterialApp(
      builder: (BuildContext context, Widget? child) {
        Widget result = MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(widget.textScale)),
          child: Directionality(
            textDirection: widget.rtl ? TextDirection.rtl : TextDirection.ltr,
            child: child!,
          ),
        );
        if (widget.reduced) {
          result = MorphMotionScope(reduceMotion: true, child: result);
        }
        return result;
      },
      home: Scaffold(body: body),
    );
  }
}

List<MorphTab> _tabs(List<String> labels) => <MorphTab>[
  for (final String label in labels) MorphTab(label: label),
];

final List<MorphTab> _five = _tabs(<String>[
  'One',
  'Two',
  'Three',
  'Four',
  'Five',
]);

Future<_HostState> _pump(WidgetTester tester, _Host host) async {
  final GlobalKey<_HostState> key = GlobalKey<_HostState>();
  await tester.pumpWidget(
    _Host(
      key: key,
      tabs: host.tabs,
      initial: host.initial,
      pages: host.pages,
      shareController: host.shareController,
      style: host.style,
      motion: host.motion,
      fit: host.fit,
      alignment: host.alignment,
      scrollable: host.scrollable,
      variant: host.variant,
      tabTheme: host.tabTheme,
      accept: host.accept,
      renderer: host.renderer,
      onRenderer: host.onRenderer,
      duration: host.duration,
      width: host.width,
      textScale: host.textScale,
      rtl: host.rtl,
      reduced: host.reduced,
      pageDuration: host.pageDuration,
      externalController: host.externalController,
    ),
  );
  await tester.pumpAndSettle();
  return key.currentState!;
}

Rect _indicator(WidgetTester tester) =>
    tester.getRect(find.byKey(_indicatorKey));

Rect _slot(WidgetTester tester, String label) => tester.getRect(
  find.ancestor(of: find.text(label), matching: find.byType(MorphTappable)),
);

Rect _barRect(WidgetTester tester) => tester.getRect(find.byType(MorphTabs));

double _pagePixels(WidgetTester tester) {
  final ScrollableState state = tester.state<ScrollableState>(
    find.descendant(
      of: find.byType(MorphTabsView),
      matching: find.byType(Scrollable),
    ),
  );
  return state.position.pixels;
}

/// Pumps frames until nothing animates, recording the indicator each frame.
Future<List<Rect>> _record(WidgetTester tester, {int maxFrames = 80}) async {
  final List<Rect> frames = <Rect>[_indicator(tester)];
  for (var i = 0; i < maxFrames; i++) {
    await tester.pump(const Duration(milliseconds: 16));
    expect(find.byKey(_indicatorKey), findsOneWidget, reason: 'frame $i');
    frames.add(_indicator(tester));
    if (!tester.hasRunningAnimations) {
      break;
    }
  }
  return frames;
}

void main() {
  setUp(MorphFocusInteraction.resetForTest);

  group('compatibility defaults', () {
    testWidgets('primary underline: 3dp, bottom aligned, follows the content', (
      WidgetTester tester,
    ) async {
      await _pump(tester, _Host(tabs: _tabs(<String>['Alpha', 'Beta gamma'])));
      final Rect bar = _barRect(tester);
      final Rect text = tester.getRect(find.text('Alpha'));
      final Rect line = _indicator(tester);
      expect(line.height, 3);
      expect(line.bottom, closeTo(bar.bottom, 0.01));
      // Previous behaviour: content width minus the 2dp inset on each side.
      expect(line.width, closeTo(text.width - 4, 0.01));
      expect(line.center.dx, closeTo(text.center.dx, 0.01));
    });

    testWidgets('secondary underline: 2dp over the whole tab', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        _Host(
          tabs: _tabs(<String>['Alpha', 'Beta']),
          variant: MorphTabsVariant.secondary,
        ),
      );
      final Rect line = _indicator(tester);
      final Rect slot = _slot(tester, 'Alpha');
      expect(line.height, 2);
      expect(line.left, closeTo(slot.left, 0.01));
      expect(line.width, closeTo(slot.width, 0.01));
    });

    testWidgets('the style is independent of the variant', (
      WidgetTester tester,
    ) async {
      for (final MorphTabsVariant variant in MorphTabsVariant.values) {
        await _pump(
          tester,
          _Host(
            tabs: _tabs(<String>['Alpha', 'Beta']),
            variant: variant,
            style: MorphTabsIndicatorStyle.surface,
          ),
        );
        final Rect bar = _barRect(tester);
        final Rect surface = _indicator(tester);
        expect(surface.height, bar.height - 8, reason: '$variant');
        expect(surface.top, closeTo(bar.top + 4, 0.01));
      }
    });
  });

  group('measurement and destinations', () {
    testWidgets('a stacked badge stays inside the bar at 2x text', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        _Host(
          tabs: const <MorphTab>[
            MorphTab(label: 'Home', icon: Icon(MorphIcons.home)),
            MorphTab(
              label: 'Inbox',
              icon: Icon(MorphIcons.home),
              badgeCount: 8,
            ),
          ],
          textScale: 2,
        ),
      );
      final Rect bar = _barRect(tester);
      expect(tester.getRect(find.text('8')).top, greaterThanOrEqualTo(bar.top));
      expect(tester.takeException(), isNull);
    });

    testWidgets('text 2x grows the bar only as much as the content needs', (
      WidgetTester tester,
    ) async {
      final List<MorphTab> stacked = <MorphTab>[
        const MorphTab(label: 'Home', icon: Icon(MorphIcons.home)),
        const MorphTab(label: 'Profile', icon: Icon(MorphIcons.star_outline)),
      ];
      await _pump(tester, _Host(tabs: stacked));
      expect(_barRect(tester).height, 64);
      final _HostState host = await _pump(
        tester,
        _Host(tabs: stacked, textScale: 2),
      );
      final double scaled = _barRect(tester).height;
      expect(scaled, greaterThan(64));
      expect(tester.takeException(), isNull, reason: 'no overflow at 2x');
      // The height never depends on the selection or on the motion.
      host.select(1);
      await tester.pump();
      for (var i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 16));
        expect(_barRect(tester).height, scaled);
      }
    });

    testWidgets('content fit follows text of different widths', (
      WidgetTester tester,
    ) async {
      final _HostState host = await _pump(
        tester,
        _Host(
          tabs: _tabs(<String>['A', 'A much longer label', 'Mid']),
          alignment: MorphTabsAlignment.content,
          style: MorphTabsIndicatorStyle.surface,
          fit: MorphTabsIndicatorFit.content,
        ),
      );
      for (var i = 0; i < 3; i++) {
        host.select(i);
        await tester.pumpAndSettle();
        final Rect text = tester.getRect(
          find.text(<String>['A', 'A much longer label', 'Mid'][i]),
        );
        final Rect surface = _indicator(tester);
        expect(surface.width, closeTo(text.width + 32, 0.01), reason: 'tab $i');
        expect(surface.center.dx, closeTo(text.center.dx, 0.01));
      }
    });

    testWidgets('tab fit follows the slot minus the inset', (
      WidgetTester tester,
    ) async {
      final _HostState host = await _pump(
        tester,
        _Host(
          tabs: _tabs(<String>['A', 'A much longer label', 'Mid']),
          alignment: MorphTabsAlignment.content,
          style: MorphTabsIndicatorStyle.surface,
          fit: MorphTabsIndicatorFit.tab,
        ),
      );
      host.select(1);
      await tester.pumpAndSettle();
      final Rect slot = _slot(tester, 'A much longer label');
      final Rect surface = _indicator(tester);
      expect(surface.left, closeTo(slot.left + 4, 0.01));
      expect(surface.right, closeTo(slot.right - 4, 0.01));
    });

    testWidgets('distribution and fit are independent decisions', (
      WidgetTester tester,
    ) async {
      // Uniform distribution with a content fit, and content distribution
      // with a tab fit, are both valid and measured from the real layout.
      await _pump(
        tester,
        _Host(
          tabs: _tabs(<String>['Short', 'A noticeably longer one']),
          alignment: MorphTabsAlignment.fill,
          style: MorphTabsIndicatorStyle.surface,
          fit: MorphTabsIndicatorFit.content,
        ),
      );
      final Rect slot = _slot(tester, 'Short');
      final Rect text = tester.getRect(find.text('Short'));
      expect(slot.width, closeTo(400, 0.5));
      expect(_indicator(tester).width, closeTo(text.width + 32, 0.01));
    });

    testWidgets('icons and badges are part of the measured content', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        _Host(
          variant: MorphTabsVariant.secondary,
          style: MorphTabsIndicatorStyle.surface,
          fit: MorphTabsIndicatorFit.content,
          alignment: MorphTabsAlignment.content,
          tabs: const <MorphTab>[
            MorphTab(
              label: 'Inbox',
              icon: Icon(MorphIcons.home),
              badgeCount: 4,
            ),
            MorphTab(label: 'Sent'),
          ],
        ),
      );
      final Rect icon = tester.getRect(find.byIcon(MorphIcons.home));
      final Rect badge = tester.getRect(find.text('4'));
      final Rect surface = _indicator(tester);
      expect(surface.left, lessThan(icon.left));
      expect(surface.right, greaterThan(badge.right));
    });

    testWidgets('text scale 2x re-measures the destination', (
      WidgetTester tester,
    ) async {
      final List<MorphTab> tabs = _tabs(<String>['Alpha', 'Beta', 'Gamma']);
      await _pump(
        tester,
        _Host(
          tabs: tabs,
          style: MorphTabsIndicatorStyle.surface,
          fit: MorphTabsIndicatorFit.content,
          alignment: MorphTabsAlignment.content,
        ),
      );
      final double normal = _indicator(tester).width;
      await _pump(
        tester,
        _Host(
          tabs: tabs,
          style: MorphTabsIndicatorStyle.surface,
          fit: MorphTabsIndicatorFit.content,
          alignment: MorphTabsAlignment.content,
          textScale: 2,
        ),
      );
      final Rect text = tester.getRect(find.text('Alpha'));
      expect(_indicator(tester).width, greaterThan(normal * 1.5));
      expect(_indicator(tester).width, closeTo(text.width + 32, 0.01));
      expect(tester.takeException(), isNull);
    });

    testWidgets('the window size re-measures without animating', (
      WidgetTester tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(800, 600);
      addTearDown(tester.view.reset);
      final _HostState host = await _pump(
        tester,
        _Host(tabs: _five, fit: MorphTabsIndicatorFit.tab),
      );
      host.select(2);
      await tester.pumpAndSettle();
      expect(
        _indicator(tester).left,
        closeTo(_slot(tester, 'Three').left, 0.01),
      );
      tester.view.physicalSize = const Size(500, 600);
      await tester.pump();
      await tester.pump();
      expect(
        _indicator(tester).left,
        closeTo(_slot(tester, 'Three').left, 0.01),
      );
      expect(_indicator(tester).width, closeTo(100, 0.01));
    });
  });

  group('motion profiles', () {
    for (final MorphTabsIndicatorMotion motion
        in MorphTabsIndicatorMotion.values) {
      testWidgets(
        '${motion.name}: valid rectangle, still tabs, exact arrival',
        (WidgetTester tester) async {
          final _HostState host = await _pump(
            tester,
            _Host(
              tabs: _tabs(<String>[
                'Alpha',
                'Beta gamma delta',
                'Eps',
                'Zeta one',
              ]),
              style: MorphTabsIndicatorStyle.surface,
              fit: MorphTabsIndicatorFit.content,
              alignment: MorphTabsAlignment.content,
              motion: motion,
            ),
          );
          final Rect bar = _barRect(tester);
          final Map<String, Rect> before = <String, Rect>{
            for (final String l in <String>[
              'Alpha',
              'Beta gamma delta',
              'Eps',
              'Zeta one',
            ])
              l: _slot(tester, l),
          };
          host.select(3);
          await tester.pump();
          final List<Rect> frames = await _record(tester);
          for (final Rect frame in frames) {
            expect(frame.width, greaterThanOrEqualTo(0));
            expect(frame.height, 40);
            expect(frame.left, greaterThanOrEqualTo(bar.left - 0.01));
            expect(frame.right, lessThanOrEqualTo(bar.right + 0.01));
          }
          for (var i = 1; i < frames.length; i++) {
            expect(
              frames[i].left,
              greaterThanOrEqualTo(frames[i - 1].left - 0.01),
            );
            expect(
              frames[i].right,
              greaterThanOrEqualTo(frames[i - 1].right - 0.01),
            );
          }
          final Rect text = tester.getRect(find.text('Zeta one'));
          expect(frames.last.center.dx, closeTo(text.center.dx, 0.01));
          expect(frames.last.width, closeTo(text.width + 32, 0.01));
          // Tabs and the bar never moved or changed height.
          expect(_barRect(tester), bar);
          for (final MapEntry<String, Rect> e in before.entries) {
            expect(_slot(tester, e.key), e.value);
          }
        },
      );
    }

    testWidgets(
      'elastic stretches discreetly, slide does not',
      skip: _platformForcesReducedMotion,
      (WidgetTester tester) async {
        Future<double> peakWidth(MorphTabsIndicatorMotion motion) async {
          final _HostState host = await _pump(
            tester,
            _Host(
              tabs: _tabs(<String>['One', 'Two', 'Three', 'Four']),
              style: MorphTabsIndicatorStyle.surface,
              fit: MorphTabsIndicatorFit.tab,
              motion: motion,
            ),
          );
          final double rest = _indicator(tester).width;
          host.select(3);
          await tester.pump();
          final List<Rect> frames = await _record(tester);
          final double peak = frames
              .map((Rect r) => r.width)
              .reduce((double a, double b) => a > b ? a : b);
          expect(frames.last.width, closeTo(rest, 0.01));
          return peak / rest;
        }

        final double slide = await peakWidth(MorphTabsIndicatorMotion.slide);
        final double elastic = await peakWidth(
          MorphTabsIndicatorMotion.elastic,
        );
        expect(slide, closeTo(1, 0.001));
        expect(elastic, greaterThan(1.02));
        expect(elastic, lessThan(1.6));
      },
    );

    test('geometry: elastic edges are monotonic, ordered and exact', () {
      final List<MorphTabsEdges> cases = <MorphTabsEdges>[
        const MorphTabsEdges(0, 100),
        const MorphTabsEdges(110, 130),
        const MorphTabsEdges(10, 30),
        const MorphTabsEdges(0, 400),
        const MorphTabsEdges(390, 400),
        const MorphTabsEdges(50, 60),
      ];
      for (final MorphTabsEdges a in cases) {
        for (final MorphTabsEdges b in cases) {
          for (final double k in <double>[0, 0.3, 1]) {
            MorphTabsEdges previous = a;
            final bool forward = b.center >= a.center;
            for (var i = 0; i <= 50; i++) {
              final double t = i / 50;
              final MorphTabsEdges e = MorphTabsGeometry.between(
                a,
                b,
                t,
                motion: MorphTabsIndicatorMotion.elastic,
                elasticity: k,
              );
              expect(e.width, greaterThanOrEqualTo(0));
              expect(e.right, greaterThanOrEqualTo(e.left));
              if (a.left <= b.left) {
                expect(e.left, greaterThanOrEqualTo(previous.left - 1e-9));
              } else {
                expect(e.left, lessThanOrEqualTo(previous.left + 1e-9));
              }
              if (a.right <= b.right) {
                expect(e.right, greaterThanOrEqualTo(previous.right - 1e-9));
              } else {
                expect(e.right, lessThanOrEqualTo(previous.right + 1e-9));
              }
              previous = e;
              if (forward && a.left < b.left && a.right < b.right) {
                // The leading (right) edge is never behind the slide.
                final MorphTabsEdges plain = MorphTabsGeometry.between(a, b, t);
                expect(e.right, greaterThanOrEqualTo(plain.right - 1e-9));
                expect(e.left, lessThanOrEqualTo(plain.left + 1e-9));
              }
            }
            expect(previous, b);
          }
        }
      }
    });

    test(
      'geometry: position maps to neighbours and weights ignore the rest',
      () {
        const List<MorphTabsEdges> t = <MorphTabsEdges>[
          MorphTabsEdges(0, 10),
          MorphTabsEdges(20, 50),
          MorphTabsEdges(60, 70),
        ];
        expect(
          MorphTabsGeometry.atPosition(t, 0.5),
          const MorphTabsEdges(10, 30),
        );
        expect(MorphTabsGeometry.atPosition(t, 2), t[2]);
        expect(MorphTabsGeometry.atPosition(t, 9), t[2]);
        expect(MorphTabsGeometry.atPosition(t, -3), t[0]);
        expect(MorphTabsGeometry.weights(3, 0.25), <double>[0.75, 0.25, 0]);
        expect(MorphTabsGeometry.weights(5, 2, from: 0, to: 4), <double>[
          0.5,
          0,
          0,
          0,
          0.5,
        ]);
      },
    );
  });

  group('taps', () {
    testWidgets(
      'retargeting starts from the visible rectangle',
      skip: _platformForcesReducedMotion,
      (WidgetTester tester) async {
        final _HostState host = await _pump(
          tester,
          _Host(tabs: _five, fit: MorphTabsIndicatorFit.tab),
        );
        host.select(4);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 16));
        await tester.pump(const Duration(milliseconds: 90));
        final Rect mid = _indicator(tester);
        expect(mid.left, greaterThan(_slot(tester, 'One').left + 1));
        expect(mid.left, lessThan(_slot(tester, 'Five').left - 1));
        host.select(1);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 1));
        final Rect after = _indicator(tester);
        expect(
          after.left,
          closeTo(mid.left, 6),
          reason: 'no jump at the retarget',
        );
        final List<Rect> frames = await _record(tester);
        for (var i = 1; i < frames.length; i++) {
          // Directly towards tab 1: never back to tab 0, never on to tab 4.
          expect(frames[i].left, lessThanOrEqualTo(frames[i - 1].left + 0.01));
          expect(
            frames[i].left,
            greaterThanOrEqualTo(_slot(tester, 'Two').left - 0.01),
          );
        }
        expect(frames.last.left, closeTo(_slot(tester, 'Two').left, 0.01));
      },
    );

    testWidgets('a rejected request leaves the indicator on the selection', (
      WidgetTester tester,
    ) async {
      final _HostState host = await _pump(
        tester,
        _Host(tabs: _five, accept: (int i) => false),
      );
      final Rect before = _indicator(tester);
      await tester.tap(find.text('Four'));
      await tester.pumpAndSettle();
      expect(host.selections, <int>[3]);
      expect(host.selected, 0);
      expect(_indicator(tester), before);
    });

    testWidgets(
      'a far jump reports once and never lights up the tabs between',
      (WidgetTester tester) async {
        final _HostState host = await _pump(
          tester,
          _Host(tabs: _five, pages: true, fit: MorphTabsIndicatorFit.tab),
        );
        final MorphColorScheme scheme = MorphTheme.of(
          tester.element(find.byType(MorphTabs)),
        ).colorScheme;
        await tester.tap(find.text('Five'));
        await tester.pump();
        for (var i = 0; i < 40; i++) {
          await tester.pump(const Duration(milliseconds: 16));
          for (final String label in <String>['Two', 'Three', 'Four']) {
            final Color? color = tester
                .widget<Text>(find.text(label))
                .style
                ?.color;
            expect(
              color,
              scheme.onSurfaceVariant,
              reason: '$label at frame $i',
            );
          }
          if (!tester.hasRunningAnimations) break;
        }
        await tester.pumpAndSettle();
        expect(host.selections, <int>[4]);
        expect(
          _indicator(tester).left,
          closeTo(_slot(tester, 'Five').left, 0.01),
        );
        expect(find.text('page 4'), findsOneWidget);
      },
    );
  });

  group('swipe following', () {
    Future<void> setUpPages(WidgetTester tester, {bool accept = true}) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(800, 600);
      addTearDown(tester.view.reset);
    }

    testWidgets('the indicator follows the real page progress frame by frame', (
      WidgetTester tester,
    ) async {
      await setUpPages(tester);
      final _HostState host = await _pump(
        tester,
        _Host(
          tabs: _tabs(<String>['One', 'Two', 'Three']),
          pages: true,
          fit: MorphTabsIndicatorFit.tab,
        ),
      );
      final double slot = _slot(tester, 'One').width;
      final TestGesture gesture = await tester.startGesture(
        tester.getCenter(find.byType(MorphTabsView)),
      );
      void expectSynced(String reason) {
        final double f = _pagePixels(tester) / 800;
        expect(
          _indicator(tester).left,
          closeTo(f * slot, 0.05),
          reason: reason,
        );
        expect(_indicator(tester).width, closeTo(slot, 0.05), reason: reason);
      }

      await gesture.moveBy(const Offset(-100, 0));
      await tester.pump();
      await tester.pump();
      expectSynced('quarter forward');
      expect(_pagePixels(tester), greaterThan(0));
      await gesture.moveBy(const Offset(-200, 0));
      await tester.pump();
      expectSynced('further forward');
      // Reversal retreats immediately, with the same progress.
      await gesture.moveBy(const Offset(220, 0));
      await tester.pump();
      expectSynced('reversed');
      // Stopped: neither moves.
      final Rect stopped = _indicator(tester);
      await tester.pump(const Duration(milliseconds: 200));
      expect(_indicator(tester), stopped);
      await gesture.moveBy(const Offset(-500, 0));
      await tester.pump();
      expectSynced('across the midpoint');
      // Nothing was confirmed per frame.
      expect(host.selections.length, lessThanOrEqualTo(1));
      await gesture.up();
      await tester.pumpAndSettle();
      expect(host.selected, 1);
      expect(host.selections, <int>[1]);
      expect(_indicator(tester).left, closeTo(_slot(tester, 'Two').left, 0.01));
    });

    testWidgets('a cancelled drag returns with the page', (
      WidgetTester tester,
    ) async {
      await setUpPages(tester);
      final _HostState host = await _pump(
        tester,
        _Host(
          tabs: _tabs(<String>['One', 'Two', 'Three']),
          pages: true,
          fit: MorphTabsIndicatorFit.tab,
        ),
      );
      final TestGesture gesture = await tester.startGesture(
        tester.getCenter(find.byType(MorphTabsView)),
      );
      await gesture.moveBy(const Offset(-160, 0));
      await tester.pump();
      await gesture.up();
      final double slot = _slot(tester, 'One').width;
      for (var i = 0; i < 40; i++) {
        await tester.pump(const Duration(milliseconds: 16));
        final double f = _pagePixels(tester) / 800;
        expect(_indicator(tester).left, closeTo(f * slot, 0.05));
        if (!tester.hasRunningAnimations) break;
      }
      await tester.pumpAndSettle();
      expect(host.selected, 0);
      expect(host.selections, isEmpty);
      expect(_indicator(tester).left, closeTo(_slot(tester, 'One').left, 0.01));
    });

    testWidgets('no feedback loop between bar, controller and pages', (
      WidgetTester tester,
    ) async {
      await setUpPages(tester);
      final _HostState host = await _pump(
        tester,
        _Host(tabs: _tabs(<String>['One', 'Two', 'Three']), pages: true),
      );
      var notifications = 0;
      host.controller.addListener(() => notifications++);
      await tester.fling(
        find.byType(MorphTabsView),
        const Offset(-600, 0),
        1500,
      );
      await tester.pumpAndSettle();
      expect(host.selections, <int>[1]);
      expect(notifications, lessThanOrEqualTo(2));
      expect(host.controller.position.value, isNull);
      expect(host.controller.isPageDriven, isFalse);
      // A tap afterwards animates the pages once, without a second callback.
      await tester.tap(find.text('Three'));
      await tester.pumpAndSettle();
      expect(host.selections, <int>[1, 2]);
    });

    testWidgets('a swipe interrupts a programmatic change without a jump', (
      WidgetTester tester,
    ) async {
      await setUpPages(tester);
      final _HostState host = await _pump(
        tester,
        _Host(
          tabs: _tabs(<String>['One', 'Two', 'Three', 'Four']),
          pages: true,
          fit: MorphTabsIndicatorFit.tab,
        ),
      );
      final double slot = _slot(tester, 'One').width;
      host.select(3);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 120));
      final Rect before = _indicator(tester);
      final TestGesture gesture = await tester.startGesture(
        tester.getCenter(find.byType(MorphTabsView)),
      );
      await gesture.moveBy(const Offset(40, 0));
      await tester.pump();
      final Rect after = _indicator(tester);
      expect((after.left - before.left).abs(), lessThan(slot * 0.5));
      final double f = _pagePixels(tester) / 800;
      expect(after.left, closeTo(f * slot, 0.05));
      await gesture.up();
      await tester.pumpAndSettle();
      expect(find.byKey(_indicatorKey), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('a parent that keeps another selection brings the page back', (
      WidgetTester tester,
    ) async {
      await setUpPages(tester);
      final _HostState host = await _pump(
        tester,
        _Host(
          tabs: _tabs(<String>['One', 'Two', 'Three']),
          pages: true,
          accept: (int i) => false,
          fit: MorphTabsIndicatorFit.tab,
        ),
      );
      await tester.drag(find.byType(MorphTabsView), const Offset(-700, 0));
      await tester.pumpAndSettle();
      expect(host.selected, 0);
      expect(find.text('page 0'), findsOneWidget);
      expect(_pagePixels(tester), closeTo(0, 0.5));
      expect(_indicator(tester).left, closeTo(_slot(tester, 'One').left, 0.01));
    });

    testWidgets('the bar works without a page view', (
      WidgetTester tester,
    ) async {
      final _HostState host = await _pump(
        tester,
        _Host(tabs: _five, shareController: false),
      );
      host.select(2);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 16));
      await tester.pump(const Duration(milliseconds: 100));
      final Rect mid = _indicator(tester);
      expect(mid.center.dx, greaterThan(_slot(tester, 'One').center.dx));
      await tester.pumpAndSettle();
      expect(
        _indicator(tester).center.dx,
        closeTo(_slot(tester, 'Three').center.dx, 0.5),
      );
    });
  });

  group('scrollable bar', () {
    final List<MorphTab> many = _tabs(<String>[
      for (var i = 0; i < 12; i++) 'Tab number $i',
    ]);

    testWidgets('the indicator shares the coordinates of the tabs', (
      WidgetTester tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(400, 600);
      addTearDown(tester.view.reset);
      await _pump(
        tester,
        _Host(tabs: many, scrollable: true, fit: MorphTabsIndicatorFit.tab),
      );
      var scrolled = false;
      for (final double dx in <double>[-60, -140, 90]) {
        await tester.drag(find.text('Tab number 1'), Offset(dx, 0));
        await tester.pumpAndSettle();
        final ScrollableState bar = tester.state<ScrollableState>(
          find.descendant(
            of: find.byType(MorphTabs),
            matching: find.byType(Scrollable),
          ),
        );
        expect(bar.position.pixels, greaterThanOrEqualTo(0));
        scrolled = scrolled || bar.position.pixels > 1;
        final Rect slot = _slot(tester, 'Tab number 0');
        expect(
          _indicator(tester).left,
          closeTo(slot.left, 0.01),
          reason: '$dx',
        );
        expect(_indicator(tester).width, closeTo(slot.width, 0.01));
      }
      expect(scrolled, isTrue, reason: 'the bar really scrolled');
    });

    testWidgets('selecting a distant tab reveals it and keeps alignment', (
      WidgetTester tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(400, 600);
      addTearDown(tester.view.reset);
      final _HostState host = await _pump(
        tester,
        _Host(tabs: many, scrollable: true, fit: MorphTabsIndicatorFit.tab),
      );
      host.select(11);
      await tester.pumpAndSettle();
      final Rect slot = _slot(tester, 'Tab number 11');
      final Rect bar = _barRect(tester);
      expect(slot.left, greaterThanOrEqualTo(bar.left - 0.5));
      expect(slot.right, lessThanOrEqualTo(bar.right + 0.5));
      expect(_indicator(tester).left, closeTo(slot.left, 0.01));
      expect(_indicator(tester).width, closeTo(slot.width, 0.01));
    });

    testWidgets('a manual scroll in progress is not fought', (
      WidgetTester tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(400, 600);
      addTearDown(tester.view.reset);
      final _HostState host = await _pump(
        tester,
        _Host(tabs: many, scrollable: true, fit: MorphTabsIndicatorFit.tab),
      );
      final TestGesture gesture = await tester.startGesture(
        tester.getCenter(find.text('Tab number 1')),
      );
      await gesture.moveBy(const Offset(-30, 0)); // past the touch slop
      await gesture.moveBy(const Offset(-80, 0));
      await tester.pump();
      final ScrollableState scroll = tester.state<ScrollableState>(
        find.descendant(
          of: find.byType(MorphTabs),
          matching: find.byType(Scrollable),
        ),
      );
      final double held = scroll.position.pixels;
      expect(held, greaterThan(0));
      host.select(11);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      expect(scroll.position.pixels, closeTo(held, 0.01));
      await gesture.up();
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });

  group('changes to content and to the list', () {
    testWidgets('a longer label updates the destination', (
      WidgetTester tester,
    ) async {
      final _HostState host = await _pump(
        tester,
        _Host(tabs: _tabs(<String>['Alpha', 'Beta', 'Gamma'])),
      );
      final double before = _indicator(tester).width;
      host.setTabs(
        _tabs(<String>['Alpha with a much longer label', 'Beta', 'Gamma']),
      );
      await tester.pumpAndSettle();
      final Rect text = tester.getRect(
        find.text('Alpha with a much longer label'),
      );
      expect(_indicator(tester).width, greaterThan(before));
      expect(_indicator(tester).width, closeTo(text.width - 4, 0.01));
    });

    testWidgets('a badge on the selected tab widens the measured content', (
      WidgetTester tester,
    ) async {
      final _HostState host = await _pump(
        tester,
        _Host(
          tabs: const <MorphTab>[
            MorphTab(label: 'Alpha'),
            MorphTab(label: 'Beta'),
          ],
          style: MorphTabsIndicatorStyle.surface,
          fit: MorphTabsIndicatorFit.content,
          alignment: MorphTabsAlignment.content,
        ),
      );
      final double before = _indicator(tester).width;
      host.setTabs(const <MorphTab>[
        MorphTab(label: 'Alpha', badgeCount: 12),
        MorphTab(label: 'Beta'),
      ]);
      await tester.pumpAndSettle();
      expect(_indicator(tester).width, greaterThan(before + 20));
    });

    testWidgets('adding and removing tabs keeps a valid state', (
      WidgetTester tester,
    ) async {
      final _HostState host = await _pump(
        tester,
        _Host(
          tabs: _tabs(<String>['A', 'B', 'C']),
          initial: 2,
          fit: MorphTabsIndicatorFit.tab,
        ),
      );
      host.setTabs(_tabs(<String>['A', 'B', 'C', 'D', 'E']));
      await tester.pumpAndSettle();
      expect(_indicator(tester).left, closeTo(_slot(tester, 'C').left, 0.5));
      host.setTabs(_tabs(<String>['A', 'B']), index: 2);
      await tester.pumpAndSettle();
      // Out of range: displayed clamped, reported once so the parent can fix it.
      expect(_indicator(tester).left, closeTo(_slot(tester, 'B').left, 0.5));
      expect(host.selections, <int>[1]);
      expect(host.selected, 1);
      expect(tester.takeException(), isNull);
    });

    testWidgets('stable ids keep the selection on the same tab', (
      WidgetTester tester,
    ) async {
      MorphTab t(String id) => MorphTab(label: id, id: id);
      final _HostState host = await _pump(
        tester,
        _Host(
          tabs: <MorphTab>[t('a'), t('b'), t('c')],
          initial: 2,
          fit: MorphTabsIndicatorFit.tab,
        ),
      );
      // A tab is inserted before the selected one; the parent keeps index 2.
      host.setTabs(<MorphTab>[t('x'), t('a'), t('b'), t('c')]);
      await tester.pumpAndSettle();
      expect(host.selections, <int>[3]);
      expect(host.selected, 3);
      expect(_indicator(tester).left, closeTo(_slot(tester, 'c').left, 0.5));
      // The selected tab disappears: the selection stays valid, no callback.
      host.setTabs(<MorphTab>[t('x'), t('a'), t('b')]);
      await tester.pumpAndSettle();
      expect(host.selected, 2);
      expect(_indicator(tester).left, closeTo(_slot(tester, 'b').left, 0.5));
    });

    testWidgets('disposing mid-transition leaves nothing behind', (
      WidgetTester tester,
    ) async {
      final MorphTabsController controller = MorphTabsController();
      addTearDown(controller.dispose);
      final _HostState host = await _pump(
        tester,
        _Host(tabs: _five, pages: true, externalController: controller),
      );
      host.select(4);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 80));
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      // A stale listener would try to rebuild a disposed bar here.
      expect(
        () => controller.reportPosition(const MorphTabsPosition(1)),
        returnsNormally,
      );
      await tester.pump();
      expect(tester.takeException(), isNull);
    });
  });

  group('accessibility and input', () {
    testWidgets('RTL: first tab on the right, indicator on it, keys mirrored', (
      WidgetTester tester,
    ) async {
      final _HostState host = await _pump(
        tester,
        _Host(
          tabs: _tabs(<String>['One', 'Two', 'Three']),
          rtl: true,
          fit: MorphTabsIndicatorFit.tab,
        ),
      );
      expect(_slot(tester, 'One').left, greaterThan(_slot(tester, 'Two').left));
      expect(_indicator(tester).left, closeTo(_slot(tester, 'One').left, 0.01));
      host.select(2);
      await tester.pumpAndSettle();
      expect(
        _indicator(tester).left,
        closeTo(_slot(tester, 'Three').left, 0.01),
      );
      host.select(0);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      final Rect resting = _indicator(tester);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pump();
      expect(FocusManager.instance.primaryFocus?.debugLabel, 'tab 1');
      // Moving focus neither selects nor moves the indicator.
      expect(host.selections, isEmpty);
      expect(_indicator(tester), resting);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(host.selections, <int>[1]);
    });

    testWidgets('semantics: tab role, selected state, controlled panel', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      final _HostState host = await _pump(
        tester,
        _Host(tabs: _tabs(<String>['Alpha', 'Beta']), pages: true),
      );
      SemanticsNode node(String label) => tester.getSemantics(
        find.ancestor(
          of: find.text(label),
          matching: find.byType(MorphTappable),
        ),
      );
      expect(node('Alpha').role, SemanticsRole.tab);
      expect(node('Alpha').flagsCollection.isSelected, Tristate.isTrue);
      expect(node('Beta').flagsCollection.isSelected, isNot(Tristate.isTrue));
      expect(
        node('Alpha').controlsNodes,
        contains(host.controller.panelIdentifier(0)),
      );
      host.select(1);
      await tester.pumpAndSettle();
      expect(node('Beta').flagsCollection.isSelected, Tristate.isTrue);
      expect(tester.takeException(), isNull);
      handle.dispose();
    });

    testWidgets('reduced motion: no travel, no elasticity, callbacks intact', (
      WidgetTester tester,
    ) async {
      final _HostState host = await _pump(
        tester,
        _Host(
          tabs: _five,
          pages: true,
          reduced: true,
          motion: MorphTabsIndicatorMotion.elastic,
          fit: MorphTabsIndicatorFit.tab,
        ),
      );
      await tester.tap(find.text('Four'));
      await tester.pump();
      await tester.pump();
      expect(host.selections, <int>[3]);
      expect(
        _indicator(tester).left,
        closeTo(_slot(tester, 'Four').left, 0.01),
      );
      expect(find.text('page 3'), findsOneWidget);
      expect(tester.hasRunningAnimations, isFalse);
    });
  });

  group('renderer', () {
    testWidgets('shader request falls back to Canvas with the same geometry', (
      WidgetTester tester,
    ) async {
      final List<MorphShapeRenderStatus> statuses = <MorphShapeRenderStatus>[];
      final _HostState host = await _pump(
        tester,
        _Host(
          tabs: _five,
          style: MorphTabsIndicatorStyle.surface,
          fit: MorphTabsIndicatorFit.tab,
          renderer: MorphShapeRenderer.shader,
          onRenderer: statuses.add,
        ),
      );
      expect(statuses, isNotEmpty);
      final Rect rest = _indicator(tester);
      expect(rest.left, closeTo(_slot(tester, 'One').left + 4, 0.01));
      host.select(3);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 16));
      await tester.pump(const Duration(milliseconds: 100));
      // The transition keeps going while the renderer settles.
      expect(_indicator(tester).left, greaterThan(rest.left));
      await tester.pumpAndSettle();
      expect(
        _indicator(tester).left,
        closeTo(_slot(tester, 'Four').left + 4, 0.01),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('asymmetric underline radii always use Canvas', (
      WidgetTester tester,
    ) async {
      final List<MorphShapeRenderStatus> statuses = <MorphShapeRenderStatus>[];
      await _pump(
        tester,
        _Host(
          tabs: _five,
          tabTheme: const MorphTabTheme(indicatorRoundedEnds: false),
          renderer: MorphShapeRenderer.auto,
          onRenderer: statuses.add,
        ),
      );
      expect(statuses.last.effective, MorphShapeRenderer.canvas);
      expect(statuses.last.reason, contains('asymmetric'));
    });

    testWidgets('rounded ends use uniform radii; style changes keep going', (
      WidgetTester tester,
    ) async {
      final List<MorphShapeRenderStatus> statuses = <MorphShapeRenderStatus>[];
      await _pump(
        tester,
        _Host(
          tabs: _five,
          tabTheme: const MorphTabTheme(indicatorRoundedEnds: true),
          renderer: MorphShapeRenderer.auto,
          onRenderer: statuses.add,
        ),
      );
      expect(statuses, isNotEmpty);
      expect(statuses.last.reason ?? '', isNot(contains('asymmetric')));
      await _pump(
        tester,
        _Host(
          tabs: _five,
          style: MorphTabsIndicatorStyle.surface,
          tabTheme: const MorphTabTheme(indicatorRoundedEnds: true),
          renderer: MorphShapeRenderer.canvas,
          onRenderer: statuses.add,
        ),
      );
      expect(tester.takeException(), isNull);
    });
  });

  group('theme and API', () {
    test('resolution precedence: widget, tab theme, defaults', () {
      const MorphTabTheme theme = MorphTabTheme(
        indicatorStyle: MorphTabsIndicatorStyle.surface,
        indicatorMotion: MorphTabsIndicatorMotion.elastic,
        indicatorFit: MorphTabsIndicatorFit.tab,
        indicatorPadding: 20,
        indicatorDuration: Duration(milliseconds: 500),
      );
      final MorphColorScheme scheme = MorphThemeData.light().colorScheme;
      final MorphTabIndicatorSpec inherited = theme.resolveIndicator(
        scheme,
        MorphTabsVariant.primary,
      );
      expect(inherited.style, MorphTabsIndicatorStyle.surface);
      expect(inherited.motion, MorphTabsIndicatorMotion.elastic);
      expect(inherited.fit, MorphTabsIndicatorFit.tab);
      expect(inherited.padding, 20);
      expect(inherited.duration, const Duration(milliseconds: 500));
      final MorphTabIndicatorSpec widget = theme.resolveIndicator(
        scheme,
        MorphTabsVariant.primary,
        style: MorphTabsIndicatorStyle.underline,
        motion: MorphTabsIndicatorMotion.slide,
        fit: MorphTabsIndicatorFit.content,
        duration: const Duration(milliseconds: 120),
      );
      expect(widget.style, MorphTabsIndicatorStyle.underline);
      expect(widget.motion, MorphTabsIndicatorMotion.slide);
      expect(widget.fit, MorphTabsIndicatorFit.content);
      expect(widget.duration, const Duration(milliseconds: 120));
      final MorphTabIndicatorSpec defaults = MorphTabTheme.defaults
          .resolveIndicator(scheme, MorphTabsVariant.secondary);
      expect(defaults.style, MorphTabsIndicatorStyle.underline);
      expect(defaults.motion, MorphTabsIndicatorMotion.slide);
      expect(defaults.fit, MorphTabsIndicatorFit.tab);
    });

    test('copyWith, equality and lerp carry the new fields', () {
      const MorphTabTheme a = MorphTabTheme();
      final MorphTabTheme b = a.copyWith(
        indicatorStyle: MorphTabsIndicatorStyle.surface,
        indicatorMotion: MorphTabsIndicatorMotion.elastic,
        indicatorFit: MorphTabsIndicatorFit.content,
        indicatorElasticity: 0.5,
        indicatorDuration: const Duration(milliseconds: 600),
        indicatorRoundedEnds: true,
        indicatorBottomCornerRadius: 2,
        secondaryIndicatorCornerRadius: 1,
        indicatorTabInset: 6,
        indicatorPadding: 18,
        indicatorSurfaceInset: 5,
        indicatorVerticalPadding: 9,
        indicatorGroupRadius: 20,
        indicatorSurfaceRadius: 10,
        indicatorColorOverride: const Color(0xFF112233),
        indicatorGroupBackground: true,
        indicatorGroupColor: const Color(0xFF223344),
        indicatorRenderer: MorphShapeRenderer.canvas,
      );
      expect(a, const MorphTabTheme());
      expect(a.hashCode, const MorphTabTheme().hashCode);
      expect(b, isNot(a));
      expect(b, b.copyWith());
      expect(b.indicatorStyle, MorphTabsIndicatorStyle.surface);
      expect(b.indicatorPadding, 18);
      final MorphTabTheme mid = a.lerp(b, 0.5);
      expect(mid.indicatorElasticity, closeTo(0.4, 1e-9));
      expect(mid.indicatorDuration, const Duration(milliseconds: 450));
      // An unset (default) value switches at the midpoint.
      expect(mid.indicatorPadding, 18);
      final MorphTabTheme end = a.lerp(b, 1);
      expect(end.indicatorStyle, b.indicatorStyle);
      expect(end.indicatorColorOverride, b.indicatorColorOverride);
      expect(end.indicatorElasticity, closeTo(b.indicatorElasticity, 1e-9));
      expect(a.lerp(b, 0), a);
    });
  });
}
