import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show clampDouble, kIsWeb;
import 'package:flutter/gestures.dart'
    show DragUpdateDetails, PointerDeviceKind;
import 'package:flutter/physics.dart';
import 'package:material_new_shapes/material_new_shapes.dart'
    as shapes
    show RoundedPolygon;
import 'package:material_ui/material_ui.dart'
    show
        Align,
        Alignment,
        AlwaysStoppedAnimation,
        Animatable,
        AnimatedBuilder,
        Animation,
        AnimationController,
        AxisDirection,
        BoxConstraints,
        BuildContext,
        Clip,
        Color,
        ColorTween,
        CurveTween,
        DecoratedBox,
        DragUpdateDetails,
        EdgeInsets,
        IgnorePointer,
        Interval,
        Key,
        Listenable,
        MaterialLocalizations,
        NotificationListener,
        Offset,
        Opacity,
        OverscrollIndicatorNotification,
        OverscrollNotification,
        Padding,
        Positioned,
        RefreshProgressIndicator,
        RepaintBoundary,
        ScrollBehavior,
        ScrollConfiguration,
        ScrollEndNotification,
        ScrollMetrics,
        ScrollNotification,
        ScrollNotificationPredicate,
        ScrollPhysics,
        ScrollStartNotification,
        ScrollUpdateNotification,
        ShapeDecoration,
        SizedBox,
        Stack,
        State,
        StatefulWidget,
        TargetPlatform,
        TickerProviderStateMixin,
        Transform,
        Tween,
        ValueChanged,
        ValueKey,
        Widget,
        defaultScrollNotificationPredicate;
import 'package:motor/motor.dart';

import '../../foundations/foundations.dart';
import '../loading_indicator/morph_loading_indicator.dart';
import 'controllers/morph_refresh_indicator_controller.dart';
import 'enums/morph_refresh_status.dart';
import 'styles/morph_refresh_indicator_theme.dart';

export 'controllers/morph_refresh_indicator_controller.dart';
export 'enums/morph_refresh_status.dart';
export 'styles/morph_refresh_indicator_theme.dart';

part 'components/morph_refresh_indicator_scroll.dart';
part 'components/morph_refresh_indicator_build.dart';
part 'components/morph_refresh_indicator_web.dart';

enum _IndicatorType { material, expressive, contained, adaptive, noSpinner }

/// Web spinner cache phase (morph path must not rebuild every animation tick).
enum _WebSpinnerPhase { none, drag, refresh }

/// A Material Design 3 expressive refresh indicator.
///
/// Expressive and contained refresh kinds use a contained
/// [MorphLoadingIndicator]; elevation (when set) is applied on the refresh host
/// shell so it works on all platforms (including Flutter web).
///
/// Call [MorphRefreshIndicatorState.show] via a [GlobalKey], or pass a
/// [MorphRefreshIndicatorController] to trigger refresh programmatically.
///
/// Refresh runs only when the indicator is fully revealed (scale/opacity at 1)
/// and the pointer is released. Releasing earlier cancels with a scale/fade out.
///
/// On Flutter web, mouse drag is enabled for the child scrollable, and drag
/// updates avoid empty [State.setState] calls once the pull is at its visual
/// cap (those rebuilds freeze CanvasKit). Other platforms are unchanged.
class MorphRefreshIndicator extends StatefulWidget {
  /// const.
  const MorphRefreshIndicator({
    super.key,
    required this.child,
    this.displacement = MorphRefreshIndicatorTheme.kDefaultDisplacement,
    this.indicatorPadding = MorphRefreshIndicatorTheme.kDefaultIndicatorPadding,
    this.contentDragOffset,
    this.edgeOffset = MorphRefreshIndicatorTheme.kDefaultEdgeOffset,
    required this.onRefresh,
    this.controller,
    this.color,
    this.backgroundColor,
    this.notificationPredicate = defaultScrollNotificationPredicate,
    this.semanticsLabel,
    this.semanticsValue,
    this.triggerMode = MorphRefreshTriggerMode.onEdge,
    this.elevation = MorphRefreshIndicatorTheme.kDefaultElevation,
    this.releaseBubbleSpring,
    this.releaseBubbleFromScale,
    this.polygons,
    this.indicatorConstraints,
    this.onStatusChange,
  }) : _indicatorType = _IndicatorType.expressive,
       strokeWidth = 0.0,
       assert(elevation >= 0.0, 'assertion failed'),
       assert(indicatorPadding >= 0.0, 'assertion failed'),
       assert(
         releaseBubbleFromScale == null || releaseBubbleFromScale > 0.0,
         'assertion failed',
       ),
       assert(!(polygons != null) || polygons.length > 1, 'assertion failed');

