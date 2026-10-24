import 'package:flutter/widgets.dart';
import 'package:motor/motor.dart';

import '../../../foundations/interaction/morph_motion_controller.dart';
import '../../../foundations/foundations.dart';
import '../morph_dialogs.dart';
import '../res/morph_dialog_strings.dart';
import '../utils/morph_dialog_action_button.dart';
import '../utils/morph_dialog_spring.dart';

part 'morph_adaptive_dialog_morph.dart';

/// Dialog that swaps variant at the compact breakpoint.
///
/// Below `MorphDialogTheme.compactBreakpoint` it is a full-screen dialog (close
/// X and [confirmLabel] in the header). Wider, it is a basic dialog with
/// [dismissLabel] and [confirmLabel] actions. Crossing the breakpoint morphs
/// the surface on the spatial spring.
class MorphAdaptiveDialog extends StatefulWidget {
  /// MorphAdaptiveDialog.
  const MorphAdaptiveDialog({
    required this.title,
    required this.content,
    required this.confirmLabel,
    required this.onConfirm,
    this.dismissLabel = MorphDialogStrings.cancel,
    this.icon,
    this.position = MorphDialogPosition.center,
    this.controller,
    this.semanticLabel,
    super.key,
  });

  /// Headline.
  final String title;

  /// Body. Scrolls in both variants.
  final Widget content;

  /// Confirming action label (e.g. Save).
  final String confirmLabel;

  /// Confirming action. Null disables it.
  final VoidCallback? onConfirm;

  /// Dismissive action label in the basic variant.
  final String dismissLabel;

  /// Optional hero icon in the basic variant.
  final Widget? icon;

  /// Basic dialog position.
  final MorphDialogPosition position;

  /// Receives the active variant.
  final MorphDialogController? controller;

  /// Null uses [title].
  final String? semanticLabel;

  @override
  State<MorphAdaptiveDialog> createState() => _MorphAdaptiveDialogState();
}

class _MorphAdaptiveDialogState extends State<MorphAdaptiveDialog>
    with SingleTickerProviderStateMixin {
  final GlobalKey _surfaceKey = GlobalKey();
  SingleMotionController? _morph;
  MorphDialogVariant? _variant;
  Rect? _lastRect;
  Rect? _from;
  Rect? _to;
  bool _pendingSwap = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _morph ??= MorphMotionController(
      motion: morphDialogSpringMotion(
        MorphTheme.of(context).dialogTheme.enterSpring,
      ),
      vsync: this,
    )..value = 1;
  }

  @override
  void dispose() {
    _morph?.dispose();
    super.dispose();
  }

  void _refresh() => setState(() {});

  void _dismiss() => Navigator.maybePop(context);

  Widget _basic(MorphThemeData theme) {
    return MorphDialogInset(
      padding: theme.dialogTheme.screenMargin,
      alignment: widget.position.alignment,
      child: KeyedSubtree(
        key: _surfaceKey,
        child: MorphDialog(
          title: widget.title,
          icon: widget.icon,
          content: widget.content,
          semanticLabel: widget.semanticLabel,
          actions: <Widget>[
            morphDialogTextAction(
              label: widget.dismissLabel,
              onPressed: _dismiss,
            ),
            morphDialogTextAction(
              label: widget.confirmLabel,
              onPressed: widget.onConfirm,
            ),
          ],
        ),
      ),
    );
  }

  Widget _fullScreen() {
    return KeyedSubtree(
      key: _surfaceKey,
      child: MorphFullScreenDialog(
        title: widget.title,
        body: SingleChildScrollView(child: widget.content),
        confirmLabel: widget.confirmLabel,
        onConfirm: widget.onConfirm,
        semanticLabel: widget.semanticLabel,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final MorphThemeData theme = MorphTheme.of(context);
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final variant =
            constraints.maxWidth < theme.dialogTheme.compactBreakpoint
            ? MorphDialogVariant.fullScreen
            : MorphDialogVariant.basic;
        _onVariant(variant);
        final Widget layout = variant == MorphDialogVariant.fullScreen
            ? _fullScreen()
            : _basic(theme);
        return _morphed(layout);
      },
    );
  }
}
