import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:motor/motor.dart';

import '../../foundations/interaction/morph_motion_controller.dart';
import '../../foundations/foundations.dart';
import '../divider/morph_divider.dart';
import 'components/morph_card_container_transform.dart';
import 'components/morph_card_group_scope.dart';
import 'controllers/morph_card_controller.dart';
import 'enums/morph_card_divider_span.dart';
import 'enums/morph_card_overflow_alignment.dart';
import 'enums/morph_card_swipe_mode.dart';
import 'enums/morph_card_variant.dart';
import 'styles/morph_card_theme.dart';

export 'components/morph_card_container_transform.dart'
    show
        MorphCardContainerTransform,
        MorphCardContainerTransformHandle,
        MorphCardContainerTransformScope;
export 'components/morph_card_group.dart';
export 'controllers/morph_card_controller.dart';
export 'enums/morph_card_divider_span.dart';
export 'enums/morph_card_group_layout.dart';
export 'enums/morph_card_overflow_alignment.dart';
export 'enums/morph_card_swipe_mode.dart';
export 'enums/morph_card_variant.dart';
export 'styles/morph_card_theme.dart';

part 'components/morph_card_content.dart';
part 'components/morph_card_swipe.dart';

const double _kSwipeReveal = 80;

SpringMotion _swipeSpring(MorphSpring spring) {
  return MorphMotion.springMotion(spring);
}

/// A Material 3 card surface for one subject.
///
/// The container is the only required piece. Pass [child] for custom content,
/// or the structured slots for media, text, actions, and overflow.
class MorphCard extends StatefulWidget {
  /// Creates a card.
  const MorphCard({
    this.child,
    this.variant = MorphCardVariant.elevated,
    this.onPressed,
    this.onLongPress,
    this.onSwipe,
    this.swipeMode = MorphCardSwipeMode.both,
    this.swipeAction,
    this.leadingSwipeAction,
    this.trailingSwipeAction,
    this.leadingSwipeColor,
    this.trailingSwipeColor,
    this.alternativeActions,
    this.openBuilder,
    this.controller,
    this.enabled = true,
    this.expanded = false,
    this.dragged = false,
    this.padding,
    this.clipBehavior = Clip.antiAlias,
    this.borderRadius,
    this.color,
    this.elevation,
    this.border,
    this.animationDuration,
    this.animationCurve,
    this.width,
    this.maxHeight,
    this.surfaceKey,
    this.mouseCursor,
    this.focusNode,
    this.focusable = true,
    this.skipTraversal,
    this.showFocusRing = true,
    this.showFocusFill = true,
    this.trackHover = true,
    this.semanticLabel,
    this.semanticLink = false,
    this.haptic = MorphHapticFeedback.inherit,
    this.onStateChanged,
    this.media,
    this.vertical,
    this.mediaDecorative = false,
    this.headline,
    this.subhead,
    this.supportingText,
    this.actions,
    this.overflow,
    this.overflowAlignment = MorphCardOverflowAlignment.topEnd,
    this.dividerAfterMedia = false,
    this.dividerAfterText = false,
    this.mediaDividerSpan = MorphCardDividerSpan.edge,
    this.textDividerSpan = MorphCardDividerSpan.padding,
    this.contentOnMedia = false,
    this.contentOverlayPlate,
    super.key,
  });

  /// Custom content. Omitted from the structured column when null.
  final Widget? child;

  /// Elevated, filled, or outlined.
  final MorphCardVariant variant;

  /// Primary action. Also runs before a container transform opens.
  final VoidCallback? onPressed;

  /// Long-press action.
  final VoidCallback? onLongPress;

  /// Runs after a dismiss swipe. Ignored when [swipeMode] is
  /// [MorphCardSwipeMode.reveal].
  final VoidCallback? onSwipe;

  /// Dismiss only, reveal only, or reveal then dismiss. Defaults to both.
  final MorphCardSwipeMode swipeMode;

  /// Background shown on both sides when [leadingSwipeAction] and
  /// [trailingSwipeAction] are null.
  final Widget? swipeAction;

  /// Revealed on the leading side. In LTR that is a swipe to the right.
  final Widget? leadingSwipeAction;

  /// Revealed on the trailing side. In LTR that is a swipe to the left.
  final Widget? trailingSwipeAction;

