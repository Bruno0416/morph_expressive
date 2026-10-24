import 'dart:ui' show lerpDouble;

import 'package:flutter/widgets.dart';
import 'package:motor/motor.dart';

import '../../foundations/interaction/morph_motion_controller.dart';
import '../../foundations/foundations.dart';
import '../buttons/utils/morph_button_gradient_layer.dart';
import '../tooltips/morph_tooltips.dart';
import 'components/morph_fab_container_transform.dart';
import 'controllers/morph_fab_controller.dart';
import 'enums/morph_fab.dart';
import 'styles/morph_fab_decoration.dart';
import 'styles/morph_fab_theme.dart';

export 'components/morph_fab_container_transform.dart'
    show MorphFabContainerTransformScope;
export 'controllers/morph_fab_controller.dart';
export 'enums/morph_fab.dart';
export 'styles/morph_fab_decoration.dart';
export 'styles/morph_fab_theme.dart';

/// A Material 3 Expressive floating action button.
///
/// Renders at one of four [MorphFabSize]s with any of the seven [MorphFabColor]s.
/// Default size is [MorphFabSize.medium] (80dp). Elevation rests at level 3 and
/// lifts to level 4 on hover; press uses expressive spatial scale (380 / 0.55).
///
/// Optional [controller] drives scroll show/hide, appear morph, and container
/// transform. Pass [openBuilder] (or call [MorphFabController.open]) to morph
/// into another surface on tap.
class MorphFab extends StatefulWidget {
  /// MorphFab.
  const MorphFab({
    required this.icon,
    this.onPressed,
    this.size = MorphFabSize.medium,
    this.color = MorphFabColor.primary,
    this.cornerRadius,
    this.decoration,
    this.elevation,
    this.hoverElevation,
    this.tooltip,
    this.focusNode,
    this.autofocus = false,
    this.controller,
    this.appear = false,
    this.scaleAlignment = AlignmentDirectional.bottomEnd,
    this.openBuilder,
    this.openColor,
    this.transformScrimColor,
    super.key,
  }) : assert(elevation == null || elevation >= 0.0, 'assertion failed'),
       assert(
         hoverElevation == null || hoverElevation >= 0.0,
         'assertion failed',
       );

  /// icon.

  final Widget icon;

  /// onPressed.
  final VoidCallback? onPressed;

  /// size.
  final MorphFabSize size;

  /// color.
  final MorphFabColor color;

  /// When set, overrides the themed corner radius (e.g. for open/close morph).
  final double? cornerRadius;

  /// Optional decoration for solid and gradient surfaces.
  final MorphFabDecoration? decoration;

  /// Resting surface elevation.
  ///
  /// Defaults to [MorphElevation.level3].
  final double? elevation;

  /// Surface elevation while hovered.
  ///
  /// Defaults to [MorphElevation.level4].
  final double? hoverElevation;

  /// tooltip.
  final String? tooltip;

  /// focusNode.
  final FocusNode? focusNode;

  /// autofocus.
  final bool autofocus;

  /// Optional controller for visibility, appear, and container transform.
  final MorphFabController? controller;

  /// When true, plays an appear morph on first layout.
  final bool appear;

  /// Anchor for appear and scroll-dismiss scale (not center).
  ///
  /// Defaults to [AlignmentDirectional.bottomEnd] (typical end-float FAB).
  final AlignmentGeometry scaleAlignment;

  /// When set, tap opens a container transform to this destination.
  final WidgetBuilder? openBuilder;

  /// Destination fill color for the container transform.
  final Color? openColor;

  /// Scrim color behind the open container transform.
  final Color? transformScrimColor;

  @override
  State<MorphFab> createState() => _MorphFabState();
}

