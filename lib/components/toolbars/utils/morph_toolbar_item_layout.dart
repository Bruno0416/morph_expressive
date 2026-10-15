import 'package:flutter/widgets.dart';

import '../models/morph_toolbar_item.dart';

/// Shared helpers for partitioning and laying out [MorphToolbarItem]s.
abstract final class MorphToolbarItemLayout {
  const MorphToolbarItemLayout._();

  /// Cross-axis room left for item content after [padding] on [axis].
  static double availableCrossExtent({
    required double crossAxisSize,
    required EdgeInsets padding,
    required Axis axis,
  }) {
    final double inset = axis == Axis.horizontal
        ? padding.top + padding.bottom
        : padding.left + padding.right;
    return (crossAxisSize - inset).clamp(0.0, double.infinity);
  }

  /// Wraps a [MorphToolbarWidget] so it cannot exceed the bar content extent.
  ///
  /// [opticalInset] mirrors the icon-button target overhang beyond its visual
  /// so widget↔action spacing matches action↔action spacing.
  static Widget constrainWidget({
    required MorphToolbarWidget item,
    required double availableExtent,
    required Axis axis,
    double opticalInset = 0,
  }) {
    Widget child = item.child;
    if (item.semanticLabel != null) {
      child = Semantics(label: item.semanticLabel, child: child);
    }
    child = ConstrainedBox(
      constraints: axis == Axis.horizontal
          ? BoxConstraints(maxHeight: availableExtent)
          : BoxConstraints(maxWidth: availableExtent),
      child: child,
    );
    if (opticalInset <= 0) {
      return child;
    }
    return Padding(
      padding: axis == Axis.horizontal
          ? EdgeInsets.symmetric(horizontal: opticalInset)
          : EdgeInsets.symmetric(vertical: opticalInset),
      child: child,
    );
  }

  /// Builds the visual for one item (icon button or constrained widget).
  static Widget buildItem({
    required MorphToolbarItem item,
    required double availableExtent,
    required Axis axis,
    required Widget Function(MorphToolbarAction action) buildAction,
    double opticalInset = 0,
  }) {
    return switch (item) {
      MorphToolbarAction action => buildAction(action),
      MorphToolbarWidget widget => constrainWidget(
        item: widget,
        availableExtent: availableExtent,
        axis: axis,
        opticalInset: opticalInset,
      ),
    };
  }

  /// Docked gap clamped to `[minGap, preferredGap]`.
  ///
  /// Wide bars stay at [preferredGap]. Tight bars shrink toward [minGap].
  static double dockedGap({
    required double available,
    required double slotExtent,
    required int slotCount,
    required double preferredGap,
    required double minGap,
  }) {
    if (slotCount <= 1 || !available.isFinite) {
      return preferredGap;
    }
    final double even = (available - slotCount * slotExtent) / (slotCount - 1);
    return even.clamp(minGap, preferredGap);
  }

  /// Inserts [gap] between consecutive [children] along [axis].
  static List<Widget> withGaps(
    List<Widget> children, {
    required double gap,
    required Axis axis,
  }) {
    if (children.length <= 1 || gap <= 0) {
      return children;
    }
    final Widget spacer = SizedBox(
      width: axis == Axis.horizontal ? gap : 0,
      height: axis == Axis.vertical ? gap : 0,
    );
    final out = <Widget>[children.first];
    for (var i = 1; i < children.length; i++) {
      out
        ..add(spacer)
        ..add(children[i]);
    }
    return out;
  }

