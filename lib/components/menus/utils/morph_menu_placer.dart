import 'package:flutter/widgets.dart';

import '../enums/morph_menu_anchor_position.dart';
import '../models/morph_menu_node.dart';
import '../styles/morph_menu_theme.dart';

/// Computed placement for an anchored menu popup.
@immutable
class MorphMenuPlacement {
  /// MorphMenuPlacement.
  const MorphMenuPlacement({
    required this.left,
    required this.width,
    required this.maxHeight,
    required this.scaleAlignment,
    required this.opensAbove,
    this.top,
    this.bottom,
  }) : assert(
         (top == null) != (bottom == null),
         'Exactly one of top or bottom must be set.',
       );

  /// left.

  final double left;

  /// Distance from the top of the screen when opening below the anchor.
  final double? top;

  /// Distance from the bottom of the screen when opening above the anchor.
  ///
  /// Pinning with [bottom] keeps the menu flush under the available space
  /// regardless of content height (unlike subtracting [maxHeight] from [top]).
  final double? bottom;

  /// width.

  final double width;

  /// maxHeight.
  final double maxHeight;

  /// scaleAlignment.
  final Alignment scaleAlignment;

  /// opensAbove.
  final bool opensAbove;
}

/// Collision-aware menu placement (Compose popup position provider).
abstract final class MorphMenuPlacer {
  const MorphMenuPlacer._();

  /// compute.
  static MorphMenuPlacement compute({
    required Size screenSize,
    required Rect anchorRect,
    required MorphMenuTheme theme,
    required MorphMenuAnchorPosition position,
    required TextDirection textDirection,
    required int approximateItemCount,
    double? preferredWidth,
  }) {
    final edge = theme.screenEdgePadding;
    final width = _resolveWidth(
      preferredWidth: preferredWidth,
      anchorRect: anchorRect,
      theme: theme,
    );
    final double itemExtent = theme.entryHeight + theme.itemGap;
    final double lower = theme.entryHeight * 2;
    final double upper = theme.maxHeight;
    final double approxHeight =
        (approximateItemCount * itemExtent + theme.verticalPadding * 2)
            .clamp(lower < upper ? lower : 0, upper)
            .toDouble();
    final spaceBelow = screenSize.height - anchorRect.bottom - edge;
    final spaceAbove = anchorRect.top - edge;
    final isRtl = textDirection == TextDirection.rtl;
    final isSide =
        position == MorphMenuAnchorPosition.end ||
        position == MorphMenuAnchorPosition.start;
    final opensAbove = _opensAbove(
      position: position,
      isSide: isSide,
      approxHeight: approxHeight,
      spaceAbove: spaceAbove,
      spaceBelow: spaceBelow,
    );
    final alignEnd = _alignEnd(position, isRtl);
    final horizontal = _resolveHorizontal(
      screenSize: screenSize,
      anchorRect: anchorRect,
      theme: theme,
      position: position,
      isSide: isSide,
      isRtl: isRtl,
      alignEnd: alignEnd,
      width: width,
      edge: edge,
    );
    final vertical = _resolveVertical(
      screenSize: screenSize,
      anchorRect: anchorRect,
      theme: theme,
      isSide: isSide,
      opensAbove: opensAbove,
      spaceAbove: spaceAbove,
      spaceBelow: spaceBelow,
      edge: edge,
      approxHeight: approxHeight,
    );
    return MorphMenuPlacement(
      left: horizontal.left,
      top: vertical.top,
      bottom: vertical.bottom,
      width: width,
      maxHeight: vertical.maxHeight,
      scaleAlignment: _scaleAlignment(
        isSide: isSide,
        opensTowardStart: horizontal.opensTowardStart,
        isClampedToLeft: horizontal.left <= edge + 0.5,
        alignEnd: alignEnd,
        opensAbove: opensAbove,
      ),
      opensAbove: opensAbove,
    );
  }

