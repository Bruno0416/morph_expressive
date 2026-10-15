import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../../../foundations/foundations.dart';
import '../styles/morph_slider_theme.dart';
import '../../tooltips/components/morph_tooltip_plain_surface.dart';

/// Floating value label that shares MorphTooltip's surface and typography.
class MorphSliderValueIndicator extends StatelessWidget {
  const MorphSliderValueIndicator({
    required this.label,
    required this.colors,
    super.key,
  });

  final String label;
  final MorphSliderColors colors;

  /// Measure the pill including MorphTooltip's padding. The configured
  /// valueIndicatorWidth is a minimum, not a hard width that clips labels.
  static double widthFor(
    BuildContext context,
    String label,
    MorphSliderTheme sliderTheme,
  ) {
    final theme = MorphTheme.of(context);
    final tooltip = theme.tooltipTheme;
    final text = TextPainter(
      text: TextSpan(
        text: label,
        style: tooltip.plainMessageStyle(theme.typeScale, theme.colorScheme),
      ),
      maxLines: 1,
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
    )..layout(maxWidth: tooltip.plainMaxWidth);
    final desired = text.width + tooltip.plainPadding.horizontal + 2;
    text.dispose();
    return math.min(
      tooltip.plainMaxWidth,
      math.max(sliderTheme.valueIndicatorWidth, desired),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sliderTheme = MorphTheme.of(context).sliderTheme;
    return SizedBox(
      width: widthFor(context, label, sliderTheme),
      height: sliderTheme.valueIndicatorHeight,
      child: Center(child: MorphTooltipPlainSurface(message: label)),
    );
  }
}
