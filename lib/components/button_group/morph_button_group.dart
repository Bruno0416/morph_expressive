import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:material_ui/material_ui.dart';
import 'package:motor/motor.dart';

import '../../foundations/foundations.dart';
import '../buttons/morph_buttons.dart';
import '../menus/morph_menus.dart';
import 'components/morph_button_group_item_scope.dart';
import 'components/morph_button_group_provider.dart';
import 'components/morph_button_group_scope.dart';
import 'controllers/morph_button_group_overflow_controller.dart';
import 'enums/morph_button_group_enums.dart';
import 'models/morph_button_group_action.dart';
import 'models/morph_button_group_overflow_paging_window.dart';
import 'styles/morph_button_group_theme.dart';

export '../buttons/components/morph_no_overflow_strategy.dart';
export '../buttons/components/morph_overflow_strategy.dart';
export '../buttons/components/morph_scroll_overflow_strategy.dart';
export 'components/morph_button_group_item_scope.dart';
export 'components/morph_button_group_provider.dart';
export 'components/morph_button_group_scope.dart';
export 'controllers/morph_button_group_overflow_controller.dart';
export 'enums/morph_button_group_enums.dart';
export 'models/morph_button_group_action.dart';
export 'models/morph_button_group_overflow_paging_window.dart';
export 'styles/morph_button_group_theme.dart';

part 'components/morph_button_group_align.dart';
part 'components/morph_button_group_parent_data.dart';
part 'components/morph_button_group_collaborators.dart';
part 'components/morph_button_group_overflow_presenter.dart';
part 'components/morph_button_group_render.dart';
part 'components/morph_button_group_measurement.dart';
part 'components/morph_button_group_action_radii.dart';
part 'components/morph_button_group_layout.dart';
part 'components/morph_button_group_overflow_button.dart';
part 'components/morph_button_group_scroll.dart';
part 'components/morph_button_group_build.dart';

/// A row (or column) of selectable [MorphButton]s with standard or connected
/// layout, optional neighbour squish, and overflow handling.
///
/// All actions render as [MorphButton]. Use [MorphButtonGroupAction.minWidth] for
/// icon-only resting widths. Standard groups use size-token between-space;
/// connected groups use a 2dp gap and span their surface.
///
/// Selection:
/// - Single-select (default): [selectedIndex] + [onSelectedIndexChanged]
/// - Multi-select: set [multiSelect] to true and use [selectedIndices] +
///   [onSelectedIndicesChanged]
/// - [selectionRequired] prevents clearing the last selected action
class MorphButtonGroup extends StatefulWidget {
  /// Creates a button group.
  const MorphButtonGroup({
    super.key,
    required this.actions,
    this.type = MorphButtonGroupType.standard,
    this.shape = MorphButtonShape.round,
    this.size = MorphButtonSize.sm,
    this.style = MorphButtonStyle.filled,
    this.density = MorphButtonGroupDensity.regular,
    this.spacing,
    this.direction = Axis.horizontal,
    this.selectedIndex,
    this.selectedIndices,
    this.onSelectedIndexChanged,
    this.onSelectedIndicesChanged,
    this.multiSelect = false,
    this.selectionRequired = false,
    this.neighborSquish = true,
    this.expandedRatio = 0.15,
    this.haptic = MorphHapticFeedback.inherit,
    this.enableFeedback = true,
    this.decoration,
    this.semanticLabel,
    this.clipBehavior = Clip.none,
    this.overflow = MorphButtonGroupOverflow.scroll,
    this.overflowIcon,
    this.overflowPopupDecoration = const MorphOverflowPopupDecoration(),
    this.overflowBottomSheetDecoration =
        const MorphOverflowBottomSheetDecoration(),
    this.overflowMenuStyle = MorphButtonGroupOverflowMenuStyle.popup,
    this.overflowStrategy,
  });

  /// Actions rendered as group buttons.
  final List<MorphButtonGroupAction> actions;

  /// Standard (gapped) or connected (joined) layout.
  final MorphButtonGroupType type;

  /// Default corner strategy for actions (round or square).
  final MorphButtonShape shape;

  /// Size token applied uniformly to every action.
  final MorphButtonSize size;

  /// Visual style applied uniformly to every action.
  final MorphButtonStyle style;

  /// Density level (0…−3) that shrinks container height.
  final MorphButtonGroupDensity density;

  /// Optional between-space override; defaults to size / connection tokens.
  final double? spacing;

  /// Main layout axis.
  final Axis direction;

  /// Controlled single-select index; pair with [onSelectedIndexChanged].
  final int? selectedIndex;

  /// Controlled multi-select indices; pair with [onSelectedIndicesChanged].
  final Set<int>? selectedIndices;

  /// Called when single-select selection changes.
  final ValueChanged<int?>? onSelectedIndexChanged;

  /// Called when multi-select selection changes.
  final ValueChanged<Set<int>>? onSelectedIndicesChanged;

  /// When true, taps toggle membership in [selectedIndices] (multi-select).
  ///
  /// When false (default), selection is exclusive via [selectedIndex].
  final bool multiSelect;

  /// When true, the last selected action cannot be cleared.
  final bool selectionRequired;

  /// Whether pressing an action squishes neighbours (standard horizontal only).
  final bool neighborSquish;

  /// Pressed width growth ratio for neighbour squish (default 0.15).
  final double expandedRatio;

