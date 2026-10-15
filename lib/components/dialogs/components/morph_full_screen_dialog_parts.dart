part of 'morph_full_screen_dialog.dart';

extension _MorphFullScreenDialogParts on _MorphFullScreenDialogState {
  Widget _wrapSurface(MorphThemeData theme, Widget column) {
    final MorphFullScreenDialogTheme fs = theme.dialogTheme.fullScreen;
    final MorphColorScheme scheme = theme.colorScheme;
    final Color color = morphDialogTinted(
      fs.resolveContainer(scheme),
      fs.surfaceTintColor,
      fs.containerElevation,
    );
    return Semantics(
      scopesRoute: true,
      namesRoute: true,
      explicitChildNodes: true,
      role: SemanticsRole.dialog,
      label: widget.semanticLabel ?? widget.title,
      child: Actions(
        actions: <Type, Action<Intent>>{
          DismissIntent: CallbackAction<DismissIntent>(
            onInvoke: (_) {
              _close();
              return null;
            },
          ),
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(fs.cornerRadius),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: color,
              boxShadow: MorphElevation.shadows(
                fs.containerElevation,
                shadowColor: scheme.shadow,
              ),
            ),
            // Header and action bar paint under the system bars (like app
            // bars); only the keyboard pushes the layout up.
            child: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.viewInsetsOf(context).bottom,
              ),
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: fs.maxWidth),
                  child: column,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Side insets plus the [top] status bar / [bottom] navigation bar.
  ///
  /// Read from the view, not [MediaQuery]: edge-to-edge apps (e.g.
  /// `MorphMaterialApp.drawUnderSystemBars`) clear the padding. The bottom
  /// drops to 0 while the keyboard is up.
  EdgeInsets _systemInset({bool top = false, bool bottom = false}) {
    final EdgeInsets system = MorphSafeArea.paddingOf(context);
    return EdgeInsets.only(
      left: system.left,
      right: system.right,
      top: top ? system.top : 0,
      bottom: bottom ? system.bottom : 0,
    );
  }

  Widget _scrollSurface({
    required SingleMotionController motion,
    required Color rest,
    required double restElevation,
    required double scrolledElevation,
    required double height,
    required EdgeInsets inset,
    required Widget child,
  }) {
    final MorphThemeData theme = MorphTheme.of(context);
    final MorphFullScreenDialogTheme fs = theme.dialogTheme.fullScreen;
    return AnimatedBuilder(
      animation: motion,
      child: child,
      builder: (BuildContext context, Widget? child) {
        final double t = morphDialogSnap(motion.value).clamp(0, 1);
        final double elevation = lerpDouble(
          restElevation,
          scrolledElevation,
          t,
        )!;
        final Color base = Color.lerp(
          rest,
          fs.resolveOnScroll(theme.colorScheme),
          t,
        )!;
        return DecoratedBox(
          decoration: BoxDecoration(
            color: morphDialogTinted(base, fs.surfaceTintColor, elevation),
            boxShadow: MorphElevation.shadows(
              elevation,
              shadowColor: theme.colorScheme.shadow,
            ),
          ),
          child: Padding(
            padding: inset,
            child: SizedBox(height: height, child: child),
          ),
        );
      },
    );
  }

  Widget _buildHeader(MorphThemeData theme) {
    final MorphDialogTheme dt = theme.dialogTheme;
    final MorphFullScreenDialogTheme fs = dt.fullScreen;
    final MorphColorScheme scheme = theme.colorScheme;
    final Widget? action = widget.action ?? _confirmAction();
    return _scrollSurface(
      motion: _header!,
      rest: fs.resolveHeader(scheme),
      restElevation: fs.headerElevation,
      scrolledElevation: fs.headerScrolledElevation,
      height: dt.fullScreenHeaderHeight,
      inset: _systemInset(top: true),
      child: Row(
        children: <Widget>[
          SizedBox(width: dt.headerEdgeGap),
          MorphIconButton(
            variant: MorphIconButtonVariant.standard,
            icon: widget.closeIcon ?? const Icon(MorphIcons.close),
            onPressed: _close,
            tooltip: widget.closeLabel,
            semanticLabel: widget.closeLabel,
            decoration: MorphIconButtonDecoration(
              foregroundColor: WidgetStatePropertyAll<Color?>(
                fs.resolveIcon(scheme),
              ),
            ),
          ),
          SizedBox(width: fs.closeTitleGap),
          Expanded(
            child: Text(
              widget.title,
              style: fs.resolveHeadline(theme),
              textAlign: TextAlign.start,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (action != null) ...<Widget>[
            SizedBox(width: dt.actionGap),
            _actionScope(theme, action),
            SizedBox(width: dt.headerActionGap),
          ],
        ],
      ),
    );
  }

  /// Header and action bar text buttons use the full-screen action tokens.
  Widget _actionScope(MorphThemeData theme, Widget child) {
    final MorphFullScreenDialogTheme fs = theme.dialogTheme.fullScreen;
    return morphDialogActionScope(
      color: fs.resolveAction(theme.colorScheme),
      textStyle: fs.resolveActionText(theme),
      overlay: theme.dialogTheme.appearance.actionOverlay,
      child: child,
    );
  }

  Widget? _confirmAction() {
    final String? label = widget.confirmLabel;
    if (label == null) {
      return null;
    }
    return morphDialogTextAction(label: label, onPressed: widget.onConfirm);
  }

  Widget _buildContent(MorphThemeData theme) {
    final MorphFullScreenDialogTheme fs = theme.dialogTheme.fullScreen;
    final String? headline = widget.contentHeadline;
    Widget content = widget.body;
    if (headline != null) {
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(headline, style: fs.resolveContentHeadline(theme)),
          SizedBox(height: fs.elementGap),
          Expanded(child: content),
        ],
      );
    }
    return NotificationListener<ScrollMetricsNotification>(
      onNotification: (ScrollMetricsNotification n) {
        _onMetrics(n.metrics);
        return false;
      },
      child: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification n) {
          _onMetrics(n.metrics);
          return false;
        },
        child: Padding(
          padding: _systemInset(bottom: widget.bottomActions.isEmpty),
          child: Padding(
            padding: widget.contentPadding ?? fs.contentPadding,
            child: DefaultTextStyle.merge(
              style: fs.resolveContent(theme),
              child: content,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionBar(MorphThemeData theme) {
    final MorphDialogTheme dt = theme.dialogTheme;
    final MorphFullScreenDialogTheme fs = dt.fullScreen;
    return _scrollSurface(
      motion: _bar!,
      rest: fs.resolveActionBar(theme.colorScheme),
      restElevation: fs.actionBarElevation,
      scrolledElevation: fs.actionBarScrolledElevation,
      height: fs.actionBarHeight,
      inset: _systemInset(bottom: true),
      child: Padding(
        padding: fs.actionBarPadding,
        child: _actionScope(
          theme,
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            spacing: dt.actionGap,
            children: widget.bottomActions,
          ),
        ),
      ),
    );
  }
}