  /// const.
  const MorphRefreshIndicator.contained({
    super.key,
    required this.child,
    this.displacement = MorphRefreshIndicatorTheme.kDefaultDisplacement,
    this.indicatorPadding = MorphRefreshIndicatorTheme.kDefaultIndicatorPadding,
    this.contentDragOffset,
    this.edgeOffset = MorphRefreshIndicatorTheme.kDefaultEdgeOffset,
    required this.onRefresh,
    this.controller,
    this.color,
    this.backgroundColor,
    this.notificationPredicate = defaultScrollNotificationPredicate,
    this.semanticsLabel,
    this.semanticsValue,
    this.triggerMode = MorphRefreshTriggerMode.onEdge,
    this.elevation = MorphRefreshIndicatorTheme.kDefaultElevation,
    this.releaseBubbleSpring,
    this.releaseBubbleFromScale,
    this.polygons,
    this.indicatorConstraints,
    this.onStatusChange,
  }) : _indicatorType = _IndicatorType.contained,
       strokeWidth = 0.0,
       assert(elevation >= 0.0, 'assertion failed'),
       assert(indicatorPadding >= 0.0, 'assertion failed'),
       assert(
         releaseBubbleFromScale == null || releaseBubbleFromScale > 0.0,
         'assertion failed',
       ),
       assert(!(polygons != null) || polygons.length > 1, 'assertion failed');

  /// const.
  const MorphRefreshIndicator.material({
    super.key,
    required this.child,
    this.displacement = MorphRefreshIndicatorTheme.kDefaultDisplacement,
    this.indicatorPadding = MorphRefreshIndicatorTheme.kDefaultIndicatorPadding,
    this.contentDragOffset,
    this.edgeOffset = MorphRefreshIndicatorTheme.kDefaultEdgeOffset,
    required this.onRefresh,
    this.controller,
    this.color,
    this.backgroundColor,
    this.notificationPredicate = defaultScrollNotificationPredicate,
    this.semanticsLabel,
    this.semanticsValue,
    this.strokeWidth = RefreshProgressIndicator.defaultStrokeWidth,
    this.triggerMode = MorphRefreshTriggerMode.onEdge,
    this.elevation = MorphRefreshIndicatorTheme.kDefaultElevation,
    this.releaseBubbleSpring,
    this.releaseBubbleFromScale,
    this.onStatusChange,
  }) : _indicatorType = _IndicatorType.material,
       polygons = null,
       indicatorConstraints = null,
       assert(elevation >= 0.0, 'assertion failed'),
       assert(indicatorPadding >= 0.0, 'assertion failed'),
       assert(
         releaseBubbleFromScale == null || releaseBubbleFromScale > 0.0,
         'assertion failed',
       );

  /// const.
  const MorphRefreshIndicator.adaptive({
    super.key,
    required this.child,
    this.displacement = MorphRefreshIndicatorTheme.kDefaultDisplacement,
    this.indicatorPadding = MorphRefreshIndicatorTheme.kDefaultIndicatorPadding,
    this.contentDragOffset,
    this.edgeOffset = MorphRefreshIndicatorTheme.kDefaultEdgeOffset,
    required this.onRefresh,
    this.controller,
    this.color,
    this.backgroundColor,
    this.notificationPredicate = defaultScrollNotificationPredicate,
    this.semanticsLabel,
    this.semanticsValue,
    this.strokeWidth = RefreshProgressIndicator.defaultStrokeWidth,
    this.triggerMode = MorphRefreshTriggerMode.onEdge,
    this.elevation = MorphRefreshIndicatorTheme.kDefaultElevation,
    this.releaseBubbleSpring,
    this.releaseBubbleFromScale,
    this.onStatusChange,
  }) : _indicatorType = _IndicatorType.adaptive,
       polygons = null,
       indicatorConstraints = null,
       assert(elevation >= 0.0, 'assertion failed'),
       assert(indicatorPadding >= 0.0, 'assertion failed'),
       assert(
         releaseBubbleFromScale == null || releaseBubbleFromScale > 0.0,
         'assertion failed',
       );

  /// const.
  const MorphRefreshIndicator.noSpinner({
    super.key,
    required this.child,
    required this.onRefresh,
    this.controller,
    this.onStatusChange,
    this.indicatorPadding = MorphRefreshIndicatorTheme.kDefaultIndicatorPadding,
    this.contentDragOffset,
    this.notificationPredicate = defaultScrollNotificationPredicate,
    this.semanticsLabel,
    this.semanticsValue,
    this.triggerMode = MorphRefreshTriggerMode.onEdge,
    this.elevation = MorphRefreshIndicatorTheme.kDefaultElevation,
  }) : _indicatorType = _IndicatorType.noSpinner,
       displacement = 0.0,
       edgeOffset = 0.0,
       color = null,
       backgroundColor = null,
       strokeWidth = 0.0,
       polygons = null,
       indicatorConstraints = null,
       releaseBubbleSpring = null,
       releaseBubbleFromScale = null,
       assert(elevation >= 0.0, 'assertion failed'),
       assert(indicatorPadding >= 0.0, 'assertion failed');

