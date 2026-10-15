import 'package:flutter/widgets.dart';

import '../enums/morph_menu_color_style.dart';
import '../styles/morph_menu_theme.dart';

/// Provides [colorStyle] / resolved [colors] to menu item descendants.
class MorphMenuStyleScope extends InheritedWidget {
  /// MorphMenuStyleScope.
  const MorphMenuStyleScope({
    required this.colorStyle,
    required this.colors,
    required super.child,
    super.key,
  });

  /// colorStyle.

  final MorphMenuColorStyle colorStyle;

  /// colors.
  final MorphMenuColors colors;

  /// maybeOf.

  static MorphMenuStyleScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<MorphMenuStyleScope>();
  }

  /// styleOf.

  static MorphMenuColorStyle styleOf(BuildContext context) {
    return maybeOf(context)?.colorStyle ?? MorphMenuColorStyle.standard;
  }

  /// colorsOf.

  static MorphMenuColors? colorsOf(BuildContext context) {
    return maybeOf(context)?.colors;
  }

  @override
  bool updateShouldNotify(covariant MorphMenuStyleScope oldWidget) {
    return colorStyle != oldWidget.colorStyle || colors != oldWidget.colors;
  }
}
