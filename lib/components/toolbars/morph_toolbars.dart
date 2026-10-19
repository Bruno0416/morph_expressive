// Derived from Material 3 Expressive by Paa Developments (MIT), modified
// in 2026 for Morph Expressive (naming, layout, styling and/or motion).
// Follows Material 3 Compose design/reference patterns; direct inclusion
// of Android Open Source Project Apache-2.0 code is not established here.
// See NOTICE for original copyright and third-party attribution.

import 'package:material_ui/material_ui.dart';
import 'package:motor/motor.dart';

import '../../foundations/foundations.dart';
import '../floating_action_buttons/enums/morph_fab.dart';
import '../floating_action_buttons/styles/morph_fab_theme.dart';
import '../icon_buttons/enums/morph_icon_button_enums.dart';
import '../icon_buttons/styles/morph_icon_button_theme.dart';
import 'components/morph_toolbar_actions_row.dart';
import 'components/morph_toolbar_body.dart';
import 'components/morph_toolbar_expanding_actions.dart';
import 'components/morph_toolbar_fab_layout.dart';
import 'components/morph_toolbar_fab_slot.dart';
import 'components/morph_toolbar_measure_size.dart';
import 'components/morph_toolbar_title_block.dart';
import 'controllers/morph_toolbar_visibility_controller.dart';
import 'enums/morph_toolbar_enums.dart';
import 'morph_toolbar_scroll_behavior.dart';
import 'models/morph_toolbar_item.dart';
import 'res/morph_toolbar_tokens.dart';
import 'styles/morph_toolbar_theme.dart';
import 'utils/morph_toolbar_item_layout.dart';
import 'utils/morph_toolbar_spring_motion.dart';

export 'components/morph_toolbar_actions_row.dart';
export 'components/morph_toolbar_body.dart';
export 'components/morph_toolbar_expanding_actions.dart';
export 'components/morph_toolbar_fab_slot.dart';
export 'components/morph_toolbar_icon_button.dart';
export 'components/morph_toolbar_overflow_menu.dart';
export 'components/morph_toolbar_title_block.dart';
export 'controllers/morph_toolbar_visibility_controller.dart';
export 'enums/morph_toolbar_enums.dart';
export 'morph_toolbar_scroll_behavior.dart';
export 'models/morph_toolbar_item.dart';
export 'res/morph_toolbar_tokens.dart';
export 'styles/morph_toolbar_theme.dart';
export 'utils/morph_toolbar_item_layout.dart';

part 'components/morph_toolbar_build.dart';
part 'components/morph_toolbar_exit_offset.dart';
part 'components/morph_toolbar_fab_wrap.dart';
part 'components/morph_toolbar_visibility_wrap.dart';

/// A Material 3 Expressive toolbar.
///
/// Mirrors Compose Material 3:
/// - [MorphToolbar] / [MorphToolbar.floating] → `HorizontalFloatingToolbar` /
///   `VerticalFloatingToolbar`
/// - [MorphToolbar.docked] → `FlexibleBottomAppBar` (docked toolbar tokens)
///
/// Floating expand:
/// - With an adjacent FAB: FAB press toggles **whole-pill** expand/collapse
///   (FAB 80→56) with [MorphMotion.expressiveSpatialFast].
/// - Without a FAB: [MorphToolbarAction.isExpandTrigger] toggles neighbor reveal.
class MorphToolbar extends StatefulWidget implements PreferredSizeWidget {
  /// Floating toolbar (default). Horizontal unless [axis] is vertical.
  ///
  /// When [safeArea] is true, only [dockEdge] gets an **external** [MorphSafeArea]
  /// inset (outside the pill) — never inside [Material]. Floating toolbars also
  /// inset by [screenOffset] on every side, outside the pill.
  const MorphToolbar({
    this.leading,
    this.title,
    this.titleText,
    this.subtitle,
    this.subtitleText,
    this.trailing,
    this.actions = const <MorphToolbarItem>[],
    this.maxInlineActions = 4,
    this.overflowIcon = const Icon(MorphIcons.more_vert),
    this.centerTitle = false,
    this.alignment = Alignment.center,
    this.colorStyle = MorphToolbarColorStyle.standard,
    this.variant,
    this.size = MorphToolbarSize.medium,
    this.axis = Axis.horizontal,
    this.expanded = true,
    this.onExpandedChanged,
    this.floatingActionButton,
    this.fabIcon,
    this.fabExpandIcon,
    this.fabCollapseIcon,
    this.onFabPressed,
    this.fabPosition = MorphToolbarFabPosition.end,
    this.dockEdge = MorphToolbarDockEdge.bottom,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
    this.padding,
    this.safeArea = false,
    this.screenOffset,
    this.clipBehavior = Clip.none,
    this.semanticLabel,
    this.visibilityController,
    this.scrollBehavior,
    this.exitExtent,
    this.activeIndex,
    this.onActiveIndexChanged,
    this.fabExpandsToolbar = true,
    this.pillActiveSpring = true,
    this.contentAlignment = MorphToolbarContentAlignment.even,
    super.key,
  }) : assert(
         screenOffset == null || screenOffset >= 0,
         'screenOffset must be >= 0',
       ),
       placement = MorphToolbarPlacement.floating;