  /// final.
  final Widget child;

  /// Resting offset of the indicator below the scroll edge (top of spinner).
  ///
  /// Defaults to [MorphRefreshIndicatorTheme.kDefaultDisplacement] (8), matching
  /// the top [indicatorPadding] so the spinner sits in the list pad.
  final double displacement;

  /// Vertical gap above and below the spinner inside the list pad (default 8).
  ///
  /// Max list pad defaults to `indicatorHeight + 2 * indicatorPadding`.
  /// Scale/fade/downward reveal starts after the pad reaches
  /// `2 * indicatorPadding`.
  final double indicatorPadding;

  /// Max list top padding while dragging. Defaults to indicator height +
  /// `2 * indicatorPadding`. Does not move the indicator's resting edge.
  final double? contentDragOffset;

  /// final.
  final double edgeOffset;

  /// final.
  final MorphRefreshCallback onRefresh;

  /// Optional controller to call [MorphRefreshIndicatorController.show].
  final MorphRefreshIndicatorController? controller;

  /// final.
  final ValueChanged<MorphRefreshStatus?>? onStatusChange;

  /// final.
  final Color? color;

  /// final.
  final Color? backgroundColor;

  /// final.
  final ScrollNotificationPredicate notificationPredicate;

  /// final.
  final String? semanticsLabel;

  /// final.
  final String? semanticsValue;

  /// final.
  final double strokeWidth;

  /// final.
  final MorphRefreshTriggerMode triggerMode;

  /// final.
  final double elevation;

  /// Override for the release scale-bubble spring. Defaults to theme
  /// [MorphRefreshIndicatorTheme.releaseBubbleSpring].
  final MorphSpring? releaseBubbleSpring;

  /// Override for the bubble start scale. Defaults to theme
  /// [MorphRefreshIndicatorTheme.releaseBubbleFromScale].
  final double? releaseBubbleFromScale;

  final _IndicatorType _indicatorType;

  /// final.
  final List<shapes.RoundedPolygon>? polygons;

  /// final.
  final BoxConstraints? indicatorConstraints;

  @override
  MorphRefreshIndicatorState createState() => MorphRefreshIndicatorState();
}

