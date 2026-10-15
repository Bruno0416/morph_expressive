part of '../morph_carousel.dart';

/// Header, "Show all" button, and the shared full-item-list transition for
/// [_MorphCarouselState].
extension _MorphCarouselHeader on _MorphCarouselState {
  void _openList(MorphCarouselTheme theme) {
    final box = _trackKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) {
      return;
    }
    final Rect origin = box.localToGlobal(Offset.zero) & box.size;
    final MorphColorScheme scheme = MorphTheme.of(context).colorScheme;
    MorphCardContainerTransform.show<void>(
      context: context,
      origin: origin,
      originRadius: theme.radiusFor(widget.type),
      originColor: scheme.surface,
      builder: (BuildContext context) {
        return MorphCarouselShowAll(
          header: widget.header,
          children: widget.children,
        );
      },
    );
  }

  Widget _header(MorphCarouselTheme theme) {
    return SizedBox(
      height: theme.arrowSize,
      child: Padding(
        padding: EdgeInsetsDirectional.only(start: theme.headerInset)
            .resolve(Directionality.of(context)),
        child: Row(
          children: <Widget>[
            Expanded(child: widget.header!),
            MorphIconButton(
              variant: MorphIconButtonVariant.standard,
              icon: const Icon(MorphIcons.arrow_forward),
              tooltip: 'Show all',
              onPressed: () => _openList(theme),
            ),
          ],
        ),
      ),
    );
  }

  Widget _showAll(MorphCarouselTheme theme) {
    return Align(
      alignment: AlignmentDirectional.centerEnd,
      child: Padding(
        padding: EdgeInsets.only(top: theme.showAllGap),
        child: Padding(
          padding: EdgeInsets.all(theme.showAllPadding),
          child: MorphButton(
            style: MorphButtonStyle.text,
            onPressed: () => _openList(theme),
            child: const Text('Show all'),
          ),
        ),
      ),
    );
  }
}
