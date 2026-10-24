import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:material_ui/material_ui.dart'
    show InkWell, Material, MaterialType;
import 'package:motor/motor.dart';

import '../../foundations/foundations.dart';

/// Una opcion inmutable del selector segmentado Morph.
@immutable
class MorphSegmentedToggleOption<T> {
  const MorphSegmentedToggleOption({
    required this.value,
    required this.label,
    this.icon,
  });

  final T value;
  final String label;
  final IconData? icon;
}

/// Selector exclusivo con una pildora que se estira hacia el destino antes
/// de desplazar el extremo opuesto. No comparte estado con MorphButtonGroup.
///
/// [selected] es controlado por el padre: [onChanged] debe actualizarlo.
class MorphSegmentedToggle<T> extends StatefulWidget {
  const MorphSegmentedToggle({
    super.key,
    required this.options,
    required this.selected,
    required this.onChanged,
    this.label,
    this.duration = MorphMotion.selectionDuration,
    this.curve = MorphMotion.spatial,
    this.stretchDelay = MorphMotion.selectionStretchDelay,
    this.height = 48,
    this.padding = 4,
    this.backgroundColor,
    this.selectedColor,
    this.selectedForegroundColor,
    this.unselectedForegroundColor,
  }) : assert(options.length >= 2),
       assert(height > 0),
       assert(padding >= 0 && padding * 2 < height);

  final List<MorphSegmentedToggleOption<T>> options;
  final T selected;
  final ValueChanged<T> onChanged;
  final String? label;
  final Duration duration;
  final Curve curve;
  final Duration stretchDelay;
  final double height;
  final double padding;
  final Color? backgroundColor;
  final Color? selectedColor;
  final Color? selectedForegroundColor;
  final Color? unselectedForegroundColor;

  @override
  State<MorphSegmentedToggle<T>> createState() =>
      _MorphSegmentedToggleState<T>();
}

class _MorphSegmentedToggleState<T> extends State<MorphSegmentedToggle<T>> {
  double _left = 0;
  double _right = 0;
  double? _width;
  Timer? _stretchTimer;

  int _indexOf(T value) =>
      widget.options.indexWhere((option) => option.value == value);

  void _align(double width) {
    _width = width;
    final index = _indexOf(widget.selected);
    if (index == -1) {
      throw FlutterError('MorphSegmentedToggle.selected must match an option.');
    }
    final segment = width / widget.options.length;
    _left = index * segment;
    _right = (index + 1) * segment;
  }

  @override
  void didUpdateWidget(covariant MorphSegmentedToggle<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    final changedOptions =
        oldWidget.options.length != widget.options.length ||
        !oldWidget.options.asMap().entries.every(
          (entry) => entry.value.value == widget.options[entry.key].value,
        );
    if (changedOptions) {
      _stretchTimer?.cancel();
      _width = null;
    } else if (oldWidget.selected != widget.selected) {
      _animateFrom(oldWidget.selected);
    }
  }

  void _animateFrom(T previous) {
    _stretchTimer?.cancel();
    final width = _width;
    if (width == null) return;
    final oldIndex = _indexOf(previous);
    final newIndex = _indexOf(widget.selected);
    if (newIndex == -1) {
      throw FlutterError('MorphSegmentedToggle.selected must match an option.');
    }
    final segment = width / widget.options.length;
    final targetLeft = newIndex * segment;
    final targetRight = (newIndex + 1) * segment;
    if (oldIndex == newIndex || MorphMotion.reduceMotionOf(context)) {
      setState(() {
        _left = targetLeft;
        _right = targetRight;
      });
      return;
    }
    final rightward = newIndex > oldIndex;
    setState(() {
      if (rightward) {
        _right = targetRight;
      } else {
        _left = targetLeft;
      }
    });
    _stretchTimer = Timer(widget.stretchDelay, () {
      if (!mounted) return;
      final currentWidth = _width;
      final currentIndex = _indexOf(widget.selected);
      if (currentWidth == null || currentIndex == -1) return;
      final step = currentWidth / widget.options.length;
      setState(() {
        if (rightward) {
          _left = currentIndex * step;
        } else {
          _right = (currentIndex + 1) * step;
        }
      });
    });
  }

