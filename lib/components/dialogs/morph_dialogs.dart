import 'dart:ui' show SemanticsRole;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../foundations/foundations.dart';
import '../checkbox/morph_checkbox.dart';
import '../divider/morph_divider.dart';
import '../radio_button/morph_radio_button.dart';
import 'components/morph_adaptive_dialog.dart';
import 'components/morph_dialog_actions.dart';
import 'components/morph_dialog_dismiss_scope.dart';
import 'components/morph_dialog_headline.dart';
import 'components/morph_dialog_inset.dart';
import 'components/morph_dialog_transition.dart';
import 'components/morph_full_screen_dialog.dart';
import 'controllers/morph_dialog_controller.dart';
import 'enums/morph_dialog_enums.dart';
import 'models/morph_dialog_discard_labels.dart';
import 'res/morph_dialog_strings.dart';
import 'styles/morph_dialog_appearance.dart';
import 'styles/morph_dialog_theme.dart';
import 'utils/morph_dialog_action_button.dart';
import 'utils/morph_dialog_surface.dart';

export 'components/morph_adaptive_dialog.dart';
export 'components/morph_dialog_inset.dart';
export 'components/morph_full_screen_dialog.dart';
export 'controllers/morph_dialog_controller.dart';
export 'enums/morph_dialog_enums.dart';
export 'models/morph_dialog_discard_labels.dart';
export 'styles/morph_dialog_appearance.dart';
export 'styles/morph_dialog_theme.dart';
export 'styles/morph_full_screen_dialog_theme.dart';

part 'components/morph_dialog_layout.dart';
part 'components/morph_dialog_route.dart';
part 'components/morph_selection_dialog.dart';

/// A Material 3 Expressive basic dialog plus helpers to present dialogs.
///
/// Use [MorphDialog.show] for a basic dialog over a scrim,
/// [MorphDialog.showFullScreen] for compact full-screen tasks and
/// [MorphDialog.showAdaptive] to swap between them at the compact breakpoint.
/// The headline and actions stay pinned while the content scrolls.
class MorphDialog extends StatelessWidget {
  /// MorphDialog.
  const MorphDialog({
    required this.title,
    this.icon,
    this.content,
    this.contentPadding,
    this.actions = const <Widget>[],
    this.topDivider = false,
    this.bottomDivider = false,
    this.subhead,
    this.leadingAction,
    this.scrollController,
    this.titleMaxLines,
    this.semanticLabel,
    super.key,
  });

  /// Headline. Also the dialog's accessibility label.
  final String title;

  /// Optional hero icon. Centres the headline when set.
  final Widget? icon;

  /// Supporting content. Scrolls between the pinned headline and actions.
  final Widget? content;

  /// Null uses 24 left / right with spec gaps above and below.
  final EdgeInsets? contentPadding;

  /// Dismissive first, confirming last (closest to the trailing edge).
  /// At most two are recommended; they stack when they don't fit.
  final List<Widget> actions;

  /// Full-bleed divider between the header and the section below it.
  final bool topDivider;

  /// Full-bleed divider above the actions row.
  final bool bottomDivider;

  /// Optional subhead under the headline.
  final String? subhead;

  /// Optional third action at the leading edge (e.g. Learn more).
  ///
  /// Use with caution: it can take people away from an unfinished task.
  final Widget? leadingAction;

  /// Controller for the scrolling content.
  final ScrollController? scrollController;

  /// Headline lines before truncation. Null wraps without limit. A truncated
  /// headline expands on tap.
  final int? titleMaxLines;

  /// Null uses [title].
  final String? semanticLabel;

  /// Presents a basic dialog and completes with the popped result.
  ///
  /// [position] places the dialog (centre by default) inside the system bars
  /// and above the soft keyboard.
  ///
  /// Escape, back, barrier taps and [controller] dismissals run
  /// [onDismissRequest] first. Focus lands on the first interactive element
  /// when [autofocusFirst] is true.
  static Future<T?> show<T>(
    BuildContext context, {
    required Widget dialog,
    bool barrierDismissible = true,
    bool? resizeToAvoidBottomInset,
    MorphDialogPosition position = MorphDialogPosition.center,
    MorphDialogController? controller,
    Future<bool> Function()? onDismissRequest,
    bool autofocusFirst = true,
  }) {
    return _pushDialog<T>(
      context,
      variant: MorphDialogVariant.basic,
      barrierDismissible: barrierDismissible,
      controller: controller,
      onDismissRequest: onDismissRequest,
      autofocusFirst: autofocusFirst,
      builder: (BuildContext context) {
        return MorphScrimSystemUi.wrap(
          MorphDialogInset(
            padding: MorphTheme.of(context).dialogTheme.screenMargin,
            resizeToAvoidBottomInset: resizeToAvoidBottomInset,
            alignment: position.alignment,
            child: dialog,
          ),
        );
      },
    );
  }

