// Part of the carousel subsystem inherited from Material 3 Expressive (MIT).
// Its upstream CarouselView-based implementation includes Flutter-derived
// code (Copyright 2014 The Flutter Authors; BSD-3-Clause).
// Modified in 2026 for Morph Expressive (naming, layouts and/or refactoring).
// See NOTICE; file-specific BSD derivation has not been fully established.

import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../../../foundations/foundations.dart';
import '../../cards/morph_cards.dart';
import '../models/morph_carousel_change_details.dart';
import '../models/morph_carousel_scrim.dart';
import '../styles/morph_carousel_theme.dart';
import 'morph_carousel_item.dart';
import 'morph_carousel_step_physics.dart';
import 'morph_carousel_track_clip.dart';
import 'morph_carousel_view.dart';

part 'morph_carousel_wrapper_anchors.dart';
part 'morph_carousel_wrapper_pulse.dart';
part 'morph_carousel_wrapper_focus.dart';
part 'morph_carousel_wrapper_geometry.dart';
part 'morph_carousel_wrapper_tap.dart';
part 'morph_carousel_wrapper_item_builder.dart';

/// Wraps [MorphCarouselView] with tap handling and a neighbor pulse animation.
///
/// Item content is laid out at the largest slot size (plus pulse budget) and
/// clipped to the current item bounds. Scrolling and tap pulse only move that
/// clip "window"; the content layer stays still underneath.
class MorphCarouselWrapper extends StatefulWidget {
  /// Creates a carousel wrapper with optional pulse animation on tap.
  const MorphCarouselWrapper({
    super.key,
    this.freeScroll = false,
    this.padding,
    this.backgroundColor = Colors.transparent,
    this.elevation = 0.0,
    this.shape = const RoundedRectangleBorder(),
    this.itemClipBehavior = Clip.none,
    this.overlayColor,
    this.itemSnapping = false,
    this.consumeMaxWeight = true,
    this.shrinkExtent = 0.0,
    this.scaleItems = true,
    this.controller,
    this.scrollDirection = Axis.horizontal,
    this.reverse = false,
    this.onTap,
    this.haptic = MorphHapticFeedback.none,
    this.enableSplash = true,
    this.infinite = false,
    this.itemExtent,
    this.flexWeights,
    required this.children,
    this.onIndexChanged,
    this.onChange,
    this.onFocusedIndex,
    this.reducedMotion = false,
    this.itemExtents,
    this.leadingInset = 0,
    this.trailingGap = 0,

    /// Fixed logical pixels added or removed per animating edge at peak pulse.
    ///
    /// A value of `4` expands or squishes each active edge by up to 4px.
    /// When both sides animate, each edge uses the full delta independently.
    this.fixedPulseDelta = 4,
  }) : assert(
         (flexWeights != null && itemExtent == null && itemExtents == null) ||
             (flexWeights == null &&
                 itemExtent != null &&
                 itemExtents == null) ||
             (flexWeights == null && itemExtent == null && itemExtents != null),
         'Provide itemExtent, flexWeights, or itemExtents.',
       );

  /// Whether free scrolling is enabled (passed through to scroll physics).
  final bool freeScroll;

  /// Padding around each carousel item.
  final EdgeInsets? padding;

  /// Background color for each item's [Material].
  final Color? backgroundColor;

  /// Elevation for each item's [Material].
  final double? elevation;

  /// Shape for each item's [Material] and pulse clip radius.
  final ShapeBorder? shape;

  /// Clip behavior for pulsed item content.
  final Clip itemClipBehavior;

  /// Ink overlay colors when splash is enabled on the wrapper layer.
  final WidgetStateProperty<Color?>? overlayColor;

  /// Whether the underlying view snaps to items.
  final bool itemSnapping;

  /// Whether collapsed weighted items may expand to the max weight size.
  final bool consumeMaxWeight;

  /// Minimum item extent during scroll transitions.
  final double shrinkExtent;

  /// Whether fixed-extent items shrink as they scroll.
  ///
  /// Full-screen pages stay one size and slide.
  final bool scaleItems;

  /// Optional controller for the underlying [MorphCarouselView].
  final MorphCarouselController? controller;

  /// Scroll axis for the carousel.
  final Axis scrollDirection;

  /// Whether the list scrolls in the reverse reading direction.
  final bool reverse;

  /// Called when an item is tapped.
  final void Function(int)? onTap;

  /// Haptic intensity on item tap. Defaults to [MorphHapticFeedback.none].
  final MorphHapticFeedback haptic;

  /// Whether the wrapper ink layer reports splash feedback.
  final bool enableSplash;