  /// Keeps all widgets inline; only excess non-trigger actions overflow.
  ///
  /// Returns `(inline, overflowActions)` preserving relative order in `inline`.
  static ({List<MorphToolbarItem> inline, List<MorphToolbarAction> overflow})
  partitionInline({
    required List<MorphToolbarItem> items,
    required int maxInline,
    int? triggerIndex,
  }) {
    if (items.isEmpty) {
      return (
        inline: const <MorphToolbarItem>[],
        overflow: const <MorphToolbarAction>[],
      );
    }

    // Count how many non-trigger icon actions may stay inline.
    final reservedTrigger = triggerIndex != null ? 1 : 0;
    final int actionBudget = (maxInline - reservedTrigger).clamp(0, maxInline);

    final inline = <MorphToolbarItem>[];
    final overflow = <MorphToolbarAction>[];
    var usedActionSlots = 0;

    for (var i = 0; i < items.length; i++) {
      final MorphToolbarItem item = items[i];
      if (item is MorphToolbarWidget) {
        inline.add(item);
        continue;
      }
      final action = item as MorphToolbarAction;
      if (action.isExpandTrigger) {
        inline.add(action);
        continue;
      }
      if (usedActionSlots < actionBudget) {
        inline.add(action);
        usedActionSlots++;
      } else {
        overflow.add(action);
      }
    }

    return (inline: inline, overflow: overflow);
  }

  /// Fixed pill width for labeled selection when the outer pill should not
  /// grow/shrink: widest (icon+label) action + icon-only neighbors + gaps.
  ///
  /// Returns null when reservation does not apply (no labeled actions, or
  /// inline widgets that cannot be measured cheaply).
  ///
  /// [iconSlotExtent] must be the laid-out icon-only width
  /// (`max(visual, target)`), matching the icon button outer size.
  ///
  /// For [Axis.horizontal] this is the full row main-axis extent. For
  /// [Axis.vertical] it is the column cross-axis width (widest expanded
  /// action) — labels expand horizontally even in a vertical toolbar.
  static double? reservedLabeledSelectionExtent({
    required List<MorphToolbarItem> inline,
    required Axis axis,
    required double iconVisualExtent,
    required double iconSlotExtent,
    required TextStyle labelStyle,
    required TextScaler textScaler,
    required double gap,
    required double labelGap,
    bool includeOverflowSlot = false,
  }) {
    final metrics = _labeledSelectionMetrics(
      inline: inline,
      iconVisualExtent: iconVisualExtent,
      iconSlotExtent: iconSlotExtent,
      labelStyle: labelStyle,
      textScaler: textScaler,
      labelGap: labelGap,
    );
    if (metrics == null) {
      return null;
    }
    final slotCount = metrics.slotCount + (includeOverflowSlot ? 1 : 0);
    if (metrics.labeledCount == 0 || slotCount == 0) {
      return null;
    }
    if (axis == Axis.vertical) {
      return metrics.maxExpanded;
    }
    return metrics.maxExpanded +
        (slotCount - 1) * iconSlotExtent +
        (slotCount - 1) * gap;
  }

  static ({int labeledCount, int slotCount, double maxExpanded})?
  _labeledSelectionMetrics({
    required List<MorphToolbarItem> inline,
    required double iconVisualExtent,
    required double iconSlotExtent,
    required TextStyle labelStyle,
    required TextScaler textScaler,
    required double labelGap,
  }) {
    if (inline.any((MorphToolbarItem item) => item is MorphToolbarWidget)) {
      return null;
    }
    final actions = inline.whereType<MorphToolbarAction>().toList();
    if (actions.isEmpty) {
      return null;
    }
    var maxExpanded = iconSlotExtent;
    var labeledCount = 0;
    for (final action in actions) {
      final label = action.label;
      if (label == null || label.isEmpty) {
        continue;
      }
      labeledCount++;
      // Match [MorphToolbarIconButton]: visual + gap + label, then at least slot.
      final expanded = _maxDouble(
        iconSlotExtent,
        iconVisualExtent +
            labelGap +
            _measureLabelWidth(label, labelStyle, textScaler),
      );
      if (expanded > maxExpanded) {
        maxExpanded = expanded;
      }
    }
    return (
      labeledCount: labeledCount,
      slotCount: actions.length,
      maxExpanded: maxExpanded,
    );
  }

  static double _maxDouble(double a, double b) => a > b ? a : b;

  static double _measureLabelWidth(
    String label,
    TextStyle style,
    TextScaler textScaler,
  ) {
    final painter = TextPainter(
      text: TextSpan(text: label, style: style),
      maxLines: 1,
      textDirection: TextDirection.ltr,
      textScaler: textScaler,
    )..layout();
    return painter.width;
  }
}
