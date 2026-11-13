import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:morph_expressive/morph_expressive.dart';

/// Consumer-owned simulation helper: one generation token, cancelable timers.
mixin _Sim<T extends StatefulWidget> on State<T> {
  final List<Timer> _timers = [];
  int _gen = 0;
  void cancelSim() {
    _gen++;
    for (final t in _timers) {
      t.cancel();
    }
    _timers.clear();
  }

  void after(int ms, VoidCallback action) {
    final token = _gen;
    _timers.add(
      Timer(Duration(milliseconds: ms), () {
        if (mounted && token == _gen) setState(action);
      }),
    );
  }

  @override
  void dispose() {
    cancelSim();
    super.dispose();
  }
}

Widget _label(BuildContext c, String t) => Padding(
  padding: const EdgeInsets.only(top: 12, bottom: 6),
  child: Text(t, style: MorphTheme.of(c).typeScale.labelLarge),
);

Widget _wrap(List<Widget> children) => Wrap(
  spacing: 8,
  runSpacing: 8,
  crossAxisAlignment: WrapCrossAlignment.center,
  children: children,
);

Widget _chip(String text, VoidCallback onTap, {bool on = false}) => on
    ? MorphButton.filled(onPressed: onTap, child: Text(text))
    : MorphButton.tonal(onPressed: onTap, child: Text(text));

/// AsyncButton: error colours, loading→success glyph transition variants.
class AsyncPolishSection extends StatefulWidget {
  const AsyncPolishSection({super.key});
  @override
  State<AsyncPolishSection> createState() => _AsyncPolishSectionState();
}

class _AsyncPolishSectionState extends State<AsyncPolishSection> with _Sim {
  MorphOperationState state = MorphOperationState.idle;
  @override
  void initState() {
    super.initState();
    // Opt-in native review: loop loading → success so motion can be captured.
    if (const bool.fromEnvironment('MORPH_OPERATION_AUTORUN')) {
      void loop() {
        run(MorphOperationState.success, ms: 900);
        after(2200, () {});
        Timer(const Duration(milliseconds: 3200), () {
          if (mounted) loop();
        });
      }

      WidgetsBinding.instance.addPostFrameCallback((_) => loop());
    }
  }

  void run(MorphOperationState result, {int ms = 1400}) {
    cancelSim();
    setState(() => state = MorphOperationState.loading);
    after(ms, () => state = result);
  }

  void interrupt() {
    cancelSim();
    setState(() => state = MorphOperationState.loading);
    after(500, () => state = MorphOperationState.success);
    // Change state while the glyph is still entering.
    after(650, () => state = MorphOperationState.loading);
    after(760, () => state = MorphOperationState.error);
    after(900, () => state = MorphOperationState.success);
  }

  Widget demo(
    String title, {
    MorphOperationPresentation mode = MorphOperationPresentation.preserveWidth,
    MorphOperationIconTransition? transition,
    Widget? success,
    MorphButtonStyle style = MorphButtonStyle.filled,
  }) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(title, style: MorphTheme.of(context).typeScale.bodySmall),
      const SizedBox(height: 6),
      MorphAsyncButton(
        label: 'Save',
        state: state,
        style: style,
        presentation: mode,
        iconTransition: transition,
        successIcon: success,
        labels: const {
          MorphOperationState.loading: 'Saving',
          MorphOperationState.success: 'Saved',
          MorphOperationState.error: 'Retry',
        },
        onPressed: () => run(MorphOperationState.success),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final scheme = MorphTheme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(
          context,
          'Error colours · all five styles (semantic error tokens + icon + label)',
        ),
        _wrap([
          for (final s in MorphButtonStyle.values)
            MorphAsyncButton(
              label: 'Retry ${s.name}',
              style: s,
              state: MorphOperationState.error,
              onPressed: () {},
            ),
          const MorphAsyncButton(
            label: 'Disabled error',
            state: MorphOperationState.error,
            onPressed: null,
          ),
          MorphAsyncButton(
            label: 'Explicit override',
            state: MorphOperationState.error,
            onPressed: () {},
            stateDecorations: {
              MorphOperationState.error: MorphButtonDecoration.styleFrom(
                backgroundColor: scheme.tertiaryContainer,
                foregroundColor: scheme.onTertiaryContainer,
              ),
            },
          ),
        ]),
        _label(context, 'Loading → success / error transitions'),
        _wrap([
          _chip('Loading → success', () => run(MorphOperationState.success)),
          _chip('Loading → error', () => run(MorphOperationState.error)),
          _chip('Success → loading', () {
            cancelSim();
            setState(() => state = MorphOperationState.success);
            after(900, () => state = MorphOperationState.loading);
          }),
          _chip('Repeat ×3', () {
            cancelSim();
            for (var i = 0; i < 3; i++) {
              after(i * 1800, () => state = MorphOperationState.loading);
              after(i * 1800 + 900, () => state = MorphOperationState.success);
            }
          }),
          _chip('Interrupt during entry', interrupt),
          _chip('Reset idle', () {
            cancelSim();
            setState(() => state = MorphOperationState.idle);
          }),
        ]),
        const SizedBox(height: 12),
        Wrap(
          spacing: 24,
          runSpacing: 16,
          children: [
            demo('Default icon · 320 ms'),
            demo(
              'Slow · 1400 ms',
              transition: const MorphOperationIconTransition(
                duration: Duration(milliseconds: 1400),
              ),
            ),
            demo('Custom widget (star)', success: const _CustomSuccess()),
            demo(
              'Animation disabled',
              transition: MorphOperationIconTransition.none,
            ),
            demo('Compact', mode: MorphOperationPresentation.compact),
            demo(
              'Compact · slow · tonal',
              mode: MorphOperationPresentation.compact,
              style: MorphButtonStyle.tonal,
              transition: const MorphOperationIconTransition(
                duration: Duration(milliseconds: 1400),
              ),
            ),
          ],
        ),
        const Text(
          'Reduced motion (toggle above) shows the result without rotation.',
        ),
      ],
    );
  }
}

