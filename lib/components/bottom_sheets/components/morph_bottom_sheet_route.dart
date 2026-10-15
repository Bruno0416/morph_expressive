part of '../morph_bottom_sheets.dart';

MorphThemeData _themeOf(BuildContext context) =>
    MorphThemeScope.resolveOf(context) ?? MorphTheme.of(context);

/// Pushes the modal sheet route. The host paints its own spring scrim.
Future<T?> _pushModalSheet<T>(
  BuildContext context, {
  required WidgetBuilder builder,
  required MorphBottomSheetTheme? theme,
  required MorphBottomSheetLabels labels,
  required bool useRootNavigator,
  required Widget Function(Animation<double>, MorphBottomSheetTheme) host,
}) {
  final MorphBottomSheetTheme sheetTheme =
      theme ?? _themeOf(context).bottomSheetTheme;
  final Duration enter = morphBottomSheetSpringSettle(sheetTheme.enterSpring);
  final Duration scrim = morphBottomSheetSpringSettle(sheetTheme.scrimSpring);
  return Navigator.of(context, rootNavigator: useRootNavigator).push<T>(
    RawDialogRoute<T>(
      barrierColor: null,
      barrierDismissible: false,
      transitionDuration: enter > scrim ? enter : scrim,
      traversalEdgeBehavior: TraversalEdgeBehavior.closedLoop,
      pageBuilder: (BuildContext context, Animation<double> animation, _) {
        return MorphComponentTheme(builder: (_) => host(animation, sheetTheme));
      },
      transitionBuilder: (_, _, _, Widget child) => child,
    ),
  );
}
