import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/services.dart' show LogicalKeyboardKey;

/// Opt-in geometric overscroll for scrollables containing frosted surfaces.
///
/// The stock Material 3 stretching indicator may render its scrollable through
/// an image filter, preventing frosted cards inside it from sampling the actual
/// background behind the scrollable. This behavior uses a transform instead.
///
/// Apply with Flutter's own [ScrollConfiguration] around an existing [ListView],
/// [GridView], [SingleChildScrollView] or [CustomScrollView]. No custom scroll
/// view is needed:
///
/// ```dart
/// ScrollConfiguration(
///   behavior: const MorphScrollBehavior(),
///   child: ListView(children: cards),
/// )
/// ```
///
/// [delegate] preserves existing custom scrollbar, input-device and
/// keyboard policies. To inherit the current settings, pass
/// `ScrollConfiguration.of(context)` as the delegate. By default this behavior
/// intentionally uses clamping physics (including on iOS) so an overscroll
/// notification is generated for the geometric indicator. This only affects
/// the subtree in which this behavior is installed.
///
/// Explicit `physics` on a ScrollView takes precedence and can
/// prevent overscroll notifications, particularly with bouncing physics.
@immutable
class MorphScrollBehavior extends ScrollBehavior {
  const MorphScrollBehavior({
    this.delegate,
    this.maxStretch = 1.0,
    this.stretchGain = 1.0,
    this.releaseDuration = const Duration(milliseconds: 330),
    this.physics,
  }) : assert(maxStretch > 0 && maxStretch <= 1),
       assert(stretchGain > 0);

  /// Optional existing scroll behavior whose non-overscroll policies are kept.
  final ScrollBehavior? delegate;

  /// Limit applied to the computed stretch strength (default 1.0).
  ///
  /// With [stretchGain] at 1, Flutter's native drag equation produces at
  /// most 0.032 for a viewport-sized pull. This larger safety ceiling also
  /// allows the native spring response to an impact without truncation.
  final double maxStretch;

  /// Multiplier for Flutter's stretch response. 1.0 matches the native model.
  ///
  /// Values below 1 make both drag and impact responses more subtle.
  final double stretchGain;

  /// Reference recovery time for scaling the spring's natural frequency.
  ///
  /// The 330 ms default maps to Flutter's spring constants, not a fixed
  /// animation duration. A custom value changes the spring's relative speed;
  /// actual settling time depends on current stretch and velocity.
  final Duration releaseDuration;

  /// Optional scoped physics override; default is clamping + always scrollable.
  ///
  /// A bouncing physics configuration may not emit the OverscrollNotification
  /// required to drive geometric stretch. In particular, avoid using an
  /// explicit BouncingScrollPhysics on the affected scrollables.
  final ScrollPhysics? physics;

  ScrollBehavior get _base => delegate ?? const MaterialScrollBehavior();

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    // Duration getters are not const-evaluable in constructor assertions.
    assert(releaseDuration > Duration.zero);
    return _MorphStretchIndicator(
      axisDirection: details.direction,
      maxStretch: maxStretch,
      stretchGain: stretchGain,
      releaseDuration: releaseDuration,
      child: child,
    );
  }

  @override
  Widget buildScrollbar(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) => _base.buildScrollbar(context, child, details);

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) =>
      physics ??
      const ClampingScrollPhysics(parent: AlwaysScrollableScrollPhysics());

  @override
  TargetPlatform getPlatform(BuildContext context) =>
      _base.getPlatform(context);

  @override
  Set<PointerDeviceKind> get dragDevices => _base.dragDevices;

  @override
  Set<LogicalKeyboardKey> get pointerAxisModifiers =>
      _base.pointerAxisModifiers;

  @override
  MultitouchDragStrategy getMultitouchDragStrategy(BuildContext context) =>
      _base.getMultitouchDragStrategy(context);

  @override
  ScrollViewKeyboardDismissBehavior getKeyboardDismissBehavior(
    BuildContext context,
  ) => _base.getKeyboardDismissBehavior(context);

  @override
  GestureVelocityTrackerBuilder velocityTrackerBuilder(BuildContext context) =>
      _base.velocityTrackerBuilder(context);

  @override
  bool shouldNotify(covariant ScrollBehavior oldDelegate) =>
      oldDelegate is! MorphScrollBehavior ||
      delegate != oldDelegate.delegate ||
      maxStretch != oldDelegate.maxStretch ||
      stretchGain != oldDelegate.stretchGain ||
      releaseDuration != oldDelegate.releaseDuration ||
      physics != oldDelegate.physics;
}

