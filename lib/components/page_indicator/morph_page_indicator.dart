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
class MorphPageIndicator extends StatefulWidget {
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
  State<MorphPageIndicator> createState() => _MorphPageIndicatorState();
}

class _MorphPageIndicatorState extends State<MorphPageIndicator> {
  final List<FocusNode> _focusNodes = <FocusNode>[];

  void _syncFocusNodes() {
    while (_focusNodes.length < widget.count) {
      _focusNodes.add(
        FocusNode(debugLabel: 'Morph page ${_focusNodes.length}'),
      );
    }
    while (_focusNodes.length > widget.count) {
      _focusNodes.removeLast().dispose();
    }
  }

  @override
  void initState() {
    super.initState();
    _syncFocusNodes();
  }

  @override
  void didUpdateWidget(MorphPageIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.count != widget.count) _syncFocusNodes();
  }

  @override
  void dispose() {
    for (final node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final count = widget.count;
    final selectedIndex = widget.selectedIndex;
    final activeColor = widget.activeColor;
    final inactiveColor = widget.inactiveColor;
    final activeWidth = widget.activeWidth;
    final inactiveWidth = widget.inactiveWidth;
    final height = widget.height;
    final inactiveHeight = widget.inactiveHeight;
    final spacing = widget.spacing;
    final effect = widget.effect;
    final spring = widget.spring;
    final selectionDelay = widget.selectionDelay;
    final semanticLabelBuilder = widget.semanticLabelBuilder;
    final onPageSelected = widget.onPageSelected;
    final scheme = MorphTheme.of(context).colorScheme;
    final active = activeColor ?? scheme.primary;
    final inactive =
        inactiveColor ?? scheme.onSurfaceVariant.withValues(alpha: 0.5);
    final interactive = onPageSelected != null;
    final smallHeight = inactiveHeight ?? height;
    final maxHeight = math.max(height, smallHeight);
    final fixedWidth = math.max(activeWidth, inactiveWidth);
    // The *visual* gap, not the touch target width, defines dot spacing.
    // Interactive semantics remain 48x48 in a separate overlay; one shared
    // gesture handler chooses the nearest dot in overlapping hit regions.
    final slotWidths = <double>[
      for (var i = 0; i < count; i++)
        effect == MorphPageIndicatorEffect.slide
            ? fixedWidth
            : i == selectedIndex
            ? activeWidth
            : inactiveWidth,
    ];
    final trackWidth =
        slotWidths.fold<double>(0, (sum, width) => sum + width) +
        spacing * (count - 1);
    final centers = <double>[];
    var cursor = 0.0;
    for (final slot in slotWidths) {
      centers.add(cursor + slot / 2);
      cursor += slot + spacing;
    }
    final rtl = Directionality.of(context) == TextDirection.rtl;
    double centerOf(int i) => rtl ? trackWidth - centers[i] : centers[i];

    final visual = MorphSlidingIndicator(
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
                final width = inactiveWidth + (activeWidth - inactiveWidth) * t;
                final dotHeight = smallHeight + (height - smallHeight) * t;
                final slotWidth = effect == MorphPageIndicatorEffect.slide
                    ? fixedWidth
                    : width;
                final dot = SizedBox(
                  width: slotWidth,
                  height: maxHeight,
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
                if (interactive) return dot;
                return Semantics(
                  label:
                      semanticLabelBuilder?.call(i, count) ??
                      MaterialLocalizations.of(context)
                          .tabLabel(tabIndex: i + 1, tabCount: count),
                  selected: i == selectedIndex,
                  child: ExcludeSemantics(child: dot),
                );
              },
            ),
        ],
      ),
    );
    if (!interactive) {
      return MorphComponentTheme(builder: (context) => visual);
    }

    final onSelected = onPageSelected;
    // Padding gives the first/last semantic targets their full 48px width.
    // Hit testing is centralized, because targets would otherwise overlap
    // when dots are closer than 48px and intercept neighboring selections.
    return MorphComponentTheme(
      builder: (context) => GestureDetector(
        excludeFromSemantics: true,
        behavior: HitTestBehavior.opaque,
        onTapUp: (details) {
          final dx = details.localPosition.dx - 24;
          var nearest = 0;
          var distance = double.infinity;
          for (var i = 0; i < count; i++) {
            final next = (centerOf(i) - dx).abs();
            if (next < distance) {
              nearest = i;
              distance = next;
            }
          }
          _focusNodes[nearest].requestFocus();
          onSelected(nearest);
        },
        child: SizedBox(
          width: trackWidth + 48,
          height: math.max(48, maxHeight),
          child: Stack(
            clipBehavior: Clip.none,
            children: <Widget>[
              Positioned(
                left: 24,
                top: (math.max(48, maxHeight) - maxHeight) / 2,
                child: visual,
              ),
              for (var i = 0; i < count; i++)
                Positioned(
                  left: centerOf(i),
                  top: (math.max(48, maxHeight) - 48) / 2,
                  child: Semantics(
                    label:
                        semanticLabelBuilder?.call(i, count) ??
                        MaterialLocalizations.of(context)
                            .tabLabel(tabIndex: i + 1, tabCount: count),
                    selected: i == selectedIndex,
                    button: true,
                    onTap: () {
                      _focusNodes[i].requestFocus();
                      onSelected(i);
                    },
                    child: ExcludeSemantics(
                      child: IgnorePointer(
                        child: MorphTappable(
                          focusNode: _focusNodes[i],
                          onTap: () => onSelected(i),
                          semanticButton: false,
                          excludeSemantics: true,
                          trackHover: false,
                          focusOverlay: false,
                          builder: (context, state) =>
                              const SizedBox(width: 48, height: 48),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
