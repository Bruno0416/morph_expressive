import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/widgets.dart';
import 'package:motor/motor.dart';

import '../../../foundations/interaction/morph_motion_controller.dart';
import '../../../foundations/foundations.dart';
import '../enums/morph_dialog_enums.dart';
import '../styles/morph_dialog_theme.dart';
import '../utils/morph_dialog_spring.dart';

/// Spring-driven enter / exit for dialog routes.
///
/// Follows the route [animation] direction. Basic dialogs fade and scale up;
/// full-screen dialogs slide up from the bottom edge.
class MorphDialogTransition extends StatefulWidget {
  /// MorphDialogTransition.
  const MorphDialogTransition({
    required this.animation,
    required this.variant,
    required this.dialogTheme,
    required this.child,
    super.key,
  });

  /// Theme captured from the opening context.
  final MorphDialogTheme dialogTheme;

  /// Route animation; only its direction is used.
  final Animation<double> animation;

  /// Which motion to play.
  final MorphDialogVariant variant;

  /// Dialog surface.
  final Widget child;

  /// Route duration that covers the slowest spring for [variant].
  static Duration durationFor(
    MorphDialogTheme theme,
    MorphDialogVariant variant,
  ) {
    if (variant == MorphDialogVariant.fullScreen) {
      return morphDialogSpringSettle(theme.fullScreen.enterSpring);
    }
    final Duration spatial = morphDialogSpringSettle(theme.enterSpring);
    final Duration fade = morphDialogSpringSettle(theme.fadeSpring);
    return spatial > fade ? spatial : fade;
  }

  @override
  State<MorphDialogTransition> createState() => _MorphDialogTransitionState();
}

class _MorphDialogTransitionState extends State<MorphDialogTransition>
    with TickerProviderStateMixin {
  SingleMotionController? _spatial;
  SingleMotionController? _fade;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_spatial != null) {
      return;
    }
    final MorphDialogTheme dialogTheme = widget.dialogTheme;
    final MorphSpring spatial = widget.variant == MorphDialogVariant.fullScreen
        ? dialogTheme.fullScreen.enterSpring
        : dialogTheme.enterSpring;
    _spatial = MorphMotionController(
      motion: morphDialogSpringMotion(spatial),
      vsync: this,
    );
    _fade = MorphMotionController(
      motion: morphDialogSpringMotion(dialogTheme.fadeSpring),
      vsync: this,
    );
    widget.animation.addStatusListener(_onStatus);
    _onStatus(widget.animation.status);
  }

  @override
  void didUpdateWidget(covariant MorphDialogTransition oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.animation != widget.animation) {
      oldWidget.animation.removeStatusListener(_onStatus);
      widget.animation.addStatusListener(_onStatus);
    }
  }

  void _onStatus(AnimationStatus status) {
    final double target = status.isForwardOrCompleted ? 1 : 0;
    final bool reduce = MorphMotion.reduceMotionOf(context);
    if (status == AnimationStatus.completed && _spatial!.value == 0 || reduce) {
      _spatial!.value = target;
      _fade!.value = target;
      return;
    }
    _spatial!.animateTo(target);
    _fade!.animateTo(target);
  }

  @override
  void dispose() {
    widget.animation.removeStatusListener(_onStatus);
    _spatial?.dispose();
    _fade?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final MorphDialogTheme dialogTheme = widget.dialogTheme;
    return AnimatedBuilder(
      animation: Listenable.merge(<Listenable>[_spatial!, _fade!]),
      child: widget.child,
      builder: (BuildContext context, Widget? child) {
        final double p = morphDialogSnap(_spatial!.value);
        if (widget.variant == MorphDialogVariant.fullScreen) {
          return FractionalTranslation(
            translation: Offset(0, math.max(0, 1 - p)),
            child: child,
          );
        }
        return Opacity(
          opacity: morphDialogSnap(_fade!.value).clamp(0, 1),
          child: Transform.scale(
            scale: lerpDouble(dialogTheme.entranceScale, 1, p),
            child: child,
          ),
        );
      },
    );
  }
}
