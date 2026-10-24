import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:motor/motor.dart';

import '../../../foundations/interaction/morph_motion_controller.dart';
import '../../../foundations/foundations.dart';
import '../../cards/enums/morph_card_variant.dart';
import '../../tooltips/morph_tooltips.dart';
import '../enums/morph_expandable_enums.dart';
import '../enums/morph_list_selection_enums.dart';
import '../styles/morph_expandable_style.dart';
import '../styles/morph_list_reorder_state.dart';
import '../styles/morph_list_selection_state.dart';
import '../utils/morph_expandable_spring_motion.dart';
import '../utils/morph_list_immediate_tap.dart';
import '../utils/morph_list_selection_fill.dart';
import '../utils/morph_measure_size.dart';
import 'morph_card_list_item.dart';
import 'morph_expandable_expanded.dart';
import 'morph_expandable_nest_scope.dart';
import 'morph_expandable_snap_collapse.dart';
import 'morph_expandable_sublist.dart';
import 'morph_list_drag_proxy_scope.dart';
import 'morph_list_feature_scope.dart';
import 'morph_list_focus_ring.dart';
import 'morph_list_item_scope.dart';
import 'morph_list_key_target.dart';
import 'morph_list_keyboard.dart';
import 'morph_list_reorder_exclude.dart';
import 'morph_list_row_surface.dart';
import 'morph_list_trailing_override.dart';

part 'morph_expandable_item_body.dart';
part 'morph_expandable_item_interaction.dart';

/// MorphExpandableHeaderBuilder.

typedef MorphExpandableHeaderBuilder = Widget Function(
  BuildContext context,
  int index,
  double progress,
);

/// MorphExpandableBodyBuilder.
typedef MorphExpandableBodyBuilder = Widget Function(
  BuildContext context,
  int index,
  double progress,
);

/// Resolved header/card tap wiring for an expandable item.
typedef _HeaderInteraction = ({
  bool separateLeadingSelect,
  bool entireCardTappable,
  VoidCallback? rawHeaderOrOuter,
  VoidCallback? outerTap,
  VoidCallback? headerTap,
  String? outerTooltip,
  VoidCallback? doubleTap,
});

/// MorphExpandableItem.

class MorphExpandableItem extends StatefulWidget {
  /// MorphExpandableItem.
  const MorphExpandableItem({
    super.key,
    required this.index,
    required this.totalCount,
    required this.isExpanded,
    required this.headerBuilder,
    required this.bodyBuilder,
    required this.decoration,
    required this.expandMotion,
    required this.collapseMotion,
    required this.onToggle,
    this.onTransform,
    this.onTransformAnchor,
    this.expanded,
    this.nestVariant,
    this.trailingGap,
  });

  /// index.

  final int index;

  /// totalCount.
  final int totalCount;

  /// isExpanded.
  final bool isExpanded;

  /// headerBuilder.
  final MorphExpandableHeaderBuilder headerBuilder;

  /// bodyBuilder.
  final MorphExpandableBodyBuilder bodyBuilder;

  /// Optional expanded content (list rows or freeform child).
  final MorphExpandableExpanded? expanded;

  /// decoration.
  final MorphExpandableStyle decoration;

  /// expandMotion.
  final MorphSpring expandMotion;

  /// collapseMotion.
  final MorphSpring collapseMotion;

  /// onToggle.
  final VoidCallback onToggle;

  /// Opens a container transform instead of expanding in place.
  final VoidCallback? onTransform;

  /// Reports the resting row context used to measure the morph origin.
  final ValueChanged<BuildContext>? onTransformAnchor;

  /// Variant a nested sublist inherits when it does not set its own.
  final MorphCardVariant? nestVariant;

  /// Overrides the gap trailing this row, independent of [decoration].
  ///
  /// [decoration]'s own gap still separates a header from its nested sublist
  /// (see [MorphExpandableSublist]) — this only overrides the space between
  /// this row and the next one. Defaults to [MorphExpandableStyle.gap] when
  /// null (e.g. when the reorder host supplies row spacing itself).
  final double? trailingGap;

  @override
  State<MorphExpandableItem> createState() => _MorphExpandableItemState();
}

