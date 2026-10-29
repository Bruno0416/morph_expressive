import 'dart:math' as math;
import 'dart:ui' show ImageFilter;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart' show Positioned, Stack, StackFit;
import 'package:material_ui/material_ui.dart'
    show
        Alignment,
        BackdropFilter,
        Border,
        BorderRadius,
        BoxDecoration,
        ClipRRect,
        DecoratedBox,
        RoundedRectangleBorder,
        AnimatedAlign,
        BoxConstraints,
        BuildContext,
        CallbackShortcuts,
        ClipRect,
        Color,
        Directionality,
        EdgeInsets,
        EdgeInsetsDirectional,
        EdgeInsetsGeometry,
        ExcludeSemantics,
        Expanded,
        FocusNode,
        LayoutBuilder,
        MainAxisAlignment,
        Material,
        MediaQuery,
        Padding,
        Row,
        RepaintBoundary,
        ScrollController,
        Semantics,
        ShapeBorder,
        ShortcutActivator,
        SingleActivator,
        SizedBox,
        State,
        StatefulWidget,
        TextDirection,
        TextOverflow,
        TextPainter,
        TextScaler,
        TextSpan,
        TextStyle,
        ValueChanged,
        VoidCallback,
        Widget;

import '../../foundations/foundations.dart';
import '../navigation_rail/components/morph_sliding_indicator.dart';
import 'components/morph_nav_bar_destination_button.dart';
import 'components/morph_navigation_scroll_activity.dart';
import 'controllers/morph_navigation_bar_controller.dart';
import 'enums/morph_nav_bar_enums.dart';
import 'models/morph_nav_metrics.dart';
import 'models/morph_navigation_bar_destination.dart';
import 'styles/morph_navigation_bar_theme.dart';
import 'styles/morph_navigation_glass.dart';

export 'controllers/morph_navigation_bar_controller.dart';
export 'enums/morph_nav_bar_enums.dart';
export 'models/morph_nav_metrics.dart';
export 'models/morph_navigation_bar_destination.dart';
export 'res/morph_nav_bar_constants.dart';
export 'styles/morph_navigation_bar_theme.dart';
export 'styles/morph_navigation_glass.dart';

part 'components/morph_navigation_bar_build.dart';

/// A Material 3 Expressive navigation bar.
///
/// The flexible size is 64. The baseline size is 80. Vertical items share the
/// width and keep the pill behind the icon. Horizontal items turn on in a
/// medium window, or when [layout] is [MorphNavBarLayout.wide]. Arrow keys move
/// focus. Space or Enter selects, including the active destination.
class MorphNavigationBar extends StatefulWidget {
  /// MorphNavigationBar.
  const MorphNavigationBar({
    this.motion = MorphNavigationMotion.standard,
    this.floating = false,
    this.glass,
    this.selectionDelay,
    this.iconSize,
    this.unselectedIconScale = 1.0,
    this.labelStyle,
    this.topIndicatorWidth = 40,
    this.topIndicatorHeight = 4,
    this.floatingRadius = 40,
    super.key,
    required this.destinations,
    this.selectedIndex = 0,
    this.onDestinationSelected,
    this.labelBehavior = MorphNavBarLabelBehavior.alwaysShow,
    this.iconBehavior = MorphNavBarIconBehavior.alwaysShow,
    this.autoLayout = true,
    this.layout = MorphNavBarLayout.compact,
    this.alignment = MorphNavBarAlignment.center,
    this.wideBreakpoint,
    this.wideDestinationWidth,
    this.distributeWideDestinations = false,
    this.size = MorphNavBarSize.medium,
    this.shapeFamily = MorphNavBarShapeFamily.square,
    this.density = MorphNavBarDensity.regular,
    this.backgroundColor,
    this.elevation,
    this.indicatorStyle = MorphNavBarIndicatorStyle.pill,
    this.indicatorColor,
    this.padding,
    this.safeArea = true,
    this.semanticLabel,
    this.controller,
    this.hideOnScroll = false,
    this.scrollController,
  }) : assert(unselectedIconScale > 0),
       _topDash = false;

