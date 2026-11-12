import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:material_ui/material_ui.dart' show Scaffold, AppBar, IconButton;
import 'package:morph_expressive/morph_expressive.dart';

import 'operation_lab_extras.dart';

/// Consumer-owned simulations; no operation scheduling lives in the library.
class OperationLoadingLab extends StatefulWidget {
  const OperationLoadingLab({super.key, this.onToggleTheme});
  final VoidCallback? onToggleTheme;
  @override
  State<OperationLoadingLab> createState() => _OperationLoadingLabState();
}

class _OperationLoadingLabState extends State<OperationLoadingLab> {
  final skeletonSection = GlobalKey();
  final asyncSection = GlobalKey(), groupsSection = GlobalKey();
  @override
  void initState() {
    super.initState();
    // Opt-in native review helper: scroll to a section on start.
    final jump =
        const String.fromEnvironment('MORPH_OPERATION_SECTION').isNotEmpty
        ? const String.fromEnvironment('MORPH_OPERATION_SECTION')
        : (Uri.base.queryParameters['section'] ?? '');
    if (jump.isNotEmpty) {
      later(900, () {
        final key = switch (jump) {
          'async' => asyncSection,
          'groups' => groupsSection,
          _ => skeletonSection,
        };
        Scrollable.ensureVisible(key.currentContext!, duration: Duration.zero);
      });
    }
    // Opt-in deterministic native review; never enabled by normal lab entry.
    if (const bool.fromEnvironment('MORPH_OPERATION_REVIEW')) {
      later(1200, () => state = MorphOperationState.loading);
      later(2200, () => debugPrint('OPERATION_MARK loading'));
      later(3200, () => state = MorphOperationState.error);
      later(4000, () => debugPrint('OPERATION_MARK error'));
      later(4800, () {
        Scrollable.ensureVisible(
          skeletonSection.currentContext!,
          duration: Duration.zero,
        );
      });
      later(6000, () => debugPrint('OPERATION_MARK skeleton'));
      later(6800, () {
        reduced = true;
        rtl = true;
        largeText = true;
        mobile = true;
      });
      later(8000, () => debugPrint('OPERATION_MARK reduced_rtl_mobile'));
      later(9000, () => debugPrint('OPERATION_DONE'));
    }
  }

  MorphOperationState state = MorphOperationState.idle;
  MorphOperationPresentation presentation =
      MorphOperationPresentation.preserveWidth;
  MorphSkeletonEffect effect = MorphSkeletonEffect.shimmer;
  MorphShimmerDirection direction = MorphShimmerDirection.leftToRight;
  MorphShapeRenderer renderer = MorphShapeRenderer.auto;
  MorphShapeRenderer buttonEffective = MorphShapeRenderer.canvas,
      skeletonEffective = MorphShapeRenderer.canvas;
  bool loading = true,
      reduced = false,
      rtl = false,
      largeText = false,
      mobile = false,
      label = true;
  double seconds = 1.6, intensity = .35, angle = 0;
  int generation = 0;
  final List<Timer> timers = [];
  void cancel() {
    generation++;
    for (final timer in timers) {
      timer.cancel();
    }
    timers.clear();
  }

  void later(int ms, VoidCallback action) {
    final token = generation;
    timers.add(
      Timer(Duration(milliseconds: ms), () {
        if (mounted && token == generation) setState(action);
      }),
    );
  }

  void simulate(MorphOperationState result, {bool instant = false}) {
    cancel();
    setState(() => state = MorphOperationState.loading);
    if (instant) {
      setState(() => state = result);
    } else {
      later(1200, () => state = result);
    }
  }

  void rapid() {
    cancel();
    setState(() => state = MorphOperationState.loading);
    later(75, () => state = MorphOperationState.success);
    later(130, () => state = MorphOperationState.error);
    later(200, () => state = MorphOperationState.loading);
    later(330, () => state = MorphOperationState.idle);
  }

  @override
  void dispose() {
    cancel();
    super.dispose();
  }

