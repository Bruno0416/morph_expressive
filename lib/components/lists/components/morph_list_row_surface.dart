import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import '../../../foundations/foundations.dart';
import '../../cards/morph_cards.dart';
import '../enums/morph_list_enums.dart';
import '../styles/morph_list_theme.dart';
import 'morph_list_feature_scope.dart';
import 'morph_list_focus_ring.dart';
import 'morph_list_interaction.dart';
import 'morph_list_keyboard.dart';
import 'morph_list_reorder_session_scope.dart';
import 'morph_list_transform_scope.dart';

/// Card surface for one list row.
///
/// The container is [MorphCard]. The list draws its inset focus ring around it.
class MorphListRowSurface extends StatefulWidget {
  /// Creates a list row surface.
  const MorphListRowSurface({
    required this.child,
    required this.radius,
    this.onTap,
    this.onLongPress,
    this.enabled = true,
    this.selected = false,
    this.hovered = false,
    this.pressed = false,
    this.focused = false,
    this.dragged = false,
    this.color,
    this.border,
    this.variant = MorphCardVariant.filled,
    this.elevation,
    this.padding = EdgeInsets.zero,
    this.onStateChanged,
    this.suppressHover = false,
    this.minHeight = 0,
    this.mouseCursor,
    this.semanticLabel,
    this.haptic = MorphHapticFeedback.inherit,
    this.semanticButton = true,
    this.semanticChecked,
    this.semanticInMutuallyExclusiveGroup = false,
    this.index,
    super.key,
  });

  /// Row content.
  final Widget child;

  /// Corner radius.
  final BorderRadius radius;

  /// Tap callback. Null keeps the row non-interactive.
  final VoidCallback? onTap;

  /// Long-press callback.
  final VoidCallback? onLongPress;

  /// When false, the row is disabled.
  final bool enabled;

  /// Whether the row is selected.
  final bool selected;

  /// Hover reported by a parent when this surface's card does not track it.
  final bool hovered;

  /// Press reported by a parent when this surface's card does not track it.
  final bool pressed;

  /// Focus reported by a parent when this surface's card does not track it.
  final bool focused;

  /// Whether this row is the drag proxy.
  final bool dragged;

  /// Container color. Null uses the theme container or selected color.
  final Color? color;

  /// Optional outline.
  final BorderSide? border;

  /// Card variant. Elevation comes from the card theme when [elevation] is null.
  final MorphCardVariant variant;

  /// Resting elevation. Null uses the card variant. Drag proxies pass 0.
  final double? elevation;

  /// Pressed, hovered, and focused updates from the card.
  final ValueChanged<MorphInteractionState>? onStateChanged;

  /// Keeps the resting surface while a swipe is moving the row.
  final bool suppressHover;

  /// Padding inside the minimum height.
  final EdgeInsetsGeometry padding;

  /// Minimum outer height. Zero sizes to the child.
  final double minHeight;

  /// Cursor override.
  final MouseCursor? mouseCursor;

  /// Spoken label.
  final String? semanticLabel;

  /// Tap haptic.
  final MorphHapticFeedback haptic;

  /// Whether semantics use the button role.
  final bool semanticButton;

  /// Checkbox or radio checked state.
  final bool? semanticChecked;

  /// Radio-group flag.
  final bool semanticInMutuallyExclusiveGroup;

  /// Row index for keyboard registration. Falls back to [MorphListItemIndex].
  final int? index;

  @override
  State<MorphListRowSurface> createState() => _MorphListRowSurfaceState();
}

class _MorphListRowSurfaceState extends State<MorphListRowSurface> {
  MorphListKeyboardRegistration? _registration;
  FocusNode? _focusNode;
  MorphInteractionState _interaction = const MorphInteractionState();
  MorphInteractionState? _queuedInteraction;
  bool _interactionFrameQueued = false;
  Widget? _transform;
  bool _transformInteractive = false;
  bool _transformFrameQueued = false;
  MorphCardContainerTransformHandle<void>? _transformHandle;
  double _originRadius = 0;
  Color _originColor = const Color(0x00000000);
  ValueNotifier<bool>? _reorderSession;

