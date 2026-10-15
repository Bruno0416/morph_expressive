import 'package:flutter/widgets.dart';

import '../enums/morph_button_enums.dart';
import 'morph_button_decoration.dart';

/// Default [MorphButtonDecoration] for `MorphButton`s below it.
///
/// A button's own `decoration` is merged on top, field by field. Containers
/// such as dialogs use this to style the buttons they are given.
class MorphButtonDecorationScope extends InheritedWidget {
  /// MorphButtonDecorationScope.
  const MorphButtonDecorationScope({
    required this.decoration,
    required super.child,
    this.styles,
    super.key,
  });

  /// Decoration applied to descendant buttons.
  final MorphButtonDecoration decoration;

  /// Button styles the scope applies to. Null applies to every style.
  final Set<MorphButtonStyle>? styles;

  /// Scope decoration for a button of [style], or null.
  static MorphButtonDecoration? maybeOf(
    BuildContext context,
    MorphButtonStyle style,
  ) {
    final MorphButtonDecorationScope? scope = context
        .dependOnInheritedWidgetOfExactType<MorphButtonDecorationScope>();
    if (scope == null || !(scope.styles?.contains(style) ?? true)) {
      return null;
    }
    return scope.decoration;
  }

  @override
  bool updateShouldNotify(MorphButtonDecorationScope oldWidget) =>
      decoration != oldWidget.decoration || styles != oldWidget.styles;
}
