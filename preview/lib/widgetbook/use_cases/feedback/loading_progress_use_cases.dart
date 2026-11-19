import 'package:material_ui/material_ui.dart'
    show
        BuildContext,
        CircleAvatar,
        Column,
        CrossAxisAlignment,
        Expanded,
        Row,
        SizedBox,
        Text,
        Widget;
import 'package:morph_expressive/morph_expressive.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../utilities/demo.dart';
import '../../utilities/knobs.dart';
import '../../utilities/stage.dart';

@widgetbook.UseCase(
  name: 'Playground',
  type: MorphLoadingIndicator,
  path: '[Feedback]/Loading indicator',
)
Widget loadingIndicatorUseCase(BuildContext context) {
  final variant = enumKnob<MorphLoadingIndicatorVariant>(
    context,
    label: 'variant',
    values: MorphLoadingIndicatorVariant.values,
  );
  final size = context.knobs.double.slider(
    label: 'size',
    initialValue: 48,
    min: 24,
    max: 160,
  );
  final renderer = enumKnob<MorphShapeRenderer>(
    context,
    label: 'renderer',
    values: MorphShapeRenderer.values,
    initial: MorphShapeRenderer.canvas,
  );
  final scheme = MorphTheme.of(context).colorScheme;
  final custom = context.knobs.boolean(label: 'custom colors');
  return StageCenter(
    // The indicator animates continuously by nature.
    child: MorphLoadingIndicator(
      variant: variant,
      size: size,
      renderer: renderer,
      color: custom ? scheme.tertiary : null,
      containerColor: custom ? scheme.tertiaryContainer : null,
      semanticLabel: 'Loading',
    ),
  );
}

enum _ProgressKind { circular, circularWavy, linear, linearWavy }

@widgetbook.UseCase(
  name: 'Playground',
  type: MorphProgressIndicator,
  path: '[Feedback]/Progress',
)
Widget progressIndicatorUseCase(BuildContext context) {
  final kind = enumKnob<_ProgressKind>(
    context,
    label: 'type',
    values: _ProgressKind.values,
  );
  final determinate = context.knobs.boolean(
    label: 'determinate',
    initialValue: true,
  );
  final value = context.knobs.double.slider(
    label: 'value',
    initialValue: 0.6,
    min: 0,
    max: 1,
    divisions: 20,
    precision: 2,
  );
  final size = context.knobs.double.slider(
    label: 'circular size',
    initialValue: 48,
    min: 24,
    max: 120,
  );
  final linearSize = enumKnob<MorphProgressIndicatorSize>(
    context,
    label: 'linear size',
    values: MorphProgressIndicatorSize.values,
  );
  final track = context.knobs.boolean(label: 'show track', initialValue: true);
  final v = determinate ? value : null;
  final indicator = switch (kind) {
    _ProgressKind.circular => MorphProgressIndicator.circular(
      value: v,
      size: size,
      showTrack: track,
    ),
    _ProgressKind.circularWavy => MorphProgressIndicator.circularWavy(
      value: v,
      size: size,
      showTrack: track,
    ),
    _ProgressKind.linear => MorphProgressIndicator.linear(
      value: v,
      linearSize: linearSize,
      showTrack: track,
    ),
    _ProgressKind.linearWavy => MorphProgressIndicator.linearWavy(
      value: v,
      linearSize: linearSize,
      showTrack: track,
    ),
  };
  return StageCenter(
    child: SizedBox(
      width: kind == _ProgressKind.linear || kind == _ProgressKind.linearWavy
          ? 400
          : null,
      child: indicator,
    ),
  );
}

@widgetbook.UseCase(
  name: 'All types',
  type: MorphProgressIndicator,
  path: '[Feedback]/Progress',
)
Widget progressTypesUseCase(BuildContext context) {
  final value = context.knobs.double.slider(
    label: 'value',
    initialValue: 0.6,
    min: 0,
    max: 1,
    divisions: 20,
    precision: 2,
  );
  return Stage(
    children: [
      StageSection(
        title: 'Circular',
        child: StageWrap(
          spacing: 28,
          children: [
            MorphProgressIndicator.circular(value: value, size: 48),
            MorphProgressIndicator.circularWavy(value: value, size: 48),
            const MorphLoadingIndicator(size: 48),
          ],
        ),
      ),
      StageSection(
        title: 'Linear',
        child: SizedBox(
          width: 420,
          child: Column(
            children: [
              for (final size in MorphProgressIndicatorSize.values) ...[
                MorphProgressIndicator.linear(value: value, linearSize: size),
                const SizedBox(height: 16),
                MorphProgressIndicator.linearWavy(
                  value: value,
                  linearSize: size,
                ),
                const SizedBox(height: 16),
              ],
            ],
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Skeleton',
  type: MorphSkeleton,
  path: '[Feedback]/Skeleton',
)
Widget skeletonUseCase(BuildContext context) {
  final loading = context.knobs.boolean(label: 'loading', initialValue: true);
  final effect = enumKnob<MorphSkeletonEffect>(
    context,
    label: 'effect',
    values: MorphSkeletonEffect.values,
  );
  final direction = enumKnob<MorphShimmerDirection>(
    context,
    label: 'direction',
    values: MorphShimmerDirection.values,
  );
  final intensity = context.knobs.double.slider(
    label: 'intensity',
    initialValue: 0.5,
    min: 0,
    max: 1,
    divisions: 20,
    precision: 2,
  );
  return Stage(
    children: [
      SizedBox(
        width: 380,
        child: MorphSkeletonGroup(
          loading: loading,
          effect: effect,
          direction: direction,
          intensity: intensity,
          semanticLabel: 'Loading content',
          placeholder: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const MorphSkeleton.image(),
              const SizedBox(height: 16),
              Row(
                children: [
                  const MorphSkeleton.avatar(),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        MorphSkeleton.line(width: 160),
                        SizedBox(height: 8),
                        MorphSkeleton.line(),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 180, child: DemoImage(index: 1)),
              const SizedBox(height: 16),
              Row(
                children: [
                  const CircleAvatar(child: Text('M')),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Loaded headline'),
                      Text('Loaded supporting text'),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ],
  );
}
