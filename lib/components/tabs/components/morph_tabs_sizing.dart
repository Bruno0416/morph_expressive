part of '../morph_tabs.dart';

/// Layout sizing helpers (stacked icon/label detection, content width, and
/// scroll-vs-fixed decision) for [MorphTabs].
extension _MorphTabsSizing on _MorphTabsState {
  bool _stacked(MorphTabTheme theme) {
    if (widget.variant != MorphTabsVariant.primary) {
      return false;
    }
    return widget.tabs.any(
      (MorphTab tab) => tab.icon != null && tab.label != null,
    );
  }

  double _contentWidth(MorphTab tab, TextStyle style, MorphTabTheme theme) {
    var textWidth = 0.0;
    final String? label = tab.label;
    if (label != null) {
      final painter = TextPainter(
        text: TextSpan(text: label, style: style),
        maxLines: 1,
        textDirection: Directionality.of(context),
      )..layout();
      textWidth = painter.width;
      painter.dispose();
    }
    final bool stacked =
        widget.variant == MorphTabsVariant.primary &&
        tab.icon != null &&
        tab.label != null;
    if (stacked) {
      return math.max(theme.iconSize, textWidth);
    }
    var width = textWidth;
    if (tab.icon != null) {
      width += theme.iconSize;
      if (tab.label != null) {
        width += theme.inlineIconLabelGap;
      }
    }
    if (_inlineBadge(tab)) {
      width += theme.inlineBadgeGap + 24;
    }
    return width;
  }

  bool _useScroll(double maxWidth, MorphTabTheme theme, TextStyle style) {
    if (!maxWidth.isFinite) {
      return false;
    }
    final bool? forced = widget.scrollable;
    if (forced != null) {
      return forced;
    }
    if (widget.alignment == MorphTabsAlignment.fill) {
      final double slot = maxWidth / widget.tabs.length;
      for (final MorphTab tab in widget.tabs) {
        if (_contentWidth(tab, style, theme) > slot) {
          return true;
        }
      }
      return false;
    }
    final double widest = widget.tabs
        .map((MorphTab tab) => _contentWidth(tab, style, theme))
        .reduce(math.max);
    return widest * widget.tabs.length > maxWidth;
  }
}