  /// Material 3 Expressive: a shared elastic selection pill around the icon.
  ///
  /// Uses the same morphing selection motion as the rail and drawer variants.
  /// Defaults to the compact 64dp bar height; use [size] for the 80dp baseline.
  /// Unlike [MorphNavigationBar.morph], it does not display a top dash.
  const MorphNavigationBar.expressive({
    this.floating = false,
    this.glass,
    this.selectionDelay,
    this.iconSize,
    this.unselectedIconScale = 1.0,
    this.labelStyle,
    this.topIndicatorWidth = 40,
    this.topIndicatorHeight = 4,
    this.floatingRadius = 40,
    super.key,
    required this.destinations,
    this.selectedIndex = 0,
    this.onDestinationSelected,
    this.labelBehavior = MorphNavBarLabelBehavior.alwaysShow,
    this.iconBehavior = MorphNavBarIconBehavior.alwaysShow,
    this.autoLayout = true,
    this.layout = MorphNavBarLayout.compact,
    this.alignment = MorphNavBarAlignment.center,
    this.wideBreakpoint,
    this.wideDestinationWidth,
    this.distributeWideDestinations = false,
    this.size = MorphNavBarSize.small,
    this.shapeFamily = MorphNavBarShapeFamily.square,
    this.density = MorphNavBarDensity.regular,
    this.backgroundColor,
    this.elevation,
    this.indicatorStyle = MorphNavBarIndicatorStyle.pill,
    this.indicatorColor,
    this.padding,
    this.safeArea = true,
    this.semanticLabel,
    this.controller,
    this.hideOnScroll = false,
    this.scrollController,
  }) : assert(unselectedIconScale > 0),
       motion = MorphNavigationMotion.morph,
       _topDash = false;

  /// Morph navigation: a sliding top dash, active icon and selected label.
  ///
  /// Use [floating] inside `MorphNavigationBarHost` for an inset floating
  /// shell. The top indicator follows the elastic Morph selection motion.
  /// The small Morph variant defaults to 76dp to keep the dash and 32dp icon
  /// visually separated. Use [size] for the 80dp medium baseline.
  const MorphNavigationBar.morph({
    this.floating = false,
    this.glass,
    this.selectionDelay,
    this.iconSize = 32,
    this.unselectedIconScale = 1.0,
    this.labelStyle = const TextStyle(fontSize: 14),
    this.topIndicatorWidth = 40,
    this.topIndicatorHeight = 4,
    this.floatingRadius = 40,
    super.key,
    required this.destinations,
    this.selectedIndex = 0,
    this.onDestinationSelected,
    this.labelBehavior = MorphNavBarLabelBehavior.onlySelected,
    this.iconBehavior = MorphNavBarIconBehavior.alwaysShow,
    this.autoLayout = false,
    this.layout = MorphNavBarLayout.compact,
    this.alignment = MorphNavBarAlignment.center,
    this.wideBreakpoint,
    this.wideDestinationWidth,
    this.distributeWideDestinations = false,
    this.size = MorphNavBarSize.small,
    this.shapeFamily = MorphNavBarShapeFamily.square,
    this.density = MorphNavBarDensity.regular,
    this.backgroundColor,
    this.elevation,
    this.indicatorStyle = MorphNavBarIndicatorStyle.pill,
    this.indicatorColor,
    this.padding,
    this.safeArea = true,
    this.semanticLabel,
    this.controller,
    this.hideOnScroll = false,
    this.scrollController,
  }) : assert(unselectedIconScale > 0),
       motion = MorphNavigationMotion.morph,
       _topDash = true;

  /// destinations.
  final List<MorphNavigationBarDestination> destinations;

  /// selectedIndex.
  final int selectedIndex;

  /// Called when a destination is chosen, including the active one.
  final ValueChanged<int>? onDestinationSelected;

  /// labelBehavior.
  final MorphNavBarLabelBehavior labelBehavior;

  /// iconBehavior.
  final MorphNavBarIconBehavior iconBehavior;

  /// When true, pick compact vs wide from the bar’s own width.
  final bool autoLayout;

  /// Used only when [autoLayout] is false.
  final MorphNavBarLayout layout;

  /// Destination-group placement in wide layout (bar stays full width).
  final MorphNavBarAlignment alignment;

  /// Auto-layout width threshold. When null, uses the theme breakpoint
  /// (600).
  final double? wideBreakpoint;

  /// Width of each horizontal destination. When null, every item uses the
  /// widest icon-plus-label content.
  final double? wideDestinationWidth;

