part of '../morph_navigation_bar.dart';

/// Resolved layout metrics for one destination band, computed once per
/// build and threaded through the destination slots.
typedef _NavBarBandMetrics = ({
  bool wide,
  TextStyle label,
  double slot,
  ({double top, double bottom}) pad,
  double indicatorHeight,
  double radius,
  double height,
  EdgeInsetsGeometry edgeInset,
  int maxLines,
  TextOverflow overflow,
});

/// Widget-building helpers for `_MorphNavigationBarState`, split out to keep
/// the state class under the component length guidelines.
extension _MorphNavigationBarBuild on _MorphNavigationBarState {
  MorphNavBarLayout _resolveLayout(
    double maxWidth,
    MorphNavigationBarTheme theme,
  ) {
    if (!widget.autoLayout) {
      return widget.layout;
    }
    final double breakpoint = widget.wideBreakpoint ?? theme.wideBreakpoint;
    return maxWidth >= breakpoint
        ? MorphNavBarLayout.wide
        : MorphNavBarLayout.compact;
  }

  MainAxisAlignment _wideMainAxisAlignment() {
    return switch (widget.alignment) {
      MorphNavBarAlignment.start => MainAxisAlignment.start,
      MorphNavBarAlignment.center => MainAxisAlignment.center,
      MorphNavBarAlignment.end => MainAxisAlignment.end,
    };
  }

  bool _showsIcon(MorphNavigationBarDestination destination, bool selected) {
    if (!destination.hasIcon) {
      return false;
    }
    return switch (widget.iconBehavior) {
      MorphNavBarIconBehavior.alwaysShow => true,
      MorphNavBarIconBehavior.onlySelected => selected,
      MorphNavBarIconBehavior.alwaysHide => false,
    };
  }

  bool _showsLabel(MorphNavigationBarDestination destination, bool selected) {
    if (!destination.hasLabel) {
      return false;
    }
    return switch (widget.labelBehavior) {
      MorphNavBarLabelBehavior.alwaysShow => true,
      MorphNavBarLabelBehavior.onlySelected => selected,
      MorphNavBarLabelBehavior.alwaysHide => false,
    };
  }

