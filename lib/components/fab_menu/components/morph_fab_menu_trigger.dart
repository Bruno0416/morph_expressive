part of '../morph_fab_menu.dart';

/// Closed FAB that morphs into the menu's close target.
class _MorphFabMenuTrigger {
  const _MorphFabMenuTrigger(this.menu);

  final _MorphFabMenuState menu;

  Widget build(BuildContext context) {
    return MorphComponentTheme(
      builder: (BuildContext context) {
        final theme = MorphTheme.of(context);
        final fabMenuTheme = theme.fabMenuTheme;
        final fabTheme = theme.fabTheme;
        final metrics = fabTheme.resolve(
          size: menu.widget.size,
          color: menu.widget.color,
          scheme: theme.colorScheme,
        );
        final double closedSize = fabMenuTheme.resolveClosedContainer(
          size: menu.widget.size,
          fabTheme: fabTheme,
        );
        final double openSize = fabMenuTheme.openFabContainer;
        final double closedRadius = metrics.radius;
        final double openRadius = openSize / 2;
        return OverlayPortal(
          controller: menu._portal,
          overlayChildBuilder: (BuildContext context) => _MorphFabMenuOverlay(
            menu,
            closedSize: closedSize,
            openSize: openSize,
          ).build(context),
          child: CompositedTransformTarget(
            link: menu._link,
            child: AnimatedBuilder(
              animation: menu._fabShapeCtrl,
              builder: (BuildContext context, Widget? child) {
                final double t = menu._fabShapeCtrl.value;
                final double radius = lerpDouble(closedRadius, openRadius, t)!;
                final double fabSize = lerpDouble(closedSize, openSize, t)!;
                final MorphFabColor closeColor = MorphFabMenuTheme.closeFabColor(
                  menu._colorSet,
                );
                final bool showClose = t > 0.5;
                final double regularIcon = fabTheme
                    .resolve(
                      size: MorphFabSize.regular,
                      color: closeColor,
                      scheme: theme.colorScheme,
                    )
                    .iconSize;
                final double iconSize = lerpDouble(
                  metrics.iconSize,
                  fabMenuTheme.closeIconSize,
                  t.clamp(0.0, 1.0),
                )!;
                // Morph toward the top trailing corner (shared with the bottom
                // of the menu stack / close button top).
                return SizedBox(
                  key: menu._fabKey,
                  width: closedSize,
                  height: closedSize,
                  child: Align(
                    alignment: menu._fabAlign,
                    child: Opacity(
                      // Overlay owns the interactive close while open.
                      opacity: menu._open ? 0 : 1,
                      child: IgnorePointer(
                        ignoring: menu._open,
                        child: SizedBox(
                          width: fabSize,
                          height: fabSize,
                          child: FittedBox(
                            child: Semantics(
                              button: true,
                              label: 'Toggle menu',
                              expanded: menu._open,
                              child: MorphFab(
                                icon: Transform.scale(
                                  scale: iconSize / regularIcon,
                                  child: showClose
                                      ? menu._resolvedCollapseIcon
                                      : menu._resolvedExpandIcon,
                                ),
                                color: showClose
                                    ? closeColor
                                    : menu.widget.color,
                                size: showClose
                                    ? MorphFabSize.regular
                                    : menu.widget.size,
                                cornerRadius: radius,
                                decoration: showClose
                                    ? null
                                    : menu.widget.decoration,
                                elevation: fabMenuTheme.closeElevation,
                                hoverElevation:
                                    fabMenuTheme.closeHoverElevation,
                                onPressed: menu._toggle,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