  /// Spread wide-layout destinations uniformly across the available width.
  ///
  /// When false (default), destinations remain a compact group positioned by
  /// [alignment] and separated by the theme's wide item gap. When true, each
  /// destination keeps its intrinsic or [wideDestinationWidth] slot width,
  /// but its center is evenly distributed across the bar. [alignment] is
  /// ignored in distributed wide layout. Compact layout is unaffected.
  final bool distributeWideDestinations;

  /// Flexible [MorphNavBarSize.small] or baseline [MorphNavBarSize.medium].
  ///
  /// Defaults to [MorphNavBarSize.medium] for the unnamed constructor and
  /// [MorphNavBarSize.small] for `.morph` and `.expressive`.
  final MorphNavBarSize size;

  /// shapeFamily.
  final MorphNavBarShapeFamily shapeFamily;

  /// density.
  final MorphNavBarDensity density;

  /// backgroundColor.
  final Color? backgroundColor;

  /// elevation.
  final double? elevation;

  /// indicatorStyle.
  final MorphNavBarIndicatorStyle indicatorStyle;

  /// indicatorColor.
  final Color? indicatorColor;

  /// padding.
  final EdgeInsetsGeometry? padding;

  /// When true, the system navigation inset is padding inside the bar.
  final bool safeArea;

  /// semanticLabel.
  final String? semanticLabel;

  /// Optional selection and visibility controller.
  final MorphNavigationBarController? controller;

  /// When true, [scrollController] hides the bar on a downward scroll.
  final bool hideOnScroll;

  /// Body scroll position. A bottom bar is not inside that scroll view.
  final ScrollController? scrollController;

  /// Round floating shell, or an edge-to-edge docked surface.
  final bool floating;

  /// Null uses an opaque surface; otherwise enables clipped backdrop blur.
  final MorphNavigationGlass? glass;

  /// Optional trailing-edge pause for morph navigation. Defaults to 60ms.
  final Duration? selectionDelay;

  /// Base glyph size in logical pixels, resolved through the navigation
  /// theme when null. The top-dash `.morph()` variant defaults to 32dp.
  ///
  /// Combined with [unselectedIconScale] for the resting icon size; the
  /// selected icon is always painted at the base [iconSize] scale (1.0).
  final double? iconSize;

  /// Relative paint scale of icons in unselected destinations.
  ///
  /// `1.0` keeps selected and unselected glyphs equally sized (default).
  /// `0.9` paints unselected glyphs at 90% of [iconSize], while `1.1`
  /// makes them 10% larger. Selection transitions use the existing icon
  /// spring; this does not change destination layout or tap targets.
  /// Must be greater than zero.
  final double unselectedIconScale;

  /// Overrides the label typography while retaining state colors and weights.
  final TextStyle? labelStyle;
  final double topIndicatorWidth;
  final double topIndicatorHeight;
  final double floatingRadius;
  final bool _topDash;

  /// Standard independent fills or one continuous Morph indicator.
  final MorphNavigationMotion motion;

  @override
  State<MorphNavigationBar> createState() => _MorphNavigationBarState();
}

class _MorphNavigationBarState extends State<MorphNavigationBar> {
  final List<FocusNode> _nodes = <FocusNode>[];
  MorphNavigationBarController? _bound;
  ScrollController? _scroll;
  late final ValueChanged<int> _controllerSelect = _selectFromController;
  bool _inside = false;
  bool _redirecting = false;
  int _focusIndex = 0;
  bool _visible = true;

  int get _selected {
    if (widget.destinations.isEmpty) {
      return 0;
    }
    return widget.selectedIndex.clamp(0, widget.destinations.length - 1);
  }

  @override
  void initState() {
    super.initState();
    _focusIndex = widget.selectedIndex;
    _syncNodes();
    _bindScroll();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _bindController();
  }

