part of '../morph_lists.dart';

enum _MorphListLayout { column, scrollable, sliver }

/// One list for selection, variant, reorder, swipe, and expand.
///
/// List-level fields apply to every row. A row opts into swipe with
/// [MorphListItem.swipe] and into expand with [MorphListItem.expanded].
/// A sub-list expansion is its own nested [MorphList].
class MorphList extends StatefulWidget {
  /// Non-scrollable column.
  const MorphList({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.outerRadius = MorphListCardListTheme.defaultOuterRadius,
    this.innerRadius = MorphListCardListTheme.defaultInnerRadius,
    this.gap = MorphListCardListTheme.defaultGap,
    this.color,
    this.colorBuilder,
    this.borderRadiusBuilder,
    this.padding,
    this.margin,
    this.onTap,
    this.onLongPress,
    this.semanticLabelBuilder,
    this.mouseCursor,
    this.haptic = MorphHapticFeedback.inherit,
    this.variant,
    this.border,
    this.emptyBuilder,
    this.selection = false,
    this.reorder = false,
    this.selectionController,
    this.onSelectionChanged,
    this.onReorder,
    this.selectionState,
    this.reorderState,
    this.embedded = false,
    this.semanticsLabel,
    this.dismissController,
    this.dismissStyle = const MorphDismissibleListStyle(),
    this.allowMultipleExpanded,
    this.initiallyExpanded = const <int>{},
    this.expandStyle,
    this.expandMotion,
    this.collapseMotion,
    this.onExpansionChanged,
    this.expandController,
  }) : assert(
         !reorder || onReorder != null,
         'onReorder is required when reorder is true',
       ),
       _layout = _MorphListLayout.column,
       controller = null,
       physics = null,
       shrinkWrap = false,
       listPadding = null,
       clipBehavior = Clip.hardEdge;

  /// Scrollable list.
  const MorphList.scrollable({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.outerRadius = MorphListCardListTheme.defaultOuterRadius,
    this.innerRadius = MorphListCardListTheme.defaultInnerRadius,
    this.gap = MorphListCardListTheme.defaultGap,
    this.color,
    this.colorBuilder,
    this.borderRadiusBuilder,
    this.padding,
    this.margin,
    this.onTap,
    this.onLongPress,
    this.semanticLabelBuilder,
    this.mouseCursor,
    this.haptic = MorphHapticFeedback.inherit,
    this.variant,
    this.border,
    this.emptyBuilder,
    this.controller,
    this.physics,
    this.shrinkWrap = false,
    this.listPadding,
    this.clipBehavior = Clip.hardEdge,
    this.selection = false,
    this.reorder = false,
    this.selectionController,
    this.onSelectionChanged,
    this.onReorder,
    this.selectionState,
    this.reorderState,
    this.embedded = false,
    this.semanticsLabel,
    this.dismissController,
    this.dismissStyle = const MorphDismissibleListStyle(),
    this.allowMultipleExpanded,
    this.initiallyExpanded = const <int>{},
    this.expandStyle,
    this.expandMotion,
    this.collapseMotion,
    this.onExpansionChanged,
    this.expandController,
  }) : assert(
         !reorder || onReorder != null,
         'onReorder is required when reorder is true',
       ),
       _layout = _MorphListLayout.scrollable;

  /// Sliver list. Selection stays; reorder is not supported.
  const MorphList.sliver({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.outerRadius = MorphListCardListTheme.defaultOuterRadius,
    this.innerRadius = MorphListCardListTheme.defaultInnerRadius,
    this.gap = MorphListCardListTheme.defaultGap,
    this.color,
    this.colorBuilder,
    this.borderRadiusBuilder,
    this.padding,
    this.margin,
    this.onTap,
    this.onLongPress,
    this.semanticLabelBuilder,
    this.mouseCursor,
    this.haptic = MorphHapticFeedback.inherit,
    this.variant,
    this.border,
    this.emptyBuilder,
    this.selection = false,
    this.selectionController,
    this.onSelectionChanged,
    this.selectionState,
    this.embedded = false,
    this.semanticsLabel,
    this.dismissController,
    this.dismissStyle = const MorphDismissibleListStyle(),
    this.allowMultipleExpanded,
    this.initiallyExpanded = const <int>{},
    this.expandStyle,
    this.expandMotion,
    this.collapseMotion,
    this.onExpansionChanged,
    this.expandController,
  }) : _layout = _MorphListLayout.sliver,
       reorder = false,
       onReorder = null,
       reorderState = null,
       controller = null,
       physics = null,
       shrinkWrap = false,
       listPadding = null,
       clipBehavior = Clip.hardEdge;

