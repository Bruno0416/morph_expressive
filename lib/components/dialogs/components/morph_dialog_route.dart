part of '../morph_dialogs.dart';

MorphThemeData _themeOf(BuildContext context) =>
    MorphThemeScope.resolveOf(context) ?? MorphTheme.of(context);

Future<bool?> _discardPrompt(
  BuildContext context,
  MorphDialogDiscardLabels labels,
) => MorphDialog.showDiscardConfirmation(context, labels: labels);

/// Ruta interna que permite una salida mas breve que la entrada.
///
/// RawDialogRoute no admite reverseTransitionDuration en su constructor;
/// la propiedad se personaliza sobrescribiendo su getter.
class _MorphRawDialogRoute<T> extends RawDialogRoute<T> {
  _MorphRawDialogRoute({
    required super.pageBuilder,
    super.barrierDismissible,
    super.barrierLabel,
    super.barrierColor,
    super.transitionDuration,
    super.transitionBuilder,
    super.traversalEdgeBehavior,
  });

  @override
  Duration get reverseTransitionDuration => MorphMotion.medium2;
}

/// Pushes a spring-animated dialog route with the shared dismiss path.
Future<T?> _pushDialog<T>(
  BuildContext context, {
  required MorphDialogVariant variant,
  required bool barrierDismissible,
  required WidgetBuilder builder,
  required MorphDialogController? controller,
  required Future<bool> Function()? onDismissRequest,
  required bool autofocusFirst,
}) {
  final MorphThemeData theme = _themeOf(context);
  final MorphDialogTheme dialogTheme = theme.dialogTheme;
  return Navigator.of(context, rootNavigator: true).push<T>(
    _MorphRawDialogRoute<T>(
      barrierDismissible: barrierDismissible,
      barrierLabel: variant == MorphDialogVariant.basic
          ? MorphDialogStrings.dismiss
          : MorphDialogStrings.fullScreen,
      barrierColor: dialogTheme.scrimColor(theme.colorScheme),
      transitionDuration: MorphDialogTransition.durationFor(dialogTheme, variant),
      traversalEdgeBehavior: TraversalEdgeBehavior.closedLoop,
      pageBuilder: (BuildContext context, _, _) {
        return MorphComponentTheme(
          builder: (BuildContext context) => MorphDialogDismissScope(
            controller: controller,
            onDismissRequest: onDismissRequest,
            autofocusFirst: autofocusFirst,
            variant: variant,
            discardPrompt: _discardPrompt,
            child: builder(context),
          ),
        );
      },
      transitionBuilder: (context, animation, _, child) => MorphDialogTransition(
        animation: animation,
        variant: variant,
        dialogTheme: dialogTheme,
        child: child,
      ),
    ),
  );
}

/// Basic dialog that confirms discarding unsaved changes.
Widget _discardDialog(BuildContext context, MorphDialogDiscardLabels labels) {
  final NavigatorState navigator = Navigator.of(context);
  final String? supporting = labels.supportingText;
  return MorphDialog(
    title: labels.title,
    content: supporting == null ? null : Text(supporting),
    actions: <Widget>[
      morphDialogTextAction(
        label: labels.keepLabel,
        onPressed: () => navigator.pop(false),
      ),
      morphDialogTextAction(
        label: labels.discardLabel,
        onPressed: () => navigator.pop(true),
      ),
    ],
  );
}