  void _onNodeFocus() {
    if (mounted) {
      setState(() {});
    }
  }

  void _bindFocus(FocusNode? node) {
    if (identical(_focusNode, node)) {
      return;
    }
    _focusNode?.removeListener(_onNodeFocus);
    _focusNode = node;
    node?.addListener(_onNodeFocus);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final ValueNotifier<bool>? session = MorphListReorderSessionScope.maybeOf(
      context,
    )?.active;
    if (!identical(_reorderSession, session)) {
      _reorderSession?.removeListener(_onReorderSession);
      _reorderSession = session;
      _reorderSession?.addListener(_onReorderSession);
    }
    final int? index = widget.index ?? MorphListItemIndex.maybeOf(context);
    final MorphListKeyboardBinding? binding = MorphListKeyboardGroup.maybeOf(
      context,
    );
    if (_registration != null && _registration!.index != index) {
      _registration!.dispose();
      _registration = null;
    }
    if (_registration == null && index != null && binding != null) {
      _registration = binding.register(index: index);
    }
    _registration?.enabled = widget.enabled && _rowInteractive;
    _bindFocus(_registration?.node);
  }

  @override
  void didUpdateWidget(MorphListRowSurface oldWidget) {
    super.didUpdateWidget(oldWidget);
    _registration?.enabled = widget.enabled && _rowInteractive;
  }

  void _onReorderSession() {
    if (!mounted || (_reorderSession?.value ?? false)) {
      return;
    }
    if (!_interaction.hovered && !_interaction.pressed) {
      return;
    }
    setState(() {
      _interaction = _interaction.copyWith(hovered: false, pressed: false);
    });
  }

  @override
  void dispose() {
    _reorderSession?.removeListener(_onReorderSession);
    _focusNode?.removeListener(_onNodeFocus);
    _focusNode = null;
    final MorphListKeyboardRegistration? registration = _registration;
    _registration = null;
    super.dispose();
    registration?.dispose();
  }

  bool get _rowInteractive =>
      widget.enabled &&
      (widget.onTap != null ||
          widget.onLongPress != null ||
          (_transformInteractive && !widget.dragged));

