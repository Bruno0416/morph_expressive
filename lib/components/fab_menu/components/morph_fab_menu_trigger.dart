part of '../morph_fab_menu.dart';

/// The in-layout slot of the FAB menu. The visible control is one persistent
/// surface (see [_MorphFabMenuOverlay.surface]) that never changes owner:
/// closed, opening, open, closing and interrupted states all paint the same
/// widget, only its size, radius, colors and icon change.
class _MorphFabMenuTrigger {
  const _MorphFabMenuTrigger(this.menu);

  final _MorphFabMenuState menu;

  Widget build(BuildContext context) {
    return MorphComponentTheme(
      builder: (BuildContext context) {
        final theme = MorphTheme.of(context);
        final double closedSize = theme.fabMenuTheme.resolveClosedContainer(
          size: menu.widget.size,
          fabTheme: theme.fabTheme,
        );
        final double openSize = theme.fabMenuTheme.openFabContainer;
        final overlay = _MorphFabMenuOverlay(
          menu,
          closedSize: closedSize,
          openSize: openSize,
        );
        final Widget slot = CompositedTransformTarget(
          link: menu._link,
          child: SizedBox(
            key: menu._fabKey,
            width: closedSize,
            height: closedSize,
          ),
        );
        if (Overlay.maybeOf(context) == null) {
          // No Overlay (isolated tests / custom hosts): paint the surface
          // inline; the menu layer needs an Overlay and stays unavailable.
          return Stack(
            clipBehavior: Clip.none,
            children: <Widget>[
              slot,
              Positioned.fill(child: overlay.surface(context)),
            ],
          );
        }
        return OverlayPortal(
          controller: menu._portal,
          overlayChildBuilder: overlay.build,
          // Until the portal is shown (first frame) the identical closed
          // surface is painted inline, so there is never an empty frame.
          child: menu._portal.isShowing
              ? slot
              : Stack(
                  clipBehavior: Clip.none,
                  children: <Widget>[
                    slot,
                    Positioned.fill(child: overlay.surface(context)),
                  ],
                ),
        );
      },
    );
  }
}