class _MorphFabState extends State<MorphFab>
    with TickerProviderStateMixin
    implements MorphFabControllerClient {
  final GlobalKey _originKey = GlobalKey();
  FocusNode? _ownedFocusNode;

  late SingleMotionController _appearCtrl;
  late SingleMotionController _visibilityCtrl;

  MorphFabContainerTransformHandle<dynamic>? _transformHandle;

  bool get _interactive =>
      widget.onPressed != null || widget.openBuilder != null;

  FocusNode get _effectiveFocusNode =>
      widget.focusNode ?? (_ownedFocusNode ??= FocusNode());

  SpringMotion _springMotion(MorphSpring spring) =>
      MorphMotion.springMotion(spring);

  @override
  void initState() {
    super.initState();
    final bool startAppeared = !widget.appear;
    _appearCtrl = MorphMotionController(
      motion: _springMotion(MorphMotion.expressiveSpatialDefault),
      vsync: this,
      initialValue: startAppeared ? 1 : 0,
    )..addListener(_onAppearTick);
    _visibilityCtrl = MorphMotionController(
      motion: _springMotion(MorphMotion.expressiveSpatialDefault),
      vsync: this,
      initialValue: widget.controller?.isVisible == false ? 0 : 1,
    )..addListener(_onVisibilityTick);

    widget.controller?.attachClient(this);
    if (widget.appear) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          playAppearInternal();
        }
      });
    } else {
      widget.controller?.updateAppearProgress(1);
    }
    widget.controller?.updateVisibilityProgress(_visibilityCtrl.value);
  }

  @override
  void didUpdateWidget(covariant MorphFab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.detachClient(this);
      widget.controller?.attachClient(this);
    }
    if (widget.appear && !oldWidget.appear && _appearCtrl.value < 1) {
      playAppearInternal();
    }
  }

  @override
  void dispose() {
    widget.controller?.detachClient(this);
    _appearCtrl
      ..removeListener(_onAppearTick)
      ..dispose();
    _visibilityCtrl
      ..removeListener(_onVisibilityTick)
      ..dispose();
    _transformHandle?.close();
    _ownedFocusNode?.dispose();
    super.dispose();
  }

  void _onTapOutside(PointerDownEvent event) {
    MorphFocusInteraction.instance.notePointerInteraction();
    if (_effectiveFocusNode.hasFocus) {
      _effectiveFocusNode.unfocus();
    }
  }

  void _onAppearTick() {
    widget.controller?.updateAppearProgress(_appearCtrl.value);
    if (mounted) {
      setState(() {});
    }
  }

  void _onVisibilityTick() {
    widget.controller?.updateVisibilityProgress(_visibilityCtrl.value);
    if (mounted) {
      setState(() {});
    }
  }

  void playAppearInternal() {
    _appearCtrl
      ..motion = _springMotion(MorphMotion.expressiveSpatialDefault)
      ..value = 0
      ..animateTo(1);
  }

  @override
  bool get isTransformOpen => _transformHandle != null;

  @override
  void onVisibilityRequested({required bool visible}) {
    _visibilityCtrl
      ..motion = _springMotion(MorphMotion.expressiveSpatialDefault)
      ..animateTo(visible ? 1 : 0);
  }

  @override
  void onAppearRequested() => playAppearInternal();

  @override
  Future<T?> openTransform<T extends Object?>({WidgetBuilder? builder}) async {
    final WidgetBuilder? openBuilder = builder ?? widget.openBuilder;
    if (openBuilder == null || _transformHandle != null) {
      return null;
    }
    final BuildContext? originContext = _originKey.currentContext;
    if (originContext == null || !originContext.mounted) {
      return null;
    }
    final RenderObject? renderObject = originContext.findRenderObject();
    if (renderObject is! RenderBox || !renderObject.hasSize) {
      return null;
    }
    final theme = MorphTheme.of(context);
    final metrics = theme.fabTheme.resolve(
      size: widget.size,
      color: widget.color,
      scheme: theme.colorScheme,
      enabled: _interactive,
    );
    final Rect origin =
        renderObject.localToGlobal(Offset.zero) & renderObject.size;
    final double radius = widget.cornerRadius ?? metrics.radius;

    final handle = MorphFabContainerTransform.show<T>(
      context: context,
      origin: origin,
      originRadius: radius,
      originColor: metrics.background,
      openColor: widget.openColor,
      scrimColor: widget.transformScrimColor,
      builder: openBuilder,
    );
    _transformHandle = handle;
    setState(() {});

    final T? result = await handle.future;
    _transformHandle = null;
    if (mounted) {
      setState(() {});
    }
    return result;
  }

  @override
  void closeTransform() {
    _transformHandle?.close();
  }

  void _handleTap() {
    widget.onPressed?.call();
    if (widget.openBuilder != null) {
      openTransform();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = MorphTheme.of(context);
    final fabTheme = theme.fabTheme;
    final metrics = fabTheme.resolve(
      size: widget.size,
      color: widget.color,
      scheme: theme.colorScheme,
      enabled: _interactive,
    );

    final double appearT = _appearCtrl.value.clamp(0.0, 1.0);
    final double visibilityT = _visibilityCtrl.value.clamp(0.0, 1.0);
    final double combinedScale =
        lerpDouble(fabTheme.appearStartScale, 1, appearT)! * visibilityT;
    final double appearRadius = lerpDouble(
      metrics.container / 2,
      widget.cornerRadius ?? metrics.radius,
      appearT,
    )!;
    final BorderRadius borderRadius = MorphShapes.resolve(appearRadius);
    final ShapeBorder border = RoundedRectangleBorder(
      borderRadius: borderRadius,
    );
    final Duration radiusDuration = widget.cornerRadius != null && appearT >= 1
        ? Duration.zero
        : MorphMotion.short4;

    final hideForTransform = _transformHandle != null;
    final opacity = (visibilityT * appearT).clamp(0.0, 1.0);

    Widget fab = MorphComponentTheme(
      builder: (context) => MorphTappable(
        onTap: _interactive ? _handleTap : null,
        enabled: _interactive,
        focusNode: _effectiveFocusNode,
        autofocus: widget.autofocus,
        semanticLabel: widget.tooltip,
        pressedScale: fabTheme.pressedScale,
        materialInk: !morphUsesGradientOverlay(
          widget.decoration?.overlayGradient,
        ),
        builder: (context, state) => _buildSurface(
          theme: theme,
          fabTheme: fabTheme,
          metrics: metrics,
          borderRadius: borderRadius,
          border: border,
          radiusDuration: radiusDuration,
          state: state,
        ),
      ),
    );

    fab = KeyedSubtree(key: _originKey, child: fab);

    fab = Opacity(
      opacity: hideForTransform ? 0 : opacity,
      child: Transform.scale(
        scale: hideForTransform ? 0 : combinedScale,
        alignment: widget.scaleAlignment,
        child: fab,
      ),
    );

    final String? tooltip = widget.tooltip;
    if (tooltip != null) {
      fab = MorphTooltip(message: tooltip, child: fab);
    }

    if (visibilityT <= 0.001 && _transformHandle == null) {
      fab = IgnorePointer(child: fab);
    }

    return TapRegion(onTapOutside: _onTapOutside, child: fab);
  }

  Widget _buildSurface({
    required MorphThemeData theme,
    required MorphFabTheme fabTheme,
    required MorphFabMetrics metrics,
    required BorderRadius borderRadius,
    required ShapeBorder border,
    required Duration radiusDuration,
    required MorphInteractionState state,
  }) {
    final states = morphStatesForInteraction(state, enabled: _interactive);
    final Gradient? fill =
        widget.decoration?.backgroundGradient?.resolve(states) ??
        fabTheme.gradient;
    final Color? solidBg =
        widget.decoration?.backgroundColor?.resolve(states) ??
        (fill == null ? metrics.background : null);
    final Color fg =
        widget.decoration?.foregroundGradient?.resolve(states) != null
        ? morphGradientForegroundSourceColor
        : (widget.decoration?.foregroundColor?.resolve(states) ??
              metrics.foreground);
    final Gradient? outline = widget.decoration?.outlineGradient?.resolve(
      states,
    );
    final BorderSide? side = outline != null
        ? null
        : widget.decoration?.side?.resolve(states);
    final resolvedElevation = !_interactive
        ? MorphElevation.level0
        : state.hovered
        ? widget.hoverElevation ?? MorphElevation.level4
        : widget.elevation ?? MorphElevation.level3;

    return _composeFabSurface(
      theme: theme,
      fabTheme: fabTheme,
      metrics: metrics,
      borderRadius: borderRadius,
      border: border,
      radiusDuration: radiusDuration,
      state: state,
      states: states,
      fill: fill,
      solidBg: solidBg,
      fg: fg,
      outline: outline,
      side: side,
      resolvedElevation: resolvedElevation,
    );
  }

  Widget _composeFabSurface({
    required MorphThemeData theme,
    required MorphFabTheme fabTheme,
    required MorphFabMetrics metrics,
    required BorderRadius borderRadius,
    required ShapeBorder border,
    required Duration radiusDuration,
    required MorphInteractionState state,
    required Set<WidgetState> states,
    required Gradient? fill,
    required Color? solidBg,
    required Color fg,
    required Gradient? outline,
    required BorderSide? side,
    required double resolvedElevation,
  }) {
    Widget content = _decorateContent(
      state: state,
      states: states,
      fg: fg,
      borderRadius: borderRadius,
      border: border,
      child: SizedBox(
        width: metrics.container,
        height: metrics.container,
        child: Align(
          child: IconTheme.merge(
            data: IconThemeData(color: fg, size: metrics.iconSize),
            child: widget.icon,
          ),
        ),
      ),
    );

    Widget surface = AnimatedContainer(
      duration: MorphMotion.durationOf(context, radiusDuration),
      curve: MorphMotion.standard,
      width: metrics.container,
      height: metrics.container,
      decoration: BoxDecoration(
        color: fill == null ? solidBg : null,
        gradient: fill,
        borderRadius: borderRadius,
        border: side == null ? null : Border.fromBorderSide(side),
        boxShadow: MorphElevation.shadows(
          resolvedElevation,
          shadowColor: theme.colorScheme.shadow,
        ),
      ),
      child: content,
    );
    if (outline != null) {
      surface = morphGradientOutlineLayer(
        clipRadius: borderRadius,
        gradient: outline,
        width: morphOutlineWidth(widget.decoration?.side?.resolve(states)),
        child: surface,
      );
    }
    return MorphFocusRing(
      focused: state.focused,
      radius: borderRadius,
      width: fabTheme.focusRingWidth,
      gap: fabTheme.focusRingGap,
      color: fabTheme.resolveFocusRingColor(theme.colorScheme),
      child: surface,
    );
  }

  Widget _decorateContent({
    required MorphInteractionState state,
    required Set<WidgetState> states,
    required Color fg,
    required BorderRadius borderRadius,
    required ShapeBorder border,
    required Widget child,
  }) {
    var content = child;
    final Gradient? fgGradient = widget.decoration?.foregroundGradient?.resolve(
      states,
    );
    if (fgGradient != null) {
      content = morphGradientForegroundLayer(
        clipRadius: borderRadius,
        gradient: fgGradient,
        child: content,
      );
    }
    if (morphUsesGradientOverlay(widget.decoration?.overlayGradient)) {
      return morphResolveGradientOverlay(
        clipRadius: borderRadius,
        states: states,
        overlayGradient: widget.decoration?.overlayGradient,
        child: content,
      );
    }
    return MorphStateLayerOverlay(
      state: state,
      color: fg,
      shape: border,
      alignment: Alignment.center,
      child: content,
    );
  }
}
