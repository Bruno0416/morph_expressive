// Diagnostic harness (`--dart-define=MORPH_NATIVE_CHECK=visual|perf`).
//
// `visual` drives real pointer events through the gesture binding and prints
// `MARK <name>` lines; an external script takes a screenshot at each mark.
// `perf` runs the same animated scenario with MorphSmoothEdges disabled and
// enabled (alternating) and prints FrameTiming summaries and RSS.
import 'dart:async';
import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:material_ui/material_ui.dart' show Scaffold, Icon, Text;
import 'package:morph_expressive/morph_expressive.dart';

void _out(String s) => stdout.writeln(s);

class NativeCheckApp extends StatefulWidget {
  const NativeCheckApp({super.key, required this.mode});
  final String mode;
  @override
  State<NativeCheckApp> createState() => _NativeCheckAppState();
}

class _NativeCheckAppState extends State<NativeCheckApp> {
  String _scene = 'boot';
  final _btn = GlobalKey(), _anchor = GlobalKey(), _listKey = GlobalKey();
  final _fab = MorphFabMenuController();
  final _scroll = ScrollController();
  double _turns = 0;
  Timer? _spin;
  MorphShapeRenderer _renderer = MorphShapeRenderer.auto;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future<void>.delayed(const Duration(seconds: 2));
      if (widget.mode == 'edges') {
        await _edges();
      } else if (widget.mode == 'perf') {
        await _perf();
      } else {
        await _visual();
      }
      _out('DONE');
      await Future<void>.delayed(const Duration(milliseconds: 500));
      exit(0);
    });
  }

  // ───────── helpers ─────────
  Future<void> _wait(int ms) =>
      Future<void>.delayed(Duration(milliseconds: ms));
  Future<void> _mark(String name, {int hold = 1400}) async {
    _out('MARK $name');
    await _wait(hold);
  }

  Future<void> _scene_(String s) async {
    setState(() => _scene = s);
    await _wait(700);
  }

  void _ev(PointerEvent e) => GestureBinding.instance.handlePointerEvent(e);
  Offset _center(GlobalKey k) {
    final rb = k.currentContext!.findRenderObject()! as RenderBox;
    return rb.localToGlobal(rb.size.center(Offset.zero));
  }

  // ───────── visual ─────────
  Future<void> _edges() async {
    for (final renderer in [
      MorphShapeRenderer.canvas,
      MorphShapeRenderer.shader,
    ]) {
      setState(() => _renderer = renderer);
      await _scene_('fab');
      await _mark('${renderer.name}_closed', hold: 300);
      // Hold a real splash while the controller morphs its enclosing surface.
      final surface = _center(_anchor);
      _ev(PointerDownEvent(pointer: 21, position: surface));
      await _wait(160);
      timeDilation = 6;
      _fab.open();
      await _wait(350);
      await _mark('${renderer.name}_opening_ink', hold: 100);
      _fab.close();
      await _wait(250);
      await _mark('${renderer.name}_reverse_ink', hold: 100);
      _fab.open();
      await _wait(3500);
      await _mark('${renderer.name}_open_ink', hold: 100);
      _fab.close();
      await _wait(450);
      await _mark('${renderer.name}_closing_ink', hold: 100);
      _ev(PointerCancelEvent(pointer: 21, position: surface));
      await _wait(3500);
      timeDilation = 1;
    }
    await _scene_('components');
    await _mark('progress_static_and_animated');
    await _mark('progress_next_frame');
  }

  Future<void> _visual() async {
    // 1. Splash: press, release, cancel (touch).
    await _scene_('buttons');
    final c = _center(_btn);
    _ev(const PointerAddedEvent(pointer: 1, position: Offset.zero));
    _ev(PointerDownEvent(pointer: 1, position: c));
    await _wait(60);
    await _mark('splash_press_early', hold: 100);
    await _wait(250);
    await _mark('splash_press_held');
    _ev(PointerUpEvent(pointer: 1, position: c));
    await _wait(70);
    await _mark('splash_release_early', hold: 100);
    await _wait(500);
    _ev(PointerDownEvent(pointer: 2, position: c));
    await _wait(250);
    _ev(
      PointerMoveEvent(
        pointer: 2,
        position: c + const Offset(0, 300),
        delta: const Offset(0, 300),
      ),
    );
    _ev(PointerCancelEvent(pointer: 2, position: c + const Offset(0, 300)));
    await _wait(80);
    await _mark('splash_cancel_early', hold: 100);
    await _wait(600);
    await _mark('splash_cancel_done');

    // 2. Menus: hover, cross to submenu, leave.
    await _scene_('menus');
    final a = _center(_anchor);
    final ctx = _anchor.currentContext!;
    if (!ctx.mounted) return;
    final box = ctx.findRenderObject()! as RenderBox;
    final anchorRect = box.localToGlobal(Offset.zero) & box.size;
    // ignore: unawaited_futures
    showMorphMenu<String>(
      context: ctx,
      anchor: anchorRect,
      children: const <MorphMenuNode>[
        MorphMenuEntry(label: 'First', value: 'first'),
        MorphMenuSubmenu(
          label: 'More',
          children: <MorphMenuNode>[
            MorphMenuEntry(label: 'Sub one', value: 's1'),
            MorphMenuEntry(label: 'Sub two', value: 's2'),
          ],
        ),
        MorphMenuEntry(label: 'Last', value: 'last'),
      ],
    );
    await _wait(900);
    await _mark('menu_open');
    // Find the "More" row by walking render objects for its paragraph.
    Offset? more;
    void walk(RenderObject r) {
      if (r is RenderParagraph && r.text.toPlainText() == 'More') {
        more = r.localToGlobal(r.size.center(Offset.zero));
      }
      r.visitChildren(walk);
    }

    RendererBinding.instance.renderViews.first.visitChildren(walk);
    final mouse = more ?? a;
    _ev(
      const PointerAddedEvent(
        pointer: 9,
        device: 9,
        kind: PointerDeviceKind.mouse,
        position: Offset(5, 5),
      ),
    );
    _ev(
      PointerHoverEvent(
        device: 9,
        kind: PointerDeviceKind.mouse,
        position: mouse,
      ),
    );
    await _wait(120);
    await _mark('submenu_before_delay', hold: 100);
    await _wait(350);
    await _mark('submenu_open');
    // Move across to the submenu in small steps (crossing the gap).
    for (var i = 1; i <= 8; i++) {
      _ev(
        PointerHoverEvent(
          device: 9,
          kind: PointerDeviceKind.mouse,
          position: mouse + Offset(i * 28.0, 4),
        ),
      );
      await _wait(20);
    }
    await _wait(500);
    await _mark('submenu_after_cross');
    _ev(
      PointerHoverEvent(
        device: 9,
        kind: PointerDeviceKind.mouse,
        position: const Offset(5, 5),
      ),
    );
    await _wait(100);
    await _mark('submenu_grace', hold: 100);
    await _wait(500);
    await _mark('submenu_closed');
    // Close the menu (Escape).
    await _wait(200);

    // 3. FAB: open, interrupt, close (x4 slow motion).
    await _scene_('fab');
    timeDilation = 4;
    _fab.open();
    await _wait(350);
    await _mark('fab_open_early', hold: 200);
    await _wait(600);
    await _mark('fab_open_mid', hold: 200);
    _fab.close(); // interrupt mid-flight
    await _wait(450);
    await _mark('fab_interrupt_close_mid', hold: 200);
    _fab.open();
    await _wait(500);
    await _mark('fab_reopen_mid', hold: 200);
    await _wait(4500);
    await _mark('fab_open_settled');
    _fab.close();
    for (var i = 1; i <= 5; i++) {
      await _wait(i == 1 ? 120 : 160);
      await _mark('fab_close_$i', hold: 60);
    }
    await _wait(4000);
    await _mark('fab_closed');
    timeDilation = 1;

    // 4. Sliders / progress / swipe.
    await _scene_('components');
    final lc = _center(_listKey);
    _ev(PointerDownEvent(pointer: 3, position: lc));
    for (var i = 1; i <= 12; i++) {
      _ev(
        PointerMoveEvent(
          pointer: 3,
          position: lc - Offset(i * 12.0, 0),
          delta: const Offset(-12, 0),
        ),
      );
      await _wait(16);
    }
    _ev(PointerUpEvent(pointer: 3, position: lc - const Offset(144, 0)));
    await _wait(900);
    await _mark('components_swipe_open');

    // 5. Shapes: 0°, 360°, repeated turns.
    await _scene_('shapes');
    await _mark('shapes_static');
    _spin = Timer.periodic(const Duration(milliseconds: 16), (_) {
      setState(() => _turns += 0.016 / 1.0);
    });
    await _wait(4200); // 4+ turns
    await _mark('shapes_after_turns', hold: 100);
    _spin?.cancel();
    setState(() => _turns = 0);
    await _wait(300);
    await _mark('shapes_reset');
  }

  // ───────── perf ─────────
  final List<FrameTiming> _timings = [];

  Future<void> _perf() async {
    SchedulerBinding.instance.addTimingsCallback((t) => _timings.addAll(t));
    await _scene_('perf');
    _fabLoop();
    _scrollLoop();
    for (final mode in [
      MorphSmoothEdgesMode.disabled,
      MorphSmoothEdgesMode.enabled,
      MorphSmoothEdgesMode.disabled,
      MorphSmoothEdgesMode.enabled,
    ]) {
      MorphSmoothEdges.defaultMode = mode;
      setState(() {});
      await _wait(1500);
      _timings.clear();
      final rss0 = _rss();
      await _wait(8000);
      _report(mode.name, rss0);
    }
  }

  final bool _loop = true;
  Future<void> _fabLoop() async {
    while (_loop) {
      await _wait(1800);
      _fab.toggle();
    }
  }

  Future<void> _scrollLoop() async {
    while (_loop) {
      if (_scroll.hasClients) {
        await _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(seconds: 4),
          curve: Curves.linear,
        );
        await _scroll.animateTo(
          0,
          duration: const Duration(seconds: 4),
          curve: Curves.linear,
        );
      } else {
        await _wait(100);
      }
    }
  }

  int _rss() {
    try {
      final s = File('/proc/self/status').readAsStringSync();
      final m = RegExp(r'VmRSS:\s+(\d+) kB').firstMatch(s);
      return int.parse(m!.group(1)!);
    } catch (_) {
      return -1;
    }
  }

  void _report(String mode, int rss0) {
    List<double> col(Duration Function(FrameTiming) f) =>
        _timings.map((t) => f(t).inMicroseconds / 1000).toList()..sort();
    String stats(List<double> v) {
      if (v.isEmpty) return 'n/a';
      double p(double q) => v[((v.length - 1) * q).round()];
      final avg = v.reduce((a, b) => a + b) / v.length;
      return 'avg ${avg.toStringAsFixed(2)} p50 ${p(.5).toStringAsFixed(2)} '
          'p90 ${p(.9).toStringAsFixed(2)} p99 ${p(.99).toStringAsFixed(2)} '
          'max ${v.last.toStringAsFixed(2)}';
    }

    final total = col((t) => t.totalSpan);
    final jank = total.where((v) => v > 16.7).length;
    _out('PERF mode=$mode frames=${_timings.length} jank>16.7ms=$jank');
    _out('PERF   build  ms: ${stats(col((t) => t.buildDuration))}');
    _out('PERF   raster ms: ${stats(col((t) => t.rasterDuration))}');
    _out('PERF   total  ms: ${stats(total)}');
    _out('PERF   rssKB start=$rss0 end=${_rss()}');
  }

  // ───────── scenes ─────────
  @override
  Widget build(BuildContext context) {
    return MorphMaterialApp(
      data: MorphThemeData.light(),
      home: Scaffold(body: _sceneWidget()),
    );
  }

  Widget _sceneWidget() {
    switch (_scene) {
      case 'buttons':
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              MorphButton(
                key: _btn,
                onPressed: () {},
                child: const Text('Press me'),
              ),
              const SizedBox(height: 16),
              MorphButton.tonal(onPressed: () {}, child: const Text('Tonal')),
            ],
          ),
        );
      case 'menus':
        return Align(
          alignment: Alignment.topLeft,
          child: Padding(
            padding: const EdgeInsets.all(40),
            child: MorphButton.tonal(
              key: _anchor,
              onPressed: () {},
              child: const Text('Anchor'),
            ),
          ),
        );
      case 'fab':
        return Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: MorphFabMenu(
              key: _anchor,
              controller: _fab,
              renderer: _renderer,
              onRendererChanged: (r) => _out('RENDERER ${r.effective.name}'),
              items: <MorphFabMenuItem>[
                MorphFabMenuItem(
                  icon: Icon(FluentIcons.line.heart),
                  label: 'Favorite',
                ),
                MorphFabMenuItem(
                  icon: Icon(FluentIcons.line.play),
                  label: 'Play',
                ),
                MorphFabMenuItem(
                  icon: Icon(FluentIcons.line.pause),
                  label: 'Pause',
                ),
              ],
            ),
          ),
        );
      case 'components':
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              SizedBox(
                width: 360,
                child: MorphSlider.wavy(value: .45, onChanged: (_) {}),
              ),
              SizedBox(
                width: 360,
                child: MorphSlider(value: .45, onChanged: (_) {}),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  MorphProgressIndicator.circular(value: .62, size: 56),
                  SizedBox(width: 16),
                  MorphProgressIndicator.circularWavy(value: .55, size: 56),
                  SizedBox(width: 16),
                  MorphProgressIndicator.circular(size: 56),
                  SizedBox(width: 16),
                  MorphProgressIndicator.circularWavy(size: 56),
                ],
              ),
              const SizedBox(
                width: 360,
                child: MorphProgressIndicator.linear(value: .62),
              ),
              const SizedBox(
                width: 360,
                child: MorphProgressIndicator.linearWavy(value: .55),
              ),
              const SizedBox(height: 16),
              SizedBox(
                key: _listKey,
                width: 420,
                height: 96,
                child: MorphList(
                  itemCount: 1,
                  itemBuilder: (c, i) => MorphListItem(
                    headline: 'Swipe me',
                    swipe: MorphListItemSwipe(
                      onDismiss: (d) async => false,
                      trailing: <MorphListSwipeAction>[
                        MorphListSwipeAction(
                          icon: Icon(FluentIcons.line.heart),
                          width: 56,
                        ),
                        MorphListSwipeAction(
                          icon: Icon(FluentIcons.line.pause),
                          width: 56,
                          isPrimary: true,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      case 'shapes':
        final ellipse = MorphShape.ellipse(width: 1, height: .64);
        final shapeTurns = _turns;
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Wrap(
            spacing: 24,
            runSpacing: 24,
            children: [
              for (final turns in [0.0, 1.0, 2.0, shapeTurns])
                MorphShapeView(
                  shape: ellipse,
                  size: const Size(120, 120),
                  rotationRadians: turns * 6.283185307179586,
                  renderer: MorphShapeRenderer.shader,
                  color: const Color(0xff6750a4),
                ),
              for (final turns in [0.0, 1.0, shapeTurns])
                MorphShapeView(
                  shape: MorphShapeCatalog.fromKind(MorphShapeKind.clover4Leaf),
                  size: const Size(120, 120),
                  rotationRadians: turns * 6.283185307179586,
                  color: const Color(0xff6750a4),
                ),
              MorphShapeButton(
                size: 96,
                shape: MorphShapeCatalog.cookie7Sided,
                rotationEnabled: true,
                rotationDuration: const Duration(seconds: 1),
                onPressed: () {},
                child: Icon(FluentIcons.line.heart),
              ),
            ],
          ),
        );
      case 'perf':
        return _perfScene();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _perfScene() {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    for (var i = 0; i < 3; i++) ...[
                      const MorphProgressIndicator.circular(size: 48),
                      const MorphProgressIndicator.circularWavy(size: 48),
                    ],
                  ],
                ),
                for (var i = 0; i < 3; i++)
                  const SizedBox(
                    width: 360,
                    child: MorphProgressIndicator.linearWavy(),
                  ),
                for (var i = 0; i < 3; i++)
                  SizedBox(
                    width: 360,
                    child: MorphSlider.wavy(
                      value: .3 + i * .2,
                      onChanged: (_) {},
                    ),
                  ),
                Wrap(
                  spacing: 12,
                  children: [
                    for (var i = 0; i < 4; i++)
                      MorphShapeButton(
                        size: 64,
                        shape: MorphShapeCatalog.cookie7Sided,
                        rotationEnabled: true,
                        rotationDuration: const Duration(seconds: 3),
                        onPressed: () {},
                        child: Icon(FluentIcons.line.heart),
                      ),
                    const MorphLoadingIndicator(
                      variant: MorphLoadingIndicatorVariant.contained,
                    ),
                    const MorphLoadingIndicator(),
                  ],
                ),
                const Spacer(),
                Align(
                  alignment: Alignment.bottomLeft,
                  child: MorphFabMenu(
                    controller: _fab,
                    items: <MorphFabMenuItem>[
                      MorphFabMenuItem(
                        icon: Icon(FluentIcons.line.heart),
                        label: 'Favorite',
                      ),
                      MorphFabMenuItem(
                        icon: Icon(FluentIcons.line.play),
                        label: 'Play',
                      ),
                    ],
                    position: MorphFabMenuPosition.left,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(
          width: 420,
          child: ListView.builder(
            controller: _scroll,
            itemCount: 80,
            itemBuilder: (c, i) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Row(
                children: [
                  MorphButton.tonal(onPressed: () {}, child: Text('Item $i')),
                  const SizedBox(width: 12),
                  Expanded(
                    child: MorphProgressIndicator.linearWavy(
                      value: (i % 10) / 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
