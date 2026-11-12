part of '../morph_fab_menu.dart';

/// Overlay content: scrim and items (only while open or collapsing) and the
/// single persistent main surface.
class _MorphFabMenuOverlay {
  const _MorphFabMenuOverlay(
    this.menu, {
    required this.closedSize,
    required this.openSize,
  });

  final _MorphFabMenuState menu;
  final double closedSize;
  final double openSize;

  Widget build(BuildContext context) {
    final bool right = menu._isRight;
    return AnimatedBuilder(
      animation: Listenable.merge(<Listenable>[
        menu._fabShapeCtrl,
        ...menu._itemCtrls,
      ]),
      builder: (BuildContext context, Widget? _) {
        return FocusTraversalGroup(
          policy: OrderedTraversalPolicy(),
          child: FocusScope(
            node: menu._menuFocusScope,
            skipTraversal: true,
            child: CallbackShortcuts(
              bindings: <ShortcutActivator, VoidCallback>{
                if (menu._open)
                  const SingleActivator(LogicalKeyboardKey.escape): menu._close,
              },
              child: Stack(
                clipBehavior: Clip.none,
                children: <Widget>[
                  if (menu._menuLayerVisible)
                    KeyedSubtree(
                      key: const ValueKey<String>('fab-menu-layer'),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: <Widget>[
                          _dismissBarrier(context),
                          CompositedTransformFollower(
                            link: menu._link,
                            showWhenUnlinked: false,
                            targetAnchor: right
                                ? Alignment.topRight
                                : Alignment.topLeft,
                            followerAnchor: right
                                ? Alignment.topRight
                                : Alignment.topLeft,
                            child: _menuStack(context),
                          ),
                        ],
                      ),
                    ),
                  KeyedSubtree(
                    key: const ValueKey<String>('fab-menu-surface'),
                    child: CompositedTransformFollower(
                      link: menu._link,
                      showWhenUnlinked: false,
                      targetAnchor: right
                          ? Alignment.topRight
                          : Alignment.topLeft,
                      followerAnchor: right
                          ? Alignment.topRight
                          : Alignment.topLeft,
                      child: SizedBox(
                        width: closedSize,
                        height: closedSize,
                        child: surface(context),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _dismissBarrier(BuildContext context) {
    final theme = MorphTheme.of(context);
    final Color scrim = theme.fabMenuTheme.scrimColor(theme.colorScheme);
    final double t = menu._fabShapeCtrl.value.clamp(0.0, 1.0);
    return Positioned.fill(
      child: IgnorePointer(
        ignoring: !menu._open,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: menu._close,
          child: ColoredBox(color: scrim.withValues(alpha: scrim.a * t)),
        ),
      ),
    );
  }

  double _spaceAboveFab() {
    final box = menu._fabKey.currentContext?.findRenderObject();
    if (box is! RenderBox || !box.hasSize) {
      return 240;
    }
    final fabTop = box.localToGlobal(Offset.zero).dy;
    final safeTop = MediaQuery.paddingOf(menu.context).top;
    return (fabTop - safeTop).clamp(0.0, double.infinity);
  }

  Widget _menuStack(BuildContext context) {
    final theme = MorphTheme.of(context);
    final fabMenuTheme = theme.fabMenuTheme;
    final double spaceAbove = _spaceAboveFab();
    final double mediaWidth = MediaQuery.sizeOf(context).width;
    // Items sit above the closed-size slot; the surface is a separate,
    // persistent sibling and is never part of this layer.
    return Transform.translate(
      offset: Offset(0, -spaceAbove),
      child: SizedBox(
        width: mediaWidth,
        height: spaceAbove + closedSize,
        child: Padding(
          padding: EdgeInsets.only(
            bottom: closedSize + fabMenuTheme.menuOffset,
          ),
          child: Align(
            alignment: menu._isRight
                ? Alignment.bottomRight
                : Alignment.bottomLeft,
            child: SingleChildScrollView(
              primary: false,
              reverse: true,
              child: ExcludeSemantics(
                excluding: !menu._open,
                child: MorphMenuSemantics(
                  child: _MorphFabMenuItems(menu).build(theme),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// The one main control. Size, radius and colors interpolate with the
  /// surface controller (which may be interrupted at any value); only the
  /// icon cross-fades with its own animation.
  Widget surface(BuildContext context) {
    final theme = MorphTheme.of(context);
    final fabMenuTheme = theme.fabMenuTheme;
    final fabTheme = theme.fabTheme;
    final MorphFabColor closeColor = MorphFabMenuTheme.closeFabColor(
      menu._colorSet,
    );
    final closed = fabTheme.resolve(
      size: menu.widget.size,
      color: menu.widget.color,
      scheme: theme.colorScheme,
    );
    final opened = fabTheme.resolve(
      size: MorphFabSize.regular,
      color: closeColor,
      scheme: theme.colorScheme,
    );
    const noStates = <WidgetState>{};
    final Color closedBg =
        menu.widget.decoration?.backgroundColor?.resolve(noStates) ??
        closed.background;
    final Color closedFg =
        menu.widget.decoration?.foregroundColor?.resolve(noStates) ??
        closed.foreground;
    final Gradient? gradient = menu.widget.decoration?.backgroundGradient
        ?.resolve(noStates);
    final BorderSide? closedSide = menu.widget.decoration?.side?.resolve(
      noStates,
    );
    final Gradient? outline = menu.widget.decoration?.outlineGradient?.resolve(
      noStates,
    );
    return AnimatedBuilder(
      animation: menu._fabShapeCtrl,
      builder: (BuildContext context, Widget? _) {
        final double t = menu._fabShapeCtrl.value;
        final double c = t.clamp(0.0, 1.0);
        final double size = lerpDouble(closedSize, openSize, t)!;
        final double radius = lerpDouble(
          closed.radius,
          openSize / 2,
          t,
        )!.clamp(0.0, size / 2).toDouble();
        final Color bg = Color.lerp(closedBg, opened.background, c)!;
        final Color fg = Color.lerp(closedFg, opened.foreground, c)!;
        final double iconSize = lerpDouble(
          closed.iconSize,
          fabMenuTheme.closeIconSize,
          c,
        )!;
        return Align(
          alignment: menu._fabAlign,
          child: Semantics(
            button: true,
            label: 'Toggle menu',
            expanded: menu._open,
            child: ValueListenableBuilder<bool>(
              valueListenable: menu._surfaceFocused,
              builder: (BuildContext context, bool focused, _) => MorphFocusRing(
                focused: focused && MorphFocusInteraction.instance.ringsAllowed,
                radius: BorderRadius.circular(radius),
                child: SizedBox(
                  width: size,
                  height: size,
                  child: MorphSmoothEdges(
                    child: Stack(
                      children: <Widget>[
                        Positioned.fill(
                          child: MorphRoundedSurface(
                            size: Size(size, size),
                            radius: radius,
                            color: bg,
                            gradient: gradient,
                            // Decoration applies to the closed look and fades
                            // out as the surface becomes the close button.
                            side: closedSide?.copyWith(
                              width: closedSide.width * (1 - c),
                            ),
                            outlineGradient: outline,
                            elevation: fabMenuTheme.closeElevation,
                            shadowColor: theme.colorScheme.shadow,
                            renderer: menu.widget.renderer,
                            onRendererChanged: menu._onSurfaceRenderer,
                          ),
                        ),
                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(radius),
                            // Clip the Material itself: existing ink features
                            // retain their creation-time customBorder.
                            child: Material(
                              type: MaterialType.transparency,
                              child: InkWell(
                                focusNode: menu._closeFocusNode,
                                overlayColor:
                                    menu.widget.decoration?.overlayColor,
                                onFocusChange: (bool v) =>
                                    menu._surfaceFocused.value = v,
                                onTap: menu._onSurfacePressed,
                                child: Center(child: _icon(c, fg, iconSize)),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _icon(double c, Color fg, double iconSize) {
    // Own animation: expand icon turns away while the collapse icon turns in.
    return IconTheme(
      data: IconThemeData(color: fg, size: iconSize),
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Opacity(
            opacity: (1 - 2 * c).clamp(0.0, 1.0),
            child: Transform.rotate(
              angle: c * 1.5707963267948966,
              child: menu._resolvedExpandIcon,
            ),
          ),
          Opacity(
            opacity: (2 * c - 1).clamp(0.0, 1.0),
            child: Transform.rotate(
              angle: (c - 1) * 1.5707963267948966,
              child: menu._resolvedCollapseIcon,
            ),
          ),
        ],
      ),
    );
  }
}
