part of '../morph_side_sheets.dart';

/// Pushes the modal side sheet route. The host paints its own spring scrim.
Future<T?> _pushSideSheet<T>(
  BuildContext context, {
  required MorphSideSheet sheet,
  required bool isDismissible,
  required Future<bool> Function()? onDismissRequest,
  required MorphSideSheetController? controller,
  required bool useRootNavigator,
}) {
  final MorphThemeData morph =
      MorphThemeScope.resolveOf(context) ?? MorphTheme.of(context);
  final MorphSideSheetTheme theme = sheet.theme ?? morph.sideSheetTheme;
  final Duration enter = morphSideSheetSpringSettle(theme.motion.enterSpring);
  final Duration scrim = morphSideSheetSpringSettle(theme.motion.scrimSpring);
  return Navigator.of(context, rootNavigator: useRootNavigator).push<T>(
    RawDialogRoute<T>(
      barrierColor: null,
      barrierDismissible: false,
      transitionDuration: enter > scrim ? enter : scrim,
      traversalEdgeBehavior: TraversalEdgeBehavior.closedLoop,
      pageBuilder: (BuildContext context, Animation<double> animation, _) {
        return MorphComponentTheme(
          builder: (_) => _MorphSideSheetModalHost(
            animation: animation,
            sheet: sheet,
            theme: theme,
            isDismissible: isDismissible,
            onDismissRequest: onDismissRequest,
            controller: controller,
          ),
        );
      },
      transitionBuilder: (_, _, _, Widget child) => child,
    ),
  );
}
