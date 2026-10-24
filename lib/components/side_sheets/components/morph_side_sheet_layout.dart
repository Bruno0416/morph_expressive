part of '../morph_side_sheets.dart';

/// Places a side sheet next to (standard) or over (modal) [body].
///
/// When a standard sheet opens, [body] shrinks to make room for it and
/// keeps a 24 margin on its trailing edge. In [MorphSideSheetLayoutMode
/// .adaptive] the sheet is modal on compact windows (below 600) and
/// standard on medium and wider ones; crossing the breakpoint while open
/// morphs between the two with a spatial spring.
class MorphSideSheetLayout extends StatefulWidget {
  /// MorphSideSheetLayout.
  const MorphSideSheetLayout({
    required this.body,
    required this.sheet,
    this.controller,
    this.mode = MorphSideSheetLayoutMode.adaptive,
    this.initiallyOpen = false,
    this.isDismissible = true,
    this.onOpenChanged,
    super.key,
  });

  /// Main content.
  final Widget body;

  /// The side sheet. Its variant is chosen by [mode].
  final MorphSideSheet sheet;

  /// Opens and closes the sheet.
  final MorphSideSheetController? controller;

  /// Standard, modal, or chosen by window width.
  final MorphSideSheetLayoutMode mode;

  /// Whether the sheet starts open.
  final bool initiallyOpen;

  /// Whether tapping the scrim closes a modal sheet.
  final bool isDismissible;

  /// Called when the sheet opens or closes.
  final ValueChanged<bool>? onOpenChanged;

  @override
  State<MorphSideSheetLayout> createState() => _MorphSideSheetLayoutState();
}

class _MorphSideSheetLayoutState extends State<MorphSideSheetLayout>
    with TickerProviderStateMixin, WidgetsBindingObserver
    implements MorphSideSheetControllerClient {
  late final AnimationController _open = AnimationController.unbounded(
    vsync: this,
    value: widget.initiallyOpen ? 1 : 0,
  );
  late final AnimationController _modal = AnimationController.unbounded(
    vsync: this,
  );
  late final AnimationController _back = AnimationController.unbounded(
    vsync: this,
  );
  final FocusNode _sheetFocus = FocusNode(
    debugLabel: 'MorphSideSheetLayout sheet',
    skipTraversal: true,
  );
  final GlobalKey _sheetKey = GlobalKey(debugLabel: 'MorphSideSheetLayout');
  late bool _isOpen = widget.initiallyOpen;
  bool? _isModal;
  bool _keyboard = false;
  bool _fromAnchor = false;

  MorphSideSheetTheme get _theme =>
      widget.sheet.theme ?? MorphTheme.of(context).sideSheetTheme;

  bool get _modalActive => _isOpen && (_isModal ?? false);

  bool get _onRight => _morphSideSheetOnRight(context, widget.sheet.edge);

  @override
  bool get isOpen => _isOpen;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    widget.controller?.attach(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncMode();
    if (MorphMotion.reduceMotionOf(context)) {
      _open.stop(canceled: false);
      _open.value = _isOpen ? 1 : 0;
      _modal.value = (_isModal ?? false) ? 1 : 0;
      _back.value = 0;
    }
  }

  @override
  void didUpdateWidget(covariant MorphSideSheetLayout oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.detach(this);
      widget.controller?.attach(this);
    }
    _syncMode();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    widget.controller?.detach(this);
    _open.dispose();
    _modal.dispose();
    _back.dispose();
    _sheetFocus.dispose();
    super.dispose();
  }

  void _syncMode() {
    final bool modal = switch (widget.mode) {
      MorphSideSheetLayoutMode.modal => true,
      MorphSideSheetLayoutMode.standard => false,
      MorphSideSheetLayoutMode.adaptive =>
        MediaQuery.sizeOf(context).width < _theme.compactBreakpoint,
    };
    if (_isModal == null) {
      _isModal = modal;
      _modal.value = modal ? 1 : 0;
      return;
    }
    if (modal == _isModal) {
      return;
    }
    _isModal = modal;
    morphSideSheetAnimate(
      context,
      _modal,
      _theme.motion.layoutSpring,
      modal ? 1 : 0,
    );
  }

  @override
  void open() {
    if (_isOpen) {
      return;
    }
    _keyboard = MorphFocusInteraction.instance.ringsAllowed;
    _back.value = 0;
    setState(() => _isOpen = true);
    morphSideSheetAnimate(context, _open, _theme.motion.enterSpring, 1);
    _notify();
    if ((_isModal ?? false) && !_keyboard) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _isOpen) {
          _sheetFocus.requestFocus();
        }
      });
    }
  }

  @override
  void close([Object? result]) {
    if (!_isOpen) {
      return;
    }
    setState(() => _isOpen = false);
    morphSideSheetAnimate(context, _open, _theme.motion.enterSpring, 0);
    _notify();
  }

  void _notify() {
    widget.controller?.updateOpen(isOpen: _isOpen);
    widget.onOpenChanged?.call(_isOpen);
  }

  void _onClosePressed() {
    widget.sheet.onClose?.call();
    close();
  }

  // ── Predictive back (modal only) ───────────────────────────────────────

  @override
  bool handleStartBackGesture(PredictiveBackEvent backEvent) {
    final bool current = ModalRoute.of(context)?.isCurrent ?? true;
    if (!mounted || !_modalActive || !current) {
      return false;
    }
    _fromAnchor = (backEvent.swipeEdge == SwipeEdge.right) == _onRight;
    _back
      ..stop()
      ..value = backEvent.progress;
    return true;
  }

  @override
  void handleUpdateBackGestureProgress(PredictiveBackEvent backEvent) {
    _back.value = backEvent.progress;
  }

  @override
  void handleCommitBackGesture() => close();

  @override
  void handleCancelBackGesture() =>
      morphSideSheetAnimate(context, _back, _theme.motion.settleSpring, 0);

  @override
  Widget build(BuildContext context) => _buildLayout(context);
}
