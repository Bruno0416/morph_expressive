import 'dart:async';

import 'package:gap/gap.dart';
import 'package:material_ui/material_ui.dart';
import 'package:motor/motor.dart';

import '../../foundations/foundations.dart';

/// An option in a [MorphChipToggle]. Values must be unique in the group.
class MorphChipToggleOption<T> {
  const MorphChipToggleOption({
    required this.value,
    required this.label,
    this.icon,
  });

  final T value;
  final String label;
  final IconData? icon;
}

/// Animated Morph selector: one moving pill, or independently morphing pills.
///
/// In single-selection mode use [selected] and [onChanged]. In multi-selection
/// mode set [multiSelection] and provide [selectedValues] and
/// [onSelectionChanged]. This widget is externally controlled in both modes.
class MorphChipToggle<T> extends StatefulWidget {
  const MorphChipToggle({
    super.key,
    required this.options,
    this.selected,
    this.onChanged,
    this.multiSelection = false,
    this.selectedValues,
    this.onSelectionChanged,
    this.label,
    this.duration = MorphMotion.chipDuration,
    this.curve = MorphMotion.standard,
    this.stretchDelay = MorphMotion.chipStretchDelay,
    this.height = 40,
    this.labelSizeBoost = 1.5,
    this.iconSize = 20,
    this.radius = 20,
    this.spacing,
    this.horizontalPadding,
    this.scrollable = true,
    this.scrollPadding = EdgeInsets.zero,
  }) : assert(options.length >= 2),
       assert(multiSelection || (selected != null && onChanged != null)),
       assert(
         !multiSelection ||
             (selectedValues != null && onSelectionChanged != null),
       );

  final List<MorphChipToggleOption<T>> options;
  final T? selected;
  final ValueChanged<T>? onChanged;

  /// Enables multiple independent pills instead of one moving indicator.
  final bool multiSelection;

  /// Externally controlled selection in multi-selection mode.
  final Set<T>? selectedValues;

  /// Returns a fresh immutable set whenever a chip is toggled.
  final ValueChanged<Set<T>>? onSelectionChanged;

  final String? label;
  final Duration duration;
  final Curve curve;
  final Duration stretchDelay;
  final double height;
  final double labelSizeBoost;
  final double iconSize;
  final double radius;
  final double? spacing;
  final double? horizontalPadding;
  final bool scrollable;
  final EdgeInsetsGeometry scrollPadding;

  @override
  State<MorphChipToggle<T>> createState() => _MorphChipToggleState<T>();
}

typedef _ChipBounds = ({double left, double right});

class _MorphChipToggleState<T> extends State<MorphChipToggle<T>> {
  double _leftTarget = 0;
  double _rightTarget = 0;
  bool _initialized = false;
  Timer? _singlePhase;

  Set<T> _previousSelections = <T>{};
  final Set<T> _exiting = <T>{};
  // Boundary transitions (empty <-> one) alone use circular bloom.
  final Set<T> _bloomEntries = <T>{};
  final Set<T> _bloomExits = <T>{};
  // Non-boundary chips borrow the nearest active pill, then stretch/move.
  final Map<T, _ChipBounds> _entryOrigins = <T, _ChipBounds>{};

  @override
  void initState() {
    super.initState();
    _previousSelections = Set<T>.of(widget.selectedValues ?? <T>{});
  }

  @override
  void dispose() {
    _singlePhase?.cancel();
    super.dispose();
  }

  int _indexOf(T value) => widget.options.indexWhere((o) => o.value == value);

  double _chipWidth(
    BuildContext context,
    MorphChipToggleOption<T> option,
    TextStyle? style,
    EdgeInsets padding,
  ) {
    final painter = TextPainter(
      text: TextSpan(text: option.label, style: style),
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
      maxLines: 1,
    )..layout();
    double width = padding.horizontal + painter.width;
    if (option.icon != null) width += widget.iconSize + 6;
    painter.dispose();
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
    double cursor = 0;
    for (final width in widths) {
      lefts.add(cursor);
      cursor += width + spacing;
    }
    if (Directionality.of(context) == TextDirection.rtl) {
      final double total = cursor - spacing;
      for (int i = 0; i < widths.length; i++) {
        lefts[i] = total - lefts[i] - widths[i];
      }
    }
    return (widths, lefts);
  }

  _ChipBounds _boundsFor(int index, List<double> lefts, List<double> widths) =>
      (left: lefts[index], right: lefts[index] + widths[index]);

