import 'package:material_ui/material_ui.dart'
    show
        BorderRadius,
        BorderSide,
        BoxDecoration,
        BuildContext,
        Canvas,
        Center,
        Color,
        CustomPaint,
        CustomPainter,
        DecoratedBox,
        EdgeInsets,
        LinearGradient,
        Offset,
        Padding,
        Paint,
        Size,
        SizedBox,
        Stack,
        StackFit,
        Text,
        TextStyle,
        Widget,
        Wrap,
        WrapAlignment;
import 'package:morph_expressive/morph_expressive.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../utilities/lab_hosts.dart';
import '../../utilities/stage.dart';

const _path = '[Foundations]/Surfaces';

@widgetbook.UseCase(
  name: 'Frosted surface playground',
  type: MorphSurfaceGlass,
  path: _path,
)
Widget frostedSurfacePlaygroundUseCase(BuildContext context) {
  final base = MorphTheme.of(context);
  final scheme = base.colorScheme;
  final enabled = context.knobs.boolean(label: 'enabled', initialValue: true);
  final blur = context.knobs.double.slider(
    label: 'blur',
    initialValue: 14,
    min: 0,
    max: 40,
  );
  final tint = context.knobs.double.slider(
    label: 'tint opacity',
    initialValue: 0.55,
    min: 0,
    max: 1,
    divisions: 20,
    precision: 2,
  );
  final borderWidth = context.knobs.double.slider(
    label: 'border width',
    initialValue: 1,
    min: 0,
    max: 4,
    divisions: 8,
  );
  final glass = MorphSurfaceGlass(
    enabled: enabled,
    blurX: blur,
    blurY: blur,
    tintOpacity: tint,
    borderColor: scheme.outline,
    borderWidth: borderWidth,
  );
  // The theme's floatingSurfaceGlass is what MorphSurface.frosted components
  // resolve when they have no explicit glass.
  return MorphTheme(
    data: base.copyWith(floatingSurfaceGlass: glass),
    child: SizedBox.expand(
      child: Stack(
        fit: StackFit.expand,
        children: [
          // The backdrop belongs to the use case so blur is always judged
          // against detailed content, whatever the Background addon shows.
          CustomPaint(
            painter: _StripesPainter(
              colors: [
                scheme.primary,
                scheme.tertiary,
                scheme.secondary,
                scheme.error,
              ],
            ),
          ),
          Center(
            child: Wrap(
              spacing: 16,
              runSpacing: 16,
              alignment: WrapAlignment.center,
              children: [
                for (final variant in <MorphVariant?>[
                  null,
                  MorphVariant.primary,
                  MorphVariant.tertiary,
                ])
                  MorphButton.tonal(
                    surface: MorphSurface.frosted,
                    variant: variant,
                    onPressed: () {},
                    label: Text('Frosted ${variant?.name ?? 'default'}'),
                  ),
                MorphButton.outlined(
                  surface: MorphSurface.frosted,
                  onPressed: () {},
                  label: const Text('Frosted outlined'),
                ),
                MorphCard.filled(
                  surface: MorphSurface.frosted,
                  width: 240,
                  child: const Padding(
                    padding: EdgeInsets.all(20),
                    child: Text('Frosted card'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _StripesPainter extends CustomPainter {
  const _StripesPainter({required this.colors});

  final List<Color> colors;

  @override
  void paint(Canvas canvas, Size size) {
    const step = 22.0;
    var i = 0;
    for (var x = -size.height; x < size.width; x += step) {
      final paint = Paint()
        ..color = colors[i++ % colors.length]
        ..strokeWidth = step * 0.6;
      canvas.drawLine(
        Offset(x, size.height),
        Offset(x + size.height, 0),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_StripesPainter oldDelegate) =>
      oldDelegate.colors != colors;
}

@widgetbook.UseCase(
  name: 'Frosted surfaces lab',
  type: MorphSurface,
  path: _path,
)
Widget frostedSurfacesLabUseCase(BuildContext context) =>
    const MobileLabHost(kind: MobileLabKind.frostedSurfaces);

@widgetbook.UseCase(
  name: 'Scroll blur compatibility lab',
  type: MorphScrollBehavior,
  path: _path,
)
Widget scrollBlurLabUseCase(BuildContext context) =>
    const MobileLabHost(kind: MobileLabKind.scrollBlur);

@widgetbook.UseCase(
  name: 'Rounded surface',
  type: MorphRoundedSurface,
  path: _path,
)
Widget roundedSurfaceUseCase(BuildContext context) {
  final scheme = MorphTheme.of(context).colorScheme;
  final width = context.knobs.double.slider(
    label: 'width',
    initialValue: 240,
    min: 80,
    max: 400,
  );
  final height = context.knobs.double.slider(
    label: 'height',
    initialValue: 140,
    min: 60,
    max: 300,
  );
  final radius = context.knobs.double.slider(
    label: 'radius',
    initialValue: 32,
    min: 0,
    max: 80,
  );
  final elevation = context.knobs.double.slider(
    label: 'elevation',
    initialValue: 4,
    min: 0,
    max: 24,
  );
  final outline = context.knobs.boolean(label: 'outline');
  final gradient = context.knobs.boolean(label: 'gradient fill');
  return StageCenter(
    child: MorphRoundedSurface(
      size: Size(width, height),
      radius: radius,
      color: scheme.primaryContainer,
      gradient: gradient
          ? LinearGradient(colors: [scheme.primary, scheme.tertiary])
          : null,
      side: outline ? BorderSide(color: scheme.outline, width: 2) : null,
      elevation: elevation,
      child: Center(
        child: Text(
          'MorphRoundedSurface',
          style: TextStyle(color: scheme.onPrimaryContainer),
        ),
      ),
    ),
  );
}

@widgetbook.UseCase(name: 'Liquid unfold', type: MorphLiquidUnfold, path: _path)
Widget liquidUnfoldUseCase(BuildContext context) {
  final scheme = MorphTheme.of(context).colorScheme;
  final progress = context.knobs.double.slider(
    label: 'progress',
    initialValue: 1,
    min: 0,
    max: 1,
    divisions: 50,
    precision: 2,
  );
  final intensity = context.knobs.double.slider(
    label: 'intensity',
    initialValue: 0.35,
    min: 0,
    max: 1,
    divisions: 20,
    precision: 2,
  );
  final above = context.knobs.boolean(label: 'opens above');
  final radius = context.knobs.double.slider(
    label: 'radius',
    initialValue: 24,
    min: 0,
    max: 48,
  );
  return StageCenter(
    child: SizedBox(
      width: 280,
      height: 200,
      child: MorphLiquidUnfold(
        progress: progress,
        opensAbove: above,
        intensity: intensity,
        radius: radius,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: scheme.secondaryContainer,
            borderRadius: BorderRadius.circular(radius),
          ),
          child: Center(
            child: Text(
              'Unfolding surface',
              style: TextStyle(color: scheme.onSecondaryContainer),
            ),
          ),
        ),
      ),
    ),
  );
}
