import 'package:flutter/widgets.dart';

import '../../../foundations/foundations.dart';
import '../styles/morph_list_theme.dart';

/// 56dp leading image.
class MorphListImage extends StatelessWidget {
  /// Creates a list image slot.
  const MorphListImage({required this.child, super.key});

  /// Image content.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final MorphListItemTheme item = MorphTheme.of(context).listTheme.item;
    final double radius = item.isBaseline ? 0 : item.leadingImageRadius;
    return SizedBox.square(
      dimension: item.leadingImageSize,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: child,
      ),
    );
  }
}