  _ChipBounds? _findNearest(
    T value,
    Set<T> candidates,
    List<double> lefts,
    List<double> widths,
  ) {
    final index = _indexOf(value);
    if (index < 0) return null;
    final own = _boundsFor(index, lefts, widths);
    final center = (own.left + own.right) / 2;
    _ChipBounds? nearest;
    double smallest = double.infinity;
    for (var i = 0; i < widget.options.length; i++) {
      if (i == index || !candidates.contains(widget.options[i].value)) {
        continue;
      }
      final candidate = _boundsFor(i, lefts, widths);
      final distance = ((candidate.left + candidate.right) / 2 - center).abs();
      if (distance < smallest) {
        smallest = distance;
        nearest = candidate;
      }
    }
    return nearest;
  }

  void _syncSingle(List<double> lefts, List<double> widths) {
    if (_initialized || widget.selected == null) return;
    final int i = _indexOf(widget.selected as T);
    if (i < 0) return;
    final bounds = _boundsFor(i, lefts, widths);
    _leftTarget = bounds.left;
    _rightTarget = bounds.right;
    _initialized = true;
  }

  ({TextStyle? style, EdgeInsets padding, double spacing}) _resolveTokens(
    BuildContext context,
  ) {
    final theme = MorphTheme.of(context);
    final hPad = widget.horizontalPadding ?? theme.spacing.lg;
    return (
      style: theme.typeScale.labelLarge.copyWith(
        fontSize:
            (theme.typeScale.labelLarge.fontSize ?? 14) + widget.labelSizeBoost,
        fontWeight: FontWeight.w600,
      ),
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: hPad / 2),
      spacing: widget.spacing ?? theme.spacing.md,
    );
  }

  @override
  void didUpdateWidget(covariant MorphChipToggle<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    final tokens = _resolveTokens(context);
    final (widths, lefts) = _computeBounds(
      context,
      tokens.style,
      tokens.padding,
      tokens.spacing,
    );
    if (!widget.multiSelection) {
      _exiting.clear();
      _bloomEntries.clear();
      _bloomExits.clear();
      _entryOrigins.clear();
      if (oldWidget.multiSelection) {
        _initialized = false;
        _singlePhase?.cancel();
      } else if (oldWidget.selected != widget.selected) {
        final int from = oldWidget.selected == null
            ? -1
            : _indexOf(oldWidget.selected as T);
        final int to = widget.selected == null
            ? -1
            : _indexOf(widget.selected as T);
        if (from >= 0 && to >= 0) {
          _animateSingle(from, to, lefts, widths);
        }
      }
      return;
    }

    final Set<T> current = Set<T>.of(widget.selectedValues ?? <T>{});
    final Set<T> before = oldWidget.multiSelection
        ? _previousSelections
        : <T>{if (oldWidget.selected != null) oldWidget.selected as T};
    for (final value in current.difference(before)) {
      final index = _indexOf(value);
      if (index < 0) continue;
      final own = _boundsFor(index, lefts, widths);
      if (before.isEmpty && current.length == 1) {
        // Only the very first selection is born as a circle.
        _bloomEntries.add(value);
        _entryOrigins.remove(value);
      } else {
        _bloomEntries.remove(value);
        final sources = before.isEmpty ? current : before;
        _entryOrigins[value] =
            _findNearest(value, sources, lefts, widths) ?? own;
      }
      _bloomExits.remove(value);
      _exiting.remove(value);
    }
    for (final value in before.difference(current)) {
      if (_indexOf(value) < 0) continue;
      _exiting.add(value);
      if (current.isEmpty && before.length == 1) {
        // Only the final active chip shrinks back into a circle.
        _bloomExits.add(value);
      } else {
        _bloomExits.remove(value);
        _bloomEntries.remove(value);
      }
      _entryOrigins.remove(value);
    }
    _previousSelections = current;
  }

  void _animateSingle(
    int from,
    int to,
    List<double> lefts,
    List<double> widths,
  ) {
    _singlePhase?.cancel();
    final source = _boundsFor(from, lefts, widths);
    final target = _boundsFor(to, lefts, widths);
    final bool rightwards = target.left > source.left;
    final bool reduced = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (reduced) {
      setState(() {
        _leftTarget = target.left;
        _rightTarget = target.right;
      });
      return;
    }
    setState(() {
      if (rightwards) {
        _rightTarget = target.right;
      } else {
        _leftTarget = target.left;
      }
    });
    _singlePhase = Timer(widget.stretchDelay, () {
      if (!mounted) return;
      setState(() {
        _leftTarget = target.left;
        _rightTarget = target.right;
      });
    });
  }

  void _onTap(T value) {
    if (widget.multiSelection) {
      final next = Set<T>.of(widget.selectedValues ?? <T>{});
      if (!next.add(value)) next.remove(value);
      widget.onSelectionChanged?.call(Set<T>.unmodifiable(next));
    } else if (value != widget.selected) {
      widget.onChanged?.call(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = MorphTheme.of(context);
    final colors = theme.colorScheme;
    final tokens = _resolveTokens(context);
    final (widths, lefts) = _computeBounds(
      context,
      tokens.style,
      tokens.padding,
      tokens.spacing,
    );
    _syncSingle(lefts, widths);
    final double totalWidth = widths.isEmpty
        ? 0
        : lefts.reduce((a, b) => a > b ? a : b) +
              widths[lefts.indexOf(lefts.reduce((a, b) => a > b ? a : b))];
    final Set<T> selected = widget.multiSelection
        ? Set<T>.of(widget.selectedValues ?? <T>{})
        : <T>{if (widget.selected != null) widget.selected as T};
    final bool reduced = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final motion = Motion.curved(
      reduced ? Duration.zero : widget.duration,
      MorphMotion.subtleOvershoot,
    );

    final control = SizedBox(
      height: widget.height,
      width: totalWidth,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (int i = 0; i < widget.options.length; i++) ...[
                if (i > 0) Gap(tokens.spacing),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(widget.radius),
                  ),
                  child: SizedBox(width: widths[i], height: widget.height),
                ),
              ],
            ],
          ),
          if (widget.multiSelection) ...[
            for (final option in widget.options)
              if (selected.contains(option.value) ||
                  _exiting.contains(option.value))
                _buildMultiPill(
                  value: option.value,
                  selected: selected,
                  widths: widths,
                  lefts: lefts,
                  totalWidth: totalWidth,
                  color: colors.primary,
                  reduced: reduced,
                ),
          ] else
            SingleMotionBuilder(
              motion: motion,
              value: _leftTarget,
              builder: (context, left, _) => SingleMotionBuilder(
                motion: motion,
                value: _rightTarget,
                builder: (context, right, _) => Positioned(
                  left: left,
                  top: 0,
                  width: (right - left).clamp(0.0, totalWidth).toDouble(),
                  height: widget.height,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: colors.primary,
                      borderRadius: BorderRadius.circular(widget.radius),
                    ),
                  ),
                ),
              ),
            ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (int i = 0; i < widget.options.length; i++) ...[
                if (i > 0) Gap(tokens.spacing),
                MorphTappable(
                  onTap: () => _onTap(widget.options[i].value),
                  semanticButton: true,
                  semanticChecked: selected.contains(widget.options[i].value),
                  semanticInMutuallyExclusiveGroup: !widget.multiSelection,
                  builder: (context, _) => SizedBox(
                    width: widths[i],
                    height: widget.height,
                    child: _Chip<T>(
                      option: widget.options[i],
                      selected: selected.contains(widget.options[i].value),
                      padding: tokens.padding,
                      duration: reduced ? Duration.zero : widget.duration,
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
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(widget.label!, style: theme.typeScale.labelMedium),
          Gap(theme.spacing.md),
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

  Widget _buildMultiPill({
    required T value,
    required Set<T> selected,
    required List<double> widths,
    required List<double> lefts,
    required double totalWidth,
    required Color color,
    required bool reduced,
  }) {
    final i = _indexOf(value);
    final own = _boundsFor(i, lefts, widths);
    final exiting = !selected.contains(value);
    final target = exiting
        ? (_findNearest(value, selected, lefts, widths) ?? own)
        : own;
    return _MorphTogglePill(
      key: ValueKey<T>(value),
      initial: reduced || widget.duration == Duration.zero
          ? own
          : (_entryOrigins[value] ?? own),
      bounds: own,
      target: target,
      bloomIn: _bloomEntries.contains(value),
      bloomOut: exiting && _bloomExits.contains(value),
      exiting: exiting,
      maxWidth: totalWidth,
      height: widget.height,
      radius: widget.radius,
      color: color,
      duration: reduced ? Duration.zero : widget.duration,
      stretchDelay: reduced ? Duration.zero : widget.stretchDelay,
      onExit: () {
        if (!mounted || !_exiting.contains(value)) return;
        setState(() {
          _exiting.remove(value);
          _bloomEntries.remove(value);
          _bloomExits.remove(value);
          _entryOrigins.remove(value);
        });
      },
    );
  }
}

/// A circle is used only at the zero/one selection boundary. Otherwise
/// the existing indicator duplicates and stretches toward its nearest sibling
/// with a delayed trailing edge, matching the single-selection choreography.
class _MorphTogglePill extends StatefulWidget {
  const _MorphTogglePill({
    super.key,
    required this.initial,
    required this.bounds,
    required this.target,
    required this.bloomIn,
    required this.bloomOut,
    required this.exiting,
    required this.maxWidth,
    required this.height,
    required this.radius,
    required this.color,
    required this.duration,
    required this.stretchDelay,
    required this.onExit,
  });

  final _ChipBounds initial;
  final _ChipBounds bounds;
  final _ChipBounds target;
  final bool bloomIn;
  final bool bloomOut;
  final bool exiting;
  final double maxWidth;
  final double height;
  final double radius;
  final Color color;
  final Duration duration;
  final Duration stretchDelay;
  final VoidCallback onExit;

  @override
  State<_MorphTogglePill> createState() => _MorphTogglePillState();
}

class _MorphTogglePillState extends State<_MorphTogglePill>
    with TickerProviderStateMixin {
  late final AnimationController _bloom;
  late final AnimationController _transfer;
  late Animatable<double> _leftTween;
  late Animatable<double> _rightTween;
  int _generation = 0;
  bool _transferStartPending = false;

  bool get _usesBloom =>
      (widget.bloomIn && !widget.exiting) ||
      (widget.bloomOut && widget.exiting);

  @override
  void initState() {
    super.initState();
    _bloom = AnimationController(
      vsync: this,
      duration: widget.duration,
      value: widget.bloomIn && widget.duration > Duration.zero ? 0 : 1,
    )..addStatusListener(_onBloomStatus);
    _transfer = AnimationController(
      vsync: this,
      duration: widget.duration,
      value: 1,
    )..addStatusListener(_onTransferStatus);
    _leftTween = ConstantTween<double>(widget.initial.left);
    _rightTween = ConstantTween<double>(widget.initial.right);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_usesBloom) {
        if (widget.duration > Duration.zero) _bloom.forward();
      } else {
        _animateTransfer();
      }
    });
  }

  void _onBloomStatus(AnimationStatus status) {
    if (status == AnimationStatus.dismissed && widget.exiting && _usesBloom) {
      _scheduleExit();
    }
  }

  void _onTransferStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed && widget.exiting && !_usesBloom) {
      _scheduleExit();
    }
  }

  void _scheduleExit() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !widget.exiting) return;
      if (_usesBloom ? _bloom.isDismissed : _transfer.isCompleted) {
        widget.onExit();
      }
    });
  }

  @override
  void didUpdateWidget(covariant _MorphTogglePill oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.duration != widget.duration) {
      _bloom.duration = widget.duration;
      _transfer.duration = widget.duration;
    }
    final wasBloom =
        (oldWidget.bloomIn && !oldWidget.exiting) ||
        (oldWidget.bloomOut && oldWidget.exiting);
    if (_usesBloom) {
      _transfer.stop();
      if (widget.duration == Duration.zero) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _bloom.value = widget.exiting ? 0 : 1;
          if (widget.exiting) _scheduleExit();
        });
      } else if (widget.exiting) {
        _bloom.reverse();
      } else {
        _bloom.forward();
      }
    } else if (oldWidget.target != widget.target ||
        oldWidget.bounds != widget.bounds ||
        oldWidget.exiting != widget.exiting ||
        wasBloom ||
        oldWidget.duration != widget.duration ||
        oldWidget.stretchDelay != widget.stretchDelay) {
      // When switching from a fully expanded bloom, start from own bounds.
      if (wasBloom) {
        _leftTween = ConstantTween<double>(widget.bounds.left);
        _rightTween = ConstantTween<double>(widget.bounds.right);
        _transferStartPending = true;
      }
      _animateTransfer();
    }
  }

  void _animateTransfer() {
    // Before a scheduled start, the controller may still have value=1 from
    // the previous target. Sample from time zero to avoid a one-frame jump.
    final sampleTime = _transferStartPending ? 0.0 : _transfer.value;
    final fromLeft = _leftTween.transform(sampleTime);
    final fromRight = _rightTween.transform(sampleTime);
    final to = widget.target;
    final generation = ++_generation;
    _transfer.stop();
    if (widget.duration == Duration.zero ||
        (fromLeft == to.left && fromRight == to.right)) {
      _leftTween = ConstantTween<double>(to.left);
      _rightTween = ConstantTween<double>(to.right);
      _transferStartPending = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || generation != _generation) return;
        _transfer.value = 1;
        if (widget.exiting) _scheduleExit();
      });
      return;
    }
    final delayFraction =
        (widget.stretchDelay.inMicroseconds / widget.duration.inMicroseconds)
            .clamp(0.0, 0.85)
            .toDouble();
    final rightward = (to.left + to.right) >= (fromLeft + fromRight);
    // The leading edge travels immediately; the trailing edge follows after
    // a real dwell interval. TweenSequence provides stable reversal mid-flight.
    _leftTween = rightward
        ? MorphMotion.staggeredTween(
            begin: fromLeft,
            end: to.left,
            delayFraction: delayFraction,
          )
        : MorphMotion.spatialTween(begin: fromLeft, end: to.left);
    _rightTween = rightward
        ? MorphMotion.spatialTween(begin: fromRight, end: to.right)
        : MorphMotion.staggeredTween(
            begin: fromRight,
            end: to.right,
            delayFraction: delayFraction,
          );
    _transferStartPending = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || generation != _generation || _usesBloom) return;
      _transferStartPending = false;
      _transfer.forward(from: 0);
    });
  }

  @override
  void dispose() {
    _bloom.dispose();
    _transfer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_usesBloom) {
      return Positioned(
        left: widget.bounds.left,
        top: 0,
        width: widget.bounds.right - widget.bounds.left,
        height: widget.height,
        child: AnimatedBuilder(
          animation: _bloom,
          builder: (context, _) => CustomPaint(
            painter: _CircularChipBloomPainter(
              progress: _bloom.value,
              color: widget.color,
              radius: widget.radius,
            ),
          ),
        ),
      );
    }
    return AnimatedBuilder(
      animation: _transfer,
      builder: (context, _) {
        final time = _transferStartPending ? 0.0 : _transfer.value;
        final left = _leftTween.transform(time);
        final right = _rightTween.transform(time);
        return Positioned(
          left: left,
          top: 0,
          width: (right - left).clamp(0.0, widget.maxWidth).toDouble(),
          height: widget.height,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: widget.color,
              borderRadius: BorderRadius.circular(widget.radius),
            ),
          ),
        );
      },
    );
  }
}

