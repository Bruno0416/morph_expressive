import '../interaction/morph_motion_scope.dart';

import 'package:material_ui/material_ui.dart'
    show
        BuildContext,
        DefaultTextStyle,
        IconTheme,
        IconThemeData,
        InheritedTheme,
        StatelessWidget,
        TextDecoration,
        TextStyle,
        Theme,
        ThemeData,
        Widget;

import 'morph_theme.dart';

/// Applies a resolved [MorphThemeData] to a subtree.
///
/// Projects [data] onto Material [Theme] so host widgets that read
/// [Theme.of] (text/icon/color scheme) track the active Morph tokens,
/// including after dynamic color updates.
///
/// Does **not** call [Theme.of]: MaterialApp theme animations would otherwise
/// rebuild this subtree every frame and can drop weighted-sliver children
/// (e.g. the first hero carousel item).
class MorphResolvedTheme extends StatelessWidget {
  /// Creates a resolved theme projection for [child].
  const MorphResolvedTheme({
    required this.data,
    required this.child,
    super.key,
  });

  /// The expressive theme applied to [child].
  final MorphThemeData data;

  /// The subtree under this resolved theme.
  final Widget child;

  @override
  /// Projects [data] onto Material [Theme] and expressive inherited theme.
  Widget build(BuildContext context) {
    final IconThemeData icons = data.resolvedIconTheme;
    final TextStyle baseStyle = (data.textTheme.bodyMedium ?? const TextStyle())
        .copyWith(decoration: TextDecoration.none);

    // 1. proyectar los colores desde el tema activo (no desde un tema obsoleto)
    // ThemeData.copyWith(colorScheme: ...) mantiene algunos colores derivados
    // del tema anterior, como cardColor y scaffoldBackgroundColor.
    final ThemeData? parentTheme = context
        .findAncestorWidgetOfExactType<Theme>()
        ?.data;
    final ThemeData projected = data.toThemeData().copyWith(
      extensions: parentTheme?.extensions.values.toList(),
    );

    return Theme(
      data: projected,
      child: MorphInheritedTheme(
        data: data,
        child: IconTheme(
          data: icons,
          child: MorphMotionScope(
            reduceMotion: data.reduceMotion,
            child: DefaultTextStyle(style: baseStyle, child: child),
          ),
        ),
      ),
    );
  }
}

/// Inherited theme handle used by [MorphTheme.of].
class MorphInheritedTheme extends InheritedTheme {
  /// Creates an inherited expressive theme.
  const MorphInheritedTheme({
    super.key,
    required this.data,
    required super.child,
  });

  /// The expressive theme for descendants.
  final MorphThemeData data;

  @override
  /// Wraps [child] in a [MorphResolvedTheme] with this [data].
  Widget wrap(BuildContext context, Widget child) {
    return MorphResolvedTheme(data: data, child: child);
  }

  @override
  /// Whether descendants should rebuild when [data] changes.
  bool updateShouldNotify(MorphInheritedTheme oldWidget) =>
      data != oldWidget.data;
}
