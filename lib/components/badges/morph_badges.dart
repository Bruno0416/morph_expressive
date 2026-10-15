import 'package:flutter/widgets.dart';

import '../../foundations/foundations.dart';
import 'components/morph_badge_layout.dart';
import 'enums/morph_badge_alignment.dart';
import 'styles/morph_badge_theme.dart';

export 'enums/morph_badge_alignment.dart';
export 'styles/morph_badge_theme.dart';

/// A Material 3 Expressive badge.
///
/// Shows a small dot, a numeric count, or a short status [label] anchored to a
/// top edge of [child].
///
/// [alignment] places the indicator at the top-left, top-center, or top-right
/// of [child]'s box. `topRight` is trailing and `topLeft` is leading; both
/// mirror under RTL. [offset] overrides the theme Compose-style placement
/// (distance from the anchored corner to the badge's bottom-leading corner).
/// The indicator overlays without expanding or shifting [child].
///
/// Content priority: [showDot] > [label] > formatted [count].
class MorphBadge extends StatelessWidget {
  /// MorphBadge.
  const MorphBadge({
    super.key,
    required this.child,
    this.count,
    this.label,
    this.showDot = false,
    this.maxCount = 999,
    this.alignment = MorphBadgeAlignment.topRight,
    this.offset,
    this.backgroundColor,
    this.foregroundColor,
    this.semanticLabel,
  }) : assert(count == null || count >= 0, 'count must be non-negative');

  /// child.
  final Widget child;

  /// Numeric count for the large badge. Ignored when [showDot] or [label] is set.
  final int? count;

  /// Status text for the large badge. Preferred over [count] when both are set.
  final String? label;

  /// When true, shows a small dot badge (takes precedence over [label]/[count]).
  final bool showDot;

  /// Cap for [count] formatting (`{maxCount}+`). Spec default: 999.
  final int maxCount;

  /// Top-edge placement of the indicator. Defaults to [MorphBadgeAlignment.topRight]
  /// (trailing; mirrors in RTL).
  final MorphBadgeAlignment alignment;

  /// Override theme placement offset (corner → badge bottom-leading, W×H).
  final Offset? offset;

  /// backgroundColor.
  final Color? backgroundColor;

  /// foregroundColor.
  final Color? foregroundColor;

  /// semanticLabel.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final bool hasLabel = label != null && label!.isNotEmpty;
    if (!showDot && count == null && !hasLabel) {
      return child;
    }

    final theme = MorphTheme.of(context);
    final scheme = theme.colorScheme;
    final badgeTheme = theme.badgeTheme;
    final bool isDot = showDot;
    final effectiveOffset =
        offset ?? (isDot ? badgeTheme.smallOffset : badgeTheme.largeOffset);
    final bg = backgroundColor ?? badgeTheme.containerColor(scheme);
    final fg = foregroundColor ?? badgeTheme.labelColor(scheme);
    final textDirection = Directionality.of(context);

    final Widget badge = isDot
        ? _dot(badgeTheme, bg)
        : _label(
            theme.typeScale,
            badgeTheme,
            scheme,
            bg,
            fg,
            hasLabel ? label! : _format(count!, maxCount),
          );

    return MorphComponentTheme(
      builder: (context) => MorphBadgeLayout(
        alignment: alignment,
        offset: effectiveOffset,
        textDirection: textDirection,
        content: child,
        indicator: Semantics(
          label: semanticLabel ?? _defaultSemanticLabel(isDot: isDot),
          excludeSemantics: true,
          child: badge,
        ),
      ),
    );
  }

  String _defaultSemanticLabel({required bool isDot}) {
    if (isDot) {
      return 'New notification';
    }
    if (label != null && label!.isNotEmpty) {
      return label!;
    }
    final int value = count!;
    if (value == 1) {
      return 'One new notification';
    }
    return '$value new notifications';
  }

  Widget _dot(MorphBadgeTheme badgeTheme, Color bg) {
    return Container(
      width: badgeTheme.dotSize,
      height: badgeTheme.dotSize,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: badgeTheme.dotBorderRadius,
      ),
    );
  }

  Widget _label(
    MorphTypeScale typeScale,
    MorphBadgeTheme badgeTheme,
    MorphColorScheme scheme,
    Color bg,
    Color fg,
    String text,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: badgeTheme.labelHorizontalPadding,
        vertical: badgeTheme.labelVerticalPadding,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: badgeTheme.labelBorderRadius,
      ),
      constraints: BoxConstraints(
        minWidth: badgeTheme.labelMinSize,
        minHeight: badgeTheme.labelMinSize,
      ),
      alignment: Alignment.center,
      child: DefaultTextStyle(
        style: badgeTheme.labelStyle(typeScale, scheme).copyWith(color: fg),
        child: Text(text, textAlign: TextAlign.center),
      ),
    );
  }

  String _format(int value, int max) => value > max ? '$max+' : '$value';
}
