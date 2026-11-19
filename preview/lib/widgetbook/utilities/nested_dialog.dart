import 'package:material_ui/material_ui.dart'
    show
        BuildContext,
        Center,
        Color,
        FadeTransition,
        MaterialLocalizations,
        SafeArea,
        ScaleTransition,
        Tween,
        Widget,
        showGeneralDialog;

/// Shows [dialog] on the use case's own navigator.
///
/// Widgetbook's root app only provides the framework's Material localizations,
/// while Morph's picker dialogs read `material_ui`'s. Pushing on the nested
/// navigator (which lives in a real Material app) gives them everything they
/// need, and keeps the dialog inside the viewport frame.
Future<T?> showNestedDialog<T>(BuildContext context, Widget dialog) {
  return showGeneralDialog<T>(
    context: context,
    useRootNavigator: false,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: const Color(0x66000000),
    transitionDuration: const Duration(milliseconds: 250),
    pageBuilder: (context, _, _) => SafeArea(child: Center(child: dialog)),
    transitionBuilder: (context, animation, _, child) => FadeTransition(
      opacity: animation,
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.92, end: 1).animate(animation),
        child: child,
      ),
    ),
  );
}
