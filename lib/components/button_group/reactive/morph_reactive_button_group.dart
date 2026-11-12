import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import '../../../foundations/foundations.dart';
import '../../buttons/morph_buttons.dart';
import '../styles/morph_button_group_theme.dart';
import 'morph_reactive_distribution.dart';

export 'morph_reactive_distribution.dart';

/// Interaction model of [MorphReactiveButtonGroup].
enum MorphReactiveGroupMode {
  /// One selected item (controlled by [MorphReactiveButtonGroup.selectedIndex]).
  /// Tapping the selected item clears it unless `selectionRequired`.
  singleSelect,

  /// Independent toggles (controlled by `selectedIndices`).
  multiToggle,

  /// Plain actions: never selected; the pressed item widens while held.
  actions,
}

/// One button of a [MorphReactiveButtonGroup]. Every item keeps its own
/// surface; shapes are per item and never imply selection.
@immutable
class MorphReactiveGroupItem {
  const MorphReactiveGroupItem({
    this.icon,
    this.selectedIcon,
    this.label,
    this.selectedLabel,
    this.onPressed,
    this.enabled = true,
    this.style,
    this.decoration,
    this.restRadius,
    this.selectedRadius,
    this.pressedRadius,
    this.minWidth,
    this.width,
    this.focusNode,
    this.autofocus = false,
    this.semanticLabel,
    this.tooltip,
  }) : assert(icon != null || label != null, 'Provide an icon and/or label.');

  final Widget? icon, selectedIcon, label, selectedLabel;

  /// Used by [MorphReactiveGroupMode.actions]; the selection modes report
  /// through the group callbacks (this one is also called if set).
  final VoidCallback? onPressed;
  final bool enabled;

  /// Overrides the group style for this item (e.g. a filled centre button).
  final MorphButtonStyle? style;

  /// Per-item decoration, merged over the group decoration.
  final MorphButtonDecoration? decoration;

  /// Corner radius (dp) at rest / when selected / while pressed. Null → the
  /// group value → Morph defaults (round rest, squarer selected/pressed).
  final double? restRadius, selectedRadius, pressedRadius;

  /// Natural-width floor. Icon-only items default to a square target.
  final double? minWidth;

  /// Explicit width: excluded from the distribution.
  final double? width;

  final FocusNode? focusNode;
  final bool autofocus;
  final String? semanticLabel, tooltip;

  bool get isIconOnly => icon != null && label == null && selectedLabel == null;
}

/// Button group whose items own their surfaces and trade width with their
/// siblings: the pressed item asks for more, neighbours yield, selected /
/// active items keep a bounded expansion.
///
/// Width resolution lives in [resolveReactiveWidths] (one common distribution
/// state for the whole group, driven by one ticker); see [fit] for how
/// bounded / unbounded parents are handled. Selection is controlled by the
/// consumer and only confirmed by the button's normal tap gesture, never on
/// pointer down. The classic [MorphButtonGroup] is unchanged.
class MorphReactiveButtonGroup extends StatefulWidget {
  const MorphReactiveButtonGroup({
    super.key,
    required this.items,
    this.mode = MorphReactiveGroupMode.singleSelect,
    this.selectedIndex,
    this.onSelectedIndexChanged,
    this.selectedIndices = const {},
    this.onSelectedIndicesChanged,
    this.selectionRequired = false,
    this.fit = MorphReactiveGroupFit.fill,
    this.size = MorphButtonSize.sm,
    this.style = MorphButtonStyle.tonal,
    this.gap,
    this.pressedExpansion = .15,
    this.selectedExpansion = .08,
    this.restRadius,
    this.selectedRadius,
    this.pressedRadius,
    this.decoration,
    this.enableFeedback = true,
    this.semanticLabel,
  }) : assert(pressedExpansion >= 0 && selectedExpansion >= 0);

  final List<MorphReactiveGroupItem> items;
  final MorphReactiveGroupMode mode;

  /// [MorphReactiveGroupMode.singleSelect]; null = none selected.
  final int? selectedIndex;
  final ValueChanged<int?>? onSelectedIndexChanged;