  /// Fill behind [leadingSwipeAction]. Null uses the primary container.
  final Color? leadingSwipeColor;

  /// Fill behind [trailingSwipeAction]. Null uses the primary container.
  final Color? trailingSwipeColor;

  /// Long-press menu anchor. Receives the card's global rect so the menu
  /// can open beside the card instead of on top of it.
  final void Function(Rect cardRect)? alternativeActions;

  /// Full-screen destination for the container transform.
  final WidgetBuilder? openBuilder;

  /// Opens and closes [openBuilder].
  final MorphCardController? controller;

  /// When false, the card uses the disabled tokens and ignores input.
  final bool enabled;

  /// Removes the max-height cap so the card can grow with the page.
  final bool expanded;

  /// Paints the dragged elevation and state layer.
  final bool dragged;

  /// Inner padding. Null uses the theme padding.
  final EdgeInsetsGeometry? padding;

  /// How the container clips its child.
  final Clip clipBehavior;

  /// Corner radius. Null uses the theme radius.
  final BorderRadius? borderRadius;

  /// Container color override.
  final Color? color;

  /// Elevation override for every state.
  final double? elevation;

  /// Outline override.
  final BorderSide? border;

  /// Duration of color and elevation changes.
  final Duration? animationDuration;

  /// Curve of color and elevation changes.
  final Curve? animationCurve;

  /// Width of the container.
  final double? width;

  /// Unexpanded content cap. Null uses the theme cap, which is also null.
  final double? maxHeight;

  /// Key for the decorated container.
  final Key? surfaceKey;

  /// Cursor used while the card is actionable.
  final MouseCursor? mouseCursor;

  /// Focus node for the card action. The card owns one when this is null.
  final FocusNode? focusNode;

  /// Whether the card action can take keyboard focus.
  final bool focusable;

  /// Tab-order override. Null follows [focusable].
  final bool? skipTraversal;

  /// Draws the card focus ring. List rows turn this off and draw their own.
  final bool showFocusRing;

  /// Paints the focused state-layer fill. List rows use their inset ring instead.
  final bool showFocusFill;

  /// When false, moving the pointer does not paint the hover layer.
  final bool trackHover;

  /// Screen-reader label. Defaults to the headline and supporting text.
  final String? semanticLabel;

  /// Uses a link role instead of a button role when the card is actionable.
  final bool semanticLink;

  /// Tap haptic.
  final MorphHapticFeedback haptic;

  /// Reports hover, focus, press, and drag.
  final ValueChanged<MorphInteractionState>? onStateChanged;

  /// Thumbnail, image, or video.
  final Widget? media;

  /// Stacks [media] above the text.
  ///
  /// Null follows the card group. Outside a group, media sits beside the text.
  final bool? vertical;

  /// Hides [media] from screen readers.
  final bool mediaDecorative;

  /// Primary subject.
  final String? headline;

  /// Secondary context under the headline.
  final String? subhead;

  /// Body copy.
  final String? supportingText;

  /// Buttons and other controls. They keep their own taps and tab stops.
  final Widget? actions;

  /// Overflow control, typically a menu. Placed at [overflowAlignment].
  final Widget? overflow;

  /// Corner used by [overflow].
  final MorphCardOverflowAlignment overflowAlignment;

  /// Divider after [media].
  final bool dividerAfterMedia;

  /// Whether [dividerAfterMedia] reaches the card edges or the padding.
  final MorphCardDividerSpan mediaDividerSpan;

  /// Divider after the text block.
  final bool dividerAfterText;

  /// Whether [dividerAfterText] reaches the card edges or the padding.
  final MorphCardDividerSpan textDividerSpan;

  /// Paints the text on top of [media] with a scrim or plate.
  final bool contentOnMedia;

  /// Plate instead of a scrim when [contentOnMedia] is true. Null uses the theme.
  final bool? contentOverlayPlate;

  @override
  State<MorphCard> createState() => _MorphCardState();
}