  /// Desktop context-menu placement for a surface of exactly [surfaceSize].
  ///
  /// Root menus ([isSubmenu] false) open with the surface's top-left corner at
  /// [anchorRect]'s top-left (the pointer) and flip to the left / above only
  /// when the surface would leave the viewport; if it fits neither way it is
  /// shifted inside the viewport and scrolls. RTL mirrors the horizontal
  /// preference. Submenus open beside the parent row ([anchorRect]) with their
  /// first row aligned to it, flip to the other side when there is no room and
  /// shift vertically to stay in view.
  ///
  /// The returned [MorphMenuPlacement] is in positioned-box coordinates: it is
  /// already outset by [shadowPad] on every side, and [MorphMenuPlacement.width]
  /// / [MorphMenuPlacement.maxHeight] include that margin.
  static MorphMenuPlacement computeDesktop({
    required Size screenSize,
    required Rect anchorRect,
    required Size surfaceSize,
    required double edge,
    required double shadowPad,
    required TextDirection textDirection,
    bool isSubmenu = false,
    double sideInset = 4,
    double sideOverlap = 2,
    double firstRowOffset = 4,
  }) {
    final bool isRtl = textDirection == TextDirection.rtl;
    final double maxSurfaceWidth = (screenSize.width - 2 * edge).clamp(
      0.0,
      double.infinity,
    );
    final double width = surfaceSize.width.clamp(0.0, maxSurfaceWidth);
    final double maxSurfaceHeight = (screenSize.height - 2 * edge).clamp(
      0.0,
      double.infinity,
    );
    final double height = surfaceSize.height.clamp(0.0, maxSurfaceHeight);

    // Horizontal.
    double left;
    var opensTowardStart = isRtl;
    if (isSubmenu) {
      final double rightSide = anchorRect.right + sideInset - sideOverlap;
      final double leftSide = anchorRect.left - sideInset + sideOverlap - width;
      final bool preferRight = !isRtl;
      final double first = preferRight ? rightSide : leftSide;
      final double second = preferRight ? leftSide : rightSide;
      bool fits(double l) => l >= edge && l + width <= screenSize.width - edge;
      if (fits(first)) {
        left = first;
        opensTowardStart = !preferRight;
      } else if (fits(second)) {
        left = second;
        opensTowardStart = preferRight;
      } else {
        left = first;
        opensTowardStart = !preferRight;
      }
    } else {
      final double x = anchorRect.left;
      final double first = isRtl ? x - width : x;
      final double second = isRtl ? x : x - width;
      bool fits(double l) => l >= edge && l + width <= screenSize.width - edge;
      if (fits(first)) {
        left = first;
        opensTowardStart = isRtl;
      } else if (fits(second)) {
        left = second;
        opensTowardStart = !isRtl;
      } else {
        left = first;
        opensTowardStart = isRtl;
      }
    }
    left = left.clamp(edge, screenSize.width - width - edge).toDouble();

    // Vertical.
    final double y = isSubmenu
        ? anchorRect.top - firstRowOffset
        : anchorRect.top;
    final double minTop = edge;
    final double maxBottom = screenSize.height - edge;
    double? top;
    double? bottom;
    var opensAbove = false;
    if (y + height <= maxBottom) {
      top = y < minTop ? minTop : y;
    } else if (!isSubmenu && y - height >= minTop) {
      // Flip above the pointer: pin the bottom edge to it.
      opensAbove = true;
      bottom = screenSize.height - y;
    } else {
      // Neither side fits: shift inside the viewport (submenus, tall menus).
      top = (maxBottom - height).clamp(minTop, maxBottom).toDouble();
    }

    final Alignment scale = Alignment(
      opensTowardStart ? 1.0 : -1.0,
      opensAbove ? 1.0 : -1.0,
    );
    return MorphMenuPlacement(
      left: left - shadowPad,
      top: top == null ? null : top - shadowPad,
      bottom: bottom == null ? null : bottom - shadowPad,
      width: width + shadowPad * 2,
      maxHeight: maxSurfaceHeight + shadowPad * 2,
      scaleAlignment: scale,
      opensAbove: opensAbove,
    );
  }

  static double _resolveWidth({
    required double? preferredWidth,
    required Rect anchorRect,
    required MorphMenuTheme theme,
  }) {
    return (preferredWidth ??
            (anchorRect.width + 176.0).clamp(theme.minWidth, theme.maxWidth))
        .clamp(theme.minWidth, theme.maxWidth);
  }

  static bool _opensAbove({
    required MorphMenuAnchorPosition position,
    required bool isSide,
    required double approxHeight,
    required double spaceAbove,
    required double spaceBelow,
  }) {
    if (isSide) {
      return false;
    }
    final preferAbove =
        position == MorphMenuAnchorPosition.topStart ||
        position == MorphMenuAnchorPosition.topEnd;
    if (preferAbove) {
      return spaceAbove >= approxHeight || spaceAbove > spaceBelow;
    }
    return spaceBelow < approxHeight && spaceAbove > spaceBelow;
  }

  static bool _alignEnd(MorphMenuAnchorPosition position, bool isRtl) {
    return switch (position) {
      MorphMenuAnchorPosition.bottomEnd ||
      MorphMenuAnchorPosition.topEnd ||
      MorphMenuAnchorPosition.end => !isRtl,
      MorphMenuAnchorPosition.bottomStart ||
      MorphMenuAnchorPosition.topStart ||
      MorphMenuAnchorPosition.start => isRtl,
    };
  }