  void _publishTransform(Widget? destination) {
    _transform = destination;
    final has = destination != null;
    if (has == _transformInteractive || _transformFrameQueued) {
      return;
    }
    _transformFrameQueued = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _transformFrameQueued = false;
      if (!mounted) {
        return;
      }
      final next = _transform != null;
      if (next == _transformInteractive) {
        return;
      }
      setState(() => _transformInteractive = next);
    });
  }

  void _handleTap() {
    final Widget? destination = _transform;
    if (destination != null && !widget.dragged && _transformHandle == null) {
      _openTransform(destination);
    }
    widget.onTap?.call();
  }

  void _openTransform(Widget destination) {
    final RenderObject? object = context.findRenderObject();
    if (object is! RenderBox || !object.hasSize) {
      return;
    }
    final MorphThemeData theme = MorphTheme.of(context);
    final MorphCardTheme cardTheme = theme.cardTheme;
    final MorphCardContainerTransformHandle<void> handle =
        MorphCardContainerTransform.show<void>(
          context: context,
          origin: object.localToGlobal(Offset.zero) & object.size,
          originRadius: _originRadius,
          originColor: _originColor,
          builder: (BuildContext context) => destination,
          scrimColor: cardTheme.resolveTransformScrim(theme.colorScheme),
          openColor: cardTheme.resolveTransformOpenColor(theme.colorScheme),
          endRadius: cardTheme.transformEndRadius,
          contentFadeStart: cardTheme.transformContentFadeStart,
          contentVisibleAt: cardTheme.transformContentVisibleAt,
          motion: cardTheme.transformSpring,
        );
    _transformHandle = handle;
    handle.future.whenComplete(() {
      if (identical(_transformHandle, handle)) {
        _transformHandle = null;
      }
    });
  }

  MorphInteractionState _resolveCardState(MorphInteractionState state) {
    final MorphInteractionState resolved = widget.dragged
        ? state.copyWith(dragged: true)
        : state;
    if (widget.suppressHover && resolved.hovered) {
      return resolved.copyWith(hovered: false);
    }
    return resolved;
  }

  void _onCardState(MorphInteractionState state) {
    final MorphInteractionState resolved = _resolveCardState(state);
    if (SchedulerBinding.instance.schedulerPhase ==
        SchedulerPhase.persistentCallbacks) {
      _queuedInteraction = resolved;
      if (_interactionFrameQueued) {
        return;
      }
      _interactionFrameQueued = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _interactionFrameQueued = false;
        final MorphInteractionState? pending = _queuedInteraction;
        _queuedInteraction = null;
        if (pending == null) {
          return;
        }
        _applyCardState(pending);
      });
      return;
    }
    _applyCardState(resolved);
  }

  void _applyCardState(MorphInteractionState state) {
    if (!mounted) {
      return;
    }
    final MorphInteractionState resolved = _resolveCardState(state);
    widget.onStateChanged?.call(resolved);
    if (resolved.hovered == _interaction.hovered &&
        resolved.focused == _interaction.focused &&
        resolved.pressed == _interaction.pressed &&
        resolved.dragged == _interaction.dragged) {
      return;
    }
    setState(() => _interaction = resolved);
  }

  @override
  Widget build(BuildContext context) {
    final MorphThemeData theme = MorphTheme.of(context);
    final MorphListItemTheme itemTheme = theme.listTheme.item;
    final MorphColorScheme scheme = theme.colorScheme;
    final bool hovered =
        (widget.hovered || _interaction.hovered) && !widget.suppressHover;
    final bool pressed = widget.pressed || _interaction.pressed;
    final bool radiusFocused = widget.focused || _interaction.focused;
    final bool dragged = widget.dragged || _interaction.dragged;
    final BorderRadius radius = itemTheme.radiusFor(
      resting: widget.radius,
      selected: widget.selected,
      hovered: hovered,
      focused: radiusFocused,
      pressed: pressed,
      dragged: dragged,
    );
    final bool paintContainer = itemTheme.restingContainer(
      selected: widget.selected,
      hovered: hovered,
      focused: radiusFocused,
      pressed: pressed,
      dragged: dragged,
    );
    final Color fill = _resolveFill(itemTheme, scheme, paintContainer);
    final bool focused =
        (_focusNode?.hasPrimaryFocus ?? false) && theme.keyboardFocusIndicators;
    _originRadius = radius.topLeft.x;
    _originColor = fill.a == 0 ? scheme.surfaceContainerHighest : fill;
    _registration?.enabled = widget.enabled && _rowInteractive;
    Widget card = _buildCardSurface(
      paintContainer: paintContainer,
      radius: radius,
      fill: fill,
    );
    card = _stateLayer(
      itemTheme: itemTheme,
      scheme: scheme,
      radius: radius,
      dragged: dragged,
      child: card,
    );
    card = MorphListFocusRing(
      focused: focused,
      radius: radius,
      color: itemTheme.resolveFocusIndicator(scheme),
      thickness: itemTheme.focusIndicatorThickness,
      inset: itemTheme.focusIndicatorInset,
      child: card,
    );
    return _wrapSemantics(card);
  }

  Color _resolveFill(
    MorphListItemTheme itemTheme,
    MorphColorScheme scheme,
    bool paintContainer,
  ) {
    if (!paintContainer) {
      return const Color(0x00000000);
    }
    if (widget.selected) {
      return widget.enabled
          ? itemTheme.selectedColor(scheme)
          : itemTheme.disabledSelectedColor(scheme);
    }
    if (itemTheme.style == MorphListStyle.standard) {
      return itemTheme.resolveContainer(scheme);
    }
    return widget.color ?? itemTheme.resolveContainer(scheme);
  }

  /// Resting elevation for the row's [MorphCard] surface.
  ///
  /// List rows use a state-layer fill for hover/press/focus, not elevation —
  /// unlike a standalone [MorphCard], a row should not float above its
  /// neighbors on hover. This always resolves the variant's plain resting
  /// value (ignoring interaction state) so [MorphCard] never applies its own
  /// hover/press/focus elevation bump.
  double _resolveElevation(bool paintContainer) {
    if (widget.dragged || !paintContainer) {
      return 0;
    }
    if (widget.elevation != null) {
      return widget.elevation!;
    }
    return MorphTheme.of(context).cardTheme
        .elevation(widget.variant, hovered: false, enabled: widget.enabled);
  }

  Widget _buildCardSurface({
    required bool paintContainer,
    required BorderRadius radius,
    required Color fill,
  }) {
    final bool canTransform = _transformInteractive && !widget.dragged;
    final VoidCallback? tap = canTransform ? _handleTap : widget.onTap;
    Widget child = widget.child;
    if (widget.minHeight > 0) {
      child = ConstrainedBox(
        constraints: BoxConstraints(minHeight: widget.minHeight),
        child: child,
      );
    }
    return MorphCard(
      variant: paintContainer ? widget.variant : MorphCardVariant.filled,
      borderRadius: radius,
      color: fill,
      border: paintContainer ? widget.border : null,
      elevation: _resolveElevation(paintContainer),
      padding: widget.padding,
      enabled: widget.enabled,
      dragged: widget.dragged,
      onPressed: _rowInteractive ? tap : null,
      onLongPress: _rowInteractive ? widget.onLongPress : null,
      focusNode: _registration?.node,
      focusable: _rowInteractive,
      skipTraversal: _registration != null && !_registration!.tabStop,
      showFocusRing: false,
      showFocusFill: false,
      trackHover: !widget.suppressHover,
      mouseCursor: widget.mouseCursor,
      semanticLabel: widget.semanticLabel,
      haptic: widget.haptic,
      width: double.infinity,
      animationDuration: Duration.zero,
      onStateChanged: _onCardState,
      child: MorphListTransformScope(
        publish: _publishTransform,
        child: MorphListInteractionScope(
          state: widget.suppressHover
              ? _interaction.copyWith(hovered: false)
              : _interaction,
          enabled: widget.enabled,
          selected: widget.selected,
          child: child,
        ),
      ),
    );
  }

  Widget _wrapSemantics(Widget card) {
    if (widget.semanticChecked == null) {
      return card;
    }
    return Semantics(
      container: true,
      checked: widget.semanticChecked,
      inMutuallyExclusiveGroup: widget.semanticInMutuallyExclusiveGroup,
      button: widget.semanticButton && widget.semanticChecked == null,
      enabled: widget.enabled,
      child: card,
    );
  }

  /// Drag and disabled layers. Focus is the inset ring. Hover and press stay
  /// on the card ink.
  Widget _stateLayer({
    required MorphListItemTheme itemTheme,
    required MorphColorScheme scheme,
    required BorderRadius radius,
    required bool dragged,
    required Widget child,
  }) {
    double? opacity;
    if (!widget.enabled) {
      opacity = itemTheme.disabledStateOpacity;
    } else if (dragged) {
      opacity = itemTheme.draggedStateOpacity;
    }
    if (opacity == null || opacity == 0) {
      return child;
    }
    return Stack(
      children: <Widget>[
        child,
        Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: itemTheme
                    .resolveStateLayer(scheme)
                    .withValues(alpha: opacity),
                borderRadius: radius,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
