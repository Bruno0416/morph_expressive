import 'package:flutter/widgets.dart';
import 'package:morph_expressive/components/toolbars/morph_toolbars.dart'
    show MorphToolbar;
import 'package:morph_expressive/morph_components.dart'
    show MorphToolbar;

/// Title and optional subtitle for [MorphToolbar].
class MorphToolbarTitleBlock extends StatelessWidget {
  /// MorphToolbarTitleBlock.
  const MorphToolbarTitleBlock({
    required this.title,
    required this.subtitle,
    required this.center,
    required this.titleStyle,
    required this.subtitleStyle,
    super.key,
  });

  /// title.

  final Widget? title;

  /// subtitle.
  final Widget? subtitle;

  /// center.
  final bool center;

  /// titleStyle.
  final TextStyle titleStyle;

  /// subtitleStyle.
  final TextStyle subtitleStyle;

  @override
  Widget build(BuildContext context) {
    if (title == null && subtitle == null) {
      return const SizedBox.shrink();
    }

    final Widget column = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: center
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: <Widget>[
        if (title != null)
          DefaultTextStyle.merge(style: titleStyle, child: title!),
        if (subtitle != null)
          DefaultTextStyle.merge(style: subtitleStyle, child: subtitle!),
      ],
    );

    if (center) {
      return Align(child: column);
    }
    return column;
  }
}
