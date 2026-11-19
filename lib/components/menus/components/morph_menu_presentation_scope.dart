import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:flutter/widgets.dart';

import '../enums/morph_menu_presentation.dart';

/// Tells menu rows which presentation they are laid out in and which shared
/// slots (leading icon, trailing chevron) the whole menu reserves.
///
/// Rows outside a popup (no scope) always use the standard layout.
class MorphMenuPresentationScope extends InheritedWidget {
  /// Creates a presentation scope.
  const MorphMenuPresentationScope({
    required this.presentation,
    required super.child,
    this.reserveLeading = false,
    this.reserveTrailing = false,
    this.expandedNode,
    super.key,
  });

  /// Presentation of the enclosing popup.
  final MorphMenuPresentation presentation;

  /// True when any row has a leading widget or check indicator, so rows
  /// without one still reserve the slot and labels share one x position.
  final bool reserveLeading;

  /// True when any row has a submenu chevron, so every row reserves the
  /// fixed trailing slot and shortcut hints stay aligned.
  final bool reserveTrailing;

  /// Focus node of the row whose submenu is currently open (desktop). That
  /// row keeps a hover-strength highlight while its submenu is open.
  final ValueListenable<FocusNode?>? expandedNode;

  /// The nearest scope or null.
  static MorphMenuPresentationScope? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<MorphMenuPresentationScope>();
  }

  /// Whether [context] is inside a desktop-presentation menu.
  static bool isDesktop(BuildContext context) =>
      maybeOf(context)?.presentation == MorphMenuPresentation.desktop;

  @override
  bool updateShouldNotify(covariant MorphMenuPresentationScope oldWidget) {
    return presentation != oldWidget.presentation ||
        reserveLeading != oldWidget.reserveLeading ||
        reserveTrailing != oldWidget.reserveTrailing ||
        expandedNode != oldWidget.expandedNode;
  }
}
