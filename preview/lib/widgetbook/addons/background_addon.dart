import 'dart:math' as math;

import 'package:material_ui/material_ui.dart'
    show
        Alignment,
        BoxDecoration,
        Brightness,
        BuildContext,
        Canvas,
        Color,
        ColoredBox,
        CustomPaint,
        CustomPainter,
        DecoratedBox,
        DefaultTextStyle,
        LinearGradient,
        Offset,
        Paint,
        RRect,
        Radius,
        Rect,
        Size,
        StatelessWidget,
        TextStyle,
        Theme,
        Widget;
import 'package:widgetbook/widgetbook.dart';

/// Backdrops behind a use case, chosen to judge opaque and frosted surfaces.
enum MorphPreviewBackground {
  theme('Theme surface'),
  light('Light'),
  dark('Dark'),
  highContrast('High contrast'),
  colored('Colored'),
  gradient('Decorative gradient'),
  pattern('Image-like pattern');

  const MorphPreviewBackground(this.label);
  final String label;
}

/// Paints a [MorphPreviewBackground] behind the use case.
///
/// The addon sits inside the Morph scope, so [MorphPreviewBackground.theme] and
/// [MorphPreviewBackground.colored] follow the selected seed and brightness.
class MorphBackgroundAddon extends WidgetbookAddon<MorphPreviewBackground> {
  MorphBackgroundAddon() : super(name: 'Background');

  @override
  List<Field> get fields => [
    ObjectDropdownField<MorphPreviewBackground>(
      name: 'style',
      values: MorphPreviewBackground.values,
      initialValue: MorphPreviewBackground.theme,
      labelBuilder: (value) => value.label,
    ),
  ];

  @override
  MorphPreviewBackground valueFromQueryGroup(Map<String, String> group) =>
      valueOf<MorphPreviewBackground>('style', group) ??
      MorphPreviewBackground.theme;

  @override
  Widget buildUseCase(
    BuildContext context,
    Widget child,
    MorphPreviewBackground setting,
  ) => MorphBackdrop(style: setting, child: child);
}

/// Background widget used by [MorphBackgroundAddon].
class MorphBackdrop extends StatelessWidget {
  const MorphBackdrop({super.key, required this.style, required this.child});

  final MorphPreviewBackground style;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final dark = scheme.brightness == Brightness.dark;
    final Widget content = DefaultTextStyle.merge(
      style: TextStyle(
        color: switch (style) {
          MorphPreviewBackground.light => const Color(0xFF1B1B1F),
          MorphPreviewBackground.dark => const Color(0xFFE6E1E5),
          MorphPreviewBackground.highContrast =>
            dark ? const Color(0xFFFFFFFF) : const Color(0xFF000000),
          _ => null,
        },
      ),
      child: child,
    );
    return switch (style) {
      MorphPreviewBackground.theme => ColoredBox(
        color: scheme.surface,
        child: content,
      ),
      MorphPreviewBackground.light => ColoredBox(
        color: const Color(0xFFF7F5FA),
        child: content,
      ),
      MorphPreviewBackground.dark => ColoredBox(
        color: const Color(0xFF121014),
        child: content,
      ),
      MorphPreviewBackground.highContrast => ColoredBox(
        color: dark ? const Color(0xFF000000) : const Color(0xFFFFFFFF),
        child: content,
      ),
      MorphPreviewBackground.colored => ColoredBox(
        color: scheme.primaryContainer,
        child: content,
      ),
      MorphPreviewBackground.gradient => DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              scheme.primary,
              scheme.tertiary,
              scheme.secondaryContainer,
              scheme.primaryContainer,
            ],
          ),
        ),
        child: content,
      ),
      MorphPreviewBackground.pattern => CustomPaint(
        painter: _PatternPainter(
          base: scheme.surfaceContainerHighest,
          colors: [
            scheme.primary,
            scheme.tertiary,
            scheme.secondary,
            scheme.error,
          ],
        ),
        child: content,
      ),
    };
  }
}

/// Dense, high-frequency shapes so any backdrop blur is clearly visible.
class _PatternPainter extends CustomPainter {
  const _PatternPainter({required this.base, required this.colors});

  final Color base;
  final List<Color> colors;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = base);
    final random = math.Random(7);
    for (var i = 0; i < 70; i++) {
      final color = colors[i % colors.length].withValues(alpha: 0.85);
      final center = Offset(
        random.nextDouble() * size.width,
        random.nextDouble() * size.height,
      );
      final radius = 18 + random.nextDouble() * 56;
      if (i.isEven) {
        canvas.drawCircle(center, radius, Paint()..color = color);
      } else {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: center, width: radius * 2, height: radius),
            Radius.circular(radius / 3),
          ),
          Paint()..color = color,
        );
      }
    }
    final line = Paint()
      ..color = const Color(0x55000000)
      ..strokeWidth = 2;
    for (var x = 0.0; x < size.width; x += 28) {
      canvas.drawLine(Offset(x, 0), Offset(x + 40, size.height), line);
    }
  }

  @override
  bool shouldRepaint(_PatternPainter oldDelegate) =>
      oldDelegate.base != base || oldDelegate.colors != colors;
}