  /// Whether the carousel loops infinitely.
  final bool infinite;

  /// Fixed main-axis extent for unweighted layouts.
  final double? itemExtent;

  /// Flex weights for weighted layouts.
  final List<int>? flexWeights;

  /// Items in the carousel.
  final List<MorphCarouselItem> children;

  /// Empty space before the first item on uncontained tracks.
  final double leadingInset;

  /// Called when the leading item index changes.
  final void Function(int)? onIndexChanged;

  /// Called when the leading or focal item index changes.
  final ValueChanged<MorphCarouselChangeDetails>? onChange;

  /// Called when keyboard focus moves to an item.
  final ValueChanged<int>? onFocusedIndex;

  /// Turns off parallax and size morphing.
  final bool reducedMotion;

  /// Resting main-axis size of each item.
  ///
  /// The track shrinks these the same way an uncontained carousel does.
  final List<double>? itemExtents;

  /// Empty space after each item, inside a fixed extent.
  final double trailingGap;

  /// Fixed logical pixels added or removed per animating edge at peak pulse.
  final double fixedPulseDelta;

  @override
  State<MorphCarouselWrapper> createState() => _MorphCarouselWrapperState();
}

class _MorphCarouselWrapperState extends State<MorphCarouselWrapper>
    with SingleTickerProviderStateMixin {
  int? _activeIndex;
  int? _leftVisibleNeighborIndex;
  int? _rightVisibleNeighborIndex;
  late MorphCarouselController _internalController;
  final List<FocusNode> _itemFocus = <FocusNode>[];
  final List<WidgetStatesController> _itemStates = <WidgetStatesController>[];
  final List<LayerLink> _itemLinks = <LayerLink>[];
  final List<Size> _itemRest = <Size>[];
  bool _restRebuildScheduled = false;

  /// Per-index item boxes for pulse measuring.
  final Map<int, RenderBox> _itemBoxes = <int, RenderBox>{};

  /// Viewport box for neighbor visibility checks (no [GlobalKey] — those can
  /// reparent under [Theme] rebuilds and corrupt the weighted sliver).
  RenderBox? _viewportBox;

  late final AnimationController _pulseController = AnimationController(
    vsync: this,
    duration: MorphMotion.carouselPulse,
    reverseDuration: MorphMotion.carouselReturn,
  );

  late final Animation<double> _bump = CurvedAnimation(
    parent: _pulseController,
    curve: MorphMotion.enter,
    reverseCurve: MorphMotion.exit,
  );

  @override
  void initState() {
    super.initState();
    _internalController = widget.controller ?? MorphCarouselController();
    _syncFocusNodes();
  }

  @override
  void didUpdateWidget(MorphCarouselWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.children.length != oldWidget.children.length) {
      _itemBoxes.removeWhere((int index, _) => index >= widget.children.length);
    }
    if (widget.controller != oldWidget.controller) {
      if (oldWidget.controller == null) {
        _internalController.dispose();
      }
      _internalController = widget.controller ?? MorphCarouselController();
    }
    _syncFocusNodes();
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _internalController.dispose();
    }
    for (final FocusNode node in _itemFocus) {
      node.dispose();
    }
    for (final WidgetStatesController states in _itemStates) {
      states.dispose();
    }
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints viewportConstraints) {
        final double viewportMain = _vertical
            ? viewportConstraints.maxHeight
            : viewportConstraints.maxWidth;
        return AnimatedBuilder(
          animation: _bump,
          builder: (context, _) {
            final double edgeDelta = widget.fixedPulseDelta * _bump.value;
            final carouselChildren = List<Widget>.generate(
              widget.children.length,
              (int index) => _buildPulsedChild(
                index: index,
                edgeDelta: edgeDelta,
                viewportMain: viewportMain,
              ),
            );
            final MorphThemeData theme = MorphTheme.of(context);
            return Stack(
              clipBehavior: Clip.none,
              children: <Widget>[
                _CarouselViewportAnchor(
                  onRegister: (RenderBox box) => _viewportBox = box,
                  onUnregister: _unregisterViewportBox,
                  child: ClipRect(
                    clipper: MorphCarouselTrackClipper(
                      axis: widget.scrollDirection,
                    ),
                    child: _buildCarouselView(carouselChildren),
                  ),
                ),
                Positioned.fill(
                  child: ClipRect(
                    clipper: MorphCarouselTrackClipper(
                      axis: widget.scrollDirection,
                      mainAxisBleed: _focusRingBleed,
                      crossAxisBleed: _focusRingBleed,
                    ),
                    child: Stack(children: _focusRings(edgeDelta, theme)),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  static const double _focusRingBleed = 8;
}