class _MorphExpandableItemState extends State<MorphExpandableItem>
    with TickerProviderStateMixin {
  late final SingleMotionController _expandCtrl;

  bool _isPressed = false;
  bool _hovered = false;

  /// Fallback toggle node when the item is not inside a list keyboard group.
  final FocusNode _ownToggleFocusNode = FocusNode();

  /// Toggle node registered with the list keyboard group, so a header that
  /// owns its own tap target joins the list's arrow order and single Tab stop.
  MorphListKeyboardRegistration? _toggleRegistration;

  /// Node of the item's single toggle target (whole card or header row).
  FocusNode get _toggleFocusNode =>
      _toggleRegistration?.node ?? _ownToggleFocusNode;
  bool _focused = false;

  double? _collapsedHeight;
  double? _expandedHeight;

  @override
  void initState() {
    super.initState();
    final motion = widget.isExpanded
        ? widget.expandMotion.toMotion()
        : widget.collapseMotion.toMotion();

    _expandCtrl = MorphMotionController(motion: motion, vsync: this)
      ..value = widget.isExpanded ? 1.0 : 0.0;
    _ownToggleFocusNode.addListener(_handleToggleFocusChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) => _reportAnchor());
    FocusManager.instance.addHighlightModeListener(_handleHighlightModeChanged);
    MorphFocusInteraction.instance.addListener(_handleToggleFocusChanged);
  }

  void _reportAnchor() {
    if (!mounted || MorphListDragProxyScope.maybeOf(context) != null) {
      return;
    }
    widget.onTransformAnchor?.call(context);
  }

  void _handleHighlightModeChanged(FocusHighlightMode mode) {
    _handleToggleFocusChanged();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncToggleRegistration();
  }

  void _syncToggleRegistration() {
    final MorphListKeyboardBinding? binding =
        MorphListDragProxyScope.maybeOf(context) != null
        ? null
        : MorphListKeyboardGroup.maybeOf(context);
    final MorphListKeyboardRegistration? current = _toggleRegistration;
    if (current != null && (binding == null || current.index != widget.index)) {
      current.node.removeListener(_handleToggleFocusChanged);
      current.dispose();
      _toggleRegistration = null;
    }
    if (_toggleRegistration == null && binding != null) {
      _toggleRegistration = binding.register(index: widget.index)
        ..node.addListener(_handleToggleFocusChanged);
    }
  }

  @override
  void didUpdateWidget(covariant MorphExpandableItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.index != widget.index) {
      _syncToggleRegistration();
    }

    _reportAnchor();
    if (oldWidget.isExpanded != widget.isExpanded) {
      final bool snap = MorphExpandableSnapCollapse.of(context);
      if (snap) {
        _expandCtrl.value = widget.isExpanded ? 1.0 : 0.0;
      } else {
        final motion = widget.isExpanded
            ? widget.expandMotion.toMotion()
            : widget.collapseMotion.toMotion();
        _expandCtrl.motion = motion;
        _expandCtrl.animateTo(widget.isExpanded ? 1.0 : 0.0);
      }
    }
  }

  void _handleTapDown() => setState(() => _isPressed = true);
  void _handleTapUp() => setState(() => _isPressed = false);
  void _handleTapCancel() => setState(() => _isPressed = false);

  void _setHovered(bool value) {
    if (_hovered == value) {
      return;
    }
    setState(() => _hovered = value);
  }

  void _handleCardStateChanged(MorphInteractionState state) {
    if (_isPressed == state.pressed) {
      return;
    }
    setState(() => _isPressed = state.pressed);
  }

  void _handleToggleFocusChanged() {
    if (!mounted) {
      return;
    }
    final bool show = MorphFocusRing.shouldShow(_toggleFocusNode, context);
    if (_focused != show) {
      setState(() => _focused = show);
    }
  }

  @override
  void dispose() {
    MorphFocusInteraction.instance.removeListener(_handleToggleFocusChanged);
    FocusManager.instance.removeHighlightModeListener(
      _handleHighlightModeChanged,
    );
    _ownToggleFocusNode
      ..removeListener(_handleToggleFocusChanged)
      ..dispose();
    _toggleRegistration?.node.removeListener(_handleToggleFocusChanged);
    _toggleRegistration?.dispose();
    _toggleRegistration = null;
    _expandCtrl.dispose();
    super.dispose();
  }

  bool get _hasListExpansion {
    final MorphExpandableExpanded? expanded = widget.expanded;
    return expanded != null && expanded.isList;
  }

  BorderRadius _buildEffectiveRadius() {
    final d = widget.decoration;
    final BorderRadius? selectedRadius = morphSelectionRadius(
      context,
      widget.index,
      outerRadius: d.outerRadius,
    );
    if (selectedRadius != null) {
      return selectedRadius;
    }

    if (_hasListExpansion) {
      return morphExpandableParentRadius(
        globalPosition: calculateCardPosition(widget.index, widget.totalCount),
        outerRadius: d.outerRadius,
        innerRadius: d.innerRadius,
        isExpanded: widget.isExpanded,
        hasSublist: true,
      );
    }

    final isFirst = widget.index == 0;
    final isLast = widget.index == widget.totalCount - 1;
    final isSingle = widget.totalCount == 1;

    if (widget.isExpanded && d.expandedRadius != null) {
      return BorderRadius.circular(d.expandedRadius!);
    }

    if (isSingle) {
      return BorderRadius.circular(d.outerRadius);
    }

    final effectiveInnerRadius = d.innerRadius;

    if (isFirst) {
      return BorderRadius.vertical(
        top: Radius.circular(d.outerRadius),
        bottom: Radius.circular(effectiveInnerRadius),
      );
    }
    if (isLast) {
      return BorderRadius.vertical(
        top: Radius.circular(effectiveInnerRadius),
        bottom: Radius.circular(d.outerRadius),
      );
    }
    return BorderRadius.circular(effectiveInnerRadius);
  }

  @override
  Widget build(BuildContext context) {
    final theme = MorphTheme.of(context);
    final scheme = theme.colorScheme;
    final d = widget.decoration;
    final isLast = widget.index == widget.totalCount - 1;
    final hasList = _hasListExpansion;
    final interaction = _resolveHeaderInteraction(d: d, hasList: hasList);

    Widget content = _buildHeaderCard(
      scheme: scheme,
      d: d,
      hasList: hasList,
      interaction: interaction,
    );
    if (hasList) {
      content = _buildListExpansionColumn(
        headerCard: content,
        d: d,
        isLast: isLast,
      );
    }

    final double trailingGap = widget.trailingGap ?? d.gap;

    // Same local reading-order group as dropdown panel items: header, then
    // revealed sublist rows, then the next sibling outside this group.
    return RepaintBoundary(
      child: Padding(
        padding: d.margin ?? EdgeInsets.zero,
        child: Padding(
          padding: EdgeInsets.only(bottom: isLast ? 0 : trailingGap),
          child: FocusTraversalGroup(
            policy: ReadingOrderTraversalPolicy(),
            child: content,
          ),
        ),
      ),
    );
  }
}
