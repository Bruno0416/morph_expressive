import 'package:flutter/widgets.dart';
import 'package:material_ui/material_ui.dart' show Colors;

import '../theme/morph_theme.dart';
import 'morph_state_layer.dart';

/// Supplies expressive splash color for Material buttons that only expose
/// overlay color to their ink layer.
///
/// Pressed feedback is splash-only; hover/focus use hover/focus overlays.
class MorphInkSplashTheme extends StatelessWidget {
  /// Creates an ink splash theme for [child] derived from [color].
  const MorphInkSplashTheme({
    required this.color,
    required this.child,
    super.key,
  });

  /// Role color used to derive the pressed ripple.
  final Color color;

  /// The subtree that receives the splash/highlight override.
  final Widget child;

  @override
  /// Applies splash/highlight overrides around [child].
  Widget build(BuildContext context) {
    return MorphTheme(
      data: MorphTheme.of(context).copyWith(
        splashColor: MorphStateLayer.splashColor(color),
        highlightColor: Colors.transparent,
      ),
      child: child,
    );
  }
}