// The accept flag is protected in Flutter; read it from a subclass rather
// than accessing a protected member from unrelated client code.
class _MorphIndicatorNotification extends OverscrollIndicatorNotification {
  _MorphIndicatorNotification({required super.leading});

  bool get allowed => accepted;
}

/// Internal indicator, kept separate from the public ScrollBehavior API.
///
/// The pull response and spring constants follow Flutter's
/// StretchingOverscrollIndicator / _StretchController (BSD-3-Clause,
/// Copyright 2014 The Flutter Authors). The shader-based StretchEffect is
/// deliberately not used: it can isolate descendant BackdropFilters.
class _MorphStretchIndicator extends StatefulWidget {
  const _MorphStretchIndicator({
    required this.axisDirection,
    required this.maxStretch,
    required this.stretchGain,
    required this.releaseDuration,
    required this.child,
  });

  final AxisDirection axisDirection;
  final double maxStretch;
  final double stretchGain;
  final Duration releaseDuration;
  final Widget child;

  @override
  State<_MorphStretchIndicator> createState() => _MorphStretchIndicatorState();
}

class _MorphStretchIndicatorState extends State<_MorphStretchIndicator>
    with TickerProviderStateMixin {
  static const double _intensity = 0.016;
  static const double _exponentialScalar = math.e / 0.33;
  static const double _naturalFrequency = 24.657;
  static const double _dampingRatio = 0.98;
  static const double _timeCorrection = 0.8;

  final ValueNotifier<double> _amount = ValueNotifier<double>(0);
  AnimationController? _animation;
  double _interruptedAmount = 0;
  double _totalOverscroll = 0;
  bool _accepted = true;
  ScrollNotification? _lastNotification;

  void _cancelAnimation() {
    final previous = _animation;
    _animation = null;
    previous?.dispose();
  }

  double _clamp(double strength) =>
      strength.clamp(-widget.maxStretch, widget.maxStretch).toDouble();

  SpringSimulation _spring(double velocity) {
    // At the default reference time the parameters are identical to Flutter's
    // Android EdgeEffect spring. Custom durations scale its natural frequency.
    final double speed = 330000 / widget.releaseDuration.inMicroseconds;
    final double frequency = _naturalFrequency * _timeCorrection * speed;
    final spring = SpringDescription.withDampingRatio(
      mass: 1,
      stiffness: frequency * frequency,
      ratio: _dampingRatio,
    );
    return SpringSimulation(
      spring,
      _amount.value,
      0,
      velocity * _timeCorrection * speed,
    );
  }

  void _animate(double velocity) {
    _cancelAnimation();
    final controller = AnimationController.unbounded(vsync: this);
    _animation = controller;
    controller.addListener(() {
      if (identical(_animation, controller)) {
        _amount.value = _clamp(controller.value);
      }
    });
    controller.animateWith(_spring(velocity)).whenCompleteOrCancel(() {
      if (!mounted || !identical(_animation, controller)) return;
      _animation = null;
      _amount.value = 0;
      _interruptedAmount = 0;
      controller.dispose();
    });
  }

  void _pull(double normalized) {
    if (_animation != null) {
      _interruptedAmount = _animation!.value;
      _cancelAnimation();
    }
    final double distance = normalized.abs();
    // Flutter's native pull equation, before the (opt-in) gain and cap.
    final double strength =
        _intensity * (distance + 1 - math.exp(-distance * _exponentialScalar));
    _amount.value = _clamp(
      normalized.sign * strength * widget.stretchGain + _interruptedAmount,
    );
  }

  void _absorbImpact(double velocity) {
    if (velocity == 0) return;
    final double scaled =
        (velocity / 3000).clamp(-1.25, 1.25).toDouble() * widget.stretchGain;
    _animate(scaled);
  }

  void _scrollEnd(double velocity) {
    if (velocity == 0 && _amount.value == 0) return;
    if (_animation != null) return;
    final double scaled =
        (-velocity / 6000).clamp(-0.5, 0.5).toDouble() * widget.stretchGain;
    _animate(scaled);
  }

  bool _onScroll(ScrollNotification notification) {
    if (notification.depth != 0 ||
        notification.metrics.axis !=
            axisDirectionToAxis(widget.axisDirection)) {
      return false;
    }
    if (notification is ScrollStartNotification) {
      _accepted = true;
      _totalOverscroll = 0;
    } else if (notification is OverscrollNotification) {
      if (_lastNotification is! OverscrollNotification) {
        final confirmation = _MorphIndicatorNotification(
          leading: notification.overscroll < 0,
        );
        confirmation.dispatch(context);
        _accepted = confirmation.allowed;
      }
      if (_accepted) {
        _totalOverscroll += notification.overscroll;
        if (notification.velocity != 0) {
          _absorbImpact(notification.velocity);
        } else if (notification.dragDetails != null) {
          final double viewport = notification.metrics.viewportDimension;
          if (viewport.isFinite && viewport > 0) {
            _pull((_totalOverscroll / viewport).clamp(-1.0, 1.0));
          }
        }
      }
    } else if (notification is ScrollEndNotification) {
      double velocity = switch (notification.metrics.axis) {
        Axis.vertical =>
          notification.dragDetails?.velocity.pixelsPerSecond.dy ?? 0.0,
        Axis.horizontal =>
          notification.dragDetails?.velocity.pixelsPerSecond.dx ?? 0.0,
      };
      if (notification.metrics.axisDirection == AxisDirection.up ||
          notification.metrics.axisDirection == AxisDirection.left) {
        velocity = -velocity;
      }
      _totalOverscroll = 0;
      if (_accepted) _scrollEnd(velocity);
    } else if (notification is ScrollUpdateNotification) {
      _totalOverscroll = 0;
      _scrollEnd(0);
    }
    _lastNotification = notification;
    return false;
  }

  @override
  void didUpdateWidget(covariant _MorphStretchIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.maxStretch != widget.maxStretch) {
      _amount.value = _clamp(_amount.value);
    }
    if (oldWidget.releaseDuration != widget.releaseDuration ||
        oldWidget.stretchGain != widget.stretchGain) {
      if (_animation != null) _animate(0);
    }
  }

  @override
  void dispose() {
    _cancelAnimation();
    _amount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: _onScroll,
      child: ListenableBuilder(
        listenable: _amount,
        child: widget.child,
        builder: (context, child) {
          // Flutter passes the negative controller strength to StretchEffect.
          double strength = -_amount.value;
          if (widget.axisDirection == AxisDirection.up ||
              widget.axisDirection == AxisDirection.left) {
            strength = -strength;
          }
          if (strength.abs() <= 1e-10) return child!;

          final bool vertical =
              axisDirectionToAxis(widget.axisDirection) == Axis.vertical;
          final Alignment alignment;
          if (vertical) {
            alignment = strength > 0
                ? Alignment.topCenter
                : Alignment.bottomCenter;
          } else {
            final bool rtl = Directionality.of(context) == TextDirection.rtl;
            alignment = (strength > 0) == !rtl
                ? Alignment.centerLeft
                : Alignment.centerRight;
          }
          final double scale = 1 + strength.abs();
          // Matches Flutter's matrix fallback without the shader's
          // ImageFiltered layer, so the scroll's BackdropFilters keep working.
          return Transform.scale(
            alignment: alignment,
            scaleX: vertical ? 1 : scale,
            scaleY: vertical ? scale : 1,
            child: child,
          );
        },
      ),
    );
  }
}