  /// Explicit floating constructor (same as default).
  const MorphToolbar.floating({
    this.leading,
    this.title,
    this.titleText,
    this.subtitle,
    this.subtitleText,
    this.trailing,
    this.actions = const <MorphToolbarItem>[],
    this.maxInlineActions = 4,
    this.overflowIcon = const Icon(MorphIcons.more_vert),
    this.centerTitle = false,
    this.alignment = Alignment.center,
    this.colorStyle = MorphToolbarColorStyle.standard,
    this.variant,
    this.size = MorphToolbarSize.medium,
    this.axis = Axis.horizontal,
    this.expanded = true,
    this.onExpandedChanged,
    this.floatingActionButton,
    this.fabIcon,
    this.fabExpandIcon,
    this.fabCollapseIcon,
    this.onFabPressed,
    this.fabPosition = MorphToolbarFabPosition.end,
    this.dockEdge = MorphToolbarDockEdge.bottom,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
    this.padding,
    this.safeArea = false,
    this.screenOffset,
    this.clipBehavior = Clip.none,
    this.semanticLabel,
    this.visibilityController,
    this.scrollBehavior,
    this.exitExtent,
    this.activeIndex,
    this.onActiveIndexChanged,
    this.fabExpandsToolbar = true,
    this.pillActiveSpring = true,
    this.contentAlignment = MorphToolbarContentAlignment.even,
    super.key,
  }) : assert(
         screenOffset == null || screenOffset >= 0,
         'screenOffset must be >= 0',
       ),
       placement = MorphToolbarPlacement.floating;

  /// Docked full-bleed bar (Compose `FlexibleBottomAppBar`).
  ///
  /// Optional [scrollBehavior] / [visibilityController] enable scroll-exit
  /// (default: no scroll detection). No FAB expand morph.
  /// [MorphToolbarAction.isExpandTrigger] styling is ignored when docked.
  const MorphToolbar.docked({
    this.leading,
    this.title,
    this.titleText,
    this.subtitle,
    this.subtitleText,
    this.trailing,
    this.actions = const <MorphToolbarItem>[],
    this.maxInlineActions = 4,
    this.overflowIcon = const Icon(MorphIcons.more_vert),
    this.centerTitle = false,
    this.colorStyle = MorphToolbarColorStyle.standard,
    this.variant,
    this.size = MorphToolbarSize.medium,
    this.dockEdge = MorphToolbarDockEdge.bottom,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
    this.padding,
    this.safeArea = true,
    this.clipBehavior = Clip.none,
    this.semanticLabel,
    this.visibilityController,
    this.scrollBehavior,
    this.exitExtent,
    this.activeIndex,
    this.onActiveIndexChanged,
    this.contentAlignment = MorphToolbarContentAlignment.even,
    super.key,
  }) : placement = MorphToolbarPlacement.docked,
       axis = Axis.horizontal,
       alignment = Alignment.center,
       expanded = true,
       onExpandedChanged = null,
       floatingActionButton = null,
       fabIcon = null,
       fabExpandIcon = null,
       fabCollapseIcon = null,
       onFabPressed = null,
       fabPosition = MorphToolbarFabPosition.end,
       fabExpandsToolbar = true,
       pillActiveSpring = true,
       screenOffset = null;