  @override
  void didUpdateWidget(covariant MorphNavigationBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.destinations.length != widget.destinations.length) {
      _syncNodes();
    }
    if (oldWidget.controller != widget.controller) {
      _bindController();
    } else {
      _bound?.updateIndex(_selected);
    }
    if (oldWidget.scrollController != widget.scrollController ||
        oldWidget.hideOnScroll != widget.hideOnScroll) {
      _bindScroll();
    }
    if (!_inside) {
      _focusIndex = _selected;
    }
  }

  @override
  void dispose() {
    _bound?.removeListener(_onController);
    _bound?.detach(_controllerSelect);
    _scroll?.removeListener(_onScroll);
    for (final FocusNode node in _nodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _syncNodes() {
    final int count = widget.destinations.length;
    while (_nodes.length < count) {
      _nodes.add(
        FocusNode(debugLabel: 'nav ${_nodes.length}')..addListener(_onFocus),
      );
    }
    while (_nodes.length > count) {
      _nodes.removeLast()
        ..removeListener(_onFocus)
        ..dispose();
    }
    if (_nodes.isEmpty) {
      _focusIndex = 0;
      return;
    }
    _focusIndex = _focusIndex.clamp(0, _nodes.length - 1);
  }

  void _bindController() {
    final MorphNavigationBarController? next = widget.controller;
    if (identical(_bound, next)) {
      _bound?.updateIndex(_selected);
      return;
    }
    _bound?.removeListener(_onController);
    _bound?.detach(_controllerSelect);
    _bound = next;
    next?.attach(_controllerSelect, _selected);
    next?.addListener(_onController);
  }

  void _bindScroll() {
    final ScrollController? next = widget.hideOnScroll
        ? widget.scrollController
        : null;
    if (identical(_scroll, next)) {
      return;
    }
    _scroll?.removeListener(_onScroll);
    _scroll = next;
    _scroll?.addListener(_onScroll);
  }

  void _selectFromController(int index) {
    widget.onDestinationSelected?.call(index);
  }

  void _onController() {
    if (!mounted) {
      return;
    }
    final bool visible = _bound?.visible ?? _visible;
    if (visible == _visible) {
      return;
    }
    setState(() => _visible = visible);
  }

  void _onScroll() {
    if (!mounted || !widget.hideOnScroll) {
      return;
    }
    final ScrollController? scroll = _scroll;
    if (scroll == null || !scroll.hasClients) {
      return;
    }
    if (MediaQuery.accessibleNavigationOf(context)) {
      _applyVisible(true);
      return;
    }
    final ScrollDirection direction = scroll.position.userScrollDirection;
    if (direction == ScrollDirection.reverse) {
      _applyVisible(false);
    } else if (direction == ScrollDirection.forward) {
      _applyVisible(true);
    }
  }

  void _applyVisible(bool visible) {
    final MorphNavigationBarController? bound = _bound;
    if (bound != null) {
      bound.updateVisible(visible: visible);
      return;
    }
    if (_visible == visible) {
      return;
    }
    setState(() => _visible = visible);
  }

  bool _shown(BuildContext context) {
    if (!widget.hideOnScroll) {
      return true;
    }
    if (MediaQuery.accessibleNavigationOf(context)) {
      return true;
    }
    return _bound?.visible ?? _visible;
  }

  void _onFocus() {
    if (!mounted || _redirecting || _nodes.isEmpty) {
      return;
    }
    final bool any = _nodes.any((FocusNode node) => node.hasFocus);
    if (!any) {
      if (!_inside) {
        return;
      }
      setState(() {
        _inside = false;
        _focusIndex = _selected;
      });
      return;
    }
    final int focused = _nodes.indexWhere((FocusNode node) => node.hasFocus);
    if (!_inside) {
      _inside = true;
      if (focused != _selected) {
        _redirecting = true;
        _focusIndex = _selected;
        _nodes[_selected].requestFocus();
        _redirecting = false;
        setState(() {});
        return;
      }
    }
    if (focused >= 0 && focused != _focusIndex) {
      setState(() => _focusIndex = focused);
    }
  }

  void _move(int delta) {
    final int current = _nodes.indexWhere((FocusNode node) => node.hasFocus);
    if (current < 0) {
      return;
    }
    final int next = current + delta;
    if (next < 0 || next >= _nodes.length) {
      return;
    }
    setState(() {
      _inside = true;
      _focusIndex = next;
    });
    _nodes[next].requestFocus();
  }

  bool _tabStop(int index) {
    if (_inside) {
      return index == _focusIndex;
    }
    return index == _selected;
  }

  @override
  Widget build(BuildContext context) {
    assert(widget.destinations.isNotEmpty, 'Provide at least one destination');
    return MorphComponentTheme(
      builder: (BuildContext context) => _buildNavigationBar(context),
    );
  }
}
