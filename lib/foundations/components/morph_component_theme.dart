import 'package:flutter/widgets.dart';

import '../theme/morph_theme.dart';

/// Registers an adaptive theme dependency for a single Morph component subtree.
///
/// Only descendants of an adaptive [MorphTheme] root with [MorphThemeScope] need
/// this wrapper. When no scope is present the [builder] runs unchanged.
class MorphComponentTheme extends StatelessWidget {
  /// Creates a component theme dependency wrapper.
  const MorphComponentTheme({required this.builder, super.key});

  /// Builds the themed component subtree.
  final WidgetBuilder builder;

  @override
  /// Builds the component subtree with an adaptive theme dependency.
  Widget build(BuildContext context) {
    final MorphInheritedTheme? inherited = context
        .dependOnInheritedWidgetOfExactType<MorphInheritedTheme>();
    if (inherited == null) {
      MorphThemeScope.resolveForComponent(context);
    }
    return builder(context);
  }
}