class _CustomSuccess extends StatelessWidget {
  const _CustomSuccess();
  @override
  Widget build(BuildContext context) => Icon(FluentIcons.line.star, size: 20);
}

/// New reactive groups: three modes, references, controls, comparison.
class ReactiveGroupsSection extends StatefulWidget {
  const ReactiveGroupsSection({super.key});
  @override
  State<ReactiveGroupsSection> createState() => _ReactiveGroupsSectionState();
}

class _ReactiveGroupsSectionState extends State<ReactiveGroupsSection> {
  int? single = 0, wifiSel = 1;
  Set<int> multi = {0, 2}, all = {0, 1, 2, 3};
  int? connectedSel = 0;
  double pressed = .15,
      selected = .08,
      gap = 4,
      restRadius = 28,
      selRadius = 12;
  bool wide = true, customRadii = false;
  MorphReactiveGroupFit fit = MorphReactiveGroupFit.fill;
  String lastAction = '–';

  Widget box(Widget child) => Align(
    alignment: AlignmentDirectional.centerStart,
    child: SizedBox(width: wide ? 560 : 260, child: child),
  );

  List<MorphReactiveGroupItem> labeled(
    int n, {
    bool icons = false,
    bool longLabels = false,
  }) => [
    for (var i = 0; i < n; i++)
      MorphReactiveGroupItem(
        icon: icons ? Icon(FluentIcons.line.star, size: 20) : null,
        label: Text(
          longLabels
              ? 'A rather long label number $i'
              : ['Day', 'Week', 'Month', 'Year', 'All'][i % 5],
        ),
      ),
  ];

  Widget group({
    required List<MorphReactiveGroupItem> items,
    MorphReactiveGroupMode mode = MorphReactiveGroupMode.singleSelect,
    int? sel,
    ValueChanged<int?>? onSel,
    Set<int> multiSel = const {},
    ValueChanged<Set<int>>? onMulti,
    MorphButtonStyle style = MorphButtonStyle.tonal,
    MorphReactiveGroupFit? fitOverride,
    String? semantic,
    MorphButtonSize size = MorphButtonSize.sm,
  }) => MorphReactiveButtonGroup(
    items: items,
    mode: mode,
    selectedIndex: sel,
    onSelectedIndexChanged: onSel,
    selectedIndices: multiSel,
    onSelectedIndicesChanged: onMulti,
    style: style,
    size: size,
    fit: fitOverride ?? fit,
    gap: gap,
    pressedExpansion: pressed,
    selectedExpansion: selected,
    restRadius: customRadii ? restRadius : null,
    selectedRadius: customRadii ? selRadius : null,
    semanticLabel: semantic,
  );

