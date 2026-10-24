import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:material_ui/material_ui.dart' show MaterialLocalizations;
import 'package:motor/motor.dart';

import '../../foundations/foundations.dart';
import '../navigation_rail/components/morph_sliding_indicator.dart';

/// Geometry used when a page becomes selected.
enum MorphPageIndicatorEffect {
  /// Fixed slots; one elastic pill travels between them.
  slide,

  /// Inactive dots expand to the active dimensions as selection travels.
  expand,
}

/// Onboarding/page dots with an elastic shared indicator.
///
/// Equal active/inactive dimensions give equal pills. A wider [activeWidth]
/// produces a capsule; smaller inactive dimensions produce expanding dots.
/// Null [onPageSelected] makes the indicator informational. Interactive dots
/// retain a minimum 48x48 target, independent of their visual dimensions.
class MorphPageIndicator extends StatelessWidget {
  const MorphPageIndicator({
    required this.count,
    required this.selectedIndex,
    this.onPageSelected,
    this.effect = MorphPageIndicatorEffect.expand,
    this.activeWidth = 40,
    this.inactiveWidth = 16,
    this.height = 16,
    this.inactiveHeight,
    this.spacing = 6,
    this.activeColor,
    this.inactiveColor,
    this.spring = MorphMotion.navigationSelection,
    this.selectionDelay,
    this.semanticLabelBuilder,
    super.key,
  }) : assert(count > 0),
       assert(selectedIndex >= 0 && selectedIndex < count),
       assert(activeWidth > 0),
       assert(inactiveWidth > 0),
       assert(height > 0),
       assert(inactiveHeight == null || inactiveHeight > 0),
       assert(spacing >= 0);

  final int count;
  final int selectedIndex;
  final ValueChanged<int>? onPageSelected;
  final MorphPageIndicatorEffect effect;
  final double activeWidth;
  final double inactiveWidth;
  final double height;
  final double? inactiveHeight;
  final double spacing;
  final Color? activeColor;
  final Color? inactiveColor;
  final MorphSpring spring;

  /// Optional trailing-edge pause for page selection. Defaults to 60ms.
  final Duration? selectionDelay;

  /// Localized override; receives the zero-based index and page count.
  final String Function(int index, int count)? semanticLabelBuilder;

  @override
  Widget build(BuildContext context) {
    final scheme = MorphTheme.of(context).colorScheme;
    final active = activeColor ?? scheme.primary;
    final inactive =
        inactiveColor ?? scheme.onSurfaceVariant.withValues(alpha: 0.5);
    return MorphComponentTheme(
      builder: (context) => MorphSlidingIndicator(
        leadSpring: spring,
        selectionDelay: selectionDelay,
        foreground: true,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: spacing,
          children: [
            for (var i = 0; i < count; i++)
              SingleMotionBuilder(
                key: ValueKey(i),
                motion: MorphMotion.springMotion(spring),
                value: i == selectedIndex ? 1.0 : 0.0,
                active: !MorphMotion.reduceMotionOf(context),
                builder: (context, value, child) {
                  final t = value.clamp(0.0, 1.0);
                  final width =
                      inactiveWidth + (activeWidth - inactiveWidth) * t;
                  final smallHeight = inactiveHeight ?? height;
                  final dotHeight = smallHeight + (height - smallHeight) * t;
                  final slotWidth = effect == MorphPageIndicatorEffect.slide
                      ? math.max(activeWidth, inactiveWidth)
                      : width;
                  final label =
                      semanticLabelBuilder?.call(i, count) ??
                      MaterialLocalizations.of(context)
                          .tabLabel(tabIndex: i + 1, tabCount: count);
                  Widget dot = SizedBox(
                    width: onPageSelected == null
                        ? slotWidth
                        : math.max(48, slotWidth),
                    height: onPageSelected == null
                        ? math.max(height, smallHeight)
                        : math.max(48, math.max(height, smallHeight)),
                    child: Center(
                      child: SizedBox(
                        width: width,
                        height: dotHeight,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            DecoratedBox(
                              decoration: BoxDecoration(
                                color: inactive,
                                borderRadius: BorderRadius.circular(1000),
                              ),
                            ),
                            MorphIndicatorTarget(
                              selected: i == selectedIndex,
                              decoration: BoxDecoration(
                                color: active,
                                borderRadius: BorderRadius.circular(1000),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                  final callback = onPageSelected;
                  if (callback != null) {
                    final visual = dot;
                    dot = MorphTappable(
                      onTap: () => callback(i),
                      semanticButton: false,
                      excludeSemantics: true,
                      builder: (context, state) => visual,
                    );
                  }
                  return Semantics(
                    label: label,
                    selected: i == selectedIndex,
                    button: callback != null,
                    onTap: callback == null ? null : () => callback(i),
                    child: ExcludeSemantics(child: dot),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
