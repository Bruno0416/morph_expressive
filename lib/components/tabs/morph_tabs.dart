import 'dart:math' as math;
import 'dart:ui' show SemanticsRole;

import 'package:flutter/rendering.dart' show RenderAbstractViewport;

import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:material_ui/material_ui.dart'
    show Material, PinnedHeaderSliver, SliverFloatingHeader;

import '../../foundations/foundations.dart';
import '../badges/morph_badges.dart';
import 'components/morph_tabs_geometry.dart';
import 'controllers/morph_tabs_controller.dart';
import 'enums/morph_tabs_alignment.dart';
import 'enums/morph_tabs_indicator_options.dart';
import 'enums/morph_tabs_variant.dart';
import 'models/morph_tab.dart';
import 'styles/morph_tab_theme.dart';

export 'components/morph_tabs_geometry.dart';
export 'controllers/morph_tabs_controller.dart';
export 'enums/morph_tabs_alignment.dart';
export 'enums/morph_tabs_indicator_options.dart';
export 'enums/morph_tabs_variant.dart';
export 'morph_tabs_view.dart';
export 'models/morph_tab.dart';
export 'styles/morph_tab_theme.dart';

part 'components/morph_tabs_indicator.dart';
part 'components/morph_tabs_indicator_paint.dart';
part 'components/morph_tabs_sizing.dart';
part 'components/morph_tabs_build.dart';
part 'components/morph_tabs_content.dart';

/// A Material 3 tab bar with a continuous selection indicator.
///
/// Primary tabs stack an optional icon above the label. Secondary tabs place
/// an optional icon before the label. Arrow keys move focus; Space or Enter
/// selects.
///
/// ## Indicator
///
/// The indicator is drawn as an [MorphTabsIndicatorStyle.underline] (the
/// default, the previous look) or as a persistent
/// [MorphTabsIndicatorStyle.surface] behind the content. The style is
/// independent of [variant]. Only the indicator moves; tabs, labels, icons and
/// the bar height stay still. [indicatorMotion] chooses
/// [MorphTabsIndicatorMotion.slide] (default) or a restrained
/// [MorphTabsIndicatorMotion.elastic]. [indicatorFit] chooses whether the
/// indicator follows the content or the whole tab, independently of how the
/// tabs are distributed ([alignment], [scrollable]).
///
/// Precedence: the widget arguments, then [tabTheme], then
/// `MorphTheme.of(context).tabTheme`, then the package defaults.
///
/// ## Selection, progress and focus
///
/// * *Selection* is [selectedIndex] (confirmed). [onTabSelected] reports a tap
///   or key activation once. The bar never changes it by itself: if the parent
///   keeps another index the indicator stays on it.
/// * *Progress* is transient and visual. With a shared [controller], an
///   attached `MorphTabsView` publishes its fractional page position and the
///   indicator follows it directly while the user drags, flings or an animated
///   change runs. Progress never calls [onTabSelected] per frame.
/// * *Focus* is separate: arrow keys move focus without selecting, and the
///   focus ring is independent of the indicator.
///
/// Without a view the bar animates its own indicator after a selection change
/// (directly to the destination, retargeting from the visible rectangle).
///
/// ## List changes
///
/// If every tab has a [MorphTab.id] and the selected tab moved, the bar reports
/// its new index through [onTabSelected] once so a controlled parent can keep
/// the selection on the same tab. An out-of-range [selectedIndex] is displayed
/// clamped to the nearest valid tab and reported once the same way.
class MorphTabs extends StatefulWidget {
  /// A fixed bar. Set [scrollable] to force or forbid horizontal scrolling.
  const MorphTabs({
    required this.tabs,
    required this.selectedIndex,
    required this.onTabSelected,
    this.variant = MorphTabsVariant.primary,
    this.scrollable,
    this.autoScrollToFocusedTab = false,
    this.alignment = MorphTabsAlignment.fill,
    this.controller,
    this.indicatorStyle,
    this.indicatorMotion,
    this.indicatorFit,
    this.indicatorRenderer,
    this.indicatorDuration,
    this.onIndicatorRendererChanged,
    this.tabTheme,
    super.key,
  }) : assert(tabs.length >= 2, 'A tab bar needs 2+ tabs.'),
       floating = false,
       _sliver = false;

  /// A bar inside a [CustomScrollView].
  ///
  /// When [floating] is true the bar scrolls away and returns on an upward
  /// scroll. When false it stays pinned at the top of the scroll view.
  const MorphTabs.sliver({
    required this.tabs,
    required this.selectedIndex,
    required this.onTabSelected,
    this.variant = MorphTabsVariant.primary,
    this.scrollable,
    this.autoScrollToFocusedTab = false,
    this.alignment = MorphTabsAlignment.fill,
    this.controller,
    this.floating = true,
    this.indicatorStyle,
    this.indicatorMotion,
    this.indicatorFit,
    this.indicatorRenderer,
    this.indicatorDuration,
    this.onIndicatorRendererChanged,
    this.tabTheme,
    super.key,
  }) : assert(tabs.length >= 2, 'A tab bar needs 2+ tabs.'),
       _sliver = true;

  /// Tabs, left to right in LTR.
  final List<MorphTab> tabs;

