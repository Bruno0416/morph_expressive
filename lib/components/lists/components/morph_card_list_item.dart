import 'package:flutter/widgets.dart';

import '../../../foundations/foundations.dart';
import '../../cards/enums/morph_card_variant.dart';
import '../enums/morph_list_enums.dart';
import 'morph_card_radius_motion.dart';
import 'morph_expandable_nest_scope.dart';
import 'morph_list_drag_proxy_scope.dart';
import 'morph_list_item_scope.dart';
import 'morph_list_row_surface.dart';

/// Internal helper to calculate [MorphCardPosition] based on index and total.
MorphCardPosition calculateCardPosition(int index, int total) => total == 1
    ? MorphCardPosition.single
    : index == 0
    ? MorphCardPosition.first
    : index == total - 1
    ? MorphCardPosition.last
    : MorphCardPosition.middle;

/// Internal helper to calculate [BorderRadius] based on [MorphCardPosition].
///
/// When [embedded] is true, items use [innerRadius] by default so the list can
/// sit under another card row. Set [closeBottom] when the parent expandable is
/// last/single, or rounds its sublist bottom, so the nested last (or single)
/// row uses [outerRadius] on the bottom corners.
BorderRadius calculateCardRadius({
  required MorphCardPosition position,
  required double outerRadius,
  required double innerRadius,
  bool embedded = false,
  bool closeBottom = false,
}) {
  if (embedded) {
    final bool isTail =
        position == MorphCardPosition.last || position == MorphCardPosition.single;
    if (closeBottom && isTail) {
      return BorderRadius.vertical(
        top: Radius.circular(innerRadius),
        bottom: Radius.circular(outerRadius),
      );
    }
    return BorderRadius.circular(innerRadius);
  }
  switch (position) {
    case MorphCardPosition.single:
      return BorderRadius.circular(outerRadius);
    case MorphCardPosition.first:
      return BorderRadius.vertical(
        top: Radius.circular(outerRadius),
        bottom: Radius.circular(innerRadius),
      );
    case MorphCardPosition.last:
      return BorderRadius.vertical(
        top: Radius.circular(innerRadius),
        bottom: Radius.circular(outerRadius),
      );
    case MorphCardPosition.middle:
      return BorderRadius.circular(innerRadius);
  }
}

/// A single card item within a card-backed list.
class MorphCardListItem extends StatelessWidget {
  /// MorphCardListItem.
  const MorphCardListItem({
    required this.index,
    required this.position,
    required this.child,
    required this.outerRadius,
    required this.innerRadius,
    required this.gap,
    this.embedded = false,
    this.color,
    this.padding,
    this.onTap,
    this.onLongPress,
    this.semanticLabel,
    this.mouseCursor,
    this.haptic = MorphHapticFeedback.none,
    this.variant = MorphCardVariant.filled,
    this.border,
    this.resolvedColor,
    this.resolvedBorderRadius,
    super.key,
  });

  /// index.

  final int index;

  /// position.
  final MorphCardPosition position;

  /// child.
  final Widget child;

  /// outerRadius.
  final double outerRadius;

  /// innerRadius.
  final double innerRadius;

  /// gap.
  final double gap;

  /// When true, first/last/single use [innerRadius] like middle items, unless
  /// an ancestor [MorphExpandableNestScope] requests closing the bottom.
  final bool embedded;

  /// color.
  final Color? color;

  /// padding.
  final EdgeInsetsGeometry? padding;

  /// Function.
  final void Function(int index)? onTap;

  /// Function.
  final void Function(int index)? onLongPress;

  /// semanticLabel.
  final String? semanticLabel;

  /// mouseCursor.
  final MouseCursor? mouseCursor;

  /// haptic.
  final MorphHapticFeedback haptic;

  /// Card variant for this item.
  final MorphCardVariant variant;

  /// Optional card outline.
  final BorderSide? border;

  /// Per-item color override. When null for an index, uses [color].
  final Color? resolvedColor;

  /// Per-item radius override. When null, uses position-based radii.
  final BorderRadius? resolvedBorderRadius;

  @override
  Widget build(BuildContext context) {
    final theme = MorphTheme.of(context);
    final scheme = theme.colorScheme;
    final cardListTheme = theme.listTheme.cardList;
    final MorphListDragProxyScope? dragProxy = MorphListDragProxyScope.maybeOf(
      context,
    );

    final MorphExpandableNestScope? nest = MorphExpandableNestScope.maybeOf(
      context,
    );
    final bool closeBottom = nest?.closeBottom ?? false;
    final double effectiveOuter = nest?.outerRadius ?? outerRadius;

    final BorderRadius borderRadius = dragProxy != null
        ? BorderRadius.circular(dragProxy.radius)
        : (resolvedBorderRadius ??
              calculateCardRadius(
                position: position,
                outerRadius: effectiveOuter,
                innerRadius: innerRadius,
                embedded: embedded,
                closeBottom: closeBottom,
              ));

    final MorphCardVariant effectiveVariant = dragProxy != null
        ? MorphCardVariant.filled
        : variant;
    final BorderSide? effectiveBorder = dragProxy != null ? null : border;
    final Color? inheritedSurface = color == null && resolvedColor == null
        ? nest?.surfaceColor
        : null;
    final Color? effectiveColor = dragProxy != null
        ? dragProxy.color
        : (resolvedColor ??
              color ??
              inheritedSurface ??
              (variant == MorphCardVariant.outlined
                  ? null
                  : cardListTheme.backgroundColor(scheme, variant: variant)));

    final bool isLast =
        position == MorphCardPosition.last || position == MorphCardPosition.single;

    final VoidCallback? wrappedOnTap = onTap != null
        ? () => onTap!(index)
        : null;
    final VoidCallback? wrappedOnLongPress = onLongPress != null
        ? () => onLongPress!(index)
        : null;
    final parentPads = padding != null;

    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : gap),
      child: MorphCardRadiusMotion(
        radius: borderRadius,
        builder: (BuildContext context, BorderRadius animatedRadius) {
          return MorphListRowSurface(
            index: index,
            variant: effectiveVariant,
            radius: animatedRadius,
            color: effectiveColor,
            border: effectiveBorder,
            elevation: dragProxy != null ? 0 : null,
            padding: parentPads ? padding! : EdgeInsets.zero,
            onTap: dragProxy != null ? null : wrappedOnTap,
            onLongPress: dragProxy != null ? null : wrappedOnLongPress,
            dragged: dragProxy != null,
            mouseCursor: mouseCursor,
            semanticLabel: semanticLabel,
            haptic: haptic,
            child: MorphListItemScope(padsChild: parentPads, child: child),
          );
        },
      ),
    );
  }
}
