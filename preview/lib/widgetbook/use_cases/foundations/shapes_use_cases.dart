import 'package:material_ui/material_ui.dart'
    show BuildContext, Center, LinearGradient, Size, Text, TextStyle, Widget;
import 'package:morph_expressive/morph_expressive.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../../shape_morph_lab.dart';
import '../../utilities/knobs.dart';
import '../../utilities/stage.dart';

const _path = '[Foundations]/Shapes';

@widgetbook.UseCase(
  name: 'Shape catalog',
  type: MorphShapeContainer,
  path: _path,
)
Widget shapeCatalogUseCase(BuildContext context) {
  final scheme = MorphTheme.of(context).colorScheme;
  final size = context.knobs.double.slider(
    label: 'size',
    initialValue: 88,
    min: 40,
    max: 160,
  );
  final filled = context.knobs.boolean(label: 'filled', initialValue: true);
  final kinds = MorphShapeKind.values;
  return Stage(
    children: [
      StageSection(
        title: '${kinds.length} MorphShapeKind values',
        note: 'Each cell is a real MorphShapeContainer.',
        child: StageWrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            for (final kind in kinds)
              StageCell(
                caption: kind.name,
                child: MorphShapeContainer(
                  kind: kind,
                  width: size,
                  height: size,
                  color: filled ? scheme.primaryContainer : scheme.tertiary,
                  child: Center(
                    child: Text(
                      kind.index.toString(),
                      style: TextStyle(color: scheme.onPrimaryContainer),
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

@widgetbook.UseCase(
  name: 'Shape container playground',
  type: MorphShapeContainer,
  path: _path,
)
Widget shapeContainerPlaygroundUseCase(BuildContext context) {
  final scheme = MorphTheme.of(context).colorScheme;
  final kind = enumKnob<MorphShapeKind>(
    context,
    label: 'kind',
    values: MorphShapeKind.values,
    initial: MorphShapeKind.cookie7Sided,
  );
  final width = context.knobs.double.slider(
    label: 'width',
    initialValue: 180,
    min: 60,
    max: 320,
  );
  final height = context.knobs.double.slider(
    label: 'height',
    initialValue: 180,
    min: 60,
    max: 320,
  );
  final gradient = context.knobs.boolean(label: 'gradient');
  return StageCenter(
    child: MorphShapeContainer(
      kind: kind,
      width: width,
      height: height,
      color: gradient ? null : scheme.primary,
      gradient: gradient
          ? LinearGradient(colors: [scheme.primary, scheme.tertiary])
          : null,
      child: Center(
        child: Text(kind.name, style: TextStyle(color: scheme.onPrimary)),
      ),
    ),
  );
}

@widgetbook.UseCase(
  name: 'Shape and interaction lab',
  type: MorphShapeKind,
  path: _path,
)
Widget shapeMorphLabUseCase(BuildContext context) => const ShapeMorphLab();

@widgetbook.UseCase(name: 'Shape view morph', type: MorphShapeView, path: _path)
Widget shapeViewUseCase(BuildContext context) {
  final scheme = MorphTheme.of(context).colorScheme;
  final from = enumKnob<MorphShapeKind>(
    context,
    label: 'from',
    values: MorphShapeKind.values,
    initial: MorphShapeKind.cookie7Sided,
  );
  final to = enumKnob<MorphShapeKind>(
    context,
    label: 'to',
    values: MorphShapeKind.values,
    initial: MorphShapeKind.softBurst,
  );
  final progress = context.knobs.double.slider(
    label: 'progress',
    initialValue: 0.5,
    min: 0,
    max: 1,
    divisions: 50,
    precision: 2,
  );
  final rotation = context.knobs.double.slider(
    label: 'rotation (rad)',
    initialValue: 0,
    min: 0,
    max: 6.28,
  );
  final size = context.knobs.double.slider(
    label: 'size',
    initialValue: 200,
    min: 80,
    max: 360,
  );
  final renderer = enumKnob<MorphShapeRenderer>(
    context,
    label: 'renderer',
    values: MorphShapeRenderer.values,
    initial: MorphShapeRenderer.canvas,
  );
  return StageCenter(
    child: MorphShapeView(
      shape: MorphShapeCatalog.fromKind(from),
      targetShape: MorphShapeCatalog.fromKind(to),
      progress: progress,
      rotationRadians: rotation,
      size: Size(size, size),
      color: scheme.primary,
      renderer: renderer,
    ),
  );
}