  /// [MorphReactiveGroupMode.multiToggle].
  final Set<int> selectedIndices;
  final ValueChanged<Set<int>>? onSelectedIndicesChanged;

  /// Prevents clearing the last selection (single and multi).
  final bool selectionRequired;

  final MorphReactiveGroupFit fit;
  final MorphButtonSize size;
  final MorphButtonStyle style;

  /// Between-item gap (dp). Null → [MorphButtonGroupTheme.connectedGap].
  final double? gap;

  /// Growth ratio (of the resting width) requested while pressed / selected.
  /// The target of an item is `max(...)` of the applicable ones, never their
  /// sum, and is reduced when the parent leaves no room.
  final double pressedExpansion, selectedExpansion;

  /// Group-wide radii (dp); items may override them. See
  /// [MorphReactiveGroupItem].
  final double? restRadius, selectedRadius, pressedRadius;

  final MorphButtonDecoration? decoration;
  final bool enableFeedback;
  final String? semanticLabel;

  @override
  State<MorphReactiveButtonGroup> createState() =>
      _MorphReactiveButtonGroupState();
}

/// One shared, critically damped evolution for the whole group: each value is
/// a second-order system (no overshoot, no velocity jump at press/release).
/// Retargeting keeps both position and velocity, so interruptions start from
/// what is visible and nothing accumulates.
class _ExpansionBank extends ChangeNotifier {
  _ExpansionBank(TickerProvider vsync) {
    _ticker = vsync.createTicker(_tick);
  }
  late final Ticker _ticker;
  List<double> values = const [];
  List<double> velocities = const [];
  List<double> targets = const [];
  Duration _last = Duration.zero;
  bool _disposed = false;
  static const _omegaPress = 30.0, _omegaRelease = 22.0; // rad/s

  void configure(int count) {
    if (values.length == count) return;
    values = List<double>.filled(count, 0);
    velocities = List<double>.filled(count, 0);
    targets = List<double>.filled(count, 0);
  }

  void setTargets(List<double> next, {required bool animate}) {
    if (listEquals(next, targets) &&
        (_ticker.isActive || listEquals(values, targets))) {
      return;
    }
    targets = next;
    if (!animate) {
      _ticker.stop();
      values = List<double>.of(next);
      velocities = List<double>.filled(next.length, 0);
      notifyListeners();
      return;
    }
    if (!_ticker.isActive) {
      _last = Duration.zero;
      _ticker.start();
    }
  }

  void _tick(Duration elapsed) {
    // Clamp dt: a long frame must not fling the value.
    final dt = ((elapsed - _last).inMicroseconds / 1e6).clamp(0.0, 1 / 30);
    _last = elapsed;
    var moving = false;
    final x = List<double>.of(values), v = List<double>.of(velocities);
    for (var i = 0; i < x.length; i++) {
      final e0 = x[i] - targets[i];
      if (e0.abs() < .0004 && v[i].abs() < .004) {
        x[i] = targets[i];
        v[i] = 0;
        continue;
      }
      final w = targets[i] >= x[i] ? _omegaPress : _omegaRelease;
      final decay = math.exp(-w * dt);
      final c = v[i] + w * e0;
      x[i] = targets[i] + (e0 + c * dt) * decay;
      v[i] = (v[i] - w * c * dt) * decay;
      // Critical damping from rest cannot overshoot; guard the retarget case.
      if ((x[i] - targets[i]) * e0 < 0) {
        x[i] = targets[i];
        v[i] = 0;
      } else {
        moving = true;
      }
    }
    values = x;
    velocities = v;
    notifyListeners();
    if (!moving) _ticker.stop();
  }

  @override
  void dispose() {
    _disposed = true;
    _ticker.dispose();
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }
}

