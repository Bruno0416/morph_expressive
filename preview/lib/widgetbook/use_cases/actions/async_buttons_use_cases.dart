import 'dart:async';

import 'package:material_ui/material_ui.dart'
    show
        BuildContext,
        Column,
        Icon,
        MainAxisSize,
        SizedBox,
        State,
        StatefulWidget,
        Widget;
import 'package:morph_expressive/morph_expressive.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../utilities/demo.dart';
import '../../utilities/knobs.dart';
import '../../utilities/stage.dart';

const _path = '[Actions]/Async Buttons';

@widgetbook.UseCase(
  name: 'Controlled state',
  type: MorphAsyncButton,
  path: _path,
)
Widget asyncButtonControlledUseCase(BuildContext context) {
  final state = enumKnob<MorphOperationState>(
    context,
    label: 'state',
    values: MorphOperationState.values,
  );
  final presentation = enumKnob<MorphOperationPresentation>(
    context,
    label: 'presentation',
    values: MorphOperationPresentation.values,
  );
  final style = enumKnob<MorphButtonStyle>(
    context,
    label: 'style',
    values: MorphButtonStyle.values,
  );
  final variant = variantKnob(context);
  final surface = surfaceKnob(context);
  final size = buttonSizeKnob(context);
  final enabled = context.knobs.boolean(label: 'enabled', initialValue: true);
  final showLoadingLabel = context.knobs.boolean(
    label: 'show loading label',
    initialValue: true,
  );
  final label = context.knobs.string(label: 'label', initialValue: 'Save');
  return StageCenter(
    child: MorphAsyncButton(
      label: label,
      state: state,
      presentation: presentation,
      style: style,
      variant: variant,
      surface: surface,
      size: size,
      enabled: enabled,
      showLoadingLabel: showLoadingLabel,
      icon: Icon(FluentIcons.line.bookmark),
      labels: const {
        MorphOperationState.loading: 'Saving',
        MorphOperationState.success: 'Saved',
        MorphOperationState.error: 'Retry',
      },
      onPressed: () {},
    ),
  );
}

@widgetbook.UseCase(
  name: 'Simulated operation',
  type: MorphAsyncButton,
  path: _path,
)
Widget asyncButtonSimulatedUseCase(BuildContext context) {
  final style = enumKnob<MorphButtonStyle>(
    context,
    label: 'style',
    values: MorphButtonStyle.values,
  );
  final variant = variantKnob(context);
  final fails = context.knobs.boolean(label: 'operation fails');
  final millis = context.knobs.int.slider(
    label: 'duration (ms)',
    initialValue: 1200,
    min: 300,
    max: 4000,
  );
  return _SimulatedAsyncButton(
    key: resetKey([style, variant, fails, millis]),
    style: style,
    variant: variant,
    fails: fails,
    duration: Duration(milliseconds: millis),
  );
}

class _SimulatedAsyncButton extends StatefulWidget {
  const _SimulatedAsyncButton({
    super.key,
    required this.style,
    required this.variant,
    required this.fails,
    required this.duration,
  });

  final MorphButtonStyle style;
  final MorphVariant? variant;
  final bool fails;
  final Duration duration;

  @override
  State<_SimulatedAsyncButton> createState() => _SimulatedAsyncButtonState();
}

class _SimulatedAsyncButtonState extends State<_SimulatedAsyncButton> {
  MorphOperationState _state = MorphOperationState.idle;
  Timer? _timer;
  Timer? _reset;

  @override
  void dispose() {
    _timer?.cancel();
    _reset?.cancel();
    super.dispose();
  }

  void _run() {
    setState(() => _state = MorphOperationState.loading);
    _timer = Timer(widget.duration, () {
      if (!mounted) return;
      setState(
        () => _state = widget.fails
            ? MorphOperationState.error
            : MorphOperationState.success,
      );
      _reset = Timer(const Duration(milliseconds: 1500), () {
        if (mounted) setState(() => _state = MorphOperationState.idle);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return StageCenter(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          MorphAsyncButton(
            label: 'Upload',
            state: _state,
            style: widget.style,
            variant: widget.variant,
            icon: Icon(FluentIcons.line.arrow_up),
            labels: const {
              MorphOperationState.loading: 'Uploading',
              MorphOperationState.success: 'Done',
              MorphOperationState.error: 'Retry',
            },
            onPressed: _run,
          ),
          const SizedBox(height: 16),
          DemoReadout('State: ${_state.name}'),
        ],
      ),
    );
  }
}