  Widget choice(String text, VoidCallback action) =>
      MorphButton.tonal(onPressed: action, child: Text(text));
  Widget choices(Iterable<Widget> widgets) =>
      Wrap(spacing: 8, runSpacing: 8, children: widgets.toList());
  Widget section(String title, List<Widget> children) => Padding(
    key: switch (title) {
      'Coordinated skeleton / shimmer' => skeletonSection,
      'AsyncButton polish' => asyncSection,
      'Reactive button groups' => groupsSection,
      _ => null,
    },
    padding: const EdgeInsets.symmetric(vertical: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: MorphTheme.of(context).typeScale.titleLarge),
        const SizedBox(height: 16),
        ...children,
      ],
    ),
  );
  void reportButton(MorphShapeRenderStatus r) {
    if (buttonEffective != r.effective) {
      setState(() => buttonEffective = r.effective);
    }
  }

  void reportSkeleton(MorphShapeRenderStatus r) {
    if (skeletonEffective != r.effective) {
      setState(() => skeletonEffective = r.effective);
    }
  }

  Widget operation(
    MorphButtonStyle style,
    MorphOperationPresentation mode, {
    MorphButtonSize size = MorphButtonSize.sm,
    bool enabled = true,
    String text = 'Save changes',
  }) => MorphAsyncButton(
    label: text,
    state: state,
    presentation: mode,
    style: style,
    size: size,
    enabled: enabled,
    showLoadingLabel: label,
    renderer: renderer,
    onRendererChanged: reportButton,
    icon: const Text('↑'),
    labels: const {
      MorphOperationState.success: 'Saved',
      MorphOperationState.error: 'Retry',
    },
    tooltip: 'Consumer-controlled ${style.name}',
    onPressed: () => simulate(MorphOperationState.success),
  );
  Widget profile({bool skeleton = true}) => SizedBox(
    height: 80,
    child: Row(
      children: [
        if (skeleton)
          const MorphSkeleton.avatar()
        else
          const SizedBox.square(
            dimension: 48,
            child: Center(child: Text('ME')),
          ),
        const SizedBox(width: 16),
        Expanded(
          child: skeleton
              ? MorphSkeleton.lines(count: 3)
              : const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Mara — product designer'),
                    Text('Content is ready'),
                    Text('Independent consumer state'),
                  ],
                ),
        ),
      ],
    ),
  );
  Widget group(
    Widget placeholder, {
    Widget? content,
    MorphSkeletonEffect? variant,
    Duration? duration,
    bool independent = false,
  }) => MorphSkeletonGroup(
    loading: independent || loading,
    effect: variant ?? effect,
    direction: direction,
    duration: duration ?? Duration(milliseconds: (seconds * 1000).round()),
    intensity: intensity,
    angle: angle,
    renderer: renderer,
    onRendererChanged: independent ? null : reportSkeleton,
    semanticLabel: 'Loading content',
    placeholder: placeholder,
    child: content,
  );
  @override
  Widget build(BuildContext context) {
    final theme = MorphTheme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Operation & Skeleton Lab'),
        actions: [
          IconButton(
            onPressed: widget.onToggleTheme,
            tooltip: 'Light / dark',
            icon: Icon(FluentIcons.line.weather_sunny),
          ),
        ],
      ),
      body: MorphTheme(
        data: theme.copyWith(reduceMotion: reduced || theme.reduceMotion),
        child: Directionality(
          textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
          child: MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: TextScaler.linear(largeText ? 2 : 1)),
            child: Align(
              alignment: Alignment.topCenter,
              child: SizedBox(
                width: mobile ? 390 : 1100,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Controlled operations · shared lighting · no hidden timers in components',
                      ),
                      choices([
                        choice(
                          'Reduced motion: $reduced',
                          () => setState(() => reduced = !reduced),
                        ),
                        choice('RTL: $rtl', () => setState(() => rtl = !rtl)),
                        choice(
                          'Text 2×: $largeText',
                          () => setState(() => largeText = !largeText),
                        ),
                        choice(
                          'Mobile width: $mobile',
                          () => setState(() => mobile = !mobile),
                        ),
                      ]),
                      section('Operation buttons', [
                        choices(
                          MorphOperationState.values.map(
                            (s) => choice(s.name, () {
                              cancel();
                              setState(() => state = s);
                            }),
                          ),
                        ),
                        const SizedBox(height: 12),
                        choices([
                          choice(
                            'Success simulation',
                            () => simulate(MorphOperationState.success),
                          ),
                          choice(
                            'Error / retry',
                            () => simulate(MorphOperationState.error),
                          ),
                          choice(
                            'Immediate result',
                            () => simulate(
                              MorphOperationState.success,
                              instant: true,
                            ),
                          ),
                          choice('Rapid interruptions', rapid),
                          ...MorphOperationPresentation.values.map(
                            (mode) => choice(
                              'Size samples: ${mode.name}',
                              () => setState(() => presentation = mode),
                            ),
                          ),
                          choice(
                            'Loading label: $label',
                            () => setState(() => label = !label),
                          ),
                        ]),
                        const SizedBox(height: 12),
                        for (final style in MorphButtonStyle.values)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${style.name} · preserve width / compact',
                                ),
                                const SizedBox(height: 8),
                                choices([
                                  operation(
                                    style,
                                    MorphOperationPresentation.preserveWidth,
                                  ),
                                  operation(
                                    style,
                                    MorphOperationPresentation.compact,
                                  ),
                                ]),
                              ],
                            ),
                          ),
                        choices([
                          for (final size in [
                            MorphButtonSize.xs,
                            MorphButtonSize.md,
                            MorphButtonSize.lg,
                          ])
                            operation(
                              MorphButtonStyle.tonal,
                              presentation,
                              size: size,
                              text: size.name,
                            ),
                          operation(
                            MorphButtonStyle.filled,
                            presentation,
                            enabled: false,
                            text: 'Explicit disabled',
                          ),
                        ]),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: 240,
                          child: operation(
                            MorphButtonStyle.outlined,
                            MorphOperationPresentation.compact,
                            text: 'A long label in an explicitly limited width',
                          ),
                        ),
                        const Text(
                          'Tight width wins over compact. Labels ellipsize, never scale.',
                        ),
                        const SizedBox(height: 12),
                        MorphAsyncButton(
                          label: 'Custom loader / result',
                          state: state,
                          onPressed: rapid,
                          loading: const Text('…'),
                          successIcon: const Text('✓'),
                          errorIcon: const Text('×'),
                          stateDecorations: {
                            MorphOperationState.error:
                                MorphButtonDecoration.styleFrom(
                                  backgroundColor: theme.colorScheme.error,
                                  foregroundColor: theme.colorScheme.onError,
                                ),
                          },
                        ),
                        Text(
                          'Requested: ${renderer.name} · button effective: ${buttonEffective.name}',
                        ),
                      ]),
                      section('AsyncButton polish', [
                        const AsyncPolishSection(),
                      ]),
                      section('Reactive button groups', [
                        const ReactiveGroupsSection(),
                      ]),
                      section('Coordinated skeleton / shimmer', [
                        choices([
                          choice(
                            loading ? 'Show real content' : 'Back to loading',
                            () => setState(() => loading = !loading),
                          ),
                          choice('Reverse transition', () {
                            cancel();
                            setState(() => loading = false);
                            later(70, () => loading = true);
                          }),
                          ...MorphSkeletonEffect.values.map(
                            (e) => choice(
                              e.name,
                              () => setState(() => effect = e),
                            ),
                          ),
                          ...MorphShapeRenderer.values.map(
                            (r) => choice(
                              'renderer ${r.name}',
                              () => setState(() => renderer = r),
                            ),
                          ),
                        ]),
                        choices(
                          MorphShimmerDirection.values.map(
                            (d) => choice(
                              d.name,
                              () => setState(() => direction = d),
                            ),
                          ),
                        ),
                        Text('Duration ${seconds.toStringAsFixed(1)} s'),
                        MorphSlider(
                          value: (seconds - .6) / 3.4,
                          onChanged: (v) =>
                              setState(() => seconds = .6 + v * 3.4),
                        ),
                        Text(
                          'Band angle ${angle.toStringAsFixed(0)}° from the vertical (+ leans /, − leans \\) · direction decides travel',
                        ),
                        MorphSlider(
                          value: (angle + 90) / 180,
                          onChanged: (v) => setState(
                            () => angle = (v * 180 - 90).roundToDouble(),
                          ),
                        ),
                        choices([
                          for (final a in [
                            -85,
                            -45,
                            -30,
                            -15,
                            0,
                            15,
                            30,
                            45,
                            85,
                          ])
                            choice(
                              '$a°',
                              () => setState(() => angle = a.toDouble()),
                            ),
                        ]),
                        Text('Intensity ${intensity.toStringAsFixed(2)}'),
                        MorphSlider(
                          value: intensity,
                          onChanged: (v) => setState(() => intensity = v),
                        ),
                        Text(
                          'Requested: ${renderer.name} · shimmer effective: ${skeletonEffective.name}',
                        ),
                        const SizedBox(height: 16),
                        group(
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              profile(),
                              const SizedBox(height: 16),
                              const MorphSkeleton.image(height: 140),
                              const SizedBox(height: 16),
                              MorphSkeleton.lines(count: 3),
                            ],
                          ),
                          content: SizedBox(
                            height: 304,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                profile(skeleton: false),
                                const Text('A real content card'),
                                MorphButton(
                                  onPressed: () {},
                                  child: const Text('Focusable real action'),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text('One shared sweep across the entire list'),
                        group(
                          Column(
                            children: [for (var i = 0; i < 8; i++) profile()],
                          ),
                          content: Column(
                            children: [
                              for (var i = 0; i < 8; i++)
                                profile(skeleton: false),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text('Poster grid · common group coordinates'),
                        group(
                          LayoutBuilder(
                            builder: (context, bounds) => Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: [
                                for (var i = 0; i < 6; i++)
                                  MorphSkeleton.image(
                                    width: (bounds.maxWidth - 24) / 3,
                                    height: 150,
                                  ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Independent groups: pulse, static, slower shimmer',
                        ),
                        choices([
                          group(
                            const MorphSkeleton.avatar(size: 64),
                            variant: MorphSkeletonEffect.pulse,
                            independent: true,
                          ),
                          group(
                            const MorphSkeleton(width: 120, height: 64),
                            variant: MorphSkeletonEffect.none,
                            independent: true,
                          ),
                          group(
                            const MorphSkeleton(width: 120, height: 64),
                            duration: const Duration(seconds: 3),
                            independent: true,
                          ),
                        ]),
                        const SizedBox(height: 16),
                        const Text(
                          'Angle comparison · each group has its own common space (0°, +30°, −30°, wide vs narrow)',
                        ),
                        Wrap(
                          spacing: 16,
                          runSpacing: 16,
                          children: [
                            for (final a in [0.0, 30.0, -30.0])
                              for (final w in [320.0, 120.0])
                                SizedBox(
                                  width: w,
                                  child: MorphSkeletonGroup(
                                    angle: a,
                                    direction: direction,
                                    intensity: intensity,
                                    renderer: renderer,
                                    placeholder: Column(
                                      children: [
                                        Row(
                                          children: [
                                            const MorphSkeleton.avatar(
                                              size: 40,
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: MorphSkeleton.lines(
                                                count: 2,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        const MorphSkeleton.image(height: 56),
                                      ],
                                    ),
                                  ),
                                ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Catalog contour · Canvas coverage fallback',
                        ),
                        group(
                          SizedBox.square(
                            dimension: 80,
                            child: MorphSkeleton(
                              height: 80,
                              shape: MorphShapeCatalog.sunny,
                            ),
                          ),
                        ),
                      ]),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