  /// Haptic feedback policy for presses.
  final MorphHapticFeedback haptic;

  /// Whether actions play platform feedback by default.
  final bool enableFeedback;

  /// Group-level decoration merged under each action's decoration.
  final MorphButtonDecoration? decoration;

  /// Semantics label for the group container (optional).
  final String? semanticLabel;

  /// Clip behavior for the group bounds.
  final Clip clipBehavior;

  /// Built-in overflow strategy when [overflowStrategy] is null.
  final MorphButtonGroupOverflow overflow;

  /// Icon for the overflow menu / paging trigger.
  final Widget? overflowIcon;

  /// Decoration for the overflow popup menu.
  final MorphOverflowPopupDecoration overflowPopupDecoration;

  /// Decoration for the overflow bottom sheet.
  final MorphOverflowBottomSheetDecoration overflowBottomSheetDecoration;

  /// Popup vs bottom sheet for [MorphButtonGroupOverflow.menu].
  final MorphButtonGroupOverflowMenuStyle overflowMenuStyle;

  /// Custom overflow strategy; overrides [overflow] when non-null.
  final MorphOverflowStrategy? overflowStrategy;

  bool get _connected => type == MorphButtonGroupType.connected;

  @override
  State<MorphButtonGroup> createState() => _MorphButtonGroupState();
}

class _MorphButtonGroupState extends State<MorphButtonGroup>
    with _ButtonGroupOverflowPresenterMixin {
  late List<WidgetStatesController> _controllers;
  late List<FocusNode?> _focusNodes;
  late int _layoutSignature;
  late int _focusNodeSignature;
  late final MorphButtonGroupOverflowController _overflowController;
  late final ScrollController _scrollOverflowController;
  late final _ButtonGroupPressCoordinator _pressCoordinator;
  late final _ButtonGroupMeasurementOrchestrator _measurement;
  int? _lastOverflowSelectionIndex;

  final ValueNotifier<int?> _focusedIndexNotifier = ValueNotifier<int?>(null);

  bool _isRtl = false;

  int get _measurementGeneration => _measurement.generation;
  set _measurementGeneration(int value) => _measurement.generation = value;

  List<GlobalKey> get _unselectedKeys => _measurement.unselectedKeys;
  List<GlobalKey> get _selectedKeys => _measurement.selectedKeys;

  List<double?> get _measuredUnselectedWidths =>
      _measurement.measuredUnselectedWidths;
  List<double?> get _measuredSelectedWidths =>
      _measurement.measuredSelectedWidths;

  bool get _hasAnyLabel => _measurement.hasAnyLabel;
  set _hasAnyLabel(bool value) => _measurement.hasAnyLabel = value;

  double _iconOnlyNaturalSizeCache = 40;

  bool get _supportsAnimatedSquish =>
      widget.direction == Axis.horizontal &&
      !widget._connected &&
      widget.neighborSquish;

  /// Exclusive selection is the default regardless of attached callbacks.
  /// Multi-selection must be requested explicitly through [multiSelect].
  bool get _isMultiSelect => widget.multiSelect;

  late List<MorphButtonDecoration> _cachedDecorations;
  bool _stateDisposed = false;

  @override
  void initState() {
    super.initState();
    _assertControlledSelection();
    _bootstrapState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateDecorations();
    _updateIconOnlyNaturalSizeCache();
    _scheduleMeasurementIfNeeded();
  }

  @override
  void didUpdateWidget(covariant MorphButtonGroup old) {
    super.didUpdateWidget(old);
    _assertControlledSelection();
    _applyWidgetUpdate(old);
  }

  @override
  void dispose() {
    // Invalidate pending measurement / press frame callbacks before tearing
    // down notifiers (State.mounted stays true until dispose returns).
    _stateDisposed = true;
    _measurementGeneration++;
    _overflowController.stableAllOverflowMeasured.removeListener(
      _handleOverflowChange,
    );
    _pressCoordinator.dispose();
    _disposeControllers();
    _disposeFocusNodes();
    _disposeMeasurerControllers();
    _overflowController.dispose();
    _scrollOverflowController.dispose();
    _focusedIndexNotifier.dispose();
    super.dispose();
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(EnumProperty<MorphButtonGroupType>('type', widget.type))
      ..add(EnumProperty<MorphButtonShape>('shape', widget.shape))
      ..add(DiagnosticsProperty<MorphButtonSize>('size', widget.size))
      ..add(IntProperty('actionCount', widget.actions.length))
      ..add(
        FlagProperty(
          'multiSelect',
          value: widget.multiSelect,
          ifTrue: 'multi-select',
        ),
      )
      ..add(
        FlagProperty(
          'selectionRequired',
          value: widget.selectionRequired,
          ifTrue: 'selection required',
        ),
      )
      ..add(EnumProperty<MorphButtonGroupOverflow>('overflow', widget.overflow))
      ..add(
        FlagProperty(
          'neighborSquish',
          value: widget.neighborSquish,
          ifTrue: 'squish',
        ),
      )
      ..add(FlagProperty('hasLabels', value: _hasAnyLabel, ifTrue: 'labeled'));
  }

  @override
  Widget build(BuildContext context) {
    return MorphComponentTheme(builder: _buildGroup);
  }

  @override
  void _handleOverflowActionSelection(int index) {
    _applyOverflowActionSelection(index);
  }

  @override
  bool _isActionSelected(int index) {
    return _resolveActionSelected(index);
  }
}