/// The first phase is **always a circle**, never a compressed full-height pill.
/// Only the final phase stretches that circle sideways to fill its chip.
class _CircularChipBloomPainter extends CustomPainter {
  static final Animatable<double> _fadeTween = MorphMotion.effectsTween(
    begin: 0,
    end: 1,
  );

  const _CircularChipBloomPainter({
    required this.progress,
    required this.color,
    required this.radius,
  });

  final double progress;
  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final p = progress.clamp(0.0, 1.0);
    if (p <= 0.0) return;

    const circularPhase = 0.78;
    final maxDiameter = size.height < size.width ? size.height : size.width;
    final minDiameter = maxDiameter < 4.0 ? maxDiameter : 4.0;
    double width;
    double height;
    double cornerRadius;

    if (p < circularPhase) {
      // Ease-in preserves a genuinely tiny dot in the opening frames.
      final t = Curves.easeInQuad.transform(p / circularPhase);
      final diameter = minDiameter + (maxDiameter - minDiameter) * t;
      width = diameter;
      height = diameter;
      cornerRadius = diameter / 2;
    } else {
      // Expand sideways only after the circle has reached the chip's height.
      final t = Curves.easeOutCubic.transform(
        (p - circularPhase) / (1 - circularPhase),
      );
      width = maxDiameter + (size.width - maxDiameter) * t;
      height = maxDiameter + (size.height - maxDiameter) * t;
      cornerRadius = maxDiameter / 2 + (radius - maxDiameter / 2) * t;
    }

    // Fade occurs only at the tiny-dot end, in both directions.
    final alpha = _fadeTween.transform((p / 0.12).clamp(0.0, 1.0).toDouble());
    final paint = Paint()..color = color.withValues(alpha: color.a * alpha);
    final rect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: width,
      height: height,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(cornerRadius)),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _CircularChipBloomPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.color != color ||
      oldDelegate.radius != radius;
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
                Text(option.label, style: labelStyle?.copyWith(color: c)),
              ],
            );
          },
        ),
      ),
    );
  }
}
