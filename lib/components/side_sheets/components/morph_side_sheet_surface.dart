import 'package:flutter/widgets.dart';

import '../../../foundations/foundations.dart';
import '../enums/morph_side_sheet_enums.dart';
import '../styles/morph_side_sheet_theme.dart';

/// Side sheet container: color, tint, elevation and corner shape.
///
/// [modal] blends the standard (0) and modal (1) looks while the sheet
/// morphs between them.
class MorphSideSheetSurface extends StatelessWidget {
  /// MorphSideSheetSurface.
  const MorphSideSheetSurface({
    required this.theme,
    required this.modal,
    required this.borderRadius,
    required this.child,
    super.key,
  });

  /// Resolved sheet theme.
  final MorphSideSheetTheme theme;

  /// 0 for standard, 1 for modal.
  final double modal;

  /// Current corner shape.
  final BorderRadius borderRadius;

  /// Sheet content.
  final Widget child;

  /// Tint opacity for M3 elevation levels.
  static double tintOpacity(double elevation) {
    if (elevation <= 0) {
      return 0;
    }
    if (elevation <= MorphElevation.level1) {
      return 0.05;
    }
    if (elevation <= MorphElevation.level2) {
      return 0.08;
    }
    if (elevation <= MorphElevation.level3) {
      return 0.11;
    }
    return elevation <= MorphElevation.level4 ? 0.12 : 0.14;
  }

  @override
  Widget build(BuildContext context) {
    final MorphColorScheme scheme = MorphTheme.of(context).colorScheme;
    final double t = modal.clamp(0, 1).toDouble();
    final double elevation =
        theme.standardElevation +
        (theme.modalElevation - theme.standardElevation) * t;
    Color color = Color.lerp(
      theme.containerColor(scheme, MorphSideSheetVariant.standard),
      theme.containerColor(scheme, MorphSideSheetVariant.modal),
      t,
    )!;
    final Color? tint = theme.colors.surfaceTintColor;
    if (tint != null) {
      color = Color.alphaBlend(
        tint.withValues(alpha: tintOpacity(elevation)),
        color,
      );
    }
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        borderRadius: borderRadius,
        boxShadow: MorphElevation.shadows(elevation, shadowColor: scheme.shadow),
      ),
      child: ClipRRect(borderRadius: borderRadius, child: child),
    );
  }
}
