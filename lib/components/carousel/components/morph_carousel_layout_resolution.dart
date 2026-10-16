// Part of the carousel subsystem inherited from Material 3 Expressive (MIT).
// Its upstream CarouselView-based implementation includes Flutter-derived
// code (Copyright 2014 The Flutter Authors; BSD-3-Clause).
// Modified in 2026 for Morph Expressive (naming, layouts and/or refactoring).
// See NOTICE; file-specific BSD derivation has not been fully established.

part of '../morph_carousel.dart';

/// Resolves layout inputs (slot patterns, weights, extents, padding) for
/// [_MorphCarouselState] from the widget's [MorphCarouselType] and theme.
extension _MorphCarouselLayoutResolution on _MorphCarouselState {
  bool _extended(MorphCarouselTheme theme) {
    if (widget.type == MorphCarouselType.hero) {
      return false;
    }
    if (widget.isExtended != null) {
      return widget.isExtended!;
    }
    return frameWidth >= theme.expandedBreakpoint;
  }

  /// Gap before the first uncontained item. Later rests keep that gap too.
  double _leadingGap(MorphCarouselTheme theme) {
    final bool uncontained =
        widget.type == MorphCarouselType.uncontained ||
        widget.type == MorphCarouselType.uncontainedMultiAspect;
    if (!_horizontal || !uncontained || widget.itemPadding != null) {
      return 0;
    }
    return theme.itemGap;
  }

  List<int> _pattern(bool extended) {
    switch (widget.type) {
      case MorphCarouselType.hero:
        switch (widget.heroAlignment) {
          case MorphCarouselHeroAlignment.left:
            return <int>[8, 2];
          case MorphCarouselHeroAlignment.center:
            return <int>[2, 6, 2];
          case MorphCarouselHeroAlignment.right:
            return <int>[2, 8];
        }
      case MorphCarouselType.contained:
        return extended ? <int>[4, 3, 2, 1] : <int>[5, 4, 1];
      case MorphCarouselType.uncontained:
      case MorphCarouselType.uncontainedMultiAspect:
      case MorphCarouselType.fullScreen:
        return const <int>[];
    }
  }

  List<int> _resolvedWeights(
    MorphCarouselTheme theme,
    bool extended,
    bool reduced,
    double trackMain,
  ) {
    if (reduced ||
        widget.type == MorphCarouselType.uncontained ||
        widget.type == MorphCarouselType.uncontainedMultiAspect ||
        _fullScreen) {
      return const <int>[];
    }
    return MorphCarouselLayout.clampWeights(
      pattern: _pattern(extended),
      viewport: trackMain,
      smallMin: theme.smallMinWidth,
      smallMax: theme.smallMaxWidth,
      largeMax: widget.largeMaxWidth ?? theme.largeMaxWidth,
    );
  }

  double? _fixedExtent(
    MorphCarouselTheme theme,
    bool reduced,
    double trackMain,
  ) {
    if (widget.type == MorphCarouselType.uncontainedMultiAspect) {
      return null;
    }
    if (_fullScreen) {
      // One item is the viewport. A gap here makes later pages land short.
      return trackMain;
    }
    if (widget.type == MorphCarouselType.uncontained) {
      return widget.uncontainedItemExtent;
    }
    if (!reduced) {
      return null;
    }
    if (widget.type == MorphCarouselType.hero) {
      return math.max(trackMain - theme.smallMaxWidth, trackMain * 0.5);
    }
    return trackMain;
  }

  List<double>? _aspectExtentsFor(
    MorphCarouselTheme theme,
    EdgeInsets container,
  ) {
    if (widget.type != MorphCarouselType.uncontainedMultiAspect) {
      return null;
    }
    final double cross = _horizontal
        ? math.max(0, frameHeight - container.vertical)
        : math.max(0, frameWidth - container.horizontal);
    final EdgeInsets itemPadding = _itemPadding(theme, false);
    final double gap = _horizontal
        ? itemPadding.horizontal
        : itemPadding.vertical;
    return <double>[
      for (int i = 0; i < widget.children.length; i++)
        cross *
                widget.children[i].aspectRatio.clamp(
                  theme.minAspect,
                  theme.maxAspect,
                ) +
            gap,
    ];
  }

  EdgeInsets _containerPadding(MorphCarouselTheme theme, bool reduced) {
    if (reduced && widget.type == MorphCarouselType.contained) {
      return EdgeInsets.zero;
    }
    return theme.containerPaddingFor(widget.type);
  }

  EdgeInsets _itemPadding(MorphCarouselTheme theme, bool reduced) {
    if (widget.itemPadding != null) {
      return widget.itemPadding!.resolve(Directionality.of(context));
    }
    final EdgeInsets themed = theme.itemPadding.resolve(
      Directionality.of(context),
    );
    const fallback = EdgeInsets.symmetric(horizontal: 4);
    if (themed != fallback) {
      return themed;
    }
    if (_fullScreen ||
        (reduced && widget.type == MorphCarouselType.contained)) {
      return EdgeInsets.zero;
    }
    final bool bleed =
        widget.type == MorphCarouselType.uncontained ||
        widget.type == MorphCarouselType.uncontainedMultiAspect;
    if (bleed) {
      // The gap is on the trailing side so the leading edge matches the flush
      // trailing edge of the track.
      if (_horizontal) {
        return EdgeInsetsDirectional.only(end: theme.itemGap)
            .resolve(Directionality.of(context));
      }
      return EdgeInsets.only(top: theme.itemGap);
    }
    return _horizontal
        ? EdgeInsets.symmetric(horizontal: theme.itemGap / 2)
        : EdgeInsets.symmetric(vertical: theme.itemGap / 2);
  }
}