class _MorphCardState extends State<MorphCard>
    with SingleTickerProviderStateMixin
    implements MorphCardControllerClient {
  double _swipeDx = 0;
  bool _dismissPending = false;
  int _swipeEpoch = 0;
  bool _transformOpen = false;
  void Function([Object? result])? _closeTransform;
  late final SingleMotionController _swipeMotion;
  FocusNode? _ownedFocus;
  final ValueNotifier<bool> _keyboardFocused = ValueNotifier<bool>(false);

  FocusNode get _focusNode => widget.focusNode ?? _ownedFocus!;

  bool get _hasPrimaryAction =>
      widget.onPressed != null ||
      widget.onLongPress != null ||
      widget.openBuilder != null ||
      widget.alternativeActions != null;

  bool get _actionable => widget.enabled && _hasPrimaryAction;

  @override
  void initState() {
    super.initState();
    _swipeMotion =
        MorphMotionController(
          motion: _swipeSpring(MorphMotion.expressiveSpatialDefault),
          vsync: this,
        )..addListener(() {
          if (!mounted) {
            return;
          }
          final double dx = _swipeMotion.value;
          setState(() => _swipeDx = dx);
          _commitDismissIfOffscreen(dx);
        });
    widget.controller?.attach(this);
    if (widget.focusNode == null) {
      _ownedFocus = FocusNode(debugLabel: 'MorphCard');
    }
  }

  @override
  void didUpdateWidget(MorphCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.detach(this);
      widget.controller?.attach(this);
    }
    if (widget.focusNode == null && _ownedFocus == null) {
      _ownedFocus = FocusNode(debugLabel: 'MorphCard');
    } else if (widget.focusNode != null && _ownedFocus != null) {
      _ownedFocus!.dispose();
      _ownedFocus = null;
    }
  }

  @override
  void dispose() {
    _swipeMotion.dispose();
    _ownedFocus?.dispose();
    _keyboardFocused.dispose();
    widget.controller?.detach(this);
    super.dispose();
  }

  @override
  bool get isTransformOpen => _transformOpen;

  @override
  Future<T?> openTransform<T extends Object?>({WidgetBuilder? builder}) async {
    final WidgetBuilder? openBuilder = builder ?? widget.openBuilder;
    if (openBuilder == null || _transformOpen) {
      return null;
    }
    final RenderObject? renderObject = context.findRenderObject();
    if (renderObject is! RenderBox || !renderObject.hasSize) {
      return null;
    }
    final MorphThemeData theme = MorphTheme.of(context);
    final MorphCardTheme cardTheme = theme.cardTheme;
    final BorderRadius radius = widget.borderRadius ?? cardTheme.borderRadius;
    final Rect origin =
        renderObject.localToGlobal(Offset.zero) & renderObject.size;
    final Color originColor =
        widget.color ??
        cardTheme.containerColorFor(
          theme.colorScheme,
          widget.variant,
          enabled: widget.enabled,
        );
    final MorphCardContainerTransformHandle<T> handle =
        MorphCardContainerTransform.show<T>(
          context: context,
          origin: origin,
          originRadius: radius.topLeft.x,
          originColor: originColor,
          builder: openBuilder,
          scrimColor: cardTheme.resolveTransformScrim(theme.colorScheme),
          openColor: widget.color == null
              ? cardTheme.resolveTransformOpenColor(theme.colorScheme)
              : null,
          endRadius: cardTheme.transformEndRadius,
          contentFadeStart: cardTheme.transformContentFadeStart,
          contentVisibleAt: cardTheme.transformContentVisibleAt,
          motion: cardTheme.transformSpring,
        );
    _closeTransform = ([Object? result]) => handle.close(result as T?);
    setState(() => _transformOpen = true);
    widget.controller?.refresh();
    final T? result = await handle.future;
    _closeTransform = null;
    if (mounted) {
      setState(() => _transformOpen = false);
      widget.controller?.refresh();
    }
    return result;
  }

  @override
  void closeTransform() => _closeTransform?.call();

  void _handleTap() {
    widget.onPressed?.call();
    if (widget.openBuilder != null) {
      openTransform<Object?>();
      return;
    }
    _openAlternativeActions();
  }

  void _handleLongPress() {
    widget.onLongPress?.call();
    _openAlternativeActions();
  }

  void _openAlternativeActions() {
    final void Function(Rect cardRect)? actions = widget.alternativeActions;
    if (actions == null) {
      return;
    }
    final RenderObject? renderObject = context.findRenderObject();
    if (renderObject is! RenderBox || !renderObject.hasSize) {
      return;
    }
    final Rect rect =
        renderObject.localToGlobal(Offset.zero) & renderObject.size;
    actions(rect);
  }

  @override
  Widget build(BuildContext context) {
    return MorphComponentTheme(builder: _buildCard);
  }

  Widget _buildCard(BuildContext context) {
    final theme = MorphTheme.of(context);
    final MorphCardTheme cardTheme = theme.cardTheme;
    final MorphCardGroupScope? group = MorphCardGroupScope.maybeOf(context);
    final BorderRadius radius = widget.borderRadius ?? cardTheme.borderRadius;
    final dragged = widget.dragged || (group?.dragged ?? false);
    final idle = MorphInteractionState(dragged: dragged);

    final body = _actionable
        ? _tappable(theme, cardTheme, group, radius, idle, dragged)
        : _buildSurface(context, theme, cardTheme, group, radius, idle);
    Widget framed = _swipeWrap(body, radius);
    if (_actionable && widget.showFocusRing) {
      framed = ValueListenableBuilder<bool>(
        valueListenable: _keyboardFocused,
        builder: (BuildContext context, bool focused, Widget? child) {
          return MorphFocusRing(
            focused: focused,
            radius: radius,
            color: cardTheme.resolveFocusColor(theme.colorScheme),
            width: cardTheme.focusThickness,
            gap: cardTheme.focusGap,
            child: child!,
          );
        },
        child: framed,
      );
    }
    return Focus(
      canRequestFocus: false,
      skipTraversal: true,
      onKeyEvent: _onCardKey,
      child: FocusTraversalGroup(
        policy: OrderedTraversalPolicy(),
        child: framed,
      ),
    );
  }

  bool _editableFocused() {
    final BuildContext? focusContext =
        FocusManager.instance.primaryFocus?.context;
    if (focusContext == null) {
      return false;
    }
    return focusContext.widget is EditableText ||
        focusContext.findAncestorWidgetOfExactType<EditableText>() != null;
  }

  Widget _tappable(
    MorphThemeData theme,
    MorphCardTheme cardTheme,
    MorphCardGroupScope? group,
    BorderRadius radius,
    MorphInteractionState idle,
    bool dragged,
  ) {
    Widget tappable = MorphTappable(
      enabled: widget.enabled,
      onTap: _handleTap,
      onLongPress:
          widget.onLongPress != null || widget.alternativeActions != null
          ? _handleLongPress
          : null,
      focusNode: _focusNode,
      focusable: widget.focusable,
      skipTraversal: widget.skipTraversal,
      trackHover: widget.trackHover,
      focusOverlay: widget.showFocusFill,
      mouseCursor: widget.mouseCursor,
      semanticLabel: _spokenLabel(),
      semanticButton: !widget.semanticLink,
      onStateChanged: (MorphInteractionState state) {
        widget.onStateChanged?.call(state);
        if (_keyboardFocused.value != state.focused) {
          _keyboardFocused.value = state.focused;
        }
      },
      materialInk: true,
      haptic: widget.haptic,
      builder: (BuildContext context, MorphInteractionState state) {
        final MorphInteractionState resolved = widget.enabled
            ? state.copyWith(dragged: state.dragged || dragged)
            : idle;
        return _buildSurface(
          context,
          theme,
          cardTheme,
          group,
          radius,
          resolved,
        );
      },
    );
    if (widget.semanticLink) {
      tappable = Semantics(link: true, child: tappable);
    }
    return FocusTraversalOrder(
      order: const NumericFocusOrder(1),
      child: tappable,
    );
  }

  String? _spokenLabel() {
    if (widget.semanticLabel != null) {
      return widget.semanticLabel;
    }
    final parts = <String>[
      if (widget.headline != null && widget.headline!.isNotEmpty)
        widget.headline!,
      if (widget.supportingText != null && widget.supportingText!.isNotEmpty)
        widget.supportingText!,
    ];
    if (parts.isEmpty) {
      return null;
    }
    return parts.join(', ');
  }

  Widget _buildSurface(
    BuildContext context,
    MorphThemeData theme,
    MorphCardTheme cardTheme,
    MorphCardGroupScope? group,
    BorderRadius radius,
    MorphInteractionState state,
  ) {
    final scheme = theme.colorScheme;
    final double resolvedElevation =
        widget.elevation ?? _elevation(cardTheme, group, state);
    final outlined = widget.variant == MorphCardVariant.outlined;
    final BoxBorder? resolvedBorder = widget.border != null
        ? Border.all(color: widget.border!.color, width: widget.border!.width)
        : (outlined
              ? Border.all(
                  color: cardTheme.outlineColorFor(
                    scheme,
                    enabled: widget.enabled,
                    focused: state.focused,
                  ),
                  width: cardTheme.outlineWidth,
                )
              : null);
    final Color fill =
        widget.color ??
        cardTheme.containerColorFor(
          scheme,
          widget.variant,
          enabled: widget.enabled,
        );
    final bool fadeContent =
        !widget.enabled && widget.variant != MorphCardVariant.outlined;

    Widget content = _buildContent(context, theme, cardTheme, group);
    if (!_hasStructuredContent) {
      content = Padding(
        padding: widget.padding ?? cardTheme.contentPadding,
        child: content,
      );
    }
    content = _limitHeight(content, cardTheme);
    content = _withInteractionFill(scheme, cardTheme, state, content);

    Widget surface = AnimatedContainer(
      key: widget.surfaceKey,
      width: widget.width,
      duration: MorphMotion.durationOf(
        context,
        widget.animationDuration ?? MorphMotion.short4,
      ),
      curve: widget.animationCurve ?? MorphMotion.standard,
      clipBehavior: widget.clipBehavior,
      decoration: BoxDecoration(
        color: fill,
        borderRadius: radius,
        border: resolvedBorder,
        boxShadow: MorphElevation.shadows(
          resolvedElevation,
          shadowColor: cardTheme.resolveShadowColor(scheme),
        ),
      ),
      child: _actionable
          ? MorphStateLayerOverlay(
              state: state,
              color: cardTheme.resolveStateLayerColor(scheme),
              shape: RoundedRectangleBorder(borderRadius: radius),
              child: SizedBox(
                width: widget.width ?? double.infinity,
                child: content,
              ),
            )
          : content,
    );

    if (fadeContent) {
      surface = Opacity(opacity: cardTheme.disabledOpacity, child: surface);
    }
    return surface;
  }

  Widget _withInteractionFill(
    MorphColorScheme scheme,
    MorphCardTheme cardTheme,
    MorphInteractionState state,
    Widget content,
  ) {
    final double alpha = state.dragged
        ? MorphStateOpacity.dragged
        : widget.showFocusFill && state.focused
        ? MorphStateOpacity.focus
        : 0;
    if (alpha == 0) {
      return content;
    }
    return Stack(
      children: <Widget>[
        Positioned.fill(
          child: IgnorePointer(
            child: ColoredBox(
              color: cardTheme
                  .resolveStateLayerColor(scheme)
                  .withValues(alpha: alpha),
            ),
          ),
        ),
        content,
      ],
    );
  }

  double _elevation(
    MorphCardTheme cardTheme,
    MorphCardGroupScope? group,
    MorphInteractionState state,
  ) {
    final double themed = cardTheme.elevation(
      widget.variant,
      hovered: state.hovered,
      focused: state.focused,
      pressed: state.pressed,
      dragged: state.dragged,
      enabled: widget.enabled,
    );
    final double? shared = group?.restingElevation;
    final bool resting =
        widget.enabled &&
        !state.dragged &&
        !state.pressed &&
        !state.focused &&
        !state.hovered;
    if (shared != null && resting) {
      return shared;
    }
    return themed;
  }

  Widget _limitHeight(Widget content, MorphCardTheme cardTheme) {
    if (widget.expanded) {
      return content;
    }
    final double? cap = widget.maxHeight ?? cardTheme.maxHeight;
    if (cap == null) {
      return content;
    }
    if (_scrollsInternally()) {
      return ConstrainedBox(
        constraints: BoxConstraints(maxHeight: cap),
        child: SingleChildScrollView(child: content),
      );
    }
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: cap),
      child: ClipRect(
        child: OverflowBox(
          alignment: Alignment.topCenter,
          minHeight: 0,
          maxHeight: double.infinity,
          child: content,
        ),
      ),
    );
  }
}