  final _MorphListLayout _layout;

  /// Number of rows.
  final int itemCount;

  /// Builds the row at the given index. A list item can set swipe and expanded.
  final IndexedWidgetBuilder itemBuilder;

  /// Outer corner radius.
  final double outerRadius;

  /// Inner corner radius.
  final double innerRadius;

  /// Gap between rows.
  final double gap;

  /// Shared row fill. Null lets the variant or a parent nest choose.
  final Color? color;

  /// Per-index fill. Non-null wins over [color].
  final Color? Function(int index)? colorBuilder;

  /// Per-index radius. Non-null wins over position radii.
  final BorderRadius? Function(int index, MorphCardPosition position)?
  borderRadiusBuilder;

  /// Padding inside each non-expanding row.
  final EdgeInsetsGeometry? padding;

  /// Margin around the whole list.
  final EdgeInsetsGeometry? margin;

  /// Called when a non-expanding row is tapped.
  final void Function(int index)? onTap;

  /// Called when a non-expanding row is long-pressed.
  final void Function(int index)? onLongPress;

  /// Semantic label for a row.
  final String Function(int index)? semanticLabelBuilder;

  /// Cursor for a row.
  final MouseCursor? mouseCursor;

  /// Haptic on a non-expanding row tap.
  final MorphHapticFeedback haptic;

  /// Filled, outlined, or elevated. A nested list inherits the parent variant.
  final MorphCardVariant? variant;

  /// Outline override.
  final BorderSide? border;

  /// Shown when [itemCount] is 0.
  final Widget? emptyBuilder;

  /// Scroll controller for [MorphList.scrollable].
  final ScrollController? controller;

  /// Scroll physics for [MorphList.scrollable].
  final ScrollPhysics? physics;

  /// Sizes the scroll view to its children.
  final bool shrinkWrap;

  /// Padding around the scrollable list.
  final EdgeInsetsGeometry? listPadding;

  /// Clip for [MorphList.scrollable].
  final Clip clipBehavior;

  /// Enables selection.
  final bool selection;

  /// Enables long-press reorder. Requires [onReorder].
  final bool reorder;

  /// Optional selection controller. An ancestor scope wins.
  final MorphSelectionController? selectionController;

  /// Called when selection changes.
  final ValueChanged<Set<int>>? onSelectionChanged;

  /// Called after a reorder drop.
  final ReorderCallback? onReorder;

  /// Selection state override.
  final MorphListSelectionState? selectionState;

  /// Reorder state override.
  final MorphListReorderState? reorderState;

  /// Forces nested corner radii even when this list is not under a parent.
  final bool embedded;

  /// List-box description.
  final String? semanticsLabel;

  /// Reveals or dismisses a swiping row by index.
  final MorphDismissibleListController? dismissController;

  /// Shared swipe chrome (springs, action metrics, default background).
  final MorphDismissibleListStyle dismissStyle;

  /// When false, opening one row closes the others.
  final bool? allowMultipleExpanded;

  /// Rows that start expanded.
  final Set<int> initiallyExpanded;

  /// Expandable row decoration override.
  final MorphExpandableStyle? expandStyle;

  /// Spring used while expanding.
  final MorphSpring? expandMotion;

  /// Spring used while collapsing.
  final MorphSpring? collapseMotion;

  /// Called when a row expands or collapses.
  final void Function(int index, {required bool isExpanded})?
  onExpansionChanged;

  /// Opens a row container transform by index.
  final MorphExpandableListController? expandController;

  @override
  State<MorphList> createState() => _MorphListState();
}