  /// Selected index.
  final int selectedIndex;

  /// Called when a tab is chosen.
  final ValueChanged<int> onTabSelected;

  /// Primary or secondary.
  final MorphTabsVariant variant;

  /// Forces scrollable tabs when true, and equal slots when false.
  ///
  /// Null scrolls only when a label does not fit its equal slot.
  final bool? scrollable;

  /// Automatically reveals the focused tab in its enclosing scrollables.
  /// Disabled by default so selecting a tab does not shift the page scroll.
  /// Set to true to retain the previous focus-following scroll behavior.
  final bool autoScrollToFocusedTab;

  /// How fixed tabs share the width. Ignored while scrolling.
  final MorphTabsAlignment alignment;

  /// Optional selection controller. Share it with a `MorphTabsView` so the
  /// indicator follows the pages.
  final MorphTabsController? controller;

  /// Whether a sliver bar scrolls away and returns.
  final bool floating;

  /// Indicator presentation. Null: theme, then underline.
  final MorphTabsIndicatorStyle? indicatorStyle;

  /// Indicator motion. Null: theme, then slide.
  final MorphTabsIndicatorMotion? indicatorMotion;

  /// Indicator width basis. Null: theme, then content (primary) or tab
  /// (secondary).
  final MorphTabsIndicatorFit? indicatorFit;

  /// Renderer requested for the indicator. Null: theme, then auto.
  final MorphShapeRenderer? indicatorRenderer;

  /// Duration of a tap or programmatic change. Null: theme.
  final Duration? indicatorDuration;

  /// Reports the renderer actually used by the indicator (the Shader may still
  /// be loading, unavailable, or the radii may be asymmetric).
  final ValueChanged<MorphShapeRenderStatus>? onIndicatorRendererChanged;

  /// Replaces the inherited tab theme for this bar.
  final MorphTabTheme? tabTheme;

  final bool _sliver;

  @override
  State<MorphTabs> createState() => _MorphTabsState();
}

/// Notifies the indicator and the tab contents. One stable listenable keeps
/// the per-frame work to a repaint of the indicator and a colour update.
class _Pulse extends ChangeNotifier {
  void pulse() => notifyListeners();
}

class _MorphTabsState extends State<MorphTabs> with TickerProviderStateMixin {
  final GlobalKey _barKey = GlobalKey();
  final GlobalKey _trackKey = GlobalKey();
  final ScrollController _scroll = ScrollController();
  final _Pulse _pulse = _Pulse();
  late final AnimationController _anim;
  late final ValueChanged<int> _controllerSelect = _selectFromController;
  // Extension tear-offs are not canonical: keep one instance to unregister.
  late final VoidCallback _positionListener = _onPosition;

  late List<GlobalKey> _slotKeys;
  late List<GlobalKey> _contentKeys;
  late List<FocusNode> _nodes;

  MorphTabsController? _bound;

  // Measurement, in track coordinates.
  List<MorphTabsEdges> _targets = const <MorphTabsEdges>[];
  bool _stale = true;
  MorphTabsEdges? _shown;
  bool _placed = false;
  bool _syncScheduled = false;
  int _syncRetries = 0;
  Object? _layoutSig;
  Object? _contentSig;
  bool _layoutChanged = false;
  bool _contentChanged = false;
  bool _settled = false;
  double _barHeight = 48;
  double _stackedLift = 0;
  late MorphTabIndicatorSpec _spec;

  // Own (tap) animation: from a captured rectangle to the live destination.
  MorphTabsEdges? _from;
  int _toIndex = 0;
  List<double> _fromWeights = const <double>[];
  int _lastIndex = 0;

  // Selection policy.
  List<MorphTab>? _prevTabs;
  int? _prevSelected;
  int? _reportedInvalid;

  // Scroll and focus.
  bool _userScrolling = false;
  int _revealed = -1;
  bool _inside = false;
  bool _redirecting = false;
  bool _pageActive = false;

  // Renderer reporting.
  String? _lastRenderer;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(vsync: this, duration: MorphMotion.medium2)
      ..addListener(_pulse.pulse)
      ..addStatusListener(_onAnimStatus);
    _alloc(widget.tabs.length);
    _lastIndex = _index;
    _scheduleSync();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _bindController();
    if (MorphMotion.reduceMotionOf(context) && _anim.isAnimating) {
      _anim.value = 1;
    }
  }

  @override
  void didUpdateWidget(covariant MorphTabs oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tabs.length != widget.tabs.length) {
      _disposeNodes();
      _alloc(widget.tabs.length);
      _stale = true;
      _revealed = -1;
    }
    if (oldWidget.controller != widget.controller) {
      _bindController();
    } else {
      _bound?.updateIndex(_index);
    }
    _scheduleSync();
  }

  @override
  void dispose() {
    _bound?.detach(_controllerSelect);
    _bound?.position.removeListener(_positionListener);
    _anim.dispose();
    _pulse.dispose();
    _disposeNodes();
    _scroll.dispose();
    super.dispose();
  }

  int get _index => widget.selectedIndex.clamp(0, widget.tabs.length - 1);

  @override
  Widget build(BuildContext context) => _build(context);
}
