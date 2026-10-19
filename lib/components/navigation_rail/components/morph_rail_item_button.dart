import 'dart:ui' show SemanticsRole;

import 'package:material_ui/material_ui.dart';

import '../../../foundations/foundations.dart';
import '../enums/morph_navigation_rail_enums.dart';
import '../styles/morph_navigation_rail_theme.dart';
import 'morph_nav_icon_scale.dart';
import 'morph_nav_selection_indicator.dart';
import 'morph_rail_badge_view.dart';

/// One rail destination. The hit target is the full rail width. Collapsed
/// pills hug the icon. Expanded pills hug the icon and label, inset from
/// the rail edge.
class MorphRailItemButton extends StatelessWidget {
  /// Creates a [MorphRailItemButton].
  const MorphRailItemButton({
    super.key,
    required this.icon,
    this.selectedIcon,
    required this.isSelected,
    required this.onPressed,
    required this.expanded,
    required this.labelBehavior,
    required this.label,
    this.semanticLabel,
    this.suppressInk = false,
    this.badgeCount,
    this.heightOverride,
    this.short = false,
    this.focusNode,
    this.skipTraversal = false,
    this.haptic = MorphHapticFeedback.inherit,
  });

  /// Icon to display.
  final Widget icon;

  /// Optional icon to display when [isSelected] is true.
  final Widget? selectedIcon;

  /// Whether this destination is currently selected.
  final bool isSelected;

  /// Callback when the button is tapped.
  final VoidCallback onPressed;

  /// Whether the rail is in expanded layout.
  final bool expanded;

  /// Controls when the text label is visible.
  final MorphNavigationRailLabelBehavior labelBehavior;

  /// Text label for the destination.
  final String label;

  /// Semantic label used for accessibility.
  final String? semanticLabel;

  /// If true, suppresses the splash while the rail is changing width.
  final bool suppressInk;

  /// Optional numeric badge value to show.
  final int? badgeCount;

  /// Optional min height for the tap target.
  final double? heightOverride;

  /// Uses the short, unlabeled item height.
  final bool short;

  /// Focus node owned by the rail.
  final FocusNode? focusNode;

  /// When true, Tab skips this destination.
  final bool skipTraversal;

  /// Haptic intensity on tap.
  final MorphHapticFeedback haptic;

  bool _showLabel(bool selected) {
    return switch (labelBehavior) {
      MorphNavigationRailLabelBehavior.alwaysShow => true,
      MorphNavigationRailLabelBehavior.onlySelected => selected,
      MorphNavigationRailLabelBehavior.alwaysHide => false,
    };
  }

