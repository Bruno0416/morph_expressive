part of '../morph_dialogs.dart';

extension _MorphDialogLayout on MorphDialog {
  Widget _buildDialog(BuildContext context) {
    final MorphThemeData theme = MorphTheme.of(context);
    final MorphDialogTheme dialogTheme = theme.dialogTheme;
    final MorphDialogAppearance appearance = dialogTheme.appearance;
    final MorphColorScheme scheme = theme.colorScheme;
    return Semantics(
      scopesRoute: true,
      namesRoute: true,
      explicitChildNodes: true,
      role: SemanticsRole.alertDialog,
      label: semanticLabel ?? title,
      child: Container(
        constraints: BoxConstraints(
          minWidth: dialogTheme.minWidth,
          maxWidth: dialogTheme.maxWidth,
        ),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: morphDialogTinted(
            appearance.resolveContainer(scheme),
            appearance.surfaceTintColor,
            dialogTheme.elevation,
          ),
          borderRadius: dialogTheme.borderRadius,
          boxShadow: MorphElevation.shadows(
            dialogTheme.elevation,
            shadowColor: scheme.shadow,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: icon == null
              ? CrossAxisAlignment.start
              : CrossAxisAlignment.center,
          children: _buildChildren(theme),
        ),
      ),
    );
  }

  List<Widget> _buildChildren(MorphThemeData theme) {
    final MorphDialogTheme dialogTheme = theme.dialogTheme;
    final EdgeInsets padding = dialogTheme.padding;
    final hasContent = content != null;
    final bool hasActions = actions.isNotEmpty || leadingAction != null;
    final bool showTop = topDivider && (hasContent || hasActions);
    final bool showBottom = bottomDivider && hasActions;
    final double headerBottom = !(hasContent || hasActions)
        ? padding.bottom
        : (hasContent || showTop ? dialogTheme.gapAfterTitle : 0);

    return <Widget>[
      Padding(
        padding: padding.copyWith(bottom: headerBottom),
        child: _buildHeader(theme),
      ),
      if (showTop) _divider(theme),
      if (hasContent)
        Flexible(
          child: SingleChildScrollView(
            controller: scrollController,
            primary: false,
            padding:
                contentPadding ??
                EdgeInsets.fromLTRB(
                  padding.left,
                  showTop ? dialogTheme.gapAfterTitle : 0,
                  padding.right,
                  hasActions
                      ? (showBottom ? dialogTheme.gapBeforeActions : 0)
                      : padding.bottom,
                ),
            child: DefaultTextStyle(
              style: dialogTheme.appearance.resolveSupporting(theme),
              child: content!,
            ),
          ),
        ),
      if (showBottom) _divider(theme),
      if (hasActions)
        Padding(
          padding: padding.copyWith(top: dialogTheme.gapBeforeActions),
          child: MorphDialogActions(
            actions: actions,
            leadingAction: leadingAction,
          ),
        ),
    ];
  }

  Widget _buildHeader(MorphThemeData theme) {
    final MorphDialogTheme dialogTheme = theme.dialogTheme;
    final MorphDialogAppearance appearance = dialogTheme.appearance;
    final TextAlign align = icon == null ? TextAlign.start : TextAlign.center;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: icon == null
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.center,
      children: <Widget>[
        if (icon != null) ...<Widget>[
          IconTheme.merge(
            data: IconThemeData(
              color: appearance.resolveIcon(theme.colorScheme),
              size: dialogTheme.iconSize,
            ),
            child: icon!,
          ),
          SizedBox(height: dialogTheme.gapAfterIcon),
        ],
        MorphDialogHeadline(
          text: title,
          style: appearance.resolveHeadline(theme),
          textAlign: align,
          maxLines: titleMaxLines,
        ),
        if (subhead != null)
          Text(
            subhead!,
            style: appearance.resolveSubhead(theme),
            textAlign: align,
          ),
      ],
    );
  }

  Widget _divider(MorphThemeData theme) {
    final MorphDialogTheme dialogTheme = theme.dialogTheme;
    return MorphDivider(
      color: dialogTheme.appearance.resolveDivider(theme.colorScheme),
      thickness: dialogTheme.dividerThickness,
    );
  }
}
