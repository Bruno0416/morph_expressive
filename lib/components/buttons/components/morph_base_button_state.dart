import 'dart:async' show scheduleMicrotask;

import 'package:flutter/scheduler.dart' show SchedulerBinding, SchedulerPhase;
import 'package:morph_expressive/foundations/foundations.dart';
import 'package:morph_expressive/morph_components.dart' show MorphButton;
import 'package:material_ui/material_ui.dart'
    show
        BuildContext,
        FocusHighlightMode,
        FocusManager,
        FocusNode,
        HitTestBehavior,
        Listener,
        PointerCancelEvent,
        PointerDownEvent,
        PointerUpEvent,
        State,
        StatefulWidget,
        TapRegion,
        TextOverflow,
        TextStyle,
        ValueListenableBuilder,
        ValueNotifier,
        Widget,
        WidgetState,
        WidgetStatesController,
        WidgetsBinding,
        protected;
import 'package:motor/motor.dart';
import 'package:flutter/gestures.dart'
    show
        PointerMoveEvent,
        PointerEvent,
        OneSequenceGestureRecognizer,
        GestureDisposition,
        kPrimaryButton,
        kTouchSlop;
import 'package:flutter/rendering.dart' show RenderBox;
import 'package:flutter/widgets.dart'
    show Offset, RawGestureDetector, GestureRecognizerFactoryWithHandlers;

import '../enums/morph_button_enums.dart';
import '../styles/morph_button_motion.dart';

