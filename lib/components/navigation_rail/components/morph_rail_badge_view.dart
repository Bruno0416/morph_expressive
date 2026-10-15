import 'package:flutter/widgets.dart';

import 'package:morph_expressive/components/badges/morph_badges.dart';

import '../../../foundations/foundations.dart';
import '../styles/morph_navigation_rail_theme.dart';

/// Navigation rail badge using [MorphBadge].
///
/// - With [child]: anchors to that widget (collapsed rail — badge on icon).
/// - Without [child]: standalone indicator (expanded rail — after the label).
///
/// `count == 0` shows a small dot. Null [count] and [showDot] false hides the
/// badge (returns [child] or [SizedBox.shrink]).
class MorphRailBadge extends StatelessWidget {
  /// Anchors a badge to [child] (collapsed / icon placement).
  const MorphRailBadge({
    super.key,
    required Widget this.child,
    this.count,
    this.showDot = false,
    this.maxCount = 999,
  }) : assert(
         count == null || count >= 0,
         'count must be null or non-negative',
       );

  /// Standalone badge for expanded rail trailing placement (after the label).
  const MorphRailBadge.standalone({
    super.key,
    this.count,
    this.showDot = false,
    this.maxCount = 999,
  }) : child = null,
       assert(
         count == null || count >= 0,
         'count must be null or non-negative',
       );

  /// Icon (or other content) the badge anchors to. Null for standalone.
  final Widget? child;

  /// Numeric count. `0` is treated as a small dot.
  final int? count;

  /// Force a small dot badge.
  final bool showDot;

  /// Cap for count formatting.
  final int maxCount;

  @override
  Widget build(BuildContext context) {
    final bool dot = showDot || count == 0;
    if (!dot && count == null) {
      return child ?? const SizedBox.shrink();
    }
    final theme = MorphTheme.of(context).navigationRailTheme;
    final morph = MorphTheme.of(context);
    final badgeTheme = morph.badgeTheme;
    final scheme = morph.colorScheme;
    final bg = theme.badgeBackgroundResolved(scheme);
    final fg = theme.badgeLabelResolved(scheme);

    if (child != null) {
      return MorphBadge(
        showDot: dot,
        count: dot ? null : count,
        maxCount: maxCount,
        backgroundColor: bg,
        foregroundColor: fg,
        child: child!,
      );
    }

    // Standalone trailing indicator (expanded rail).
    if (dot) {
      return Semantics(
        label: 'New notification',
        excludeSemantics: true,
        child: Container(
          width: badgeTheme.dotSize,
          height: badgeTheme.dotSize,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: badgeTheme.dotBorderRadius,
          ),
        ),
      );
    }
    final value = count!;
    final text = value > maxCount ? '$maxCount+' : '$value';
    final a11y = value == 1
        ? 'One new notification'
        : '$value new notifications';
    return Semantics(
      label: a11y,
      excludeSemantics: true,
      child: Container(
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
          style: badgeTheme
              .labelStyle(morph.typeScale, scheme)
              .copyWith(color: fg),
          child: Text(text, textAlign: TextAlign.center),
        ),
      ),
    );
  }
}