  @override
  void dispose() {
    _stretchTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = MorphTheme.of(context);
    if (MorphMotion.reduceMotionOf(context)) {
      _stretchTimer?.cancel();
      if (_width != null) _align(_width!);
    }
    final scheme = theme.colorScheme;
    final radius = widget.height / 2;
    final innerRadius = (widget.height - widget.padding * 2) / 2;
    final index = _indexOf(widget.selected);
    if (index == -1) {
      throw FlutterError('MorphSegmentedToggle.selected must match an option.');
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.label != null) ...[
          Text(widget.label!, style: theme.textTheme.labelMedium),
          const SizedBox(height: 8),
        ],
        LayoutBuilder(
          builder: (context, constraints) {
            if (!constraints.hasBoundedWidth) {
              throw FlutterError('MorphSegmentedToggle needs a bounded width.');
            }
            final width = constraints.maxWidth;
            if (_width != width) _align(width);
            final motion = Motion.curved(widget.duration, widget.curve);
            return ClipRRect(
              borderRadius: BorderRadius.circular(radius),
              child: SizedBox(
                height: widget.height,
                child: ColoredBox(
                  color:
                      widget.backgroundColor ?? scheme.surfaceContainerHighest,
                  child: SingleMotionBuilder(
                    active: !MorphMotion.reduceMotionOf(context),
                    motion: motion,
                    value: _left,
                    builder: (context, left, _) => SingleMotionBuilder(
                      active: !MorphMotion.reduceMotionOf(context),
                      motion: motion,
                      value: _right,
                      builder: (context, right, _) => Stack(
                        children: [
                          Positioned(
                            left: left + widget.padding,
                            top: widget.padding,
                            height: widget.height - 2 * widget.padding,
                            width: (right - left - 2 * widget.padding)
                                .clamp(0.0, width)
                                .toDouble(),
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: widget.selectedColor ?? scheme.primary,
                                borderRadius: BorderRadius.circular(
                                  innerRadius,
                                ),
                              ),
                            ),
                          ),
                          Positioned.fill(
                            child: Material(
                              animationDuration: MorphMotion.durationOf(
                                context,
                                MorphMotion.short4,
                              ),
                              type: MaterialType.transparency,
                              child: Row(
                                children: [
                                  for (
                                    var i = 0;
                                    i < widget.options.length;
                                    i++
                                  )
                                    Expanded(
                                      child: Semantics(
                                        selected: i == index,
                                        button: true,
                                        child: InkWell(
                                          enableFeedback: false,
                                          borderRadius: BorderRadius.circular(
                                            innerRadius,
                                          ),
                                          onTap: () {
                                            MorphHaptics.triggerFor(context);
                                            widget.onChanged(
                                              widget.options[i].value,
                                            );
                                          },
                                          child: Center(
                                            child: _ToggleOption(
                                              option: widget.options[i],
                                              selected: i == index,
                                              duration: widget.duration,
                                              selectedColor:
                                                  widget
                                                      .selectedForegroundColor ??
                                                  scheme.onPrimary,
                                              unselectedColor:
                                                  widget
                                                      .unselectedForegroundColor ??
                                                  scheme.onSurfaceVariant,
                                              textStyle:
                                                  theme.textTheme.labelLarge,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _ToggleOption<T> extends StatelessWidget {
  const _ToggleOption({
    required this.option,
    required this.selected,
    required this.duration,
    required this.selectedColor,
    required this.unselectedColor,
    required this.textStyle,
  });

  final MorphSegmentedToggleOption<T> option;
  final bool selected;
  final Duration duration;
  final Color selectedColor;
  final Color unselectedColor;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<Color?>(
    duration: MorphMotion.durationOf(context, duration),
    curve: MorphMotion.standard,
    tween: ColorTween(end: selected ? selectedColor : unselectedColor),
    builder: (context, color, _) => Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (option.icon != null) ...[
          Icon(option.icon, size: 18, color: color),
          const SizedBox(width: 6),
        ],
        Flexible(
          child: Text(
            option.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textStyle?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );
}
