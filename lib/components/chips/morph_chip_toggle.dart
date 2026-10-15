import 'package:gap/gap.dart';
import 'package:material_ui/material_ui.dart';
import 'package:motor/motor.dart';

import '../../foundations/foundations.dart';

// ---------- opciones ----------
class MorphChipToggleOption<T> {
  const MorphChipToggleOption({required this.value, required this.label, this.icon});

  final T value;
  final String label;
  final IconData? icon;
}

// ---------- selector animado de chips ----------
class MorphChipToggle<T> extends StatefulWidget {
  final List<MorphChipToggleOption<T>> options;
  final T selected;
  final ValueChanged<T> onChanged;

  final String? label;

  final Duration duration;
  final Curve curve;

  final Duration stretchDelay;

  final double height;

  /// Incremento de tamano del texto respecto al token tipografico.
  final double labelSizeBoost;

  /// Tamano del icono opcional de cada chip.
  final double iconSize;

  final double radius;

  final double? spacing;
  final double? horizontalPadding;

  final bool scrollable;

  final EdgeInsetsGeometry scrollPadding;

  const MorphChipToggle({
    super.key,
    required this.options,
    required this.selected,
    required this.onChanged,
    this.label,
    this.duration = MorphMotion.selectionDuration,
    this.curve = MorphMotion.standard,
    this.stretchDelay = MorphMotion.selectionStretchDelay,
    this.height = 40,
    this.labelSizeBoost = 1.5,
    this.iconSize = 20,
    this.radius = 20,
    this.spacing,
    this.horizontalPadding,
    this.scrollable = true,
    this.scrollPadding = EdgeInsets.zero,
  }) : assert(options.length >= 2);

  @override
  State<MorphChipToggle<T>> createState() => _MorphChipToggleState<T>();
}

class _MorphChipToggleState<T> extends State<MorphChipToggle<T>> {
  double _leftTarget = 0;
  double _rightTarget = 0;
  bool _initialized = false;

  int _indexOf(T value) {
    final i = widget.options.indexWhere((o) => o.value == value);
    return i < 0 ? 0 : i;
  }

  // --- helper privado ---
  double _chipWidth(
    BuildContext context,
    MorphChipToggleOption<T> option,
    TextStyle? style,
    EdgeInsets padding,
  ) {
    final painter = TextPainter(
      text: TextSpan(text: option.label, style: style),
      textDirection: TextDirection.ltr,
      textScaler: MediaQuery.textScalerOf(context),
      maxLines: 1,
    )..layout();

    var width = padding.horizontal + painter.width;
    if (option.icon != null) {
      width += widget.iconSize + 6;
    }
    return width;
  }

  (List<double>, List<double>) _computeBounds(
    BuildContext context,
    TextStyle? style,
    EdgeInsets padding,
    double spacing,
  ) {
    final widths = widget.options
        .map((o) => _chipWidth(context, o, style, padding))
        .toList(growable: false);

    final lefts = <double>[];
    var cursor = 0.0;
    for (final w in widths) {
      lefts.add(cursor);
      cursor += w + spacing;
    }
    return (widths, lefts);
  }

  (double, double) _boundsFor(
    int index,
    List<double> lefts,
    List<double> widths,
  ) => (lefts[index], lefts[index] + widths[index]);

  // --- helper privado ---
  void _syncTargets(List<double> lefts, List<double> widths) {
    if (_initialized) return;
    final (l, r) = _boundsFor(_indexOf(widget.selected), lefts, widths);
    _leftTarget = l;
    _rightTarget = r;
    _initialized = true;
  }

