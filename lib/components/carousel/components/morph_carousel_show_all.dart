import 'package:flutter/widgets.dart';

import '../../../foundations/foundations.dart';
import '../../cards/morph_cards.dart';
import '../../icon_buttons/morph_icon_buttons.dart';
import '../../lists/morph_lists.dart';
import 'morph_carousel_item.dart';

/// Vertical page of every carousel item.
///
/// Shown by Show all and the header arrow. Repeats [header] when one was set.
class MorphCarouselShowAll extends StatelessWidget {
  /// MorphCarouselShowAll.
  const MorphCarouselShowAll({required this.children, this.header, super.key});

  /// The same items the carousel shows.
  final List<MorphCarouselItem> children;

  /// Header repeated from the carousel, when it has one.
  final Widget? header;

  @override
  Widget build(BuildContext context) {
    final MorphThemeData theme = MorphTheme.of(context);
    final MorphColorScheme scheme = theme.colorScheme;
    return ColoredBox(
      color: scheme.surface,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            SizedBox(
              height: 48,
              child: Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Row(
                  children: <Widget>[
                    Expanded(child: header ?? const SizedBox.shrink()),
                    MorphIconButton(
                      variant: MorphIconButtonVariant.standard,
                      icon: const Icon(MorphIcons.arrow_back),
                      tooltip: 'Back',
                      onPressed: () =>
                          MorphCardContainerTransformScope.closeOf(context),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: MorphList.scrollable(
                itemCount: children.length,
                listPadding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                itemBuilder: (BuildContext context, int index) {
                  final MorphCarouselItem item = children[index];
                  return MorphListItem(
                    headline: item.semanticLabel ?? 'Item ${index + 1}',
                    leading: SizedBox(width: 56, height: 56, child: item.image),
                    transform: item.transform,
                    onTap: item.onTap,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
