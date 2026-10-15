import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../../foundations/foundations.dart';
import 'components/morph_nav_bar_destination_button.dart';
import 'controllers/morph_navigation_bar_controller.dart';
import 'enums/morph_nav_bar_enums.dart';
import 'models/morph_nav_metrics.dart';
import 'models/morph_navigation_bar_destination.dart';
import 'styles/morph_navigation_bar_theme.dart';

export 'controllers/morph_navigation_bar_controller.dart';
export 'enums/morph_nav_bar_enums.dart';
export 'models/morph_nav_metrics.dart';
export 'models/morph_navigation_bar_destination.dart';
export 'res/morph_nav_bar_constants.dart';
export 'styles/morph_navigation_bar_theme.dart';

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
  });

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

  /// Flexible [MorphNavBarSize.small] or baseline [MorphNavBarSize.medium].
  ///
  /// Defaults to the baseline bar.
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