  static ({double left, bool opensTowardStart}) _resolveHorizontal({
    required Size screenSize,
    required Rect anchorRect,
    required MorphMenuTheme theme,
    required MorphMenuAnchorPosition position,
    required bool isSide,
    required bool isRtl,
    required bool alignEnd,
    required double width,
    required double edge,
  }) {
    late double left;
    var opensTowardStart = false;
    if (isSide) {
      final side = _sideLeft(
        anchorRect: anchorRect,
        theme: theme,
        position: position,
        isRtl: isRtl,
        width: width,
        edge: edge,
        screenWidth: screenSize.width,
      );
      left = side.left;
      opensTowardStart = side.opensTowardStart;
    } else if (alignEnd) {
      left = anchorRect.right - width;
    } else {
      left = anchorRect.left;
    }
    left = left.clamp(edge, screenSize.width - width - edge);
    return (left: left, opensTowardStart: opensTowardStart);
  }

  static ({double left, bool opensTowardStart}) _sideLeft({
    required Rect anchorRect,
    required MorphMenuTheme theme,
    required MorphMenuAnchorPosition position,
    required bool isRtl,
    required double width,
    required double edge,
    required double screenWidth,
  }) {
    final openEnd = position == MorphMenuAnchorPosition.end;
    final preferRight = (openEnd && !isRtl) || (!openEnd && isRtl);
    if (preferRight) {
      var left = anchorRect.right + theme.anchorOffset;
      var opensTowardStart = false;
      if (left + width > screenWidth - edge) {
        left = anchorRect.left - width - theme.anchorOffset;
        opensTowardStart = true;
      }
      return (left: left, opensTowardStart: opensTowardStart);
    }
    var left = anchorRect.left - width - theme.anchorOffset;
    var opensTowardStart = true;
    if (left < edge) {
      left = anchorRect.right + theme.anchorOffset;
      opensTowardStart = false;
    }
    return (left: left, opensTowardStart: opensTowardStart);
  }

  static ({double? top, double? bottom, double maxHeight}) _resolveVertical({
    required Size screenSize,
    required Rect anchorRect,
    required MorphMenuTheme theme,
    required bool isSide,
    required bool opensAbove,
    required double spaceAbove,
    required double spaceBelow,
    required double edge,
    required double approxHeight,
  }) {
    final maxHeight =
        (isSide
                ? (screenSize.height - edge - edge)
                : (opensAbove ? spaceAbove : spaceBelow))
            .clamp(0.0, theme.maxHeight);
    if (isSide) {
      // Top-align with the triggering row. Do not use [maxHeight] as the
      // intrinsic height — it is only a scroll viewport cap; using it pushed
      // cascading menus to the top of the screen.
      final heightBudget = approxHeight.clamp(0.0, maxHeight);
      var top = anchorRect.top;
      if (top + heightBudget > screenSize.height - edge) {
        top = screenSize.height - edge - heightBudget;
      }
      top = top.clamp(edge, screenSize.height - edge);
      return (top: top, bottom: null, maxHeight: maxHeight);
    }
    if (opensAbove) {
      // Pin the menu's bottom edge just above the anchor so short menus sit
      // flush (same gap as opening below), instead of top = anchor - maxHeight.
      return (
        top: null,
        bottom: screenSize.height - anchorRect.top + theme.anchorOffset,
        maxHeight: maxHeight,
      );
    }
    return (
      top: anchorRect.bottom + theme.anchorOffset,
      bottom: null,
      maxHeight: maxHeight,
    );
  }

  static Alignment _scaleAlignment({
    required bool isSide,
    required bool opensTowardStart,
    required bool isClampedToLeft,
    required bool alignEnd,
    required bool opensAbove,
  }) {
    if (isSide) {
      return Alignment(opensTowardStart ? 1.0 : -1.0, -1);
    }
    final h = isClampedToLeft ? -1.0 : (alignEnd ? 1.0 : -1.0);
    return Alignment(h, opensAbove ? 1.0 : -1.0);
  }

  /// Rough visible row count for height estimation.
  static int approximateItemCount(List<MorphMenuNode> nodes) {
    var count = 0;
    for (final node in nodes) {
      switch (node) {
        case MorphMenuGroup(:final children, :final label):
          if (label != null) {
            count += 1;
          }
          count += approximateItemCount(children);
        case MorphMenuDivider():
          count += 1;
        case MorphMenuEntry() ||
            MorphMenuSelectable() ||
            MorphMenuToggleable() ||
            MorphMenuSubmenu() ||
            MorphMenuWidget():
          count += 1;
      }
    }
    return count == 0 ? 1 : count;
  }
}