  /// placement.
  final MorphToolbarPlacement placement;

  /// dockEdge.
  final MorphToolbarDockEdge dockEdge;

  /// axis.
  final Axis axis;

  /// leading.
  final Widget? leading;

  /// title.
  final Widget? title;

  /// titleText.
  final String? titleText;

  /// subtitle.
  final Widget? subtitle;

  /// subtitleText.
  final String? subtitleText;

  /// trailing.
  final Widget? trailing;

  /// actions.
  final List<MorphToolbarItem> actions;

  /// maxInlineActions.
  final int maxInlineActions;

  /// overflowIcon.
  final Widget overflowIcon;

  /// centerTitle.
  final bool centerTitle;

  /// Positions a floating toolbar within its parent. Ignored when docked.
  final AlignmentGeometry alignment;

  /// colorStyle.
  final MorphToolbarColorStyle colorStyle;

  /// Legacy variant; when set, overrides [colorStyle].
  final MorphToolbarVariant? variant;

  /// size.
  final MorphToolbarSize size;

  /// Expand state for floating toolbars with a FAB or expand trigger.
  ///
  /// Parent changes are synced via spring. Listen via [onExpandedChanged].
  final bool expanded;

  /// Called whenever the expand state changes.
  final ValueChanged<bool>? onExpandedChanged;

  /// floatingActionButton.
  final Widget? floatingActionButton;

  /// Expand-state FAB icon fallback / opt-in for the default adjacent FAB.
  ///
  /// Used when [fabExpandIcon] is null. Prefer [fabExpandIcon] /
  /// [fabCollapseIcon] when providing both states.
  final Widget? fabIcon;

  /// Icon shown on the default FAB when the toolbar is collapsed.
  ///
  /// Defaults to [MorphIcons.add] when resolving the default FAB.
  final Widget? fabExpandIcon;

  /// Icon shown on the default FAB when the toolbar is expanded.
  ///
  /// Defaults to [MorphIcons.close] when resolving the default FAB.
  final Widget? fabCollapseIcon;

  /// Called when the FAB is pressed. When null and a default FAB is built,
  /// the FAB toggles whole-pill expand. When set, it is invoked in addition
  /// to the expand toggle (for default FAB) or alone (custom [floatingActionButton]
  /// that does not wire expand — keep [expanded] true for always-open pill).
  ///
  /// When [fabExpandsToolbar] is false, this is the only FAB callback (no
  /// expand toggle). If null, the FAB tap is a no-op.
  final VoidCallback? onFabPressed;

  /// When true (default), an adjacent FAB toggles whole-pill expand/collapse
  /// and morphs between large (80) and small (56) sizes.
  ///
  /// When false, the pill stays open, the FAB stays at [MorphToolbarTokens.fabBaseline]
  /// (56), and only [onFabPressed] runs. [expanded] / [onExpandedChanged] are
  /// ignored. Floating toolbars only.
  final bool fabExpandsToolbar;

  /// How docked actions use leftover width at 600dp and wider.
  ///
  /// Below that width the bar always spaces items evenly. Ignored when floating.
  final MorphToolbarContentAlignment contentAlignment;

  /// When true (default), labeled action selection springs the toolbar pill
  /// width in sync with each action's label morph.
  ///
  /// When false, the pill reserves a fixed width (widest labeled action +
  /// icon-only neighbors + gaps) so the outer pill does not resize while
  /// action labels still morph.
  final bool pillActiveSpring;

  /// fabPosition.
  final MorphToolbarFabPosition fabPosition;

  /// backgroundColor.
  final Color? backgroundColor;

  /// foregroundColor.
  final Color? foregroundColor;

  /// elevation.
  final double? elevation;

  /// padding.
  final EdgeInsetsGeometry? padding;

  /// safeArea.
  final bool safeArea;

  /// Space outside a floating pill, on every side, in addition to the
  /// [safeArea] inset on [dockEdge].
  ///
  /// Keeps the pill off the screen edge when that edge has no system bar.
  /// Null uses [MorphToolbarTheme.screenOffset]. Ignored when docked.
  final double? screenOffset;

  /// clipBehavior.
  final Clip clipBehavior;

  /// semanticLabel.
  final String? semanticLabel;

