import 'package:material_ui/material_ui.dart'
    show
        BuildContext,
        Color,
        Column,
        MainAxisSize,
        SizedBox,
        State,
        StatefulWidget,
        ValueKey,
        Widget;
import 'package:morph_expressive/morph_expressive.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../utilities/demo.dart';
import '../../utilities/knobs.dart';
import '../../utilities/stage.dart';

const _path = '[Inputs]/Sliders';

enum _SliderKind {
  linear,
  centered,
  wavy,
  wavyCentered,
  vertical,
  verticalCentered,
}

@widgetbook.UseCase(name: 'Playground', type: MorphSlider, path: _path)
Widget sliderPlaygroundUseCase(BuildContext context) {
  final kind = enumKnob<_SliderKind>(
    context,
    label: 'type',
    values: _SliderKind.values,
  );
  final size = enumKnob<MorphSliderSize>(
    context,
    label: 'size',
    values: MorphSliderSize.values,
  );
  final enabled = context.knobs.boolean(label: 'enabled', initialValue: true);
  final divisions = context.knobs.int.slider(
    label: 'divisions (0 = continuous)',
    initialValue: 0,
    min: 0,
    max: 20,
  );
  final showLabel = context.knobs.boolean(label: 'value label');
  return _SliderHarness(
    key: resetKey([kind]),
    kind: kind,
    size: size,
    enabled: enabled,
    divisions: divisions == 0 ? null : divisions,
    showLabel: showLabel,
  );
}

class _SliderHarness extends StatefulWidget {
  const _SliderHarness({
    super.key,
    required this.kind,
    required this.size,
    required this.enabled,
    required this.divisions,
    required this.showLabel,
  });

  final _SliderKind kind;
  final MorphSliderSize size;
  final bool enabled;
  final int? divisions;
  final bool showLabel;

  @override
  State<_SliderHarness> createState() => _SliderHarnessState();
}

class _SliderHarnessState extends State<_SliderHarness> {
  double _value = 0.6;

  @override
  Widget build(BuildContext context) {
    final label = widget.showLabel ? '${(_value * 100).round()}%' : null;
    void onChanged(double v) => setState(() => _value = v);
    final slider = switch (widget.kind) {
      _SliderKind.linear => MorphSlider(
        key: const ValueKey('morph_slider_under_test'),
        value: _value,
        onChanged: widget.enabled ? onChanged : null,
        size: widget.size,
        divisions: widget.divisions,
        label: label,
      ),
      _SliderKind.centered => MorphSlider.centered(
        key: const ValueKey('morph_slider_under_test'),
        value: _value,
        onChanged: widget.enabled ? onChanged : null,
        size: widget.size,
        divisions: widget.divisions,
        label: label,
      ),
      _SliderKind.wavy => MorphSlider.wavy(
        key: const ValueKey('morph_slider_under_test'),
        value: _value,
        onChanged: widget.enabled ? onChanged : null,
        size: widget.size,
        divisions: widget.divisions,
        label: label,
      ),
      _SliderKind.wavyCentered => MorphSlider.wavyCentered(
        key: const ValueKey('morph_slider_under_test'),
        value: _value,
        onChanged: widget.enabled ? onChanged : null,
        size: widget.size,
        divisions: widget.divisions,
        label: label,
      ),
      _SliderKind.vertical => MorphSlider.vertical(
        key: const ValueKey('morph_slider_under_test'),
        value: _value,
        onChanged: widget.enabled ? onChanged : null,
        size: widget.size,
        divisions: widget.divisions,
        label: label,
      ),
      _SliderKind.verticalCentered => MorphSlider.verticalCentered(
        key: const ValueKey('morph_slider_under_test'),
        value: _value,
        onChanged: widget.enabled ? onChanged : null,
        size: widget.size,
        divisions: widget.divisions,
        label: label,
      ),
    };
    final vertical =
        widget.kind == _SliderKind.vertical ||
        widget.kind == _SliderKind.verticalCentered;
    return StageCenter(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: vertical ? null : 460,
            height: vertical ? 260 : null,
            child: slider,
          ),
          const SizedBox(height: 16),
          DemoReadout('Value: ${_value.toStringAsFixed(2)}'),
        ],
      ),
    );
  }
}

