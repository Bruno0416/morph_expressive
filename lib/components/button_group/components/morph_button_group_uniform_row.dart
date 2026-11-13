part of '../morph_button_group.dart';

/// Connected-group row: every button shares one resting width.
///
/// Children alternate `button, gap, button, …`. The common width is the widest
/// natural button (real layout of the content, never character counting),
/// raised to [floors] (selected-state content measured by the group), unless
/// [itemWidth] fixes it. It is limited to the per-item budget left after gaps
/// and the available extent (never negative); buttons then keep a single line
/// with ellipsis. [fixedWidths] entries (per-action `width`) win for their
/// own button. With unbounded constraints the natural width is used.
class _UniformRowWidget extends MultiChildRenderObjectWidget {
  const _UniformRowWidget({
    required this.textDirection,
    required this.itemWidth,
    required this.floors,
    required this.fixedWidths,
    required this.maxExtent,
    required super.children,
  });

  final TextDirection textDirection;
  final double? itemWidth;
  final List<double> floors;
  final List<double?> fixedWidths;
  final double maxExtent;

  @override
  _RenderUniformRow createRenderObject(BuildContext context) =>
      _RenderUniformRow(
        textDirection: textDirection,
        itemWidth: itemWidth,
        floors: floors,
        fixedWidths: fixedWidths,
        maxExtent: maxExtent,
      );

  @override
  void updateRenderObject(BuildContext context, _RenderUniformRow r) {
    r
      ..textDirection = textDirection
      ..itemWidth = itemWidth
      ..floors = floors
      ..fixedWidths = fixedWidths
      ..maxExtent = maxExtent
      // Every rebuild of the group (content, typography, text scale, locale,
      // direction, padding) re-measures: children with fixed-width ancestors
      // do not propagate their own content changes up to this layout.
      ..markNeedsLayout();
  }
}

class _UniformRowParentData extends ContainerBoxParentData<RenderBox> {}

class _RenderUniformRow extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _UniformRowParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _UniformRowParentData> {
  _RenderUniformRow({
    required this._textDirection,
    required this._itemWidth,
    required this._floors,
    required this._fixedWidths,
    required this._maxExtent,
  });

  TextDirection _textDirection;
  set textDirection(TextDirection v) {
    if (v == _textDirection) return;
    _textDirection = v;
    markNeedsLayout();
  }

  double? _itemWidth;
  set itemWidth(double? v) {
    if (v == _itemWidth) return;
    _itemWidth = v;
    markNeedsLayout();
  }

  List<double> _floors;
  set floors(List<double> v) {
    if (listEquals(v, _floors)) return;
    _floors = v;
    markNeedsLayout();
  }

  List<double?> _fixedWidths;
  set fixedWidths(List<double?> v) {
    if (listEquals(v, _fixedWidths)) return;
    _fixedWidths = v;
    markNeedsLayout();
  }

  double _maxExtent;
  set maxExtent(double v) {
    if (v == _maxExtent) return;
    _maxExtent = v;
    markNeedsLayout();
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _UniformRowParentData) {
      child.parentData = _UniformRowParentData();
    }
  }

  List<RenderBox> get _all {
    final out = <RenderBox>[];
    for (var c = firstChild; c != null; c = childAfter(c)) {
      out.add(c);
    }
    return out;
  }

  @override
  void performLayout() {
    final children = _all;
    final loose = BoxConstraints(maxHeight: constraints.maxHeight);
    var gaps = 0.0;
    final buttons = <RenderBox>[];
    for (var i = 0; i < children.length; i++) {
      children[i].layout(loose, parentUsesSize: true);
      if (i.isOdd) {
        gaps += children[i].size.width;
      } else {
        buttons.add(children[i]);
      }
    }
    var common = 0.0;
    for (var i = 0; i < buttons.length; i++) {
      if (i < _fixedWidths.length && _fixedWidths[i] != null) continue;
      final floor = i < _floors.length ? _floors[i] : 0.0;
      common = math.max(common, math.max(buttons[i].size.width, floor));
    }
    final fixedTotal = [
      for (var i = 0; i < buttons.length; i++)
        if (i < _fixedWidths.length && _fixedWidths[i] != null)
          _fixedWidths[i]!,
    ].fold<double>(0, (a, b) => a + b);
    final flexCount =
        buttons.length -
        [
          for (var i = 0; i < buttons.length; i++)
            if (i < _fixedWidths.length && _fixedWidths[i] != null) i,
        ].length;
    if (_itemWidth != null) common = _itemWidth!;
    final available = math.min(_maxExtent, constraints.maxWidth);
    if (available.isFinite && flexCount > 0) {
      final budget = math.max(0.0, (available - gaps - fixedTotal) / flexCount);
      common = math.min(common, budget);
    }
    var x = 0.0;
    var height = 0.0;
    final widths = <double>[];
    for (var i = 0; i < children.length; i++) {
      final c = children[i];
      if (i.isEven) {
        final index = i ~/ 2;
        final fixed = index < _fixedWidths.length ? _fixedWidths[index] : null;
        final w = fixed ?? common;
        c.layout(
          BoxConstraints.tightFor(width: w)
              .copyWith(minHeight: 0, maxHeight: constraints.maxHeight),
          parentUsesSize: true,
        );
      }
      widths.add(c.size.width);
      height = math.max(height, c.size.height);
      x += c.size.width;
    }
    size = constraints.constrain(Size(x, height));
    var offset = 0.0;
    for (var i = 0; i < children.length; i++) {
      final c = children[i];
      final left = _textDirection == TextDirection.ltr
          ? offset
          : size.width - offset - c.size.width;
      (c.parentData! as _UniformRowParentData).offset = Offset(
        left,
        (size.height - c.size.height) / 2,
      );
      offset += c.size.width;
    }
  }

  @override
  double computeMinIntrinsicWidth(double height) =>
      getMaxIntrinsicWidth(height);

  @override
  double computeMaxIntrinsicWidth(double height) {
    var w = 0.0;
    for (final c in _all) {
      w += c.getMaxIntrinsicWidth(height);
    }
    return w;
  }

  @override
  double computeMinIntrinsicHeight(double width) =>
      getMaxIntrinsicHeight(width);

  @override
  double computeMaxIntrinsicHeight(double width) {
    var h = 0.0;
    for (final c in _all) {
      h = math.max(h, c.getMaxIntrinsicHeight(width));
    }
    return h;
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    return constraints.constrain(
      Size(
        computeMaxIntrinsicWidth(constraints.maxHeight),
        computeMaxIntrinsicHeight(double.infinity),
      ),
    );
  }

  @override
  void paint(PaintingContext context, Offset offset) =>
      defaultPaint(context, offset);

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) =>
      defaultHitTestChildren(result, position: position);
}
