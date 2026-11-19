import 'package:material_ui/material_ui.dart'
    show
        BuildContext,
        Center,
        Column,
        Icon,
        IconData,
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

@widgetbook.UseCase(
  name: 'Playground',
  type: MorphShapeButton,
  path: '[Actions]/Shape Buttons',
)
Widget shapeButtonPlaygroundUseCase(BuildContext context) {
  final kind = enumKnob<MorphShapeKind>(
    context,
    label: 'shape',
    values: MorphShapeKind.values,
    initial: MorphShapeKind.cookie7Sided,
  );
  final pressedKind = enumKnob<MorphShapeKind>(
    context,
    label: 'pressed shape',
    values: MorphShapeKind.values,
    initial: MorphShapeKind.softBurst,
  );
  final size = context.knobs.double.slider(
    label: 'size',
    initialValue: 96,
    min: 40,
    max: 200,
  );
  final rotate = context.knobs.boolean(label: 'rotate');
  final pressedScale = context.knobs.double.slider(
    label: 'pressed scale',
    initialValue: 0.96,
    min: 0.8,
    max: 1,
    divisions: 20,
    precision: 2,
  );
  final usePressedShape = context.knobs.boolean(label: 'morph on press');
  final enabled = context.knobs.boolean(label: 'enabled', initialValue: true);
  final icon = iconKnob(context, initial: 'heart');
  final variant = variantKnob(context);
  return _ShapeButtonHarness(
    kind: kind,
    pressedKind: usePressedShape ? pressedKind : null,
    size: size,
    rotate: rotate,
    pressedScale: pressedScale,
    enabled: enabled,
    icon: icon,
    variant: variant,
  );
}

class _ShapeButtonHarness extends StatefulWidget {
  const _ShapeButtonHarness({
    required this.kind,
    required this.pressedKind,
    required this.size,
    required this.rotate,
    required this.pressedScale,
    required this.enabled,
    required this.icon,
    required this.variant,
  });

  final MorphShapeKind kind;
  final MorphShapeKind? pressedKind;
  final double size;
  final bool rotate;
  final double pressedScale;
  final bool enabled;
  final IconData icon;
  final MorphVariant? variant;

  @override
  State<_ShapeButtonHarness> createState() => _ShapeButtonHarnessState();
}

class _ShapeButtonHarnessState extends State<_ShapeButtonHarness> {
  int _taps = 0;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          MorphShapeButton(
            size: widget.size,
            shape: MorphShapeCatalog.fromKind(widget.kind),
            pressedShape: widget.pressedKind == null
                ? null
                : MorphShapeCatalog.fromKind(widget.pressedKind!),
            rotationEnabled: widget.rotate,
            pressedScale: widget.pressedScale,
            enabled: widget.enabled,
            variant: widget.variant,
            tooltip: 'Shape button',
            semanticLabel: 'Shape button',
            onPressed: () => setState(() => _taps++),
            child: Icon(widget.icon),
          ),
          const SizedBox(height: 16),
          DemoReadout('Tapped $_taps times'),
        ],
      ),
    );
  }
}