  @override
  Widget build(BuildContext context) {
    final MorphNavigationRailTheme theme = MorphTheme.of(context)
        .navigationRailTheme;
    final MorphThemeData morph = MorphTheme.of(context);
    final bool showLabel = _showLabel(isSelected) && label.isNotEmpty;
    final bool unlabeled = short || !showLabel;
    final double height =
        heightOverride ??
        (expanded
            ? theme.itemExpandedHeight
            : (unlabeled ? theme.shortItemHeight : theme.itemCollapsedHeight));
    return Semantics(
      role: SemanticsRole.menuItem,
      selected: isSelected,
      label: semanticLabel ?? label,
      onTap: onPressed,
      child: MorphTappable(
        focusNode: focusNode,
        skipTraversal: skipTraversal,
        focusOverlay: false,
        materialInk: true,
        semanticButton: false,
        excludeSemantics: true,
        haptic: haptic,
        onTap: onPressed,
        builder: (BuildContext context, MorphInteractionState state) {
          return Builder(
            builder: (BuildContext inkContext) {
              final MorphTappableInkScope? ink = MorphTappableInkScope.maybeOf(
                inkContext,
              );
              return InkWell(
                enableFeedback: false,
                onTap: ink?.onTap,
                onLongPress: ink?.onLongPress,
                onHover: ink?.onHover,
                mouseCursor: ink?.mouseCursor ?? SystemMouseCursors.click,
                canRequestFocus: false,
                splashFactory: NoSplash.splashFactory,
                splashColor: const Color(0x00000000),
                highlightColor: const Color(0x00000000),
                overlayColor: const WidgetStatePropertyAll<Color>(
                  Color(0x00000000),
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: height),
                  child: expanded
                      ? _expanded(inkContext, state, theme, morph, showLabel)
                      : _collapsed(
                          inkContext,
                          state,
                          theme,
                          morph,
                          showLabel,
                          unlabeled,
                        ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _collapsed(
    BuildContext context,
    MorphInteractionState state,
    MorphNavigationRailTheme theme,
    MorphThemeData morph,
    bool showLabel,
    bool unlabeled,
  ) {
    final double pillWidth = unlabeled
        ? theme.noLabelIndicatorSize
        : theme.verticalIndicatorWidth;
    final double pillHeight = unlabeled
        ? theme.noLabelIndicatorSize
        : theme.verticalIndicatorHeight;
    final double radius = unlabeled
        ? theme.noLabelIndicatorSize / 2
        : theme.verticalIndicatorRadius;
    final bool narrow =
        (theme.collapsedWidth - theme.narrowCollapsedWidth).abs() < 0.5;
    final double inset = narrow
        ? theme.narrowHorizontalPadding
        : theme.collapsedHorizontalPadding;
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: inset,
        vertical: theme.itemVerticalPadding,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            width: pillWidth,
            height: pillHeight,
            child: _pillStack(
              context,
              state,
              theme,
              morph,
              radius: radius,
              icon: _icon(morph, theme, collapsedBadge: true),
            ),
          ),
          if (showLabel) ...<Widget>[
            SizedBox(height: theme.verticalIconLabelGap),
            _label(theme),
          ],
        ],
      ),
    );
  }

  Widget _expanded(
    BuildContext context,
    MorphInteractionState state,
    MorphNavigationRailTheme theme,
    MorphThemeData morph,
    bool showLabel,
  ) {
    final bool fill = theme.indicatorFillsWidth;
    final Widget pill = _pillStack(
      context,
      state,
      theme,
      morph,
      radius: theme.expandedIndicatorRadius,
      alignment: AlignmentDirectional.centerStart,
      icon: ConstrainedBox(
        constraints: BoxConstraints(minHeight: theme.expandedIndicatorHeight),
        child: Padding(
          padding: EdgeInsetsDirectional.only(
            start: theme.indicatorLeading,
            end: theme.indicatorTrailing,
          ),
          child: Row(
            mainAxisSize: fill ? MainAxisSize.max : MainAxisSize.min,
            children: <Widget>[
              _icon(morph, theme, collapsedBadge: false),
              if (showLabel) ...<Widget>[
                SizedBox(width: theme.iconLabelGap),
                Flexible(child: _label(theme)),
              ],
              if (badgeCount != null) ...<Widget>[
                SizedBox(width: theme.iconLabelGap),
                MorphRailBadge.standalone(count: badgeCount),
              ],
            ],
          ),
        ),
      ),
    );
    return Padding(
      padding: EdgeInsetsDirectional.symmetric(
        horizontal: theme.expandedItemInset,
      ),
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: fill ? SizedBox(width: double.infinity, child: pill) : pill,
      ),
    );
  }

  Widget _pillStack(
    BuildContext context,
    MorphInteractionState state,
    MorphNavigationRailTheme theme,
    MorphThemeData morph, {
    required double radius,
    required Widget icon,
    AlignmentGeometry alignment = Alignment.center,
  }) {
    final bool interacting = state.hovered || state.focused || state.pressed;
    final Color? overlay = _layerOpacity(state, theme) > 0
        ? theme
              .stateLayerColorResolved(morph.colorScheme)
              .withValues(alpha: _layerOpacity(state, theme))
        : null;
    return Stack(
      alignment: alignment,
      children: <Widget>[
        Positioned.fill(
          child: MorphSelectionIndicator(
            selected: isSelected,
            scaleSpring: theme.indicatorScaleSpring,
            fadeSpring: theme.indicatorFadeSpring,
            child: _pillFill(theme, morph, radius, isSelected ? overlay : null),
          ),
        ),
        if (!isSelected && interacting)
          Positioned.fill(child: _pillFill(theme, morph, radius, overlay)),
        if (state.focused) _ring(context, theme, radius),
        icon,
      ],
    );
  }

  Widget _pillFill(
    MorphNavigationRailTheme theme,
    MorphThemeData morph,
    double radius,
    Color? overlay,
  ) {
    final border = BorderRadius.circular(radius);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.activeIndicatorColorResolved(morph.colorScheme),
        borderRadius: border,
      ),
      child: ClipRRect(
        borderRadius: border,
        child: overlay == null
            ? const SizedBox.expand()
            : ColoredBox(color: overlay, child: const SizedBox.expand()),
      ),
    );
  }

  double _layerOpacity(
    MorphInteractionState state,
    MorphNavigationRailTheme theme,
  ) {
    if (state.pressed) {
      return theme.pressedOpacity;
    }
    if (state.focused) {
      return theme.focusOpacity;
    }
    if (state.hovered) {
      return theme.hoverOpacity;
    }
    return 0;
  }

  Widget _ring(
    BuildContext context,
    MorphNavigationRailTheme theme,
    double radius,
  ) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Padding(
          padding: EdgeInsets.all(theme.focusRingInset),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(radius),
              border: Border.all(
                color: theme.focusRingColorResolved(
                  MorphTheme.of(context).colorScheme,
                ),
                width: theme.focusRingThickness,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _icon(
    MorphThemeData morph,
    MorphNavigationRailTheme theme, {
    required bool collapsedBadge,
  }) {
    final bool selected = isSelected;
    final Color color = selected
        ? theme.activeIconColor(morph.colorScheme)
        : theme.inactiveIconAndLabelColor(morph.colorScheme);
    final Widget glyph = MorphNavIconScale(
      selected: selected,
      child: IconTheme.merge(
        data: IconThemeData(
          color: color,
          size: theme.iconSize,
          weight: selected && selectedIcon == null ? 600 : null,
        ),
        child: selected && selectedIcon != null ? selectedIcon! : icon,
      ),
    );
    if (!collapsedBadge || badgeCount == null) {
      return glyph;
    }
    return MorphRailBadge(count: badgeCount, child: glyph);
  }

  Widget _label(MorphNavigationRailTheme theme) {
    return Builder(
      builder: (BuildContext context) {
        final double scale = MediaQuery.textScalerOf(context)
            .scale(theme.labelFontSize);
        final double unit = scale / theme.labelFontSize;
        final bool truncate = unit > theme.truncationTextScale;
        final bool wrap = unit > 1 && !truncate;
        return Text(
          label,
          maxLines: truncate
              ? 1
              : wrap
              ? theme.scaledLabelMaxLines
              : 1,
          overflow: truncate ? TextOverflow.ellipsis : TextOverflow.visible,
          textAlign: expanded ? TextAlign.start : TextAlign.center,
          style: theme.labelStyle(
            MorphTheme.of(context).colorScheme,
            selected: isSelected,
          ),
        );
      },
    );
  }
}
