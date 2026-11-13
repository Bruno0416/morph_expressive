part of '../morph_tabs.dart';

/// Layout sizing helpers (stacked icon/label detection, content width, and
/// scroll-vs-fixed decision) for [MorphTabs].
///
/// These estimates only decide *whether* the bar scrolls. Indicator geometry is
/// never estimated: it is read from the laid out tabs (see `_measure`).
extension _MorphTabsSizing on _MorphTabsState {
  bool _stacked(MorphTabTheme theme) {
    if (widget.variant != MorphTabsVariant.primary) {
      return false;
    }
    return widget.tabs.any(
      (MorphTab tab) => tab.icon != null && tab.label != null,
    );
  }

  /// Horizontal space between a tab edge and its content when the tab hugs the
  /// content. A surface reserves its uniform inset plus its content padding, so
  /// the surface edge sits exactly one inset from the neighbouring container.
  double _slotPadding(MorphTabTheme theme) => _spec.isSurface
      ? _spec.surfaceInset + _spec.padding
      : theme.scrollableTabPadding;

  /// Width of the badge slot after the label, matching `_badge`.
  double _inlineBadgeSlot(MorphTab tab) => tab.badgeDot ? 6 : 32;

  double _contentWidth(MorphTab tab, TextStyle style, MorphTabTheme theme) {
    var textWidth = 0.0;
    final String? label = tab.label;
    if (label != null) {
      final painter = TextPainter(
        text: TextSpan(text: label, style: style),
        maxLines: 1,
        textDirection: Directionality.of(context),
        textScaler: MediaQuery.textScalerOf(context),
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
      width += theme.inlineBadgeGap + _inlineBadgeSlot(tab);
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
    if (widget.alignment == MorphTabsAlignment.content) {
      var total = 0.0;
      for (final MorphTab tab in widget.tabs) {
        total += _contentWidth(tab, style, theme) + _slotPadding(theme) * 2;
      }
      return total > maxWidth;
    }
    final double widest = widget.tabs
        .map((MorphTab tab) => _contentWidth(tab, style, theme))
        .reduce(math.max);
    return widest * widget.tabs.length > maxWidth;
  }

  /// Hash of everything that changes the content of the tabs.
  Object _tabsSignature() {
    return Object.hashAll(<Object?>[
      for (final MorphTab tab in widget.tabs)
        Object.hash(
          tab.label,
          tab.id,
          tab.semanticLabel,
          tab.badgeCount,
          tab.badgeLabel,
          tab.badgeDot,
          tab.badgeInline,
          tab.icon?.runtimeType,
          tab.icon?.key,
        ),
    ]);
  }
}