  /// Presents a full-screen dialog with a header of [title] and [action].
  ///
  /// For compact widths only; see [showAdaptive] for larger screens.
  static Future<T?> showFullScreen<T>(
    BuildContext context, {
    required String title,
    required Widget body,
    Widget? action,
    String? confirmLabel,
    VoidCallback? onConfirm,
    List<Widget> bottomActions = const <Widget>[],
    String? contentHeadline,
    EdgeInsetsGeometry? contentPadding,
    MorphDialogController? controller,
    Future<bool> Function()? onDismissRequest,
    bool autofocusFirst = true,
    String? semanticLabel,
  }) {
    return _pushDialog<T>(
      context,
      variant: MorphDialogVariant.fullScreen,
      barrierDismissible: false,
      controller: controller,
      onDismissRequest: onDismissRequest,
      autofocusFirst: autofocusFirst,
      builder: (BuildContext context) => MorphFullScreenDialog(
        title: title,
        body: body,
        action: action,
        confirmLabel: confirmLabel,
        onConfirm: onConfirm,
        bottomActions: bottomActions,
        contentHeadline: contentHeadline,
        contentPadding: contentPadding,
        semanticLabel: semanticLabel,
      ),
    );
  }

  /// Presents an [MorphAdaptiveDialog]: full-screen below the compact
  /// breakpoint, basic above it, morphing when the width crosses it.
  static Future<T?> showAdaptive<T>(
    BuildContext context, {
    required String title,
    required Widget content,
    required String confirmLabel,
    required VoidCallback? onConfirm,
    String dismissLabel = MorphDialogStrings.cancel,
    Widget? icon,
    MorphDialogPosition position = MorphDialogPosition.center,
    bool barrierDismissible = true,
    MorphDialogController? controller,
    Future<bool> Function()? onDismissRequest,
    bool autofocusFirst = true,
    String? semanticLabel,
  }) {
    final double width = MediaQuery.sizeOf(context).width;
    final MorphDialogTheme dialogTheme = _themeOf(context).dialogTheme;
    return _pushDialog<T>(
      context,
      variant: width < dialogTheme.compactBreakpoint
          ? MorphDialogVariant.fullScreen
          : MorphDialogVariant.basic,
      barrierDismissible: barrierDismissible,
      controller: controller,
      onDismissRequest: onDismissRequest,
      autofocusFirst: autofocusFirst,
      builder: (BuildContext context) => MorphAdaptiveDialog(
        title: title,
        content: content,
        confirmLabel: confirmLabel,
        onConfirm: onConfirm,
        dismissLabel: dismissLabel,
        icon: icon,
        position: position,
        controller: controller,
        semanticLabel: semanticLabel,
      ),
    );
  }

  /// Asks to discard unsaved changes. Resolves true to discard.
  static Future<bool> showDiscardConfirmation(
    BuildContext context, {
    MorphDialogDiscardLabels labels = const MorphDialogDiscardLabels(),
  }) async {
    final bool? discard = await show<bool>(
      context,
      dialog: Builder(
        builder: (BuildContext context) => _discardDialog(context, labels),
      ),
    );
    return discard ?? false;
  }

  /// Presents a centred [MorphDialog] with selectable [options].
  ///
  /// Uses [MorphRadio] for single selection and [MorphCheckbox] when
  /// [multiSelect] is true. Both section dividers are enabled. Confirm stays
  /// disabled until at least one option is selected; on confirm, returns the
  /// selected values (or `null` if dismissed).
  static Future<List<String>?> showSelectionScreen(
    BuildContext context, {
    required String title,
    required List<String> options,
    bool multiSelect = false,
    List<String> initialSelection = const <String>[],
    String cancelLabel = MorphDialogStrings.cancel,
    String confirmLabel = MorphDialogStrings.confirm,
    Widget? icon,
    bool barrierDismissible = true,
    bool? resizeToAvoidBottomInset,
  }) {
    assert(options.isNotEmpty, 'options must not be empty.');
    return show<List<String>>(
      context,
      barrierDismissible: barrierDismissible,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      dialog: _MorphSelectionDialog(
        title: title,
        options: options,
        multiSelect: multiSelect,
        initialSelection: initialSelection,
        cancelLabel: cancelLabel,
        confirmLabel: confirmLabel,
        icon: icon,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MorphComponentTheme(builder: _buildDialog);
  }
}
