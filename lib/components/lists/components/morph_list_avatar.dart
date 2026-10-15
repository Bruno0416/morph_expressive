import 'package:flutter/widgets.dart';

import '../../../foundations/foundations.dart';
import '../styles/morph_list_theme.dart';

/// 40dp circular leading avatar.
class MorphListAvatar extends StatelessWidget {
  /// Creates a list avatar.
  const MorphListAvatar({this.label, this.child, super.key});

  /// Initials drawn when [child] is null.
  final String? label;

  /// Optional avatar content, such as an image.
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final MorphThemeData theme = MorphTheme.of(context);
    final MorphListItemTheme item = theme.listTheme.item;
    final MorphColorScheme scheme = theme.colorScheme;
    final double size = item.avatarSize;
    return SizedBox.square(
      dimension: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: item.resolveAvatar(scheme),
          shape: BoxShape.circle,
        ),
        child: Center(
          child:
              child ??
              Text(
                label ?? '',
                style: item.avatarLabelStyle(theme.typeScale, scheme),
              ),
        ),
      ),
    );
  }
}