/// class.
class MorphRefreshIndicatorState extends State<MorphRefreshIndicator>
    with TickerProviderStateMixin<MorphRefreshIndicator> {
  late AnimationController _positionController;
  late AnimationController _scaleController;
  late AnimationController _contentPadController;

  /// Release scale bubble at the locked rest inset (motor / MorphMotion spring).
  late SingleMotionController _bubbleController;
  late Animation<double> _scaleFactor;
  late Animation<double> _value;
  late Animation<Color?> _valueColor;

  MorphRefreshStatus? _status;
  late Future<void> _pendingRefreshFuture;
  bool? _isIndicatorAtTop;
  double? _dragOffset;

  /// Cached morph spinner on web (drag = frozen morph; refresh = auto-spin).
  Widget? _webSpinnerCache;
  _WebSpinnerPhase _webSpinnerPhase = _WebSpinnerPhase.none;
  _IndicatorType? _webSpinnerType;

  /// Dedupes pointer drag deltas when ScrollUpdate + Overscroll fire together.
  bool _pointerDeltaLocked = false;

  /// Indicator top inset locked when loading starts.
  double? _restingInset;
  late Color _effectiveValueColor;
  late Color _effectiveContainerColor;

  /// Stable show callback for [MorphRefreshIndicatorController] attach/detach.
  /// Fresh method tear-offs are never [identical], so dispose would fail to
  /// clear and leave a disposed State's callback attached.
  late final Future<void> Function({bool atTop}) _controllerShow;

  static final Animatable<double> _threeQuarterTween = Tween<double>(
    begin: 0,
    end: 0.75,
  );
  static final Animatable<double> _oneToZeroTween = Tween<double>(
    begin: 1,
    end: 0,
  );

  double _indicatorHeight(BuildContext context) {
    final double? maxHeight = widget.indicatorConstraints?.maxHeight;
    if (maxHeight != null && maxHeight.isFinite) {
      return maxHeight;
    }
    return MorphTheme.of(context).loadingIndicatorTheme.containerHeight;
  }

  /// Max list pad: enough for the spinner plus padding above and below.
  double _resolvedContentDragOffset(BuildContext context) {
    if (widget.contentDragOffset != null) {
      return widget.contentDragOffset!;
    }
    return _indicatorHeight(context) + 2 * widget.indicatorPadding;
  }

  /// Pull (px) at which scale/fade/downward motion begins.
  double get _revealDelayPx => 2 * widget.indicatorPadding;

  MorphRefreshIndicatorTheme get _refreshTheme =>
      MorphTheme.of(context).refreshIndicatorTheme;

  MorphSpring get _resolvedReleaseBubbleSpring =>
      widget.releaseBubbleSpring ?? _refreshTheme.releaseBubbleSpring;

  double get _resolvedReleaseBubbleFromScale =>
      widget.releaseBubbleFromScale ?? _refreshTheme.releaseBubbleFromScale;

  /// Motor spring from theme / widget override (user-tuned defaults: 350 / 0.1).
  SpringMotion get _releaseBubbleMotion {
    final MorphSpring spring = _resolvedReleaseBubbleSpring;
    return MorphMotion.springMotion(spring);
  }

  @override
  void initState() {
    super.initState();
    _positionController = AnimationController.unbounded(vsync: this);
    _value = _positionController.drive(_threeQuarterTween);
    _scaleController = AnimationController.unbounded(vsync: this);
    _scaleFactor = _scaleController.drive(_oneToZeroTween);
    _contentPadController = AnimationController.unbounded(vsync: this);
    // Theme may not be available yet; _playReleaseBubble applies resolved motion.
    _bubbleController = SingleMotionController(
      motion: MorphMotion.springMotion(
        MorphRefreshIndicatorTheme.kDefaultReleaseBubbleSpring,
      ),
      vsync: this,
      initialValue: 1,
    );
    _pendingRefreshFuture = Future<void>.value();
    Future<void> controllerShow({bool atTop = true}) => show(atTop: atTop);
    _controllerShow = controllerShow;
    widget.controller?.attach(_controllerShow);
  }

  @override
  void didChangeDependencies() {
    _setupColorTween();
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(covariant MorphRefreshIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.detach(_controllerShow);
      widget.controller?.attach(_controllerShow);
    }
    if (oldWidget.color != widget.color) {
      _setupColorTween();
    }
  }

  @override
  void dispose() {
    widget.controller?.detach(_controllerShow);
    _positionController.dispose();
    _scaleController.dispose();
    _contentPadController.dispose();
    _bubbleController.dispose();
    super.dispose();
  }

  /// Shows the refresh indicator and runs [MorphRefreshIndicator.onRefresh].
  Future<void> show({bool atTop = true}) {
    if (!mounted) {
      return Future<void>.value();
    }
    if (_status != MorphRefreshStatus.refresh &&
        _status != MorphRefreshStatus.snap) {
      if (_status == null) {
        _start(atTop ? AxisDirection.down : AxisDirection.up);
      }
      _show();
    }
    return _pendingRefreshFuture;
  }

  /// Web and native desktop: mouse/trackpad pull needs 1:1 pointer deltas and
  /// leading underscroll clamp (same pad/reveal math as mobile).
  bool get _usePointerPullTracking {
    if (kIsWeb) {
      return true;
    }
    return switch (MorphTheme.platformOf(context)) {
      TargetPlatform.macOS ||
      TargetPlatform.windows ||
      TargetPlatform.linux => true,
      TargetPlatform.iOS ||
      TargetPlatform.android ||
      TargetPlatform.fuchsia => false,
    };
  }

  @override
  Widget build(BuildContext context) {
    return MorphComponentTheme(
      builder: (BuildContext context) {
        final Widget tree = kIsWeb
            ? _buildWebTree(context)
            : _buildHostTree(context);
        if (_usePointerPullTracking) {
          return _wrapPointerPullScrollBehavior(tree);
        }
        return tree;
      },
    );
  }

  Widget _buildHostTree(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge(<Listenable>[
        _positionController,
        _scaleController,
        _contentPadController,
        _bubbleController,
      ]),
      builder: (BuildContext context, Widget? _) {
        final double pad = _currentPad(context);
        return Stack(
          clipBehavior: Clip.none,
          children: <Widget>[
            NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification n) =>
                  _handleScrollNotification(n),
              child: NotificationListener<OverscrollIndicatorNotification>(
                onNotification: (OverscrollIndicatorNotification n) =>
                    _handleIndicatorNotification(n),
                child: Padding(
                  padding: EdgeInsets.only(
                    top: (_isIndicatorAtTop ?? false) ? pad : 0,
                    bottom: _isIndicatorAtTop == false ? pad : 0,
                  ),
                  child: widget.child,
                ),
              ),
            ),
            if (_status != null) _buildPositionedIndicator(context),
          ],
        );
      },
    );
  }
}