  double _textWidth(String text, TextStyle style, TextScaler scaler) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textScaler: scaler,
      maxLines: 1,
      textDirection: Directionality.of(context),
    )..layout();
    final double width = painter.width;
    painter.dispose();
    return width;
  }

  double _textHeight(
    String text,
    TextStyle style,
    TextScaler scaler,
    int maxLines,
    double maxWidth,
  ) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textScaler: scaler,
      maxLines: maxLines,
      textDirection: Directionality.of(context),
    )..layout(maxWidth: math.max(1, maxWidth));
    final double height = painter.height;
    painter.dispose();
    return height;
  }

  double _slotWidth(
    MorphNavigationBarTheme theme,
    TextStyle style,
    TextScaler scaler,
  ) {
    final double? forced = widget.wideDestinationWidth;
    if (forced != null) {
      return forced;
    }
    var widest = 0.0;
    for (final MorphNavigationBarDestination destination
        in widget.destinations) {
      double widthFor({required bool icon, required bool label}) {
        var width = theme.horizontalIndicatorInset * 2;
        if (icon) {
          width += theme.iconSize;
        }
        if (icon && label) {
          width += theme.horizontalIconLabelGap;
        }
        if (label) {
          width += _textWidth(destination.label!, style, scaler);
        }
        return width;
      }

      widest = math.max(
        widest,
        math.max(
          widthFor(
            icon: _showsIcon(destination, true),
            label: _showsLabel(destination, true),
          ),
          widthFor(
            icon: _showsIcon(destination, false),
            label: _showsLabel(destination, false),
          ),
        ),
      );
    }
    return widest;
  }

  double _labelBlock({
    required bool wide,
    required double cellWidth,
    required MorphNavigationBarTheme theme,
    required TextStyle style,
    required TextScaler scaler,
    required int maxLines,
  }) {
    var tallest = 0.0;
    for (final MorphNavigationBarDestination destination
        in widget.destinations) {
      if (!_showsLabel(destination, true) && !_showsLabel(destination, false)) {
        continue;
      }
      final bool icon = _showsIcon(destination, true);
      final double maxWidth = wide
          ? cellWidth -
                theme.horizontalIndicatorInset * 2 -
                (icon ? theme.iconSize + theme.horizontalIconLabelGap : 0)
          : cellWidth;
      tallest = math.max(
        tallest,
        _textHeight(destination.label!, style, scaler, maxLines, maxWidth),
      );
    }
    return tallest;
  }

  ({double top, double bottom}) _bandPadding(
    MorphNavigationBarTheme theme,
    bool wide,
  ) {
    final double extra = widget.size == MorphNavBarSize.medium
        ? theme.baselineExtraPadding
        : 0;
    var top =
        (wide ? theme.horizontalPadding : theme.verticalPaddingTop) + extra;
    var bottom =
        (wide ? theme.horizontalPadding : theme.verticalPaddingBottom) + extra;
    if (widget.density == MorphNavBarDensity.compact) {
      final double cut = theme.compactHeightReduction / 2;
      top = math.max(0, top - cut);
      bottom = math.max(0, bottom - cut);
    }
    return (top: top, bottom: bottom);
  }

  Widget _buildNavigationBar(BuildContext context) {
    final MorphThemeData morph = MorphTheme.of(context);
    final MorphNavigationBarTheme theme = morph.navigationBarTheme;
    final MorphColorScheme scheme = morph.colorScheme;
    final MorphNavMetrics metrics = theme.metrics(
      widget.density,
      morph.spacing,
    );
    final Color background =
        widget.backgroundColor ?? theme.containerColor(scheme);
    final ShapeBorder shape = theme.containerShape(widget.shapeFamily);
    final double bottomInset = widget.safeArea
        ? MorphSafeArea.bottomOf(context)
        : 0.0;
    final Color indicator =
        widget.indicatorColor ?? theme.indicatorColor(scheme);
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final bool shown = _shown(context);

    Widget nav = Material(
      color: background,
      elevation: widget.elevation ?? theme.elevation,
      shadowColor: theme.shadowColor(scheme),
      surfaceTintColor: const Color(0x00000000),
      shape: shape,
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomInset),
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return _buildBand(
              context,
              morph: morph,
              theme: theme,
              scheme: scheme,
              metrics: metrics,
              indicator: indicator,
              maxWidth: constraints.maxWidth,
            );
          },
        ),
      ),
    );
    nav = Padding(padding: widget.padding ?? EdgeInsets.zero, child: nav);
    nav = CallbackShortcuts(
      bindings: <ShortcutActivator, VoidCallback>{
        const SingleActivator(LogicalKeyboardKey.arrowLeft): () =>
            _move(rtl ? 1 : -1),
        const SingleActivator(LogicalKeyboardKey.arrowRight): () =>
            _move(rtl ? -1 : 1),
      },
      child: ClipRect(
        child: AnimatedAlign(
          alignment: Alignment.bottomCenter,
          heightFactor: shown ? 1 : 0,
          duration: MorphMotion.short4,
          curve: MorphMotion.enter,
          child: nav,
        ),
      ),
    );
    nav = ExcludeSemantics(excluding: !shown, child: nav);
    if (widget.semanticLabel != null) {
      nav = Semantics(container: true, label: widget.semanticLabel, child: nav);
    }
    return nav;
  }

  /// Resolves once-per-layout band metrics (wide/compact, label style,
  /// slot width, padding, indicator size, and outer height/inset).
  _NavBarBandMetrics _resolveBandMetrics(
    BuildContext context, {
    required MorphThemeData morph,
    required MorphNavigationBarTheme theme,
    required double maxWidth,
  }) {
    final wide = _resolveLayout(maxWidth, theme) == MorphNavBarLayout.wide;
    final TextScaler scaler = MediaQuery.textScalerOf(context);
    final double scale = theme.labelFontSize == 0
        ? 1
        : scaler.scale(theme.labelFontSize) / theme.labelFontSize;
    final int maxLines = scale <= 1
        ? theme.restingLabelMaxLines
        : theme.scaledLabelMaxLines;
    final TextOverflow overflow = scale > theme.truncationTextScale
        ? TextOverflow.ellipsis
        : TextOverflow.clip;
    final TextStyle measure = theme.labelStyle(morph.typeScale, selected: true);
    final TextStyle label = theme.labelStyle(morph.typeScale);
    final double slot = _slotWidth(theme, measure, scaler);
    final double cell = wide
        ? slot
        : maxWidth / math.max(1, widget.destinations.length);
    final double labelHeight = _labelBlock(
      wide: wide,
      cellWidth: cell,
      theme: theme,
      style: measure,
      scaler: scaler,
      maxLines: maxLines,
    );
    final ({double top, double bottom}) pad = _bandPadding(theme, wide);
    final double indicatorHeight = wide
        ? math.max(theme.horizontalIndicatorHeight, labelHeight)
        : theme.verticalIndicatorHeight;
    final double natural = wide
        ? pad.top + indicatorHeight + pad.bottom
        : pad.top +
              theme.verticalIndicatorHeight +
              (labelHeight > 0 ? theme.verticalIconLabelGap : 0) +
              labelHeight +
              pad.bottom;
    var minHeight = widget.size == MorphNavBarSize.small
        ? theme.heightSmall
        : theme.heightMedium;
    if (widget.density == MorphNavBarDensity.compact) {
      minHeight -= theme.compactHeightReduction;
    }
    final double height = math.max(minHeight, natural);
    final double radius = wide
        ? indicatorHeight / 2
        : theme.verticalIndicatorRadius;
    final EdgeInsetsGeometry edgeInset = !wide
        ? EdgeInsets.zero
        : switch (widget.alignment) {
            MorphNavBarAlignment.start => EdgeInsetsDirectional.only(
              start: theme.wideEdgePadding,
            ),
            MorphNavBarAlignment.end => EdgeInsetsDirectional.only(
              end: theme.wideEdgePadding,
            ),
            MorphNavBarAlignment.center => EdgeInsets.zero,
          };
    return (
      wide: wide,
      label: label,
      slot: slot,
      pad: pad,
      indicatorHeight: indicatorHeight,
      radius: radius,
      height: height,
      edgeInset: edgeInset,
      maxLines: maxLines,
      overflow: overflow,
    );
  }

  Widget _buildBand(
    BuildContext context, {
    required MorphThemeData morph,
    required MorphNavigationBarTheme theme,
    required MorphColorScheme scheme,
    required MorphNavMetrics metrics,
    required Color indicator,
    required double maxWidth,
  }) {
    final _NavBarBandMetrics band = _resolveBandMetrics(
      context,
      morph: morph,
      theme: theme,
      maxWidth: maxWidth,
    );
    return SizedBox(
      height: band.height,
      width: double.infinity,
      child: Padding(
        padding: band.edgeInset,
        child: Row(
          spacing: band.wide ? theme.wideItemGap : theme.itemGap,
          mainAxisAlignment: band.wide
              ? _wideMainAxisAlignment()
              : MainAxisAlignment.start,
          children: _destinationSlots(
            theme: theme,
            scheme: scheme,
            metrics: metrics,
            indicator: indicator,
            band: band,
          ),
        ),
      ),
    );
  }

  List<Widget> _destinationSlots({
    required MorphNavigationBarTheme theme,
    required MorphColorScheme scheme,
    required MorphNavMetrics metrics,
    required Color indicator,
    required _NavBarBandMetrics band,
  }) {
    return <Widget>[
      for (int i = 0; i < widget.destinations.length; i++)
        if (band.wide)
          SizedBox(
            width: band.slot,
            child: _button(
              index: i,
              theme: theme,
              scheme: scheme,
              metrics: metrics,
              indicator: indicator,
              label: band.label,
              wide: true,
              slot: band.slot,
              indicatorHeight: band.indicatorHeight,
              radius: band.radius,
              pad: band.pad,
              maxLines: band.maxLines,
              overflow: band.overflow,
            ),
          )
        else
          Expanded(
            child: _button(
              index: i,
              theme: theme,
              scheme: scheme,
              metrics: metrics,
              indicator: indicator,
              label: band.label,
              wide: false,
              slot: band.slot,
              indicatorHeight: band.indicatorHeight,
              radius: band.radius,
              pad: band.pad,
              maxLines: band.maxLines,
              overflow: band.overflow,
            ),
          ),
    ];
  }

  Widget _button({
    required int index,
    required MorphNavigationBarTheme theme,
    required MorphColorScheme scheme,
    required MorphNavMetrics metrics,
    required Color indicator,
    required TextStyle label,
    required bool wide,
    required double slot,
    required double indicatorHeight,
    required double radius,
    required ({double top, double bottom}) pad,
    required int maxLines,
    required TextOverflow overflow,
  }) {
    return MorphNavBarDestinationButton(
      destination: widget.destinations[index],
      selected: index == _selected,
      selectedColor: theme.selectedColor(scheme),
      activeLabelColor: theme.activeLabelColor(scheme),
      unselectedColor: theme.unselectedColor(scheme),
      labelStyle: label,
      iconSize: metrics.iconSize,
      labelBehavior: widget.labelBehavior,
      iconBehavior: widget.iconBehavior,
      layout: wide ? MorphNavBarLayout.wide : MorphNavBarLayout.compact,
      indicatorStyle: widget.indicatorStyle,
      indicatorWidth: theme.verticalIndicatorWidth,
      indicatorHeight: indicatorHeight,
      indicatorRadius: radius,
      contentPadding: EdgeInsets.only(top: pad.top, bottom: pad.bottom),
      iconLabelGap: wide
          ? theme.horizontalIconLabelGap
          : theme.verticalIconLabelGap,
      labelMaxLines: maxLines,
      labelOverflow: overflow,
      wideDestinationWidth: wide ? slot : null,
      horizontalInset: wide ? theme.horizontalIndicatorInset : 0,
      underlineThickness: metrics.indicatorThickness,
      underlineColor: indicator,
      indicatorColor: indicator,
      focusNode: _nodes[index],
      skipTraversal: !_tabStop(index),
      onTap: () => widget.onDestinationSelected?.call(index),
    );
  }
}