/// Shared lifecycle infrastructure for [MorphButton].
mixin MorphBaseButtonState<T extends StatefulWidget> on State<T> {
  /// buttonSize.
  MorphButtonSize get buttonSize;

  /// externalStatesController.
  WidgetStatesController? get externalStatesController;

  /// externalFocusNode.
  FocusNode? get externalFocusNode;

  /// effectiveMotion.
  MorphButtonMotion? get effectiveMotion;

  /// statesController.

  late WidgetStatesController statesController;
  bool _ownsController = false;
  int? _activePointer;
  Offset? _pointerOrigin;
  bool _trackingEnabled = false;
  bool _stateSyncPending = false;

  /// isPressedNotifier.

  late final ValueNotifier<bool> isPressedNotifier;

  /// isPointerDownNotifier.
  late final ValueNotifier<bool> isPointerDownNotifier;

  /// isHoveredNotifier.
  late final ValueNotifier<bool> isHoveredNotifier;

  /// isFocusedNotifier.
  late final ValueNotifier<bool> isFocusedNotifier;

  /// wrapWithPointerPressTracking.

  @protected
  Widget wrapWithPointerPressTracking({
    required bool enabled,
    required Widget child,
  }) {
    _trackingEnabled = enabled;
    return RawGestureDetector(
      gestures: {
        _PressArenaObserver:
            GestureRecognizerFactoryWithHandlers<_PressArenaObserver>(
              _PressArenaObserver.new,
              (observer) => observer.onResolved = (pointer) {
                // Arena callbacks may precede the winning Material recognizer's
                // accept callback. Observe its final state, never activate here.
                scheduleMicrotask(() {
                  if (mounted &&
                      pointer == _activePointer &&
                      !statesController.value.contains(WidgetState.pressed)) {
                    cancelPointerPress();
                  }
                });
              },
            ),
      },
      child: TapRegion(
        onTapOutside: _onTapOutside,
        child: Listener(
          behavior: HitTestBehavior.translucent,
          onPointerDown: _onPointerDown,
          onPointerUp: _onPointerUp,
          onPointerCancel: _onPointerCancel,
          onPointerMove: _onPointerMove,
          child: child,
        ),
      ),
    );
  }

  void _onTapOutside(PointerDownEvent _) {
    if (!_trackingEnabled) return;
    MorphFocusInteraction.instance.notePointerInteraction();
    if (effectiveFocusNode.hasPrimaryFocus) {
      effectiveFocusNode.unfocus();
    }
  }

  void _onPointerDown(PointerDownEvent event) {
    if (!_trackingEnabled ||
        _activePointer != null ||
        event.buttons != kPrimaryButton) {
      return;
    }
    _activePointer = event.pointer;
    _pointerOrigin = event.position;
    MorphFocusInteraction.instance.notePointerInteraction();
    _setPointerDown(true);
  }

  void _onPointerUp(PointerUpEvent event) {
    if (event.pointer != _activePointer) return;
    // Do not request focus here — Material may focus for a11y, but
    // visual focus chrome is ring-only (keyboard). Sticky post-tap
    // focus fill is suppressed in button overlay resolution.
    cancelPointerPress();
  }

  void _onPointerCancel(PointerCancelEvent event) {
    if (event.pointer == _activePointer) cancelPointerPress();
  }

  void _onPointerMove(PointerMoveEvent event) {
    if (event.pointer != _activePointer) return;
    final box = context.findRenderObject();
    final outside =
        box is RenderBox &&
        !(Offset.zero & box.size).contains(box.globalToLocal(event.position));
    if (outside || (event.position - _pointerOrigin!).distance > kTouchSlop) {
      cancelPointerPress();
    }
  }

  /// Cancels visual tracking only; Material remains the activation authority.
  @protected
  void cancelPointerPress() {
    _activePointer = null;
    _pointerOrigin = null;
    _setPointerDown(false);
  }

  void _setPointerDown(bool down) {
    if (isPointerDownNotifier.value == down) {
      return;
    }
    isPointerDownNotifier.value = down;
  }

  /// buildAnimatedContent.

  @protected
  Widget buildAnimatedContent({
    required Widget Function(
      BuildContext context, {
      required bool isPressed,
      required bool isHovered,
      required bool isFocused,
    })
    builder,
  }) {
    return ValueListenableBuilder<bool>(
      valueListenable: isPressedNotifier,
      builder: (context, isPressed, _) {
        return ValueListenableBuilder<bool>(
          valueListenable: isPointerDownNotifier,
          builder: (context, isPointerDown, _) {
            return ValueListenableBuilder<bool>(
              valueListenable: isHoveredNotifier,
              builder: (context, isHovered, _) {
                return ValueListenableBuilder<bool>(
                  valueListenable: isFocusedNotifier,
                  builder: (context, isFocused, _) {
                    final effectivePressed = isPressed || isPointerDown;
                    return builder(
                      context,
                      isPressed: effectivePressed,
                      isHovered: isHovered,
                      isFocused: isFocused,
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  /// isFocused.

  bool get isFocused => isFocusedNotifier.value;

  FocusNode? _internalFocusNode;

  /// labelStyle.
  late TextStyle labelStyle;

  /// springMotion.
  late SpringMotion springMotion;

  /// effectiveFocusNode.

  FocusNode get effectiveFocusNode => externalFocusNode ?? _internalFocusNode!;

  /// initBaseButtonState.

  void initBaseButtonState() {
    _initController();
    isPressedNotifier = ValueNotifier(
      statesController.value.contains(WidgetState.pressed),
    );
    isPointerDownNotifier = ValueNotifier(false);
    isHoveredNotifier = ValueNotifier(
      statesController.value.contains(WidgetState.hovered),
    );
    isFocusedNotifier = ValueNotifier(false);
    _initFocusNode();
  }

  void _initController() {
    _ownsController = externalStatesController == null;
    statesController = externalStatesController ?? WidgetStatesController();
    statesController.addListener(onStateChanged);
  }

  void _initFocusNode() {
    if (externalFocusNode == null) {
      _internalFocusNode = FocusNode(debugLabel: '$T');
    }
    effectiveFocusNode.addListener(_onFocusChanged);
    FocusManager.instance.addHighlightModeListener(_onHighlightModeChanged);
    MorphFocusInteraction.instance.addListener(_onFocusInteractionChanged);
    _syncFocusHighlight();
  }

  void _onFocusInteractionChanged() {
    _syncFocusHighlight();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  /// updateLabelStyle.

  void updateLabelStyle(BuildContext context) {
    final type = MorphTheme.of(context).typeScale;
    final base = switch (buttonSize.name) {
      'xs' => type.labelSmall,
      'sm' => type.labelMedium,
      'md' => type.labelLarge,
      'lg' => type.titleMedium,
      'xl' => type.titleLarge,
      _ => type.labelLarge,
    };
    labelStyle = base.copyWith(overflow: TextOverflow.ellipsis);
  }

  /// updateSpringMotion.

  void updateSpringMotion() {
    springMotion = (effectiveMotion ?? MorphButtonMotion.shapeMorph).toMotion();
  }

  /// handleStatesControllerUpdate.

  void handleStatesControllerUpdate(
    WidgetStatesController? oldExternal,
    WidgetStatesController? newExternal,
  ) {
    if (oldExternal != newExternal) {
      statesController.removeListener(onStateChanged);
      if (_ownsController) {
        statesController.dispose();
      }
      _initController();
      onStateChanged();
    }
  }

  /// handleFocusNodeUpdate.

  void handleFocusNodeUpdate(FocusNode? oldExternal, FocusNode? newExternal) {
    if (oldExternal != newExternal) {
      final old = oldExternal ?? _internalFocusNode;
      old?.removeListener(_onFocusChanged);
      if (oldExternal == null) {
        _internalFocusNode?.dispose();
        _internalFocusNode = null;
      }
      if (externalFocusNode == null) {
        _internalFocusNode = FocusNode(debugLabel: '$T');
      }
      effectiveFocusNode.addListener(_onFocusChanged);
      _syncFocusHighlight();
    }
  }

  void _onFocusChanged() {
    _syncFocusHighlight();
  }

  void _onHighlightModeChanged(FocusHighlightMode mode) {
    _syncFocusHighlight();
  }

  void _syncFocusHighlight() {
    if (!mounted) {
      return;
    }
    final show = MorphFocusRing.shouldShow(effectiveFocusNode, context);
    if (isFocusedNotifier.value != show) {
      isFocusedNotifier.value = show;
      if (show && mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) {
            return;
          }
          MorphFocusInteraction.ensureVisibleIfKeyboard(context);
        });
      }
    }
  }

  /// onStateChanged.

  void onStateChanged() {
    if (!mounted) {
      return;
    }
    // Material may update disabled/pressed while its subtree is building.
    // Never notify an ancestor ValueListenableBuilder from that descendant.
    if (SchedulerBinding.instance.schedulerPhase ==
        SchedulerPhase.persistentCallbacks) {
      if (!_stateSyncPending) {
        _stateSyncPending = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _stateSyncPending = false;
          if (mounted) onStateChanged();
        });
      }
      return;
    }
    final wasPressed = isPressedNotifier.value;
    isPressedNotifier.value = statesController.value.contains(
      WidgetState.pressed,
    );
    if ((wasPressed && !isPressedNotifier.value) ||
        statesController.value.contains(WidgetState.disabled)) {
      cancelPointerPress();
    }
    isHoveredNotifier.value = statesController.value.contains(
      WidgetState.hovered,
    );
  }

  /// disposeBaseButtonState.

  void disposeBaseButtonState() {
    statesController.removeListener(onStateChanged);
    if (_ownsController) {
      statesController.dispose();
    }
    effectiveFocusNode.removeListener(_onFocusChanged);
    FocusManager.instance.removeHighlightModeListener(_onHighlightModeChanged);
    MorphFocusInteraction.instance.removeListener(_onFocusInteractionChanged);
    _internalFocusNode?.dispose();
    isPressedNotifier.dispose();
    isPointerDownNotifier.dispose();
    isHoveredNotifier.dispose();
    isFocusedNotifier.dispose();
  }
}

/// A non-activating arena participant. Inner Material recognizers win first;
/// rejection also observes wins by scroll/drag/eager recognizers before tap-down.
class _PressArenaObserver extends OneSequenceGestureRecognizer {
  void Function(int pointer)? onResolved;
  bool _withdrawing = false;
  bool _disposed = false;
  @override
  void addAllowedPointer(PointerDownEvent event) {
    if (event.buttons != kPrimaryButton) return;
    startTrackingPointer(event.pointer, event.transform);
    // Do not hold Material's tap pending (including connected group motion).
    // Immediate competing winners are observed; later cancellation is supplied
    // by Material state and pointer-slop tracking.
    scheduleMicrotask(() {
      if (_disposed) return;
      _withdrawing = true;
      resolve(GestureDisposition.rejected);
      _withdrawing = false;
    });
  }

  @override
  void handleEvent(PointerEvent event) {
    if (event is PointerUpEvent || event is PointerCancelEvent) {
      resolve(GestureDisposition.rejected);
      stopTrackingPointer(event.pointer);
    }
  }

  @override
  void acceptGesture(int pointer) {
    onResolved?.call(pointer);
    stopTrackingPointer(pointer);
  }

  @override
  void rejectGesture(int pointer) {
    if (!_withdrawing) onResolved?.call(pointer);
    stopTrackingPointer(pointer);
  }

  @override
  void didStopTrackingLastPointer(int pointer) {}
  @override
  String get debugDescription => 'Morph visual press observer';
  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
