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
    if (!enabled) {
      return child;
    }

    return TapRegion(
      onTapOutside: _onTapOutside,
      child: Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: _onPointerDown,
        onPointerUp: _onPointerUp,
        onPointerCancel: _onPointerCancel,
        child: child,
      ),
    );
  }

  void _onTapOutside(PointerDownEvent _) {
    MorphFocusInteraction.instance.notePointerInteraction();
    if (effectiveFocusNode.hasPrimaryFocus) {
      effectiveFocusNode.unfocus();
    }
  }

  void _onPointerDown(PointerDownEvent _) {
    MorphFocusInteraction.instance.notePointerInteraction();
    _setPointerDown(true);
  }

  void _onPointerUp(PointerUpEvent _) {
    // Do not request focus here — Material may focus for a11y, but
    // visual focus chrome is ring-only (keyboard). Sticky post-tap
    // focus fill is suppressed in button overlay resolution.
    _setPointerDown(false);
  }

  void _onPointerCancel(PointerCancelEvent _) {
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
      _initFocusNode();
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
    isPressedNotifier.value = statesController.value.contains(
      WidgetState.pressed,
    );
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