  /// Optional manual visibility controller (show / hide / toggle).
  final MorphToolbarVisibilityController? visibilityController;

  /// Optional scroll-exit behavior. Default null = no scroll detection.
  ///
  /// When set, uses the behavior's controller unless [visibilityController]
  /// is also provided (then they should be the same instance).
  final MorphToolbarScrollBehavior? scrollBehavior;

  /// Overrides measured exit distance when non-null.
  final double? exitExtent;

  /// Optional seed / external sync for the active action index.
  ///
  /// Selection is owned internally only when [onActiveIndexChanged] is set.
  /// Expand triggers do not become active. When selection is enabled,
  /// per-action [MorphToolbarAction.active] is ignored.
  final int? activeIndex;

  /// Enables toolbar-owned selection and notifies when the active index changes.
  ///
  /// When non-null, taps update internal selection then invoke this callback;
  /// [MorphToolbarAction.onPressed] is not called. When null, taps only run the
  /// action (or expand-trigger toggle) — no internal selection.
  final ValueChanged<int>? onActiveIndexChanged;

  @override
  Size get preferredSize =>
      const Size.fromHeight(MorphToolbarTokens.containerSize);

  @override
  State<MorphToolbar> createState() => _MorphToolbarState();
}

class _MorphToolbarState extends State<MorphToolbar>
    with TickerProviderStateMixin {
  late bool _expanded;
  late SingleMotionController _expandCtrl;
  double _fabSize = MorphToolbarTokens.fabBaseline;
  int? _activeIndex;

  /// Docked bar's own measured extent along the exit axis, tracked so its
  /// reserved layout space (e.g. Scaffold.bottomNavigationBar) can shrink in
  /// sync with scroll-exit instead of leaving an empty slot behind.
  double? _dockedExtent;

  bool get _floating => widget.placement == MorphToolbarPlacement.floating;
  bool get _hasFab =>
      _floating &&
      (widget.floatingActionButton != null ||
          widget.fabIcon != null ||
          widget.fabExpandIcon != null ||
          widget.fabCollapseIcon != null);
  bool get _hasTrigger => widget.actions.any(
    (MorphToolbarItem item) =>
        item is MorphToolbarAction && item.isExpandTrigger,
  );

  /// Scroll-collapse (collapse to the adjacent FAB / expand-trigger action
  /// instead of sliding away). Requires one of those to exist — asserted in
  /// [initState].
  bool get _collapseOnScrollActive =>
      widget.scrollBehavior?.action == MorphToolbarScrollAction.collapse;

  /// Neighbor-reveal expand (no FAB). FAB path uses whole-pill morph instead.
  ///
  /// Independent of scroll behavior: hide-on-scroll's slide-away and
  /// collapse-on-scroll's collapse both compose with a manual tap
  /// expand/collapse rather than disabling it.
  bool get _usesTriggerExpand => _floating && !_hasFab && _hasTrigger;
  bool get _usesFabExpand => _hasFab && widget.fabExpandsToolbar;

  MorphToolbarVisibilityController? get _visibility {
    return widget.visibilityController ?? widget.scrollBehavior?.controller;
  }

  MorphToolbarExitDirection get _exitDirection =>
      widget.scrollBehavior?.exitDirection ?? MorphToolbarExitDirection.bottom;

  /// Actions with toolbar-owned active / press wiring applied.
  List<MorphToolbarItem> get _resolvedActions {
    return <MorphToolbarItem>[
      for (int i = 0; i < widget.actions.length; i++)
        _resolveItem(i, widget.actions[i]),
    ];
  }

  bool get _selectionEnabled => widget.onActiveIndexChanged != null;

  MorphToolbarItem _resolveItem(int index, MorphToolbarItem item) {
    if (item is! MorphToolbarAction) {
      return item;
    }
    final bool triggerExpand = item.isExpandTrigger && _usesTriggerExpand;
    // Docked: never treat as expand trigger for styling / expand behavior.
    final bool showAsTrigger = _floating && item.isExpandTrigger;
    final bool active =
        !triggerExpand &&
        (_selectionEnabled ? _activeIndex == index : item.active);
    return MorphToolbarAction(
      icon: item.icon,
      onPressed: () => _handleActionPressed(index, item),
      tooltip: item.tooltip,
      semanticLabel: item.semanticLabel,
      enabled: item.enabled,
      label: item.label,
      isDestructive: item.isDestructive,
      active: active,
      isExpandTrigger: showAsTrigger,
    );
  }

  void _handleActionPressed(int index, MorphToolbarAction action) {
    if (action.isExpandTrigger && _usesTriggerExpand) {
      _toggleExpanded();
      return;
    }
    if (_selectionEnabled) {
      _setActiveIndex(index);
      return;
    }
    action.onPressed();
  }

  void _setActiveIndex(int index) {
    if (_activeIndex == index) {
      return;
    }
    setState(() => _activeIndex = index);
    widget.onActiveIndexChanged!(index);
  }

  @override
  void initState() {
    super.initState();
    assert(
      widget.actions
              .whereType<MorphToolbarAction>()
              .where((MorphToolbarAction a) => a.isExpandTrigger)
              .length <=
          1,
      'At most one MorphToolbarAction may set isExpandTrigger.',
    );
    assert(
      !_collapseOnScrollActive ||
          (_floating && ((_hasFab && widget.fabExpandsToolbar) || _hasTrigger)),
      'MorphToolbarScrollBehavior.collapseAlways requires a floating toolbar '
      'with an adjacent FAB (fabExpandsToolbar true) or an '
      'MorphToolbarAction.isExpandTrigger action.',
    );
    _activeIndex = widget.activeIndex;
    _expanded = widget.expanded;
    final bool startExpanded =
        _expanded || (!_usesTriggerExpand && !_usesFabExpand);
    _expandCtrl = SingleMotionController(
      motion: MorphToolbarTheme.defaults.expandSpring.toMotion(),
      vsync: this,
      initialValue: startExpanded ? 1 : 0,
    )..addListener(_handleExpandTick);
    _fabSize = _resolvedFabSize(_expandCtrl.value);
    _visibility?.attach(this);
    _visibility?.addListener(_handleScrollCollapseRequest);
    _applyExitExtent();
  }

  @override
  void didUpdateWidget(covariant MorphToolbar oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncVisibilityAttachment(oldWidget);
    _applyExitExtent();
    _syncActiveIndex(oldWidget);
    _syncExpandFromWidget(oldWidget);
  }

  void _syncVisibilityAttachment(MorphToolbar oldWidget) {
    if (oldWidget.visibilityController != widget.visibilityController ||
        oldWidget.scrollBehavior?.controller !=
            widget.scrollBehavior?.controller) {
      final MorphToolbarVisibilityController? oldController =
          oldWidget.visibilityController ??
          oldWidget.scrollBehavior?.controller;
      oldController?.removeListener(_handleScrollCollapseRequest);
      oldWidget.visibilityController?.detach();
      oldWidget.scrollBehavior?.controller.detach();
      _visibility?.attach(this);
      _visibility?.addListener(_handleScrollCollapseRequest);
    }
  }

  /// Mirrors `MorphToolbarVisibilityController.collapseRequested` onto
  /// [_expanded] for [MorphToolbarScrollAction.collapse] — edge-triggered, so
  /// the collapse/expand starts instantly instead of waiting on a spring.
  void _handleScrollCollapseRequest() {
    final MorphToolbarVisibilityController? controller = _visibility;
    if (controller == null) {
      return;
    }
    if (!_collapseOnScrollActive) {
      // Scroll-exit and collapse-on-scroll never run together. A collapse
      // request here means the scroll wrapper was handed a different
      // behavior (collapseAlways) than this toolbar (exitAlways) over the
      // same controller.
      assert(
        !controller.collapseRequested,
        'MorphToolbarScrollBehavior.exitAlways and '
        'MorphToolbarScrollBehavior.collapseAlways do not run together. This '
        'toolbar slides away on scroll, but its controller received a '
        'collapse-on-scroll request. Give MorphToolbarScrollWrapper the same '
        'MorphToolbarScrollBehavior as the toolbar.',
      );
      return;
    }
    _setExpanded(!controller.collapseRequested);
  }

  void _syncActiveIndex(MorphToolbar oldWidget) {
    if (widget.activeIndex != oldWidget.activeIndex &&
        widget.activeIndex != _activeIndex) {
      _activeIndex = widget.activeIndex;
    }
  }

  void _syncExpandFromWidget(MorphToolbar oldWidget) {
    if (!_floating || (!_usesTriggerExpand && !_usesFabExpand)) {
      if (_expandCtrl.value != 1) {
        _expandCtrl.value = 1;
      }
      if (!_expanded) {
        _expanded = true;
      }
      return;
    }

    if (widget.expanded != oldWidget.expanded && widget.expanded != _expanded) {
      _setExpanded(widget.expanded, notify: false);
    }
  }

  @override
  void dispose() {
    _expandCtrl
      ..removeListener(_handleExpandTick)
      ..dispose();
    _visibility?.removeListener(_handleScrollCollapseRequest);
    _visibility?.detach();
    super.dispose();
  }

  void _handleExpandTick() {
    if (!_usesFabExpand) {
      return;
    }
    setState(() {
      _fabSize = _resolvedFabSize(_expandCtrl.value);
    });
  }

  double _resolvedFabSize(double progress) {
    if (_hasFab && !widget.fabExpandsToolbar) {
      return MorphToolbarTokens.fabBaseline;
    }
    return MorphToolbarTokens.fabMedium +
        (MorphToolbarTokens.fabBaseline - MorphToolbarTokens.fabMedium) *
            progress;
  }

  double get _fabLayoutProgress => _usesFabExpand ? _expandCtrl.value : 1.0;

  void _applyExitExtent() {
    final double? extent = widget.exitExtent ?? _visibility?.exitExtent;
    if (extent != null) {
      _visibility?.offsetLimit = -extent.abs();
    }
  }

  void _setExpanded(bool value, {bool notify = true}) {
    if ((!_usesTriggerExpand && !_usesFabExpand) || _expanded == value) {
      return;
    }
    setState(() => _expanded = value);
    if (notify) {
      widget.onExpandedChanged?.call(value);
    }
    _expandCtrl
      ..motion = MorphTheme.of(context).toolbarTheme.expandSpring.toMotion()
      ..animateTo(value ? 1 : 0);
  }

  void _toggleExpanded() => _setExpanded(!_expanded);

  void _onFabPressed() {
    if (_usesFabExpand) {
      _toggleExpanded();
      widget.onFabPressed?.call();
      return;
    }
    widget.onFabPressed?.call();
  }

  @override
  Widget build(BuildContext context) {
    return MorphComponentTheme(builder: _buildToolbar);
  }

  EdgeInsets _edgeSafeAreaInset(BuildContext context) {
    if (!widget.safeArea) {
      return EdgeInsets.zero;
    }
    final EdgeInsets mq = MorphSafeArea.paddingOf(context);
    return EdgeInsets.only(
      top: widget.dockEdge == MorphToolbarDockEdge.top ? mq.top : 0,
      bottom: widget.dockEdge == MorphToolbarDockEdge.bottom ? mq.bottom : 0,
    );
  }

  /// Screen-edge clearance plus the dock-edge system inset, outside the pill.
  ///
  /// Horizontal floating bars use 16. Vertical bars use 24. An explicit
  /// [MorphToolbar.screenOffset] replaces both. Safe area stays outside the pill.
  EdgeInsets _floatingOuterPadding(BuildContext context) {
    final MorphToolbarTheme toolbarTheme = MorphTheme.of(context).toolbarTheme;
    final double offset =
        widget.screenOffset ??
        (widget.axis == Axis.vertical
            ? toolbarTheme.verticalScreenOffset
            : toolbarTheme.screenOffset);
    final EdgeInsets safe = _edgeSafeAreaInset(context);
    return EdgeInsets.fromLTRB(
      offset,
      safe.top + offset,
      offset,
      safe.bottom + offset,
    );
  }

  double _titleOpticalStartInset(
    MorphToolbarTheme toolbarTheme,
    MorphIconButtonTheme iconButtonTheme,
  ) {
    final MorphIconButtonSize buttonSize = toolbarTheme.iconButtonSize(
      widget.size,
    );
    final double targetWidth = iconButtonTheme
        .target(buttonSize, MorphIconButtonWidth.defaultWidth)
        .width;
    final double iconPx = iconButtonTheme.iconSize(buttonSize);
    return (targetWidth - iconPx) / 2;
  }
}