@widgetbook.UseCase(name: 'All types', type: MorphSlider, path: _path)
Widget sliderTypesUseCase(BuildContext context) {
  return const _AllSliders();
}

class _AllSliders extends StatefulWidget {
  const _AllSliders();

  @override
  State<_AllSliders> createState() => _AllSlidersState();
}

class _AllSlidersState extends State<_AllSliders> {
  double _value = 0.6;

  @override
  Widget build(BuildContext context) {
    void onChanged(double v) => setState(() => _value = v);
    Widget section(String title, Widget child) => StageSection(
      title: title,
      child: SizedBox(width: 520, child: child),
    );
    return Stage(
      children: [
        section(
          'Linear',
          MorphSlider(value: _value, onChanged: onChanged, label: '$_value'),
        ),
        section(
          'Centered',
          MorphSlider.centered(value: _value, onChanged: onChanged),
        ),
        section('Wavy', MorphSlider.wavy(value: _value, onChanged: onChanged)),
        section(
          'Wavy centered',
          MorphSlider.wavyCentered(value: _value, onChanged: onChanged),
        ),
        section('Disabled', MorphSlider(value: _value, onChanged: null)),
      ],
    );
  }
}

@widgetbook.UseCase(name: 'Range slider', type: MorphRangeSlider, path: _path)
Widget rangeSliderUseCase(BuildContext context) {
  final wavy = context.knobs.boolean(label: 'wavy');
  final enabled = context.knobs.boolean(label: 'enabled', initialValue: true);
  final size = enumKnob<MorphSliderSize>(
    context,
    label: 'size',
    values: MorphSliderSize.values,
  );
  return _RangeHarness(wavy: wavy, enabled: enabled, size: size);
}

class _RangeHarness extends StatefulWidget {
  const _RangeHarness({
    required this.wavy,
    required this.enabled,
    required this.size,
  });

  final bool wavy;
  final bool enabled;
  final MorphSliderSize size;

  @override
  State<_RangeHarness> createState() => _RangeHarnessState();
}

class _RangeHarnessState extends State<_RangeHarness> {
  MorphSliderRange _range = const MorphSliderRange(0.25, 0.78);

  @override
  Widget build(BuildContext context) {
    void onChanged(MorphSliderRange next) => setState(() => _range = next);
    final slider = widget.wavy
        ? MorphRangeSlider.wavy(
            values: _range,
            onChanged: widget.enabled ? onChanged : null,
            size: widget.size,
          )
        : MorphRangeSlider(
            values: _range,
            onChanged: widget.enabled ? onChanged : null,
            size: widget.size,
          );
    return Stage(
      children: [
        SizedBox(width: 520, child: slider),
        DemoReadout(
          'Range: ${_range.start.toStringAsFixed(2)} to ${_range.end.toStringAsFixed(2)}',
        ),
      ],
    );
  }
}

@widgetbook.UseCase(name: 'Slider parts', type: MorphSliderTrack, path: _path)
Widget sliderPartsUseCase(BuildContext context) {
  final scheme = MorphTheme.of(context).colorScheme;
  return Stage(
    children: [
      StageSection(
        title: 'Custom thumb and track builders',
        note:
            'MorphSliderThumb, MorphSliderTrack, MorphSliderCenteredTrack and '
            'MorphSliderValueIndicator are the parts MorphSlider composes; '
            'they are exercised by every slider on this page, and a custom '
            'trackThickness / thumbLength is shown here.',
        child: SizedBox(
          width: 520,
          child: _CustomSlider(color: scheme.tertiary),
        ),
      ),
    ],
  );
}

class _CustomSlider extends StatefulWidget {
  const _CustomSlider({required this.color});

  final Color color;

  @override
  State<_CustomSlider> createState() => _CustomSliderState();
}

class _CustomSliderState extends State<_CustomSlider> {
  double _value = 0.4;

  @override
  Widget build(BuildContext context) {
    return MorphSlider(
      value: _value,
      onChanged: (v) => setState(() => _value = v),
      trackThickness: 28,
      thumbLength: 6,
      cornerRadius: 14,
      label: _value.toStringAsFixed(2),
    );
  }
}
