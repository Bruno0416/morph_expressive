import 'package:flutter/physics.dart' show SpringSimulation;
import 'package:material_ui/material_ui.dart'
    show
        AnimatedBuilder,
        AnimationController,
        BorderRadius,
        BoxDecoration,
        BuildContext,
        Center,
        Clip,
        Column,
        Container,
        CrossAxisAlignment,
        DecoratedBox,
        InkWell,
        LayoutBuilder,
        Material,
        Positioned,
        RoundedRectangleBorder,
        SingleTickerProviderStateMixin,
        SizedBox,
        Stack,
        State,
        StatefulWidget,
        Text,
        TextStyle,
        Widget;
import 'package:morph_expressive/morph_expressive.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../utilities/knobs.dart';
import '../../utilities/lab_hosts.dart';
import '../../utilities/stage.dart';

const _path = '[Foundations]/Motion';

const _springs = <String, MorphSpring>{
  'spatialFast': MorphMotion.spatialFast,
  'spatialDefault': MorphMotion.spatialDefault,
  'spatialSlow': MorphMotion.spatialSlow,
  'expressiveSpatialFast': MorphMotion.expressiveSpatialFast,
  'expressiveSpatialDefault': MorphMotion.expressiveSpatialDefault,
  'expressiveSpatialSlow': MorphMotion.expressiveSpatialSlow,
  'expressiveSpatialPress': MorphMotion.expressiveSpatialPress,
  'effectsFast': MorphMotion.effectsFast,
  'effectsDefault': MorphMotion.effectsDefault,
  'effectsSlow': MorphMotion.effectsSlow,
  'buttonMorph': MorphMotion.buttonMorph,
};

@widgetbook.UseCase(name: 'Spring presets', type: MorphMotionScope, path: _path)
Widget springPresetsUseCase(BuildContext context) {
  final name = context.knobs.object.dropdown<String>(
    label: 'spring',
    options: _springs.keys.toList(),
    initialOption: 'expressiveSpatialDefault',
  );
  final reduce = context.knobs.boolean(label: 'reduce motion (scope)');
  return MorphMotionScope(
    reduceMotion: reduce,
    child: _SpringDemo(key: resetKey([name, reduce]), spring: _springs[name]!),
  );
}

class _SpringDemo extends StatefulWidget {
  const _SpringDemo({super.key, required this.spring});

  final MorphSpring spring;

  @override
  State<_SpringDemo> createState() => _SpringDemoState();
}

class _SpringDemoState extends State<_SpringDemo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _toEnd = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController.unbounded(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    _toEnd = !_toEnd;
    final target = _toEnd ? 1.0 : 0.0;
    if (MorphMotionScope.reducedOf(context, listen: false)) {
      _controller.value = target;
      return;
    }
    _controller.animateWith(
      SpringSimulation(
        widget.spring.toDescription(),
        _controller.value,
        target,
        _controller.velocity,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = MorphTheme.of(context).colorScheme;
    final reduced = MorphMotionScope.reducedOf(context);
    return Stage(
      children: [
        StageSection(
          title: 'Spring-driven position',
          note:
              'Stiffness ${widget.spring.stiffness}, damping ratio '
              '${widget.spring.damping}. Reduced motion: $reduced.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MorphButton.filled(
                onPressed: _toggle,
                label: const Text('Animate'),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 72,
                child: LayoutBuilder(
                  builder: (context, constraints) => AnimatedBuilder(
                    animation: _controller,
                    builder: (context, _) => Stack(
                      children: [
                        Positioned(
                          left:
                              _controller.value *
                              (constraints.maxWidth - 64).clamp(0, 600),
                          child: Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: scheme.primary,
                              borderRadius: BorderRadius.circular(
                                16 + 16 * _controller.value,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

@widgetbook.UseCase(
  name: 'Tappable and state layer',
  type: MorphTappable,
  path: _path,
)
Widget tappableUseCase(BuildContext context) {
  final scale = context.knobs.double.slider(
    label: 'pressedScale',
    initialValue: 0.94,
    min: 0.8,
    max: 1.0,
    divisions: 20,
    precision: 2,
  );
  final enabled = context.knobs.boolean(label: 'enabled', initialValue: true);
  final focusRing = context.knobs.boolean(
    label: 'focus ring',
    initialValue: true,
  );
  return _TappableDemo(
    key: resetKey([scale, enabled, focusRing]),
    pressedScale: scale,
    enabled: enabled,
    focusRing: focusRing,
  );
}

class _TappableDemo extends StatefulWidget {
  const _TappableDemo({
    super.key,
    required this.pressedScale,
    required this.enabled,
    required this.focusRing,
  });

  final double pressedScale;
  final bool enabled;
  final bool focusRing;

  @override
  State<_TappableDemo> createState() => _TappableDemoState();
}

class _TappableDemoState extends State<_TappableDemo> {
  int _taps = 0;

  @override
  Widget build(BuildContext context) {
    final scheme = MorphTheme.of(context).colorScheme;
    final radius = BorderRadius.circular(24);
    return Stage(
      children: [
        StageSection(
          title: 'MorphTappable · $_taps taps',
          note:
              'Hover, press and keyboard-focus (Tab) to see the state layer, '
              'the pressed scale spring and the MorphFocusRing.',
          child: MorphTappable(
            enabled: widget.enabled,
            pressedScale: widget.pressedScale,
            onTap: () => setState(() => _taps++),
            builder: (context, state) {
              final surface = DecoratedBox(
                decoration: BoxDecoration(
                  color: scheme.secondaryContainer,
                  borderRadius: radius,
                ),
                child: MorphStateLayerOverlay(
                  state: state,
                  color: scheme.onSecondaryContainer,
                  shape: RoundedRectangleBorder(borderRadius: radius),
                  child: SizedBox(
                    width: 220,
                    height: 96,
                    child: Center(
                      child: Text(
                        state.pressed ? 'pressed' : 'tap me',
                        style: TextStyle(color: scheme.onSecondaryContainer),
                      ),
                    ),
                  ),
                ),
              );
              return widget.focusRing
                  ? MorphFocusRing(
                      radius: radius,
                      focused: state.focused,
                      child: surface,
                    )
                  : surface;
            },
          ),
        ),
      ],
    );
  }
}

@widgetbook.UseCase(name: 'Haptics lab', type: MorphHapticFeedback, path: _path)
Widget hapticsLabUseCase(BuildContext context) =>
    const MobileLabHost(kind: MobileLabKind.haptics);

@widgetbook.UseCase(
  name: 'Ink splash theme',
  type: MorphInkSplashTheme,
  path: _path,
)
Widget inkSplashThemeUseCase(BuildContext context) {
  final scheme = MorphTheme.of(context).colorScheme;
  final color = context.knobs.object.dropdown<String>(
    label: 'role',
    options: const ['primary', 'tertiary', 'error'],
  );
  final role = switch (color) {
    'tertiary' => scheme.tertiary,
    'error' => scheme.error,
    _ => scheme.primary,
  };
  return Stage(
    children: [
      StageSection(
        title: 'MorphInkSplashTheme',
        note: 'Press and hold: the splash and highlight derive from the role.',
        child: MorphInkSplashTheme(
          color: role,
          child: Material(
            color: scheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(20),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () {},
              child: const SizedBox(
                width: 260,
                height: 88,
                child: Center(child: Text('Press for an ink splash')),
              ),
            ),
          ),
        ),
      ),
    ],
  );
}