class _MorphListState extends State<MorphList>
    with
        TickerProviderStateMixin,
        MorphDismissibleCardMixin,
        MorphDismissibleCardDragMixin,
        MorphDismissibleCardBuildMixin {
  final List<Widget> _built = <Widget>[];
  final List<MorphListItemSwipe?> _swipes = <MorphListItemSwipe?>[];
  final List<MorphExpandableExpanded?> _expanded = <MorphExpandableExpanded?>[];
  final List<Widget?> _transforms = <Widget?>[];

  late Set<int> _expandedIndices;
  final Map<int, BuildContext> _transformAnchors = <int, BuildContext>{};
  MorphCardContainerTransformHandle<void>? _transformHandle;
  int? _collapsedForReorder;
  bool _snapCollapse = false;
  bool _embeddedActive = false;
  int? _styleDataIndex;

  @override
  int get swipeItemCount => widget.itemCount;

  @override
  MorphDismissibleListStyle get style {
    final MorphDismissibleListStyle base = widget.dismissStyle;
    final int? index = _styleDataIndex;
    if (index == null) {
      return base;
    }
    final MorphListItemSwipe? swipe = _swipeAt(index);
    if (swipe == null ||
        (swipe.background == null && swipe.secondaryBackground == null)) {
      return base;
    }
    return base.copyWith(
      background: swipe.background,
      secondaryBackground: swipe.secondaryBackground,
    );
  }

  @override
  bool get embedded => _embeddedActive;

  @override
  bool get listReorderEnabled => widget.reorder;

  @override
  Future<bool> Function(int, DismissDirection)? get onDismissCallback =>
      _dismissAt;

  @override
  void Function(int)? get onTapCallback => widget.onTap;

  @override
  void Function(int)? get onLongPressCallback => widget.onLongPress;

  @override
  Color? Function(int index)? get colorBuilder => widget.colorBuilder;

  @override
  BorderRadius? Function(int index, MorphCardPosition position)?
  get borderRadiusBuilder => widget.borderRadiusBuilder;

  @override
  List<MorphListSwipeAction> Function(int index)? get leadingActionsBuilder =>
      (int index) => _swipeAt(index)?.leading ?? const <MorphListSwipeAction>[];

  @override
  List<MorphListSwipeAction> Function(int index)? get trailingActionsBuilder =>
      (int index) => _swipeAt(index)?.trailing ?? const <MorphListSwipeAction>[];

  @override
  MorphListSwipeMode get swipeMode =>
      _swipeAt(activeSwipeIndex ?? -1)?.mode ?? MorphListSwipeMode.both;

  @override
  MorphListSwipeEdge get dismissEdge =>
      _swipeAt(activeSwipeIndex ?? -1)?.edge ?? MorphListSwipeEdge.both;

  @override
  bool swipeItemPaintsSurface(int dataIndex) => _expandedAt(dataIndex) != null;

  @override
  Widget swipeItemBuilder(BuildContext context, int dataIndex) {
    return MorphListItemIndex(
      index: dataIndex,
      child: _childAt(context, dataIndex),
    );
  }

  @override
  void initState() {
    super.initState();
    _expandedIndices = Set<int>.from(widget.initiallyExpanded);
    initSlots();
    bindSwipeController(widget.dismissController);
    _bindExpandController(widget.expandController);
  }

  @override
  void didUpdateWidget(MorphList oldWidget) {
    super.didUpdateWidget(oldWidget);
    syncSlotsIfNeeded(oldWidget.itemCount);
    bindSwipeController(widget.dismissController);
    if (oldWidget.expandController != widget.expandController) {
      oldWidget.expandController?.detach();
      _bindExpandController(widget.expandController);
    }
  }

  @override
  void dispose() {
    widget.expandController?.detach();
    unbindSwipeController();
    disposeSlots();
    super.dispose();
  }

  Future<bool> _dismissAt(int index, DismissDirection direction) {
    final Future<bool> Function(DismissDirection direction)? dismiss = _swipeAt(
      index,
    )?.onDismiss;
    if (dismiss == null) {
      return Future<bool>.value(true);
    }
    return dismiss(direction);
  }

  MorphListItemSwipe? _swipeAt(int index) {
    if (index < 0 || index >= _swipes.length) {
      return null;
    }
    return _swipes[index];
  }

  MorphExpandableExpanded? _expandedAt(int index) {
    if (index < 0 || index >= _expanded.length) {
      return null;
    }
    return _expanded[index];
  }

  bool _enabledAt(int index) {
    if (index < 0 || index >= _built.length) {
      return true;
    }
    final Widget child = _built[index];
    return child is! MorphListItem || child.enabled;
  }

  @override
  Widget buildSlot(
    BuildContext context,
    int slotIndex, {
    List<int>? visible,
    bool suppressOwnGap = false,
  }) {
    final List<int> shown = visible ?? computeVisibleIndices();
    final int dataIndex = shown.indexOf(slotIndex);
    _styleDataIndex = dataIndex < 0 ? null : dataIndex;
    final Widget child = super.buildSlot(
      context,
      slotIndex,
      visible: shown,
      suppressOwnGap: suppressOwnGap,
    );
    _styleDataIndex = null;
    return child;
  }

  @override
  Widget build(BuildContext context) {
    assert(
      widget._layout != _MorphListLayout.sliver || !widget.reorder,
      'MorphList.sliver does not support reorder.',
    );
    return MorphComponentTheme(builder: _buildList);
  }
}

int _remapListIndex(int index, int from, int to) {
  if (index == from) {
    return to;
  }
  if (from < to && index > from && index <= to) {
    return index - 1;
  }
  if (from > to && index >= to && index < from) {
    return index + 1;
  }
  return index;
}