  Widget slider(
    String name,
    double value,
    double min,
    double max,
    ValueChanged<double> on,
  ) => Row(
    children: [
      SizedBox(width: 190, child: Text('$name ${value.toStringAsFixed(2)}')),
      Expanded(
        child: MorphSlider(
          value: (value - min) / (max - min),
          onChanged: (v) => setState(() => on(min + v * (max - min))),
        ),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    Widget icon(IconData d) => Icon(d, size: 20);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(context, 'Controls'),
        _wrap([
          _chip(
            'Container: ${wide ? 'wide 560' : 'narrow 260'}',
            () => setState(() => wide = !wide),
          ),
          for (final f in MorphReactiveGroupFit.values)
            _chip('fit ${f.name}', () => setState(() => fit = f), on: fit == f),
          _chip(
            'Custom radii: $customRadii',
            () => setState(() => customRadii = !customRadii),
          ),
        ]),
        slider('Pressed expansion', pressed, 0, .3, (v) => pressed = v),
        slider('Selected expansion', selected, 0, .3, (v) => selected = v),
        slider('Gap dp', gap, 0, 24, (v) => gap = v),
        slider('Rest radius dp', restRadius, 4, 40, (v) => restRadius = v),
        slider('Selected radius dp', selRadius, 0, 28, (v) => selRadius = v),

        _label(
          context,
          'A · Single select (consumer controlled; tap selected clears)',
        ),
        box(
          group(
            items: labeled(4),
            sel: single,
            onSel: (v) => setState(() => single = v),
            semantic: 'Range',
          ),
        ),
        _label(context, 'B · Multi toggle (several active keep expansion)'),
        box(
          group(
            items: labeled(4),
            mode: MorphReactiveGroupMode.multiToggle,
            multiSel: multi,
            onMulti: (v) => setState(() => multi = v),
          ),
        ),
        _label(context, 'B · All active (shapes only, layout intact)'),
        box(
          group(
            items: labeled(4),
            mode: MorphReactiveGroupMode.multiToggle,
            multiSel: all,
            onMulti: (v) => setState(() => all = v),
          ),
        ),
        _label(
          context,
          'C · Independent actions (widen while pressed · last: $lastAction)',
        ),
        box(
          group(
            mode: MorphReactiveGroupMode.actions,
            items: [
              for (final n in ['Copy', 'Share', 'Delete'])
                MorphReactiveGroupItem(
                  label: Text(n),
                  onPressed: () => setState(() => lastAction = n),
                ),
            ],
          ),
        ),

        _label(
          context,
          'Connectivity (reference image 6): icon-only, selected is squarer',
        ),
        box(
          group(
            items: [
              MorphReactiveGroupItem(
                icon: icon(FluentIcons.line.wifi_1),
                semanticLabel: 'Wi-Fi',
                minWidth: 64,
              ),
              MorphReactiveGroupItem(
                icon: icon(FluentIcons.line.bluetooth),
                semanticLabel: 'Bluetooth',
                minWidth: 64,
              ),
              MorphReactiveGroupItem(
                icon: icon(FluentIcons.line.airplane),
                semanticLabel: 'Airplane',
                minWidth: 64,
              ),
            ],
            sel: wifiSel,
            onSel: (v) => setState(() => wifiSel = v),
            size: MorphButtonSize.md,
          ),
        ),
        _label(
          context,
          'Media (reference images 7/8): rounded ends, distinct centre',
        ),
        box(
          group(
            mode: MorphReactiveGroupMode.actions,
            size: MorphButtonSize.md,
            items: [
              MorphReactiveGroupItem(
                icon: icon(FluentIcons.line.rewind),
                semanticLabel: 'Rewind',
                minWidth: 72,
                onPressed: () => setState(() => lastAction = 'rewind'),
              ),
              MorphReactiveGroupItem(
                icon: icon(FluentIcons.line.play),
                semanticLabel: 'Play',
                style: MorphButtonStyle.filled,
                restRadius: 16,
                pressedRadius: 12,
                minWidth: 96,
                onPressed: () => setState(() => lastAction = 'play'),
              ),
              MorphReactiveGroupItem(
                icon: icon(FluentIcons.line.fast_forward),
                semanticLabel: 'Forward',
                minWidth: 72,
                onPressed: () => setState(() => lastAction = 'forward'),
              ),
            ],
          ),
        ),
        box(
          group(
            mode: MorphReactiveGroupMode.actions,
            items: [
              MorphReactiveGroupItem(
                icon: icon(FluentIcons.line.previous),
                label: const Text('Prev'),
                onPressed: () {},
              ),
              MorphReactiveGroupItem(
                icon: icon(FluentIcons.line.pause),
                label: const Text('Pause'),
                style: MorphButtonStyle.filled,
                restRadius: 10,
                onPressed: () {},
              ),
              MorphReactiveGroupItem(
                icon: icon(FluentIcons.line.next),
                label: const Text('Next'),
                onPressed: () {},
              ),
            ],
          ),
        ),

        _label(context, 'Content kinds: icon-only · label-only · icon + label'),
        box(
          group(
            items: [
              MorphReactiveGroupItem(
                icon: icon(FluentIcons.line.home),
                semanticLabel: 'Home',
              ),
              const MorphReactiveGroupItem(label: Text('Label only')),
              MorphReactiveGroupItem(
                icon: icon(FluentIcons.line.search),
                label: const Text('Search'),
              ),
            ],
            sel: single,
            onSel: (v) => setState(() => single = v),
          ),
        ),
        _label(
          context,
          'Long labels (ellipsis only when the constraints truly cannot hold them)',
        ),
        box(
          group(
            items: labeled(3, longLabels: true),
            sel: single,
            onSel: (v) => setState(() => single = v),
          ),
        ),
        _label(context, 'Uniform width option'),
        box(
          group(
            items: labeled(4),
            sel: single,
            onSel: (v) => setState(() => single = v),
            fitOverride: MorphReactiveGroupFit.uniform,
          ),
        ),

        _label(context, 'Previous connected group (unchanged, approved look)'),
        box(
          MorphButtonGroup(
            type: MorphButtonGroupType.connected,
            actions: [
              for (final l in ['Day', 'Week', 'Month', 'Year'])
                MorphButtonGroupAction(label: Text(l)),
            ],
            selectedIndex: connectedSel,
            onSelectedIndexChanged: (v) => setState(() => connectedSel = v),
          ),
        ),
      ],
    );
  }
}
