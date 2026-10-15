import 'package:flutter/widgets.dart';

import '../../../foundations/foundations.dart';
import '../styles/morph_list_theme.dart';

/// Leading video thumbnail.
///
/// Small is 100×56. [large] is 114×64.
class MorphListVideo extends StatelessWidget {
  /// Creates a list video slot.
  const MorphListVideo({required this.child, this.large = false, super.key});

  /// Thumbnail content.
  final Widget child;

  /// Uses the large 114×64 slot.
  final bool large;

  @override
  Widget build(BuildContext context) {
    final MorphListItemTheme item = MorphTheme.of(context).listTheme.item;
    final double width = large
        ? item.largeLeadingVideoWidth
        : item.leadingVideoWidth;
    final double height = large
        ? item.largeLeadingVideoHeight
        : item.leadingVideoHeight;
    final double radius = item.isBaseline ? 0 : item.leadingImageRadius;
    return SizedBox(
      width: width,
      height: height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: child,
      ),
    );
  }
}