class _MorphReactiveButtonGroupState extends State<MorphReactiveButtonGroup>
    with SingleTickerProviderStateMixin {
  late final _ExpansionBank _bank = _ExpansionBank(this);
  List<WidgetStatesController> _states = [];
  List<bool> _pressed = [];
  bool _syncScheduled = false;
  bool _reduced = false; // cached: children may notify while deactivating

  @override
  void initState() {
    super.initState();
    _rebuildControllers();
  }

  void _rebuildControllers() {
    for (final c in _states) {
      c.dispose();
    }
    _states = List.generate(widget.items.length, (i) {
      final c = WidgetStatesController();
      c.addListener(() => _onStates(i));
      return c;
    });
    _pressed = List<bool>.filled(widget.items.length, false);
    _bank.configure(widget.items.length);
  }

  void _onStates(int i) {
    if (i >= _states.length) return;
    final p = _states[i].value.contains(WidgetState.pressed);
    if (_pressed[i] == p) return;
    _pressed[i] = p;
    _syncTargets();
  }

  @override
  void didUpdateWidget(covariant MorphReactiveButtonGroup old) {
    super.didUpdateWidget(old);
    if (old.items.length != widget.items.length) _rebuildControllers();
    _syncTargets();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduced = MorphMotion.reduceMotionOf(context);
    _syncTargets();
  }

  bool _isSelected(int i) => switch (widget.mode) {
    MorphReactiveGroupMode.singleSelect => widget.selectedIndex == i,
    MorphReactiveGroupMode.multiToggle => widget.selectedIndices.contains(i),
    MorphReactiveGroupMode.actions => false,
  };

  void _syncTargets() {
    if (_syncScheduled) return;
    final reduced = _reduced;
    final targets = <double>[
      for (var i = 0; i < widget.items.length; i++)
        !widget.items[i].enabled
            ? 0.0
            : math.max(
                _isSelected(i) ? widget.selectedExpansion : 0.0,
                _pressed[i] ? widget.pressedExpansion : 0.0,
              ),
    ];
    // A pressed-state change can arrive during build (statesController);
    // defer the notification, never the visible value.
    final phase = SchedulerBinding.instance.schedulerPhase;
    if (phase == SchedulerPhase.persistentCallbacks) {
      _syncScheduled = true;
      SchedulerBinding.instance.addPostFrameCallback((_) {
        _syncScheduled = false;
        if (mounted) _bank.setTargets(targets, animate: !reduced);
      });
    } else {
      _bank.setTargets(targets, animate: !reduced);
    }
  }

  void _activate(int i) {
    final item = widget.items[i];
    if (!item.enabled) return;
    switch (widget.mode) {
      case MorphReactiveGroupMode.singleSelect:
        final selected = widget.selectedIndex == i;
        if (selected && widget.selectionRequired) break;
        widget.onSelectedIndexChanged?.call(selected ? null : i);
      case MorphReactiveGroupMode.multiToggle:
        final next = {...widget.selectedIndices};
        if (!next.remove(i)) next.add(i);
        if (widget.selectionRequired && next.isEmpty) break;
        widget.onSelectedIndicesChanged?.call(next);
      case MorphReactiveGroupMode.actions:
        break;
    }
    item.onPressed?.call();
  }

  @override
  void dispose() {
    for (final c in _states) {
      c.dispose();
    }
    _bank.dispose();
    super.dispose();
  }

  Widget _button(BuildContext context, int i, double height) {
    final item = widget.items[i];
    final selected = _isSelected(i);
    final selectable = widget.mode != MorphReactiveGroupMode.actions;
    final rest = item.restRadius ?? widget.restRadius;
    final press = item.pressedRadius ?? widget.pressedRadius;
    // MorphButton's non-selection path reads `borderRadius` for the resting
    // shape; keep the press morph unless a pressed radius is given.
    final base = (widget.decoration ?? const MorphButtonDecoration()).merge(
      item.decoration,
    );
    final decoration = selectable
        ? base.copyWith(
            unselectedRadius: rest,
            selectedRadius: item.selectedRadius ?? widget.selectedRadius,
            pressedRadius: press,
          )
        : base.copyWith(
            borderRadius: rest,
            pressedRadius:
                press ??
                (rest == null
                    ? null
                    : MorphTheme.of(context).buttonTheme
                          .pressedRadius(widget.size)),
          );
    final size = widget.size.copyWith(
      height: height,
      hPadding: item.isIconOnly ? 0 : widget.size.hPadding,
    );
    return MorphButton(
      key: ValueKey(i),
      icon: item.icon,
      selectedIcon: item.selectedIcon,
      label: item.label,
      selectedLabel: item.selectedLabel,
      isSelected: selectable ? selected : null,
      onPressed: item.enabled ? () => _activate(i) : null,
      enabled: item.enabled,
      style: item.style ?? widget.style,
      size: size,
      focusNode: item.focusNode,
      autofocus: item.autofocus,
      statesController: _states[i],
      enableFeedback: widget.enableFeedback,
      semanticLabel: item.semanticLabel,
      tooltip: item.tooltip,
      decoration: decoration,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = MorphTheme.of(context);
    final groupTheme = theme.buttonGroupTheme;
    final gap = math.max(0.0, widget.gap ?? groupTheme.connectedGap);
    final height = groupTheme.containerHeightFor(widget.size);
    // Donor threshold: an item stops donating as soon as it asks for anything
    // (pressed or selected), whatever the configured amplitudes are. Scaling
    // by the larger amplitude made selected items partial donors and let a
    // pressed item re-route selection compensation to far neighbours.
    final positive = [
      widget.pressedExpansion,
      widget.selectedExpansion,
    ].where((e) => e > 0);
    final maxExpansion = positive.isEmpty ? 0.0 : positive.reduce(math.min);
    return Semantics(
      container: true,
      label: widget.semanticLabel,
      child: FocusTraversalGroup(
        policy: OrderedTraversalPolicy(),
        child: _ReactiveRow(
          bank: _bank,
          textDirection: Directionality.of(context),
          gap: gap,
          fit: widget.fit,
          maxExpansion: maxExpansion,
          floors: [
            for (final item in widget.items)
              item.minWidth ?? (item.isIconOnly ? height : 0.0),
          ],
          fixedWidths: [for (final item in widget.items) item.width],
          children: [
            for (var i = 0; i < widget.items.length; i++)
              _button(context, i, height),
          ],
        ),
      ),
    );
  }
}

class _ReactiveRow extends MultiChildRenderObjectWidget {
  const _ReactiveRow({
    required this.bank,
    required this.textDirection,
    required this.gap,
    required this.fit,
    required this.maxExpansion,
    required this.floors,
    required this.fixedWidths,
    required super.children,
  });
  final _ExpansionBank bank;
  final TextDirection textDirection;
  final double gap, maxExpansion;
  final MorphReactiveGroupFit fit;
  final List<double> floors;
  final List<double?> fixedWidths;

  @override
  _RenderReactiveRow createRenderObject(BuildContext context) =>
      _RenderReactiveRow(
        bank,
        textDirection,
        gap,
        fit,
        maxExpansion,
        floors,
        fixedWidths,
      );

  @override
  void updateRenderObject(BuildContext context, _RenderReactiveRow r) {
    r
      ..bank = bank
      ..textDirection = textDirection
      ..gap = gap
      ..fit = fit
      ..maxExpansion = maxExpansion
      ..floors = floors
      ..fixedWidths = fixedWidths
      // Content, text scale or locale may have changed natural widths.
      ..invalidateBase()
      ..markNeedsLayout();
  }
}

class _ReactiveParentData extends ContainerBoxParentData<RenderBox> {}

class _RenderReactiveRow extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _ReactiveParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _ReactiveParentData> {
  _RenderReactiveRow(
    this._bank,
    this._textDirection,
    this._gap,
    this._fit,
    this._maxExpansion,
    this._floors,
    this._fixedWidths,
  );

  _ExpansionBank _bank;
  set bank(_ExpansionBank v) {
    if (identical(v, _bank)) return;
    if (attached) _bank.removeListener(markNeedsLayout);
    _bank = v;
    if (attached) _bank.addListener(markNeedsLayout);
    markNeedsLayout();
  }

  TextDirection _textDirection;
  set textDirection(TextDirection v) {
    if (v != _textDirection) {
      _textDirection = v;
      markNeedsLayout();
    }
  }

  double _gap, _maxExpansion;
  set gap(double v) => _gap = v;
  set maxExpansion(double v) => _maxExpansion = v;
  MorphReactiveGroupFit _fit;
  set fit(MorphReactiveGroupFit v) => _fit = v;
  List<double> _floors;
  set floors(List<double> v) => _floors = v;
  List<double?> _fixedWidths;
  set fixedWidths(List<double?> v) => _fixedWidths = v;

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _bank.addListener(markNeedsLayout);
  }

  @override
  void detach() {
    _bank.removeListener(markNeedsLayout);
    super.detach();
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _ReactiveParentData) {
      child.parentData = _ReactiveParentData();
    }
  }

  // Stable base: natural widths/height are measured only when the content,
  // theme or constraints change - never from the animated result.
  List<double>? _naturals;
  double _rowHeight = 0;
  double? _naturalsFor;

  void invalidateBase() => _naturals = null;

  List<RenderBox> get _kids => [
    for (var c = firstChild; c != null; c = childAfter(c)) c,
  ];

  @override
  void performLayout() {
    final kids = _kids;
    final loose = BoxConstraints(maxHeight: constraints.maxHeight);
    if (_naturals == null ||
        _naturals!.length != kids.length ||
        _naturalsFor != constraints.maxHeight) {
      final measured = <double>[];
      var h = 0.0;
      for (var i = 0; i < kids.length; i++) {
        kids[i].layout(loose, parentUsesSize: true);
        h = math.max(h, kids[i].size.height);
        measured.add(
          math.max(kids[i].size.width, i < _floors.length ? _floors[i] : 0),
        );
      }
      _naturals = measured;
      _rowHeight = h;
      _naturalsFor = constraints.maxHeight;
    }
    final natural = _naturals!;
    final expansion = _bank.values.length == kids.length
        ? _bank.values
        : List<double>.filled(kids.length, 0);
    final widths = resolveReactiveWidths(
      natural: natural,
      fixed: _fixedWidths.length == kids.length
          ? _fixedWidths
          : List<double?>.filled(kids.length, null),
      expansion: expansion,
      maxExpansion: _maxExpansion,
      available: constraints.hasBoundedWidth
          ? constraints.maxWidth
          : double.infinity,
      gap: _gap,
      fit: _fit,
    );
    var height = 0.0, total = 0.0;
    for (var i = 0; i < kids.length; i++) {
      kids[i].layout(
        BoxConstraints.tightFor(width: widths[i], height: _rowHeight),
        parentUsesSize: true,
      );
      height = math.max(height, kids[i].size.height);
      total += widths[i] + (i == 0 ? 0 : _gap);
    }
    size = constraints.constrain(Size(total, height));
    var x = 0.0;
    for (final c in kids) {
      final left = _textDirection == TextDirection.ltr
          ? x
          : size.width - x - c.size.width;
      (c.parentData! as _ReactiveParentData).offset = Offset(
        left,
        (size.height - c.size.height) / 2,
      );
      x += c.size.width + _gap;
    }
  }

  @override
  double computeMinIntrinsicWidth(double height) =>
      computeMaxIntrinsicWidth(height);
  @override
  double computeMaxIntrinsicWidth(double height) {
    var w = 0.0;
    var i = 0;
    for (final c in _kids) {
      w +=
          math.max(
            c.getMaxIntrinsicWidth(height),
            i < _floors.length ? _floors[i] : 0,
          ) +
          (i == 0 ? 0 : _gap);
      i++;
    }
    return w;
  }

  @override
  double computeMinIntrinsicHeight(double width) =>
      computeMaxIntrinsicHeight(width);
  @override
  double computeMaxIntrinsicHeight(double width) => _kids.fold<double>(
    0,
    (h, c) => math.max(h, c.getMaxIntrinsicHeight(double.infinity)),
  );

  @override
  Size computeDryLayout(BoxConstraints constraints) => constraints.constrain(
    Size(
      computeMaxIntrinsicWidth(constraints.maxHeight),
      computeMaxIntrinsicHeight(double.infinity),
    ),
  );

  @override
  void paint(PaintingContext context, Offset offset) =>
      defaultPaint(context, offset);

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) =>
      defaultHitTestChildren(result, position: position);
}
