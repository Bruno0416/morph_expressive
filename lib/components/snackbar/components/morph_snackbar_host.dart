import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../../foundations/foundations.dart';
import '../controllers/morph_snackbar_controller.dart';

/// Provides [dismiss] to snackbar descendants (action / close).
class MorphSnackbarDismissScope extends InheritedWidget {
  /// Creates a dismiss scope.
  const MorphSnackbarDismissScope({
    required this.dismiss,
    required super.child,
    super.key,
  });

  /// Requests the host to dismiss the snackbar.
  final VoidCallback dismiss;

  /// The nearest dismiss callback, if any.
  static VoidCallback? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<MorphSnackbarDismissScope>()
        ?.dismiss;
  }

  @override
  bool updateShouldNotify(MorphSnackbarDismissScope oldWidget) {
    return dismiss != oldWidget.dismiss;
  }
}

class _DismissSnackbarIntent extends Intent {
  const _DismissSnackbarIntent();
}

/// Animates a snackbar in from the bottom, holds it, then removes [entry].
class MorphSnackbarHost extends StatefulWidget {
  /// MorphSnackbarHost.
  const MorphSnackbarHost({
    required this.child,
    required this.entry,
    this.duration,
    this.swipeDismissible = false,
    this.controller,
    super.key,
  });

  /// Snackbar content.
  final Widget child;

  /// Auto-dismiss duration. Null means persistent until dismissed.
  final Duration? duration;

  /// Whether a horizontal swipe can dismiss the snackbar.
  final bool swipeDismissible;

  /// Overlay entry to remove on dismiss.
  final OverlayEntry entry;

  /// Optional controller that owns this presentation.
  final MorphSnackbarController? controller;

  @override
  State<MorphSnackbarHost> createState() => MorphSnackbarHostState();
}

/// State for [MorphSnackbarHost].
class MorphSnackbarHostState extends State<MorphSnackbarHost>
    with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _offset;
  late final AnimationController _horizontal;
  double _barWidth = 0;
  Timer? _timer;
  bool _dismissing = false;

  @override
  void initState() {
    super.initState();
    _horizontal = AnimationController.unbounded(vsync: this);
    widget.controller?.attachHost(this);
    _controller = AnimationController(
      vsync: this,
      duration: MorphMotion.medium2,
      reverseDuration: MorphMotion.short4,
    );
    _offset = Tween<Offset>(begin: const Offset(0, 1.5), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _controller, curve: MorphMotion.emphasized),
        );
    _controller.forward();
    final Duration? duration = widget.duration;
    if (duration != null) {
      _timer = Timer(duration, dismiss);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MorphMotion.reduceMotionOf(context)) {
      _controller.stop(canceled: false);
      _controller.value = _dismissing ? 0 : 1;
      _horizontal.stop(canceled: false);
      _horizontal.value = 0;
    }
  }

  @override
  void didUpdateWidget(MorphSnackbarHost oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.detachHost(this);
      widget.controller?.attachHost(this);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    widget.controller?.detachHost(this);
    _controller.dispose();
    _horizontal.dispose();
    super.dispose();
  }

  /// Plays the exit animation and removes the overlay entry.
  Future<void> dismiss() async {
    if (_dismissing) {
      return;
    }
    _dismissing = true;
    _timer?.cancel();
    if (!mounted) {
      _removeEntry();
      return;
    }
    if (!MorphMotion.reduceMotionOf(context)) await _controller.reverse();
    _removeEntry();
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (_dismissing) return;
    _horizontal.stop();
    _horizontal.value += details.primaryDelta ?? 0;
  }

  void _onDragEnd(DragEndDetails details) {
    if (_dismissing) return;
    final double velocity = details.primaryVelocity ?? 0;
    final double distance = _horizontal.value;
    final bool fling =
        velocity.abs() > 650 &&
        (distance == 0 || distance.sign == velocity.sign);
    if (distance.abs() >= _barWidth * 0.28 || fling) {
      _dismissFromSwipe(distance == 0 ? velocity : distance);
      return;
    }
    _horizontal.animateTo(
      0,
      duration: MorphMotion.durationOf(context, MorphMotion.short4),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _dismissFromSwipe(double direction) async {
    if (_dismissing) return;
    _dismissing = true;
    _timer?.cancel();
    MorphHaptics.selectionFor(context);
    if (MorphMotion.reduceMotionOf(context)) {
      _removeEntry();
      return;
    }
    await _horizontal.animateTo(
      direction.sign * (_barWidth + 80),
      duration: MorphMotion.durationOf(context, MorphMotion.short4),
      curve: Curves.easeOutCubic,
    );
    _removeEntry();
  }

  void _removeEntry() {
    widget.controller?.notifyClosed(widget.entry);
    try {
      widget.entry.remove();
    } catch (_) {
      // Already removed (e.g. controller.dispose cleared the overlay).
    }
  }

  @override
  Widget build(BuildContext context) {
    final snackTheme = MorphTheme.of(context).snackBarTheme;
    return Positioned(
      left: snackTheme.overlayHorizontalInset + MorphSafeArea.leftOf(context),
      right: snackTheme.overlayHorizontalInset + MorphSafeArea.rightOf(context),
      bottom:
          snackTheme.overlayBottomInset +
          MorphSafeArea.overlayBottomOf(context),
      child: Align(
        alignment: snackTheme.overlayAlignment,
        child: SlideTransition(
          position: _offset,
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              _barWidth = constraints.maxWidth.isFinite
                  ? constraints.maxWidth
                        .clamp(0, snackTheme.maxWidth)
                        .toDouble()
                  : snackTheme.maxWidth;
              return AnimatedBuilder(
                animation: _horizontal,
                builder: (BuildContext context, Widget? child) {
                  final double fade =
                      (1 - _horizontal.value.abs() / (_barWidth + 80)).clamp(
                        0.0,
                        1.0,
                      );
                  return Transform.translate(
                    offset: Offset(_horizontal.value, 0),
                    child: Opacity(opacity: fade, child: child),
                  );
                },
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onHorizontalDragUpdate: widget.swipeDismissible
                      ? _onDragUpdate
                      : null,
                  onHorizontalDragEnd: widget.swipeDismissible
                      ? _onDragEnd
                      : null,
                  child: FocusScope(
                    child: Shortcuts(
                      shortcuts: const <ShortcutActivator, Intent>{
                        SingleActivator(LogicalKeyboardKey.escape):
                            _DismissSnackbarIntent(),
                      },
                      child: Actions(
                        actions: <Type, Action<Intent>>{
                          _DismissSnackbarIntent:
                              CallbackAction<_DismissSnackbarIntent>(
                                onInvoke: (_) {
                                  dismiss();
                                  return null;
                                },
                              ),
                        },
                        child: MorphSnackbarDismissScope(
                          dismiss: dismiss,
                          child: widget.child,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