  ({TextStyle? style, EdgeInsets padding, double spacing}) _resolveTokens(
    BuildContext context,
  ) {
    final hPad = widget.horizontalPadding ?? MorphTheme.of(context).spacing.lg;
    return (
      style: MorphTheme.of(context).typeScale.labelLarge.copyWith(
        fontSize: (MorphTheme.of(context).typeScale.labelLarge.fontSize ?? 14) + widget.labelSizeBoost,
        fontWeight: FontWeight.w600,
      ),
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: hPad / 2),
      spacing: widget.spacing ?? MorphTheme.of(context).spacing.md,
    );
  }

  @override
  void didUpdateWidget(covariant MorphChipToggle<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selected == widget.selected) return;

    final tokens = _resolveTokens(context);
    final (widths, lefts) = _computeBounds(
      context,
      tokens.style,
      tokens.padding,
      tokens.spacing,
    );

    _animate(
      from: _indexOf(oldWidget.selected),
      to: _indexOf(widget.selected),
      lefts: lefts,
      widths: widths,
    );
  }

  // --- helper privado ---
  void _animate({
    required int from,
    required int to,
    required List<double> lefts,
    required List<double> widths,
  }) {
    final (fromLeft, _) = _boundsFor(from, lefts, widths);
    final (toLeft, toRight) = _boundsFor(to, lefts, widths);
    final movingRight = toLeft > fromLeft;

    setState(() {
      if (movingRight) {
        _rightTarget = toRight;
      } else {
        _leftTarget = toLeft;
      }
    });

    Future.delayed(widget.stretchDelay, () {
      if (!mounted) return;
      setState(() {
        if (movingRight) {
          _leftTarget = toLeft;
        } else {
          _rightTarget = toRight;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = MorphTheme.of(context).colorScheme;
    final motion = Motion.curved(widget.duration, MorphMotion.subtleOvershoot);
    final selectedIndex = _indexOf(widget.selected);

    final tokens = _resolveTokens(context);
    final (widths, lefts) = _computeBounds(
      context,
      tokens.style,
      tokens.padding,
      tokens.spacing,
    );
    _syncTargets(lefts, widths);

    final totalWidth = widths.isEmpty ? 0.0 : lefts.last + widths.last;

    final control = SizedBox(
      height: widget.height,
      width: totalWidth,
      child: SingleMotionBuilder(
        motion: motion,
        value: _leftTarget,
        builder: (context, left, _) => SingleMotionBuilder(
          motion: motion,
          value: _rightTarget,
          builder: (context, right, _) {
            final pillLeft = left;
            final pillWidth = (right - left).clamp(0.0, totalWidth).toDouble();

            return Stack(
              children: [
                // 1. construir la base del selector
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (var i = 0; i < widget.options.length; i++) ...[
                      if (i > 0) Gap(tokens.spacing),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: colors.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(widget.radius),
                        ),
                        child: SizedBox(
                          width: widths[i],
                          height: widget.height,
                        ),
                      ),
                    ],
                  ],
                ),

                // 2. posicionar el indicador animado
                Positioned(
                  left: pillLeft,
                  top: 0,
                  width: pillWidth,
                  height: widget.height,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: colors.primary,
                      borderRadius: BorderRadius.circular(widget.radius),
                    ),
                  ),
                ),

                // 3. dibujar las etiquetas e iconos
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (var i = 0; i < widget.options.length; i++) ...[
                      if (i > 0) Gap(tokens.spacing),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => widget.onChanged(widget.options[i].value),
                        child: SizedBox(
                          width: widths[i],
                          height: widget.height,
                          child: _Chip<T>(
                            option: widget.options[i],
                            selected: i == selectedIndex,
                            padding: tokens.padding,
                            duration: widget.duration,
                            curve: widget.curve,
                            labelStyle: tokens.style,
                            iconSize: widget.iconSize,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(widget.label!, style: MorphTheme.of(context).typeScale.labelMedium),
          Gap(MorphTheme.of(context).spacing.md),
        ],
        widget.scrollable
            ? SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: widget.scrollPadding,
                child: control,
              )
            : control,
      ],
    );
  }
}

class _Chip<T> extends StatelessWidget {
  const _Chip({
    required this.option,
    required this.selected,
    required this.padding,
    required this.duration,
    required this.curve,
    required this.labelStyle,
    required this.iconSize,
  });

  final MorphChipToggleOption<T> option;
  final bool selected;
  final EdgeInsets padding;
  final Duration duration;
  final Curve curve;
  final TextStyle? labelStyle;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final colors = MorphTheme.of(context).colorScheme;
    final target = selected ? colors.onPrimary : colors.onSurfaceVariant;

    return Padding(
      padding: padding,
      child: Center(
        child: TweenAnimationBuilder<Color?>(
          duration: duration,
          curve: curve,
          tween: ColorTween(end: target),
          builder: (context, color, _) {
            final c = color ?? target;
            return Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (option.icon != null) ...[
                  Icon(option.icon, size: iconSize, color: c),
                  const Gap(6),
                ],
                Text(
                  option.label,
                  style: labelStyle?.copyWith(color: c),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
